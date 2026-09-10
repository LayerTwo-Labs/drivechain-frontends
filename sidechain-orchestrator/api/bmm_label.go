package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// coreReader calls one mainchain Core RPC method.
type coreReader func(ctx context.Context, method, paramsJSON string) (json.RawMessage, error)

// BidLabel reads a BMM request from an output's scriptPubKey and says whether
// the bid can still win. tipHash is the current mainchain tip. It returns nil
// for every other script.
func BidLabel(scriptHex, tipHash string) *wpb.BmmBid {
	script, err := hex.DecodeString(scriptHex)
	if err != nil {
		return nil
	}
	req := orchestrator.ParseM8BmmRequestScript(script)
	if req == nil {
		return nil
	}
	return &wpb.BmmBid{
		Slot:         uint32(req.Slot),
		CriticalHash: req.CriticalHash,
		PrevMainHash: req.PrevMainHash,
		// A bid names one parent block, so a moved tip strands it. An unknown
		// tip leaves the bid live rather than calling a winnable bid lost.
		Lost: tipHash != "" && tipHash != req.PrevMainHash,
	}
}

// BidLabels names the BMM request each mempool transaction carries. A
// transaction the node cannot read, or the mempool does not hold, gets no label.
func BidLabels(ctx context.Context, call coreReader, txids []string) map[string]*wpb.BmmBid {
	if len(txids) == 0 {
		return nil
	}
	tip, err := coreTipHash(ctx, call)
	if err != nil {
		return nil
	}
	out := make(map[string]*wpb.BmmBid, len(txids))
	for _, txid := range txids {
		if _, done := out[txid]; done {
			continue
		}
		script, err := firstOutputScript(ctx, call, txid)
		if err != nil {
			continue
		}
		if bid := BidLabel(script, tip); bid != nil && inMempool(ctx, call, txid) {
			out[txid] = bid
		}
	}
	return out
}

// inMempool says whether the mempool holds txid. A replaced bid stays in the
// wallet with no confirmations, but the mempool drops it.
func inMempool(ctx context.Context, call coreReader, txid string) bool {
	_, err := call(ctx, "getmempoolentry", fmt.Sprintf("[%q]", txid))
	return err == nil
}

func coreTipHash(ctx context.Context, call coreReader) (string, error) {
	raw, err := call(ctx, "getbestblockhash", "[]")
	if err != nil {
		return "", fmt.Errorf("read the mainchain tip: %w", err)
	}
	var hash string
	if err := json.Unmarshal(raw, &hash); err != nil {
		return "", fmt.Errorf("decode the mainchain tip: %w", err)
	}
	return hash, nil
}

func firstOutputScript(ctx context.Context, call coreReader, txid string) (string, error) {
	raw, err := call(ctx, "getrawtransaction", fmt.Sprintf("[%q,true]", txid))
	if err != nil {
		return "", fmt.Errorf("read transaction %s: %w", txid, err)
	}
	var tx struct {
		Vout []struct {
			ScriptPubKey struct {
				Hex string `json:"hex"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return "", fmt.Errorf("decode transaction %s: %w", txid, err)
	}
	if len(tx.Vout) == 0 {
		return "", fmt.Errorf("transaction %s has no outputs", txid)
	}
	return tx.Vout[0].ScriptPubKey.Hex, nil
}
