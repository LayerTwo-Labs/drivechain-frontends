package daemon

import (
	"context"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

func freeAddr(t *testing.T) string {
	t.Helper()
	lis, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	addr := lis.Addr().String()
	require.NoError(t, lis.Close())
	return addr
}

func testConfig(t *testing.T) Config {
	t.Helper()
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("BITWINDOW_HOME", home)
	dir := filepath.Join(home, "bitwindow")
	require.NoError(t, os.MkdirAll(dir, 0o755))
	return Config{
		DataDir:      dir,
		Network:      "signet",
		ListenAddr:   freeAddr(t),
		BitwindowDir: dir,
		AppHome:      home,
		LocalAuth:    true,
		OwnerPID:     os.Getpid(),
		Log:          zerolog.Nop(),
	}
}

func startRun(t *testing.T, ctx context.Context, cfg Config) <-chan error {
	t.Helper()
	done := make(chan error, 1)
	go func() { done <- Run(ctx, cfg) }()
	client := orchestratorClient(cfg)
	require.Eventually(t, func() bool {
		_, err := client.ListBinaries(ctx, &pb.ListBinariesRequest{})
		return err == nil
	}, 30*time.Second, 50*time.Millisecond, "drivechaind never served")
	return done
}

func orchestratorClient(cfg Config) rpc.OrchestratorServiceClient {
	return rpc.NewOrchestratorServiceClient(connect.NewClient(
		connecthttp.NewTransport(http.DefaultClient, "http://"+cfg.ListenAddr, connecthttp.WithGRPC()),
		localauth.ClientInterceptor(cfg.BitwindowDir),
	))
}

func awaitRun(t *testing.T, done <-chan error) {
	t.Helper()
	select {
	case err := <-done:
		require.NoError(t, err)
	case <-time.After(30 * time.Second):
		t.Fatal("Run did not return")
	}
}

func TestRunReturnsWhenTheContextEnds(t *testing.T) {
	cfg := testConfig(t)
	ctx, cancel := context.WithCancel(t.Context())
	done := startRun(t, ctx, cfg)

	cancel()
	awaitRun(t, done)

	conn, err := net.DialTimeout("tcp", cfg.ListenAddr, time.Second)
	if err == nil {
		_ = conn.Close()
	}
	require.Error(t, err, "the RPC port must be free after Run returns")
}

func TestRunReturnsAfterTheShutdownRPC(t *testing.T) {
	cfg := testConfig(t)
	done := startRun(t, t.Context(), cfg)

	_, err := orchestratorClient(cfg).Shutdown(t.Context(), &pb.ShutdownRequest{})
	require.NoError(t, err)
	awaitRun(t, done)
}

func TestRunServesAgainInTheSameProcess(t *testing.T) {
	cfg := testConfig(t)
	for range 2 {
		ctx, cancel := context.WithCancel(t.Context())
		done := startRun(t, ctx, cfg)
		cancel()
		awaitRun(t, done)
	}
}
