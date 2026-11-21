package chaindata

import (
	"container/heap"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"slices"
	"strings"
	"sync"
	"time"
)

// mempoolFetchTimeout caps one Core read of the mempool tracker.
const mempoolFetchTimeout = time.Minute

// checkAfter holds the times after a seed when the tracker compares its copy
// with getmempoolinfo. A subscription that Core starts to serve after the
// seed loses messages with no gap in the sequence.
var checkAfter = []time.Duration{time.Second, 5 * time.Second}

// checkIdle is how long the feed must be quiet before a check, so that no
// message is still on its way.
var checkIdle = time.Second

// feedBacklog is the most changes a feed holds. A slower reader gets a new
// snapshot in their place.
const feedBacklog = 100_000

// MempoolTx is a mempool transaction as Core reported it when it entered.
type MempoolTx struct {
	Txid            string
	FeeSats         int64
	Vsize           uint32
	Time            time.Time
	AncestorFeeSats int64
	AncestorVsize   uint32
	// Height is the tip height when the transaction entered.
	Height uint32
}

// MempoolBlock is a block that Core connected to or disconnected from the tip.
type MempoolBlock struct {
	Hash      string
	Height    uint32
	Connected bool
	Txids     []string
}

// MempoolChange is one change of the mempool. One field is set.
type MempoolChange struct {
	Added   *MempoolTx
	Removed string
	Block   *MempoolBlock
}

// MempoolSnapshot is the full mempool at one tip.
type MempoolSnapshot struct {
	Height uint32
	Txs    []MempoolTx
}

// MempoolStats sums the mempool. Fee rates are in sat/vB.
type MempoolStats struct {
	TxCount       uint64
	Vsize         uint64
	FeeSats       uint64
	MedianFeeRate float64
	Buckets       []FeeBucket
}

// FeeBucket sums the transactions with a fee rate from MinFeeRate up to the
// next bucket.
type FeeBucket struct {
	MinFeeRate float64
	TxCount    uint64
	Vsize      uint64
	FeeSats    uint64
}

type txKey [32]byte

type memTx struct {
	fee, ancestorFee     int64
	vsize, ancestorVsize uint32
	height               uint32
	time                 int64
	order                uint64
}

func (t memTx) tx(key txKey) MempoolTx {
	return MempoolTx{
		Txid:            hex.EncodeToString(key[:]),
		FeeSats:         t.fee,
		Vsize:           t.vsize,
		Time:            time.Unix(t.time, 0),
		AncestorFeeSats: t.ancestorFee,
		AncestorVsize:   t.ancestorVsize,
		Height:          t.height,
	}
}

// coreEntry is the part of a getmempoolentry or verbose getrawmempool entry
// that the tracker keeps.
type coreEntry struct {
	Vsize        uint32 `json:"vsize"`
	AncestorSize uint32 `json:"ancestorsize"`
	Time         int64  `json:"time"`
	Height       uint32 `json:"height"`
	Fees         struct {
		Base     float64 `json:"base"`
		Ancestor float64 `json:"ancestor"`
	} `json:"fees"`
}

func (c coreEntry) memTx() memTx {
	return memTx{
		fee:           btcToSats(c.Fees.Base),
		ancestorFee:   btcToSats(c.Fees.Ancestor),
		vsize:         c.Vsize,
		ancestorVsize: c.AncestorSize,
		height:        c.Height,
		time:          c.Time,
	}
}

func btcToSats(btc float64) int64 { return int64(math.Round(btc * 1e8)) }

func parseTxKey(txid string) (txKey, error) {
	var k txKey
	b, err := hex.DecodeString(txid)
	if err != nil || len(b) != len(k) {
		return k, fmt.Errorf("bad txid %q", txid)
	}
	copy(k[:], b)
	return k, nil
}

// seqEvent is one message of Core's ZMQ sequence feed.
type seqEvent struct {
	label byte
	hash  txKey
	// seq is the mempool sequence of an A or R message.
	seq uint64
	// gap marks a lost message: the tracker reads the mempool again.
	gap bool
}

// Mempool keeps a copy of Core's mempool. One getrawmempool fills it, and
// the ZMQ sequence feed keeps it current. While it holds no copy, each read
// goes to Core.
type Mempool struct {
	call  Caller
	batch BatchCaller
	// seeded runs after each seed. A seed can follow lost messages, so the
	// reads that depend on the mempool go stale.
	seeded func()

	mu       sync.Mutex
	lastMsg  time.Time
	ready    bool
	txs      map[txKey]memTx
	height   uint32
	order    uint64
	queue    []seqEvent
	received uint64
	applied  uint64
	// minSeq skips the A and R messages that the copy already holds.
	minSeq  uint64
	changed chan struct{}
	wake    chan struct{}
	feeds   map[*MempoolFeed]struct{}
}

func newMempool(call Caller, batch BatchCaller) *Mempool {
	return &Mempool{
		call:    call,
		batch:   batch,
		changed: make(chan struct{}),
		wake:    make(chan struct{}, 1),
		feeds:   make(map[*MempoolFeed]struct{}),
	}
}

func (m *Mempool) push(ev seqEvent) {
	m.mu.Lock()
	m.queue = append(m.queue, ev)
	m.received++
	m.lastMsg = time.Now()
	m.mu.Unlock()
	select {
	case m.wake <- struct{}{}:
	default:
	}
}

// broadcastLocked wakes the readers that wait for the copy.
func (m *Mempool) broadcastLocked() {
	close(m.changed)
	m.changed = make(chan struct{})
}

// reset drops the copy. Reads go to Core until the next seed.
func (m *Mempool) reset() {
	m.mu.Lock()
	m.ready = false
	m.txs = nil
	m.queue = nil
	m.applied = m.received
	m.broadcastLocked()
	m.mu.Unlock()
}

// run keeps the copy current until ctx ends. Start it after the ZMQ
// subscription receives messages.
func (m *Mempool) run(ctx context.Context, onErr func(error)) {
	defer m.reset()
	for ctx.Err() == nil {
		err := m.seed(ctx)
		if err == nil {
			err = m.follow(ctx)
		}
		if ctx.Err() != nil {
			return
		}
		m.reset()
		if errors.Is(err, errMissed) {
			onErr(err)
		}
		if errors.Is(err, errSequenceGap) || errors.Is(err, errReorg) || errors.Is(err, errMissed) {
			continue
		}
		onErr(err)
		t := time.NewTimer(retryDelay)
		select {
		case <-ctx.Done():
			t.Stop()
			return
		case <-t.C:
		}
	}
}

var (
	errSequenceGap = errors.New("zmq sequence gap")
	// errReorg follows a disconnected block. A reorg during a seed can put
	// back transactions whose A messages the seed skips, so the tracker
	// reads the mempool again.
	errReorg  = errors.New("block disconnected")
	errMissed = errors.New("the copy differs from getmempoolinfo")
)

// seed fills the copy from Core. The messages that came before it are in
// the copy, so it drops them.
func (m *Mempool) seed(ctx context.Context) error {
	m.mu.Lock()
	m.queue = nil
	m.applied = m.received
	m.mu.Unlock()

	ctx, cancel := context.WithTimeout(ctx, mempoolFetchTimeout)
	defer cancel()
	var height uint32
	if err := m.callInto(ctx, &height, "getblockcount"); err != nil {
		return err
	}
	var snapshot struct {
		Txids           []string `json:"txids"`
		MempoolSequence uint64   `json:"mempool_sequence"`
	}
	if err := m.callInto(ctx, &snapshot, "getrawmempool", false, true); err != nil {
		return err
	}
	// A verbose read cannot hold the sequence. A transaction that left
	// between the two reads has an R message after the sequence; one that
	// came has an A message after it.
	var entries map[string]coreEntry
	if err := m.callInto(ctx, &entries, "getrawmempool", true); err != nil {
		return err
	}
	txs := make(map[txKey]memTx, len(snapshot.Txids))
	var order uint64
	for _, txid := range snapshot.Txids {
		entry, ok := entries[txid]
		if !ok {
			continue
		}
		key, err := parseTxKey(txid)
		if err != nil {
			return err
		}
		t := entry.memTx()
		order++
		t.order = order
		txs[key] = t
	}

	m.mu.Lock()
	defer m.mu.Unlock()
	m.txs, m.height, m.order, m.minSeq, m.ready = txs, height, order, snapshot.MempoolSequence, true
	snap := m.snapshotLocked()
	for f := range m.feeds {
		f.replace(snap)
	}
	m.broadcastLocked()
	if m.seeded != nil {
		m.seeded()
	}
	return nil
}

// follow applies the queued messages until ctx ends or a read fails.
func (m *Mempool) follow(ctx context.Context) error {
	start := time.Now()
	checks := slices.Clone(checkAfter)
	timer := time.NewTimer(time.Hour)
	defer timer.Stop()
	for {
		m.mu.Lock()
		batch := m.queue
		m.queue = nil
		m.mu.Unlock()
		if len(batch) == 0 {
			timer.Stop()
			if len(checks) > 0 {
				timer.Reset(time.Until(start.Add(checks[0])))
			}
			select {
			case <-ctx.Done():
				return nil
			case <-m.wake:
			case <-timer.C:
				done, err := m.check(ctx)
				if err != nil {
					return err
				}
				if done {
					checks = checks[1:]
				} else {
					start = start.Add(checkIdle)
				}
			}
			continue
		}
		if err := m.apply(ctx, batch); err != nil {
			return err
		}
	}
}

// check compares the copy with Core once the feed is quiet. It reports false
// when the feed was not quiet, so the caller tries again later.
func (m *Mempool) check(ctx context.Context) (bool, error) {
	m.mu.Lock()
	quiet := len(m.queue) == 0 && m.applied == m.received && time.Since(m.lastMsg) >= checkIdle
	m.mu.Unlock()
	if !quiet {
		return false, nil
	}
	var info struct {
		Size  int    `json:"size"`
		Bytes uint64 `json:"bytes"`
	}
	if err := m.callInto(ctx, &info, "getmempoolinfo"); err != nil {
		return false, err
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.received != m.applied || len(m.queue) > 0 {
		return false, nil
	}
	var vsize uint64
	for _, t := range m.txs {
		vsize += uint64(t.vsize)
	}
	if info.Size != len(m.txs) || info.Bytes != vsize {
		return false, errMissed
	}
	return true, nil
}

type blockInfo struct {
	Height uint32   `json:"height"`
	Tx     []string `json:"tx"`
}

// apply reads what the messages need from Core, then applies them in order.
func (m *Mempool) apply(ctx context.Context, batch []seqEvent) error {
	ctx, cancel := context.WithTimeout(ctx, mempoolFetchTimeout)
	defer cancel()

	m.mu.Lock()
	minSeq := m.minSeq
	m.mu.Unlock()

	var added []txKey
	wanted := map[txKey]bool{}
	blocks := map[txKey]blockInfo{}
	for _, ev := range batch {
		switch {
		case ev.gap:
			return errSequenceGap
		case ev.label == 'A' && ev.seq >= minSeq && !wanted[ev.hash]:
			wanted[ev.hash] = true
			added = append(added, ev.hash)
		case ev.label == 'C' || ev.label == 'D':
			if _, ok := blocks[ev.hash]; ok {
				continue
			}
			var b blockInfo
			if err := m.callInto(ctx, &b, "getblock", hex.EncodeToString(ev.hash[:]), 1); err != nil {
				return err
			}
			blocks[ev.hash] = b
		}
	}
	entries, err := m.entries(ctx, added)
	if err != nil {
		return err
	}

	m.mu.Lock()
	defer m.mu.Unlock()
	var changes []MempoolChange
	for _, ev := range batch {
		switch ev.label {
		case 'A':
			entry, ok := entries[ev.hash]
			if ev.seq < minSeq || !ok {
				continue
			}
			m.order++
			entry.order = m.order
			m.txs[ev.hash] = entry
			tx := entry.tx(ev.hash)
			changes = append(changes, MempoolChange{Added: &tx})
		case 'R':
			if ev.seq < minSeq {
				continue
			}
			if _, ok := m.txs[ev.hash]; !ok {
				continue
			}
			delete(m.txs, ev.hash)
			changes = append(changes, MempoolChange{Removed: hex.EncodeToString(ev.hash[:])})
		case 'C', 'D':
			b := blocks[ev.hash]
			// Core sends no R message for the transactions of a block.
			if ev.label == 'C' {
				for _, txid := range b.Tx {
					if key, err := parseTxKey(txid); err == nil {
						delete(m.txs, key)
					}
				}
				m.height = b.Height
			} else {
				m.height = b.Height - min(b.Height, 1)
			}
			changes = append(changes, MempoolChange{Block: &MempoolBlock{
				Hash:      hex.EncodeToString(ev.hash[:]),
				Height:    b.Height,
				Connected: ev.label == 'C',
				Txids:     b.Tx,
			}})
		}
	}
	m.applied += uint64(len(batch))
	if len(changes) > 0 {
		for f := range m.feeds {
			f.add(changes, m)
		}
	}
	m.broadcastLocked()
	for _, ev := range batch {
		if ev.label == 'D' {
			return errReorg
		}
	}
	return nil
}

// entries reads the mempool entries of keys in one batch. A transaction that
// left again has no entry; its R message follows or came.
func (m *Mempool) entries(ctx context.Context, keys []txKey) (map[txKey]memTx, error) {
	out := make(map[txKey]memTx, len(keys))
	if len(keys) == 0 {
		return out, nil
	}
	params := make([][]any, len(keys))
	for i, k := range keys {
		params[i] = []any{hex.EncodeToString(k[:])}
	}
	var results []BatchResult
	if m.batch != nil {
		var err error
		if results, err = m.batch(ctx, "getmempoolentry", params); err != nil {
			return nil, err
		}
	} else {
		results = make([]BatchResult, len(params))
		for i, p := range params {
			results[i].Result, results[i].Err = m.call(ctx, "getmempoolentry", p...)
		}
	}
	if len(results) != len(keys) {
		return nil, fmt.Errorf("getmempoolentry: %d results for %d calls", len(results), len(keys))
	}
	for i, r := range results {
		if r.Err != nil {
			if strings.Contains(r.Err.Error(), "not in mempool") {
				continue
			}
			return nil, fmt.Errorf("getmempoolentry: %w", r.Err)
		}
		var entry coreEntry
		if err := json.Unmarshal(r.Result, &entry); err != nil {
			return nil, fmt.Errorf("decode getmempoolentry: %w", err)
		}
		out[keys[i]] = entry.memTx()
	}
	return out, nil
}

func (m *Mempool) callInto(ctx context.Context, out any, method string, params ...any) error {
	raw, err := m.call(ctx, method, params...)
	if err != nil {
		return fmt.Errorf("%s: %w", method, err)
	}
	if err := json.Unmarshal(raw, out); err != nil {
		return fmt.Errorf("decode %s: %w", method, err)
	}
	return nil
}

func (m *Mempool) snapshotLocked() *MempoolSnapshot {
	snap := &MempoolSnapshot{Height: m.height, Txs: make([]MempoolTx, 0, len(m.txs))}
	for k, t := range m.txs {
		snap.Txs = append(snap.Txs, t.tx(k))
	}
	return snap
}

// view calls fn with the copy once it holds each message that came before
// the call. With no copy, fn gets the mempool from Core.
func (m *Mempool) view(ctx context.Context, fn func(txs map[txKey]memTx)) error {
	m.mu.Lock()
	target := m.received
	for m.ready && m.applied < target {
		ch := m.changed
		m.mu.Unlock()
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ch:
		}
		m.mu.Lock()
	}
	if m.ready {
		defer m.mu.Unlock()
		fn(m.txs)
		return nil
	}
	m.mu.Unlock()

	txs, err := m.fromCore(ctx)
	if err != nil {
		return err
	}
	fn(txs)
	return nil
}

func (m *Mempool) fromCore(ctx context.Context) (map[txKey]memTx, error) {
	var entries map[string]coreEntry
	if err := m.callInto(ctx, &entries, "getrawmempool", true); err != nil {
		return nil, err
	}
	txs := make(map[txKey]memTx, len(entries))
	for txid, entry := range entries {
		key, err := parseTxKey(txid)
		if err != nil {
			return nil, err
		}
		txs[key] = entry.memTx()
	}
	return txs, nil
}

// Newest gives the count newest transactions, newest first, and the size of
// the mempool. A count of zero gives all.
func (m *Mempool) Newest(ctx context.Context, count int) ([]MempoolTx, int, error) {
	var out []MempoolTx
	var total int
	err := m.view(ctx, func(txs map[txKey]memTx) {
		total = len(txs)
		h := &newestHeap{}
		for k, t := range txs {
			e := keyed{k, t}
			if count <= 0 || h.Len() < count {
				heap.Push(h, e)
				continue
			}
			if older(h.items[0], e) {
				h.items[0] = e
				heap.Fix(h, 0)
			}
		}
		items := h.items
		slices.SortFunc(items, func(a, b keyed) int {
			if older(a, b) {
				return 1
			}
			if older(b, a) {
				return -1
			}
			return 0
		})
		out = make([]MempoolTx, len(items))
		for i, e := range items {
			out[i] = e.t.tx(e.k)
		}
	})
	return out, total, err
}

type keyed struct {
	k txKey
	t memTx
}

// older reports whether a entered the mempool before b.
func older(a, b keyed) bool {
	if a.t.time != b.t.time {
		return a.t.time < b.t.time
	}
	if a.t.order != b.t.order {
		return a.t.order < b.t.order
	}
	return string(a.k[:]) < string(b.k[:])
}

// newestHeap holds the oldest kept transaction at the top.
type newestHeap struct{ items []keyed }

func (h *newestHeap) Len() int           { return len(h.items) }
func (h *newestHeap) Less(i, j int) bool { return older(h.items[i], h.items[j]) }
func (h *newestHeap) Swap(i, j int)      { h.items[i], h.items[j] = h.items[j], h.items[i] }
func (h *newestHeap) Push(x any)         { h.items = append(h.items, x.(keyed)) }
func (h *newestHeap) Pop() any {
	last := h.items[len(h.items)-1]
	h.items = h.items[:len(h.items)-1]
	return last
}

// Stats sums the mempool into buckets with the lower fee rate edges.
func (m *Mempool) Stats(ctx context.Context, edges []float64) (MempoolStats, error) {
	if !slices.IsSorted(edges) {
		return MempoolStats{}, errors.New("bucket edges must ascend")
	}
	var out MempoolStats
	err := m.view(ctx, func(txs map[txKey]memTx) {
		out.Buckets = make([]FeeBucket, len(edges))
		for i, edge := range edges {
			out.Buckets[i].MinFeeRate = edge
		}
		rates := make([]float64, 0, len(txs))
		for _, t := range txs {
			var rate float64
			if t.vsize > 0 {
				rate = float64(t.fee) / float64(t.vsize)
			}
			rates = append(rates, rate)
			out.TxCount++
			out.Vsize += uint64(t.vsize)
			out.FeeSats += uint64(max(t.fee, 0))
			i, found := slices.BinarySearch(edges, rate)
			if !found {
				i--
			}
			if i < 0 {
				continue
			}
			b := &out.Buckets[i]
			b.TxCount++
			b.Vsize += uint64(t.vsize)
			b.FeeSats += uint64(max(t.fee, 0))
		}
		if len(rates) > 0 {
			slices.Sort(rates)
			out.MedianFeeRate = rates[len(rates)/2]
		}
	})
	return out, err
}

// Watch gives a feed of the mempool. Its first read waits for a snapshot.
// The feed ends when ctx ends.
func (m *Mempool) Watch(ctx context.Context) *MempoolFeed {
	f := &MempoolFeed{wake: make(chan struct{}, 1)}
	m.mu.Lock()
	if m.ready {
		f.replace(m.snapshotLocked())
	}
	m.feeds[f] = struct{}{}
	m.mu.Unlock()
	go func() {
		<-ctx.Done()
		m.mu.Lock()
		delete(m.feeds, f)
		m.mu.Unlock()
	}()
	return f
}

// Changes wakes after each change of the copy, also a seed or a reset,
// until ctx ends. One wake can stand for more changes.
func (m *Mempool) Changes(ctx context.Context) <-chan struct{} {
	out := make(chan struct{}, 1)
	m.mu.Lock()
	changed := m.changed
	m.mu.Unlock()
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case <-changed:
			}
			// Take the next channel before the wake, so a reader after the
			// wake sees each change that closed no watched channel.
			m.mu.Lock()
			changed = m.changed
			m.mu.Unlock()
			select {
			case out <- struct{}{}:
			default:
			}
		}
	}()
	return out
}

// MempoolFeed is the snapshots and changes of the mempool for one reader.
type MempoolFeed struct {
	mu      sync.Mutex
	snap    *MempoolSnapshot
	changes []MempoolChange
	wake    chan struct{}
}

func (f *MempoolFeed) signal() {
	select {
	case f.wake <- struct{}{}:
	default:
	}
}

func (f *MempoolFeed) replace(snap *MempoolSnapshot) {
	f.mu.Lock()
	f.snap, f.changes = snap, nil
	f.mu.Unlock()
	f.signal()
}

// add queues changes. m.mu must be held.
func (f *MempoolFeed) add(changes []MempoolChange, m *Mempool) {
	f.mu.Lock()
	if len(f.changes)+len(changes) > feedBacklog {
		f.mu.Unlock()
		f.replace(m.snapshotLocked())
		return
	}
	f.changes = append(f.changes, changes...)
	f.mu.Unlock()
	f.signal()
}

// Next waits for a snapshot or changes. A snapshot replaces the mempool; the
// changes that come with it follow it.
func (f *MempoolFeed) Next(ctx context.Context) (*MempoolSnapshot, []MempoolChange, error) {
	for {
		f.mu.Lock()
		snap, changes := f.snap, f.changes
		f.snap, f.changes = nil, nil
		f.mu.Unlock()
		if snap != nil || len(changes) > 0 {
			return snap, changes, nil
		}
		select {
		case <-ctx.Done():
			return nil, nil, ctx.Err()
		case <-f.wake:
		}
	}
}

// Ready reports whether the tracker holds a copy of the mempool.
func (m *Mempool) Ready() bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.ready
}
