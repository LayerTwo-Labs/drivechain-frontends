package api

import (
	"context"
	"encoding/json"
	"io"
	"os"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func newBMMModeHandler(t *testing.T) (*BMMHandler, *bmmstate.Store) {
	t.Helper()
	home := config.HomeDir()
	userHome, err := os.UserHomeDir()
	require.NoError(t, err)
	if home == userHome {
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

func TestBMMLightModeRejectsCoreWork(t *testing.T) {
	for _, operation := range []string{"start", "create", "list"} {
		t.Run(operation, func(t *testing.T) {
			h, _ := newBMMModeHandler(t)
			require.NoError(t, orchestrator.WriteNodeMode(h.orch.BitwindowDir, orchestrator.NodeModeLight))
			require.Equal(t, orchestrator.NodeModeLight, h.orch.NodeMode())
			var coreCalls int
			h.SetCoreCaller(func(context.Context, string, string, string) (json.RawMessage, error) {
				coreCalls++
				return json.RawMessage(`{}`), nil
			})
			ctx, cancel := context.WithCancel(context.Background())
			cancel()
			var err error
			switch operation {
			case "start":
				_, err = h.Start(ctx, connect.NewRequest(&bmmpb.StartRequest{Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER, MaxBidSats: 10000}))
			case "create":
				_, err = h.CreateBid(ctx, connect.NewRequest(&bmmpb.CreateBidRequest{Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER, BidSats: 1000}))
			case "list":
				_, err = h.ListBids(ctx, connect.NewRequest(&bmmpb.ListBidsRequest{Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER}))
			}
			require.ErrorContains(t, err, "BMM is unavailable in light mode")
			require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
			require.Zero(t, coreCalls)
			running, _, _ := h.engine.Running(pb.BinaryType_BINARY_TYPE_THUNDER)
			require.False(t, running)
		})
	}
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
	require.Zero(t, state.NextBlockFeeRateSatVb)
}
