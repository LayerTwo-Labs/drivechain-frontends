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

var errRequiresFullNode = errors.New("requires a full node")

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

func NewMempoolWatcher(db *sql.DB, call RawCall, subscribe SequenceSubscribe) *MempoolWatcher {
	return &MempoolWatcher{
		db:                db,
		call:              call,
		subscribe:         subscribe,
		retryDelay:        5 * time.Second,
		rebootstrapMinGap: time.Minute,
		statsLookback:     144,
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
	if w.nodeMode != nil && !w.nodeMode.RunsLocalNode(ctx) {
		return errRequiresFullNode
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
	w.setRunning(true)
	defer w.setRunning(false)

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

// bootstrap replaces the watched set with the node's mempool and returns the
// last mempool sequence the snapshot covers, so that older sequence events
// can be skipped. Core reports the sequence the next event will carry, hence
// the step back. A tx that leaves the mempool between the two reads is
// skipped; its removal is announced or already was.
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
	var entries map[string]mempoolEntry
	if err := w.callInto(ctx, &entries, "getrawmempool", true); err != nil {
		return 0, err
	}
	var txs []mempooltx.Tx
	oldest := tip
	for _, txid := range snapshot.Txids {
		entry, ok := entries[txid]
		if !ok {
			continue
		}
		tx, err := entry.tx(txid)
		if err != nil {
			return 0, err
		}
		txs = append(txs, tx)
		oldest = min(oldest, entry.Height)
	}
	if err := mempooltx.DeleteNotIn(ctx, w.db, snapshot.Txids); err != nil {
		return 0, err
	}
	if err := mempooltx.Upsert(ctx, w.db, txs); err != nil {
		return 0, err
	}
	w.setTip(tip)
	if err := w.readStats(ctx, oldest, tip); err != nil {
		return 0, err
	}
	if snapshot.MempoolSequence == 0 {
		return 0, nil
	}
	return snapshot.MempoolSequence - 1, nil
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

// handle applies one sequence event and returns how many mempool txs a
// connected block took with it.
func (w *MempoolWatcher) handle(ctx context.Context, ev SequenceMsg) (uint64, error) {
	hash := hex.EncodeToString(ev.Hash[:])
	switch ev.Event {
	case TransactionAdded:
		// A tx already gone again is skipped; its removal follows or came.
		var entry mempoolEntry
		err := w.callInto(ctx, &entry, "getmempoolentry", hash)
		if err != nil && strings.Contains(err.Error(), "not in mempool") {
			return 0, nil
		}
		if err != nil {
			return 0, err
		}
		tx, err := entry.tx(hash)
		if err != nil {
			return 0, err
		}
		return 0, mempooltx.Upsert(ctx, w.db, []mempooltx.Tx{tx})

	case TransactionRemoved:
		return 0, mempooltx.Forget(ctx, w.db, []string{hash})

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
		if err := mempooltx.Forget(ctx, w.db, block.Tx); err != nil {
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
		keep := block.Height - min(block.Height, referenceBlocks-1)
		if err := mempooltx.PruneBlockStats(ctx, w.db, keep); err != nil {
			return 0, err
		}
		return uint64(len(block.Tx)), nil

	case BlockDisconnected:
		var block struct {
			Height uint32 `json:"height"`
		}
		if err := w.callInto(ctx, &block, "getblock", hash, 1); err != nil {
			return 0, err
		}
		if err := mempooltx.DeleteBlockStatsAbove(ctx, w.db, block.Height-1); err != nil {
			return 0, err
		}
		w.setTip(block.Height - 1)
		return 0, nil

	case Invalid:
		return 0, fmt.Errorf("invalid sequence event for %s", hash)
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
