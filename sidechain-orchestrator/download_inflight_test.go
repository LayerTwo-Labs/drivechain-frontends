package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// TestDownload_InFlightClearsOnCtxCancel is the regression guard for the
// "X is already being downloaded" wedge: an unprotected `ch <- progress`
// send in the download goroutine could block forever once the buffered
// channel filled and the consumer disappeared, the deferred
// `inFlight.Delete` never fired, and every subsequent Download call for
// the same binary errored out — exactly what hit the user after they
// canceled a bitcoind download and clicked restart.
//
// Strategy: start a download against a slow HTTP server, cancel the ctx
// while bytes are still streaming, do NOT drain the returned channel
// (mimics a Flutter consumer that disconnected mid-download), wait, then
// kick off a second Download. The second call must succeed instead of
// erroring out with "already being downloaded".
func TestDownload_InFlightClearsOnCtxCancel(t *testing.T) {
	const (
		totalSize = 5 * 1024 * 1024 // 5MB so multiple percent ticks fire
	)
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		w.WriteHeader(http.StatusOK)
		flusher, _ := w.(http.Flusher)
		// Drip-feed: one chunk every few ms — gives us a window to cancel
		// while the goroutine is mid-stream.
		const chunk = 16 * 1024
		for i := 0; i < totalSize; i += chunk {
			end := i + chunk
			if end > totalSize {
				end = totalSize
			}
			_, _ = w.Write(payload[i:end])
			if flusher != nil {
				flusher.Flush()
			}
			time.Sleep(2 * time.Millisecond)
		}
	}))
	defer srv.Close()

	dm, _ := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	cfg := BinaryConfig{
		Name:           "wedgetest",
		BinaryName:     "wedgetest",
		DownloadSource: DownloadSourceDirect,
		Files:          map[string]string{currentOS(): "wedgetest.bin"},
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
	}

	ctx1, cancel1 := context.WithCancel(context.Background())
	ch1, err := dm.Download(ctx1, cfg, "", false)
	require.NoError(t, err, "first Download must register")

	// DO NOT drain ch1 — simulates a Flutter consumer that walked away.
	// Cancel mid-stream so the goroutine has to bail through ctx and not
	// the happy "Done: true" path.
	time.Sleep(20 * time.Millisecond)
	cancel1()
	_ = ch1

	// Wait long enough for the canceled goroutine's deferred cleanup to
	// run. If `inFlight.Delete` never fired, the next Download will error.
	deadline := time.Now().Add(2 * time.Second)
	var lastErr error
	for time.Now().Before(deadline) {
		ctx2, cancel2 := context.WithCancel(context.Background())
		_, lastErr = dm.Download(ctx2, cfg, "", false)
		cancel2()
		if lastErr == nil {
			return
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("second Download still wedged after 2s: %v (inflight.Delete deferred but goroutine never returned — buffered channel send was likely blocked)", lastErr)
}
