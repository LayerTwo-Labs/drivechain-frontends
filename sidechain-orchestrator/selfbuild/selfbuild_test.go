package selfbuild

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestRunsTheStartFileOnly(t *testing.T) {
	self, err := Path()
	require.NoError(t, err)

	runs, err := Runs(self)
	require.NoError(t, err)
	require.True(t, runs)

	other := filepath.Join(t.TempDir(), "other")
	require.NoError(t, os.WriteFile(other, []byte("x"), 0o755))
	runs, err = Runs(other)
	require.NoError(t, err)
	require.False(t, runs)

	runs, err = Runs(filepath.Join(t.TempDir(), "missing"))
	require.NoError(t, err)
	require.False(t, runs)
}

func TestARewrittenStartFileIsAnotherBuild(t *testing.T) {
	self, err := Path()
	require.NoError(t, err)
	info, err := os.Stat(self)
	require.NoError(t, err)
	t.Cleanup(func() { _ = os.Chtimes(self, info.ModTime(), info.ModTime()) })

	require.NoError(t, os.Chtimes(self, time.Now(), info.ModTime().Add(time.Second)))
	runs, err := Runs(self)
	require.NoError(t, err)
	require.False(t, runs)
}

func TestAskReadsTheAnswer(t *testing.T) {
	srv := httptest.NewServer(Handler())
	t.Cleanup(srv.Close)
	self, err := Path()
	require.NoError(t, err)

	runs, err := Ask(t.Context(), srv.URL, self)
	require.NoError(t, err)
	require.True(t, runs)

	runs, err = Ask(t.Context(), srv.URL, filepath.Join(t.TempDir(), "missing"))
	require.NoError(t, err)
	require.False(t, runs)
}

func TestAskTreatsNoEndpointAsAnotherBuild(t *testing.T) {
	srv := httptest.NewServer(http.NotFoundHandler())
	t.Cleanup(srv.Close)

	runs, err := Ask(t.Context(), srv.URL, "/x")
	require.NoError(t, err)
	require.False(t, runs)
}
