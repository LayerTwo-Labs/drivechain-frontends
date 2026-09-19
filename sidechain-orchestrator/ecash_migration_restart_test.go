package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func TestECashMigrationKeepsCoreCrashRestart(t *testing.T) {
	for _, test := range []struct {
		name          string
		sourceMonitor bool
		walletOnly    bool
	}{
		{name: "CLI source"},
		{name: "managed source", sourceMonitor: true},
		{name: "wallet-only source", walletOnly: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			var o *Orchestrator
			var fixture migrationCoreFixture
			var block, undo, wallet []byte
			if test.walletOnly {
				o, fixture, wallet = prepareWalletOnlyEngineTest(t, false)
			} else {
				o, fixture, block, undo, wallet = prepareMigrationEngineTest(t, "", false)
			}
			ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
			t.Cleanup(cancel)
			if test.sourceMonitor {
				require.NoError(t, o.stopMigrationCore(ctx))
				progress := make(chan StartupProgress, 64)
				var opts StartOpts
				require.NoError(t, o.prepareCoreArgs(&opts))
				started := o.startBitcoindOnly(ctx, opts, progress)
				close(progress)
				for item := range progress {
					require.NoError(t, item.Error)
				}
				require.True(t, started)
				requireMigrationCoreCrashRestart(t, o)
			}

			_, err := o.StartECashMigration(ctx, "alphanet", "betanet")
			require.NoError(t, err)
			complete := waitMigrationEngineTest(t, o)
			if test.walletOnly {
				requireWalletOnlyEngineResult(t, o, fixture, complete, wallet, false, true)
				o.monitorsMu.Lock()
				monitor := o.monitors["bitcoind"]
				o.monitorsMu.Unlock()
				require.NotNil(t, monitor)
				require.Equal(t, PresyncMessagePrefix, monitor.StartupError())
			} else {
				requireMigrationEngineResult(t, o, fixture, complete, block, undo, wallet)
			}
			cancel()
			target := o.process.Get("bitcoind")
			repeat, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			require.True(t, repeat.Complete)
			require.Equal(t, complete.JobID, repeat.JobID)
			require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
			require.Same(t, target, o.process.Get("bitcoind"))
			requireMigrationCoreCrashRestart(t, o)
			args := o.process.Get("bitcoind").Cmd.Args
			require.Contains(t, args, "-conf="+o.BitcoinConf.GetConfFilePath())
			require.Contains(t, args, "-datadir="+fixture.DataDir)
			require.NotContains(t, args, "-networkactive=0")
			client, err := o.CoreStatusClient()
			require.NoError(t, err)
			var network struct {
				Active bool `json:"networkactive"`
			}
			require.NoError(t, migrationRPC(context.Background(), client, "getnetworkinfo", &network))
			require.True(t, network.Active)
			require.Equal(t, "betanet", o.Settings.ECashChainID())
		})
	}
}

func requireMigrationCoreCrashRestart(t *testing.T, o *Orchestrator) {
	t.Helper()
	process := o.process.Get("bitcoind")
	require.NotNil(t, process)
	require.NoError(t, process.Cmd.Process.Kill())
	select {
	case <-process.ExitCh():
	case <-time.After(5 * time.Second):
		t.Fatal("the Core fixture did not exit")
	}
	require.NotZero(t, process.ExitCode())
	require.Eventually(t, func() bool {
		next := o.process.Get("bitcoind")
		return next != nil && next.Pid != process.Pid && o.coreRPCReachable()
	}, 5*time.Second, 25*time.Millisecond, "the Core did not restart after a crash")
}
