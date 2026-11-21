package engines

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"testing"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	mempoolpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

const (
	testTimeout = 5 * time.Second
	testTick    = 10 * time.Millisecond
)

type fakeNode struct {
	mu      sync.Mutex
	results map[string]string
	errs    map[string]error
	calls   []string
}

func newFakeNode() *fakeNode {
	return &fakeNode{results: map[string]string{}, errs: map[string]error{}}
}

func (n *fakeNode) set(key, result string) {
	n.mu.Lock()
	defer n.mu.Unlock()
	n.results[key] = result
}

// call answers "method firstParam" when set, else "method".
func (n *fakeNode) call(_ context.Context, method string, params ...any) (json.RawMessage, error) {
	n.mu.Lock()
	defer n.mu.Unlock()
	keys := []string{method}
	if len(params) > 0 {
		keys = []string{fmt.Sprintf("%s %v", method, params[0]), method}
	}
	n.calls = append(n.calls, keys[0])
	for _, key := range keys {
		if err, ok := n.errs[key]; ok {
			return nil, err
		}
		if result, ok := n.results[key]; ok {
			return json.RawMessage(result), nil
		}
	}
	return nil, fmt.Errorf("fake node: no result for %s", keys[0])
}

func (n *fakeNode) count(key string) int {
	n.mu.Lock()
	defer n.mu.Unlock()
	var c int
	for _, call := range n.calls {
		if call == key {
			c++
		}
	}
	return c
}

func pbTx(txid string, height uint32, firstSeen int64) *mempoolpb.Transaction {
	return &mempoolpb.Transaction{
		Txid: txid, FeeSats: 1000, Vsize: 200, AncestorFeeSats: 4000, AncestorVsize: 400,
		Time: timestamppb.New(time.Unix(firstSeen, 0)), Height: height,
	}
}

func added(tx *mempoolpb.Transaction) *mempoolpb.Change {
	return &mempoolpb.Change{Change: &mempoolpb.Change_Added{Added: tx}}
}

func removed(txid string) *mempoolpb.Change {
	return &mempoolpb.Change{Change: &mempoolpb.Change_Removed{Removed: txid}}
}

func block(hash string, height uint32, connected bool, txids ...string) *mempoolpb.Change {
	return &mempoolpb.Change{Change: &mempoolpb.Change_Block{Block: &mempoolpb.Block{
		Hash: hash, Height: height, Connected: connected, Txids: txids,
	}}}
}

func statsNode() *fakeNode {
	node := newFakeNode()
	node.set("getblockstats", `{"minfeerate":2,"totalfee":5000}`)
	node.set("getblockhash", `"00"`)
	return node
}

// fakeFeed is a drivechaind mempool feed that a test writes to.
type fakeFeed struct {
	msgs   chan *mempoolpb.WatchTransactionsResponse
	closed chan struct{}
}

func newFakeFeed() *fakeFeed {
	return &fakeFeed{msgs: make(chan *mempoolpb.WatchTransactionsResponse), closed: make(chan struct{})}
}

// open ends the feed with ctx, as a stream does.
func (f *fakeFeed) open(ctx context.Context) (MempoolStream, error) {
	go func() {
		<-ctx.Done()
		f.Close() //nolint:errcheck // always nil
	}()
	return f, nil
}

func (f *fakeFeed) Receive() (*mempoolpb.WatchTransactionsResponse, error) {
	select {
	case msg, ok := <-f.msgs:
		if !ok {
			return nil, errors.New("feed closed")
		}
		return msg, nil
	case <-f.closed:
		return nil, errors.New("stream closed")
	}
}

func (f *fakeFeed) Close() error {
	select {
	case <-f.closed:
	default:
		close(f.closed)
	}
	return nil
}

func newTestWatcher(t *testing.T, node *fakeNode) (*MempoolWatcher, *sql.DB) {
	t.Helper()
	db := database.Test(t)
	w := NewMempoolWatcher(db, node.call, func(context.Context) (MempoolStream, error) {
		return nil, errors.New("no feed in this test")
	}, nodeModeWith(t, orchpb.NodeMode_NODE_MODE_FULL))
	w.statsLookback = 0
	return w, db
}

func storedTxids(t *testing.T, db *sql.DB) []string {
	t.Helper()
	txs, _, err := mempooltx.List(t.Context(), db, mempooltx.Filter{})
	require.NoError(t, err)
	out := []string{}
	for _, tx := range txs {
		out = append(out, tx.Txid)
	}
	return out
}

func storedHeights(t *testing.T, db *sql.DB) []uint32 {
	t.Helper()
	stats, err := mempooltx.ListBlockStats(t.Context(), db, 0, 1_000_000)
	require.NoError(t, err)
	out := []uint32{}
	for _, s := range stats {
		out = append(out, s.Height)
	}
	return out
}

func TestMempoolWatchBootstrap(t *testing.T) {
	ctx := t.Context()

	t.Run("stores the snapshot and drops rows not in the mempool", func(t *testing.T) {
		w, db := newTestWatcher(t, statsNode())
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "stale", FirstSeenHeight: 90}}))

		require.NoError(t, w.bootstrap(ctx, 100, []*mempoolpb.Transaction{pbTx("aa", 98, 1000), pbTx("bb", 99, 2000)}))

		assert.EqualValues(t, 100, w.Status().Tip)
		assert.Equal(t, []string{"aa", "bb"}, storedTxids(t, db))
	})

	t.Run("reads block stats back to the oldest entry", func(t *testing.T) {
		w, db := newTestWatcher(t, statsNode())
		w.statsLookback = 144

		require.NoError(t, w.bootstrap(ctx, 100, []*mempoolpb.Transaction{pbTx("aa", 92, 1000)}))

		assert.Equal(t, []uint32{92, 93, 94, 95, 96, 97, 98, 99, 100}, storedHeights(t, db))
	})

	t.Run("reads at least the reference blocks for an empty mempool", func(t *testing.T) {
		w, db := newTestWatcher(t, statsNode())
		w.statsLookback = 144

		require.NoError(t, w.bootstrap(ctx, 100, nil))

		assert.Equal(t, []uint32{95, 96, 97, 98, 99, 100}, storedHeights(t, db))
	})

	t.Run("a new snapshot updates the package rate", func(t *testing.T) {
		w, db := newTestWatcher(t, statsNode())
		require.NoError(t, w.bootstrap(ctx, 100, []*mempoolpb.Transaction{pbTx("aa", 100, 1)}))
		tx := pbTx("aa", 100, 1)
		tx.AncestorFeeSats, tx.AncestorVsize = 1000, 200
		require.NoError(t, w.bootstrap(ctx, 100, []*mempoolpb.Transaction{tx}))
		rows, _, err := mempooltx.List(ctx, db, mempooltx.Filter{})
		require.NoError(t, err)
		require.Len(t, rows, 1)
		assert.InDelta(t, 5.0, rows[0].FeeRate, 1e-9)
	})
}

func TestMempoolWatchHandleAdded(t *testing.T) {
	ctx := t.Context()

	t.Run("stores the tx with the ancestor package fee rate", func(t *testing.T) {
		w, db := newTestWatcher(t, newFakeNode())

		require.NoError(t, w.handle(ctx, added(pbTx("aa", 100, 1234))))

		txs, _, err := mempooltx.List(ctx, db, mempooltx.Filter{})
		require.NoError(t, err)
		require.Len(t, txs, 1)
		assert.Equal(t, "aa", txs[0].Txid)
		assert.EqualValues(t, 1000, txs[0].FeeSats)
		assert.EqualValues(t, 200, txs[0].Vsize)
		assert.InDelta(t, 10.0, txs[0].FeeRate, 1e-9)
		assert.EqualValues(t, 1234, txs[0].FirstSeenAt.Unix())
		assert.EqualValues(t, 100, txs[0].FirstSeenHeight)
	})

	t.Run("uses the tx own fee rate without an ancestor size", func(t *testing.T) {
		w, db := newTestWatcher(t, newFakeNode())
		tx := pbTx("aa", 1, 1)
		tx.AncestorVsize = 0

		require.NoError(t, w.handle(ctx, added(tx)))

		txs, _, err := mempooltx.List(ctx, db, mempooltx.Filter{})
		require.NoError(t, err)
		require.Len(t, txs, 1)
		assert.InDelta(t, 5.0, txs[0].FeeRate, 1e-9)
	})
}

func TestMempoolWatchHandleRemoved(t *testing.T) {
	ctx := t.Context()
	w, db := newTestWatcher(t, newFakeNode())
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "aa"}, {Txid: "bb"}}))

	require.NoError(t, w.handle(ctx, removed("aa")))

	assert.Equal(t, []string{"bb"}, storedTxids(t, db))
}

func TestMempoolWatchHandleBlockConnected(t *testing.T) {
	ctx := t.Context()

	t.Run("forgets the block txs, records stats, prunes and sets the tip", func(t *testing.T) {
		node := newFakeNode()
		node.set("getblockstats b9", `{"minfeerate":3.5,"totalfee":7000}`)
		w, db := newTestWatcher(t, node)
		w.setTip(100)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{
			{Txid: "aa", FirstSeenHeight: 99},
			{Txid: "bb", FirstSeenHeight: 99},
			{Txid: "cc", FirstSeenHeight: 93},
		}))
		for h := uint32(90); h <= 100; h++ {
			require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
		}

		require.NoError(t, w.handle(ctx, block("b9", 101, true, "coinbase", "aa", "bb")))

		assert.EqualValues(t, 101, w.Status().Tip)
		assert.Equal(t, []string{"cc"}, storedTxids(t, db))
		assert.Equal(t, []uint32{93, 94, 95, 96, 97, 98, 99, 100, 101}, storedHeights(t, db))
		stats, err := mempooltx.ListBlockStats(ctx, db, 101, 101)
		require.NoError(t, err)
		require.Len(t, stats, 1)
		assert.InDelta(t, 3.5, stats[0].MinFeeRate, 1e-9)
		assert.EqualValues(t, 7000, stats[0].TotalFeeSats)
		assert.Zero(t, node.count("getblock b9"), "the feed names the block txs")
	})

	t.Run("prunes to the reference blocks with no pending tx", func(t *testing.T) {
		w, db := newTestWatcher(t, statsNode())
		w.setTip(100)
		for h := uint32(90); h <= 100; h++ {
			require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
		}

		require.NoError(t, w.handle(ctx, block("b9", 101, true)))

		assert.Equal(t, []uint32{96, 97, 98, 99, 100, 101}, storedHeights(t, db))
	})

	for _, height := range []uint32{99, 100} {
		t.Run(fmt.Sprintf("ignores a block at height %d at or below the snapshot tip", height), func(t *testing.T) {
			node := newFakeNode()
			w, db := newTestWatcher(t, node)
			w.setTip(100)
			require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "aa"}}))

			require.NoError(t, w.handle(ctx, block("b9", height, true, "aa")))

			assert.EqualValues(t, 100, w.Status().Tip)
			assert.Equal(t, []string{"aa"}, storedTxids(t, db))
			assert.Zero(t, node.count("getblockstats b9"))
		})
	}
}

func TestMempoolWatchHandleBlockDisconnected(t *testing.T) {
	ctx := t.Context()
	w, db := newTestWatcher(t, newFakeNode())
	w.setTip(101)
	for h := uint32(98); h <= 101; h++ {
		require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
	}

	require.NoError(t, w.handle(ctx, block("b9", 101, false)))

	assert.EqualValues(t, 100, w.Status().Tip)
	assert.Equal(t, []uint32{98, 99, 100}, storedHeights(t, db))
}

func TestMempoolWatchHandleUnknownChange(t *testing.T) {
	w, _ := newTestWatcher(t, newFakeNode())
	require.ErrorContains(t, w.handle(t.Context(), &mempoolpb.Change{}), "unknown mempool change")
}

type watchRun struct {
	feed *fakeFeed
	done chan struct{}
	err  error
}

func startWatch(t *testing.T, w *MempoolWatcher) *watchRun {
	t.Helper()
	run := &watchRun{feed: newFakeFeed(), done: make(chan struct{})}
	w.feed = run.feed.open
	ctx, cancel := context.WithCancel(t.Context())
	go func() {
		run.err = w.watch(ctx)
		close(run.done)
	}()
	t.Cleanup(func() {
		cancel()
		run.feed.Close() //nolint:errcheck // test cleanup
		<-run.done
		t.Logf("watch stopped: %v", run.err)
	})
	return run
}

// send returns once watch took msg, and so finished every message before it.
func (r *watchRun) send(t *testing.T, msg *mempoolpb.WatchTransactionsResponse) {
	t.Helper()
	select {
	case r.feed.msgs <- msg:
	case <-r.done:
		t.Fatalf("watch stopped: %v", r.err)
	}
}

func TestMempoolWatchFollowsTheFeed(t *testing.T) {
	w, db := newTestWatcher(t, statsNode())
	require.NoError(t, mempooltx.Upsert(t.Context(), db, []mempooltx.Tx{{Txid: "stale"}}))
	run := startWatch(t, w)

	run.send(t, &mempoolpb.WatchTransactionsResponse{Changes: []*mempoolpb.Change{added(pbTx("early", 1, 1))}})
	run.send(t, &mempoolpb.WatchTransactionsResponse{Snapshot: &mempoolpb.Snapshot{
		Height: 100, Transactions: []*mempoolpb.Transaction{pbTx("aa", 99, 1)}, More: true,
	}})
	assert.False(t, w.Status().Running, "a part of a snapshot is no snapshot")
	run.send(t, &mempoolpb.WatchTransactionsResponse{Snapshot: &mempoolpb.Snapshot{
		Height: 100, Transactions: []*mempoolpb.Transaction{pbTx("bb", 99, 1)},
	}})
	run.send(t, &mempoolpb.WatchTransactionsResponse{Heartbeat: true})
	assert.True(t, w.Status().Running)
	assert.ElementsMatch(t, []string{"aa", "bb"}, storedTxids(t, db), "a change before the snapshot is dropped")

	run.send(t, &mempoolpb.WatchTransactionsResponse{Changes: []*mempoolpb.Change{
		added(pbTx("cc", 100, 2)), removed("aa"), block("b1", 101, true, "bb"),
	}})
	run.send(t, &mempoolpb.WatchTransactionsResponse{Heartbeat: true})
	assert.Equal(t, []string{"cc"}, storedTxids(t, db))
	assert.EqualValues(t, 101, w.Status().Tip)
}

func TestMempoolWatchStopsWhenTheFeedCloses(t *testing.T) {
	w, _ := newTestWatcher(t, statsNode())
	run := startWatch(t, w)
	run.send(t, &mempoolpb.WatchTransactionsResponse{Snapshot: &mempoolpb.Snapshot{Height: 100}})
	require.Eventually(t, func() bool { return w.Status().Running }, testTimeout, testTick)

	close(run.feed.msgs)

	select {
	case <-run.done:
	case <-time.After(testTimeout):
		t.Fatal("watch did not stop")
	}
	require.ErrorContains(t, run.err, "feed closed")
	assert.False(t, w.Status().Running)
}

func TestMempoolWatchRequiresFullNode(t *testing.T) {
	node := statsNode()
	w, _ := newTestWatcher(t, node)
	w.nodeMode = nodeModeWith(t, orchpb.NodeMode_NODE_MODE_LIGHT)
	opened := false
	w.feed = func(context.Context) (MempoolStream, error) {
		opened = true
		return newFakeFeed(), nil
	}

	err := w.watch(t.Context())

	require.ErrorIs(t, err, errRequiresFullNode)
	assert.False(t, opened)
	assert.Empty(t, node.calls)
}

func TestMempoolWatchSetEnabled(t *testing.T) {
	ctx := t.Context()

	t.Run("persists the preference", func(t *testing.T) {
		w, db := newTestWatcher(t, newFakeNode())
		for _, tt := range []struct {
			enabled bool
			want    string
		}{{true, "1"}, {false, "0"}} {
			require.NoError(t, w.SetEnabled(ctx, tt.enabled))
			got, err := preferences.Get(ctx, db, preferences.KeyMempoolWatchEnabled)
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
			assert.Equal(t, tt.enabled, w.Status().Enabled)
		}
	})

	t.Run("starts and stops the watch under Run", func(t *testing.T) {
		w, _ := newTestWatcher(t, statsNode())
		w.feed = func(ctx context.Context) (MempoolStream, error) {
			feed := newFakeFeed()
			go func() {
				select {
				case feed.msgs <- &mempoolpb.WatchTransactionsResponse{Snapshot: &mempoolpb.Snapshot{Height: 100}}:
				case <-feed.closed:
				}
			}()
			return feed.open(ctx)
		}
		runCtx, cancel := context.WithCancel(ctx)
		runDone := make(chan error, 1)
		go func() { runDone <- w.Run(runCtx) }()
		t.Cleanup(func() {
			cancel()
			if err := <-runDone; err != nil {
				assert.ErrorIs(t, err, context.Canceled)
			}
		})
		require.Eventually(t, func() bool {
			w.mu.Lock()
			defer w.mu.Unlock()
			return w.ctx != nil
		}, testTimeout, testTick)
		assert.False(t, w.Status().Running)

		require.NoError(t, w.SetEnabled(ctx, true))
		require.Eventually(t, func() bool { return w.Status().Running }, testTimeout, testTick)

		require.NoError(t, w.SetEnabled(ctx, false))
		assert.False(t, w.Status().Running)
	})
}

func TestMempoolWatchReset(t *testing.T) {
	ctx := t.Context()
	w, db := newTestWatcher(t, newFakeNode())
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "aa"}}))
	require.NoError(t, mempooltx.PutBlockStats(ctx, db, 100, 1, 1))

	require.NoError(t, w.Reset(ctx))

	assert.Empty(t, storedTxids(t, db))
	assert.Empty(t, storedHeights(t, db))
}

func TestMempoolResetObeysDisable(t *testing.T) {
	w, _ := newTestWatcher(t, newFakeNode())
	entered := make(chan struct{})
	canceled := make(chan struct{})
	release := make(chan struct{})
	w.call = func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		if method == "getblockstats" {
			close(entered)
			<-ctx.Done()
			close(canceled)
			<-release
			return nil, ctx.Err()
		}
		return nil, fmt.Errorf("no %s", method)
	}
	feeds := make(chan *fakeFeed, 2)
	w.feed = func(ctx context.Context) (MempoolStream, error) {
		feed := newFakeFeed()
		feeds <- feed
		return feed.open(ctx)
	}
	require.NoError(t, w.SetEnabled(t.Context(), true))
	ctx, cancel := context.WithCancel(t.Context())
	done := make(chan error, 1)
	go func() { done <- w.Run(ctx) }()
	t.Cleanup(func() {
		cancel()
		assert.NoError(t, <-done)
	})
	feed := <-feeds
	feed.msgs <- &mempoolpb.WatchTransactionsResponse{Snapshot: &mempoolpb.Snapshot{Height: 100}}
	require.Eventually(t, func() bool { return w.Status().Running }, time.Second, time.Millisecond)
	feed.msgs <- &mempoolpb.WatchTransactionsResponse{Changes: []*mempoolpb.Change{block("b1", 101, true)}}
	<-entered
	reset := make(chan error, 1)
	go func() { reset <- w.Reset(t.Context()) }()
	<-canceled
	require.NoError(t, w.SetEnabled(t.Context(), false))
	close(release)
	require.NoError(t, <-reset)
	status := w.Status()
	require.False(t, status.Enabled)
	assert.False(t, status.Running, "a disabled watcher must remain stopped after reset")
}
