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

// A network swap drops the core binary and restarts L1, so two paths ask for
// bitcoind at once. The loser must wait, not error out with a red banner.
func TestDownload_SecondCallerAttachesToInFlight(t *testing.T) {
	const totalSize = 512 * 1024

	payload := make([]byte, totalSize)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		w.WriteHeader(http.StatusOK)
		flusher, _ := w.(http.Flusher)
		const chunk = 16 * 1024
		for i := 0; i < totalSize; i += chunk {
			_, _ = w.Write(payload[i:min(i+chunk, totalSize)])
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
		Name:           "attachtest",
		BinaryName:     "attachtest",
		DownloadSource: DownloadSourceDirect,
		Files:          map[string]string{currentPlatform(): "attachtest.bin"},
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
	}

	ctx := context.Background()
	ch1, err := dm.Download(ctx, cfg, "", false)
	require.NoError(t, err, "first Download must register")

	ch2, err := dm.Download(ctx, cfg, "", false)
	require.NoError(t, err, "second Download must attach to the running one, not fail")
	require.NotNil(t, ch2)

	var firstDone bool
	for p := range ch1 {
		require.NoError(t, p.Error)
		if p.Done {
			firstDone = true
		}
	}
	require.True(t, firstDone, "first download must finish")

	select {
	case p, ok := <-ch2:
		require.True(t, ok, "attached caller must receive a result")
		require.NoError(t, p.Error)
		require.True(t, p.Done, "attached caller must see the download as done")
	case <-time.After(5 * time.Second):
		t.Fatal("attached caller never completed")
	}
}
