package chaindata

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

type fakeMempoolCore struct {
	mu      sync.Mutex
	height  uint32
	seq     uint64
	txs     map[string]coreEntry
	blocks  map[string]blockInfo
	calls   map[string]int
	batches int
	hold    chan struct{}
}

func newFakeMempoolCore() *fakeMempoolCore {
	return &fakeMempoolCore{txs: map[string]coreEntry{}, blocks: map[string]blockInfo{}, calls: map[string]int{}}
}

func txid(n int) string { return fmt.Sprintf("%064x", n) }

func key(n int) txKey {
	k, err := parseTxKey(txid(n))
	if err != nil {
		panic(err)
	}
	return k
}

func mpEntry(feeSats int64, vsize uint32, at int64) coreEntry {
	var e coreEntry
	e.Fees.Base = float64(feeSats) / 1e8
	e.Fees.Ancestor = e.Fees.Base
	e.Vsize, e.AncestorSize, e.Time = vsize, vsize, at
	return e
}

func (f *fakeMempoolCore) count(method string) int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.calls[method]
}

func (f *fakeMempoolCore) call(_ context.Context, method string, params ...any) (json.RawMessage, error) {
	f.mu.Lock()
	f.calls[method]++
	hold := f.hold
	f.mu.Unlock()
	if hold != nil && method == "getmempoolentry" {
		<-hold
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	switch method {
	case "getblockcount":
		return json.Marshal(f.height)
	case "getrawmempool":
		if len(params) > 0 && params[0] == true {
			return json.Marshal(f.txs)
		}
		ids := make([]string, 0, len(f.txs))
		for id := range f.txs {
			ids = append(ids, id)
		}
		sort.Strings(ids)
		return json.Marshal(map[string]any{"txids": ids, "mempool_sequence": f.seq})
	case "getmempoolentry":
		e, ok := f.txs[params[0].(string)]
		if !ok {
			return nil, fmt.Errorf("getmempoolentry RPC error -5: Transaction not in mempool")
		}
		return json.Marshal(e)
	case "getmempoolinfo":
		var vsize uint32
		for _, e := range f.txs {
			vsize += e.Vsize
		}
		return json.Marshal(map[string]any{"size": len(f.txs), "bytes": vsize})
	case "getblock":
		return json.Marshal(f.blocks[params[0].(string)])
	}
	return nil, fmt.Errorf("fake core: no %s", method)
}

func (f *fakeMempoolCore) batch(ctx context.Context, method string, params [][]any) ([]BatchResult, error) {
	f.mu.Lock()
	f.batches++
	f.mu.Unlock()
	out := make([]BatchResult, len(params))
	for i, p := range params {
		out[i].Result, out[i].Err = f.call(ctx, method, p...)
	}
	return out, nil
}

// add puts a tx in Core and returns the A message for it.
func (f *fakeMempoolCore) add(n int, e coreEntry) seqEvent {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.txs[txid(n)] = e
	ev := seqEvent{label: 'A', hash: key(n), seq: f.seq}
	f.seq++
	return ev
}

func (f *fakeMempoolCore) remove(n int) seqEvent {
	f.mu.Lock()
	defer f.mu.Unlock()
	delete(f.txs, txid(n))
	ev := seqEvent{label: 'R', hash: key(n), seq: f.seq}
	f.seq++
	return ev
}

// mine puts txs n in a block and returns the C message for it.
func (f *fakeMempoolCore) mine(hashN int, ns ...int) seqEvent {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.height++
	b := blockInfo{Height: f.height}
	for _, n := range ns {
		delete(f.txs, txid(n))
		b.Tx = append(b.Tx, txid(n))
		f.seq++
	}
	f.blocks[txid(hashN)] = b
	return seqEvent{label: 'C', hash: key(hashN)}
}

func startMempool(t *testing.T, core *fakeMempoolCore) *Mempool {
	t.Helper()
	m := newMempool(core.call, core.batch)
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan struct{})
	go func() {
		defer close(done)
		m.run(ctx, func(err error) { t.Logf("tracker: %v", err) })
	}()
	t.Cleanup(func() {
		cancel()
		<-done
	})
	require.Eventually(t, m.Ready, time.Second, time.Millisecond)
	return m
}

func txids(txs []MempoolTx) []string {
	out := make([]string, len(txs))
	for i, tx := range txs {
		out[i] = strings.TrimLeft(tx.Txid, "0")
	}
	return out
}

func TestMempoolSeedsThenFollowsTheFeed(t *testing.T) {
	core := newFakeMempoolCore()
	core.add(1, mpEntry(1000, 100, 10))
	core.add(2, mpEntry(5000, 200, 20))
	m := startMempool(t, core)
	require.Equal(t, 1, core.count("getrawmempool")-1, "one txid read and one verbose read")

	m.push(core.add(3, mpEntry(300, 100, 30)))
	m.push(core.remove(1))
	txs, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 2, total)
	require.Equal(t, []string{"3", "2"}, txids(txs), "a read after a message shows it")
	require.Equal(t, int64(300), txs[0].FeeSats)
	require.Equal(t, time.Unix(30, 0), txs[0].Time)

	m.push(core.mine(100, 2))
	txs, total, err = m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 1, total)
	require.Equal(t, []string{"3"}, txids(txs), "a block takes its transactions with no R message")
	require.Equal(t, 2, core.count("getrawmempool"), "no full read after the seed")
}

func TestMempoolNewestKeepsTheCountNewest(t *testing.T) {
	core := newFakeMempoolCore()
	for n := 1; n <= 50; n++ {
		core.add(n, mpEntry(100, 100, int64(n%10)))
	}
	m := startMempool(t, core)
	txs, total, err := m.Newest(t.Context(), 3)
	require.NoError(t, err)
	require.Equal(t, 50, total)
	require.Len(t, txs, 3)
	for _, tx := range txs {
		require.Equal(t, time.Unix(9, 0), tx.Time)
	}
}

func TestMempoolStatsBucketsAndMedian(t *testing.T) {
	core := newFakeMempoolCore()
	core.add(1, mpEntry(50, 100, 1))
	core.add(2, mpEntry(300, 100, 1))
	core.add(3, mpEntry(600, 200, 1))
	core.add(4, mpEntry(15000, 100, 1))
	m := startMempool(t, core)

	stats, err := m.Stats(t.Context(), []float64{0, 1, 2, 5, 100})
	require.NoError(t, err)
	require.Equal(t, uint64(4), stats.TxCount)
	require.Equal(t, uint64(500), stats.Vsize)
	require.Equal(t, uint64(15950), stats.FeeSats)
	require.InDelta(t, 3, stats.MedianFeeRate, 1e-9)
	got := make([]string, len(stats.Buckets))
	for i, b := range stats.Buckets {
		got[i] = fmt.Sprintf("%g:%d:%d:%d", b.MinFeeRate, b.TxCount, b.Vsize, b.FeeSats)
	}
	require.Equal(t, []string{"0:1:100:50", "1:0:0:0", "2:2:300:900", "5:0:0:0", "100:1:100:15000"}, got)
}

func TestMempoolBatchesTheEntryReads(t *testing.T) {
	core := newFakeMempoolCore()
	m := startMempool(t, core)
	hold := make(chan struct{})
	core.mu.Lock()
	core.hold = hold
	core.mu.Unlock()

	m.push(core.add(1, mpEntry(100, 100, 1)))
	require.Eventually(t, func() bool { return core.count("getmempoolentry") == 1 }, time.Second, time.Millisecond)
	batches := core.batches
	for n := 2; n <= 20; n++ {
		m.push(core.add(n, mpEntry(100, 100, 1)))
	}
	core.mu.Lock()
	core.hold = nil
	core.mu.Unlock()
	close(hold)

	_, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 20, total)
	core.mu.Lock()
	defer core.mu.Unlock()
	require.Equal(t, batches+1, core.batches, "the messages that wait share one batch")
}

func TestMempoolSkipsWhatTheSeedHolds(t *testing.T) {
	core := newFakeMempoolCore()
	stale := core.add(1, mpEntry(100, 100, 1))
	gone := core.add(2, mpEntry(100, 100, 1))
	m := startMempool(t, core)

	core.remove(2)
	m.push(stale)
	m.push(seqEvent{label: 'R', hash: key(1), seq: 0})
	_, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 2, total, "messages from before the seed change nothing")

	m.push(gone)
	m.push(core.add(3, mpEntry(100, 100, 1)))
	m.push(seqEvent{label: 'A', hash: key(4), seq: 99})
	txs, _, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.ElementsMatch(t, []string{"1", "2", "3"}, txids(txs), "a tx that left again has no entry")
}

func TestMempoolGapReadsTheMempoolAgain(t *testing.T) {
	core := newFakeMempoolCore()
	m := startMempool(t, core)
	core.add(1, mpEntry(100, 100, 1))
	m.push(seqEvent{gap: true})
	require.Eventually(t, func() bool { return core.count("getrawmempool") == 4 && m.Ready() }, time.Second, time.Millisecond)
	_, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 1, total)
}

func TestMempoolReorgReadsTheMempoolAgain(t *testing.T) {
	core := newFakeMempoolCore()
	core.add(1, mpEntry(100, 100, 1))
	m := startMempool(t, core)

	// A block takes tx 1 and a reorg puts it back while the copy holds the
	// C message but skips the A message of the return.
	connect := core.mine(100, 1)
	core.mu.Lock()
	core.txs[txid(1)] = mpEntry(100, 100, 1)
	core.mu.Unlock()
	m.push(connect)
	m.push(seqEvent{label: 'D', hash: key(100)})
	require.Eventually(t, func() bool { return core.count("getrawmempool") == 4 && m.Ready() }, time.Second, time.Millisecond)
	_, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 1, total)
}

func TestMempoolCheckFindsALostMessage(t *testing.T) {
	checkAfter, checkIdle = []time.Duration{20 * time.Millisecond, 40 * time.Millisecond}, 10*time.Millisecond
	t.Cleanup(func() { checkAfter, checkIdle = []time.Duration{time.Second, 5 * time.Second}, time.Second })
	core := newFakeMempoolCore()
	m := newMempool(core.call, core.batch)
	var seeds atomic.Int32
	m.seeded = func() { seeds.Add(1) }
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan struct{})
	go func() {
		defer close(done)
		m.run(ctx, func(error) {})
	}()
	t.Cleanup(func() {
		cancel()
		<-done
	})
	require.Eventually(t, func() bool { return seeds.Load() == 1 }, time.Second, time.Millisecond)

	core.add(1, mpEntry(100, 100, 1))
	require.Eventually(t, func() bool { return seeds.Load() == 2 }, time.Second, time.Millisecond, "a check after the seed finds the tx and seeds again")
	_, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 1, total)
	time.Sleep(100 * time.Millisecond)
	require.Equal(t, int32(2), seeds.Load(), "a copy that matches Core seeds no more")
}

func TestMempoolWithNoCopyReadsCore(t *testing.T) {
	core := newFakeMempoolCore()
	core.add(1, mpEntry(100, 100, 1))
	m := newMempool(core.call, core.batch)
	txs, total, err := m.Newest(t.Context(), 0)
	require.NoError(t, err)
	require.Equal(t, 1, total)
	require.Equal(t, []string{"1"}, txids(txs))
	require.Equal(t, 1, core.count("getrawmempool"))
}

func TestMempoolFeedSendsASnapshotThenChanges(t *testing.T) {
	core := newFakeMempoolCore()
	core.add(1, mpEntry(100, 100, 1))
	m := startMempool(t, core)
	feed := m.Watch(t.Context())

	snap, changes, err := feed.Next(t.Context())
	require.NoError(t, err)
	require.Empty(t, changes)
	require.Equal(t, []string{"1"}, txids(snap.Txs))

	m.push(core.add(2, mpEntry(100, 100, 2)))
	m.push(core.mine(100, 1))
	var got []MempoolChange
	require.Eventually(t, func() bool {
		ctx, cancel := context.WithTimeout(t.Context(), 10*time.Millisecond)
		defer cancel()
		_, more, _ := feed.Next(ctx)
		got = append(got, more...)
		return len(got) == 2
	}, time.Second, time.Millisecond)
	require.Equal(t, txid(2), got[0].Added.Txid)
	require.Equal(t, &MempoolBlock{Hash: txid(100), Height: 1, Connected: true, Txids: []string{txid(1)}}, got[1].Block)
}

func TestMempoolChangesWakesOnEachMessage(t *testing.T) {
	core := newFakeMempoolCore()
	m := startMempool(t, core)
	changes := m.Changes(t.Context())

	for n := 1; n <= 3; n++ {
		m.push(core.add(n, mpEntry(100, 100, int64(n))))
		select {
		case <-changes:
		case <-time.After(time.Second):
			t.Fatalf("no wake for tx %d", n)
		}
		txs, _, err := m.Newest(t.Context(), 1)
		require.NoError(t, err)
		require.Equal(t, []string{fmt.Sprint(n)}, txids(txs), "a read after the wake holds the tx")
	}
}

func TestParseTxKeyRoundTrips(t *testing.T) {
	k, err := parseTxKey(txid(7))
	require.NoError(t, err)
	require.Equal(t, txid(7), hex.EncodeToString(k[:]))
	_, err = parseTxKey("zz")
	require.Error(t, err)
}
