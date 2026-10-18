package orchestrator

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestStartEnforcerWhenReadyWaitsForUnlock(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = nil
	o.NetParams = wallet.StaticParams(&chaincfg.SigNetParams)

	svc := newSeededWalletService(t)
	require.NoError(t, svc.EncryptWallet("pw"))
	svc.LockWallet()
	o.WalletSvc = svc

	enforcerMon := o.getOrCreateMonitor("enforcer", &mockChecker{}, enforcerStartupPatterns)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	prefetched := make(chan error, 1)
	prefetched <- errors.New("no download in this test")
	done := make(chan error, 1)
	go func() { done <- o.startEnforcerWhenReady(ctx, StartOpts{}, prefetched) }()

	select {
	case err := <-done:
		t.Fatalf("the enforcer start went on with a locked wallet: %v", err)
	case <-time.After(300 * time.Millisecond):
	}

	require.NoError(t, svc.UnlockWallet("pw"))

	select {
	case err := <-done:
		require.ErrorContains(t, err, "no download in this test")
	case <-ctx.Done():
		t.Fatal("the enforcer start did not go on after the unlock")
	}
	require.NotContains(t, enforcerMon.ConnectionError(), "payout address")
}

func TestStartWithL1StopsWhenTheEnforcerStartIsRefused(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = nil
	healthy := &mockChecker{}
	healthy.healthy.Store(true)
	useCoreChecker(o, healthy)

	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	require.NoError(t, svc.CreateWatchOnlyWallet("Watch",
		"xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz",
		`{"background_svg":""}`))
	o.WalletSvc = svc

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "enforcer", StartOpts{})
	require.NoError(t, err)
	var failures []error
	for p := range ch {
		if p.Error != nil {
			failures = append(failures, p.Error)
		}
	}

	require.Len(t, failures, 1)
	require.ErrorContains(t, failures[0], "payout address")
	require.False(t, o.process.IsRunning("enforcer"))
}
