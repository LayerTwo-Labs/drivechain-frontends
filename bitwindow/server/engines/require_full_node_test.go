package engines_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

func engineWithMode(t *testing.T, mode orchpb.NodeMode, err error) *engines.WalletEngine {
	t.Helper()
	e := engines.NewWalletEngine(
		func(context.Context) (corerpc.BitcoinServiceClient, error) { return nil, nil },
		t.TempDir(),
		&chaincfg.MainNetParams,
	)
	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: mode},
		}, err)
	e.SetOrchestratorClient(orch)
	return e
}

// The one path this guard exists for. Nothing covered it before.
func TestRequireFullNodeRefusesLightMode(t *testing.T) {
	e := engineWithMode(t, orchpb.NodeMode_NODE_MODE_LIGHT, nil)

	err := e.RequireFullNode(context.Background(), "proposing a sidechain")
	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Contains(t, err.Error(), "full mode")
}

func TestRequireFullNodeAllowsFullMode(t *testing.T) {
	e := engineWithMode(t, orchpb.NodeMode_NODE_MODE_FULL, nil)
	require.NoError(t, e.RequireFullNode(context.Background(), "proposing a sidechain"))
}

// An unreadable mode must not read as full. Failing open would let the call
// through to a daemon that is not there, with a confusing error.
func TestRequireFullNodeReportsAnUnreadableMode(t *testing.T) {
	boom := connect.NewError(connect.CodeInternal, context.DeadlineExceeded)
	e := engineWithMode(t, orchpb.NodeMode_NODE_MODE_UNSPECIFIED, boom)

	err := e.RequireFullNode(context.Background(), "proposing a sidechain")
	require.Error(t, err)
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
}

// No orchestrator client means no way to know, which is not the same as yes.
func TestRequireFullNodeReportsAMissingClient(t *testing.T) {
	e := engines.NewWalletEngine(
		func(context.Context) (corerpc.BitcoinServiceClient, error) { return nil, nil },
		t.TempDir(),
		&chaincfg.MainNetParams,
	)
	require.Error(t, e.RequireFullNode(context.Background(), "proposing a sidechain"))
}
