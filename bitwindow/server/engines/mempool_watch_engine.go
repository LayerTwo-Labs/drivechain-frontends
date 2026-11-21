package engines

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	mempoolpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1"
)

// RawCall runs a bitcoind JSON-RPC method and returns its raw result.
type RawCall func(ctx context.Context, method string, params ...any) (json.RawMessage, error)

// MempoolStream receives the mempool feed of drivechaind.
type MempoolStream interface {
	Receive() (*mempoolpb.WatchTransactionsResponse, error)
	Close() error
}

// MempoolFeed opens the mempool feed of drivechaind.
type MempoolFeed func(ctx context.Context) (MempoolStream, error)

var errRequiresFullNode = errors.New("requires a full node")

type MempoolWatchStatus struct {
	Enabled bool
	Running bool
	Error   string
	Tip     uint32
}

// MempoolWatcher records every mempool tx it sees and how long it waited.
type MempoolWatcher struct {
	db       *sql.DB
	call     RawCall
	feed     MempoolFeed
	nodeMode *NodeMode

	retryDelay time.Duration
	// statsLookback caps how far back a start reads block stats.
	statsLookback uint32

	mu      sync.Mutex
	ctx     context.Context
	cancel  context.CancelFunc
	done    chan struct{}
	enabled bool
	running bool
	err     string
	tip     uint32
}

func NewMempoolWatcher(db *sql.DB, call RawCall, feed MempoolFeed, nodeMode *NodeMode) *MempoolWatcher {
	return &MempoolWatcher{
		db:            db,
		call:          call,
		feed:          feed,
		nodeMode:      nodeMode,
		retryDelay:    5 * time.Second,
		statsLookback: 144,
	}
}

// Run starts the watcher if it was left enabled and blocks until ctx ends.
func (w *MempoolWatcher) Run(ctx context.Context) error {
	enabled, err := preferences.Get(ctx, w.db, preferences.KeyMempoolWatchEnabled)
	if err != nil {
		return err
	}

	w.mu.Lock()
	w.ctx = ctx
	w.enabled = enabled == "1"
	start := w.enabled
	w.mu.Unlock()

	if start {
		w.start(ctx)
	}
	<-ctx.Done()
	w.stop()
	return nil
}

// SetEnabled persists the flag and starts or stops the watch loop.
func (w *MempoolWatcher) SetEnabled(ctx context.Context, enabled bool) error {
	value := "0"
	if enabled {
		value = "1"
	}
	if err := preferences.Set(ctx, w.db, preferences.KeyMempoolWatchEnabled, value); err != nil {
		return err
	}

	w.mu.Lock()
	w.enabled = enabled
	parent := w.ctx
	w.mu.Unlock()

	if parent == nil {
		return nil
	}
	if enabled {
		w.start(parent)
	} else {
		w.stop()
	}
	return nil
}

// Reset forgets everything recorded and, while enabled, starts over from the
// node's current mempool.
func (w *MempoolWatcher) Reset(ctx context.Context) error {
	w.mu.Lock()
	enabled, parent := w.enabled, w.ctx
	w.mu.Unlock()

	w.stop()
	if err := mempooltx.Clear(ctx, w.db); err != nil {
		return err
	}
	if enabled && parent != nil {
		w.start(parent)
	}
	return nil
}

func (w *MempoolWatcher) Status() MempoolWatchStatus {
	w.mu.Lock()
	defer w.mu.Unlock()
	return MempoolWatchStatus{Enabled: w.enabled, Running: w.running, Error: w.err, Tip: w.tip}
}

func (w *MempoolWatcher) start(parent context.Context) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if !w.enabled || w.cancel != nil {
		return
	}
	ctx, cancel := context.WithCancel(parent)
	w.cancel = cancel
	w.done = make(chan struct{})
	w.err = ""
	go w.loop(ctx, w.done)
}

func (w *MempoolWatcher) stop() {
	w.mu.Lock()
	cancel, done := w.cancel, w.done
	w.cancel = nil
	w.mu.Unlock()
	if cancel != nil {
		cancel()
		<-done
	}
}

func (w *MempoolWatcher) loop(ctx context.Context, done chan struct{}) {
	defer close(done)
	log := zerolog.Ctx(ctx).With().Str("engine", "mempool-watch").Logger()
	// Light mode is a state to wait out, not a failure to report every retry.
	waitingForFullNode := false
	for {
		err := w.watch(ctx)
		if ctx.Err() != nil {
			return
		}
		switch {
		case !errors.Is(err, errRequiresFullNode):
			waitingForFullNode = false
			log.Warn().Err(err).Msg("mempool watch stopped, retrying")
		case !waitingForFullNode:
			waitingForFullNode = true
			log.Info().Msg("mempool watch needs a full node, waiting")
		}
		w.setError(err)
		select {
		case <-ctx.Done():
			return
		case <-time.After(w.retryDelay):
		}
	}
}

func (w *MempoolWatcher) watch(ctx context.Context) error {
	if !w.nodeMode.RunsLocalNode(ctx) {
		return errRequiresFullNode
	}

	stream, err := w.feed(ctx)
	if err != nil {
		return fmt.Errorf("open mempool feed: %w", err)
	}
	defer stream.Close() //nolint:errcheck // the feed is done either way
	defer w.setRunning(false)

	var parts []*mempoolpb.Transaction
	synced := false
	for {
		msg, err := stream.Receive()
		if ctx.Err() != nil {
			return nil
		}
		if err != nil {
			return fmt.Errorf("receive mempool feed: %w", err)
		}
		if snap := msg.GetSnapshot(); snap != nil {
			parts = append(parts, snap.GetTransactions()...)
			if snap.GetMore() {
				continue
			}
			if err := w.bootstrap(ctx, snap.GetHeight(), parts); err != nil {
				return fmt.Errorf("bootstrap: %w", err)
			}
			parts, synced = nil, true
			w.setRunning(true)
		}
		if !synced {
			continue
		}
		for _, change := range msg.GetChanges() {
			if err := w.handle(ctx, change); err != nil {
				return err
			}
		}
	}
}

func mempoolTx(tx *mempoolpb.Transaction) mempooltx.Tx {
	// Miners weigh a tx by its ancestor package, so that is the rate that
	// decides whether skipping it was a choice.
	var feeRate float64
	switch {
	case tx.GetAncestorVsize() > 0:
		feeRate = float64(tx.GetAncestorFeeSats()) / float64(tx.GetAncestorVsize())
	case tx.GetVsize() > 0:
		feeRate = float64(tx.GetFeeSats()) / float64(tx.GetVsize())
	}
	return mempooltx.Tx{
		Txid:            tx.GetTxid(),
		FeeSats:         tx.GetFeeSats(),
		Vsize:           tx.GetVsize(),
		FeeRate:         feeRate,
		FirstSeenAt:     tx.GetTime().AsTime(),
		FirstSeenHeight: tx.GetHeight(),
	}
}

// bootstrap replaces the watched set with a snapshot of the mempool at tip.
func (w *MempoolWatcher) bootstrap(ctx context.Context, tip uint32, snapshot []*mempoolpb.Transaction) error {
	txids := make([]string, len(snapshot))
	txs := make([]mempooltx.Tx, len(snapshot))
	oldest := tip
	for i, tx := range snapshot {
		txids[i] = tx.GetTxid()
		txs[i] = mempoolTx(tx)
		oldest = min(oldest, tx.GetHeight())
	}
	if err := mempooltx.DeleteNotIn(ctx, w.db, txids); err != nil {
		return err
	}
	if err := mempooltx.Upsert(ctx, w.db, txs); err != nil {
		return err
	}
	w.setTip(tip)
	return w.readStats(ctx, oldest, tip)
}

// readStats records the fee floors the snapshot's txs sat through, back to
// the oldest entry but at most statsLookback blocks, and at least the blocks
// F* averages, so eligibility and F* are right from the first look.
func (w *MempoolWatcher) readStats(ctx context.Context, oldest, tip uint32) error {
	if w.statsLookback == 0 {
		return nil
	}
	from := max(oldest, tip-min(tip, w.statsLookback-1))
	from = min(from, tip-min(tip, referenceBlocks-1))
	for height := from; height <= tip; height++ {
		var hash string
		if err := w.callInto(ctx, &hash, "getblockhash", height); err != nil {
			return err
		}
		var stats struct {
			MinFeeRate float64 `json:"minfeerate"`
			TotalFee   uint64  `json:"totalfee"`
		}
		if err := w.callInto(ctx, &stats, "getblockstats", hash, []string{"minfeerate", "totalfee"}); err != nil {
			return err
		}
		if err := mempooltx.PutBlockStats(ctx, w.db, height, stats.MinFeeRate, stats.TotalFee); err != nil {
			return err
		}
	}
	return nil
}

// referenceBlocks is how many blocks the frontend averages F* over.
const referenceBlocks = 6

// handle applies one change of the mempool feed.
func (w *MempoolWatcher) handle(ctx context.Context, change *mempoolpb.Change) error {
	switch c := change.GetChange().(type) {
	case *mempoolpb.Change_Added:
		return mempooltx.Upsert(ctx, w.db, []mempooltx.Tx{mempoolTx(c.Added)})
	case *mempoolpb.Change_Removed:
		return mempooltx.Forget(ctx, w.db, []string{c.Removed})
	case *mempoolpb.Change_Block:
		block := c.Block
		if !block.GetConnected() {
			if err := mempooltx.DeleteBlockStatsAbove(ctx, w.db, block.GetHeight()-1); err != nil {
				return err
			}
			w.setTip(block.GetHeight() - 1)
			return nil
		}
		if block.GetHeight() <= w.Status().Tip {
			// Connected before the snapshot was taken.
			return nil
		}
		if err := mempooltx.Forget(ctx, w.db, block.GetTxids()); err != nil {
			return err
		}
		var stats struct {
			MinFeeRate float64 `json:"minfeerate"`
			TotalFee   uint64  `json:"totalfee"`
		}
		if err := w.callInto(ctx, &stats, "getblockstats", block.GetHash(), []string{"minfeerate", "totalfee"}); err != nil {
			return err
		}
		if err := mempooltx.PutBlockStats(ctx, w.db, block.GetHeight(), stats.MinFeeRate, stats.TotalFee); err != nil {
			return err
		}
		w.setTip(block.GetHeight())
		keep := block.GetHeight() - min(block.GetHeight(), referenceBlocks-1)
		return mempooltx.PruneBlockStats(ctx, w.db, keep)
	}
	return fmt.Errorf("unknown mempool change %T", change.GetChange())
}

func (w *MempoolWatcher) callInto(ctx context.Context, out any, method string, params ...any) error {
	raw, err := w.call(ctx, method, params...)
	if err != nil {
		return fmt.Errorf("%s: %w", method, err)
	}
	if err := json.Unmarshal(raw, out); err != nil {
		return fmt.Errorf("decode %s: %w", method, err)
	}
	return nil
}

func (w *MempoolWatcher) setTip(tip uint32) {
	w.mu.Lock()
	w.tip = tip
	w.mu.Unlock()
}

func (w *MempoolWatcher) setRunning(running bool) {
	w.mu.Lock()
	w.running = running
	if running {
		w.err = ""
	}
	w.mu.Unlock()
}

func (w *MempoolWatcher) setError(err error) {
	w.mu.Lock()
	w.err = err.Error()
	w.mu.Unlock()
}
