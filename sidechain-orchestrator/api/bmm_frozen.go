package api

import (
	"context"
	"encoding/json"
	"fmt"
	"slices"

	"connectrpc.com/connect"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// FrozenCoins returns the candidate outpoints a live BMM bid can remove, keyed by txid:vout.
func (h *BMMHandler) FrozenCoins(
	ctx context.Context, walletID string, candidates []wallet.Outpoint,
) (map[string]bool, error) {
	if len(candidates) == 0 {
		return nil, nil
	}
	return h.bids().FrozenCoins(ctx, walletID, candidates)
}

// frozenCoins reads the mainchain mempool, which names every bid the node
// relayed, ours and anyone else's.
func (c coreBids) frozenCoins(
	ctx context.Context, walletID string, candidates []wallet.Outpoint,
) (map[string]bool, error) {
	held, err := c.PendingTxids(ctx, []string{walletID})
	if err != nil {
		return nil, err
	}
	bids := newBidCache(c.h)

	frozen := make(map[string]bool)
	for _, cand := range candidates {
		if !held[cand.TxID] {
			// An Electrum wallet broadcasts through Esplora and lists its own
			// change before Core sees the transaction that paid it. A coin no
			// block holds, and no mempool names, can still be a bid's change.
			if !cand.Confirmed {
				frozen[cand.Key()] = true
			}
			continue
		}
		onABid, err := bids.overABid(ctx, cand.TxID)
		if err != nil {
			return nil, err
		}
		if onABid {
			frozen[cand.Key()] = true
		}
	}

	spent, err := c.h.bidSpentCoins(ctx, candidates, bids)
	if err != nil {
		return nil, err
	}
	for key := range spent {
		frozen[key] = true
	}
	return frozen, nil
}

// bidSpentCoins names the candidates a live bid already spends. A second spend
// of one conflicts with that bid, and the node takes it only as a replacement
// that pays more.
func (h *BMMHandler) bidSpentCoins(
	ctx context.Context, candidates []wallet.Outpoint, bids *bidCache,
) (map[string]bool, error) {
	if !h.ReadsMempool() {
		return nil, nil
	}
	if bids == nil {
		bids = newBidCache(h)
	}
	spenders, err := h.mempoolSpenders(ctx, candidates)
	if err != nil {
		return nil, err
	}
	spent := make(map[string]bool, len(spenders))
	for key, txid := range spenders {
		bid, err := bids.get(ctx, txid)
		if err != nil {
			return nil, err
		}
		if bid != nil {
			spent[key] = true
		}
	}
	return spent, nil
}

func newBidCache(h *BMMHandler) *bidCache {
	return &bidCache{
		h:       h,
		read:    map[string]*orchestrator.BmmRequest{},
		lineage: map[string]*orchestrator.BmmRequest{},
	}
}

// bidCache reads the bid a transaction carries one time.
type bidCache struct {
	h    *BMMHandler
	read map[string]*orchestrator.BmmRequest
	// lineage names the bid each transaction carries or descends from.
	lineage map[string]*orchestrator.BmmRequest
}

// overABid says whether the transaction carries a bid, or spends the coins of
// one through its mempool ancestors. A replacement of the bid evicts the whole
// line below it.
func (c *bidCache) overABid(ctx context.Context, txid string) (bool, error) {
	bid, err := c.lineageBid(ctx, txid)
	if err != nil {
		return false, err
	}
	return bid != nil, nil
}

// lineageBid names the bid a transaction carries, or the bid its mempool
// ancestors carry. It answers nil for a line that holds none.
func (c *bidCache) lineageBid(ctx context.Context, txid string) (*orchestrator.BmmRequest, error) {
	if bid, done := c.lineage[txid]; done {
		return bid, nil
	}
	bid, err := c.get(ctx, txid)
	if err != nil {
		return nil, err
	}
	if bid == nil {
		ancestors, err := c.h.mempoolAncestors(ctx, txid)
		if err != nil {
			return nil, err
		}
		for _, ancestor := range ancestors {
			bid, err = c.get(ctx, ancestor)
			if err != nil {
				return nil, err
			}
			if bid != nil {
				break
			}
		}
	}
	c.lineage[txid] = bid
	return bid, nil
}

func (c *bidCache) get(ctx context.Context, txid string) (*orchestrator.BmmRequest, error) {
	if bid, done := c.read[txid]; done {
		return bid, nil
	}
	bid, err := c.h.m8Request(ctx, txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	c.read[txid] = bid
	return bid, nil
}

// mempoolAncestors names every unconfirmed ancestor of a mempool transaction.
func (h *BMMHandler) mempoolAncestors(ctx context.Context, txid string) ([]string, error) {
	raw, err := h.coreCall(ctx, "getmempoolancestors", fmt.Sprintf("[%q]", txid))
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf(
			"read the ancestors of %s: %w", txid, err))
	}
	var ancestors []string
	if err := json.Unmarshal(raw, &ancestors); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf(
			"decode the ancestors of %s: %w", txid, err))
	}
	return ancestors, nil
}

// spenderQueryLimit is what one gettxspendingprevout call takes. Bitcoin Core
// refuses a larger query.
const spenderQueryLimit = 100

// mempoolSpenders names the mempool transaction that spends each candidate, by
// the txid:vout of the candidate. It skips a candidate no transaction spends.
func (h *BMMHandler) mempoolSpenders(
	ctx context.Context, candidates []wallet.Outpoint,
) (map[string]string, error) {
	out := make(map[string]string, len(candidates))
	for batch := range slices.Chunk(candidates, spenderQueryLimit) {
		if err := h.readSpenderBatch(ctx, batch, out); err != nil {
			return nil, err
		}
	}
	return out, nil
}

func (h *BMMHandler) readSpenderBatch(
	ctx context.Context, candidates []wallet.Outpoint, out map[string]string,
) error {
	outputs := make([]map[string]any, 0, len(candidates))
	for _, c := range candidates {
		outputs = append(outputs, map[string]any{"txid": c.TxID, "vout": c.Vout})
	}
	params, err := json.Marshal([]any{outputs})
	if err != nil {
		return connect.NewError(connect.CodeInternal, fmt.Errorf("build the spender query: %w", err))
	}

	raw, err := h.coreCall(ctx, "gettxspendingprevout", string(params))
	if err != nil {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf("read the spenders of the wallet coins: %w", err))
	}
	var spends []struct {
		Txid         string `json:"txid"`
		Vout         int    `json:"vout"`
		SpendingTxid string `json:"spendingtxid"`
	}
	if err := json.Unmarshal(raw, &spends); err != nil {
		return connect.NewError(connect.CodeInternal, fmt.Errorf("decode the spenders of the wallet coins: %w", err))
	}

	for _, s := range spends {
		if s.SpendingTxid == "" {
			continue
		}
		out[wallet.Outpoint{TxID: s.Txid, Vout: s.Vout}.Key()] = s.SpendingTxid
	}
	return nil
}
