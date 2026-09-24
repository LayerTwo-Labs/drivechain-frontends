package wallet

import (
	"context"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newDeleteFixture(t *testing.T) (*WalletEngine, *fakeBitcoind, string) {
	t.Helper()
	backend, fake, coreID := newCoreBackendFixture(t)
	params := StaticParams(&chaincfg.RegressionNetParams)
	router := NewBackendRouter(backend.svc, backend, nil)
	return NewWalletEngine(backend.svc, router, params, zerolog.New(zerolog.NewTestWriter(t))), fake, coreID
}

func unloadedNames(t *testing.T, fake *fakeBitcoind) []string {
	t.Helper()
	var names []string
	for _, c := range fake.callsFor("unloadwallet") {
		require.Len(t, c.Params, 2)
		assert.Equal(t, "false", string(c.Params[1]), "load_on_startup")
		names = append(names, mustString(t, c.Params[0]))
	}
	return names
}

func TestDeleteWalletUnloadsCoreWallet(t *testing.T) {
	engine, fake, coreID := newDeleteFixture(t)
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) { return map[string]any{}, "" })

	require.NoError(t, engine.DeleteWallet(context.Background(), coreID))

	assert.Equal(t, []string{"wallet_" + coreID[:8], "watch_" + coreID[:8]}, unloadedNames(t, fake))
	assert.Nil(t, engine.svc.GetWalletByID(coreID))
}

func TestDeleteWalletTreatsNotLoadedAsDone(t *testing.T) {
	engine, fake, coreID := newDeleteFixture(t)
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) {
		return nil, "Requested wallet does not exist or is not loaded"
	})

	require.NoError(t, engine.DeleteWallet(context.Background(), coreID))

	assert.Len(t, unloadedNames(t, fake), 2)
	assert.Nil(t, engine.svc.GetWalletByID(coreID))
}

func TestDeleteWalletKeepsEntryWhenUnloadFails(t *testing.T) {
	engine, fake, coreID := newDeleteFixture(t)
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) { return nil, "Wallet is busy" })

	err := engine.DeleteWallet(context.Background(), coreID)

	require.ErrorContains(t, err, "Wallet is busy")
	assert.NotNil(t, engine.svc.GetWalletByID(coreID))
}

func TestDeleteWalletElectrumMakesNoCoreCall(t *testing.T) {
	engine, fake, _ := newDeleteFixture(t)
	elec, err := engine.svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	require.NoError(t, engine.DeleteWallet(context.Background(), elec.ID))

	assert.Empty(t, fake.callsFor("unloadwallet"))
	assert.Nil(t, engine.svc.GetWalletByID(elec.ID))
}

func TestDeleteWalletStarterMakesNoCoreCall(t *testing.T) {
	engine, fake, _ := newDeleteFixture(t)
	starterID := engine.svc.GetAllWallets()[0].ID

	require.ErrorContains(t, engine.DeleteWallet(context.Background(), starterID), "sidechain starters")

	assert.Empty(t, fake.callsFor("unloadwallet"))
	assert.NotNil(t, engine.svc.GetWalletByID(starterID))
}
