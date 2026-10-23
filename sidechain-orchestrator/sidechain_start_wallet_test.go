package orchestrator

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func sidechainStartFixture(t *testing.T) (*Orchestrator, BinaryConfig, StartOpts, string) {
	t.Helper()
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	o.NetParams = wallet.StaticParams(&chaincfg.SigNetParams)
	o.WalletSvc = newSeededWalletService(t)
	cfg, env, argsPath := installRemoteTestDaemon(t, o)
	for _, name := range []string{"bitcoind", "enforcer"} {
		dependency := o.Configs()[name]
		checker := &mockChecker{}
		checker.healthy.Store(true)
		if name == "bitcoind" {
			useCoreChecker(o, checker)
		}
		o.getOrCreateMonitor(name, checker, nil)
		o.process.AdoptProcess(dependency, os.Getpid())
		t.Cleanup(func() { o.process.Remove(name) })
		path := o.download.ResolveTarget(dependency, o.CurrentNetwork(), DownloadOptions{}).BinPath
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("test binary"), 0o755))
	}
	return o, cfg, StartOpts{
		ForceBackend: true,
		TargetEnv:    env,
		TargetArgs:   []string{"--network=signet"},
	}, argsPath
}

func TestSidechainStartUsesTheSeedAfterUnlock(t *testing.T) {
	for _, immediate := range []bool{false, true} {
		name := "full"
		if immediate {
			name = "immediate"
		}
		t.Run(name, func(t *testing.T) {
			o, cfg, opts, argsPath := sidechainStartFixture(t)
			opts.Immediate = immediate
			walletID := o.WalletSvc.SidechainWalletID()
			seed, err := o.WalletSvc.GetOrDeriveSidechainStarterFor(walletID, cfg.Slot, cfg.DisplayName)
			require.NoError(t, err)
			require.NoError(t, o.WalletSvc.EncryptWallet("password"))
			o.WalletSvc.LockWallet()
			dir, _, ok := o.sidechainWalletDir(cfg)
			require.True(t, ok)

			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			progress, err := o.StartWithL1(ctx, cfg.Name, opts)
			require.NoError(t, err)
			select {
			case p := <-progress:
				t.Fatalf("the start did not wait for unlock: %+v", p)
			case <-time.After(100 * time.Millisecond):
			}
			require.NoFileExists(t, filepath.Join(dir, walletStampFile))
			require.False(t, o.process.IsRunning(cfg.Name))
			require.NoError(t, o.WalletSvc.UnlockWallet("password"))

			var complete bool
			for p := range progress {
				require.NoError(t, p.Error)
				complete = complete || p.Done
			}
			require.True(t, complete)
			require.True(t, o.process.IsRunning(cfg.Name))
			require.Equal(t, walletID+"\n", readState(t, filepath.Join(dir, walletStampFile)))
			args, err := os.ReadFile(argsPath)
			require.NoError(t, err)
			var paths []string
			for _, arg := range strings.Split(string(args), "\n") {
				if path, ok := strings.CutPrefix(arg, "--mnemonic-seed-phrase-path="); ok {
					paths = append(paths, path)
				}
			}
			require.Len(t, paths, 1)
			require.Equal(t, seed, readState(t, paths[0]))
		})
	}
}

func TestSidechainStartCancelsTheUnlockWait(t *testing.T) {
	o, cfg, opts, argsPath := sidechainStartFixture(t)
	require.NoError(t, o.WalletSvc.EncryptWallet("password"))
	o.WalletSvc.LockWallet()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	progress, err := o.StartWithL1(ctx, cfg.Name, opts)
	require.NoError(t, err)
	cancel()
	var failures []error
	for p := range progress {
		if p.Error != nil {
			failures = append(failures, p.Error)
		}
		require.False(t, p.Done)
	}
	require.Len(t, failures, 1)
	require.ErrorIs(t, failures[0], context.Canceled)
	require.False(t, o.process.IsRunning(cfg.Name))
	require.NoFileExists(t, argsPath)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)
	require.NoFileExists(t, filepath.Join(dir, walletStampFile))
}

func TestSidechainStartReturnsSeedErrors(t *testing.T) {
	for _, name := range []string{"derive", "write"} {
		t.Run(name, func(t *testing.T) {
			o, cfg, opts, argsPath := sidechainStartFixture(t)
			opts.Immediate = true
			if name == "derive" {
				svc := wallet.NewService(t.TempDir(), zerolog.Nop())
				require.NoError(t, svc.Init())
				t.Cleanup(svc.Close)
				require.NoError(t, svc.CreateWatchOnlyWallet("Watch",
					"xpub6CUGRUonZSQ4TWtTMmzXdrXDtypWKiKrhko4egpiMZbpiaQL2jkwSB1icqYh2cfDfVxdx4df189oLKnC5fSwqPfgyP3hooxujYzAu3fDVmz",
					`{"background_svg":""}`))
				o.WalletSvc = svc
			} else {
				path, err := o.WalletSvc.WriteSidechainStarterFor(o.WalletSvc.SidechainWalletID(), cfg.Slot)
				require.NoError(t, err)
				require.NoError(t, os.Remove(path))
				require.NoError(t, os.Mkdir(path, 0o700))
			}
			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			progress, err := o.StartWithL1(ctx, cfg.Name, opts)
			require.NoError(t, err)
			var failures []error
			for p := range progress {
				if p.Error != nil {
					failures = append(failures, p.Error)
				}
				require.False(t, p.Done)
			}
			require.Len(t, failures, 1)
			require.ErrorContains(t, failures[0], name+" sidechain starter")
			if name == "write" {
				var pathError *os.PathError
				require.True(t, errors.As(failures[0], &pathError))
			}
			require.False(t, o.process.IsRunning(cfg.Name))
			require.NoFileExists(t, argsPath)
			require.Contains(t, o.Status(cfg.Name).ConnectionError, name+" sidechain starter")
		})
	}
}

func TestSidechainWindowOpensWithALockedWallet(t *testing.T) {
	for _, mode := range []NodeMode{NodeModeFull, NodeModeLight} {
		t.Run(string(mode), func(t *testing.T) {
			o, cfg, opts, argsPath := sidechainStartFixture(t)
			require.NoError(t, o.WalletSvc.EncryptWallet("password"))
			o.WalletSvc.LockWallet()
			opts.ForceBackend = false
			opts.Immediate = mode == NodeModeFull
			if mode == NodeModeLight {
				server := remoteValidatorServer(t, 42, nil)
				setRemoteTestEndpoint(t, config.NetworkSignet, server.URL)
				require.NoError(t, WriteNodeMode(o.BitwindowDir, mode))
			}
			resolver := func(BinaryConfig) (sidechainVariantSpec, bool) {
				return sidechainVariantSpec{BinaryName: "test-thunder"}, true
			}
			o.process.SidechainVariant = resolver
			o.download.SidechainVariant = resolver
			path := TestSidechainBinaryPath(o.DataDir, "test-thunder")
			require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
			require.NoError(t, os.WriteFile(path, buildFakeSidechainBinary(t), 0o755))
			guiName := sidechainGUIProcessName(cfg.Name)
			stopOnCleanup(t, o.process, guiName)

			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			progress, err := o.StartWithL1(ctx, cfg.Name, opts)
			require.NoError(t, err)
			var complete bool
			for p := range progress {
				require.NoError(t, p.Error)
				complete = complete || p.Done
			}
			require.True(t, complete)
			require.True(t, o.process.IsRunning(guiName))
			require.False(t, o.process.IsRunning(cfg.Name))
			require.NoFileExists(t, argsPath)
			require.Equal(t, wallet.StateLocked, o.WalletSvc.State())
			dir, _, ok := o.sidechainWalletDir(cfg)
			require.True(t, ok)
			require.NoFileExists(t, filepath.Join(dir, walletStampFile))
		})
	}
}

func TestSidechainEntryPointsReturnSeedErrors(t *testing.T) {
	for _, name := range []string{"start", "restart", "reset"} {
		t.Run(name, func(t *testing.T) {
			o, cfg, opts, argsPath := sidechainStartFixture(t)
			path, err := o.WalletSvc.WriteSidechainStarterFor(o.WalletSvc.SidechainWalletID(), cfg.Slot)
			require.NoError(t, err)
			require.NoError(t, os.Remove(path))
			require.NoError(t, os.Mkdir(path, 0o700))
			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			switch name {
			case "start":
				o.SetBackendOnly(true)
				_, err = o.Start(ctx, cfg.Name, opts.TargetArgs, opts.TargetEnv)
			case "restart":
				var progress <-chan StartupProgress
				progress, err = o.RestartDaemon(ctx, cfg.Name, StopOptions{ForceBackend: true})
				require.NoError(t, err)
				for p := range progress {
					err = errors.Join(err, p.Error)
					require.False(t, p.Done)
				}
			case "reset":
				err = o.restartResetBinary(ctx, ResetBinaryThunder, true)
			}
			require.ErrorContains(t, err, "write sidechain starter")
			require.False(t, o.process.IsRunning(cfg.Name))
			require.NoFileExists(t, argsPath)
		})
	}
}
