package engines

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	"github.com/stretchr/testify/require"
)

func fakeTxid(b byte) string {
	var h [32]byte
	h[0] = b
	return hex.EncodeToString(h[:])
}

func seqEvent(hash string, event SequenceEvent, seq uint64) SequenceMsg {
	var msg SequenceMsg
	raw, _ := hex.DecodeString(hash)
	copy(msg.Hash[:], raw)
	msg.Event = event
	msg.MempoolSeq = seq
	return msg
}

func entryJSON(height uint32, feeBTC float64, vsize uint32) string {
	return fmt.Sprintf(`{"vsize":%d,"ancestorsize":%d,"time":1700000000,"height":%d,"fees":{"base":%g,"ancestor":%g}}`,
		vsize, vsize, height, feeBTC, feeBTC)
}

// childJSON is a tx whose own rate is high but whose unconfirmed parent
// drags the package rate down.
func childJSON(height uint32) string {
	return `{"vsize":100,"ancestorsize":400,"time":1700000000,"height":` + fmt.Sprint(height) + `,"fees":{"base":0.0001,"ancestor":0.00012}}`
}

type fakeCore struct {
	mu         sync.Mutex
	mempool    map[string]string
	blocks     map[string]string
	minFeeRate map[string]float64
	totalFee   map[string]uint64
	sequence   uint64
	bootstraps atomic.Int32
	entries    atomic.Int32
}

func (f *fakeCore) call(_ context.Context, method string, params ...any) (json.RawMessage, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	switch method {
	case "getblockcount":
		return json.RawMessage(`100`), nil
	case "getrawmempool":
		f.bootstraps.Add(1)
		txids := make([]string, 0, len(f.mempool))
		for txid := range f.mempool {
			txids = append(txids, txid)
		}
		out, _ := json.Marshal(map[string]any{"txids": txids, "mempool_sequence": f.sequence})
		return out, nil
	case "getblockstats":
		hash := params[0].(string)
		out, _ := json.Marshal(map[string]any{"minfeerate": f.minFeeRate[hash], "totalfee": f.totalFee[hash]})
		return out, nil
	case "getmempoolentry":
		f.entries.Add(1)
		e, ok := f.mempool[params[0].(string)]
		if !ok {
			return nil, errors.New("getmempoolentry: Transaction not in mempool")
		}
		return json.RawMessage(e), nil
	case "getblock":
		return json.RawMessage(f.blocks[params[0].(string)]), nil
	}
	return nil, fmt.Errorf("unexpected method %s", method)
}

func listAll(t *testing.T, w *MempoolWatcher) map[string]mempooltx.Tx {
	txs, _, err := mempooltx.List(context.Background(), w.db, mempooltx.Filter{})
	require.NoError(t, err)
	out := map[string]mempooltx.Tx{}
	for _, tx := range txs {
		out[tx.Txid] = tx
	}
	return out
}

func TestMempoolWatcher(t *testing.T) {
	a, b, c, stale := fakeTxid(1), fakeTxid(2), fakeTxid(3), fakeTxid(9)
	block, oldBlock := fakeTxid(0xb1), fakeTxid(0xb0)

	core := &fakeCore{
		mempool: map[string]string{
			a: entryJSON(95, 0.00001, 100),
			b: entryJSON(99, 0.00002, 200),
		},
		blocks: map[string]string{
			block:    fmt.Sprintf(`{"height":101,"tx":[%q,%q]}`, a, c),
			oldBlock: fmt.Sprintf(`{"height":100,"tx":[%q]}`, a),
		},
		minFeeRate: map[string]float64{block: 5},
		totalFee:   map[string]uint64{block: 5_000_000},
		sequence:   3,
	}

	db := database.Test(t)
	require.NoError(t, mempooltx.UpsertPending(context.Background(), db, []mempooltx.Tx{{Txid: stale, FirstSeenAt: time.Now()}}))
	require.NoError(t, preferences.Set(context.Background(), db, preferences.KeyMempoolWatchEnabled, "1"))

	events := make(chan SequenceMsg, 100)
	w := NewMempoolWatcher(db, core.call, func(context.Context) (<-chan SequenceMsg, func(), error) {
		return events, func() {}, nil
	})
	w.retryDelay = 10 * time.Millisecond
	w.rebootstrapMinGap = 0
	w.detailsAfterBlocks = 0

	// Queued before the snapshot: a block at the snapshot height and a
	// removal the snapshot already reflects (Core reports 3 as the next
	// sequence, so 2 is covered). Both must be ignored.
	events <- seqEvent(oldBlock, BlockConnected, 0)
	events <- seqEvent(a, TransactionRemoved, 2)

	runCtx, cancel := context.WithCancel(context.Background())
	defer cancel()
	done := make(chan error, 1)
	go func() { done <- w.Run(runCtx) }()
	require.Eventually(t, func() bool { return w.Status().Running }, 5*time.Second, 10*time.Millisecond)

	// Bootstrap: txids snapshotted, stale pending row dropped, and the two
	// details fetched lazily with Core's own first-seen values.
	require.Eventually(t, func() bool { return core.entries.Load() == 2 }, 5*time.Second, 10*time.Millisecond)
	txs := listAll(t, w)
	require.Len(t, txs, 2)
	require.EqualValues(t, 100, w.Status().Tip)
	require.Equal(t, mempooltx.StatusPending, txs[a].Status)
	require.True(t, txs[a].HasDetails)
	require.EqualValues(t, 1000, txs[a].FeeSats)
	require.EqualValues(t, 10, txs[a].FeeRate)
	require.EqualValues(t, 95, txs[a].FirstSeenHeight)

	// A new tx arrives without an RPC, one is removed, then a block mines a and c.
	core.mu.Lock()
	core.mempool[c] = childJSON(100)
	core.mu.Unlock()
	events <- seqEvent(c, TransactionAdded, 3)
	events <- seqEvent(b, TransactionRemoved, 4)
	require.Eventually(t, func() bool { return listAll(t, w)[b].Status == mempooltx.StatusRemoved }, 5*time.Second, 10*time.Millisecond)
	require.EqualValues(t, 2, core.entries.Load())
	txs = listAll(t, w)
	require.False(t, txs[c].HasDetails)
	require.EqualValues(t, 100, *txs[b].ResolvedHeight)

	events <- seqEvent(block, BlockConnected, 0)
	require.Eventually(t, func() bool { return w.Status().Tip == 101 }, 5*time.Second, 10*time.Millisecond)
	txs = listAll(t, w)
	require.Equal(t, mempooltx.StatusMined, txs[a].Status)
	require.EqualValues(t, 101, *txs[a].ResolvedHeight)
	require.Equal(t, mempooltx.StatusMined, txs[c].Status)

	// The block took two txs out of the mempool without R events, so the
	// sequence may skip that many without a resync.
	before := core.bootstraps.Load()
	events <- seqEvent(b, TransactionAdded, 6)
	require.Eventually(t, func() bool { return listAll(t, w)[b].Status == mempooltx.StatusPending }, 5*time.Second, 10*time.Millisecond)
	require.Equal(t, before, core.bootstraps.Load())

	// Reorg returns the block's txs to pending and forgets its fee floor.
	events <- seqEvent(block, BlockDisconnected, 0)
	require.Eventually(t, func() bool { return w.Status().Tip == 100 }, 5*time.Second, 10*time.Millisecond)
	txs = listAll(t, w)
	require.Equal(t, mempooltx.StatusPending, txs[a].Status)
	require.Nil(t, txs[a].ResolvedHeight)
	require.Equal(t, mempooltx.StatusPending, txs[c].Status)

	// Core announces removals of txs a block conflicts with before the block
	// itself, so a gap ahead of a block that accounts for it is no resync.
	before = core.bootstraps.Load()
	events <- seqEvent(b, TransactionRemoved, 8)
	events <- seqEvent(block, BlockConnected, 0)
	require.Eventually(t, func() bool { return w.Status().Tip == 101 }, 5*time.Second, 10*time.Millisecond)
	require.Equal(t, before, core.bootstraps.Load())
	events <- seqEvent(block, BlockDisconnected, 0)
	require.Eventually(t, func() bool { return w.Status().Tip == 100 }, 5*time.Second, 10*time.Millisecond)

	// A gap larger than the next block can explain resyncs once it lands.
	core.sequence = 20
	events <- seqEvent(c, TransactionAdded, 14)
	require.Eventually(t, func() bool { return listAll(t, w)[c].Status == mempooltx.StatusPending }, 5*time.Second, 10*time.Millisecond)
	require.Equal(t, before, core.bootstraps.Load(), "judged at the next block, not on the spot")
	events <- seqEvent(block, BlockConnected, 0)
	require.Eventually(t, func() bool { return core.bootstraps.Load() == before+1 }, 5*time.Second, 10*time.Millisecond)
	// The resync's snapshot now covers everything up to sequence 19.
	events <- seqEvent(b, TransactionAdded, 19)
	events <- seqEvent(b, TransactionRemoved, 20)
	require.Eventually(t, func() bool { return listAll(t, w)[b].Status == mempooltx.StatusRemoved }, 5*time.Second, 10*time.Millisecond)
	require.Equal(t, before+1, core.bootstraps.Load())

	// Disabling stops the loop; the flag is persisted.
	require.NoError(t, w.SetEnabled(context.Background(), false))
	require.False(t, w.Status().Running)
	flag, err := preferences.Get(context.Background(), db, preferences.KeyMempoolWatchEnabled)
	require.NoError(t, err)
	require.Equal(t, "0", flag)

	cancel()
	require.NoError(t, <-done)
}

func TestMempoolWatcherRetriesAfterError(t *testing.T) {
	db := database.Test(t)
	require.NoError(t, preferences.Set(context.Background(), db, preferences.KeyMempoolWatchEnabled, "1"))

	var attempts atomic.Int32
	w := NewMempoolWatcher(db, nil, func(context.Context) (<-chan SequenceMsg, func(), error) {
		attempts.Add(1)
		return nil, nil, errors.New("no zmq")
	})
	w.retryDelay = 5 * time.Millisecond

	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan error, 1)
	go func() { done <- w.Run(ctx) }()

	require.Eventually(t, func() bool { return attempts.Load() >= 3 }, 5*time.Second, 5*time.Millisecond)
	require.Contains(t, w.Status().Error, "no zmq")
	cancel()
	require.NoError(t, <-done)
}
