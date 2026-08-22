package engines

import (
	"context"
	"sync/atomic"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// countingChain answers every chain read from empty state and counts address
// lookups, so a test can tell a warm read from one that hit the network.
type countingChain struct {
	statCalls atomic.Int64
}

var _ wallet.ChainDataSource = (*countingChain)(nil)

func (c *countingChain) AddressStats(_ context.Context, address string) (wallet.EsploraAddressStats, error) {
	c.statCalls.Add(1)
	return wallet.EsploraAddressStats{Address: address}, nil
}
func (c *countingChain) AddressUTXOs(context.Context, string) ([]wallet.EsploraUTXO, error) {
	return nil, nil
}
func (c *countingChain) AddressTxs(context.Context, string) ([]wallet.EsploraTx, error) {
	return nil, nil
}
func (c *countingChain) Tx(context.Context, string) (wallet.EsploraTx, error) {
	return wallet.EsploraTx{}, nil
}
func (c *countingChain) TxHex(context.Context, string) (string, error)     { return "", nil }
func (c *countingChain) Broadcast(context.Context, string) (string, error) { return "", nil }
func (c *countingChain) TipHeight(context.Context) (int, error)            { return 110, nil }
func (c *countingChain) FeeRateForTarget(_ context.Context, _ int, fallback float64) float64 {
	return fallback
}

func newSyncFixture(t *testing.T) (*WalletSyncEngine, *wallet.Service, *wallet.WalletEngine, *countingChain) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))

	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)

	chain := &countingChain{}
	params := wallet.StaticParams(&chaincfg.SigNetParams)
	backend := wallet.NewElectrumBackend(svc, chain, params, log)
	router := wallet.NewBackendRouter(svc, nil, backend)
	engine := wallet.NewWalletEngine(svc, router, params, log)

	return NewWalletSyncEngine(log, svc, engine), svc, engine, chain
}

func createElectrumWallet(t *testing.T, svc *wallet.Service, name string) *wallet.WalletData {
	t.Helper()
	w, err := svc.CreateElectrumWallet(name, nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	return w
}

// The point of the engine: a wallet the user is not looking at is already
// scanned, so switching to it serves stored data instead of a fresh walk.
func TestTickWarmsWalletsBehindTheActiveOne(t *testing.T) {
	sync, svc, engine, chain := newSyncFixture(t)
	ctx := context.Background()

	active := createElectrumWallet(t, svc, "Active")
	background := createElectrumWallet(t, svc, "Background")
	require.NoError(t, svc.SwitchWallet(active.ID))

	sync.tick(ctx)
	require.Positive(t, chain.statCalls.Load(), "the pass must scan both wallets")

	afterTick := chain.statCalls.Load()
	_, _, err := engine.Backend().Balance(ctx, background.ID)
	require.NoError(t, err)

	assert.Equal(t, afterTick, chain.statCalls.Load(),
		"reading the wallet behind the active one must be served from the warm scan")
}

// The wallet on screen must not queue behind the others.
func TestOrderedWalletsPutsTheActiveWalletFirst(t *testing.T) {
	sync, svc, _, _ := newSyncFixture(t)

	createElectrumWallet(t, svc, "First")
	second := createElectrumWallet(t, svc, "Second")
	require.NoError(t, svc.SwitchWallet(second.ID))

	ids := sync.orderedWallets()
	require.Len(t, ids, 2)
	assert.Equal(t, second.ID, ids[0])
}

func TestTickWithoutWalletsDoesNothing(t *testing.T) {
	sync, _, _, chain := newSyncFixture(t)

	sync.tick(context.Background())

	assert.Zero(t, chain.statCalls.Load())
}
