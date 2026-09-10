package api

import (
	"context"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const (
	liveBid  = "1111111111111111111111111111111111111111111111111111111111111111"
	plainTx  = "2222222222222222222222222222222222222222222222222222222222222222"
	oldBlock = "3333333333333333333333333333333333333333333333333333333333333333"
)

func frozenHandler(t *testing.T, mempool *fakeSlotMempool) *BMMHandler {
	t.Helper()
	h, _ := newBMMModeHandler(t)
	h.SetCoreCaller(mempool.call)
	return h
}

// The change of a live bid dies with the replacement of that bid, because a
// replacement evicts every mempool descendant.
func TestFrozenCoinsHoldsTheChangeOfALiveBid(t *testing.T) {
	h := frozenHandler(t, &fakeSlotMempool{slots: map[string]int{liveBid: 9}, plain: []string{plainTx}})

	frozen, err := h.FrozenCoins(context.Background(), "", []wallet.Outpoint{
		{TxID: liveBid, Vout: 1},
		{TxID: plainTx, Vout: 0},
		{TxID: oldBlock, Vout: 0, Confirmed: true},
	})
	require.NoError(t, err)

	assert.True(t, frozen[liveBid+":1"], "the bid change belongs to the bid")
	assert.False(t, frozen[plainTx+":0"], "an ordinary mempool coin stays free")
	assert.False(t, frozen[oldBlock+":0"], "a confirmed coin stays free")
}

// A send over the coin a live bid spends replaces the bid itself.
func TestFrozenCoinsHoldsACoinALiveBidSpends(t *testing.T) {
	h := frozenHandler(t, &fakeSlotMempool{
		slots:  map[string]int{liveBid: 9},
		plain:  []string{plainTx},
		spends: map[string]string{oldBlock + ":0": liveBid, oldBlock + ":1": plainTx},
	})

	frozen, err := h.FrozenCoins(context.Background(), "", []wallet.Outpoint{
		{TxID: oldBlock, Vout: 0, Confirmed: true},
		{TxID: oldBlock, Vout: 1, Confirmed: true},
	})
	require.NoError(t, err)

	assert.True(t, frozen[oldBlock+":0"], "a live bid spends this coin")
	assert.False(t, frozen[oldBlock+":1"], "an ordinary send spends this coin")
}

// The mempool drops a bid the chain confirms, and the coins it held go free.
func TestFrozenCoinsFreesTheCoinsOfAConfirmedBid(t *testing.T) {
	h := frozenHandler(t, &fakeSlotMempool{})

	frozen, err := h.FrozenCoins(context.Background(), "", []wallet.Outpoint{
		{TxID: liveBid, Vout: 1, Confirmed: true},
	})
	require.NoError(t, err)
	assert.Empty(t, frozen)
}

// An Electrum wallet lists its own change before Core sees the transaction
// that paid it, so an unconfirmed coin the node cannot name waits.
func TestFrozenCoinsHoldsAnUnconfirmedCoinTheNodeCannotName(t *testing.T) {
	h := frozenHandler(t, &fakeSlotMempool{})

	frozen, err := h.FrozenCoins(context.Background(), "", []wallet.Outpoint{{TxID: liveBid, Vout: 1}})
	require.NoError(t, err)
	assert.True(t, frozen[liveBid+":1"])
}

// Light mode reads no mainchain mempool, so the wallet's own unconfirmed
// transactions name the bid line. A send that spends one of those coins dies
// with the next raise, which evicts the whole line.
func TestFrozenCoinsHoldsALightBidLine(t *testing.T) {
	h := lightHandler(t)
	h.wallet = &fakeBidWallet{
		txs: []*wpb.TransactionEntry{{Txid: "bid"}, {Txid: "payment"}},
		details: map[string]*wpb.GetTransactionDetailsResponse{
			"bid": {
				Inputs:  []*wpb.TransactionInput{{PrevTxid: "coin", PrevVout: 0}},
				Outputs: []*wpb.TransactionOutput{m8Output(t, 9)},
			},
			"payment": {Inputs: []*wpb.TransactionInput{{PrevTxid: "bid", PrevVout: 1}}},
		},
	}

	frozen, err := h.FrozenCoins(context.Background(), "bidder", []wallet.Outpoint{
		{TxID: "bid", Vout: 1},
		{TxID: "payment", Vout: 0},
		{TxID: "coin", Vout: 0},
		{TxID: plainTx, Vout: 0, Confirmed: true},
	})
	require.NoError(t, err)

	assert.True(t, frozen["bid:1"], "the change of the bid")
	assert.True(t, frozen["payment:0"], "the change of a transaction chained on the bid")
	assert.True(t, frozen["coin:0"], "the coin the bid spends")
	assert.False(t, frozen[plainTx+":0"], "a coin no bid reaches")
}

// A light wallet that runs no bid must spend its coins freely.
func TestFrozenCoinsHoldsNothingWithoutALightBid(t *testing.T) {
	h := lightHandler(t)
	h.wallet = &fakeBidWallet{
		txs: []*wpb.TransactionEntry{{Txid: "payment"}},
		details: map[string]*wpb.GetTransactionDetailsResponse{
			"payment": {Inputs: []*wpb.TransactionInput{{PrevTxid: "coin", PrevVout: 0}}},
		},
	}

	frozen, err := h.FrozenCoins(context.Background(), "bidder", []wallet.Outpoint{
		{TxID: "payment", Vout: 0},
		{TxID: "coin", Vout: 0},
	})
	require.NoError(t, err)
	assert.Empty(t, frozen)
}

// A node the handler cannot read leaves the freeze unknown, and an unknown
// freeze must fail the send rather than spend a coin a bid holds.
func TestFrozenCoinsFailsOnAnUnreadableMempoolTx(t *testing.T) {
	h := frozenHandler(t, &fakeSlotMempool{unreadable: []string{liveBid}})

	_, err := h.FrozenCoins(context.Background(), "", []wallet.Outpoint{{TxID: liveBid, Vout: 1}})
	require.Error(t, err)
	assert.True(t, strings.Contains(err.Error(), liveBid))
}

// A deposit over the change of a live bid is no bid itself, and a replacement
// of the bid below it evicts it just the same.
func TestFrozenCoinsHoldsTheChangeOfABidDescendant(t *testing.T) {
	const deposit = "5555555555555555555555555555555555555555555555555555555555555555"
	h := frozenHandler(t, &fakeSlotMempool{
		slots:     map[string]int{liveBid: 9},
		plain:     []string{deposit, plainTx},
		ancestors: map[string][]string{deposit: {liveBid}, plainTx: {}},
	})

	frozen, err := h.FrozenCoins(context.Background(), "", []wallet.Outpoint{
		{TxID: deposit, Vout: 2},
		{TxID: plainTx, Vout: 0},
	})
	require.NoError(t, err)

	assert.True(t, frozen[deposit+":2"], "the deposit sits over a live bid")
	assert.False(t, frozen[plainTx+":0"], "an ordinary mempool coin stays free")
}

// Bitcoin Core takes at most 100 outpoints in one gettxspendingprevout call.
func TestFrozenCoinsQueriesTheSpendersInBatches(t *testing.T) {
	mempool := &fakeSlotMempool{}
	h := frozenHandler(t, mempool)

	candidates := make([]wallet.Outpoint, 0, 250)
	for i := range 250 {
		candidates = append(candidates, wallet.Outpoint{TxID: oldBlock, Vout: i, Confirmed: true})
	}
	_, err := h.FrozenCoins(context.Background(), "", candidates)
	require.NoError(t, err)

	assert.Equal(t, []int{100, 100, 50}, mempool.spenderQueries)
}
