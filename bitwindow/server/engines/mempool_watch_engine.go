package engines

import (
	"context"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
)

// RawCall runs a bitcoind JSON-RPC method and returns its raw result.
type RawCall func(ctx context.Context, method string, params ...any) (json.RawMessage, error)

// SequenceSubscribe opens a ZMQ sequence subscription.
type SequenceSubscribe func(ctx context.Context) (<-chan SequenceMsg, func(), error)

type MempoolWatchStatus struct {
	Enabled bool
	Running bool
	Error   string
	Tip     uint32
}

// MempoolWatcher records every mempool tx it sees and how long it waited.
type MempoolWatcher struct {
	db        *sql.DB
	call      RawCall
	subscribe SequenceSubscribe
	nodeMode  *NodeMode

	retryDelay        time.Duration
	rebootstrapMinGap time.Duration
	// detailsAfterBlocks is how long a tx must sit in the mempool before its
	// fee details are worth an RPC; detailsBatch caps the fetches per block.
	detailsAfterBlocks uint32
	detailsBatch       int

	mu      sync.Mutex
	ctx     context.Context
	cancel  context.CancelFunc
	done    chan struct{}
	enabled bool
	running bool
	err     string
	tip     uint32
}

func NewMempoolWatcher(db *sql.DB, call RawCall, subscribe SequenceSubscribe) *MempoolWatcher {
	return &MempoolWatcher{
		db:                 db,
		call:               call,
		subscribe:          subscribe,
		retryDelay:         5 * time.Second,
		rebootstrapMinGap:  time.Minute,
		detailsAfterBlocks: 2,
		detailsBatch:       100,
	}
}

func (w *MempoolWatcher) SetNodeMode(nodeMode *NodeMode) {
	w.nodeMode = nodeMode
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
	w.mu.Unlock()

	if w.enabled {
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

func (w *MempoolWatcher) Status() MempoolWatchStatus {
	w.mu.Lock()
	defer w.mu.Unlock()
	return MempoolWatchStatus{Enabled: w.enabled, Running: w.running, Error: w.err, Tip: w.tip}
}

func (w *MempoolWatcher) start(parent context.Context) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if w.cancel != nil {
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
	for {
		err := w.watch(ctx)
		if ctx.Err() != nil {
			return
		}
		log.Warn().Err(err).Msg("mempool watch stopped, retrying")
		w.setError(err)
		select {
		case <-ctx.Done():
			return
		case <-time.After(w.retryDelay):
		}
	}
}

func (w *MempoolWatcher) watch(ctx context.Context) error {
	if w.nodeMode != nil && !w.nodeMode.RunsLocalNode(ctx) {
		return errors.New("requires a full node")
	}

	events, cancel, err := w.subscribe(ctx)
	if err != nil {
		return fmt.Errorf("subscribe: %w", err)
	}
	defer cancel()

	lastSeq, err := w.bootstrap(ctx)
	if err != nil {
		return fmt.Errorf("bootstrap: %w", err)
	}
	if err := w.fetchDetails(ctx); err != nil {
		return fmt.Errorf("fetch details: %w", err)
	}
	w.setRunning(true)
	defer w.setRunning(false)

	prune := time.NewTicker(time.Hour)
	defer prune.Stop()

	log := zerolog.Ctx(ctx)
	lastBootstrap := time.Now()
	// Core advances the mempool sequence for txs a block removes but sends
	// no R event for them, so a block leaves a gap this large at most.
	var allowedGap uint64
	// Core also removes txs a block conflicts with, and announces those
	// removals, before it announces the block. A gap with nothing to explain
	// it yet is therefore judged when the next block lands.
	var unexplained uint64

	for {
		select {
		case <-ctx.Done():
			return nil
		case now := <-prune.C:
			if err := mempooltx.Prune(ctx, w.db, now); err != nil {
				log.Error().Err(err).Msg("mempool watch: prune")
			}
		case ev, ok := <-events:
			if !ok {
				return errors.New("sequence subscription closed")
			}
			if ev.Event == TransactionAdded || ev.Event == TransactionRemoved {
				// Events the snapshot already covers.
				if ev.MempoolSeq <= lastSeq {
					continue
				}
				if gap := ev.MempoolSeq - lastSeq - 1; gap > allowedGap {
					unexplained += gap - allowedGap
				}
				lastSeq, allowedGap = ev.MempoolSeq, 0
			}
			mined, err := w.handle(ctx, ev)
			if err != nil {
				return err
			}
			allowedGap += mined
			if ev.Event != BlockConnected {
				continue
			}
			if unexplained > mined && time.Since(lastBootstrap) >= w.rebootstrapMinGap {
				log.Warn().Uint64("unexplained", unexplained).Uint64("block_txs", mined).
					Msg("mempool watch: sequence gap, resyncing")
				seq, err := w.bootstrap(ctx)
				if err != nil {
					return fmt.Errorf("resync: %w", err)
				}
				lastSeq, allowedGap, lastBootstrap = seq, 0, time.Now()
			}
			unexplained = 0
		}
	}
}

type mempoolEntry struct {
	Vsize        uint32 `json:"vsize"`
	AncestorSize uint32 `json:"ancestorsize"`
	Time         int64  `json:"time"`
	Height       uint32 `json:"height"`
	Fees         struct {
		Base     float64 `json:"base"`
		Ancestor float64 `json:"ancestor"`
	} `json:"fees"`
}

func (e mempoolEntry) tx(txid string) (mempooltx.Tx, error) {
	fee, err := btcutil.NewAmount(e.Fees.Base)
	if err != nil {
		return mempooltx.Tx{}, err
	}
	// Miners weigh a tx by its ancestor package, so that is the rate that
	// decides whether skipping it was a choice.
	packageFee, err := btcutil.NewAmount(e.Fees.Ancestor)
	if err != nil {
		return mempooltx.Tx{}, err
	}
	var feeRate float64
	switch {
	case e.AncestorSize > 0:
		feeRate = float64(packageFee) / float64(e.AncestorSize)
	case e.Vsize > 0:
		feeRate = float64(fee) / float64(e.Vsize)
	}
	return mempooltx.Tx{
		Txid:            txid,
		FeeSats:         uint64(fee),
		Vsize:           e.Vsize,
		FeeRate:         feeRate,
		FirstSeenAt:     time.Unix(e.Time, 0),
		FirstSeenHeight: e.Height,
	}, nil
}

// bootstrap replaces the pending set with the txids in the node's mempool and
// returns the last mempool sequence the snapshot covers, so that older
// sequence events can be skipped. Core reports the sequence the next event
// will carry, hence the step back. Fee details are fetched later, and only
// for txs that stay pending long enough to matter.
func (w *MempoolWatcher) bootstrap(ctx context.Context) (uint64, error) {
	var tip uint32
	if err := w.callInto(ctx, &tip, "getblockcount"); err != nil {
		return 0, err
	}
	var snapshot struct {
		Txids           []string `json:"txids"`
		MempoolSequence uint64   `json:"mempool_sequence"`
	}
	if err := w.callInto(ctx, &snapshot, "getrawmempool", false, true); err != nil {
		return 0, err
	}
	if err := mempooltx.DeletePendingNotIn(ctx, w.db, snapshot.Txids); err != nil {
		return 0, err
	}
	if err := mempooltx.UpsertSeen(ctx, w.db, snapshot.Txids, tip, time.Now()); err != nil {
		return 0, err
	}
	w.setTip(tip)
	if snapshot.MempoolSequence == 0 {
		return 0, nil
	}
	return snapshot.MempoolSequence - 1, nil
}

// fetchDetails asks Core about the oldest pending txs that have waited long
// enough to be interesting and still lack fee details.
func (w *MempoolWatcher) fetchDetails(ctx context.Context) error {
	tip := w.Status().Tip
	txids, err := mempooltx.PendingWithoutDetails(ctx, w.db, tip, w.detailsAfterBlocks, w.detailsBatch)
	if err != nil {
		return err
	}
	for _, txid := range txids {
		var entry mempoolEntry
		err := w.callInto(ctx, &entry, "getmempoolentry", txid)
		switch {
		case err == nil:
		case strings.Contains(err.Error(), "not in mempool"):
			// Gone between the add event and now; a removal event follows or
			// already came.
			if err := mempooltx.Delete(ctx, w.db, txid); err != nil {
				return err
			}
			continue
		default:
			return err
		}
		tx, err := entry.tx(txid)
		if err != nil {
			return err
		}
		if err := mempooltx.SetDetails(ctx, w.db, tx); err != nil {
			return err
		}
	}
	return nil
}

// handle applies one sequence event and returns how many mempool txs a
// connected block took with it.
func (w *MempoolWatcher) handle(ctx context.Context, ev SequenceMsg) (uint64, error) {
	hash := hex.EncodeToString(ev.Hash[:])
	switch ev.Event {
	case TransactionAdded:
		return 0, mempooltx.UpsertSeen(ctx, w.db, []string{hash}, w.Status().Tip, time.Now())

	case TransactionRemoved:
		return 0, mempooltx.MarkRemoved(ctx, w.db, hash, w.Status().Tip)

	case BlockConnected:
		var block struct {
			Height uint32   `json:"height"`
			Tx     []string `json:"tx"`
		}
		if err := w.callInto(ctx, &block, "getblock", hash, 1); err != nil {
			return 0, err
		}
		if block.Height <= w.Status().Tip {
			// Connected before the snapshot was taken.
			return 0, nil
		}
		if err := mempooltx.MarkMined(ctx, w.db, block.Tx, block.Height); err != nil {
			return 0, err
		}
		var stats struct {
			MinFeeRate float64 `json:"minfeerate"`
			TotalFee   uint64  `json:"totalfee"`
		}
		if err := w.callInto(ctx, &stats, "getblockstats", hash, []string{"minfeerate", "totalfee"}); err != nil {
			return 0, err
		}
		if err := mempooltx.PutBlockStats(ctx, w.db, block.Height, stats.MinFeeRate, stats.TotalFee); err != nil {
			return 0, err
		}
		w.setTip(block.Height)
		return uint64(len(block.Tx)), w.fetchDetails(ctx)

	case BlockDisconnected:
		var block struct {
			Height uint32 `json:"height"`
		}
		if err := w.callInto(ctx, &block, "getblock", hash, 1); err != nil {
			return 0, err
		}
		if err := mempooltx.Unmine(ctx, w.db, block.Height); err != nil {
			return 0, err
		}
		if err := mempooltx.DeleteBlockStatsAbove(ctx, w.db, block.Height-1); err != nil {
			return 0, err
		}
		w.setTip(block.Height - 1)
		return 0, nil
	}
	return 0, nil
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
