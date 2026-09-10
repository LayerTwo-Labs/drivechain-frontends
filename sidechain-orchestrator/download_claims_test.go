package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Two callers can each own one part of a sidechain download. Each part must
// clear its claim when it lands, or the callers wait on each other forever.
func TestDownload_ReleasesEachTargetBeforeTheNext(t *testing.T) {
	binName := "thunder"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	archive := makeZipBytes(t, map[string][]byte{binName: []byte("test-bin")})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(archive)
	}))
	defer srv.Close()

	dm, _ := newTestDownloadManager(t)
	dm.httpClient = srv.Client()
	cfg := makeSidechainConfig(srv.URL + "/")
	dm.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{
			BinaryName: c.AltBinaryName,
			BaseURL:    c.AltBaseURL("default"),
			FileName:   fileForPlatform(c.AltFiles),
		}, true
	}

	targets := dm.Targets(cfg, "default", DownloadOptions{})
	require.Len(t, targets, 2)
	app, backend := targets[0], targets[1]

	backendDone := make(chan struct{})
	dm.inFlight.Store(backend.InFlightKey, backendDone)

	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)

	require.Eventually(t, func() bool {
		_, busy := dm.inFlight.Load(app.InFlightKey)
		return !busy
	}, 5*time.Second, 10*time.Millisecond, "the app claim must clear while the backend is in flight")

	require.NoError(t, os.MkdirAll(filepath.Dir(backend.BinPath), 0o755))
	require.NoError(t, os.WriteFile(backend.BinPath, []byte("prod-bin"), 0o755))
	dm.inFlight.Delete(backend.InFlightKey)
	close(backendDone)

	last := drainProgress(t, ch)
	assert.True(t, last.Done)
}
