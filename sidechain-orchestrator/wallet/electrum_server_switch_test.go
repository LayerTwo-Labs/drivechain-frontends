package wallet

import (
	"context"
	"errors"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// swappableFakeEsplora is a fakeEsplora that also satisfies SwappableChainSource, so
// SetServerURL can exercise the runtime endpoint swap. unreachableURLs marks
// endpoints whose tip probe fails, simulating a dead server.
type swappableFakeEsplora struct {
	*fakeEsplora
	urls        []string
	unreachable map[string]bool
	torEnabled  bool
	torProxy    string
	badProxies  map[string]bool
}

var _ SwappableChainSource = (*swappableFakeEsplora)(nil)

func newSwappableFakeEsplora(url string) *swappableFakeEsplora {
	return &swappableFakeEsplora{
		fakeEsplora: newFakeEsplora(),
		urls:        []string{url},
		unreachable: map[string]bool{},
		badProxies:  map[string]bool{},
	}
}

func (f *swappableFakeEsplora) BaseURLs() []string {
	return append([]string(nil), f.urls...)
}

func (f *swappableFakeEsplora) SetBaseURLs(urls []string) {
	f.urls = append([]string(nil), urls...)
}

func (f *swappableFakeEsplora) ProxyConfig() (bool, string) {
	return f.torEnabled, f.torProxy
}

func (f *swappableFakeEsplora) SetProxy(enabled bool, proxyAddr string) error {
	f.torEnabled = enabled
	f.torProxy = proxyAddr
	return nil
}

func (f *swappableFakeEsplora) TipHeight(ctx context.Context) (int, error) {
	if len(f.urls) > 0 && f.unreachable[f.urls[0]] {
		return 0, errors.New("connection refused")
	}
	if f.torEnabled && f.badProxies[f.torProxy] {
		return 0, errors.New("proxy connection refused")
	}
	return f.fakeEsplora.TipHeight(ctx)
}

func newSwitchableElectrumBackend(t *testing.T, initialURL string) (*ElectrumBackend, *swappableFakeEsplora) {
	t.Helper()
	svc := newTestService(t)
	fake := newSwappableFakeEsplora(initialURL)
	p := NewElectrumBackend(svc, fake, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
	return p, fake
}

func TestSetServerURLValidSwapsSource(t *testing.T) {
	const original = "https://original.example/api"
	p, fake := newSwitchableElectrumBackend(t, original)
	fake.tip = 222

	tip, err := p.SetServerURL(context.Background(), "https://new.example/api/")
	require.NoError(t, err)
	assert.Equal(t, 222, tip)
	assert.Equal(t, "https://new.example/api", p.ServerURL())
	assert.Equal(t, []string{"https://new.example/api"}, fake.BaseURLs())
}

func TestSetServerURLUnreachableKeepsPrevious(t *testing.T) {
	const original = "https://original.example/api"
	p, fake := newSwitchableElectrumBackend(t, original)
	fake.unreachable["https://dead.example/api"] = true

	_, err := p.SetServerURL(context.Background(), "https://dead.example/api")
	require.Error(t, err)
	assert.Equal(t, original, p.ServerURL())
	assert.Equal(t, []string{original}, fake.BaseURLs())
}

func TestSetServerURLRejectsMalformed(t *testing.T) {
	p, fake := newSwitchableElectrumBackend(t, "https://original.example/api")

	for _, bad := range []string{"", "   ", "ftp://example.com", "not a url", "https://"} {
		_, err := p.SetServerURL(context.Background(), bad)
		require.Errorf(t, err, "expected error for %q", bad)
		assert.Equal(t, "https://original.example/api", p.ServerURL())
	}
	assert.Equal(t, []string{"https://original.example/api"}, fake.BaseURLs())
}

func TestSetServerURLHonorsHTTPS(t *testing.T) {
	p, _ := newSwitchableElectrumBackend(t, "http://plain.example/api")

	_, err := p.SetServerURL(context.Background(), "https://secure.example/api")
	require.NoError(t, err)
	assert.Equal(t, "https://secure.example/api", p.ServerURL())
}
