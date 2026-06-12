package wallet

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeProvider records which walletIDs reached it. Unimplemented Provider
// methods panic via the embedded nil interface.
type fakeProvider struct {
	Provider
	name  string
	calls []string
}

func (f *fakeProvider) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	f.calls = append(f.calls, "Balance:"+walletID)
	return 1, 2, nil
}

func (f *fakeProvider) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	f.calls = append(f.calls, "Send:"+walletID)
	return "txid-" + f.name, nil
}

func (f *fakeProvider) EnsureAll(ctx context.Context) (int, error) {
	f.calls = append(f.calls, "EnsureAll")
	return 7, nil
}

func (f *fakeProvider) Chain() ChainSource {
	return unavailableChain{reason: "fake " + f.name}
}

// newRouterFixture builds a Service holding an enforcer wallet (first) and a
// bitcoinCore wallet (second) — the real type-assignment logic — plus fakes.
func newRouterFixture(t *testing.T) (*RoutingProvider, *fakeProvider, *fakeProvider, string, string) {
	t.Helper()
	svc := newTestService(t)

	enf, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, "enforcer", enf.WalletType)

	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, "bitcoinCore", core.WalletType)

	enfFake := &fakeProvider{name: "enforcer"}
	chainFake := &fakeProvider{name: "chain"}
	return NewRoutingProvider(svc, enfFake, chainFake), enfFake, chainFake, enf.ID, core.ID
}

func TestRoutingProviderDispatchesByWalletType(t *testing.T) {
	router, enfFake, chainFake, enfID, coreID := newRouterFixture(t)
	ctx := context.Background()

	_, _, err := router.Balance(ctx, enfID)
	require.NoError(t, err)
	_, err = router.Send(ctx, coreID, SendRequest{})
	require.NoError(t, err)

	assert.Equal(t, []string{"Balance:" + enfID}, enfFake.calls)
	assert.Equal(t, []string{"Send:" + coreID}, chainFake.calls)
}

func TestRoutingProviderUnknownWallet(t *testing.T) {
	router, _, _, _, _ := newRouterFixture(t)

	_, _, err := router.Balance(context.Background(), "nope")
	require.ErrorContains(t, err, "not found")
}

func TestRoutingProviderMissingSides(t *testing.T) {
	svc := newTestService(t)
	enf, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)

	router := NewRoutingProvider(svc, nil, nil)
	ctx := context.Background()

	_, _, err = router.Balance(ctx, enf.ID)
	require.ErrorContains(t, err, "enforcer wallet client not connected")
	_, _, err = router.Balance(ctx, core.ID)
	require.ErrorContains(t, err, "bitcoin Core RPC not configured")

	_, err = router.Chain().Broadcast(ctx, "00")
	require.ErrorContains(t, err, "bitcoin Core RPC not configured")

	// EnsureAll without a chain provider is a no-op, not an error.
	n, err := router.EnsureAll(ctx)
	require.NoError(t, err)
	assert.Equal(t, 0, n)
}

func TestRoutingProviderEnsureAllOnlyChain(t *testing.T) {
	router, enfFake, chainFake, _, _ := newRouterFixture(t)

	n, err := router.EnsureAll(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 7, n)
	assert.Equal(t, []string{"EnsureAll"}, chainFake.calls)
	assert.Empty(t, enfFake.calls)
}
