package wallet

import (
	"context"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// countingChain wraps a fake chain source and counts address lookups, so a test
// can prove a scan reached the network or stayed on stored data.
type countingChain struct {
	*fakeEsplora
	statCalls atomic.Int64
}

func (c *countingChain) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	c.statCalls.Add(1)
	return c.fakeEsplora.AddressStats(ctx, address)
}

// subscribingChain adds electrum push subscriptions, whose status hash tells a
// walk which addresses moved without asking for stats.
type subscribingChain struct {
	*countingChain
	status map[string]string
	subs   atomic.Int64
}

func (s *subscribingChain) Notifications() <-chan ElectrumNotification {
	return make(chan ElectrumNotification)
}
func (s *subscribingChain) SubscribeHeaders(context.Context) (int, error) {
	return s.tip, nil
}
func (s *subscribingChain) ScriptHash(address string) (string, error) { return "sh:" + address, nil }
func (s *subscribingChain) Subscribe(_ context.Context, scriptHash string) (string, error) {
	s.subs.Add(1)
	return s.status[scriptHash], nil
}

// A wallet the user has not opened this process must render from its stored
// scan, without a single chain request.
func TestColdLoadServesStoredScanWithoutNetwork(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}
	_, err := p.scan(ctx, w.ID, false)
	require.NoError(t, err)

	counting := &countingChain{fakeEsplora: fake}
	cold := NewElectrumBackend(p.svc, counting, p.netParams, p.log)

	scan, err := cold.scan(ctx, w.ID, true)
	require.NoError(t, err)
	require.NotEmpty(t, scan.addrs)
	assert.Zero(t, counting.statCalls.Load(), "a cold read must not touch the chain")

	cold.mu.Lock()
	tip := cold.tipAt[w.ID]
	cold.mu.Unlock()
	assert.Equal(t, fake.tip, tip, "the stored checkpoint must resume the cached tip")
}

// The checkpoint is what lets a swap resume forward instead of re-walking.
func TestScanStoresChainTipCheckpoint(t *testing.T) {
	p, fake, w, _ := newElectrumFixture(t)

	_, err := p.scan(context.Background(), w.ID, false)
	require.NoError(t, err)

	tip, ok := p.svc.loadSyncCheckpoint(p.svc.Network(), w.ID)
	require.True(t, ok)
	assert.Equal(t, fake.tip, tip)
}

// Once every address is subscribed, an unchanged wallet costs no address
// lookups: the push-maintained status hash answers "did anything move".
func TestUnchangedStatusSkipsAddressLookups(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}

	counting := &countingChain{fakeEsplora: fake}
	chain := &subscribingChain{countingChain: counting, status: map[string]string{}}
	// Every address reports a stable status, so nothing has moved between walks.
	chain.status["sh:"+addr] = "unchanged"
	p.client = chain

	_, err := p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	first := counting.statCalls.Load()
	require.Positive(t, first, "the first walk has no stored status to compare")

	_, err = p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	assert.Equal(t, first, counting.statCalls.Load(), "an unchanged wallet must not re-fetch stats")
}

// A moved address must still be re-read, or a payment would never surface.
func TestChangedStatusRefetchesAddress(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	counting := &countingChain{fakeEsplora: fake}
	chain := &subscribingChain{countingChain: counting, status: map[string]string{"sh:" + addr: "before"}}
	p.client = chain

	_, err := p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	first := counting.statCalls.Load()

	chain.status["sh:"+addr] = "after"
	p.subMu.Lock()
	p.subStatus["sh:"+addr] = "after"
	p.subMu.Unlock()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 42, TxCount: 1},
	}
	_, err = p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	assert.Greater(t, counting.statCalls.Load(), first, "a changed status must re-read the address")
}

// An Esplora network has no pushes, so it must keep the short poll TTL. The
// wrapper satisfies the subscriber interface on every network, which is why
// capability is read from the notification channel rather than the type.
func TestScanTTLFollowsRealPushSupport(t *testing.T) {
	p, fake, _, _ := newElectrumFixture(t)

	p.client = fake
	assert.Equal(t, electrumPollTTL, p.scanTTL(), "a plain esplora client must poll")

	counting := &countingChain{fakeEsplora: fake}
	p.client = &subscribingChain{countingChain: counting, status: map[string]string{}}
	assert.Equal(t, electrumPushTTL, p.scanTTL(), "a real subscriber may lean on pushes")
}

// Without pushes the status probe must not run, or every address would pay for
// a subscribe the server cannot answer.
func TestStatusProbeSkippedWithoutPushes(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	p.client = fake

	_, ok := p.statusFor(context.Background(), w.ID, addr)
	assert.False(t, ok)
}

// A wallet where nothing moved still advances its checkpoint, or the catch-up
// would grow forever and every cold load would re-walk.
func TestQuietWalletAdvancesCheckpoint(t *testing.T) {
	p, fake, w, _ := newElectrumFixture(t)
	ctx := context.Background()

	_, err := p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	first, ok := p.svc.loadSyncCheckpoint(p.svc.Network(), w.ID)
	require.True(t, ok)

	fake.tip = first + 6
	_, err = p.scan(ctx, w.ID, false)
	require.NoError(t, err)

	second, ok := p.svc.loadSyncCheckpoint(p.svc.Network(), w.ID)
	require.True(t, ok)
	assert.Equal(t, fake.tip, second, "an unchanged scan must still record the new tip")
	assert.Zero(t, p.blocksBehind(ctx, p.svc.Network(), w.ID))
}
