package api

import (
	"context"
	"encoding/hex"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

const lightBidVsize = 150

// lightBid is one unconfirmed bid on prevMain that spends parent:vout.
func lightBid(t *testing.T, parent string, vout int32, prevMain string, changeSats, feeSats int64) *wpb.GetTransactionDetailsResponse {
	t.Helper()
	script, err := orchestrator.M8BmmRequestScript(9, "ab"+cancelTip[2:], prevMain)
	require.NoError(t, err)
	return &wpb.GetTransactionDetailsResponse{
		Inputs: []*wpb.TransactionInput{{PrevTxid: parent, PrevVout: vout}},
		Outputs: []*wpb.TransactionOutput{
			{Index: 0, ScriptPubkeyHex: hex.EncodeToString(script)},
			{Index: 1, ValueSats: changeSats},
		},
		FeeSats:     feeSats,
		VsizeVbytes: lightBidVsize,
	}
}

// fourLostBids holds a confirmed coin of 1 BTC under four lost bids, each on
// the change of the one before it.
func fourLostBids(t *testing.T) *fakeBidWallet {
	t.Helper()
	w := &fakeBidWallet{
		sendTxid: "replacement",
		details: map[string]*wpb.GetTransactionDetailsResponse{
			"coin": {
				Confirmations: 6,
				Outputs:       []*wpb.TransactionOutput{{Index: 0}, {Index: 1, ValueSats: 100_000_000}},
			},
			"bid1": lightBid(t, "coin", 1, cancelOldTip, 99_990_000, 10_000),
			"bid2": lightBid(t, "bid1", 1, cancelOldTip, 99_980_000, 10_000),
			"bid3": lightBid(t, "bid2", 1, cancelOldTip, 99_970_000, 10_000),
			"bid4": lightBid(t, "bid3", 1, cancelOldTip, 99_960_000, 10_000),
		},
		txs: []*wpb.TransactionEntry{
			{Txid: "bid4"}, {Txid: "bid3"}, {Txid: "bid2"}, {Txid: "bid1"},
			{Txid: "coin", Confirmations: 6},
		},
	}
	return w
}

func lightCancel(t *testing.T, w *fakeBidWallet, txid string) (*bmmpb.CancelBidResponse, error) {
	t.Helper()
	h := lightHandler(t)
	h.wallet = w
	h.chainTip = func(context.Context) (string, error) { return cancelTip, nil }
	resp, err := h.CancelBid(context.Background(), connect.NewRequest(&bmmpb.CancelBidRequest{Txid: txid}))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func TestDescendantsWalksEveryChild(t *testing.T) {
	parents := map[string][]string{
		"bid2":  {"bid1"},
		"bid3":  {"bid2"},
		"bid4":  {"bid3"},
		"send":  {"bid4", "coin"},
		"other": {"coin"},
	}

	assert.ElementsMatch(t, []string{"bid2", "bid3", "bid4", "send"}, descendants([]string{"bid1"}, parents))
	assert.Empty(t, descendants([]string{"coin2"}, parents))
}

// A light wallet reads the chain from its own history, so a cancel of any bid
// of the four respends the coin under all of them and pays over all four.
func TestLightCancelRespendsTheCoinUnderFourBids(t *testing.T) {
	for _, named := range []string{"bid1", "bid4"} {
		t.Run(named, func(t *testing.T) {
			w := fourLostBids(t)

			got, err := lightCancel(t, w, named)
			require.NoError(t, err)

			const wantFee = 4*10_000 + lightBidVsize + 1
			assert.Equal(t, "replacement", got.ReplacementTxid)
			assert.ElementsMatch(t, []string{"bid1", "bid2", "bid3", "bid4"}, got.CancelledTxids)
			assert.EqualValues(t, wantFee, got.FeeSats, "the four fees plus 1 sat/vB on the root's size")
			assert.EqualValues(t, 100_000_000-wantFee, got.RecoveredSats)

			require.Len(t, w.sends, 1)
			send := w.sends[0]
			require.Len(t, send.RequiredInputs, 1)
			assert.Equal(t, "coin", send.RequiredInputs[0].Txid)
			assert.EqualValues(t, 1, send.RequiredInputs[0].Vout)
			assert.EqualValues(t, wantFee, send.FixedFeeSats)
			assert.Equal(t, map[string]int64{"address-1": 100_000_000 - wantFee}, send.Destinations)
			assert.Empty(t, send.RawOutputs, "no M8, or the replacement bids again")
			assert.False(t, send.AllowReplay, "the wallet stamps the replay lock time")
		})
	}
}

func TestLightCancelRefusesABidThatCanStillWin(t *testing.T) {
	w := fourLostBids(t)
	w.details["bid4"] = lightBid(t, "bid3", 1, cancelTip, 99_960_000, 10_000)

	_, err := lightCancel(t, w, "bid4")

	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "can still win")
	assert.Empty(t, w.sends)
}

// A live bid on the chain dies with the cancel, so the cancel refuses.
func TestLightCancelRefusesToEvictALiveBid(t *testing.T) {
	w := fourLostBids(t)
	w.details["bid4"] = lightBid(t, "bid3", 1, cancelTip, 99_960_000, 10_000)

	_, err := lightCancel(t, w, "bid1")

	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "live bid bid4")
	assert.Empty(t, w.sends)
}

// The server dropped a replaced bid, so the wallet no longer lists it.
func TestLightCancelRefusesABidTheServerDropped(t *testing.T) {
	w := fourLostBids(t)
	w.txs = w.txs[1:]

	_, err := lightCancel(t, w, "bid4")

	require.Error(t, err)
	assert.Contains(t, err.Error(), "not in the mempool")
	assert.Empty(t, w.sends)
}
