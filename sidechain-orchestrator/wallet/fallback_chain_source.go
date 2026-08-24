package wallet

import (
	"context"
	"errors"
	"sync"
	"time"

	"github.com/rs/zerolog"
)

// sourceCooldown is how long a failed source is skipped. Without it every read
// pays the dead server's connect timeout again.
const sourceCooldown = 30 * time.Second

// fallbackChainSource reads through an ordered list of chain sources, best
// first. A source that fails is skipped for sourceCooldown, so a Fulcrum
// outage drops the wallet to the network's Esplora instead of stopping it.
type fallbackChainSource struct {
	sources []ChainDataSource
	log     zerolog.Logger

	mu        sync.Mutex
	downUntil []time.Time
}

var _ ChainDataSource = (*fallbackChainSource)(nil)

func newFallbackChainSource(sources []ChainDataSource, log zerolog.Logger) *fallbackChainSource {
	return &fallbackChainSource{
		sources:   sources,
		log:       log.With().Str("component", "fallback-chain-source").Logger(),
		downUntil: make([]time.Time, len(sources)),
	}
}

// order returns the source indexes to try: the ones off cooldown first, then
// the rest. A source in cooldown is still tried last, because a cooled-down
// primary beats no answer at all.
func (f *fallbackChainSource) order() []int {
	f.mu.Lock()
	defer f.mu.Unlock()

	now := time.Now()
	ready := make([]int, 0, len(f.sources))
	cooling := make([]int, 0, len(f.sources))
	for i := range f.sources {
		if now.Before(f.downUntil[i]) {
			cooling = append(cooling, i)
			continue
		}
		ready = append(ready, i)
	}
	return append(ready, cooling...)
}

func (f *fallbackChainSource) markDown(i int) {
	f.mu.Lock()
	f.downUntil[i] = time.Now().Add(sourceCooldown)
	f.mu.Unlock()
}

func (f *fallbackChainSource) markUp(i int) {
	f.mu.Lock()
	f.downUntil[i] = time.Time{}
	f.mu.Unlock()
}

// try runs call against each source in turn and returns the first success.
func (f *fallbackChainSource) try(ctx context.Context, op string, call func(ChainDataSource) error) error {
	var errs []error
	for _, i := range f.order() {
		if err := ctx.Err(); err != nil {
			return err
		}
		err := call(f.sources[i])
		if err == nil {
			f.markUp(i)
			return nil
		}
		f.markDown(i)
		f.log.Debug().Err(err).Str("op", op).Int("source", i).Msg("chain source failed, trying the next")
		errs = append(errs, err)
	}
	if len(errs) == 0 {
		return errors.New("no chain source configured")
	}
	return errors.Join(errs...)
}

func (f *fallbackChainSource) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	var out EsploraAddressStats
	err := f.try(ctx, "address_stats", func(c ChainDataSource) error {
		var err error
		out, err = c.AddressStats(ctx, address)
		return err
	})
	return out, err
}

func (f *fallbackChainSource) AddressUTXOs(ctx context.Context, address string) ([]EsploraUTXO, error) {
	var out []EsploraUTXO
	err := f.try(ctx, "address_utxos", func(c ChainDataSource) error {
		var err error
		out, err = c.AddressUTXOs(ctx, address)
		return err
	})
	return out, err
}

func (f *fallbackChainSource) AddressTxs(ctx context.Context, address string) ([]EsploraTx, error) {
	var out []EsploraTx
	err := f.try(ctx, "address_txs", func(c ChainDataSource) error {
		var err error
		out, err = c.AddressTxs(ctx, address)
		return err
	})
	return out, err
}

func (f *fallbackChainSource) Tx(ctx context.Context, txid string) (EsploraTx, error) {
	var out EsploraTx
	err := f.try(ctx, "tx", func(c ChainDataSource) error {
		var err error
		out, err = c.Tx(ctx, txid)
		return err
	})
	return out, err
}

func (f *fallbackChainSource) TxHex(ctx context.Context, txid string) (string, error) {
	var out string
	err := f.try(ctx, "tx_hex", func(c ChainDataSource) error {
		var err error
		out, err = c.TxHex(ctx, txid)
		return err
	})
	return out, err
}

func (f *fallbackChainSource) Broadcast(ctx context.Context, rawHex string) (string, error) {
	var out string
	err := f.try(ctx, "broadcast", func(c ChainDataSource) error {
		var err error
		out, err = c.Broadcast(ctx, rawHex)
		return err
	})
	return out, err
}

func (f *fallbackChainSource) TipHeight(ctx context.Context) (int, error) {
	var out int
	err := f.try(ctx, "tip_height", func(c ChainDataSource) error {
		var err error
		out, err = c.TipHeight(ctx)
		return err
	})
	return out, err
}

// FeeRateForTarget reports no error, so a source that hands back the caller's
// own fallback value counts as a miss and the next source gets a turn.
func (f *fallbackChainSource) FeeRateForTarget(ctx context.Context, target int, fallback float64) float64 {
	for _, i := range f.order() {
		if rate := f.sources[i].FeeRateForTarget(ctx, target, fallback); rate != fallback {
			return rate
		}
	}
	return fallback
}

// BaseURLs reports every endpoint behind this source, best first.
func (f *fallbackChainSource) BaseURLs() []string {
	var urls []string
	for _, c := range f.sources {
		sw, ok := c.(SwappableChainSource)
		if !ok {
			continue
		}
		urls = append(urls, sw.BaseURLs()...)
	}
	return urls
}

// Notifications relays the primary's push stream. Only the Electrum-protocol
// client has one, and it is the primary whenever the network publishes it. A
// primary in cooldown reports none, so the backend drops back to polling
// instead of waiting on pushes that a dead server cannot send.
func (f *fallbackChainSource) Notifications() <-chan ElectrumNotification {
	if !f.primaryReady() {
		return nil
	}
	n, ok := f.primary().(interface {
		Notifications() <-chan ElectrumNotification
	})
	if !ok {
		return nil
	}
	return n.Notifications()
}

func (f *fallbackChainSource) primaryReady() bool {
	f.mu.Lock()
	defer f.mu.Unlock()
	return len(f.sources) > 0 && !time.Now().Before(f.downUntil[0])
}

func (f *fallbackChainSource) SubscribeHeaders(ctx context.Context) (int, error) {
	sub, ok := f.primary().(interface {
		SubscribeHeaders(context.Context) (int, error)
	})
	if !ok {
		return 0, errors.New("chain source does not support subscriptions")
	}
	return sub.SubscribeHeaders(ctx)
}

func (f *fallbackChainSource) ScriptHash(address string) (string, error) {
	sh, ok := f.primary().(interface {
		ScriptHash(string) (string, error)
	})
	if !ok {
		return "", errors.New("chain source does not support subscriptions")
	}
	return sh.ScriptHash(address)
}

func (f *fallbackChainSource) Subscribe(ctx context.Context, scriptHash string) (string, error) {
	sub, ok := f.primary().(interface {
		Subscribe(context.Context, string) (string, error)
	})
	if !ok {
		return "", errors.New("chain source does not support subscriptions")
	}
	return sub.Subscribe(ctx, scriptHash)
}

func (f *fallbackChainSource) primary() ChainDataSource {
	if len(f.sources) == 0 {
		return nil
	}
	return f.sources[0]
}
