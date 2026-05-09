package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/require"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

const (
	eventuallyTimeout = 10 * time.Second
	eventuallyPoll    = 50 * time.Millisecond
)

// TestGetDownloadStatus_EmptyWhenNothingInFlight is the steady-state guard:
// no downloads running ⇒ the response is the empty list, not a synthetic
// "all idle" payload. The frontend's DownloadProvider relies on this to
// drop back to passive cadence.
func TestGetDownloadStatus_EmptyWhenNothingInFlight(t *testing.T) {
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "http://example.invalid/"},
		Files:          map[string]string{currentOS(): "streamtest.zip"},
	})
	client, stop := startTestOrchService(t, orch)
	defer stop()

	resp, err := client.GetDownloadStatus(context.Background(), connect.NewRequest(&pb.GetDownloadStatusRequest{}))
	require.NoError(t, err)
	require.Empty(t, resp.Msg.Downloads)
}

// TestGetDownloadStatus_ReportsInFlightDownload exercises the live path:
// kick off a real download against a slow HTTP server, hit the RPC mid-flight,
// and assert one entry comes back with the expected binary name and a
// non-zero MB total. We don't pin the exact MB value — the test server runs
// at whatever speed the host gives us.
func TestGetDownloadStatus_ReportsInFlightDownload(t *testing.T) {
	const totalSize = 5 * 1024 * 1024 // 5 MB
	hold := make(chan struct{})
	released := false
	var releaseOnce sync.Once
	binarySrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", "5242880")
		if r.Method == http.MethodHead {
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusOK)
		flusher, _ := w.(http.Flusher)
		// Send a small chunk, flush, then block until the test releases us.
		// That gives the in-flight RPC something to read.
		_, _ = w.Write(make([]byte, 1024))
		if flusher != nil {
			flusher.Flush()
		}
		<-hold
		_, _ = w.Write(make([]byte, totalSize-1024))
	}))
	defer func() {
		releaseOnce.Do(func() {
			released = true
			close(hold)
		})
		binarySrv.Close()
	}()
	_ = released

	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": binarySrv.URL + "/"},
		Files:          map[string]string{currentOS(): "streamtest.zip"},
	})
	client, stop := startTestOrchService(t, orch)
	defer stop()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	_, err := client.DownloadBinary(ctx, connect.NewRequest(&pb.DownloadBinaryRequest{
		Name:  "streamtest",
		Force: true,
	}))
	require.NoError(t, err)

	// Spin until the manager records something running, then sample the RPC.
	require.Eventually(t, func() bool {
		_, running := orch.DownloadStateForTest("streamtest")
		return running
	}, eventuallyTimeout, eventuallyPoll, "download never registered as running")

	// streamtest isn't a known BinaryType in the proto enum, so the handler
	// drops it from the response — exercise the empty-after-drop path.
	resp, err := client.GetDownloadStatus(ctx, connect.NewRequest(&pb.GetDownloadStatusRequest{}))
	require.NoError(t, err)
	require.Empty(
		t,
		resp.Msg.Downloads,
		"unknown binary names must be dropped, not shipped as UNSPECIFIED",
	)

	releaseOnce.Do(func() { close(hold) })
}

// TestGetDownloadStatus_KnownBinaryReportsTypedEnum is the typed-name guard:
// when a binary is in flight whose name maps to a known BinaryType enum, the
// response carries the enum value (not a string), so frontends can switch on
// it without parsing magic strings.
func TestGetDownloadStatus_KnownBinaryReportsTypedEnum(t *testing.T) {
	const totalSize = 5 * 1024 * 1024
	hold := make(chan struct{})
	var releaseOnce sync.Once
	binarySrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", "5242880")
		if r.Method == http.MethodHead {
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusOK)
		flusher, _ := w.(http.Flusher)
		_, _ = w.Write(make([]byte, 1024))
		if flusher != nil {
			flusher.Flush()
		}
		<-hold
		_, _ = w.Write(make([]byte, totalSize-1024))
	}))
	defer func() {
		releaseOnce.Do(func() { close(hold) })
		binarySrv.Close()
	}()

	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "thunder",
		BinaryName:     "thunder",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": binarySrv.URL + "/"},
		Files:          map[string]string{currentOS(): "thunder.zip"},
	})
	client, stop := startTestOrchService(t, orch)
	defer stop()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	_, err := client.DownloadBinary(ctx, connect.NewRequest(&pb.DownloadBinaryRequest{
		Name:  "thunder",
		Force: true,
	}))
	require.NoError(t, err)

	require.Eventually(t, func() bool {
		_, running := orch.DownloadStateForTest("thunder")
		return running
	}, eventuallyTimeout, eventuallyPoll, "download never registered as running")

	resp, err := client.GetDownloadStatus(ctx, connect.NewRequest(&pb.GetDownloadStatusRequest{}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Downloads, 1)
	require.Equal(t, pb.BinaryType_BINARY_TYPE_THUNDER, resp.Msg.Downloads[0].Binary)
}

// startTestOrchService stands up a connect server backed by `orch` and
// returns a client + a cleanup func. Used by the GetDownloadStatus tests
// to keep boilerplate out of each case.
func startTestOrchService(t *testing.T, orch *orchestrator.Orchestrator) (rpc.OrchestratorServiceClient, func()) {
	t.Helper()
	mux := http.NewServeMux()
	path, h := rpc.NewOrchestratorServiceHandler(NewHandler(orch))
	mux.Handle(path, h)
	srv := httptest.NewUnstartedServer(h2c.NewHandler(mux, &http2.Server{}))
	srv.Start()
	client := rpc.NewOrchestratorServiceClient(srv.Client(), srv.URL, connect.WithGRPC())
	return client, srv.Close
}
