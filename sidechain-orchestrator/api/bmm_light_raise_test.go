package api

import (
	"context"
	"encoding/hex"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// m8Output builds the output zero of a BMM bid.
func m8Output(t *testing.T, slot uint8) *wpb.TransactionOutput {
	t.Helper()
	const zeroHash = "0000000000000000000000000000000000000000000000000000000000000000"
	script, err := orchestrator.M8BmmRequestScript(slot, zeroHash, zeroHash)
	require.NoError(t, err)
	return &wpb.TransactionOutput{ScriptPubkeyHex: hex.EncodeToString(script)}
}

// lightBidSource reads our own bid through the wallet, which is what light
// mode holds.
func lightBidSource(t *testing.T, wallet *fakeBidWallet) bidSource {
	t.Helper()
	h := lightHandler(t)
	h.wallet = wallet
	return bidSource{h: h, own: walletBids{h: h}}
}

// The wallet built and signed our bid, so it names the coins to respend and
// the fee to beat. No Bitcoin Core answers any of it.
func TestLightRaisePricesFromTheWallet(t *testing.T) {
	wallet := &fakeBidWallet{details: map[string]*wpb.GetTransactionDetailsResponse{
		"live": {
			Inputs:  []*wpb.TransactionInput{{PrevTxid: "coin", PrevVout: 1}},
			Outputs: []*wpb.TransactionOutput{m8Output(t, 9)},
			FeeSats: 4_000,
		},
		"coin": {Confirmations: 6},
	}}

	replacement, err := lightBidSource(t, wallet).Replacement(context.Background(), "bidder", "live")
	require.NoError(t, err)

	require.Len(t, replacement.Inputs, 1)
	assert.Equal(t, "coin", replacement.Inputs[0].Txid)
	assert.EqualValues(t, 1, replacement.Inputs[0].Vout)
	assert.Equal(t, []string{"live"}, replacement.Evicted)
	assert.EqualValues(t, 4_000, replacement.EvictedFeeSats)
	assert.EqualValues(t, 4_000+replacementBumpSats, replacement.FloorSats)
}

// One bid takes the change of the bid before it, so the replacement respends
// the coin under the whole chain and pays for every bid on it.
func TestLightRaisePricesTheWholeChain(t *testing.T) {
	wallet := &fakeBidWallet{details: map[string]*wpb.GetTransactionDetailsResponse{
		"top": {
			Inputs:  []*wpb.TransactionInput{{PrevTxid: "root", PrevVout: 1}},
			Outputs: []*wpb.TransactionOutput{m8Output(t, 9)},
			FeeSats: 3_000,
		},
		"root": {
			Inputs:  []*wpb.TransactionInput{{PrevTxid: "coin", PrevVout: 0}},
			Outputs: []*wpb.TransactionOutput{m8Output(t, 9)},
			FeeSats: 2_000,
		},
		"coin": {Confirmations: 3},
	}}

	replacement, err := lightBidSource(t, wallet).Replacement(context.Background(), "bidder", "top")
	require.NoError(t, err)

	require.Len(t, replacement.Inputs, 1)
	assert.Equal(t, "coin", replacement.Inputs[0].Txid)
	assert.Equal(t, []string{"top", "root"}, replacement.Evicted)
	assert.EqualValues(t, 5_000, replacement.EvictedFeeSats)
	assert.EqualValues(t, 5_000+replacementBumpSats, replacement.FloorSats)
}

// A bid a block already took is no price to beat, so the replacement needs no
// floor at all.
func TestLightRaiseSkipsAConfirmedBid(t *testing.T) {
	wallet := &fakeBidWallet{details: map[string]*wpb.GetTransactionDetailsResponse{
		"live": {
			Inputs:        []*wpb.TransactionInput{{PrevTxid: "coin", PrevVout: 0}},
			Outputs:       []*wpb.TransactionOutput{m8Output(t, 9)},
			FeeSats:       4_000,
			Confirmations: 1,
		},
		"coin": {Confirmations: 6},
	}}

	replacement, err := lightBidSource(t, wallet).Replacement(context.Background(), "bidder", "live")
	require.NoError(t, err)
	assert.Zero(t, replacement.FloorSats)
}

// A wrong price is worse than no raise, so a bid the wallet cannot name is an
// error rather than a free replacement.
func TestLightRaiseRefusesAnUnknownBid(t *testing.T) {
	replacement, err := lightBidSource(t, &fakeBidWallet{}).
		Replacement(context.Background(), "bidder", "live")
	require.Error(t, err)
	assert.Zero(t, replacement.FloorSats)
}

// The stranded bid walk reads our own unconfirmed transactions from the
// wallet, because light mode holds no mempool.
func TestLightPendingTxidsReadTheWallet(t *testing.T) {
	wallet := &fakeBidWallet{txs: []*wpb.TransactionEntry{
		{Txid: "live"},
		{Txid: "mined", Confirmations: 2},
	}}

	held, err := lightBidSource(t, wallet).PendingTxids(context.Background(), []string{"bidder"})
	require.NoError(t, err)
	assert.Equal(t, map[string]bool{"live": true}, held)
}
