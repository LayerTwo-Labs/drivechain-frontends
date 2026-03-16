package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDownloadFile_ThrottlesProgress(t *testing.T) {
	// Create a 100KB payload — small enough to be fast, large enough to generate
	// multiple progress events at 0.1% granularity (each 0.1% = 100 bytes).
	totalSize := 100_000
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		w.Write(payload)
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

	// With 0.1% granularity on 100KB, max possible events = 1000
	// But we should have far fewer than one-per-read-call (100KB / 32KB buffer = ~3 reads)
	// The exact count depends on how reads align, but must be <= 1000
	assert.LessOrEqual(t, len(events), 1000, "should throttle to at most 1000 events (0.1%% granularity)")
	assert.Greater(t, len(events), 0, "should have at least one progress event")

	// All events should have correct total
	for _, e := range events {
		assert.Equal(t, int64(totalSize), e.TotalBytes)
		assert.Greater(t, e.BytesDownloaded, int64(0))
	}

	// Last event should be at 100%
	last := events[len(events)-1]
	assert.Equal(t, int64(totalSize), last.BytesDownloaded)
}

func TestDownloadFile_ThrottlesProgress_UnknownTotal(t *testing.T) {
	// Create a 3MB payload with no Content-Length → unknown total
	totalSize := 3 * 1024 * 1024
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Don't set Content-Length so ContentLength = -1
		w.Write(payload)
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

	// With 3MB payload, should get ~3 events (one per MB)
	assert.GreaterOrEqual(t, len(events), 2, "should report roughly every 1MB")
	assert.LessOrEqual(t, len(events), 5, "should not over-report for 3MB")

	// TotalBytes should be -1 (unknown)
	for _, e := range events {
		assert.Equal(t, int64(-1), e.TotalBytes)
	}
}

func TestDownloadFile_ProgressMessages(t *testing.T) {
	totalSize := 100_000
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	ch := make(chan DownloadProgress, 2000)
	savePath := dir + "/test-download-msg"

	err := dm.downloadFile(context.Background(), srv.URL+"/file", savePath, ch)
	require.NoError(t, err)
	close(ch)

	var messages []string
	for p := range ch {
		if p.Message != "" {
			messages = append(messages, p.Message)
		}
	}

	assert.Greater(t, len(messages), 0, "should have progress messages")

	// All messages should contain "Downloaded" and "MB"
	for _, msg := range messages {
		assert.Contains(t, msg, "Downloaded")
		assert.Contains(t, msg, "MB")
	}

	// Last message should show 100.0%
	lastMsg := messages[len(messages)-1]
	assert.Contains(t, lastMsg, "100.0%")
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
		DownloadURL:    srv.URL + "/",
		Files:          map[string]string{currentOS(): "test-binary.zip"},
	}

	// First download should succeed (start)
	_, err := dm.Download(context.Background(), config, true)
	require.NoError(t, err)

	// Second download of the same binary should fail
	_, err = dm.Download(context.Background(), config, true)
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
		DownloadURL:    srv.URL + "/",
		Files:          map[string]string{currentOS(): "binary-a.zip"},
	}
	config2 := BinaryConfig{
		Name:           "binary-b",
		BinaryName:     "binary-b",
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    srv.URL + "/",
		Files:          map[string]string{currentOS(): "binary-b.zip"},
	}

	// Different binaries should be downloadable concurrently
	_, err := dm.Download(context.Background(), config1, true)
	require.NoError(t, err)

	_, err = dm.Download(context.Background(), config2, true)
	require.NoError(t, err)
}

func TestForwardDownload(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	// Send some progress events
	downloadCh <- DownloadProgress{BytesDownloaded: 1000, TotalBytes: 10000, Message: "Downloaded 0.00 MB / 0.01 MB (10.0%)"}
	downloadCh <- DownloadProgress{BytesDownloaded: 5000, TotalBytes: 10000, Message: "Downloaded 0.01 MB / 0.01 MB (50.0%)"}
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

	// All events should have the correct stage
	for _, e := range events {
		assert.Equal(t, "downloading-bitcoind", e.Stage)
	}

	// First two should have download bytes
	assert.Equal(t, int64(1000), events[0].BytesDownloaded)
	assert.Equal(t, int64(10000), events[0].TotalBytes)
	assert.Equal(t, int64(5000), events[1].BytesDownloaded)
	assert.Equal(t, int64(10000), events[1].TotalBytes)

	// Last two are messages without bytes
	assert.Equal(t, "extracting...", events[2].Message)
	assert.Equal(t, int64(0), events[2].BytesDownloaded)
}

func TestForwardDownload_Error(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	downloadCh <- DownloadProgress{BytesDownloaded: 1000, TotalBytes: 10000, Message: "progress"}
	downloadCh <- DownloadProgress{Error: fmt.Errorf("network timeout")}
	close(downloadCh)

	err := forwardDownload(downloadCh, startupCh, "downloading-enforcer")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "network timeout")
	close(startupCh)

	// Only the first event should have been forwarded (before the error)
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

	// An event with zero bytes and no message should be skipped
	downloadCh <- DownloadProgress{BytesDownloaded: 0, TotalBytes: 0, Message: ""}
	downloadCh <- DownloadProgress{BytesDownloaded: 1000, TotalBytes: 10000, Message: "progress"}
	close(downloadCh)

	err := forwardDownload(downloadCh, startupCh, "downloading-thunder")
	require.NoError(t, err)
	close(startupCh)

	var events []StartupProgress
	for p := range startupCh {
		events = append(events, p)
	}
	// Only the second event should be forwarded
	require.Len(t, events, 1)
	assert.Equal(t, int64(1000), events[0].BytesDownloaded)
}

func TestForwardDownload_AlreadyDownloaded(t *testing.T) {
	downloadCh := make(chan DownloadProgress, 10)
	startupCh := make(chan StartupProgress, 10)

	// "already downloaded" has a message but no bytes
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
	assert.Equal(t, int64(0), events[0].BytesDownloaded)
}

func TestDownload_ClearsInFlightOnCompletion(t *testing.T) {
	totalSize := 1000
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", totalSize))
		w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	zipContent := makeZipBytes(t, map[string][]byte{"test-binary": []byte("data")})
	srv2 := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(zipContent)))
		w.Write(zipContent)
	}))
	defer srv2.Close()
	dm.httpClient = srv2.Client()

	config := BinaryConfig{
		Name:           "test-clear",
		BinaryName:     "test-binary",
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    srv2.URL + "/",
		Files:          map[string]string{currentOS(): "test-binary.zip"},
	}

	// First download
	ch, err := dm.Download(context.Background(), config, true)
	require.NoError(t, err)
	drainProgress(t, ch)

	// Should be able to download again (inFlight cleared)
	// Need to remove the binary first since force=true still checks the goroutine
	_ = dir // suppress unused warning
	ch, err = dm.Download(context.Background(), config, true)
	require.NoError(t, err)
	drainProgress(t, ch)
}

func TestDownloadFile_ProgressMessagesUnknownTotal(t *testing.T) {
	totalSize := 2 * 1024 * 1024 // 2MB
	payload := make([]byte, totalSize)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// No Content-Length
		w.Write(payload)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	ch := make(chan DownloadProgress, 2000)
	savePath := dir + "/test-unknown-msg"

	err := dm.downloadFile(context.Background(), srv.URL+"/file", savePath, ch)
	require.NoError(t, err)
	close(ch)

	var messages []string
	for p := range ch {
		if p.Message != "" {
			messages = append(messages, p.Message)
		}
	}

	// When total is unknown, messages should be like "Downloaded X.XX MB"
	// and should NOT contain percentage or total
	for _, msg := range messages {
		assert.Contains(t, msg, "Downloaded")
		assert.True(t, strings.Contains(msg, "MB"))
		assert.NotContains(t, msg, "%", "unknown total should not show percentage")
		assert.NotContains(t, msg, "/", "unknown total should not show total size")
	}
}
