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

// TestDownloadBinary_DispatchesAndCompletes is the regression guard for the
// unary DownloadBinary contract: the RPC returns immediately, the goroutine
// runs in the background, and the binary lands on disk eventually. Progress
// is no longer streamed back to the client — that's polled out of
// GetSyncStatus / DownloadManager.State, which is exercised elsewhere.
func TestDownloadBinary_DispatchesAndCompletes(t *testing.T) {
	bigBinary := bytes.Repeat([]byte("x"), 5*1024*1024)
	payload := makeZipBytes(t, map[string][]byte{"streamtest": bigBinary})
	binarySrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(payload)))
		if r.Method == http.MethodHead {
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(payload)
	}))
	defer binarySrv.Close()

	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": binarySrv.URL + "/"},
		Files:          map[string]string{currentOS(): "streamtest.zip"},
	})

	mux := http.NewServeMux()
	path, h := rpc.NewOrchestratorServiceHandler(NewHandler(orch))
	mux.Handle(path, h)
	connectSrv := httptest.NewUnstartedServer(h2c.NewHandler(mux, &http2.Server{}))
	connectSrv.Start()
	defer connectSrv.Close()

	client := rpc.NewOrchestratorServiceClient(connectSrv.Client(), connectSrv.URL, connect.WithGRPC())

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Unary call returns immediately — boot goroutine runs server-side.
	resp, err := client.DownloadBinary(ctx, connect.NewRequest(&pb.DownloadBinaryRequest{
		Name:  "streamtest",
		Force: true,
	}))
	require.NoError(t, err)
	require.NotNil(t, resp)

	// The download is now off-thread; spin until it lands or we hit timeout.
	deadline := time.Now().Add(20 * time.Second)
	for {
		if time.Now().After(deadline) {
			t.Fatalf("timed out waiting for download to complete")
		}
		// State stays populated while running and is deleted on completion.
		_, running := orch.DownloadStateForTest("streamtest")
		if !running {
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
}

// TestDownloadBinary_RejectsUnknownBinary confirms the handler returns an
// error directly — the goroutine never gets dispatched.
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
	_, err := client.DownloadBinary(context.Background(), connect.NewRequest(&pb.DownloadBinaryRequest{
		Name: "no-such-binary",
	}))
	require.Error(t, err, "unknown binary must surface as an RPC error")
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
