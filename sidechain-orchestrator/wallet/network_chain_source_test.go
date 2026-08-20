package wallet

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// esploraStub counts address lookups so a test can prove which network's
// server actually served a read.
type esploraStub struct {
	*httptest.Server
	hits atomic.Int64
}

func newEsploraStub(t *testing.T, funded int64) *esploraStub {
	t.Helper()
	s := &esploraStub{}
	s.Server = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		s.hits.Add(1)
		_ = json.NewEncoder(w).Encode(EsploraAddressStats{
			Address:    "addr",
			ChainStats: EsploraTxoStats{FundedTxoSum: funded, TxCount: 1},
		})
	}))
	t.Cleanup(s.Close)
	return s
}

// networkVar is a resolver backed by a network the test can flip, standing in
// for the orchestrator's live network.
type networkVar struct {
	mu      sync.Mutex
	network string
	urls    map[string][]string
	params  map[string]*chaincfg.Params
}

func (n *networkVar) set(network string) {
	n.mu.Lock()
	n.network = network
	n.mu.Unlock()
}

func (n *networkVar) resolve() ChainTarget {
	n.mu.Lock()
	defer n.mu.Unlock()
	return ChainTarget{Network: n.network, URLs: n.urls[n.network], Params: n.params[n.network]}
}

// TestNetworkChainSource_FollowsNetworkSwap is the regression for a wallet
// swapped eCash -> mainnet still reading eCash's Esplora, so balances read 0.
func TestNetworkChainSource_FollowsNetworkSwap(t *testing.T) {
	ecash := newEsploraStub(t, 111)
	mainnet := newEsploraStub(t, 222)

	nv := &networkVar{
		network: "ecash",
		urls: map[string][]string{
			"ecash":   {ecash.URL},
			"mainnet": {mainnet.URL},
		},
		params: map[string]*chaincfg.Params{
			"ecash":   &chaincfg.MainNetParams,
			"mainnet": &chaincfg.MainNetParams,
		},
	}

	src := NewNetworkChainSource(nv.resolve, zerolog.Nop())

	ctx := context.Background()

	stats, err := src.AddressStats(ctx, "bc1qtest")
	require.NoError(t, err)
	assert.EqualValues(t, 111, stats.ChainStats.FundedTxoSum, "read must come from eCash before the swap")
	assert.EqualValues(t, 1, ecash.hits.Load())
	assert.EqualValues(t, 0, mainnet.hits.Load())

	nv.set("mainnet")

	stats, err = src.AddressStats(ctx, "bc1qtest")
	require.NoError(t, err)
	assert.EqualValues(t, 222, stats.ChainStats.FundedTxoSum, "read must follow the swap to mainnet")
	assert.EqualValues(t, 1, ecash.hits.Load(), "eCash must not be queried after the swap")
	assert.EqualValues(t, 1, mainnet.hits.Load())
}

// TestNetworkChainSource_SwitchesProtocolClass covers eCash (https Esplora) to
// mainnet (ssl Electrum), where the scheme selects a different client.
func TestNetworkChainSource_SwitchesProtocolClass(t *testing.T) {
	nv := &networkVar{
		network: "ecash",
		urls: map[string][]string{
			"ecash":   {"https://esplora.drynet3.drivechain.dev"},
			"mainnet": {"ssl://explorer.mainnet.drivechain.info:50002"},
		},
		params: map[string]*chaincfg.Params{
			"ecash":   &chaincfg.MainNetParams,
			"mainnet": &chaincfg.MainNetParams,
		},
	}
	src := NewNetworkChainSource(nv.resolve, zerolog.Nop())

	assert.Equal(t, []string{"https://esplora.drynet3.drivechain.dev"}, src.BaseURLs())

	nv.set("mainnet")
	assert.Equal(t, []string{"ssl://explorer.mainnet.drivechain.info:50002"}, src.BaseURLs())

	nv.set("ecash")
	assert.Equal(t, []string{"https://esplora.drynet3.drivechain.dev"}, src.BaseURLs())
}

// TestNetworkChainSource_DropsPinOnSwap covers a user-chosen endpoint: it must
// not survive into a network it was never chosen for.
func TestNetworkChainSource_DropsPinOnSwap(t *testing.T) {
	ecash := newEsploraStub(t, 111)
	mainnet := newEsploraStub(t, 222)
	pinned := newEsploraStub(t, 333)

	nv := &networkVar{
		network: "ecash",
		urls: map[string][]string{
			"ecash":   {ecash.URL},
			"mainnet": {mainnet.URL},
		},
		params: map[string]*chaincfg.Params{
			"ecash":   &chaincfg.MainNetParams,
			"mainnet": &chaincfg.MainNetParams,
		},
	}
	src := NewNetworkChainSource(nv.resolve, zerolog.Nop())

	src.SetBaseURLs([]string{pinned.URL})
	stats, err := src.AddressStats(context.Background(), "bc1qtest")
	require.NoError(t, err)
	assert.EqualValues(t, 333, stats.ChainStats.FundedTxoSum, "pin applies on the network it was set for")

	nv.set("mainnet")
	stats, err = src.AddressStats(context.Background(), "bc1qtest")
	require.NoError(t, err)
	assert.EqualValues(t, 222, stats.ChainStats.FundedTxoSum, "pin must not carry into the new network")
}

// TestNetworkChainSource_UnsupportedNetwork covers a network with no wallet
// chain source: reads must error rather than serve the old network's data.
func TestNetworkChainSource_UnsupportedNetwork(t *testing.T) {
	ecash := newEsploraStub(t, 111)
	nv := &networkVar{
		network: "ecash",
		urls:    map[string][]string{"ecash": {ecash.URL}, "regtest": nil},
		params:  map[string]*chaincfg.Params{"ecash": &chaincfg.MainNetParams},
	}
	src := NewNetworkChainSource(nv.resolve, zerolog.Nop())

	_, err := src.AddressStats(context.Background(), "bc1qtest")
	require.NoError(t, err)
	assert.True(t, src.Available())

	nv.set("regtest")
	_, err = src.AddressStats(context.Background(), "bc1qtest")
	require.Error(t, err)
	assert.False(t, src.Available())
	assert.EqualValues(t, 1, ecash.hits.Load(), "must not fall back to the previous network")
}

// TestElectrumBackend_DropsCachesOnNetworkSwap covers per-wallet cached scans,
// which would otherwise serve the old network's balance under the new one.
func TestElectrumBackend_DropsCachesOnNetworkSwap(t *testing.T) {
	ecash := newEsploraStub(t, 111)
	mainnet := newEsploraStub(t, 222)
	nv := &networkVar{
		network: "ecash",
		urls:    map[string][]string{"ecash": {ecash.URL}, "mainnet": {mainnet.URL}},
		params:  map[string]*chaincfg.Params{"ecash": &chaincfg.MainNetParams, "mainnet": &chaincfg.MainNetParams},
	}
	src := NewNetworkChainSource(nv.resolve, zerolog.Nop())
	backend := NewElectrumBackend(nil, src, StaticParams(&chaincfg.MainNetParams), zerolog.Nop())

	_, err := src.AddressStats(context.Background(), "bc1qtest")
	require.NoError(t, err)

	backend.mu.Lock()
	backend.warm["w1"] = true
	backend.warmScan["w1"] = &electrumScan{}
	backend.tipAt["w1"] = 900000
	backend.mu.Unlock()

	nv.set("mainnet")
	backend.ResetNetworkState()

	backend.mu.Lock()
	defer backend.mu.Unlock()
	assert.Empty(t, backend.warmScan, "cached scan from eCash must not survive the swap")
	assert.Empty(t, backend.warm)
	assert.Empty(t, backend.tipAt)
}

// A switch fired from inside TipHeight cannot revoke a scan the caller already
// checked out, so without the generation stamp cachedScan serves the outgoing
// chain's UTXOs on both the error path and the equal-height path.
func TestCachedScanRejectsScanCheckedOutBeforeSwitch(t *testing.T) {
	for _, tc := range []struct {
		name string
		tip  int
		err  error
	}{
		{name: "tip lookup fails", err: assert.AnError},
		{name: "networks report the same height", tip: 900000},
	} {
		t.Run(tc.name, func(t *testing.T) {
			backend := NewElectrumBackend(nil, nil, StaticParams(&chaincfg.MainNetParams), zerolog.Nop())
			client := &switchOnTipClient{tip: tc.tip, err: tc.err}
			client.onTip = backend.ResetNetworkState
			backend.client = client

			backend.mu.Lock()
			backend.warmScan["w1"] = &electrumScan{}
			backend.tipAt["w1"] = 900000
			backend.scanAt["w1"] = time.Now()
			backend.mu.Unlock()

			got := backend.cachedScan(context.Background(), "w1")
			assert.Nil(t, got, "a scan checked out before the switch must not be served")
		})
	}
}

// switchOnTipClient switches networks from inside a chain read, the window the
// generation stamp exists to close. onTip fires from TipHeight, onStats from
// the address walk.
type switchOnTipClient struct {
	onTip   func()
	onStats func()
	once    sync.Once
	tip     int
	err     error
}

func (c *switchOnTipClient) TipHeight(context.Context) (int, error) {
	if c.onTip != nil {
		c.onTip()
	}
	return c.tip, c.err
}

func (c *switchOnTipClient) AddressStats(context.Context, string) (EsploraAddressStats, error) {
	if c.onStats != nil {
		c.once.Do(c.onStats)
	}
	return EsploraAddressStats{}, nil
}

func (c *switchOnTipClient) AddressUTXOs(context.Context, string) ([]EsploraUTXO, error) {
	return nil, nil
}
func (c *switchOnTipClient) AddressTxs(context.Context, string) ([]EsploraTx, error) {
	return nil, nil
}
func (c *switchOnTipClient) Tx(context.Context, string) (EsploraTx, error)     { return EsploraTx{}, nil }
func (c *switchOnTipClient) TxHex(context.Context, string) (string, error)     { return "", nil }
func (c *switchOnTipClient) Broadcast(context.Context, string) (string, error) { return "", nil }
func (c *switchOnTipClient) FeeRateForTarget(_ context.Context, _ int, fallback float64) float64 {
	return fallback
}

// consumerOnce bound to the first client meant an Esplora-first process could
// never consume Electrum pushes after switching.
func TestNotificationConsumerRebindsAcrossProtocolSwitch(t *testing.T) {
	backend := NewElectrumBackend(nil, nil, StaticParams(&chaincfg.MainNetParams), zerolog.Nop())

	backend.startNotificationConsumer(stubSubscriber{})
	backend.subMu.Lock()
	spent := backend.consumerCh
	backend.subMu.Unlock()
	require.Nil(t, spent, "a non-subscribing client must not bind the consumer")

	live := make(chan ElectrumNotification)
	backend.startNotificationConsumer(stubSubscriber{ch: live})
	backend.subMu.Lock()
	bound := backend.consumerCh
	backend.subMu.Unlock()
	require.NotNil(t, bound, "switching to an electrum client must start the consumer")
}

type stubSubscriber struct{ ch chan ElectrumNotification }

func (s stubSubscriber) Notifications() <-chan ElectrumNotification {
	if s.ch == nil {
		return nil
	}
	return s.ch
}
func (s stubSubscriber) SubscribeHeaders(context.Context) (int, error)     { return 0, nil }
func (s stubSubscriber) ScriptHash(string) (string, error)                 { return "", nil }
func (s stubSubscriber) Subscribe(context.Context, string) (string, error) { return "", nil }

// A switch part-way through the address walk must not persist, cache or return
// a scan assembled against the outgoing chain.
func TestScanRejectsResultWhenNetworkSwitchesMidWalk(t *testing.T) {
	svc := newTestService(t)
	w, err := svc.GenerateWallet("Electrum", "", "", testSlots)
	require.NoError(t, err)

	backend := NewElectrumBackend(svc, nil, StaticParams(&chaincfg.MainNetParams), zerolog.Nop())
	// Switching from inside the walk is what the generation stamp has to catch.
	backend.client = &switchOnTipClient{onStats: backend.ResetNetworkState}

	scan, err := backend.scan(context.Background(), w.ID, false)
	require.Error(t, err, "a scan spanning a network switch must not be returned")
	assert.Nil(t, scan)
	assert.Contains(t, err.Error(), "network changed during scan")

	backend.mu.Lock()
	_, cached := backend.warmScan[w.ID]
	warm := backend.warm[w.ID]
	backend.mu.Unlock()
	assert.False(t, cached, "a scan from the outgoing chain must not be cached")
	assert.False(t, warm, "the wallet must not be marked warm off a rejected scan")

	_, persisted := svc.loadElectrumScan(svc.Network(), w.ID)
	assert.False(t, persisted, "a rejected scan must not reach disk")
}
