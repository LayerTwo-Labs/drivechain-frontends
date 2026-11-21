package chaindata

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// fakeCore answers getblockchaininfo from its height and holds
// waitforblockheight until the height reaches the target.
type fakeCore struct {
	mu     sync.Mutex
	height int64
	down   error
	moved  chan struct{}
	calls  map[string]int
}

func newFakeCore() *fakeCore {
	return &fakeCore{moved: make(chan struct{}), calls: map[string]int{}}
}

func (f *fakeCore) count(method string) int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.calls[method]
}

func (f *fakeCore) mine() {
	f.mu.Lock()
	f.height++
	close(f.moved)
	f.moved = make(chan struct{})
	f.mu.Unlock()
}

func (f *fakeCore) stop(err error) {
	f.mu.Lock()
	f.down = err
	close(f.moved)
	f.moved = make(chan struct{})
	f.mu.Unlock()
}

func (f *fakeCore) call(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
	f.mu.Lock()
	f.calls[method]++
	f.mu.Unlock()
	for {
		f.mu.Lock()
		height, down, moved := f.height, f.down, f.moved
		f.mu.Unlock()
		if down != nil {
			return nil, down
		}
		switch method {
		case "getblockchaininfo":
			return json.RawMessage(fmt.Sprintf(`{"chain":"regtest","blocks":%d,"headers":%d,"bestblockhash":"h%d"}`, height, height, height)), nil
		case "waitforblockheight":
			if height >= params[0].(int64) {
				return json.RawMessage(fmt.Sprintf(`{"hash":"h%d","height":%d}`, height, height)), nil
			}
			select {
			case <-moved:
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		default:
			return json.RawMessage(`{}`), nil
		}
	}
}

func startEngine(t *testing.T, core *fakeCore) *Engine {
	t.Helper()
	e := New(Config{Call: core.call, Log: zerolog.Nop()})
	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	go e.Run(ctx)
	require.Eventually(t, func() bool { return e.Health() == nil }, 2*time.Second, 5*time.Millisecond)
	return e
}

func TestEngineIdleSendsOnlyTheLongPoll(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)

	for range 50 {
		raw, err := e.Get(KindBlockchainInfo)
		require.NoError(t, err)
		require.Contains(t, string(raw), `"blocks":0`)
	}
	time.Sleep(100 * time.Millisecond)
	require.Equal(t, 1, core.count("getblockchaininfo"))
	require.Equal(t, 1, core.count("waitforblockheight"))
}

func TestEngineNewBlockNotifiesAtOnce(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	ch := e.Subscribe(t.Context(), KindBlockchainInfo)

	core.mine()
	select {
	case <-ch:
	case <-time.After(time.Second):
		t.Fatal("no notification after a new block")
	}
	raw, err := e.Get(KindBlockchainInfo)
	require.NoError(t, err)
	require.Contains(t, string(raw), `"blocks":1`)
}

func TestEngineCoreDownShowsAtOnce(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)

	refused := errors.New("connection refused")
	core.stop(refused)
	require.Eventually(t, func() bool { return errors.Is(e.Health(), refused) }, time.Second, 5*time.Millisecond)
}

func TestCacheReadsCoreOnlyAfterAnEvent(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	var fetches atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(`[]`), nil
	}

	for range 10 {
		_, err := e.Call(t.Context(), "w", "listwallets", nil, fetch)
		require.NoError(t, err)
	}
	require.Equal(t, int32(1), fetches.Load())

	_, err := e.Call(t.Context(), "w", "loadwallet", []any{"x"}, fetch)
	require.NoError(t, err)
	require.Eventually(t, func() bool { return fetches.Load() == 3 }, time.Second, time.Millisecond,
		"a write reads the used value again at once")

	_, err = e.Call(t.Context(), "w", "listwallets", nil, fetch)
	require.NoError(t, err)
	require.Equal(t, int32(3), fetches.Load(), "the read after the refresh comes from memory")
}

func TestCacheDropsAnUnusedValue(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	var fetches atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(`[]`), nil
	}

	_, err := e.Call(t.Context(), "", "listwallets", nil, fetch)
	require.NoError(t, err)
	e.Fire(EventWrite)
	require.Eventually(t, func() bool { return fetches.Load() == 2 }, time.Second, time.Millisecond)
	e.Fire(EventWrite)
	e.Fire(EventWrite)
	time.Sleep(50 * time.Millisecond)
	require.Equal(t, int32(2), fetches.Load(), "a value that no caller read is not read again")
}

func TestCacheSendsMempoolReadsToCoreWithoutZMQ(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	var fetches atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(`{}`), nil
	}

	for range 3 {
		_, err := e.Call(t.Context(), "w", "getbalances", nil, fetch)
		require.NoError(t, err)
	}
	require.Equal(t, int32(3), fetches.Load())

	e.zmqUp.Store(true)
	for range 3 {
		_, err := e.Call(t.Context(), "w", "getbalances", nil, fetch)
		require.NoError(t, err)
	}
	require.Equal(t, int32(4), fetches.Load())
}

func TestCacheNeverKeepsAnError(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	boom := errors.New("boom")
	_, err := e.Call(t.Context(), "", "listwallets", nil, func(context.Context) (json.RawMessage, error) { return nil, boom })
	require.ErrorIs(t, err, boom)
	raw, err := e.Call(t.Context(), "", "listwallets", nil, func(context.Context) (json.RawMessage, error) { return json.RawMessage(`["a"]`), nil })
	require.NoError(t, err)
	require.JSONEq(t, `["a"]`, string(raw))
}

func TestEngineWithoutLongPollReadsOncePerSecond(t *testing.T) {
	var infos atomic.Int32
	e := New(Config{Log: zerolog.Nop(), Call: func(_ context.Context, method string, _ ...any) (json.RawMessage, error) {
		if method != "getblockchaininfo" {
			return nil, errors.New("Method not found")
		}
		infos.Add(1)
		return json.RawMessage(`{"chain":"regtest","blocks":1,"headers":1,"bestblockhash":"a"}`), nil
	}})
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go e.Run(ctx)

	time.Sleep(1500 * time.Millisecond)
	require.LessOrEqual(t, infos.Load(), int32(4))
	require.NoError(t, e.Health())
}

func TestWalletReadsRefreshAfterCoreSyncsItsWallets(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	e.zmqUp.Store(true)
	var fetches atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(`{}`), nil
	}
	_, err := e.Call(t.Context(), "w", "getbalances", nil, fetch)
	require.NoError(t, err)

	syncs := core.count("syncwithvalidationinterfacequeue")
	core.mine()
	require.Eventually(t, func() bool { return fetches.Load() == 2 }, time.Second, time.Millisecond)
	require.Greater(t, core.count("syncwithvalidationinterfacequeue"), syncs, "the refresh waits for Core's wallets")
}

func TestMempoolChurnCostsOneReadPerCaller(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	e.zmqUp.Store(true)
	var fetches atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(`{}`), nil
	}
	for _, method := range []string{"getbalances", "getrawmempool"} {
		fetches.Store(0)
		_, err := e.Call(t.Context(), "w", method, nil, fetch)
		require.NoError(t, err)

		for range 100 {
			e.Fire(EventMempool)
		}
		require.Eventually(t, func() bool {
			e.mu.Lock()
			defer e.mu.Unlock()
			return !e.settling
		}, time.Second, time.Millisecond)
		time.Sleep(20 * time.Millisecond)
		require.Equal(t, int32(1), fetches.Load(), "%s: no read before a caller asks", method)

		_, err = e.Call(t.Context(), "w", method, nil, fetch)
		require.NoError(t, err)
		require.Equal(t, int32(2), fetches.Load(), "%s: the caller reads Core", method)
	}
}

func TestStaleCallerDoesNotWaitForAnOlderRead(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	e.zmqUp.Store(true)
	release := make(chan struct{})
	defer close(release)
	var fetches atomic.Int32
	slow := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		<-release
		return json.RawMessage(`["old"]`), nil
	}
	go func() { _, _ = e.Call(context.Background(), "", "getrawmempool", nil, slow) }()
	require.Eventually(t, func() bool { return fetches.Load() == 1 }, time.Second, time.Millisecond)

	e.Fire(EventMempool)
	ctx, cancel := context.WithTimeout(t.Context(), time.Second)
	defer cancel()
	raw, err := e.Call(ctx, "", "getrawmempool", nil, func(context.Context) (json.RawMessage, error) {
		return json.RawMessage(`["new"]`), nil
	})
	require.NoError(t, err)
	require.JSONEq(t, `["new"]`, string(raw))
}

func TestWroteMarksWalletReadsStaleOnlyForAWrite(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	var fetches atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(`[]`), nil
	}
	_, err := e.Call(t.Context(), "", "listwallets", nil, fetch)
	require.NoError(t, err)

	e.Wrote("getblock")
	time.Sleep(50 * time.Millisecond)
	require.Equal(t, int32(1), fetches.Load())

	e.Wrote("loadwallet")
	require.Eventually(t, func() bool { return fetches.Load() == 2 }, time.Second, time.Millisecond)
}

func TestRestartStopsTheZMQFeed(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	e.zmqUp.Store(true)
	var cancelled atomic.Bool
	e.mu.Lock()
	e.zmqCancel = func() { cancelled.Store(true) }
	e.mu.Unlock()

	e.Restart()
	require.False(t, e.zmqUp.Load())
	require.True(t, cancelled.Load())
}

func TestRestartDetachesAReadInFlight(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	release := make(chan struct{})
	var old atomic.Int32
	slow := func(context.Context) (json.RawMessage, error) {
		old.Add(1)
		<-release
		return json.RawMessage(`["old"]`), nil
	}
	go func() { _, _ = e.Call(context.Background(), "", "listwallets", nil, slow) }()
	require.Eventually(t, func() bool { return old.Load() == 1 }, time.Second, time.Millisecond)

	e.Restart()
	close(release)
	require.Eventually(t, func() bool { return e.Health() == nil }, time.Second, time.Millisecond)
	raw, err := e.Call(t.Context(), "", "listwallets", nil, func(context.Context) (json.RawMessage, error) {
		return json.RawMessage(`["new"]`), nil
	})
	require.NoError(t, err)
	require.JSONEq(t, `["new"]`, string(raw))
	require.Equal(t, int32(1), old.Load(), "the old endpoint read is never started again")
}

func TestEngineReadsHeadersAfterALongPollTimeout(t *testing.T) {
	var headers atomic.Int64
	headers.Store(5)
	e := New(Config{Log: zerolog.Nop(), Call: func(ctx context.Context, method string, _ ...any) (json.RawMessage, error) {
		if method == "waitforblockheight" {
			time.Sleep(20 * time.Millisecond)
			return json.RawMessage(`{"hash":"a","height":5}`), nil
		}
		return json.RawMessage(fmt.Sprintf(`{"chain":"regtest","blocks":5,"headers":%d,"bestblockhash":"a"}`, headers.Load())), nil
	}})
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go e.Run(ctx)
	require.Eventually(t, func() bool { return e.Health() == nil }, time.Second, time.Millisecond)

	headers.Store(6)
	require.Eventually(t, func() bool {
		raw, err := e.Get(KindBlockchainInfo)
		return err == nil && strings.Contains(string(raw), `"headers":6`)
	}, time.Second, time.Millisecond, "a header with no block reaches the engine")
}

func TestEventsDuringARefreshStartOneMoreRead(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	e.zmqUp.Store(true)
	release := make(chan struct{})
	var fetches, inFlight, maxInFlight atomic.Int32
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		n := inFlight.Add(1)
		defer inFlight.Add(-1)
		for {
			m := maxInFlight.Load()
			if n <= m || maxInFlight.CompareAndSwap(m, n) {
				break
			}
		}
		if fetches.Load() > 1 {
			<-release
		}
		return json.RawMessage(`[]`), nil
	}
	_, err := e.Call(t.Context(), "", "getrawmempool", nil, fetch)
	require.NoError(t, err)

	for range 100 {
		e.Fire(EventBlock)
	}
	close(release)
	require.Eventually(t, func() bool { return inFlight.Load() == 0 && fetches.Load() >= 2 }, time.Second, time.Millisecond)
	time.Sleep(20 * time.Millisecond)
	require.LessOrEqual(t, fetches.Load(), int32(3))
	require.Equal(t, int32(1), maxInFlight.Load(), "one read per key at a time")
}

func TestWalletReadAfterABlockReadsCoreBeforeTheSettle(t *testing.T) {
	core := newFakeCore()
	release := make(chan struct{})
	t.Cleanup(func() { close(release) })
	call := func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		if method == "syncwithvalidationinterfacequeue" {
			select {
			case <-release:
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		}
		return core.call(ctx, method, params...)
	}
	e := New(Config{Call: call, Log: zerolog.Nop()})
	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	go e.Run(ctx)
	require.Eventually(t, func() bool { return e.Health() == nil }, 2*time.Second, 5*time.Millisecond)
	e.zmqUp.Store(true)

	var fetches atomic.Int32
	var balance atomic.Value
	balance.Store(`{"mine":{"trusted":1}}`)
	fetch := func(context.Context) (json.RawMessage, error) {
		fetches.Add(1)
		return json.RawMessage(balance.Load().(string)), nil
	}
	_, err := e.Call(t.Context(), "w", "getbalances", nil, fetch)
	require.NoError(t, err)

	balance.Store(`{"mine":{"trusted":2}}`)
	core.mine()
	require.Eventually(t, func() bool {
		raw, err := e.Get(KindBlockchainInfo)
		return err == nil && strings.Contains(string(raw), `"blocks":1`)
	}, time.Second, time.Millisecond)
	time.Sleep(20 * time.Millisecond)
	require.Equal(t, int32(1), fetches.Load(), "a block alone starts no wallet read")

	raw, err := e.Call(t.Context(), "w", "getbalances", nil, fetch)
	require.NoError(t, err)
	require.JSONEq(t, `{"mine":{"trusted":2}}`, string(raw), "a read after a block shows the block")
}

func TestBlockWakesWalletWatchersBeforeTheSettle(t *testing.T) {
	release := make(chan struct{})
	t.Cleanup(func() { close(release) })
	call := func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		select {
		case <-release:
		case <-ctx.Done():
			return nil, ctx.Err()
		}
		return nil, nil
	}
	e := New(Config{Call: call, Log: zerolog.Nop()})
	ch := e.Subscribe(t.Context(), KindWallet)

	e.Fire(EventBlock)
	select {
	case <-ch:
	case <-time.After(time.Second):
		t.Fatal("a block did not wake the wallet watchers")
	}
}

func TestEngineGivesTheTxidOfAWriteBeforeItsEvent(t *testing.T) {
	e := New(Config{Log: zerolog.Nop()})
	writes := e.SubscribeWrites(t.Context())
	wallet := e.Subscribe(t.Context(), KindWallet)
	txid := fmt.Sprintf("%064x", 7)

	_, err := e.Call(t.Context(), "w", "sendrawtransaction", []any{"00"}, func(context.Context) (json.RawMessage, error) {
		return json.Marshal(txid)
	})
	require.NoError(t, err)
	require.Equal(t, txid, <-writes)
	<-wallet

	_, err = e.Call(t.Context(), "w", "send", nil, func(context.Context) (json.RawMessage, error) {
		return json.Marshal(map[string]any{"txid": txid, "complete": true})
	})
	require.NoError(t, err)
	require.Equal(t, txid, <-writes)

	_, err = e.Call(t.Context(), "w", "lockunspent", nil, func(context.Context) (json.RawMessage, error) {
		return json.Marshal(true)
	})
	require.NoError(t, err)
	select {
	case got := <-writes:
		t.Fatalf("a write with no txid gave %s", got)
	default:
	}
}
