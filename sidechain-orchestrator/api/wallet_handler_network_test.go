package api

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// swappableEsplora is a psbtTestEsplora that also satisfies
// SwappableChainSource, so the handler's runtime endpoint and proxy swaps
// commit against it without a REST server.
type swappableEsplora struct {
	*psbtTestEsplora
	urls       []string
	torEnabled bool
	torProxy   string
}

var _ wallet.SwappableChainSource = (*swappableEsplora)(nil)

func (c *swappableEsplora) BaseURLs() []string { return append([]string(nil), c.urls...) }

func (c *swappableEsplora) SetBaseURLs(urls []string) { c.urls = append([]string(nil), urls...) }

func (c *swappableEsplora) ProxyConfig() (bool, string) { return c.torEnabled, c.torProxy }

func (c *swappableEsplora) SetProxy(enabled bool, proxyAddr string) error {
	c.torEnabled, c.torProxy = enabled, proxyAddr
	return nil
}

const networkTestServerURL = "https://original.example/api"

// newNetworkHandler wires the real engine over a swappable chain source, with
// an orchestrator that has no settings store so every persist fails.
func newNetworkHandler(t *testing.T) (*WalletHandler, *swappableEsplora) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	net := &chaincfg.SigNetParams
	chain := &swappableEsplora{psbtTestEsplora: &psbtTestEsplora{}, urls: []string{networkTestServerURL}}
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)

	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetOrchestrator(&orchestrator.Orchestrator{})
	return h, chain
}

// A failed persist must not leave the wallet on an endpoint it will forget at
// the next restart: the live swap is rolled back and the error says so.
func TestSetElectrumServerRollsBackWhenPersistFails(t *testing.T) {
	h, chain := newNetworkHandler(t)

	_, err := h.SetElectrumServer(context.Background(), connect.NewRequest(&pb.SetElectrumServerRequest{
		Url: "https://new.example/api",
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "kept previous "+networkTestServerURL)

	url, uerr := h.engine.ElectrumServerURL()
	require.NoError(t, uerr)
	assert.Equal(t, networkTestServerURL, url)
	assert.Equal(t, []string{networkTestServerURL}, chain.BaseURLs())
}

func TestSetTorConfigRollsBackWhenPersistFails(t *testing.T) {
	h, chain := newNetworkHandler(t)

	_, err := h.SetTorConfig(context.Background(), connect.NewRequest(&pb.SetTorConfigRequest{
		Enabled: true,
		Proxy:   "127.0.0.1:9050",
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "kept previous (no tor)")

	enabled, proxyAddr, terr := h.engine.TorConfig()
	require.NoError(t, terr)
	assert.False(t, enabled)
	assert.Empty(t, proxyAddr)

	onChain, _ := chain.ProxyConfig()
	assert.False(t, onChain)
}
