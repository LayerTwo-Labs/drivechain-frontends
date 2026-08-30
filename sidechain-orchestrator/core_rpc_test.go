package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// callWallet must route each call to /wallet/<name> without mutating shared
// client state — concurrent callers on one CoreStatusClient would otherwise
// nest paths or hit the wrong wallet.
func TestCallWalletConcurrentRouting(t *testing.T) {
	var mu sync.Mutex
	var paths []string

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		paths = append(paths, r.URL.Path)
		mu.Unlock()

		w.Header().Set("Content-Type", "application/json")
		_, _ = fmt.Fprintf(w, `{"result":"addr-for%s","error":null,"id":1}`, r.URL.Path)
	}))
	defer srv.Close()

	c := &CoreStatusClient{url: srv.URL, user: "user", password: "pass"}

	const iterations = 20
	wallets := []string{"alice", "bob"}
	got := make([]string, len(wallets)*iterations)

	var wg sync.WaitGroup
	for i, wallet := range wallets {
		for n := 0; n < iterations; n++ {
			wg.Add(1)
			go func(idx int, wallet string) {
				defer wg.Done()
				address, err := c.GetNewAddress(context.Background(), wallet)
				assert.NoError(t, err)
				got[idx] = address
			}(i*iterations+n, wallet)
		}
	}
	wg.Wait()

	for i, wallet := range wallets {
		for n := 0; n < iterations; n++ {
			assert.Equal(t, "addr-for/wallet/"+wallet, got[i*iterations+n])
		}
	}

	mu.Lock()
	defer mu.Unlock()
	require.Len(t, paths, len(wallets)*iterations)
	for _, path := range paths {
		assert.Contains(t, []string{"/wallet/alice", "/wallet/bob"}, path)
	}
	assert.Equal(t, srv.URL, c.url)
}
