package wallet

import (
	"context"
	"errors"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// stubChainSource answers every read with one canned height, or fails.
type stubChainSource struct {
	height int
	err    error
	calls  int
	fee    float64
}

func (s *stubChainSource) AddressStats(context.Context, string) (EsploraAddressStats, error) {
	s.calls++
	return EsploraAddressStats{}, s.err
}

func (s *stubChainSource) AddressUTXOs(context.Context, string) ([]EsploraUTXO, error) {
	s.calls++
	return nil, s.err
}

func (s *stubChainSource) AddressTxs(context.Context, string) ([]EsploraTx, error) {
	s.calls++
	return nil, s.err
}

func (s *stubChainSource) Tx(context.Context, string) (EsploraTx, error) {
	s.calls++
	return EsploraTx{}, s.err
}

func (s *stubChainSource) TxHex(context.Context, string) (string, error) {
	s.calls++
	return "", s.err
}

func (s *stubChainSource) Broadcast(context.Context, string) (string, error) {
	s.calls++
	return "", s.err
}

func (s *stubChainSource) TipHeight(context.Context) (int, error) {
	s.calls++
	if s.err != nil {
		return 0, s.err
	}
	return s.height, nil
}

func (s *stubChainSource) FeeRateForTarget(_ context.Context, _ int, fallback float64) float64 {
	s.calls++
	if s.fee == 0 {
		return fallback
	}
	return s.fee
}

// A dead Fulcrum server must not stop the wallet: the next source serves.
func TestFallbackChainSourceUsesTheNextSourceOnAFailure(t *testing.T) {
	fulcrum := &stubChainSource{err: errors.New("connection refused")}
	esplora := &stubChainSource{height: 840000}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	height, err := f.TipHeight(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 840000, height)
	assert.Equal(t, 1, fulcrum.calls)
	assert.Equal(t, 1, esplora.calls)
}

// The primary answers, so the fallback stays untouched.
func TestFallbackChainSourceStopsAtTheFirstSuccess(t *testing.T) {
	fulcrum := &stubChainSource{height: 840000}
	esplora := &stubChainSource{height: 1}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	height, err := f.TipHeight(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 840000, height)
	assert.Equal(t, 0, esplora.calls)
}

// Every read paying the dead server's connect timeout is what the cooldown
// prevents, so the second read must go straight to the working source.
func TestFallbackChainSourceSkipsAFailedSourceForTheCooldown(t *testing.T) {
	fulcrum := &stubChainSource{err: errors.New("connection refused")}
	esplora := &stubChainSource{height: 840000}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	_, err := f.TipHeight(context.Background())
	require.NoError(t, err)
	_, err = f.TipHeight(context.Background())
	require.NoError(t, err)

	assert.Equal(t, 1, fulcrum.calls, "the cooled-down source must not be dialled again")
	assert.Equal(t, 2, esplora.calls)
}

// All sources down is a real error, and it must carry every cause.
func TestFallbackChainSourceReportsEverySourceFailure(t *testing.T) {
	first := &stubChainSource{err: errors.New("fulcrum down")}
	second := &stubChainSource{err: errors.New("esplora down")}

	f := newFallbackChainSource([]ChainDataSource{first, second}, zerolog.Nop())
	_, err := f.TipHeight(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "fulcrum down")
	assert.Contains(t, err.Error(), "esplora down")
}

// A source that cannot estimate hands back the caller's own fallback, so the
// next source gets a turn instead of the wallet using a static fee.
func TestFallbackChainSourceFeeRateFallsThrough(t *testing.T) {
	fulcrum := &stubChainSource{}
	esplora := &stubChainSource{fee: 12.5}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	assert.Equal(t, 12.5, f.FeeRateForTarget(context.Background(), 6, 1))
}

// A cancelled read must stop, not walk the whole source list.
func TestFallbackChainSourceObeysAContextCancel(t *testing.T) {
	source := &stubChainSource{height: 1}
	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	f := newFallbackChainSource([]ChainDataSource{source}, zerolog.Nop())
	_, err := f.TipHeight(ctx)
	require.ErrorIs(t, err, context.Canceled)
	assert.Equal(t, 0, source.calls)
}

// notifyingStub is a source with an Electrum-style push channel.
type notifyingStub struct {
	stubChainSource
	ch chan ElectrumNotification
}

func (s *notifyingStub) Notifications() <-chan ElectrumNotification { return s.ch }

// A dead primary sends no pushes, so the backend must see none and go back to
// polling rather than wait on a silent channel.
func TestFallbackChainSourceDropsPushesWhileThePrimaryIsDown(t *testing.T) {
	fulcrum := &notifyingStub{
		stubChainSource: stubChainSource{err: errors.New("connection refused")},
		ch:              make(chan ElectrumNotification),
	}
	esplora := &stubChainSource{height: 840000}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	assert.NotNil(t, f.Notifications(), "a healthy primary must offer its push stream")

	_, err := f.TipHeight(context.Background())
	require.NoError(t, err)
	assert.Nil(t, f.Notifications(), "a cooled-down primary must offer no push stream")
}
