package wallet

import (
	"context"
	"testing"

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

// newRouterFixture builds a Service holding an enforcer wallet (first) and a
// bitcoinCore wallet (second) — the real type-assignment logic — plus fakes.
func newRouterFixture(t *testing.T) (*BackendRouter, *fakeBackend, *fakeBackend, string, string) {
	t.Helper()
	svc := newTestService(t)

	enf, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeEnforcer, enf.WalletType)

	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeBitcoinCore, core.WalletType)

	enfFake := &fakeBackend{name: "enforcer"}
	chainFake := &fakeBackend{name: "chain"}
	return NewBackendRouter(svc, enfFake, chainFake, nil), enfFake, chainFake, enf.ID, core.ID
}

func TestBackendRouterDispatchesByWalletType(t *testing.T) {
	router, enfFake, chainFake, enfID, coreID := newRouterFixture(t)
	ctx := context.Background()

	_, _, err := router.Balance(ctx, enfID)
	require.NoError(t, err)
	_, err = router.Send(ctx, coreID, SendRequest{})
	require.NoError(t, err)

	assert.Equal(t, []string{"Balance:" + enfID}, enfFake.calls)
	assert.Equal(t, []string{"Send:" + coreID}, chainFake.calls)
}

func TestBackendRouterUnknownWallet(t *testing.T) {
	router, _, _, _, _ := newRouterFixture(t)

	_, _, err := router.Balance(context.Background(), "nope")
	require.ErrorContains(t, err, "not found")
}

func TestBackendRouterMissingSides(t *testing.T) {
	svc := newTestService(t)
	enf, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)

	elec, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, elec.WalletType)

	router := NewBackendRouter(svc, nil, nil, nil)
	ctx := context.Background()

	_, _, err = router.Balance(ctx, enf.ID)
	require.ErrorContains(t, err, "enforcer wallet client not connected")
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
