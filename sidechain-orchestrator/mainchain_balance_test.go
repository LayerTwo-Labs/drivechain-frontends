package orchestrator

import (
	"context"
	"errors"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// balanceBackend answers Balance and records the wallet ID that reached it.
// Every other Backend method panics through the nil embedded interface.
type balanceBackend struct {
	wallet.Backend
	confirmed   float64
	unconfirmed float64
	err         error
	gotWalletID string
}

func (b *balanceBackend) Balance(_ context.Context, walletID string) (float64, float64, error) {
	b.gotWalletID = walletID
	if b.err != nil {
		return 0, 0, b.err
	}
	return b.confirmed, b.unconfirmed, nil
}

func newBalanceWalletService(t *testing.T) *wallet.Service {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	return svc
}

// newBalanceOrchestrator wires an orchestrator to a router over the two fakes,
// exactly as cmd/drivechaind wires the real backends.
func newBalanceOrchestrator(t *testing.T, svc *wallet.Service, chain, electrum wallet.Backend) *Orchestrator {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	router := wallet.NewBackendRouter(svc, chain, electrum)
	engine := wallet.NewWalletEngine(svc, router, wallet.StaticParams(&chaincfg.MainNetParams), log)
	o := &Orchestrator{}
	o.SetWalletEngine(engine)
	return o
}

func TestGetMainchainBalanceReadsAnElectrumWallet(t *testing.T) {
	svc := newBalanceWalletService(t)
	w, err := svc.CreateElectrumWallet("Light", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, wallet.WalletTypeElectrum, w.WalletType)
	require.NoError(t, svc.SwitchWallet(w.ID))

	chain := &balanceBackend{confirmed: 9, unconfirmed: 9}
	electrum := &balanceBackend{confirmed: 4.9999, unconfirmed: 0.25}
	o := newBalanceOrchestrator(t, svc, chain, electrum)

	bal, err := o.GetMainchainBalance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 4.9999, bal.Confirmed)
	assert.Equal(t, 0.25, bal.Unconfirmed)
	assert.Equal(t, w.ID, electrum.gotWalletID)
	assert.Empty(t, chain.gotWalletID)
}

func TestGetMainchainBalanceReadsACoreWallet(t *testing.T) {
	svc := newBalanceWalletService(t)
	w, err := svc.GenerateWallet("Full", "", "", nil)
	require.NoError(t, err)
	require.Equal(t, wallet.WalletTypeBitcoinCore, w.WalletType)
	require.NoError(t, svc.SwitchWallet(w.ID))

	chain := &balanceBackend{confirmed: 1.25, unconfirmed: 0.5}
	electrum := &balanceBackend{confirmed: 9, unconfirmed: 9}
	o := newBalanceOrchestrator(t, svc, chain, electrum)

	bal, err := o.GetMainchainBalance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 1.25, bal.Confirmed)
	assert.Equal(t, 0.5, bal.Unconfirmed)
	assert.Equal(t, w.ID, chain.gotWalletID)
	assert.Empty(t, electrum.gotWalletID)
}

func TestGetMainchainBalanceRefusesWithoutAWalletEngine(t *testing.T) {
	o := &Orchestrator{}

	bal, err := o.GetMainchainBalance(context.Background())
	require.ErrorContains(t, err, "no wallet engine is wired")
	assert.Nil(t, bal)
}

func TestGetMainchainBalanceRefusesWithoutAnActiveWallet(t *testing.T) {
	svc := newBalanceWalletService(t)
	o := newBalanceOrchestrator(t, svc, &balanceBackend{}, &balanceBackend{})

	bal, err := o.GetMainchainBalance(context.Background())
	require.ErrorContains(t, err, "no active wallet")
	assert.Nil(t, bal)
}

func TestGetMainchainBalanceRefusesWithoutABackend(t *testing.T) {
	svc := newBalanceWalletService(t)
	w, err := svc.CreateElectrumWallet("Light", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	require.NoError(t, svc.SwitchWallet(w.ID))

	o := newBalanceOrchestrator(t, svc, nil, nil)

	bal, err := o.GetMainchainBalance(context.Background())
	require.ErrorContains(t, err, "electrum wallet backend not configured")
	assert.Nil(t, bal)
}

func TestGetMainchainBalanceReportsABackendFailure(t *testing.T) {
	svc := newBalanceWalletService(t)
	w, err := svc.GenerateWallet("Full", "", "", nil)
	require.NoError(t, err)
	require.NoError(t, svc.SwitchWallet(w.ID))

	chain := &balanceBackend{err: errors.New("connection refused")}
	o := newBalanceOrchestrator(t, svc, chain, nil)

	bal, err := o.GetMainchainBalance(context.Background())
	require.ErrorContains(t, err, "connection refused")
	require.ErrorContains(t, err, w.ID)
	assert.Nil(t, bal)
}
