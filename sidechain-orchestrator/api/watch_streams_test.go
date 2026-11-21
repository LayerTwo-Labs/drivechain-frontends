package api

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

type fakeSyncSource struct {
	mu      sync.Mutex
	blocks  int64
	reads   int
	changed chan struct{}
}

func (f *fakeSyncSource) SubscribeSyncStatus(ctx context.Context) <-chan struct{} { return f.changed }

func (f *fakeSyncSource) SyncStatus(ctx context.Context) (*orchestrator.SyncStatus, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.reads++
	return &orchestrator.SyncStatus{
		Mainchain: &orchestrator.ChainSyncResult{Blocks: f.blocks, Headers: f.blocks},
		Enforcer:  &orchestrator.ChainSyncResult{},
		Sidechains: map[string]*orchestrator.ChainSyncResult{
			"thunder": {Error: "not running"}, "bitnames": {Error: "not running"}, "zside": {Error: "not running"},
		},
		ChainSource: &orchestrator.ChainSyncResult{},
	}, nil
}

func TestWatchSyncStatusPushesANewBlock(t *testing.T) {
	orch := orchestrator.New(t.TempDir(), "regtest", t.TempDir(), nil, zerolog.New(io.Discard))
	src := &fakeSyncSource{blocks: 100, changed: make(chan struct{}, 1)}
	handler := NewHandler(orch)
	handler.SetSyncStatusSource(src)

	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterOrchestratorServiceHandler(rpcServer, handler)
	connecthttp.Mount(mux, rpcServer)
	srv := h2cServer(mux)
	defer srv.Close()
	client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), srv.URL, connecthttp.WithGRPC())))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	stream, err := client.WatchSyncStatus(ctx, &pb.WatchSyncStatusRequest{})
	require.NoError(t, err)

	first, err := stream.Receive()
	require.NoError(t, err)
	require.EqualValues(t, 100, first.GetStatus().GetMainchain().GetBlocks())
	require.Len(t, first.GetStatus().GetSidechains(), 3)
	require.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_THUNDER, first.GetStatus().GetSidechains()[0].GetType())

	src.mu.Lock()
	src.blocks = 101
	src.mu.Unlock()
	start := time.Now()
	src.changed <- struct{}{}

	next, err := stream.Receive()
	require.NoError(t, err)
	require.False(t, next.GetHeartbeat())
	require.EqualValues(t, 101, next.GetStatus().GetMainchain().GetBlocks())
	require.Less(t, time.Since(start), binariesRecheckInterval/2, "the frame waited for the recheck tick")
}

func TestSameBinariesIgnoresUptime(t *testing.T) {
	a := []*pb.BinaryStatusMsg{{Name: "bitcoind", Running: true, UptimeSeconds: 1}}
	b := []*pb.BinaryStatusMsg{{Name: "bitcoind", Running: true, UptimeSeconds: 2}}
	c := []*pb.BinaryStatusMsg{{Name: "bitcoind", UptimeSeconds: 2}}
	require.True(t, sameBinaries(a, b))
	require.False(t, sameBinaries(a, c))
	require.EqualValues(t, 1, a[0].UptimeSeconds)
}

func TestWatchBinariesSendsTheList(t *testing.T) {
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{Name: "streamtest", BinaryName: "streamtest"})
	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterOrchestratorServiceHandler(rpcServer, NewHandler(orch))
	connecthttp.Mount(mux, rpcServer)
	srv := h2cServer(mux)
	defer srv.Close()
	client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), srv.URL, connecthttp.WithGRPC())))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	stream, err := client.WatchBinaries(ctx, &pb.WatchBinariesRequest{})
	require.NoError(t, err)

	first, err := stream.Receive()
	require.NoError(t, err)
	require.Len(t, first.GetBinaries(), 1)
	require.Equal(t, "streamtest", first.GetBinaries()[0].GetName())
}

func TestWatchSyncStatusReadsOneTimeForAllStreams(t *testing.T) {
	orch := orchestrator.New(t.TempDir(), "regtest", t.TempDir(), nil, zerolog.New(io.Discard))
	src := &fakeSyncSource{blocks: 100, changed: make(chan struct{}, 1)}
	handler := NewHandler(orch)
	handler.SetSyncStatusSource(src)

	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterOrchestratorServiceHandler(rpcServer, handler)
	connecthttp.Mount(mux, rpcServer)
	srv := h2cServer(mux)
	defer srv.Close()
	client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), srv.URL, connecthttp.WithGRPC())))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	var streams []rpc.OrchestratorServiceWatchSyncStatusClientStream
	for range 2 {
		stream, err := client.WatchSyncStatus(ctx, &pb.WatchSyncStatusRequest{})
		require.NoError(t, err)
		first, err := stream.Receive()
		require.NoError(t, err)
		require.EqualValues(t, 100, first.GetStatus().GetMainchain().GetBlocks())
		streams = append(streams, stream)
	}

	src.mu.Lock()
	src.blocks = 101
	src.mu.Unlock()
	src.changed <- struct{}{}
	for _, stream := range streams {
		next, err := stream.Receive()
		require.NoError(t, err)
		require.EqualValues(t, 101, next.GetStatus().GetMainchain().GetBlocks())
	}

	time.Sleep(2 * binariesRecheckInterval)
	src.mu.Lock()
	defer src.mu.Unlock()
	require.Equal(t, 2, src.reads)
}

func TestEngineSyncStatusWakesOnANewBlock(t *testing.T) {
	var height atomic.Int64
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		for {
			h := height.Load()
			switch {
			case method == "getblockchaininfo":
				return json.RawMessage(fmt.Sprintf(`{"chain":"regtest","blocks":%d,"headers":%d,"bestblockhash":"h%d"}`, h, h, h)), nil
			case method != "waitforblockheight":
				return json.RawMessage(`null`), nil
			case h >= params[0].(int64):
				return json.RawMessage(fmt.Sprintf(`{"hash":"h%d","height":%d}`, h, h)), nil
			}
			select {
			case <-ctx.Done():
				return nil, ctx.Err()
			case <-time.After(time.Millisecond):
			}
		}
	}})
	go engine.Run(t.Context())
	require.Eventually(t, func() bool { return engine.Health() == nil }, time.Second, time.Millisecond)

	src := engineSyncStatus{pollSyncStatus: pollSyncStatus{interval: time.Hour}, engine: engine, sidechainRunning: func() bool { return false }}
	changed := src.SubscribeSyncStatus(t.Context())
	height.Add(1)
	select {
	case <-changed:
	case <-time.After(time.Second):
		t.Fatal("no wake after a new block")
	}
}

func TestEngineSyncStatusPollsFastOnlyWhileASidechainRuns(t *testing.T) {
	var running atomic.Bool
	src := engineSyncStatus{pollSyncStatus: pollSyncStatus{interval: time.Hour}, sidechainRunning: running.Load}
	ticks := src.poll(t.Context())

	select {
	case <-ticks:
		t.Fatal("a tick with no sidechain")
	case <-time.After(3 * syncStatusPollInterval):
	}

	running.Store(true)
	start := time.Now()
	for range 3 {
		select {
		case <-ticks:
		case <-time.After(2 * syncStatusPollInterval):
			t.Fatal("no fast tick while a sidechain runs")
		}
	}
	require.Less(t, time.Since(start), 4*syncStatusPollInterval)
}
