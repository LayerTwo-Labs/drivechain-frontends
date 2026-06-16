package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
)

func newTestWalletService(t *testing.T) *wallet.Service {
	t.Helper()
	return wallet.NewService(t.TempDir(), testLogger(t))
}

// An electrum wallet serves chain data remotely, so StartWithL1 must boot
// neither Bitcoin Core nor the enforcer — it short-circuits to a skipped-l1
// completion and starts no processes.
func TestStartWithL1SkipsBackendsForElectrum(t *testing.T) {
	o := newTestOrchestrator(t)
	svc := newTestWalletService(t)
	_, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "")
	require.NoError(t, err)
	require.False(t, svc.ActiveWalletNeedsBitcoinBackends())
	o.WalletSvc = svc

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "bitcoind", StartOpts{})
	require.NoError(t, err)

	var stages []string
	for p := range ch {
		require.NoError(t, p.Error)
		stages = append(stages, p.Stage)
	}

	require.Equal(t, []string{"skipped-l1"}, stages)
	require.False(t, o.process.IsRunning("bitcoind"))
	require.False(t, o.process.IsRunning("enforcer"))
}

// A non-electrum wallet needs the local stack, so the gate must not skip it.
func TestStartWithL1NeedsBackendsForCoreWallet(t *testing.T) {
	svc := newTestWalletService(t)
	_, err := svc.GenerateWallet("Core", "", "", nil)
	require.NoError(t, err)
	require.True(t, svc.ActiveWalletNeedsBitcoinBackends())
}
