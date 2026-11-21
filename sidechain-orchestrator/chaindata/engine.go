// Package chaindata holds the Bitcoin Core state that drivechaind and its
// clients read, and refreshes each part only on the event that changes it.
package chaindata

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/rs/zerolog"
)

// Caller sends one JSON-RPC call to Bitcoin Core with no wallet.
type Caller func(ctx context.Context, method string, params ...any) (json.RawMessage, error)

// BatchResult is the answer to one call of a JSON-RPC batch.
type BatchResult struct {
	Result json.RawMessage
	Err    error
}

// BatchCaller sends method once for each entry of params in one JSON-RPC
// batch. The results come in the order of params.
type BatchCaller func(ctx context.Context, method string, params [][]any) ([]BatchResult, error)

// Kind names a part of the state that a client can read or watch.
type Kind int

const (
	// KindBlockchainInfo is the getblockchaininfo result.
	KindBlockchainInfo Kind = iota
	// KindMempool changes when a transaction enters or leaves the mempool.
	KindMempool
	// KindWallet changes when wallet balances, transactions or UTXOs can change.
	KindWallet
	// KindHealth changes when Bitcoin Core becomes reachable or unreachable.
	KindHealth
)

// Event is a set of causes that make cached reads stale.
type Event uint8

const (
	// EventBlock is a new tip or a header change.
	EventBlock Event = 1 << iota
	// EventMempool is a transaction that entered or left the mempool.
	EventMempool
	// EventWrite is a call that can change wallet state.
	EventWrite
	// EventSettle comes after Core's wallets processed the block and mempool
	// events so far. Core tells its wallets after it tells ZMQ and RPC waiters.
	EventSettle

	eventAll = EventBlock | EventMempool | EventWrite | EventSettle
)

const (
	// longPoll is how long one waitforblockheight call waits in Core. A probe
	// follows each poll, so a header with no block shows within this time.
	longPoll = 15 * time.Second
	// probeTimeout is the time Core gets to answer one getblockchaininfo. Core
	// holds cs_main for seconds during IBD on slow storage.
	probeTimeout = 60 * time.Second
	// retryDelay spaces the probes while Core is down or syncs.
	retryDelay = time.Second
	// settleDelay replaces the wallet sync on a Core that cannot do it.
	settleDelay = 500 * time.Millisecond
	// settleSpacing limits the wallet syncs while the mempool changes fast.
	settleSpacing = 200 * time.Millisecond
	// syncSpacing limits the tip reads while Core connects many blocks.
	syncSpacing = 100 * time.Millisecond
)

// ErrNoProbe is the health before the first probe of an endpoint.
var ErrNoProbe = errors.New("bitcoin core: no probe yet")

// Config wires an Engine to one Bitcoin Core.
type Config struct {
	Call Caller
	// Batch is optional. Without it, the mempool tracker sends one call per entry.
	Batch BatchCaller
	// ZMQAddr gives Core's zmqpubsequence endpoint, or "" when it has none.
	ZMQAddr func() string
	Log     zerolog.Logger
}

type tipInfo struct {
	Chain         string `json:"chain"`
	Blocks        int64  `json:"blocks"`
	Headers       int64  `json:"headers"`
	BestBlockHash string `json:"bestblockhash"`
}

type invalidator interface {
	invalidate(mask Event, eager bool)
	clear()
}

// Engine watches Bitcoin Core with one long poll and its ZMQ sequence feed,
// and keeps the reads that clients repeat until an event changes them.
type Engine struct {
	call    Caller
	zmqAddr func() string
	log     zerolog.Logger

	running atomic.Bool
	zmqUp   atomic.Bool

	mu            sync.Mutex
	gens          [4]uint64
	info          json.RawMessage
	tip           tipInfo
	health        error
	subs          map[Kind]map[chan struct{}]struct{}
	caches        []invalidator
	settling      bool
	settlePending bool
	// settleBlock marks a settle round that follows a block.
	settleBlock bool
	pollCancel  context.CancelFunc
	kicked      bool
	zmqCancel   context.CancelFunc

	wake chan struct{}

	json      *Cache[json.RawMessage]
	responses *Cache[any]
	mempool   *Mempool

	writeMu   sync.Mutex
	writeSubs map[chan string]struct{}
}

// New builds an Engine. Call Run to start it.
func New(conf Config) *Engine {
	e := &Engine{
		call:    conf.Call,
		zmqAddr: conf.ZMQAddr,
		log:     conf.Log.With().Str("component", "chaindata").Logger(),
		health:  ErrNoProbe,
		subs:    make(map[Kind]map[chan struct{}]struct{}),
		wake:    make(chan struct{}, 1),
		mempool: newMempool(conf.Call, conf.Batch),
	}
	e.mempool.seeded = func() { e.Fire(EventMempool) }
	e.json = NewCache[json.RawMessage](e)
	e.responses = NewCache[any](e)
	return e
}

// Mempool is the copy of Core's mempool.
func (e *Engine) Mempool() *Mempool { return e.mempool }

// Running reports whether Run watches Core. A stopped engine caches nothing.
func (e *Engine) Running() bool { return e.running.Load() }

// Start runs the engine in the background until ctx ends. Running reports
// true from the moment Start returns.
func (e *Engine) Start(ctx context.Context) {
	e.running.Store(true)
	go e.Run(ctx)
}

// Run watches Core until ctx ends.
func (e *Engine) Run(ctx context.Context) {
	e.running.Store(true)
	defer e.running.Store(false)
	if e.zmqAddr != nil {
		go e.runZMQ(ctx)
	}
	e.runTip(ctx)
}

// Restart forgets the state and probes Core again. Call it when the Core
// endpoint changes.
func (e *Engine) Restart() {
	e.mu.Lock()
	e.info, e.tip, e.health = nil, tipInfo{}, ErrNoProbe
	cancel := e.zmqCancel
	e.mu.Unlock()
	e.zmqUp.Store(false)
	if cancel != nil {
		cancel()
	}
	e.clearCaches()
	e.kick()
}

// Health is the error of the newest getblockchaininfo, nil while Core answers.
func (e *Engine) Health() error {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.health
}

// Get reads a part of the state from memory.
func (e *Engine) Get(kind Kind) (json.RawMessage, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	switch kind {
	case KindBlockchainInfo:
		if e.health != nil {
			return nil, e.health
		}
		return e.info, nil
	case KindHealth:
		return nil, e.health
	default:
		return nil, fmt.Errorf("chaindata: kind %d holds no data, read it with Call", kind)
	}
}

// Subscribe gives a channel that receives a value after each change of kind.
// The channel closes when ctx ends.
func (e *Engine) Subscribe(ctx context.Context, kind Kind) <-chan struct{} {
	ch := make(chan struct{}, 1)
	e.mu.Lock()
	if e.subs[kind] == nil {
		e.subs[kind] = make(map[chan struct{}]struct{})
	}
	e.subs[kind][ch] = struct{}{}
	e.mu.Unlock()
	go func() {
		<-ctx.Done()
		e.mu.Lock()
		delete(e.subs[kind], ch)
		e.mu.Unlock()
		close(ch)
	}()
	return ch
}

// Probe reads getblockchaininfo now and records the result.
func (e *Engine) Probe(ctx context.Context) error {
	return e.refresh(ctx)
}

func (e *Engine) gen(mask Event) uint64 {
	e.mu.Lock()
	defer e.mu.Unlock()
	var sum uint64
	for i := range e.gens {
		if mask&(1<<i) != 0 {
			sum += e.gens[i]
		}
	}
	return sum
}

func (e *Engine) register(c invalidator) {
	e.mu.Lock()
	e.caches = append(e.caches, c)
	e.mu.Unlock()
}

// Fire marks the reads that depend on mask as stale and tells the watchers.
// After a block or a write, the cache reads each used value again at once.
// After a mempool change, the next caller reads it, so churn costs one read
// per caller and not one per transaction.
func (e *Engine) Fire(mask Event) {
	e.fire(mask, mask&(EventBlock|EventWrite) != 0)
}

func (e *Engine) fire(mask Event, eager bool) {
	e.mu.Lock()
	for i := range e.gens {
		if mask&(1<<i) != 0 {
			e.gens[i]++
		}
	}
	kinds := map[Kind]bool{
		KindMempool: mask&EventMempool != 0,
		KindWallet:  mask&walletEvents != 0,
	}
	if mask&settleFollows != 0 {
		if mask&EventBlock != 0 {
			e.settleBlock = true
		}
		if e.settling {
			e.settlePending = true
		} else {
			e.settling = true
			go e.settle()
		}
	}
	caches := append([]invalidator(nil), e.caches...)
	e.notifyLocked(kinds)
	e.mu.Unlock()

	for _, c := range caches {
		c.invalidate(mask, eager)
	}
}

// settle waits until Core's wallets processed the events so far, then fires
// EventSettle. Events that come during the wait start one more round.
func (e *Engine) settle() {
	for {
		e.mu.Lock()
		afterBlock := e.settleBlock
		e.settleBlock = false
		e.mu.Unlock()
		ctx, cancel := context.WithTimeout(context.Background(), longPoll)
		_, err := e.call(ctx, "syncwithvalidationinterfacequeue")
		cancel()
		if err != nil {
			time.Sleep(settleDelay)
		}
		e.fire(EventSettle, afterBlock)

		e.mu.Lock()
		if !e.settlePending {
			e.settling = false
			e.mu.Unlock()
			return
		}
		e.mu.Unlock()
		time.Sleep(settleSpacing)
		e.mu.Lock()
		e.settlePending = false
		e.mu.Unlock()
	}
}

func (e *Engine) notifyLocked(kinds map[Kind]bool) {
	for kind, on := range kinds {
		if !on {
			continue
		}
		for ch := range e.subs[kind] {
			select {
			case ch <- struct{}{}:
			default:
			}
		}
	}
}

func (e *Engine) clearCaches() {
	e.mu.Lock()
	caches := append([]invalidator(nil), e.caches...)
	e.mu.Unlock()
	for _, c := range caches {
		c.clear()
	}
}

// refresh reads getblockchaininfo and fires the events its change implies.
func (e *Engine) refresh(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, probeTimeout)
	defer cancel()
	raw, err := e.call(ctx, "getblockchaininfo")
	var tip tipInfo
	if err == nil {
		if derr := json.Unmarshal(raw, &tip); derr != nil {
			err = fmt.Errorf("decode getblockchaininfo: %w", derr)
		}
	}

	e.mu.Lock()
	wasUp := e.health == nil
	if err != nil {
		e.info, e.tip, e.health = nil, tipInfo{}, err
		e.notifyLocked(map[Kind]bool{KindHealth: wasUp})
		cancel := e.zmqCancel
		e.mu.Unlock()
		if wasUp {
			e.clearCaches()
			if cancel != nil {
				cancel()
			}
		}
		return err
	}
	changed := tip != e.tip
	infoChanged := !bytes.Equal(raw, e.info)
	e.info, e.tip, e.health = raw, tip, nil
	e.mu.Unlock()

	// The caches go stale before a watcher hears of the change, so its next
	// read gets the new state.
	switch {
	case !wasUp:
		e.clearCaches()
		e.Fire(eventAll)
	case changed:
		e.Fire(EventBlock)
	}
	e.mu.Lock()
	e.notifyLocked(map[Kind]bool{KindHealth: !wasUp, KindBlockchainInfo: infoChanged})
	e.mu.Unlock()
	return nil
}

func (e *Engine) syncing() bool {
	e.mu.Lock()
	defer e.mu.Unlock()
	presync := e.tip.Chain != "regtest" && e.tip.Blocks == 0 && e.tip.Headers == 0
	return e.tip.Blocks < e.tip.Headers || presync
}

func (e *Engine) kick() {
	e.mu.Lock()
	e.kicked = true
	cancel := e.pollCancel
	e.mu.Unlock()
	if cancel != nil {
		cancel()
	}
	select {
	case e.wake <- struct{}{}:
	default:
	}
}

func (e *Engine) sleep(ctx context.Context, d time.Duration) {
	t := time.NewTimer(d)
	defer t.Stop()
	select {
	case <-ctx.Done():
	case <-t.C:
	case <-e.wake:
	}
}

func (e *Engine) runTip(ctx context.Context) {
	probe := true
	var probedAt time.Time
	for ctx.Err() == nil {
		if probe {
			probedAt = time.Now()
			if err := e.refresh(ctx); err != nil {
				e.sleep(ctx, retryDelay)
				continue
			}
		}
		if e.syncing() {
			e.sleep(ctx, retryDelay)
			probe = true
			continue
		}
		probe = true
		if e.waitForBlock(ctx) {
			if e.refresh(ctx) == nil {
				e.sleep(ctx, retryDelay)
				probe = false
			}
			continue
		}
		if wait := syncSpacing - time.Since(probedAt); wait > 0 {
			time.Sleep(wait)
		}
	}
}

// waitForBlock long-polls Core until the next block or the poll timeout, and
// reports whether the poll failed. A timeout still leads to a probe, because
// headers move with no block. A Core with no long poll reads as a 1 s poll.
func (e *Engine) waitForBlock(ctx context.Context) (failed bool) {
	e.mu.Lock()
	if e.kicked {
		e.kicked = false
		e.mu.Unlock()
		return false
	}
	height := e.tip.Blocks
	pollCtx, cancel := context.WithTimeout(ctx, longPoll+10*time.Second)
	e.pollCancel = cancel
	e.mu.Unlock()

	_, err := e.call(pollCtx, "waitforblockheight", height+1, longPoll.Milliseconds())

	e.mu.Lock()
	e.pollCancel = nil
	kicked := e.kicked
	e.kicked = false
	e.mu.Unlock()
	cancel()
	return err != nil && !kicked
}
