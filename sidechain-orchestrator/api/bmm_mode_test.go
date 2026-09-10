package api

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func newBMMModeHandler(t *testing.T) (*BMMHandler, *bmmstate.Store) {
	t.Helper()
	home := config.HomeDir()
	if home == config.UserHomeDir() {
		home = ""
	}
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })
	log := zerolog.New(io.Discard)
	orch := orchestrator.New(t.TempDir(), string(config.NetworkSignet), t.TempDir(), []orchestrator.BinaryConfig{
		{Name: "thunder", ChainLayer: 2, Slot: 9},
	}, log)
	t.Cleanup(orch.StopAllMonitors)
	h := NewBMMHandler(orch, nil)
	store := bmmstate.NewStore(t.TempDir(), 0)
	h.SetEngine(engines.NewBmmEngine(log, h, nil, nil, store))
	return h, store
}

// lightHandler answers in light mode, and fails the test on a Core call.
func lightHandler(t *testing.T) *BMMHandler {
	t.Helper()
	h, _ := newBMMModeHandler(t)
	require.NoError(t, orchestrator.WriteNodeMode(h.orch.BitwindowDir, orchestrator.NodeModeLight))
	require.Equal(t, orchestrator.NodeModeLight, h.orch.NodeMode())
	h.SetCoreCaller(func(_ context.Context, method, _, _ string) (json.RawMessage, error) {
		t.Errorf("light mode called core: %s", method)
		return nil, fmt.Errorf("no core")
	})
	return h
}

// Every mempool read names the mempool as the reason, so a user reads what is
// missing rather than which mode they picked.
func TestBMMLightModeRefusesTheMempoolReads(t *testing.T) {
	tests := []struct {
		name   string
		reason string
		call   func(*BMMHandler) error
	}{
		{
			name:   "list the competing bids",
			reason: "the competing bids reads the mainchain mempool",
			call: func(h *BMMHandler) error {
				_, err := h.ListBids(context.Background(),
					connect.NewRequest(&bmmpb.ListBidsRequest{Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER}))
				return err
			},
		},
		{
			name:   "raise a live bid",
			reason: "a raise reads the mainchain mempool",
			call: func(h *BMMHandler) error {
				_, err := h.CreateBid(context.Background(), connect.NewRequest(&bmmpb.CreateBidRequest{
					Sidechain:   pb.BinaryType_BINARY_TYPE_THUNDER,
					BidSats:     2_000,
					MaxBidSats:  30_000,
					ReplaceTxid: "live",
				}))
				return err
			},
		},
		{
			name:   "cancel a stranded bid",
			reason: "a cancel reads the mainchain mempool",
			call: func(h *BMMHandler) error {
				_, err := h.CancelBid(context.Background(),
					connect.NewRequest(&bmmpb.CancelBidRequest{Txid: "stranded"}))
				return err
			},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			err := tc.call(lightHandler(t))
			require.Error(t, err)
			assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
			assert.Contains(t, err.Error(), tc.reason)
			assert.Contains(t, err.Error(), "light mode runs no Bitcoin Core")
		})
	}
}

// The opening bid picks its coin without a mempool read. Only a confirmed coin
// qualifies: the parent of an unconfirmed one names the slot that owns it, and
// that parent is out of reach.
func TestBMMLightModePicksAConfirmedCoin(t *testing.T) {
	const unconfirmed = "1111111111111111111111111111111111111111111111111111111111111111"
	const confirmed = "2222222222222222222222222222222222222222222222222222222222222222"

	h := lightHandler(t)
	h.wallet = &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: unconfirmed, Vout: 0, AmountSats: 3_000_000, Spendable: true},
		{Txid: confirmed, Vout: 0, AmountSats: 500_000, Spendable: true, Confirmations: 6},
	}}

	coin, err := h.slotCoin(context.Background(), bidRequest(), 9, 10_000)
	require.NoError(t, err)
	assert.Equal(t, confirmed, coin.Txid)
}

// The coin split spends through the wallet alone, so light mode prepares its
// coins like any other install.
func TestBMMLightModePreparesCoins(t *testing.T) {
	const coin = "3333333333333333333333333333333333333333333333333333333333333333"

	h := lightHandler(t)
	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: coin, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
	}}
	h.wallet = wallet

	resp, err := h.PrepareBMM(context.Background(), connect.NewRequest(&bmmpb.PrepareBMMRequest{
		Targets: []*bmmpb.PrepareBMMTarget{{WalletId: "bidder", MaxBidSats: 30_000}},
	}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Wallets, 1)
	assert.EqualValues(t, 1, resp.Msg.Wallets[0].UsableCoins)
	assert.Empty(t, wallet.sends, "one coin funds one sidechain")
}

// A bid that stays unconfirmed leaves change no light-mode bid can spend, so
// the wallet splits another coin rather than counts that change as prepared.
func TestBMMLightModeSplitsPastAnUnconfirmedCoin(t *testing.T) {
	const unconfirmed = "4444444444444444444444444444444444444444444444444444444444444444"
	const confirmed = "5555555555555555555555555555555555555555555555555555555555555555"

	h := lightHandler(t)
	wallet := &fakeBidWallet{
		sendTxid: "6666666666666666666666666666666666666666666666666666666666666666",
		utxos: []*wpb.UnspentOutput{
			{Txid: unconfirmed, Vout: 0, AmountSats: 3_000_000, Spendable: true},
			{Txid: confirmed, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
		},
	}
	h.wallet = wallet

	resp, err := h.PrepareBMM(context.Background(), connect.NewRequest(&bmmpb.PrepareBMMRequest{
		Targets: []*bmmpb.PrepareBMMTarget{
			{WalletId: "bidder", MaxBidSats: 30_000},
			{WalletId: "bidder", MaxBidSats: 30_000},
		},
	}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Wallets, 1)
	assert.EqualValues(t, 1, resp.Msg.Wallets[0].UsableCoins, "the unconfirmed coin counts for nothing")
	require.Len(t, wallet.sends, 1, "the wallet splits the confirmed coin")
	assert.Equal(t, confirmed, wallet.sends[0].RequiredInputs[0].Txid)
}

func TestBMMFullModeReadsCore(t *testing.T) {
	h, _ := newBMMModeHandler(t)
	require.NoError(t, orchestrator.WriteNodeMode(h.orch.BitwindowDir, orchestrator.NodeModeFull))
	var coreCalls int
	h.SetCoreCaller(func(context.Context, string, string, string) (json.RawMessage, error) {
		coreCalls++
		return json.RawMessage(`{}`), nil
	})
	_, err := h.ListBids(context.Background(), connect.NewRequest(&bmmpb.ListBidsRequest{Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER}))
	require.NoError(t, err)
	require.Equal(t, 1, coreCalls)
}

func TestBMMLightModeKeepsStopAndPaidHistory(t *testing.T) {
	h, store := newBMMModeHandler(t)
	sidechain := pb.BinaryType_BINARY_TYPE_THUNDER
	require.NoError(t, h.engine.Start(context.Background(), sidechain, "wallet", 10000, false))
	round := bmmstate.Round{Sidechain: int32(sidechain), PrevMainHash: "paid", Result: engines.ResultWon, WinnerBidSats: 1000}
	require.NoError(t, store.Save(round))
	require.NoError(t, orchestrator.WriteNodeMode(h.orch.BitwindowDir, orchestrator.NodeModeLight))
	_, err := h.Stop(context.Background(), connect.NewRequest(&bmmpb.StopRequest{Sidechain: sidechain}))
	require.NoError(t, err)
	targets, err := store.Targets()
	require.NoError(t, err)
	require.Empty(t, targets)
	response, err := h.GetRoundBids(context.Background(), connect.NewRequest(&bmmpb.GetRoundBidsRequest{Sidechain: sidechain, PrevMainHash: "paid"}))
	require.NoError(t, err)
	require.Equal(t, engines.ResultWon, response.Msg.Round.Result)
	require.EqualValues(t, 1000, response.Msg.Round.WinnerBidSats)
	state, err := h.state(context.Background(), sidechain)
	require.NoError(t, err)
	require.False(t, state.Running)
	require.Len(t, state.History, 1)
	// Light mode still opens a bid, so it still reports the rate one opens at.
	require.Positive(t, state.NextBlockFeeRateSatVb)
}
