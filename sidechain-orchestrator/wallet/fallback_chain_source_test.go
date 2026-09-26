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

func (s *stubChainSource) FeeRateForTarget(context.Context, int) (float64, error) {
	s.calls++
	if s.fee == 0 {
		return 0, errors.New("no fee estimate")
	}
	return s.fee, nil
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

// A source that cannot estimate errors, so the next source gets a turn
// instead of the wallet using a static fee.
func TestFallbackChainSourceFeeRateFallsThrough(t *testing.T) {
	fulcrum := &stubChainSource{}
	esplora := &stubChainSource{fee: 12.5}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	rate, err := f.FeeRateForTarget(context.Background(), 6)
	require.NoError(t, err)
	assert.Equal(t, 12.5, rate)
}

// A server with no fee estimate still serves reads and pushes, so the miss
// must not send the next read to the slower source.
func TestFallbackChainSourceFeeRateMissKeepsThePrimary(t *testing.T) {
	fulcrum := &stubChainSource{height: 840000}
	esplora := &stubChainSource{fee: 12.5}

	f := newFallbackChainSource([]ChainDataSource{fulcrum, esplora}, zerolog.Nop())
	_, err := f.FeeRateForTarget(context.Background(), 6)
	require.NoError(t, err)

	_, err = f.TipHeight(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 2, fulcrum.calls, "the primary must still take the next read")
}

// No source can estimate, so the read fails. A wallet must not send at a rate
// the chain never gave.
func TestFallbackChainSourceFeeRateErrorsWhenNoSourceEstimates(t *testing.T) {
	f := newFallbackChainSource([]ChainDataSource{&stubChainSource{}, &stubChainSource{}}, zerolog.Nop())
	_, err := f.FeeRateForTarget(context.Background(), 6)
	require.Error(t, err)
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

// spenderStub is a source that can name a spender. stubChainSource cannot,
// which is the Electrum case.
type spenderStub struct {
	stubChainSource
	spender string
	spent   bool
	err     error
}

func (s *spenderStub) Outspend(context.Context, string, int) (EsploraOutspend, bool, error) {
	if s.err != nil {
		return EsploraOutspend{}, false, s.err
	}
	return EsploraOutspend{Spent: s.spent, Txid: s.spender}, true, nil
}

// A network runs Fulcrum beside Esplora. The Electrum source cannot answer, so
// the walk must reach the Esplora one rather than stop at the first source.
func TestFallbackOutspendSkipsASourceThatCannotAnswer(t *testing.T) {
	electrum := &stubChainSource{}
	esplora := &spenderStub{spender: "spender-tx", spent: true}
	f := newFallbackChainSource([]ChainDataSource{electrum, esplora}, zerolog.Nop())

	out, held, err := f.Outspend(context.Background(), "abc", 0)

	require.NoError(t, err)
	require.True(t, held)
	require.Equal(t, "spender-tx", out.Txid)
	assert.Zero(t, electrum.calls, "an incapable source must not be called or marked down")
}

// The capable source failed, so the caller must see that failure. Reporting
// ErrSpenderUnknown would let a deposit take a stale treasury output as proven.
func TestFallbackOutspendReportsACapableSourceFailure(t *testing.T) {
	boom := errors.New("esplora GET /outspend: 429 Too Many Requests")
	f := newFallbackChainSource([]ChainDataSource{
		&stubChainSource{},
		&spenderStub{err: boom},
	}, zerolog.Nop())

	_, _, err := f.Outspend(context.Background(), "abc", 0)

	require.ErrorIs(t, err, boom)
	require.NotErrorIs(t, err, ErrSpenderUnknown)
}

// No source can answer, so the wallet keeps the confirmed treasury output.
func TestFallbackOutspendReportsAnUnknownSpenderWithNoCapableSource(t *testing.T) {
	f := newFallbackChainSource([]ChainDataSource{&stubChainSource{}, &stubChainSource{}}, zerolog.Nop())

	_, _, err := f.Outspend(context.Background(), "abc", 0)

	require.ErrorIs(t, err, ErrSpenderUnknown)
}

// A spend is positive evidence whichever source reports it.
func TestFallbackOutspendTakesASpendFromAnySource(t *testing.T) {
	f := newFallbackChainSource([]ChainDataSource{
		&stubChainSource{},
		&spenderStub{spent: true, spender: "spender-tx"},
	}, zerolog.Nop())

	out, _, err := f.Outspend(context.Background(), "abc", 0)

	require.NoError(t, err)
	require.Equal(t, "spender-tx", out.Txid)
}

// With no silent source ahead of it, an unspent answer is proof.
func TestFallbackOutspendTrustsAnUnspentFromThePrimary(t *testing.T) {
	f := newFallbackChainSource([]ChainDataSource{&spenderStub{spent: false}}, zerolog.Nop())

	out, held, err := f.Outspend(context.Background(), "abc", 0)

	require.NoError(t, err)
	require.True(t, held)
	require.False(t, out.Spent)
}

// The published networks put Fulcrum first, and Fulcrum never answers an
// outspend. A verified unspent from Esplora must let the deposit through, or
// every deposit after the first one on a slot is refused.
func TestFallbackOutspendTakesAVerifiedUnspentBehindASilentSource(t *testing.T) {
	f := newFallbackChainSource([]ChainDataSource{
		&stubChainSource{},
		&spenderStub{spent: false},
	}, zerolog.Nop())

	out, held, err := f.Outspend(context.Background(), "abc", 0)

	require.NoError(t, err)
	require.True(t, held)
	require.False(t, out.Spent)
}
