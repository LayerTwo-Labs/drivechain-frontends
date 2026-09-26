package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/require"
)

// A chain lists the tools its boot arguments name among its dependencies. A
// start fetches them first, so a headless daemon boots the chain with the path.
func TestAStartFetchesTheToolsAChainBootsWith(t *testing.T) {
	o := newTestOrchestrator(t)
	archive := makeZipBytes(t, map[string][]byte{"grpcurl": []byte("binary")})
	var fetched atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		fetched.Add(1)
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(archive)))
		_, _ = w.Write(archive)
	}))
	defer srv.Close()
	o.download.httpClient = srv.Client()
	o.mu.Lock()
	o.configs["grpcurl"] = BinaryConfig{
		Name:           "grpcurl",
		DisplayName:    "grpcurl",
		BinaryName:     "grpcurl",
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": srv.URL + "/"},
		Files:          map[string]string{currentPlatform(): "grpcurl.zip"},
	}
	o.mu.Unlock()

	chain := BinaryConfig{Name: "freebank", Dependencies: []string{"bitcoind", "enforcer", "grpcurl"}}
	progress := make(chan StartupProgress, 100)
	o.fetchTools(context.Background(), chain, progress)
	require.NotEmpty(t, bootHost{orch: o}.ToolPath("grpcurl"))
	requests := fetched.Load()
	require.Positive(t, requests)

	o.fetchTools(context.Background(), chain, progress)
	require.Equal(t, requests, fetched.Load(), "a tool already on disk is not fetched again")
}
