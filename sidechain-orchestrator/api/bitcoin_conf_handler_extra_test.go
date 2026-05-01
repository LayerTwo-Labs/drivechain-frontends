package api

import (
	"context"
	"io"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

// TestGetBitcoinConfig_ReturnsRpcCredentials guards a contract bitwindowd
// depends on: after orchestratord becomes the owner of bitcoin.conf, every
// other process (bitwindowd, sidechain frontends) reads the bitcoind RPC
// credentials over gRPC instead of parsing the conf themselves. If
// rpc_user / rpc_password ever stop flowing in the GetBitcoinConfig
// response, every dependent reverts to silent auth failures with no
// obvious sign of why.
func TestGetBitcoinConfig_ReturnsRpcCredentials(t *testing.T) {
	bitwindowDir := t.TempDir()

	// Seed a bitwindow-bitcoin.conf with credentials in the [signet]
	// section the orch loader expects.
	confPath := filepath.Join(bitwindowDir, "bitwindow-bitcoin.conf")
	confContent := `chain=signet
[signet]
rpcuser=trusty
rpcpassword=hunter2
rpcport=18443
`
	require.NoError(t, os.WriteFile(confPath, []byte(confContent), 0o644))

	orch := orchestrator.New(t.TempDir(), "signet", bitwindowDir, []orchestrator.BinaryConfig{}, zerolog.New(io.Discard))
	require.NotNil(t, orch.BitcoinConf, "BitcoinConfManager must be initialised; without it the handler returns FailedPrecondition")

	h := NewBitcoinConfHandler(orch)
	resp, err := h.GetBitcoinConfig(context.Background(), connect.NewRequest(&pb.GetBitcoinConfigRequest{}))
	require.NoError(t, err)
	require.NotNil(t, resp.Msg)

	assert.Equal(t, "trusty", resp.Msg.RpcUser, "rpc_user must propagate from bitwindow-bitcoin.conf — bitwindowd's btc-buf proxy needs it")
	assert.Equal(t, "hunter2", resp.Msg.RpcPassword, "rpc_password must propagate")
	assert.Equal(t, "signet", resp.Msg.Network)
	assert.NotEmpty(t, resp.Msg.ConfigContent, "config_content must be non-empty so the conf editor UI has something to render")
}

// TestSetBitcoinConfigNetwork_RejectsEmpty closes the trivial-but-easy-to-
// regress contract: an empty Network string must return InvalidArgument
// instead of accidentally triggering a swap to the zero-value network.
func TestSetBitcoinConfigNetwork_RejectsEmpty(t *testing.T) {
	orch := orchestrator.New(t.TempDir(), "signet", t.TempDir(), []orchestrator.BinaryConfig{}, zerolog.New(io.Discard))
	require.NotNil(t, orch.BitcoinConf)
	h := NewBitcoinConfHandler(orch)

	_, err := h.SetBitcoinConfigNetwork(context.Background(), connect.NewRequest(&pb.SetBitcoinConfigNetworkRequest{Network: ""}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err), "empty network must be rejected as InvalidArgument; %v", err)
}

// TestSetBitcoinConfigNetwork_NoConfManager — when BitcoinConf isn't
// initialised, the handler must fail loud (FailedPrecondition) instead
// of dereferencing nil. Catches a regression where a future refactor
// might make BitcoinConf optional and forget to nil-check this path.
func TestSetBitcoinConfigNetwork_NoConfManager(t *testing.T) {
	// Build an orch but null out BitcoinConf to simulate the failure mode.
	orch := orchestrator.New(t.TempDir(), "signet", t.TempDir(), []orchestrator.BinaryConfig{}, zerolog.New(io.Discard))
	orch.BitcoinConf = nil
	h := NewBitcoinConfHandler(orch)

	_, err := h.SetBitcoinConfigNetwork(context.Background(), connect.NewRequest(&pb.SetBitcoinConfigNetworkRequest{Network: "regtest"}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
}
