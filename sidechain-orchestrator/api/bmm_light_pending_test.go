package api

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// The BMM controls let a user fund the bids from a wallet they never made
// active. The pending read has to name that wallet, or it reports none of its
// bids and the next round leaves the stranded one in place.
func TestLightPendingReadsTheFundingWallet(t *testing.T) {
	h := lightHandler(t)
	wallet := &fakeBidWallet{txs: []*wpb.TransactionEntry{{Txid: "bid", Confirmations: 0}}}
	h.wallet = wallet

	held, err := h.MempoolTxids(context.Background(), []string{"bidder"})
	require.NoError(t, err)

	assert.Equal(t, map[string]bool{"bid": true}, held)
	require.Len(t, wallet.listed, 1)
	assert.Equal(t, "bidder", wallet.listed[0].WalletId)
}

// A stored round names its funding wallet forever, so the list outlives a
// wallet the user deletes. That wallet must not hide the bids of the current
// one, or no later round ever replaces a stranded bid.
func TestLightPendingSkipsADeletedWallet(t *testing.T) {
	h := lightHandler(t)
	wallet := &fakeBidWallet{
		txs:     []*wpb.TransactionEntry{{Txid: "bid", Confirmations: 0}},
		listErr: map[string]error{"gone": fmt.Errorf("wallet gone not found")},
	}
	h.wallet = wallet

	held, err := h.MempoolTxids(context.Background(), []string{"bidder", "gone"})
	require.NoError(t, err)

	assert.Equal(t, map[string]bool{"bid": true}, held)
	require.Len(t, wallet.listed, 2)
}

// The current funding wallet is the first id. A backend that cannot list it
// reports nothing about our bids, so the read fails rather than reports none.
func TestLightPendingFailsOnTheCurrentWallet(t *testing.T) {
	h := lightHandler(t)
	h.wallet = &fakeBidWallet{listErr: map[string]error{"bidder": fmt.Errorf("esplora is down")}}

	_, err := h.MempoolTxids(context.Background(), []string{"bidder", "gone"})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "esplora is down")
}

// An Electrum wallet carries no block time on an unconfirmed row, so it sorts
// one after the whole confirmed history. The read asks past that history.
func TestLightPendingReadsPastTheConfirmedHistory(t *testing.T) {
	h := lightHandler(t)
	var txs []*wpb.TransactionEntry
	for i := range 100 {
		txs = append(txs, &wpb.TransactionEntry{Txid: fmt.Sprintf("old-%d", i), Confirmations: 6})
	}
	wallet := &fakeBidWallet{txs: append(txs, &wpb.TransactionEntry{Txid: "bid"})}
	h.wallet = wallet

	held, err := h.MempoolTxids(context.Background(), []string{"bidder"})
	require.NoError(t, err)

	assert.Equal(t, map[string]bool{"bid": true}, held)
	require.Len(t, wallet.listed, 1)
	assert.Greater(t, wallet.listed[0].Count, int32(100))
}
