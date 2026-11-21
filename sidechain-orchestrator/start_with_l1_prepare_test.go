package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

func TestStartWithL1StartsCoreWhileTheSidechainWaitsForUnlock(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = nil
	o.NetParams = wallet.StaticParams(&chaincfg.SigNetParams)
	healthy := &mockChecker{}
	healthy.healthy.Store(true)
	useCoreChecker(o, healthy)

	svc := newSeededWalletService(t)
	require.NoError(t, svc.EncryptWallet("pw"))
	svc.LockWallet()
	o.WalletSvc = svc

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ch, err := o.StartWithL1(ctx, "thunder", StartOpts{ForceBackend: true})
	require.NoError(t, err)

	timeout := time.After(5 * time.Second)
	for {
		select {
		case p, ok := <-ch:
			require.True(t, ok, "the boot ended before Core")
			require.NoError(t, p.Error)
			if p.Stage == "waiting-bitcoind" {
				return
			}
		case <-timeout:
			t.Fatal("Core waited for the sidechain wallet unlock")
		}
	}
}
