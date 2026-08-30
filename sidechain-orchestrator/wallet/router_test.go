package wallet

import (
	"context"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeBackend records which walletIDs reached it. Unimplemented Backend
// methods panic via the embedded nil interface.
type fakeBackend struct {
	Backend
	name  string
	calls []string
}

func (f *fakeBackend) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	f.calls = append(f.calls, "Balance:"+walletID)
	return 1, 2, nil
}

func (f *fakeBackend) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	f.calls = append(f.calls, "Send:"+walletID)
	return "txid-" + f.name, nil
}

func (f *fakeBackend) EnsureAll(ctx context.Context) (int, error) {
	f.calls = append(f.calls, "EnsureAll")
	return 7, nil
}

func (f *fakeBackend) Chain() ChainSource {
	return unavailableChain{reason: "fake " + f.name}
}

// newRouterFixture builds a Service holding two bitcoinCore wallets — the type
// every generated wallet gets — plus the chain and electrum fakes.
func newRouterFixture(t *testing.T) (*BackendRouter, *fakeBackend, *fakeBackend, string, string) {
	t.Helper()
	svc := newTestService(t)

	first, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeBitcoinCore, first.WalletType)

	second, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeBitcoinCore, second.WalletType)

	elecFake := &fakeBackend{name: "electrum"}
	chainFake := &fakeBackend{name: "chain"}
	return NewBackendRouter(svc, chainFake, elecFake), elecFake, chainFake, first.ID, second.ID
}

func TestBackendRouterDispatchesByWalletType(t *testing.T) {
	router, elecFake, chainFake, firstID, secondID := newRouterFixture(t)
	ctx := context.Background()

	_, _, err := router.Balance(ctx, firstID)
	require.NoError(t, err)
	_, err = router.Send(ctx, secondID, SendRequest{})
	require.NoError(t, err)

	// Both are bitcoinCore, so the chain backend takes both calls and the
	// electrum fake stays untouched.
	assert.Equal(t, []string{"Balance:" + firstID, "Send:" + secondID}, chainFake.calls)
	assert.Empty(t, elecFake.calls)
}

func TestBackendRouterUnknownWallet(t *testing.T) {
	router, _, _, _, _ := newRouterFixture(t)

	_, _, err := router.Balance(context.Background(), "nope")
	require.ErrorContains(t, err, "not found")
}

func TestBackendRouterMissingSides(t *testing.T) {
	svc := newTestService(t)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)

	elec, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, elec.WalletType)

	router := NewBackendRouter(svc, nil, nil)
	ctx := context.Background()

	_, _, err = router.Balance(ctx, core.ID)
	require.ErrorContains(t, err, "bitcoin Core RPC not configured")
	_, _, err = router.Balance(ctx, elec.ID)
	require.ErrorContains(t, err, "electrum wallet backend not configured")

	_, err = router.Chain().Broadcast(ctx, "00")
	require.ErrorContains(t, err, "no chain source configured")

	// EnsureAll without a chain backend is a no-op, not an error.
	n, err := router.EnsureAll(ctx)
	require.NoError(t, err)
	assert.Equal(t, 0, n)
}

func TestBackendRouterEnsureAllOnlyChain(t *testing.T) {
	router, enfFake, chainFake, _, _ := newRouterFixture(t)

	n, err := router.EnsureAll(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 7, n)
	assert.Equal(t, []string{"EnsureAll"}, chainFake.calls)
	assert.Empty(t, enfFake.calls)
}

// Regtest publishes no chain source, so an electrum wallet there has no
// backend at all. The pollers read Bip47BackendFor and skip the wallet
// instead of failing on every tick.
func TestBackendRouterRefusesElectrumWithoutChainSource(t *testing.T) {
	svc := newTestService(t)
	elec, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	log := zerolog.New(zerolog.NewTestWriter(t))
	params := StaticParams(&chaincfg.RegressionNetParams)
	source := NewNetworkChainSource(func() ChainTarget {
		return ChainTarget{Network: "regtest", Params: params()}
	}, log)
	router := NewBackendRouter(svc, nil, NewElectrumBackend(svc, source, params, log))

	_, _, err = router.Balance(context.Background(), elec.ID)
	require.ErrorContains(t, err, "has no chain source on this network")

	_, ok := router.Bip47BackendFor(elec.ID)
	assert.False(t, ok)
}
