package wallet

import (
	"context"
	"fmt"
	"strings"
	"sync"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

// ChainTarget is where the wallet reads chain data for one network: the
// endpoint list, primary first, and the params its keys derive under.
type ChainTarget struct {
	Network string
	URLs    []string
	Params  *chaincfg.Params
}

// ChainTargetResolver reports the target for the current network. Called on
// every chain read, so it must be cheap and safe for concurrent use.
type ChainTargetResolver func() ChainTarget

// ParamsSource is a ChainDataSource that reports the params of the network it
// is currently pointed at.
type ParamsSource interface {
	Params() *chaincfg.Params
}

// NetworkChainSource resolves its endpoint on every call instead of capturing
// one at construction, so a network swap applies without a restart.
type NetworkChainSource struct {
	resolve ChainTargetResolver
	log     zerolog.Logger

	mu      sync.Mutex
	network string
	params  *chaincfg.Params
	pinned  []string
	clients map[string]ChainDataSource

	proxyOn   bool
	proxyAddr string

	onNetworkSwitch func()
}

var (
	_ ChainDataSource      = (*NetworkChainSource)(nil)
	_ SwappableChainSource = (*NetworkChainSource)(nil)
	_ ParamsSource         = (*NetworkChainSource)(nil)
	// subscribeScan matches on interface, so losing this drops electrum
	// wallets to polling instead of ~1s push updates.
	_ electrumSubscriber = (*NetworkChainSource)(nil)
)

func NewNetworkChainSource(resolve ChainTargetResolver, log zerolog.Logger) *NetworkChainSource {
	return &NetworkChainSource{
		resolve: resolve,
		log:     log.With().Str("component", "network-chain-source").Logger(),
		clients: make(map[string]ChainDataSource),
	}
}

// SetOnNetworkSwitch registers a callback fired once per network change, so
// callers can drop chain state cached against the previous network.
func (s *NetworkChainSource) SetOnNetworkSwitch(fn func()) {
	s.mu.Lock()
	s.onNetworkSwitch = fn
	s.mu.Unlock()
}

func electrumScheme(url string) bool {
	return strings.HasPrefix(url, "ssl://") || strings.HasPrefix(url, "tcp://")
}

// current returns the client for the network resolved right now, re-pointing
// or building it when the endpoint changed since the last call.
func (s *NetworkChainSource) current() (ChainDataSource, error) {
	target := s.resolve()

	s.mu.Lock()
	var switched func()
	if target.Network != s.network {
		// First resolve is initialisation, not a switch: nothing was cached
		// against a previous network and any pin was set moments ago.
		if s.network != "" {
			s.pinned = nil
			switched = s.onNetworkSwitch
		}
		s.network = target.Network
	}
	s.params = target.Params

	urls := target.URLs
	if len(s.pinned) > 0 {
		urls = s.pinned
	}
	if len(urls) == 0 {
		s.mu.Unlock()
		if switched != nil {
			switched()
		}
		return nil, fmt.Errorf("no wallet chain source for network %q", target.Network)
	}

	// One client per protocol class, re-pointed rather than replaced: an
	// abandoned ElectrumClient's keepalive goroutine reconnects forever.
	class := "esplora"
	if electrumScheme(urls[0]) {
		class = "electrum"
	}
	client, ok := s.clients[class]
	if !ok {
		client = NewChainDataSource(urls, s.log, target.Params)
		if s.proxyOn {
			if sw, isSwappable := client.(SwappableChainSource); isSwappable {
				if err := sw.SetProxy(true, s.proxyAddr); err != nil {
					s.mu.Unlock()
					return nil, fmt.Errorf("apply proxy to %s chain source: %w", class, err)
				}
			}
		}
		s.clients[class] = client
		s.log.Info().Str("network", target.Network).Strs("urls", urls).Msg("chain source built")
	} else {
		if sw, isSwappable := client.(SwappableChainSource); isSwappable && !sameURLs(sw.BaseURLs(), urls) {
			sw.SetBaseURLs(urls)
			s.log.Info().Str("network", target.Network).Strs("urls", urls).Msg("chain source re-pointed")
		}
		if en, canSetNetwork := client.(interface{ SetNetwork(*chaincfg.Params) }); canSetNetwork {
			en.SetNetwork(target.Params)
		}
	}
	s.mu.Unlock()

	if switched != nil {
		switched()
	}
	return client, nil
}

// sameURLs compares endpoint lists ignoring a trailing slash, which
// EsploraClient trims on the way in.
func sameURLs(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if strings.TrimRight(a[i], "/") != strings.TrimRight(b[i], "/") {
			return false
		}
	}
	return true
}

// Available reports whether the currently resolved network has a chain source.
func (s *NetworkChainSource) Available() bool {
	_, err := s.current()
	return err == nil
}

// Params reports the params of the currently resolved network.
func (s *NetworkChainSource) Params() *chaincfg.Params {
	if _, err := s.current(); err != nil {
		s.log.Debug().Err(err).Msg("params requested with no chain source")
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.params
}

func (s *NetworkChainSource) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	c, err := s.current()
	if err != nil {
		return EsploraAddressStats{}, err
	}
	return c.AddressStats(ctx, address)
}

func (s *NetworkChainSource) AddressUTXOs(ctx context.Context, address string) ([]EsploraUTXO, error) {
	c, err := s.current()
	if err != nil {
		return nil, err
	}
	return c.AddressUTXOs(ctx, address)
}

func (s *NetworkChainSource) AddressTxs(ctx context.Context, address string) ([]EsploraTx, error) {
	c, err := s.current()
	if err != nil {
		return nil, err
	}
	return c.AddressTxs(ctx, address)
}

func (s *NetworkChainSource) Tx(ctx context.Context, txid string) (EsploraTx, error) {
	c, err := s.current()
	if err != nil {
		return EsploraTx{}, err
	}
	return c.Tx(ctx, txid)
}

func (s *NetworkChainSource) TxHex(ctx context.Context, txid string) (string, error) {
	c, err := s.current()
	if err != nil {
		return "", err
	}
	return c.TxHex(ctx, txid)
}

func (s *NetworkChainSource) Broadcast(ctx context.Context, rawHex string) (string, error) {
	c, err := s.current()
	if err != nil {
		return "", err
	}
	return c.Broadcast(ctx, rawHex)
}

func (s *NetworkChainSource) TipHeight(ctx context.Context) (int, error) {
	c, err := s.current()
	if err != nil {
		return 0, err
	}
	return c.TipHeight(ctx)
}

func (s *NetworkChainSource) FeeRateForTarget(ctx context.Context, target int, fallback float64) float64 {
	c, err := s.current()
	if err != nil {
		return fallback
	}
	return c.FeeRateForTarget(ctx, target, fallback)
}

// Notifications relays the active client's push stream when it has one.
func (s *NetworkChainSource) Notifications() <-chan ElectrumNotification {
	c, err := s.current()
	if err != nil {
		return nil
	}
	n, ok := c.(interface {
		Notifications() <-chan ElectrumNotification
	})
	if !ok {
		return nil
	}
	return n.Notifications()
}

// SubscribeHeaders registers for new-block pushes on the active client.
func (s *NetworkChainSource) SubscribeHeaders(ctx context.Context) (int, error) {
	c, err := s.current()
	if err != nil {
		return 0, err
	}
	sub, ok := c.(interface {
		SubscribeHeaders(context.Context) (int, error)
	})
	if !ok {
		return 0, fmt.Errorf("chain source does not support subscriptions")
	}
	return sub.SubscribeHeaders(ctx)
}

// ScriptHash returns the active client's scripthash for an address.
func (s *NetworkChainSource) ScriptHash(address string) (string, error) {
	c, err := s.current()
	if err != nil {
		return "", err
	}
	sh, ok := c.(interface {
		ScriptHash(string) (string, error)
	})
	if !ok {
		return "", fmt.Errorf("chain source does not support subscriptions")
	}
	return sh.ScriptHash(address)
}

// Subscribe registers for a scripthash's pushes on the active client.
func (s *NetworkChainSource) Subscribe(ctx context.Context, scriptHash string) (string, error) {
	c, err := s.current()
	if err != nil {
		return "", err
	}
	sub, ok := c.(interface {
		Subscribe(context.Context, string) (string, error)
	})
	if !ok {
		return "", fmt.Errorf("chain source does not support subscriptions")
	}
	return sub.Subscribe(ctx, scriptHash)
}

func (s *NetworkChainSource) BaseURLs() []string {
	c, err := s.current()
	if err != nil {
		return nil
	}
	sw, ok := c.(SwappableChainSource)
	if !ok {
		return nil
	}
	return sw.BaseURLs()
}

// SetBaseURLs pins an endpoint over the network default, dropped on the next
// network change.
func (s *NetworkChainSource) SetBaseURLs(urls []string) {
	s.mu.Lock()
	s.pinned = append([]string(nil), urls...)
	s.mu.Unlock()
	if _, err := s.current(); err != nil {
		s.log.Warn().Err(err).Msg("pinned chain source unavailable")
	}
}

func (s *NetworkChainSource) ProxyConfig() (bool, string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.proxyOn, s.proxyAddr
}

// SetProxy applies to every client, so a network swap cannot silently drop Tor
// routing.
func (s *NetworkChainSource) SetProxy(enabled bool, proxyAddr string) error {
	s.mu.Lock()
	s.proxyOn = enabled
	s.proxyAddr = proxyAddr
	clients := make([]ChainDataSource, 0, len(s.clients))
	for _, c := range s.clients {
		clients = append(clients, c)
	}
	s.mu.Unlock()

	for _, c := range clients {
		sw, ok := c.(SwappableChainSource)
		if !ok {
			continue
		}
		if err := sw.SetProxy(enabled, proxyAddr); err != nil {
			return err
		}
	}
	return nil
}
