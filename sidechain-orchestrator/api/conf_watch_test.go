package api

import (
	"context"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

func TestWatchEnforcerConfigSendsAFileWrite(t *testing.T) {
	dir := t.TempDir()
	bitcoinConf, err := config.NewBitcoinConfManager(dir, config.NetworkSignet, zerolog.Nop())
	require.NoError(t, err)
	enforcerConf, err := config.NewEnforcerConfManager(bitcoinConf, dir, zerolog.Nop())
	require.NoError(t, err)

	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterEnforcerConfServiceHandler(rpcServer, NewEnforcerConfHandler(enforcerConf))
	connecthttp.Mount(mux, rpcServer)
	srv := h2cServer(mux)
	defer srv.Close()
	client := rpc.NewEnforcerConfServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), srv.URL, connecthttp.WithGRPC())))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	stream, err := client.WatchEnforcerConfig(ctx, &pb.WatchEnforcerConfigRequest{})
	require.NoError(t, err)

	first, err := stream.Receive()
	require.NoError(t, err)
	require.NotContains(t, first.GetConfig().GetConfigContent(), "log-level=trace")

	content := first.GetConfig().GetConfigContent() + "\nlog-level=trace\n"
	start := time.Now()
	require.NoError(t, os.WriteFile(enforcerConf.ConfigFilePath(), []byte(content), 0o644))

	for {
		next, err := stream.Receive()
		require.NoError(t, err)
		if next.GetHeartbeat() {
			continue
		}
		require.True(t, strings.Contains(next.GetConfig().GetConfigContent(), "log-level=trace"))
		require.Less(t, time.Since(start), confRecheckInterval/2, "the frame waited for the recheck tick")
		return
	}
}

func TestWatchFilesSkipsAMissingFolderAndOtherFiles(t *testing.T) {
	dir := t.TempDir()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	changed, err := watchFiles(ctx, dir+"/missing/a.conf", dir+"/b.conf")
	require.NoError(t, err)

	require.NoError(t, os.WriteFile(dir+"/other.log", []byte("x"), 0o644))
	select {
	case <-changed:
		t.Fatal("a write to another file woke the watch")
	case <-time.After(100 * time.Millisecond):
	}

	require.NoError(t, os.WriteFile(dir+"/b.conf", []byte("x"), 0o644))
	select {
	case <-changed:
	case <-time.After(time.Second):
		t.Fatal("a write to the conf did not wake the watch")
	}
}

func TestWatchFilesWaitsForTheLastWrite(t *testing.T) {
	dir := t.TempDir()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	changed, err := watchFiles(ctx, dir+"/b.conf")
	require.NoError(t, err)

	for i := range 5 {
		require.NoError(t, os.WriteFile(dir+"/b.conf", []byte{byte('a' + i)}, 0o644))
		time.Sleep(confSettle / 4)
	}
	select {
	case <-changed:
		t.Fatal("the watch woke during the writes")
	default:
	}
	select {
	case <-changed:
	case <-time.After(time.Second):
		t.Fatal("the watch did not wake after the writes")
	}
}
