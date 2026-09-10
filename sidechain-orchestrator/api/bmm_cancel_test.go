package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
)

const (
	cancelTip    = "aaaa000000000000000000000000000000000000000000000000000000000000"
	cancelOldTip = "bbbb000000000000000000000000000000000000000000000000000000000000"
)

// cancelTx names one transaction the fake node holds.
type cancelTx struct {
	// vin names what the transaction spends, as "txid:vout".
	vin []string
	// values holds what each output carries, in sats.
	values []int64
	// slot marks a bid for that sidechain. A zero slot names no bid.
	slot int
	// prevMain is the block the bid builds on.
	prevMain string
	// confirmations above zero says a block carries it.
	confirmations int
	// feeSats is what the mempool reports the transaction pays.
	feeSats int64
	// descendants names the transactions the mempool holds over this one.
	descendants []string
	// replaced says a replacement took it out of the mempool.
	replaced bool
	// vsize is its size in vbytes. Zero reads as a one input bid.
	vsize int64
}

// cancelNode answers every Core read the cancel makes.
type cancelNode struct {
	txs map[string]cancelTx
	tip string
	// incrementalFee is the incremental relay fee, in BTC/kvB.
	incrementalFee float64
}

func (n *cancelNode) call(_ context.Context, method, paramsJSON, _ string) (json.RawMessage, error) {
	var params []any
	if paramsJSON != "" {
		if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
			return nil, err
		}
	}
	txid := ""
	if len(params) > 0 {
		txid, _ = params[0].(string)
	}

	switch method {
	case "getbestblockhash":
		return json.Marshal(n.tip)
	case "getmempooldescendants":
		return json.Marshal(n.txs[txid].descendants)
	case "getnetworkinfo":
		return json.Marshal(map[string]any{"incrementalfee": n.incrementalFee})
	case "getmempoolentry":
		tx, ok := n.txs[txid]
		if !ok || tx.replaced {
			return nil, fmt.Errorf("transaction %s not in mempool", txid)
		}
		return json.Marshal(map[string]any{
			"fees": map[string]any{"modified": float64(tx.feeSats) / 1e8},
		})
	case "getrawtransaction":
		tx, ok := n.txs[txid]
		if !ok {
			return nil, fmt.Errorf("no transaction %s", txid)
		}
		return json.Marshal(n.rawTx(tx))
	}
	return nil, fmt.Errorf("the cancel called %s", method)
}

func (n *cancelNode) rawTx(tx cancelTx) map[string]any {
	vsize := tx.vsize
	if vsize == 0 {
		vsize = nominalBidVsize
	}
	out := map[string]any{"confirmations": tx.confirmations, "vsize": vsize}
	vin := make([]map[string]any, 0, len(tx.vin))
	for _, in := range tx.vin {
		parts := strings.Split(in, ":")
		var vout int
		_, _ = fmt.Sscanf(parts[1], "%d", &vout)
		vin = append(vin, map[string]any{"txid": parts[0], "vout": vout})
	}
	out["vin"] = vin

	vout := make([]map[string]any, 0, len(tx.values))
	for i, value := range tx.values {
		entry := map[string]any{"value": float64(value) / 1e8, "scriptPubKey": map[string]any{"hex": ""}}
		if i == 0 && tx.slot > 0 {
			script, err := orchestrator.M8BmmRequestScript(uint8(tx.slot), strings.Repeat("ab", 32), tx.prevMain)
			if err == nil {
				entry["scriptPubKey"] = map[string]any{"hex": hex.EncodeToString(script)}
			}
		}
		vout = append(vout, entry)
	}
	out["vout"] = vout
	return out
}

// strandedNode holds one confirmed coin of 1 BTC under one lost bid.
func strandedNode() *cancelNode {
	return &cancelNode{
		tip:            cancelTip,
		incrementalFee: 0.00001,
		txs: map[string]cancelTx{
			"coin": {confirmations: 6, values: []int64{0, 100_000_000}},
			"lost": {
				vin:      []string{"coin:1"},
				values:   []int64{0, 99_990_000},
				slot:     9,
				prevMain: cancelOldTip,
				feeSats:  10_000,
			},
		},
	}
}

func cancelHandler(t *testing.T, node *cancelNode, w *fakeBidWallet) *BMMHandler {
	t.Helper()
	h, _ := newBMMModeHandler(t)
	h.wallet = w
	h.SetCoreCaller(node.call)
	return h
}

func cancel(t *testing.T, node *cancelNode, w *fakeBidWallet, txid string) (*bmmpb.CancelBidResponse, error) {
	t.Helper()
	resp, err := cancelHandler(t, node, w).CancelBid(
		context.Background(), connect.NewRequest(&bmmpb.CancelBidRequest{Txid: txid}))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func TestCancelBidPaysTheCoinsBackToItsOwnWallet(t *testing.T) {
	node := strandedNode()
	w := &fakeBidWallet{sendTxid: "replacement"}

	got, err := cancel(t, node, w, "lost")
	require.NoError(t, err)

	require.Equal(t, "replacement", got.ReplacementTxid)
	require.Equal(t, int64(10_189), got.FeeSats, "the evicted fee plus 1 sat/vB on 189 vB")
	require.Equal(t, int64(100_000_000-10_189), got.RecoveredSats)
	require.Equal(t, []string{"lost"}, got.CancelledTxids)

	require.Len(t, w.sends, 1)
	send := w.sends[0]
	require.Equal(t, map[string]int64{"address-1": 99_989_811}, send.Destinations)
	require.Equal(t, int64(10_189), send.FixedFeeSats)
	require.True(t, send.Replaceable)
	require.Zero(t, send.FeeRateSatPerVbyte, "a rate beside a fixed fee is refused")
	require.False(t, send.SubtractFeeFromAmount, "Core ignores it beside a fixed fee")
	require.Empty(t, send.RawOutputs, "no M8, or the replacement bids again")
	require.Len(t, send.RequiredInputs, 1)
	require.Equal(t, "coin", send.RequiredInputs[0].Txid)
}

// The M8 reaches only the block after the one it names. A bid on the tip can
// still win, and cancelling it throws away a round the wallet paid for.
func TestCancelBidRefusesABidThatCanStillWin(t *testing.T) {
	node := strandedNode()
	live := node.txs["lost"]
	live.prevMain = cancelTip
	node.txs["lost"] = live

	_, err := cancel(t, node, &fakeBidWallet{}, "lost")

	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Contains(t, err.Error(), "can still win")
}

// One wallet funds every slot, so another slot's live bid can sit on the same
// coins. The replacement would take it too.
func TestCancelBidRefusesToEvictALiveBid(t *testing.T) {
	node := strandedNode()
	lost := node.txs["lost"]
	lost.descendants = []string{"live"}
	node.txs["lost"] = lost
	node.txs["live"] = cancelTx{
		vin:      []string{"lost:1"},
		values:   []int64{0, 99_980_000},
		slot:     4,
		prevMain: cancelTip,
		feeSats:  10_000,
	}

	_, err := cancel(t, node, &fakeBidWallet{}, "lost")

	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Contains(t, err.Error(), "live bid live")
}

func TestCancelBidRefusesAPlainPayment(t *testing.T) {
	node := &cancelNode{tip: cancelTip, txs: map[string]cancelTx{
		"coin":    {confirmations: 6, values: []int64{100_000_000}},
		"payment": {vin: []string{"coin:0"}, values: []int64{99_990_000}},
	}}

	_, err := cancel(t, node, &fakeBidWallet{}, "payment")

	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Contains(t, err.Error(), "not an unconfirmed BMM bid")
}

func TestCancelBidRefusesAnEmptyTxid(t *testing.T) {
	_, err := cancel(t, strandedNode(), &fakeBidWallet{}, "")

	require.Error(t, err)
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

// A coin under the fee cannot come back, and a send would fail on dust.
func TestCancelBidRefusesACoinUnderTheFee(t *testing.T) {
	node := strandedNode()
	coin := node.txs["coin"]
	coin.values = []int64{0, 5_000}
	node.txs["coin"] = coin

	_, err := cancel(t, node, &fakeBidWallet{}, "lost")

	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Contains(t, err.Error(), "under the")
}

// A node that forgot the chain reports no fee, and a free replacement reaches
// no miner.
func TestCancelBidPaysTheBumpWhenTheMempoolForgotTheChain(t *testing.T) {
	node := strandedNode()
	lost := node.txs["lost"]
	lost.feeSats = 0
	node.txs["lost"] = lost
	w := &fakeBidWallet{sendTxid: "replacement"}

	got, err := cancel(t, node, w, "lost")

	require.NoError(t, err)
	require.Equal(t, int64(replacementBumpSats), got.FeeSats)
}

// The chain shares one parent, so a deep chain still reads it one time.
func TestCancelBidRespendsTheWholeChain(t *testing.T) {
	node := &cancelNode{tip: cancelTip, incrementalFee: 0.00001, txs: map[string]cancelTx{
		"coin": {confirmations: 6, values: []int64{0, 100_000_000}},
		"root": {vin: []string{"coin:1"}, values: []int64{0, 99_990_000}, slot: 9, prevMain: cancelOldTip, feeSats: 10_000, descendants: []string{"top"}},
		"top":  {vin: []string{"root:1"}, values: []int64{0, 99_980_000}, slot: 9, prevMain: cancelOldTip, feeSats: 10_000},
	}}
	w := &fakeBidWallet{sendTxid: "replacement"}

	got, err := cancel(t, node, w, "top")

	require.NoError(t, err)
	require.Equal(t, int64(20_189), got.FeeSats, "both bids plus 1 sat/vB on the root's size")
	require.ElementsMatch(t, []string{"root", "top"}, got.CancelledTxids)
	require.Len(t, w.sends[0].RequiredInputs, 1)
	require.Equal(t, "coin", w.sends[0].RequiredInputs[0].Txid)
}

// An RBF raise leaves the replaced bid in the wallet with no confirmations. The
// live bid conflicts with it and does not descend from it, so no descendant read
// finds the live bid.
func TestCancelBidRefusesAReplacedBid(t *testing.T) {
	node := strandedNode()
	replaced := node.txs["lost"]
	replaced.replaced = true
	node.txs["lost"] = replaced
	node.txs["live"] = cancelTx{
		vin:      []string{"coin:1"},
		values:   []int64{0, 99_980_000},
		slot:     9,
		prevMain: cancelTip,
		feeSats:  20_000,
	}
	w := &fakeBidWallet{sendTxid: "replacement"}

	_, err := cancel(t, node, w, "lost")

	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Contains(t, err.Error(), "not in the mempool")
	require.Empty(t, w.sends)
}

// The node wants the incremental relay fee on every vbyte of the cancel, over
// the fees it evicts. A bid over many coins makes a large cancel.
func TestCancelBidPaysTheIncrementalRelayFeeOnItsSize(t *testing.T) {
	const coins = 30
	node := strandedNode()
	node.incrementalFee = 0.00002
	coin := cancelTx{confirmations: 6}
	lost := node.txs["lost"]
	lost.vin = nil
	lost.vsize = 2_100
	for i := range coins {
		coin.values = append(coin.values, 1_000_000)
		lost.vin = append(lost.vin, fmt.Sprintf("coin:%d", i))
	}
	node.txs["coin"] = coin
	node.txs["lost"] = lost
	w := &fakeBidWallet{sendTxid: "replacement"}

	got, err := cancel(t, node, w, "lost")

	require.NoError(t, err)
	require.Len(t, w.sends[0].RequiredInputs, coins)
	require.Equal(t, int64(10_000+2*(2_100+coins)), got.FeeSats,
		"the evicted fee plus 2 sat/vB on the largest the cancel can be")
}
