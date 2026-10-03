package engines

import (
	"context"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
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

func (n *fakeNode) fail(key string, err error) {
	n.mu.Lock()
	defer n.mu.Unlock()
	n.errs[key] = err
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

func hashOf(b byte) [32]byte {
	var h [32]byte
	for i := range h {
		h[i] = b
	}
	return h
}

func hexOf(b byte) string {
	h := hashOf(b)
	return hex.EncodeToString(h[:])
}

func entryJSON(height uint32, firstSeen int64) string {
	return fmt.Sprintf(`{"vsize":200,"ancestorsize":400,"time":%d,"height":%d,"fees":{"base":0.00001,"ancestor":0.00004}}`, firstSeen, height)
}

func snapshotJSON(t *testing.T, seq uint64, txids ...string) string {
	if txids == nil {
		txids = []string{}
	}
	raw, err := json.Marshal(map[string]any{"txids": txids, "mempool_sequence": seq})
	require.NoError(t, err)
	return string(raw)
}

func blockJSON(t *testing.T, height uint32, txids ...string) string {
	if txids == nil {
		txids = []string{}
	}
	raw, err := json.Marshal(map[string]any{"height": height, "tx": txids})
	require.NoError(t, err)
	return string(raw)
}

func nodeAtTip(t *testing.T, seq uint64) *fakeNode {
	node := newFakeNode()
	node.set("getblockcount", "100")
	node.set("getrawmempool false", snapshotJSON(t, seq))
	node.set("getrawmempool true", `{}`)
	node.set("getblockstats", `{"minfeerate":2,"totalfee":5000}`)
	return node
}

func newTestWatcher(t *testing.T, node *fakeNode) (*MempoolWatcher, *sql.DB) {
	t.Helper()
	db := database.Test(t)
	w := NewMempoolWatcher(db, node.call, func(context.Context) (<-chan SequenceMsg, func(), error) {
		return nil, nil, errors.New("no subscription in this test")
	})
	w.rebootstrapMinGap = 0
	w.statsLookback = 0
	return w, db
}

func storedTxids(t *testing.T, db *sql.DB) []string {
	t.Helper()
	txs, _, err := mempooltx.List(context.Background(), db, mempooltx.Filter{})
	require.NoError(t, err)
	out := []string{}
	for _, tx := range txs {
		out = append(out, tx.Txid)
	}
	return out
}

func storedHeights(t *testing.T, db *sql.DB) []uint32 {
	t.Helper()
	stats, err := mempooltx.ListBlockStats(context.Background(), db, 0, 1_000_000)
	require.NoError(t, err)
	out := []uint32{}
	for _, s := range stats {
		out = append(out, s.Height)
	}
	return out
}

func TestMempoolWatchBootstrap(t *testing.T) {
	ctx := context.Background()

	t.Run("stores the snapshot and drops rows not in the mempool", func(t *testing.T) {
		node := nodeAtTip(t, 50)
		node.set("getrawmempool false", snapshotJSON(t, 50, "aa", "bb", "cc"))
		node.set("getrawmempool true", fmt.Sprintf(`{"aa":%s,"bb":%s}`, entryJSON(98, 1000), entryJSON(99, 2000)))
		w, db := newTestWatcher(t, node)
		require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "stale", FirstSeenHeight: 90}}))

		lastSeq, err := w.bootstrap(ctx)
		require.NoError(t, err)

		assert.EqualValues(t, 49, lastSeq)
		assert.EqualValues(t, 100, w.Status().Tip)
		assert.Equal(t, []string{"aa", "bb"}, storedTxids(t, db))
	})

	t.Run("reads block stats back to the oldest entry", func(t *testing.T) {
		node := nodeAtTip(t, 1)
		node.set("getrawmempool false", snapshotJSON(t, 1, "aa"))
		node.set("getrawmempool true", fmt.Sprintf(`{"aa":%s}`, entryJSON(92, 1000)))
		node.set("getblockhash", `"00"`)
		w, db := newTestWatcher(t, node)
		w.statsLookback = 144

		_, err := w.bootstrap(ctx)
		require.NoError(t, err)

		assert.Equal(t, []uint32{92, 93, 94, 95, 96, 97, 98, 99, 100}, storedHeights(t, db))
	})

	t.Run("reads at least the reference blocks for an empty mempool", func(t *testing.T) {
		node := nodeAtTip(t, 1)
		node.set("getblockhash", `"00"`)
		w, db := newTestWatcher(t, node)
		w.statsLookback = 144

		_, err := w.bootstrap(ctx)
		require.NoError(t, err)

		assert.Equal(t, []uint32{95, 96, 97, 98, 99, 100}, storedHeights(t, db))
	})

	t.Run("a zero sequence returns zero", func(t *testing.T) {
		w, _ := newTestWatcher(t, nodeAtTip(t, 0))

		lastSeq, err := w.bootstrap(ctx)
		require.NoError(t, err)
		assert.Zero(t, lastSeq)
	})
}

func TestMempoolWatchHandleTransactionAdded(t *testing.T) {
	ctx := context.Background()

	t.Run("stores the tx with the ancestor package fee rate", func(t *testing.T) {
		node := newFakeNode()
		node.set("getmempoolentry "+hexOf(1), entryJSON(100, 1234))
		w, db := newTestWatcher(t, node)

		mined, err := w.handle(ctx, SequenceMsg{Hash: hashOf(1), Event: TransactionAdded, MempoolSeq: 1})
		require.NoError(t, err)
		assert.Zero(t, mined)

		txs, _, err := mempooltx.List(ctx, db, mempooltx.Filter{})
		require.NoError(t, err)
		require.Len(t, txs, 1)
		assert.Equal(t, hexOf(1), txs[0].Txid)
		assert.EqualValues(t, 1000, txs[0].FeeSats)
		assert.EqualValues(t, 200, txs[0].Vsize)
		assert.InDelta(t, 10.0, txs[0].FeeRate, 1e-9)
		assert.EqualValues(t, 1234, txs[0].FirstSeenAt.Unix())
		assert.EqualValues(t, 100, txs[0].FirstSeenHeight)
	})

	t.Run("uses the tx own fee rate without an ancestor size", func(t *testing.T) {
		node := newFakeNode()
		node.set("getmempoolentry "+hexOf(1), `{"vsize":200,"time":1,"height":1,"fees":{"base":0.00001,"ancestor":0.00004}}`)
		w, db := newTestWatcher(t, node)

		_, err := w.handle(ctx, SequenceMsg{Hash: hashOf(1), Event: TransactionAdded})
		require.NoError(t, err)

		txs, _, err := mempooltx.List(ctx, db, mempooltx.Filter{})
		require.NoError(t, err)
		require.Len(t, txs, 1)
		assert.InDelta(t, 5.0, txs[0].FeeRate, 1e-9)
	})

	t.Run("skips a tx already gone from the mempool", func(t *testing.T) {
		node := newFakeNode()
		node.fail("getmempoolentry "+hexOf(1), connect.NewError(connect.CodeNotFound, errors.New("Transaction not in mempool")))
		w, db := newTestWatcher(t, node)

		_, err := w.handle(ctx, SequenceMsg{Hash: hashOf(1), Event: TransactionAdded})
		require.NoError(t, err)
		assert.Empty(t, storedTxids(t, db))
	})

	t.Run("returns any other error", func(t *testing.T) {
		node := newFakeNode()
		node.fail("getmempoolentry "+hexOf(1), errors.New("connection refused"))
		w, _ := newTestWatcher(t, node)

		_, err := w.handle(ctx, SequenceMsg{Hash: hashOf(1), Event: TransactionAdded})
		require.ErrorContains(t, err, "connection refused")
	})
}

func TestMempoolWatchHandleTransactionRemoved(t *testing.T) {
	ctx := context.Background()
	w, db := newTestWatcher(t, newFakeNode())
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: hexOf(1)}, {Txid: hexOf(2)}}))

	_, err := w.handle(ctx, SequenceMsg{Hash: hashOf(1), Event: TransactionRemoved})
	require.NoError(t, err)

	assert.Equal(t, []string{hexOf(2)}, storedTxids(t, db))
}

func TestMempoolWatchHandleBlockConnected(t *testing.T) {
	ctx := context.Background()

	t.Run("forgets the block txs, records stats, prunes and sets the tip", func(t *testing.T) {
		node := newFakeNode()
		node.set("getblock "+hexOf(9), blockJSON(t, 101, "coinbase", "aa", "bb"))
		node.set("getblockstats "+hexOf(9), `{"minfeerate":3.5,"totalfee":7000}`)
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

		mined, err := w.handle(ctx, SequenceMsg{Hash: hashOf(9), Event: BlockConnected})
		require.NoError(t, err)

		assert.EqualValues(t, 3, mined)
		assert.EqualValues(t, 101, w.Status().Tip)
		assert.Equal(t, []string{"cc"}, storedTxids(t, db))
		assert.Equal(t, []uint32{93, 94, 95, 96, 97, 98, 99, 100, 101}, storedHeights(t, db))

		stats, err := mempooltx.ListBlockStats(ctx, db, 101, 101)
		require.NoError(t, err)
		require.Len(t, stats, 1)
		assert.InDelta(t, 3.5, stats[0].MinFeeRate, 1e-9)
		assert.EqualValues(t, 7000, stats[0].TotalFeeSats)
	})

	t.Run("prunes to the reference blocks with no pending tx", func(t *testing.T) {
		node := newFakeNode()
		node.set("getblock "+hexOf(9), blockJSON(t, 101))
		node.set("getblockstats", `{"minfeerate":1,"totalfee":1}`)
		w, db := newTestWatcher(t, node)
		w.setTip(100)
		for h := uint32(90); h <= 100; h++ {
			require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
		}

		_, err := w.handle(ctx, SequenceMsg{Hash: hashOf(9), Event: BlockConnected})
		require.NoError(t, err)

		assert.Equal(t, []uint32{96, 97, 98, 99, 100, 101}, storedHeights(t, db))
	})

	for _, height := range []uint32{99, 100} {
		t.Run(fmt.Sprintf("ignores a block at height %d at or below the snapshot tip", height), func(t *testing.T) {
			node := newFakeNode()
			node.set("getblock "+hexOf(9), blockJSON(t, height, "aa"))
			w, db := newTestWatcher(t, node)
			w.setTip(100)
			require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "aa"}}))

			mined, err := w.handle(ctx, SequenceMsg{Hash: hashOf(9), Event: BlockConnected})
			require.NoError(t, err)

			assert.Zero(t, mined)
			assert.EqualValues(t, 100, w.Status().Tip)
			assert.Equal(t, []string{"aa"}, storedTxids(t, db))
			assert.Zero(t, node.count("getblockstats "+hexOf(9)))
		})
	}
}

func TestMempoolWatchHandleBlockDisconnected(t *testing.T) {
	ctx := context.Background()
	node := newFakeNode()
	node.set("getblock "+hexOf(9), blockJSON(t, 101))
	w, db := newTestWatcher(t, node)
	w.setTip(101)
	for h := uint32(98); h <= 101; h++ {
		require.NoError(t, mempooltx.PutBlockStats(ctx, db, h, 1, 1))
	}

	_, err := w.handle(ctx, SequenceMsg{Hash: hashOf(9), Event: BlockDisconnected})
	require.NoError(t, err)

	assert.EqualValues(t, 100, w.Status().Tip)
	assert.Equal(t, []uint32{98, 99, 100}, storedHeights(t, db))
}

func TestMempoolWatchHandleInvalidEvent(t *testing.T) {
	w, _ := newTestWatcher(t, newFakeNode())
	_, err := w.handle(context.Background(), SequenceMsg{Event: Invalid})
	require.Error(t, err)
}

type watchRun struct {
	events chan SequenceMsg
	cancel context.CancelFunc
	done   chan error
}

func startWatch(t *testing.T, w *MempoolWatcher) *watchRun {
	t.Helper()
	run := &watchRun{events: make(chan SequenceMsg), done: make(chan error, 1)}
	w.subscribe = func(context.Context) (<-chan SequenceMsg, func(), error) {
		return run.events, func() {}, nil
	}
	ctx, cancel := context.WithCancel(context.Background())
	run.cancel = cancel
	go func() { run.done <- w.watch(ctx) }()
	t.Cleanup(func() {
		cancel()
		<-run.done
	})
	return run
}

// send returns once watch took ev, and so finished every event before it.
func (r *watchRun) send(t *testing.T, ev SequenceMsg) {
	t.Helper()
	select {
	case r.events <- ev:
	case err := <-r.done:
		t.Fatalf("watch stopped: %v", err)
	}
}

func TestMempoolWatchSequenceGap(t *testing.T) {
	tests := []struct {
		name       string
		events     []SequenceMsg
		wantResync bool
	}{
		{
			name: "a gap no block explains causes a resync",
			events: []SequenceMsg{
				{Hash: hashOf(1), Event: TransactionRemoved, MempoolSeq: 14},
				{Hash: hashOf(0xb1), Event: BlockConnected},
			},
			wantResync: true,
		},
		{
			name: "a gap before a block that removed as many txs does not resync",
			events: []SequenceMsg{
				{Hash: hashOf(1), Event: TransactionRemoved, MempoolSeq: 13},
				{Hash: hashOf(0xb1), Event: BlockConnected},
			},
			wantResync: false,
		},
		{
			name: "a gap after a block that removed as many txs does not resync",
			events: []SequenceMsg{
				{Hash: hashOf(1), Event: TransactionRemoved, MempoolSeq: 11},
				{Hash: hashOf(0xb1), Event: BlockConnected},
				{Hash: hashOf(2), Event: TransactionRemoved, MempoolSeq: 14},
				{Hash: hashOf(0xb2), Event: BlockConnected},
			},
			wantResync: false,
		},
		{
			name: "a gap after a block larger than the block causes a resync",
			events: []SequenceMsg{
				{Hash: hashOf(1), Event: TransactionRemoved, MempoolSeq: 11},
				{Hash: hashOf(0xb1), Event: BlockConnected},
				{Hash: hashOf(2), Event: TransactionRemoved, MempoolSeq: 18},
				{Hash: hashOf(0xb2), Event: BlockConnected},
			},
			wantResync: true,
		},
		{
			name: "events the snapshot covers are skipped",
			events: []SequenceMsg{
				{Hash: hashOf(1), Event: TransactionRemoved, MempoolSeq: 5},
				{Hash: hashOf(2), Event: TransactionRemoved, MempoolSeq: 11},
				{Hash: hashOf(0xb1), Event: BlockConnected},
			},
			wantResync: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			node := nodeAtTip(t, 11)
			node.set("getblock "+hexOf(0xb1), blockJSON(t, 101, "x1", "x2"))
			node.set("getblock "+hexOf(0xb2), blockJSON(t, 102, "y1", "y2"))
			w, db := newTestWatcher(t, node)
			require.NoError(t, mempooltx.Upsert(context.Background(), db, []mempooltx.Tx{{Txid: hexOf(0xee)}}))
			run := startWatch(t, w)

			for _, ev := range tt.events {
				run.send(t, ev)
			}
			run.send(t, SequenceMsg{Hash: hashOf(0xee), Event: TransactionRemoved, MempoolSeq: 1})

			want := 1
			if tt.wantResync {
				want = 2
			}
			assert.Equal(t, want, node.count("getrawmempool false"))
		})
	}
}

func TestMempoolWatchStopsWhenTheSubscriptionCloses(t *testing.T) {
	w, _ := newTestWatcher(t, nodeAtTip(t, 1))
	run := startWatch(t, w)
	require.Eventually(t, func() bool { return w.Status().Running }, testTimeout, testTick)

	close(run.events)

	var err error
	require.Eventually(t, func() bool {
		select {
		case err = <-run.done:
			run.done <- err
			return true
		default:
			return false
		}
	}, testTimeout, testTick)
	require.ErrorContains(t, err, "sequence subscription closed")
	assert.False(t, w.Status().Running)
}

func TestMempoolWatchRequiresFullNode(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	client.EXPECT().
		GetNodeMode(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[orchpb.GetNodeModeResponse]{
			Msg: &orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_LIGHT},
		}, nil)
	nodeMode := NewNodeMode()
	nodeMode.SetClient(client)

	node := nodeAtTip(t, 1)
	w, _ := newTestWatcher(t, node)
	w.SetNodeMode(nodeMode)
	subscribed := false
	w.subscribe = func(context.Context) (<-chan SequenceMsg, func(), error) {
		subscribed = true
		return nil, func() {}, nil
	}

	err := w.watch(context.Background())

	require.ErrorIs(t, err, errRequiresFullNode)
	assert.False(t, subscribed)
	assert.Empty(t, node.calls)
}

func TestMempoolWatchSetEnabled(t *testing.T) {
	ctx := context.Background()

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
		w, _ := newTestWatcher(t, nodeAtTip(t, 1))
		events := make(chan SequenceMsg)
		w.subscribe = func(context.Context) (<-chan SequenceMsg, func(), error) {
			return events, func() {}, nil
		}
		runCtx, cancel := context.WithCancel(ctx)
		runDone := make(chan error, 1)
		go func() { runDone <- w.Run(runCtx) }()
		t.Cleanup(func() {
			cancel()
			<-runDone
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
	ctx := context.Background()
	w, db := newTestWatcher(t, newFakeNode())
	require.NoError(t, mempooltx.Upsert(ctx, db, []mempooltx.Tx{{Txid: "aa"}}))
	require.NoError(t, mempooltx.PutBlockStats(ctx, db, 100, 1, 1))

	require.NoError(t, w.Reset(ctx))

	assert.Empty(t, storedTxids(t, db))
	assert.Empty(t, storedHeights(t, db))
}
