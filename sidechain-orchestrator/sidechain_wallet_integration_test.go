//go:build integration

package orchestrator

import (
	"context"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// The real node of each sidechain decides whether a wallet.mdb matches the
// seed it starts with, so each step reads its verdict from the node itself.
func TestSidechainWalletSwapWithTheRealNode(t *testing.T) {
	for _, name := range []string{"thunder", "truthcoin", "bitnames", "bitassets", "photon", "coinshift"} {
		t.Run(name, func(t *testing.T) {
			testWalletSwap(t, name)
		})
	}
}

func testWalletSwap(t *testing.T, name string) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	cfg, err := o.getConfig(name)
	require.NoError(t, err)
	if _, err := cfg.FileForPlatform(); err != nil {
		t.Skipf("%s publishes no release for %s", name, currentPlatform())
	}
	spec, ok := config.SidechainSpecByName(name)
	require.True(t, ok)

	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	o.WalletSvc = svc
	slots := []wallet.SidechainSlot{{Slot: cfg.Slot, Name: cfg.DisplayName}}
	walletA, err := svc.GenerateWallet("A", "", "", slots)
	require.NoError(t, err)
	walletB, err := svc.GenerateWallet("B", "", "", slots)
	require.NoError(t, err)

	installSidechain(t, cfg, o.DataDir)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)
	live := filepath.Join(dir, sidechainWalletFile)
	parked := func(walletID string) string {
		return filepath.Join(dir, sidechainWalletFile+".network-"+walletParkKey(walletID, ""))
	}

	start := func(t *testing.T, walletID string) string {
		t.Helper()
		require.NoError(t, svc.SwitchWallet(walletID))
		aligned, err := o.alignSidechainState(cfg)
		require.NoError(t, err)
		require.Equal(t, walletID, aligned)
		starter, err := svc.WriteSidechainStarterFor(aligned, cfg.Slot)
		require.NoError(t, err)
		mainchain, err := spec.EnforcerArgs("http://127.0.0.1:" + freeTCPPort(t))
		require.NoError(t, err)
		args := append([]string{
			"--headless",
			"--datadir=" + dir,
			"--mnemonic-seed-phrase-path=" + starter,
			"--network=regtest",
			"--net-addr=127.0.0.1:" + freeUDPPort(t),
		}, mainchain...)
		if spec.PortStyle == "zmq" {
			args = append(args, "--zmq-addr=127.0.0.1:"+freeTCPPort(t))
		} else {
			args = append(args, "--rpc-addr=127.0.0.1:"+freeTCPPort(t))
		}
		// With no mainchain a node stops, or waits, after it opens its wallet.
		// A node that stops at once makes the start report an error.
		if _, err := o.process.StartWithOptions(context.Background(), cfg, args, nodeHomeEnv(), ProcessStartOptions{ForceBackend: true}); err != nil {
			require.ErrorContains(t, err, "exited immediately")
		}
		var out string
		require.Eventually(t, func() bool {
			run := o.process.LatestRun(cfg.Name)
			out = runOutput(run)
			return strings.Contains(out, seedRefusal) || strings.Contains(out, mainchainRefusal)
		}, 2*time.Minute, 100*time.Millisecond, "%s neither opened nor refused its wallet:\n%s", name, out)
		if o.process.IsRunning(cfg.Name) {
			require.NoError(t, o.process.Stop(context.Background(), cfg.Name, true))
		}
		require.True(t, o.process.WaitForExit(cfg.Name, time.Minute), "%s did not stop", name)
		return out
	}
	accepted := func(t *testing.T, out string) {
		t.Helper()
		require.NotContains(t, out, seedRefusal, "the node refused the wallet")
		require.Contains(t, out, mainchainRefusal, "the node stopped before it reached the mainchain:\n%s", out)
	}

	t.Run("wallet A makes its wallet.mdb", func(t *testing.T) {
		accepted(t, start(t, walletA.ID))
		require.DirExists(t, live)
	})

	t.Run("wallet B gets its own wallet.mdb", func(t *testing.T) {
		accepted(t, start(t, walletB.ID))
		require.DirExists(t, parked(walletA.ID))
	})

	t.Run("wallet A gets its wallet.mdb back", func(t *testing.T) {
		accepted(t, start(t, walletA.ID))
		require.DirExists(t, parked(walletB.ID))
	})

	t.Run("a wallet.mdb from outside moves aside", func(t *testing.T) {
		require.NoError(t, os.Rename(live, filepath.Join(t.TempDir(), "wallet A")))
		require.NoError(t, os.Rename(parked(walletB.ID), live))

		require.Contains(t, start(t, walletA.ID), seedRefusal, "the node took a wallet.mdb of another seed")

		accepted(t, start(t, walletA.ID))
		require.DirExists(t, parked(externalWalletID))
	})
}

// mainchainRefusal is what a node prints when it opened its wallet and finds
// no mainchain.
const mainchainRefusal = "tcp connect error"

// installSidechain puts the published release of cfg in the bin directory of
// dataDir. The download goes to the shared test cache, so a rerun skips it.
func installSidechain(t *testing.T, cfg BinaryConfig, dataDir string) {
	t.Helper()
	cache, err := os.UserCacheDir()
	require.NoError(t, err)
	cache = filepath.Join(cache, "drivechain-test-binaries")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	progress, err := NewDownloadManager(cache, "", zerolog.Nop()).Download(ctx, cfg, "default", false)
	require.NoError(t, err)
	for p := range progress {
		require.NoError(t, p.Error)
	}

	raw, err := os.ReadFile(BinaryPath(cache, cfg.BinaryName))
	require.NoError(t, err)
	dest := BinaryPath(dataDir, cfg.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(dest), 0o755))
	require.NoError(t, os.WriteFile(dest, raw, 0o755))
}

// nodeHomeEnv points the node's own default paths at the test home.
func nodeHomeEnv() map[string]string {
	home := config.HomeDir()
	env := map[string]string{"HOME": home}
	if runtime.GOOS == "windows" {
		env["USERPROFILE"] = home
		env["APPDATA"] = filepath.Join(home, "AppData", "Roaming")
		env["LOCALAPPDATA"] = filepath.Join(home, "AppData", "Local")
	}
	return env
}

func freeTCPPort(t *testing.T) string {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	defer l.Close() //nolint:errcheck // a probe socket
	return fmt.Sprint(l.Addr().(*net.TCPAddr).Port)
}

func freeUDPPort(t *testing.T) string {
	t.Helper()
	c, err := net.ListenPacket("udp", "127.0.0.1:0")
	require.NoError(t, err)
	defer c.Close() //nolint:errcheck // a probe socket
	return fmt.Sprint(c.LocalAddr().(*net.UDPAddr).Port)
}

func runOutput(run *ManagedProcess) string {
	var out strings.Builder
	for _, entry := range run.RecentLogs(maxLogEntries) {
		out.WriteString(entry.Line)
		out.WriteString("\n")
	}
	return out.String()
}

// A node that drivechaind does not track still holds its wallet.mdb open, and
// the swap must leave that file in place.
func TestWalletSwapLeavesAnOpenWalletInPlace(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	cfg, err := o.getConfig("coinshift")
	require.NoError(t, err)
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	o.WalletSvc = svc
	slots := []wallet.SidechainSlot{{Slot: cfg.Slot, Name: cfg.DisplayName}}
	walletA, err := svc.GenerateWallet("A", "", "", slots)
	require.NoError(t, err)
	walletB, err := svc.GenerateWallet("B", "", "", slots)
	require.NoError(t, err)

	installSidechain(t, cfg, o.DataDir)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)
	require.NoError(t, svc.SwitchWallet(walletA.ID))
	walletID, err := o.alignSidechainState(cfg)
	require.NoError(t, err)
	starter, err := svc.WriteSidechainStarterFor(walletID, cfg.Slot)
	require.NoError(t, err)

	// Coinshift waits for its mainchain, so it keeps the wallet open.
	cmd := exec.Command(BinaryPath(o.DataDir, cfg.BinaryName),
		"--headless",
		"--datadir="+dir,
		"--mnemonic-seed-phrase-path="+starter,
		"--network=regtest",
		"--net-addr=127.0.0.1:"+freeUDPPort(t),
		"--rpc-addr=127.0.0.1:"+freeTCPPort(t),
		"--mainchain-grpc-url=http://127.0.0.1:"+freeTCPPort(t),
	)
	for key, value := range nodeHomeEnv() {
		cmd.Env = append(cmd.Environ(), key+"="+value)
	}
	require.NoError(t, cmd.Start())
	t.Cleanup(func() {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
	})
	live := filepath.Join(dir, sidechainWalletFile)
	require.Eventually(t, func() bool {
		inUse, err := lmdbInUse(live)
		return err == nil && inUse
	}, time.Minute, 100*time.Millisecond, "coinshift did not open its wallet")

	require.NoError(t, svc.SwitchWallet(walletB.ID))
	_, err = o.alignSidechainState(cfg)
	require.ErrorContains(t, err, "holds")
	require.DirExists(t, live)
	require.NoDirExists(t, filepath.Join(dir, sidechainWalletFile+".network-"+walletParkKey(walletA.ID, "")))
}
