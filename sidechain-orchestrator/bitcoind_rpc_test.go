package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The gate enforces "at most bitcoindRPCMaxInflight calls hit bitcoind at
// once". Verify with a server that blocks until released, fires off twice
// the cap in parallel, and checks the high-water mark of concurrent
// handler invocations never exceeds the cap.
func TestCallBitcoindRPC_ConcurrencyCap(t *testing.T) {
	var (
		inflight    atomic.Int32
		maxInflight atomic.Int32
		release     = make(chan struct{})
	)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		cur := inflight.Add(1)
		for {
			prev := maxInflight.Load()
			if cur <= prev || maxInflight.CompareAndSwap(prev, cur) {
				break
			}
		}
		<-release
		inflight.Add(-1)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":1,"error":null}`))
	}))
	defer srv.Close()

	const callers = bitcoindRPCMaxInflight * 2
	var wg sync.WaitGroup
	wg.Add(callers)
	for i := 0; i < callers; i++ {
		go func() {
			defer wg.Done()
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			_, err := CallBitcoindRPC(ctx, srv.URL, "", "", "getblockchaininfo", nil)
			assert.NoError(t, err)
		}()
	}

	// Give all goroutines time to either acquire a slot or queue, then let
	// the cap settle before releasing — otherwise the test races to release
	// before the cap is ever reached.
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) && inflight.Load() < bitcoindRPCMaxInflight {
		time.Sleep(10 * time.Millisecond)
	}

	close(release)
	wg.Wait()

	assert.Equal(t, int32(bitcoindRPCMaxInflight), maxInflight.Load(),
		"gate should have admitted exactly bitcoindRPCMaxInflight callers at once")
}

// Cancelling the context while queued must return ctx.Err() instead of
// blocking forever or panicking on slot release.
func TestCallBitcoindRPC_QueuedCallerHonoursContext(t *testing.T) {
	hold := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		<-hold
		_, _ = w.Write([]byte(`{"result":1}`))
	}))
	defer srv.Close()
	defer close(hold)

	// Fill the gate so the next call has to queue.
	for i := 0; i < bitcoindRPCMaxInflight; i++ {
		go func() {
			_, _ = CallBitcoindRPC(context.Background(), srv.URL, "", "", "getblockchaininfo", nil)
		}()
	}
	require.Eventually(t, func() bool {
		return bitcoindRPCInflight.Load() == bitcoindRPCMaxInflight
	}, time.Second, 10*time.Millisecond)

	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	_, err := CallBitcoindRPC(ctx, srv.URL, "", "", "getblockchaininfo", nil)
	require.Error(t, err)
	assert.ErrorIs(t, err, context.Canceled)
}
