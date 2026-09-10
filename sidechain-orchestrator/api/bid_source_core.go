package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"

	"connectrpc.com/connect"
	"github.com/samber/lo"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// coreBids reads our own bid out of Bitcoin Core.
type coreBids struct{ h *BMMHandler }

func (c coreBids) spends(ctx context.Context, _, txid string) ([]*wpb.UnspentOutput, error) {
	raw, err := c.h.coreCall(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("read bid %s: %w", txid, err))
	}
	var tx struct {
		Vin []struct {
			Txid string `json:"txid"`
			Vout uint32 `json:"vout"`
		} `json:"vin"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode bid %s: %w", txid, err))
	}
	if len(tx.Vin) == 0 {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bid %s has no inputs to reuse", txid))
	}
	return lo.Map(tx.Vin, func(in struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	}, _ int) *wpb.UnspentOutput {
		return &wpb.UnspentOutput{Txid: in.Txid, Vout: int32(in.Vout)}
	}), nil
}

// pending says whether one transaction is an unconfirmed BMM request. The slot
// does not matter: one wallet funds the bids of every slot, so a bid for
// another slot can sit between two of ours, and stopping there would leave the
// stranded bid under it in place. A replacement evicts that other bid, and its
// own engine bids again on the next tip.
//
// Everything else stops the walk. A read that fails stops it too, because a
// coin the node cannot name is one the replacement keeps.
func (c coreBids) pending(ctx context.Context, _, txid string) bool {
	raw, err := c.h.coreCall(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return false
	}
	var tx struct {
		Confirmations int `json:"confirmations"`
		Vout          []struct {
			ScriptPubKey struct {
				Hex string `json:"hex"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil || tx.Confirmations > 0 || len(tx.Vout) == 0 {
		return false
	}
	script, err := hex.DecodeString(tx.Vout[0].ScriptPubKey.Hex)
	if err != nil {
		return false
	}
	return orchestrator.ParseM8BmmRequestScript(script) != nil
}

// feeSats reads what one mempool transaction pays after the deltas a node
// applied, which is the number Core's own replacement rule compares. It
// reports false for a transaction the mempool no longer holds.
func (c coreBids) feeSats(ctx context.Context, _, txid string) (int64, bool, error) {
	fees, ok, err := c.mempoolFees(ctx, txid)
	return fees.Modified, ok, err
}

// paidSats reads what one mempool transaction pays a miner. A node delta
// changes what a replacement has to beat, not what the transaction spent.
func (c coreBids) paidSats(ctx context.Context, _, txid string) (int64, bool, error) {
	fees, ok, err := c.mempoolFees(ctx, txid)
	return fees.Base, ok, err
}

// mempoolFeeSats holds the two fees a mempool entry reports, in sats.
type mempoolFeeSats struct {
	Base     int64
	Modified int64
}

func (c coreBids) mempoolFees(ctx context.Context, txid string) (mempoolFeeSats, bool, error) {
	raw, err := c.h.coreCall(ctx, "getmempoolentry", fmt.Sprintf("[%q]", txid))
	if err != nil {
		return mempoolFeeSats{}, false, nil
	}
	var entry struct {
		Fees struct {
			Base     float64 `json:"base"`
			Modified float64 `json:"modified"`
		} `json:"fees"`
	}
	if err := json.Unmarshal(raw, &entry); err != nil {
		return mempoolFeeSats{}, false, connect.NewError(connect.CodeInternal,
			fmt.Errorf("decode mempool entry %s: %w", txid, err))
	}
	return mempoolFeeSats{
		Base:     int64(math.Round(entry.Fees.Base * 1e8)),
		Modified: int64(math.Round(entry.Fees.Modified * 1e8)),
	}, true, nil
}

// evicted names every transaction the replacement removes: each root of the
// chain and everything the mempool holds over it.
func (c coreBids) evicted(ctx context.Context, roots, _ []string) []string {
	// One chain can carry two roots, and a bid over both of them belongs to
	// each root's descendants. So each transaction counts one time, by txid.
	seen := make(map[string]bool)
	var all []string
	for _, root := range roots {
		for _, txid := range append([]string{root}, c.mempoolDescendants(ctx, root)...) {
			if seen[txid] {
				continue
			}
			seen[txid] = true
			all = append(all, txid)
		}
	}
	return all
}

// mempoolDescendants names every transaction the mempool holds over one
// transaction. A read that fails names none, and the floor then counts the
// transactions it does know.
func (c coreBids) mempoolDescendants(ctx context.Context, txid string) []string {
	raw, err := c.h.coreCall(ctx, "getmempooldescendants", fmt.Sprintf("[%q]", txid))
	if err != nil {
		return nil
	}
	var txids []string
	if err := json.Unmarshal(raw, &txids); err != nil {
		return nil
	}
	return txids
}

// PendingTxids names every transaction the mainchain mempool holds. Our own
// bids are among them, whichever wallet funded them.
func (c coreBids) PendingTxids(ctx context.Context, _ []string) (map[string]bool, error) {
	raw, err := c.h.coreCall(ctx, "getrawmempool", "[false]")
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get raw mempool: %w", err))
	}
	var txids []string
	if err := json.Unmarshal(raw, &txids); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode mempool: %w", err))
	}
	held := make(map[string]bool, len(txids))
	for _, txid := range txids {
		held[txid] = true
	}
	return held, nil
}
