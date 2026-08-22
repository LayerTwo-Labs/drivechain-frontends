package engines_test

import (
	"context"
	"errors"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// countingBitcoind reports how many times an engine reached for Bitcoin Core.
func countingBitcoind(dials *atomic.Int64) *service.Service[corerpc.BitcoinServiceClient] {
	return service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		dials.Add(1)
		return nil, context.Canceled
	})
}

func nodeModeSource(t *testing.T, mode orchpb.NodeMode) *engines.NodeMode {
	t.Helper()
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: mode},
		}, nil)

	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(client)
	return nodeMode
}

func runParserFor(t *testing.T, mode orchpb.NodeMode, window time.Duration) int64 {
	t.Helper()

	var dials atomic.Int64
	parser := engines.NewBitcoind(countingBitcoind(&dials), database.Test(t), config.Config{})
	parser.SetNodeMode(nodeModeSource(t, mode))

	ctx, cancel := context.WithTimeout(context.Background(), window)
	defer cancel()

	done := make(chan error, 1)
	go func() { done <- parser.Run(ctx) }()

	select {
	case err := <-done:
		require.NoError(t, err)
	case <-time.After(window + 5*time.Second):
		t.Fatal("Run did not return after its context ended")
	}
	return dials.Load()
}

// A light-mode install runs no Bitcoin Core. Every tick that dialled one wrote
// a "unable to handle block tick" error, twice a second, for the whole session.
func TestParserDoesNotDialBitcoinCoreInLightMode(t *testing.T) {
	require.Zero(t, runParserFor(t, orchpb.NodeMode_NODE_MODE_LIGHT, 3*time.Second))
}

// The same loop must still run in full mode. A gate that stops both modes
// stops the block parser.
func TestParserDialsBitcoinCoreInFullMode(t *testing.T) {
	require.Positive(t, runParserFor(t, orchpb.NodeMode_NODE_MODE_FULL, 3*time.Second))
}

// Both notification watchers tick at ten seconds and both reach Bitcoin Core.
// The two modes run at the same time, so the test costs one window.
func TestNotificationEngineWatchesOnlyInFullMode(t *testing.T) {
	for _, tc := range []struct {
		name      string
		mode      orchpb.NodeMode
		wantDials bool
	}{
		{name: "light mode dials nothing", mode: orchpb.NodeMode_NODE_MODE_LIGHT},
		{name: "full mode still dials", mode: orchpb.NodeMode_NODE_MODE_FULL, wantDials: true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			var dials atomic.Int64
			engine := engines.NewNotificationEngine(database.Test(t), countingBitcoind(&dials))
			engine.SetNodeMode(nodeModeSource(t, tc.mode))

			ctx, cancel := context.WithTimeout(context.Background(), 12*time.Second)
			defer cancel()
			_ = engine.Run(ctx)

			if tc.wantDials {
				require.Positive(t, dials.Load())
			} else {
				require.Zero(t, dials.Load())
			}
		})
	}
}

// bitcoindWithMempool answers the reap and refuses the block tick, so only the
// mempool sweep counts. failFirst refuses the first sweep, the way Bitcoin Core
// refuses every RPC while it loads its block index.
func bitcoindWithMempool(t *testing.T, sweeps *atomic.Int64, failFirst bool) *service.Service[corerpc.BitcoinServiceClient] {
	t.Helper()
	client := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	client.EXPECT().
		GetRawMempool(gomock.Any(), gomock.Any()).
		AnyTimes().
		DoAndReturn(func(context.Context, *connect.Request[corepb.GetRawMempoolRequest]) (*connect.Response[corepb.GetRawMempoolResponse], error) {
			if sweeps.Add(1) == 1 && failFirst {
				return nil, errors.New("-28: Loading block index")
			}
			return connect.NewResponse(&corepb.GetRawMempoolResponse{}), nil
		})
	client.EXPECT().
		GetBlockHash(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(nil, errors.New("no chain in this test"))

	return service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return client, nil
	})
}

// bitwindowd starts the orchestrator, so the first mode read of a full-mode
// install often fails. A sweep tied to that read waits a whole hour, and the
// expired rows it drops sit in the table meanwhile.
func TestParserSweepsTheMempoolAfterTheModeRecovers(t *testing.T) {
	ctrl := gomock.NewController(t)
	orch := mocks.NewMockWalletManagerServiceClient(ctrl)
	gomock.InOrder(
		orch.EXPECT().
			GetNodeMode(gomock.Any(), gomock.Any()).
			Return(nil, errors.New("orchestrator is starting")),
		orch.EXPECT().
			GetNodeMode(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[orchpb.GetNodeModeResponse]{
				Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_FULL},
			}, nil),
	)
	nodeMode := engines.NewNodeMode()
	nodeMode.SetClient(orch)

	// The sweep reads the mempool only when an expired row waits for it.
	db := database.Test(t)
	_, err := db.ExecContext(context.Background(), `
		INSERT INTO op_returns (txid, vout, op_return_data, fee_sats, height, created_at)
		VALUES ('dead', 0, 'beef', 1, NULL, datetime('now', '-30 days'))
	`)
	require.NoError(t, err)

	var sweeps atomic.Int64
	parser := engines.NewBitcoind(bitcoindWithMempool(t, &sweeps, false), db, config.Config{})
	parser.SetNodeMode(nodeMode)

	ctx, cancel := context.WithTimeout(context.Background(), 7*time.Second)
	defer cancel()
	require.NoError(t, parser.Run(ctx))

	// Once, and once only — the hourly ticker never fires in this window.
	require.Equal(t, int64(1), sweeps.Load())

	var left int
	require.NoError(t, db.QueryRow(`SELECT count(*) FROM op_returns`).Scan(&left))
	require.Zero(t, left)
}

// Bitcoin Core can still load its block index when the mode reads full. A flag
// set before the sweep marks it done, and the rows then wait an hour.
func TestParserRetriesTheStartupSweepAfterCoreIsReady(t *testing.T) {
	db := database.Test(t)
	_, err := db.ExecContext(context.Background(), `
		INSERT INTO op_returns (txid, vout, op_return_data, fee_sats, height, created_at)
		VALUES ('dead', 0, 'beef', 1, NULL, datetime('now', '-30 days'))
	`)
	require.NoError(t, err)

	var sweeps atomic.Int64
	parser := engines.NewBitcoind(bitcoindWithMempool(t, &sweeps, true), db, config.Config{})
	parser.SetNodeMode(nodeModeSource(t, orchpb.NodeMode_NODE_MODE_FULL))

	ctx, cancel := context.WithTimeout(context.Background(), 7*time.Second)
	defer cancel()
	require.NoError(t, parser.Run(ctx))

	// The first sweep fails, the next tick sweeps again, and the row goes.
	require.Equal(t, int64(2), sweeps.Load())

	var left int
	require.NoError(t, db.QueryRow(`SELECT count(*) FROM op_returns`).Scan(&left))
	require.Zero(t, left)
}
