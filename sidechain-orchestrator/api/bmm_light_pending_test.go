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
