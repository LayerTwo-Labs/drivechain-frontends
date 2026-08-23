package scanner

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// authRecorder answers getblockcount and records the password it received.
func authRecorder(t *testing.T) (*httptest.Server, func() string) {
	t.Helper()
	var mu sync.Mutex
	var lastPass string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, pass, _ := r.BasicAuth()
		mu.Lock()
		lastPass = pass
		mu.Unlock()
		w.Header().Set("content-type", "application/json")
		_, _ = w.Write([]byte(`{"result":42,"error":null}`))
	}))
	t.Cleanup(srv.Close)
	return srv, func() string {
		mu.Lock()
		defer mu.Unlock()
		return lastPass
	}
}

func TestClientRereadsCookiePerCall(t *testing.T) {
	t.Parallel()
	srv, lastPass := authRecorder(t)

	path := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(path, []byte("__cookie__:first"), 0o600))

	c := &Client{URL: srv.URL, CookiePath: path, HTTP: srv.Client()}

	_, err := c.GetBlockCount(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "first", lastPass())

	// Core writes a new password every time it starts.
	require.NoError(t, os.WriteFile(path, []byte("__cookie__:second"), 0o600))

	_, err = c.GetBlockCount(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "second", lastPass())
}

func TestClientUsesStaticCredentialsWithoutCookie(t *testing.T) {
	t.Parallel()
	srv, lastPass := authRecorder(t)

	c := &Client{URL: srv.URL, User: "user", Pass: "static", HTTP: srv.Client()}

	_, err := c.GetBlockCount(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "static", lastPass())
}

func TestClientReportsUnauthorized(t *testing.T) {
	t.Parallel()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
	}))
	t.Cleanup(srv.Close)

	c := &Client{URL: srv.URL, User: "user", Pass: "wrong", HTTP: srv.Client()}

	_, err := c.GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "unauthorized")
	assert.NotContains(t, err.Error(), "EOF")
}

func TestClientReportsMissingCookie(t *testing.T) {
	t.Parallel()
	srv, _ := authRecorder(t)

	c := &Client{URL: srv.URL, CookiePath: filepath.Join(t.TempDir(), "absent"), HTTP: srv.Client()}

	_, err := c.GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "read cookie")
}

func TestReadCookieRejectsMalformedFile(t *testing.T) {
	t.Parallel()
	path := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(path, []byte("no-colon-here"), 0o600))

	_, _, err := ReadCookie(path)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "expected user:password")
}

func TestReadCookieTrimsWhitespace(t *testing.T) {
	t.Parallel()
	path := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(path, []byte("  __cookie__:pass\n"), 0o600))

	user, pass, err := ReadCookie(path)
	require.NoError(t, err)
	assert.Equal(t, "__cookie__", user)
	assert.Equal(t, "pass", pass)
}
