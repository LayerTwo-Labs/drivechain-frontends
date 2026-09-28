package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// A daemon that runs with --force-backend opens no chain window. Its host has no
// display, so a window exits at once and the chain never comes back.
func TestBackendOnlyOpensNoWindow(t *testing.T) {
	o := newTestOrchestrator(t)
	config := thunderConfig(t, o)
	o.process.SidechainVariant = func(BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: "test-thunder"}, true
	}

	if !o.opensSidechainWindow(config, StartOpts{}) {
		t.Fatal("a plain daemon must open the window")
	}
	o.SetBackendOnly(true)
	if o.opensSidechainWindow(config, StartOpts{}) {
		t.Error("a backend-only daemon must open no window")
	}
}

// The boot arguments carry --headless while the daemon runs backend only.
func TestBackendOnlyForcesTheBackendArgs(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SetBackendOnly(true)
	config := thunderConfig(t, o)

	opts := StartOpts{ForceBackend: o.BackendOnly()}
	require.NoError(t, o.appendSidechainArgs(context.Background(), config, &opts))
	require.Contains(t, opts.TargetArgs, "--headless")
}

// A restart of a dead process reads no flag off that process. The daemon answers
// for it, so the start still asks for the backend.
func TestBackendOnlyStartOptsForceTheBackend(t *testing.T) {
	o := newTestOrchestrator(t)
	require.False(t, o.startOptsFor(StartOpts{}).ForceBackend)

	o.SetBackendOnly(true)
	require.True(t, o.startOptsFor(StartOpts{}).ForceBackend)
	require.True(t, o.startOptsFor(StartOpts{ForceBackend: true}).ForceBackend)
}

// Status, download and version each pick a build. A backend-only daemon names
// the production daemon for all three, whatever the caller asks.
func TestBackendOnlyDownloadOptsForceTheBackend(t *testing.T) {
	o := newTestOrchestrator(t)
	require.False(t, o.downloadOptsFor(DownloadOptions{}).ForceBackend)

	o.SetBackendOnly(true)
	require.True(t, o.downloadOptsFor(DownloadOptions{}).ForceBackend)
}

// A stop names the window a caller wants closed, whatever build the daemon
// starts. A daemon that adopted a window from an earlier run still closes it.
func TestBackendOnlyStopKeepsTheWindowCleanup(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the process launch path differs on Windows")
	}
	dataDir := t.TempDir()
	config := makeSidechainConfig("http://127.0.0.1/")
	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{config}, testLogger(t))
	o.SetBackendOnly(true)

	guiName := sidechainGUIProcessName(config.Name)
	guiPath := TestSidechainBinaryPath(dataDir, config.AltBinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(guiPath), 0o755))
	require.NoError(t, os.WriteFile(guiPath, buildFakeSidechainBinary(t), 0o755))
	_, err := o.process.StartWithOptions(context.Background(), config, nil, nil, ProcessStartOptions{
		ProcessName: guiName,
		PidName:     guiName,
		WorkDir:     filepath.Dir(guiPath),
	})
	require.NoError(t, err)
	require.True(t, o.process.IsRunning(guiName))

	require.NoError(t, o.Stop(context.Background(), config.Name, true))
	o.process.WaitForExit(guiName, 5*time.Second)
	require.False(t, o.process.IsRunning(guiName),
		"a backend-only daemon must still close a window it adopted")
}

// Status reads the production path on a backend-only daemon. A caller that asks
// for nothing must not read the window build's path.
func TestBackendOnlyStatusReadsTheDaemonPath(t *testing.T) {
	dataDir := t.TempDir()
	config := makeSidechainConfig("http://127.0.0.1/")
	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{config}, testLogger(t))
	o.process.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: c.AltBinaryName}, true
	}
	windowPath := TestSidechainBinaryPath(dataDir, config.AltBinaryName)
	daemonPath := filepath.Join(BinDir(dataDir), config.BinaryName)
	for _, path := range []string{windowPath, daemonPath} {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("binary"), 0o755))
	}
	require.Equal(t, windowPath, o.StatusWithOptions(config.Name, DownloadOptions{}).BinaryPath)

	o.SetBackendOnly(true)
	require.Equal(t, daemonPath, o.StatusWithOptions(config.Name, DownloadOptions{}).BinaryPath)
}

// A bare start with no L1 boot carries the chain's own arguments, --headless
// among them. Nothing else adds them on that path.
func TestBackendOnlyBareStartCarriesHeadless(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the process launch path differs on Windows")
	}
	dataDir := t.TempDir()
	config := makeSidechainConfig("http://127.0.0.1/")
	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{config}, testLogger(t))
	o.SetBackendOnly(true)

	prodPath := filepath.Join(BinDir(dataDir), config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(prodPath), 0o755))
	require.NoError(t, os.WriteFile(prodPath, buildFakeSidechainBinary(t), 0o755))

	_, err := o.Start(context.Background(), config.Name, nil, nil)
	require.NoError(t, err)
	t.Cleanup(func() { _ = o.process.Stop(context.Background(), config.Name, true) })

	proc := o.process.Get(config.Name)
	require.NotNil(t, proc)
	require.Contains(t, proc.Cmd.Args, "--headless")
}

// Start takes the daemon slot on a backend-only daemon. The binary sits at the
// production path only, so a start that takes the window slot finds no file.
func TestBackendOnlyStartTakesTheDaemonSlot(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the process launch path differs on Windows")
	}
	dataDir := t.TempDir()
	config := makeSidechainConfig("http://127.0.0.1/")
	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{config}, testLogger(t))
	o.process.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: c.AltBinaryName}, true
	}

	prodPath := filepath.Join(BinDir(dataDir), config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(prodPath), 0o755))
	require.NoError(t, os.WriteFile(prodPath, buildFakeSidechainBinary(t), 0o755))

	_, err := o.Start(context.Background(), config.Name, nil, nil)
	require.Error(t, err, "a plain daemon must look for the window build")

	o.SetBackendOnly(true)
	pid, err := o.Start(context.Background(), config.Name, nil, nil)
	require.NoError(t, err)
	require.NotZero(t, pid)
	t.Cleanup(func() { _ = o.process.Stop(context.Background(), config.Name, true) })

	time.Sleep(250 * time.Millisecond)
	require.True(t, o.process.IsRunning(config.Name), "the daemon slot must hold the process")
	require.False(t, o.process.IsRunning(sidechainGUIProcessName(config.Name)), "the window slot must stay empty")
}

// A bare backend-only start reads the chain's own config. A chain with no
// network for the running mainchain refuses to start, rather than sync another
// network on the daemon's default ports.
func TestBackendOnlyBareStartRefusesAnUnknownNetwork(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SetBackendOnly(true)
	config := thunderConfig(t, o)
	o.SidechainConfs = nil

	_, err := o.Start(context.Background(), config.Name, nil, nil)
	require.ErrorIs(t, err, errSidechainNetworkUnknown)
}

// A bare backend-only start names the starter the user's wallet derives. Without
// it the node derives another wallet, and the user's coins read as absent.
func TestBackendOnlyBareStartNamesTheStarter(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the process launch path differs on Windows")
	}
	dataDir := t.TempDir()
	config := makeSidechainConfig("http://127.0.0.1/")
	config.Slot = 9
	config.DisplayName = "Thunder"
	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{config}, testLogger(t))
	o.SetBackendOnly(true)

	walletSvc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, walletSvc.Init())
	t.Cleanup(walletSvc.Close)
	_, err := walletSvc.GenerateWallet("Backend Only", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)
	o.WalletSvc = walletSvc

	prodPath := filepath.Join(BinDir(dataDir), config.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(prodPath), 0o755))
	require.NoError(t, os.WriteFile(prodPath, buildFakeSidechainBinary(t), 0o755))

	_, err = o.Start(context.Background(), config.Name, nil, nil)
	require.NoError(t, err)
	t.Cleanup(func() { _ = o.process.Stop(context.Background(), config.Name, true) })

	proc := o.process.Get(config.Name)
	require.NotNil(t, proc)
	starter := ""
	for _, arg := range proc.Cmd.Args {
		if strings.HasPrefix(arg, "--mnemonic-seed-phrase-path=") {
			starter = arg
		}
	}
	require.NotEmpty(t, starter, "the start names no starter: %v", proc.Cmd.Args)
}
