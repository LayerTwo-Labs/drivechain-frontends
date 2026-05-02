package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// blockHEAD wraps a handler so HEAD requests get 405 — used by tests that
// want to verify "unknown total" behavior, since the new probe step would
// otherwise pull Content-Length from the test server's HEAD response.
func blockHEAD(h http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodHead {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		h(w, r)
	}
}

func TestDownloadFile_ThrottlesProgress(t *testing.T) {
	// 5 MB payload — large enough to generate multiple progress events at
	// 1% granularity and to round to non-zero MB after conversion.
	totalSize := 5 * 1024 * 1024
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		if r.Method == http.MethodHead {
			return
		}
		_, _ = w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	ch := make(chan DownloadProgress, 2000)
	savePath := dir + "/test-download"

	err := dm.downloadFile(context.Background(), srv.URL+"/file", savePath, ch)
	require.NoError(t, err)
	close(ch)

	var events []DownloadProgress
	for p := range ch {
		events = append(events, p)
	}

	// 1% granularity — at most 101 events (0% through 100% inclusive).
	assert.LessOrEqual(t, len(events), 101, "should throttle to at most 101 events (1%% granularity)")
	assert.Greater(t, len(events), 0, "should have at least one progress event")

	expectedMBTotal := int64(totalSize / (1024 * 1024))
	for _, e := range events {
		assert.Equal(t, expectedMBTotal, e.MBTotal)
		assert.GreaterOrEqual(t, e.MBDownloaded, int64(0))
	}

	last := events[len(events)-1]
	assert.Equal(t, expectedMBTotal, last.MBDownloaded)
}

func TestDownloadFile_ThrottlesProgress_UnknownTotal(t *testing.T) {
	totalSize := 3 * 1024 * 1024
	payload := make([]byte, totalSize)

	// Block HEAD so the probe fails — exercises the "no Content-Length anywhere"
	// path. Real-world equivalent: a server that omits Content-Length on both
	// HEAD and GET (transfer-encoded streaming response).
	srv := httptest.NewServer(blockHEAD(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	ch := make(chan DownloadProgress, 2000)
	savePath := dir + "/test-download-unknown"

	err := dm.downloadFile(context.Background(), srv.URL+"/file", savePath, ch)
	require.NoError(t, err)
	close(ch)

	var events []DownloadProgress
	for p := range ch {
		events = append(events, p)
	}

	assert.GreaterOrEqual(t, len(events), 2, "should report roughly every 1MB")
	assert.LessOrEqual(t, len(events), 5, "should not over-report for 3MB")

	for _, e := range events {
		assert.Equal(t, int64(-1), e.MBTotal)
	}
}

func TestDownloadFile_ProgressMessages(t *testing.T) {
	totalSize := 5 * 1024 * 1024
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		if r.Method == http.MethodHead {
			return
		}
		_, _ = w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	ch := make(chan DownloadProgress, 2000)
	savePath := dir + "/test-download-msg"

	err := dm.downloadFile(context.Background(), srv.URL+"/file", savePath, ch)
	require.NoError(t, err)
	close(ch)

	var updates []DownloadProgress
	for p := range ch {
		if p.MBTotal > 0 {
			updates = append(updates, p)
		}
	}

	assert.Greater(t, len(updates), 0, "should have progress updates")

	expectedMBTotal := int64(totalSize / (1024 * 1024))
	for _, u := range updates {
		assert.Equal(t, expectedMBTotal, u.MBTotal)
		assert.GreaterOrEqual(t, u.MBDownloaded, int64(0))
	}

	last := updates[len(updates)-1]
	assert.Equal(t, expectedMBTotal, last.MBDownloaded)
}

func TestDownload_ConcurrentProtection(t *testing.T) {
	// Set up a server that blocks forever (until test cleanup)
	blockCh := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		<-blockCh // Block until test ends
	}))
	defer srv.Close()
	defer close(blockCh)

	dm, _ := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	config := BinaryConfig{
		Name:           "test-concurrent",
		BinaryName:     "test-binary",
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
		Files:          map[string]string{currentOS(): "test-binary.zip"},
	}

	// First download should succeed (start)
	_, err := dm.Download(context.Background(), config, "default", true)
	require.NoError(t, err)

	// Second download of the same binary should fail
	_, err = dm.Download(context.Background(), config, "default", true)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "already being downloaded")
}

func TestDownload_ConcurrentProtection_DifferentBinaries(t *testing.T) {
	blockCh := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		<-blockCh
	}))
	defer srv.Close()
	defer close(blockCh)

	dm, _ := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	config1 := BinaryConfig{
		Name:           "binary-a",
		BinaryName:     "binary-a",
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
		Files:          map[string]string{currentOS(): "binary-a.zip"},
	}
	config2 := BinaryConfig{
		Name:           "binary-b",
		BinaryName:     "binary-b",
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
		Files:          map[string]string{currentOS(): "binary-b.zip"},
	}

	// Different binaries should be downloadable concurrently
	_, err := dm.Download(context.Background(), config1, "default", true)
	require.NoError(t, err)

	_, err = dm.Download(context.Background(), config2, "default", true)
	require.NoError(t, err)
}

func TestForwardDownload(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	downloadCh <- DownloadProgress{MBDownloaded: 1, MBTotal: 10, Message: "1 / 10 MB"}
	downloadCh <- DownloadProgress{MBDownloaded: 5, MBTotal: 10, Message: "5 / 10 MB"}
	downloadCh <- DownloadProgress{Message: "extracting..."}
	downloadCh <- DownloadProgress{Message: "done", Done: true}
	close(downloadCh)

	err := forwardDownload(downloadCh, startupCh, "downloading-bitcoind")
	require.NoError(t, err)
	close(startupCh)

	var events []StartupProgress
	for p := range startupCh {
		events = append(events, p)
	}

	require.Len(t, events, 4)

	for _, e := range events {
		assert.Equal(t, "downloading-bitcoind", e.Stage)
	}

	assert.Equal(t, int64(1), events[0].MBDownloaded)
	assert.Equal(t, int64(10), events[0].MBTotal)
	assert.Equal(t, int64(5), events[1].MBDownloaded)
	assert.Equal(t, int64(10), events[1].MBTotal)

	assert.Equal(t, "extracting...", events[2].Message)
	assert.Equal(t, int64(0), events[2].MBDownloaded)
}

func TestForwardDownload_Error(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	downloadCh <- DownloadProgress{MBDownloaded: 1, MBTotal: 10, Message: "progress"}
	downloadCh <- DownloadProgress{Error: fmt.Errorf("network timeout")}
	close(downloadCh)

	err := forwardDownload(downloadCh, startupCh, "downloading-enforcer")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "network timeout")
	close(startupCh)

	var events []StartupProgress
	for p := range startupCh {
		events = append(events, p)
	}
	require.Len(t, events, 1)
	assert.Equal(t, "downloading-enforcer", events[0].Stage)
}

func TestForwardDownload_SkipsEmpty(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	downloadCh <- DownloadProgress{MBDownloaded: 0, MBTotal: 0, Message: ""}
	downloadCh <- DownloadProgress{MBDownloaded: 1, MBTotal: 10, Message: "progress"}
	close(downloadCh)

	err := forwardDownload(downloadCh, startupCh, "downloading-thunder")
	require.NoError(t, err)
	close(startupCh)

	var events []StartupProgress
	for p := range startupCh {
		events = append(events, p)
	}
	require.Len(t, events, 1)
	assert.Equal(t, int64(1), events[0].MBDownloaded)
}

func TestForwardDownload_AlreadyDownloaded(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	downloadCh <- DownloadProgress{Message: "already downloaded", Done: true}
	close(downloadCh)

	err := forwardDownload(downloadCh, startupCh, "downloading-bitcoind")
	require.NoError(t, err)
	close(startupCh)

	var events []StartupProgress
	for p := range startupCh {
		events = append(events, p)
	}
	require.Len(t, events, 1)
	assert.Equal(t, "already downloaded", events[0].Message)
	assert.Equal(t, int64(0), events[0].MBDownloaded)
}

func TestDownload_ClearsInFlightOnCompletion(t *testing.T) {
	totalSize := 1000
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		if r.Method == http.MethodHead {
			return
		}
		_, _ = w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	zipContent := makeZipBytes(t, map[string][]byte{"test-binary": []byte("data")})
	srv2 := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(zipContent)))
		if r.Method == http.MethodHead {
			return
		}
		_, _ = w.Write(zipContent)
	}))
	defer srv2.Close()
	dm.httpClient = srv2.Client()

	config := BinaryConfig{
		Name:           "test-clear",
		BinaryName:     "test-binary",
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": srv2.URL + "/"},
		Files:          map[string]string{currentOS(): "test-binary.zip"},
	}

	// First download
	ch, err := dm.Download(context.Background(), config, "default", true)
	require.NoError(t, err)
	drainProgress(t, ch)

	// Should be able to download again (inFlight cleared)
	_ = dir // suppress unused warning
	ch, err = dm.Download(context.Background(), config, "default", true)
	require.NoError(t, err)
	drainProgress(t, ch)
}

func TestDownloadFile_ProgressMessagesUnknownTotal(t *testing.T) {
	totalSize := 2 * 1024 * 1024
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(blockHEAD(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	ch := make(chan DownloadProgress, 2000)
	savePath := dir + "/test-unknown-msg"

	err := dm.downloadFile(context.Background(), srv.URL+"/file", savePath, ch)
	require.NoError(t, err)
	close(ch)

	var updates []DownloadProgress
	for p := range ch {
		if p.MBDownloaded > 0 {
			updates = append(updates, p)
		}
	}

	assert.Greater(t, len(updates), 0, "should have progress updates")

	for _, u := range updates {
		assert.LessOrEqual(t, u.MBTotal, int64(0), "unknown total should be <= 0")
		assert.Greater(t, u.MBDownloaded, int64(0))
	}
}
