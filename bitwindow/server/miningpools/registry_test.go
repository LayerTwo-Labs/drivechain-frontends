package miningpools

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const onePool = `{"network": "betanet", "pools": [{"name": "Only Pool", "coinbase_tag": "/only/"}]}`

func failingFetch(context.Context, string) ([]byte, error) {
	return nil, errors.New("offline")
}

// settle waits for the refresh that New starts.
func settle(t *testing.T, r *Registry) {
	t.Helper()
	require.Eventually(t, func() bool {
		r.mu.Lock()
		defer r.mu.Unlock()
		return !r.refreshing
	}, 5*time.Second, 5*time.Millisecond)
}

func TestSource(t *testing.T) {
	t.Parallel()

	datadir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(datadir, RegtestFile), []byte(onePool), 0o600))

	for _, test := range []struct {
		name    string
		network config.Network
		ecashID string
		datadir string
		want    string
	}{
		{name: "eCash reads its network's registry", network: config.NetworkECash, ecashID: "betanet",
			want: "https://pool.drivechain.info/networks/betanet/pools.json"},
		{name: "eCash with no network id has none", network: config.NetworkECash},
		{name: "mainnet reads mempool's list", network: config.NetworkMainnet, want: mempoolRegistry},
		{name: "regtest reads the datadir file", network: config.NetworkRegtest, datadir: datadir,
			want: "file://" + filepath.Join(datadir, RegtestFile)},
		{name: "regtest with no file has none", network: config.NetworkRegtest, datadir: t.TempDir()},
		{name: "signet has none", network: config.NetworkSignet},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			url, parse := source(test.network, test.ecashID, test.datadir)
			assert.Equal(t, test.want, url)
			assert.Equal(t, test.want != "", parse != nil)
		})
	}
}

func TestRegistry(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	t.Run("betanet serves the built-in list while the fetch fails", func(t *testing.T) {
		t.Parallel()
		r := New(ctx, config.NetworkECash, "betanet", "", failingFetch)
		settle(t, r)

		resolved := r.Pools()
		assert.True(t, resolved.Available)
		assert.Equal(t, SourceBuiltIn, resolved.Source)
		assert.Len(t, resolved.Pools, len(betanetPools(t)))
	})

	t.Run("a fetched list replaces the built-in list", func(t *testing.T) {
		t.Parallel()
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			_, _ = w.Write([]byte(onePool))
		}))
		t.Cleanup(server.Close)
		fetch := func(ctx context.Context, _ string) ([]byte, error) {
			return DefaultFetch(ctx, server.URL)
		}

		r := New(ctx, config.NetworkECash, "betanet", "", fetch)
		settle(t, r)

		resolved := r.Pools()
		assert.Equal(t, "https://pool.drivechain.info/networks/betanet/pools.json", resolved.Source)
		require.Len(t, resolved.Pools, 1)
		assert.Equal(t, "Only Pool", resolved.Pools[0].Name)
	})

	t.Run("a failed refresh keeps the last good list", func(t *testing.T) {
		t.Parallel()
		var fail atomic.Bool
		fetch := func(context.Context, string) ([]byte, error) {
			if fail.Load() {
				return nil, errors.New("offline")
			}
			return []byte(onePool), nil
		}
		r := New(ctx, config.NetworkECash, "alphanet", "", fetch)
		settle(t, r)

		fail.Store(true)
		r.mu.Lock()
		r.expires = time.Time{}
		r.mu.Unlock()
		r.Pools()
		settle(t, r)

		resolved := r.Pools()
		require.Len(t, resolved.Pools, 1)
		assert.Equal(t, "Only Pool", resolved.Pools[0].Name)
	})

	t.Run("a list that does not parse keeps the last good list", func(t *testing.T) {
		t.Parallel()
		r := New(ctx, config.NetworkECash, "betanet", "", func(context.Context, string) ([]byte, error) {
			return []byte(`<html>`), nil
		})
		settle(t, r)

		assert.Equal(t, SourceBuiltIn, r.Pools().Source)
	})

	t.Run("the list refreshes once per TTL", func(t *testing.T) {
		t.Parallel()
		var fetches atomic.Int32
		r := New(ctx, config.NetworkECash, "alphanet", "", func(context.Context, string) ([]byte, error) {
			fetches.Add(1)
			return []byte(onePool), nil
		})
		settle(t, r)
		for range 5 {
			r.Pools()
		}
		settle(t, r)

		assert.EqualValues(t, 1, fetches.Load())
	})

	t.Run("a network with no registry is not available", func(t *testing.T) {
		t.Parallel()
		r := New(ctx, config.NetworkSignet, "", "", failingFetch)

		assert.False(t, r.Available())
		assert.Equal(t, Resolved{}, r.Pools())
	})

	t.Run("a nil registry is not available", func(t *testing.T) {
		t.Parallel()
		var r *Registry
		assert.False(t, r.Available())
	})
}

func TestDefaultFetch(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	t.Run("a status other than 200 is an error", func(t *testing.T) {
		t.Parallel()
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.WriteHeader(http.StatusNotFound)
		}))
		t.Cleanup(server.Close)

		_, err := DefaultFetch(ctx, server.URL)
		require.ErrorContains(t, err, "404")
	})

	t.Run("a file URL reads the file", func(t *testing.T) {
		t.Parallel()
		path := filepath.Join(t.TempDir(), "pools.json")
		require.NoError(t, os.WriteFile(path, []byte(onePool), 0o600))

		body, err := DefaultFetch(ctx, "file://"+path)
		require.NoError(t, err)
		assert.Equal(t, onePool, string(body))
	})
}
