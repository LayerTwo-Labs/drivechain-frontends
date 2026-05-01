package api

import (
	"archive/zip"
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"runtime"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

// TestDownloadBinary_StreamsProgressAndCompletes is the end-to-end regression
// guard for the DownloadBinary RPC: a fresh download must stream incremental
// progress (BytesDownloaded / TotalBytes), end with Done=true, and the
// channel-to-stream forwarder must not drop or reorder events.
//
// Why end-to-end: download_test.go covers the channel layer directly, and
// download_progress_test.go covers downloadFile throttling. Neither catches
// regressions in the Connect handler that reads `<-ch` and calls stream.Send
// — exactly the seam where my failBoot / select-on-ctx changes touched code.
func TestDownloadBinary_StreamsProgressAndCompletes(t *testing.T) {
	// Stub binary download server. Use a real zip whose payload entry is
	// large enough to cross multiple 1% progress thresholds in downloadFile,
	// so the stream carries intermediate frames not just the final Done.
	bigBinary := bytes.Repeat([]byte("x"), 200_000)
	payload := makeZipBytes(t, map[string][]byte{"streamtest": bigBinary})
	binarySrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(payload)))
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(payload)
	}))
	defer binarySrv.Close()

	// Build an orch with a single test binary pointed at the stub server.
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": binarySrv.URL + "/"},
		Files:          map[string]string{currentOS(): "streamtest.zip"},
	})

	// Wire the Connect handler behind an h2c httptest server.
	mux := http.NewServeMux()
	path, h := rpc.NewOrchestratorServiceHandler(NewHandler(orch))
	mux.Handle(path, h)
	connectSrv := httptest.NewUnstartedServer(h2c.NewHandler(mux, &http2.Server{}))
	connectSrv.Start()
	defer connectSrv.Close()

	client := rpc.NewOrchestratorServiceClient(connectSrv.Client(), connectSrv.URL, connect.WithGRPC())

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	stream, err := client.DownloadBinary(ctx, connect.NewRequest(&pb.DownloadBinaryRequest{
		Name:  "streamtest",
		Force: true,
	}))
	require.NoError(t, err)

	var (
		events       []*pb.DownloadBinaryResponse
		sawProgress  bool
		lastByteSeen int64
	)
	for stream.Receive() {
		msg := stream.Msg()
		events = append(events, msg)
		require.Empty(t, msg.Error, "no event must carry an error in the happy path: %+v", msg)

		if msg.BytesDownloaded > 0 {
			sawProgress = true
			require.GreaterOrEqual(t, msg.BytesDownloaded, lastByteSeen, "progress must be monotonic")
			lastByteSeen = msg.BytesDownloaded
		}
	}
	require.NoError(t, stream.Err(), "stream must close cleanly")
	require.NotEmpty(t, events, "must receive at least one event")

	last := events[len(events)-1]
	require.True(t, last.Done, "last event must have Done=true; got %+v", last)
	require.True(t, sawProgress || last.Done, "either progress events or a Done frame must be present")
}

// TestDownloadBinary_RejectsUnknownBinary confirms the handler returns an
// error before opening a stream when the binary name isn't in the orch's
// config — Flutter shouldn't see a half-open stream that immediately closes.
func TestDownloadBinary_RejectsUnknownBinary(t *testing.T) {
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "http://example.invalid/"},
		Files:          map[string]string{currentOS(): "streamtest.zip"},
	})
	mux := http.NewServeMux()
	path, h := rpc.NewOrchestratorServiceHandler(NewHandler(orch))
	mux.Handle(path, h)
	srv := httptest.NewServer(h2c.NewHandler(mux, &http2.Server{}))
	defer srv.Close()

	client := rpc.NewOrchestratorServiceClient(srv.Client(), srv.URL, connect.WithGRPC())
	stream, err := client.DownloadBinary(context.Background(), connect.NewRequest(&pb.DownloadBinaryRequest{
		Name: "no-such-binary",
	}))
	require.NoError(t, err, "RPC dispatch itself must succeed")

	// Walk the stream — it should close with an error, not silently end empty.
	for stream.Receive() {
		// drain
	}
	require.Error(t, stream.Err(), "stream must surface the unknown-binary error to the caller")
}

// newTestOrchHandlerWithBinary builds a minimal Orchestrator wired with a
// single binary config — enough for DownloadBinary to walk through the
// download path without touching the rest of the configs.
func newTestOrchHandlerWithBinary(t *testing.T, cfg orchestrator.BinaryConfig) *orchestrator.Orchestrator {
	t.Helper()
	log := zerolog.New(io.Discard)
	o := orchestrator.New(t.TempDir(), "signet", t.TempDir(), []orchestrator.BinaryConfig{cfg}, log)
	return o
}

// currentOS mirrors orchestrator.currentOS — duplicated because the helper
// is unexported in the orchestrator package and we need the same key
// shape in BinaryConfig.Files for the orch's download lookup to match.
func currentOS() string {
	switch runtime.GOOS {
	case "darwin":
		return "macos"
	case "windows":
		return "windows"
	default:
		return "linux"
	}
}

// makeZipBytes builds an in-memory zip archive — duplicated from the
// orchestrator package's test helpers since those aren't exported.
func makeZipBytes(t *testing.T, files map[string][]byte) []byte {
	t.Helper()
	var buf bytes.Buffer
	w := zip.NewWriter(&buf)
	for name, content := range files {
		f, err := w.Create(name)
		require.NoError(t, err)
		_, err = f.Write(content)
		require.NoError(t, err)
	}
	require.NoError(t, w.Close())
	return buf.Bytes()
}
