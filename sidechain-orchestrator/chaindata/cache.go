package chaindata

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"strings"
	"sync"
	"time"
)

// policy says when a cached Core read goes stale: on an event in events, or
// after ttl. A read with no policy always goes to Core.
type policy struct {
	events Event
	ttl    time.Duration
}

// Core's wallet reads wait until the wallet has the newest block, so wallet
// reads go stale on EventBlock. Core's wallets process a mempool change after
// EventMempool, so wallet reads also go stale on EventSettle.
const walletEvents = EventBlock | EventWrite | EventSettle

// settleFollows holds the events after which Fire starts a settle.
const settleFollows = EventBlock | EventMempool

var policies = map[string]policy{
	"getblockchaininfo": {events: EventBlock},
	"getbestblockhash":  {events: EventBlock},
	"getblockcount":     {events: EventBlock},
	"getchainstates":    {events: EventBlock},
	"getrawmempool":     {events: EventBlock | EventMempool},
	"getmempoolinfo":    {events: EventBlock | EventMempool},
	"getbalances":       {events: walletEvents},
	"listtransactions":  {events: walletEvents},
	"listunspent":       {events: walletEvents},
	"listwallets":       {events: EventWrite},
	"getpeerinfo":       {ttl: 5 * time.Second},
	"getnettotals":      {ttl: 5 * time.Second},
	"getnetworkinfo":    {ttl: 5 * time.Second},
}

// readOnly reports whether a Core method leaves the wallets as they are.
func readOnly(method string) bool {
	switch method {
	case "getnewaddress", "getrawchangeaddress":
		return false
	}
	for _, prefix := range []string{"get", "list", "estimate", "decode", "test", "validate", "verify", "waitfor", "uptime", "help"} {
		if strings.HasPrefix(method, prefix) {
			return true
		}
	}
	return false
}

// fetchTimeout caps one Core read that the cache starts.
const fetchTimeout = 2 * time.Minute

type flight[V any] struct {
	done chan struct{}
	gen  uint64
	val  V
	err  error
}

type entry[V any] struct {
	key    string
	p      policy
	ctx    context.Context
	fetch  func(context.Context) (V, error)
	val    V
	ok     bool
	gen    uint64
	at     time.Time
	read   bool
	flight *flight[V]
	// pending asks for one more read after the flight, for an event that came
	// during it.
	pending bool
}

// Cache keeps Core reads by key until an event or a ttl makes them stale.
// After an eager event it reads again at once each value that a caller used,
// so the next caller reads from memory. Other stale values wait for the next
// caller, who reads Core at once.
type Cache[V any] struct {
	e  *Engine
	mu sync.Mutex
	m  map[string]*entry[V]
}

// NewCache builds a Cache that obeys e's events.
func NewCache[V any](e *Engine) *Cache[V] {
	c := &Cache[V]{e: e, m: make(map[string]*entry[V])}
	e.register(c)
	return c
}

// usable reports whether the engine can tell when a value with p goes stale.
func (e *Engine) usable(p policy) bool {
	if !e.running.Load() || e.Health() != nil {
		return false
	}
	return p.events&(EventMempool|EventSettle) == 0 || e.zmqUp.Load()
}

// Get gives the value for key, read by fetch for Core method.
func (c *Cache[V]) Get(ctx context.Context, method, key string, fetch func(context.Context) (V, error)) (V, error) {
	p, ok := policies[method]
	if !ok || !c.e.usable(p) {
		return fetch(ctx)
	}
	for {
		gen := c.e.gen(p.events)

		c.mu.Lock()
		en := c.m[key]
		if en == nil {
			en = &entry[V]{key: key, p: p}
			c.m[key] = en
		}
		en.ctx, en.fetch = context.WithoutCancel(ctx), fetch
		if en.ok && en.gen == gen && (p.ttl == 0 || time.Since(en.at) < p.ttl) {
			en.read = true
			v := en.val
			c.mu.Unlock()
			return v, nil
		}
		f := en.flight
		if f == nil || f.gen < gen {
			f = c.start(en, gen)
		}
		c.mu.Unlock()

		select {
		case <-f.done:
		case <-ctx.Done():
			var zero V
			return zero, ctx.Err()
		}
		if f.gen < gen {
			continue
		}
		if f.err == nil {
			c.mu.Lock()
			if en.gen == f.gen {
				en.read = true
			}
			c.mu.Unlock()
		}
		return f.val, f.err
	}
}

// start reads en from Core. c.mu must be held.
func (c *Cache[V]) start(en *entry[V], gen uint64) *flight[V] {
	f := &flight[V]{done: make(chan struct{}), gen: gen}
	en.flight = f
	ctx, fetch := en.ctx, en.fetch
	go func() {
		ctx, cancel := context.WithTimeout(ctx, fetchTimeout)
		defer cancel()
		v, err := fetch(ctx)

		c.mu.Lock()
		if err == nil && (!en.ok || gen >= en.gen) {
			en.val, en.ok, en.gen, en.at, en.read = v, true, gen, time.Now(), false
		}
		if en.flight == f {
			en.flight = nil
			if en.pending && c.m[en.key] == en {
				en.pending = false
				c.start(en, c.e.gen(en.p.events))
			}
		}
		c.mu.Unlock()

		f.val, f.err = v, err
		close(f.done)
	}()
	return f
}

func (c *Cache[V]) invalidate(mask Event, eager bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	for key, en := range c.m {
		if en.p.events&mask == 0 {
			continue
		}
		// The settle after mask reads the value again, so a read now would
		// double the Core calls. A caller before the settle reads Core.
		if en.p.events&EventSettle != 0 && mask&^settleFollows == 0 {
			continue
		}
		if !en.read {
			if en.flight == nil {
				delete(c.m, key)
			}
			continue
		}
		if !eager {
			continue
		}
		if en.flight != nil {
			en.pending = true
			continue
		}
		c.start(en, c.e.gen(en.p.events))
	}
}

// clear drops every entry. A read in flight ends on its detached entry, so
// it cannot fill the cache for a new endpoint.
func (c *Cache[V]) clear() {
	c.mu.Lock()
	defer c.mu.Unlock()
	clear(c.m)
}

// Wrote marks the wallet reads as stale after a call to method that went to
// Core around the cache and can change a wallet.
func (e *Engine) Wrote(method string) {
	if !readOnly(method) {
		e.Fire(EventWrite)
	}
}

// Call reads a Core method through the cache. A call that can change a
// wallet goes to Core and marks the wallet reads as stale.
func (e *Engine) Call(ctx context.Context, wallet, method string, params []any, fetch func(context.Context) (json.RawMessage, error)) (json.RawMessage, error) {
	if !readOnly(method) {
		raw, err := fetch(ctx)
		if err == nil {
			e.wroteTx(raw)
		}
		e.Fire(EventWrite)
		return raw, err
	}
	key, err := json.Marshal(params)
	if err != nil {
		return fetch(ctx)
	}
	return e.json.Get(ctx, method, wallet+"\x00"+method+"\x00"+string(key), fetch)
}

// SubscribeWrites gives the txid of each transaction that a write call made,
// before the write event fires, until ctx ends.
func (e *Engine) SubscribeWrites(ctx context.Context) <-chan string {
	ch := make(chan string, 16)
	e.writeMu.Lock()
	if e.writeSubs == nil {
		e.writeSubs = map[chan string]struct{}{}
	}
	e.writeSubs[ch] = struct{}{}
	e.writeMu.Unlock()
	go func() {
		<-ctx.Done()
		e.writeMu.Lock()
		delete(e.writeSubs, ch)
		e.writeMu.Unlock()
	}()
	return ch
}

// wroteTx passes the txid of a write result to the write subscribers. A
// result that holds no txid passes nothing.
func (e *Engine) wroteTx(raw json.RawMessage) {
	txid := writtenTxid(raw)
	if txid == "" {
		return
	}
	e.writeMu.Lock()
	defer e.writeMu.Unlock()
	for ch := range e.writeSubs {
		select {
		case ch <- txid:
		default:
		}
	}
}

// writtenTxid reads the txid that sendrawtransaction, sendtoaddress or send
// gives.
func writtenTxid(raw json.RawMessage) string {
	var txid string
	if json.Unmarshal(raw, &txid) != nil {
		var res struct {
			Txid string `json:"txid"`
		}
		if json.Unmarshal(raw, &res) != nil {
			return ""
		}
		txid = res.Txid
	}
	if len(txid) != 64 {
		return ""
	}
	if _, err := hex.DecodeString(txid); err != nil {
		return ""
	}
	return txid
}
