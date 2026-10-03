package orchestrator

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func newSeededWalletService(t *testing.T) *wallet.Service {
	t.Helper()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	_, err := svc.GenerateWallet("A", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)
	return svc
}

func writeWallet(t *testing.T, dir, content string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(dir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(dir, sidechainWalletFile), []byte(content), 0o644))
}

// A sidechain that starts with another wallet finds no wallet.mdb, and the
// file of the first wallet waits under that wallet.
func TestWalletSwitchParksTheWalletOfTheOtherWallet(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignWalletState(dir, "", "A", "A"))
	writeWallet(t, dir, "wallet A")

	require.NoError(t, alignWalletState(dir, "", "B", "A"))

	require.NoFileExists(t, filepath.Join(dir, sidechainWalletFile))
	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, "wallet.mdb.network-wallet-A")))
	require.Equal(t, "B\n", readState(t, filepath.Join(dir, walletStampFile)))
}

func TestWalletSwitchBackRestoresTheParkedWallet(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignWalletState(dir, "", "A", "A"))
	writeWallet(t, dir, "wallet A")
	require.NoError(t, alignWalletState(dir, "", "B", "A"))
	writeWallet(t, dir, "wallet B")

	require.NoError(t, alignWalletState(dir, "", "A", "A"))

	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
	require.Equal(t, "wallet B", readState(t, filepath.Join(dir, "wallet.mdb.network-wallet-B")))
	require.NoFileExists(t, filepath.Join(dir, "wallet.mdb.network-wallet-A"))
}

func TestSameWalletKeepsTheWallet(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignWalletState(dir, "", "A", "A"))
	writeWallet(t, dir, "wallet A")

	require.NoError(t, alignWalletState(dir, "", "A", "A"))

	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
}

// The on-disk shape from before the stamp: every sidechain loaded the starter
// wallet, so its wallet.mdb stays in place for that wallet.
func TestUnstampedWalletStaysWithTheStarterWallet(t *testing.T) {
	dir := t.TempDir()
	writeWallet(t, dir, "starter wallet")

	require.NoError(t, alignWalletState(dir, "", "A", "A"))

	require.Equal(t, "starter wallet", readState(t, filepath.Join(dir, sidechainWalletFile)))
	require.Equal(t, "A\n", readState(t, filepath.Join(dir, walletStampFile)))
}

// The same shape, when the first start is for another wallet: the file goes to
// the starter wallet, and comes back when that wallet starts the sidechain.
func TestUnstampedWalletIsParkedUnderTheStarterWallet(t *testing.T) {
	dir := t.TempDir()
	writeWallet(t, dir, "starter wallet")

	require.NoError(t, alignWalletState(dir, "", "B", "A"))
	require.NoFileExists(t, filepath.Join(dir, sidechainWalletFile))

	require.NoError(t, alignWalletState(dir, "", "A", "A"))
	require.Equal(t, "starter wallet", readState(t, filepath.Join(dir, sidechainWalletFile)))
}

// Every eCash network shares one datadir, so a wallet parked on one network
// must not open on another.
func TestParkedWalletStaysOnItsECashNetwork(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignWalletState(dir, "alphanet", "A", "A"))
	writeWallet(t, dir, "alphanet wallet A")
	require.NoError(t, alignWalletState(dir, "alphanet", "B", "A"))

	require.NoError(t, alignECashState(dir, "alphanet"))
	require.NoError(t, alignECashState(dir, "betanet"))
	require.NoError(t, alignWalletState(dir, "betanet", "A", "A"))

	require.NoFileExists(t, filepath.Join(dir, sidechainWalletFile))
	require.Equal(t, "alphanet wallet A", readState(t, filepath.Join(dir, "wallet.mdb.network-wallet-A-ecash-alphanet")))
}

// A network switch carries the stamp with the wallet.mdb it names.
func TestECashSwitchCarriesTheWalletStamp(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignECashState(dir, "alphanet"))
	require.NoError(t, alignWalletState(dir, "alphanet", "A", "A"))
	writeWallet(t, dir, "alphanet wallet A")
	require.NoError(t, alignECashState(dir, "betanet"))
	require.NoError(t, alignWalletState(dir, "betanet", "B", "A"))
	writeWallet(t, dir, "betanet wallet B")

	require.NoError(t, alignECashState(dir, "alphanet"))
	require.NoError(t, alignWalletState(dir, "alphanet", "A", "A"))

	require.Equal(t, "alphanet wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
	require.Equal(t, "A\n", readState(t, filepath.Join(dir, walletStampFile)))
}

func TestAlignFinishesAnInterruptedWalletRestore(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, walletStampFile), []byte("A\n"), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.mdb.network-wallet-A"), []byte("wallet A"), 0o644))

	require.NoError(t, alignWalletState(dir, "", "A", "A"))

	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
}

func refusedRun(lines ...string) *ManagedProcess {
	run := &ManagedProcess{}
	for _, line := range lines {
		run.addLog(LogEntry{Stream: "stderr", Line: line})
	}
	return run
}

// A wallet.mdb the node refused holds a seed that is not from the wallet the
// sidechain loads. It moves aside under no wallet, and stays on disk.
func TestStartParksAWalletTheNodeRefused(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSeededWalletService(t)
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)
	writeWallet(t, dir, "made by hand")

	run := refusedRun("Error: " + seedRefusal)
	o.process.mu.Lock()
	o.process.lastExited[cfg.Name] = run
	o.process.mu.Unlock()

	require.NoError(t, o.parkRefusedWallet(cfg))
	require.NoFileExists(t, filepath.Join(dir, sidechainWalletFile))
	require.Equal(t, "made by hand", readState(t, filepath.Join(dir, "wallet.mdb.network-wallet-external")))

	// The same run must not park the wallet.mdb the next start makes.
	writeWallet(t, dir, "new wallet")
	require.NoError(t, o.parkRefusedWallet(cfg))
	require.Equal(t, "new wallet", readState(t, filepath.Join(dir, sidechainWalletFile)))
}

func TestStartKeepsAWalletTheNodeAccepted(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSeededWalletService(t)
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)
	writeWallet(t, dir, "wallet A")

	o.process.mu.Lock()
	o.process.lastExited[cfg.Name] = refusedRun("node stopped")
	o.process.mu.Unlock()

	require.NoError(t, o.parkRefusedWallet(cfg))
	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
}

// A running sidechain restarts only when its wallet.mdb is not the one of the
// wallet the sidechains load.
func TestReloadSelectsTheSidechainsWithAnotherWallet(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	svc := newSeededWalletService(t)
	o.WalletSvc = svc
	first := svc.SidechainWalletID()
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)

	staleNames := func() []string {
		stale, err := o.sidechainsWithAnotherWallet(svc.SidechainWalletID())
		require.NoError(t, err)
		names := make([]string, len(stale))
		for i, c := range stale {
			names[i] = c.Name
		}
		return names
	}

	t.Run("a stopped sidechain needs no restart", func(t *testing.T) {
		require.Empty(t, staleNames())
	})

	o.process.AdoptProcess(cfg, os.Getpid())
	t.Cleanup(func() { o.process.Remove(cfg.Name) })

	t.Run("a wallet.mdb from before the stamp is the starter wallet's", func(t *testing.T) {
		writeWallet(t, dir, "starter wallet")
		loaded, err := o.LoadedSidechainWallet(cfg)
		require.NoError(t, err)
		require.Equal(t, first, loaded)
		require.Empty(t, staleNames())
	})

	t.Run("the same wallet needs no restart", func(t *testing.T) {
		require.NoError(t, os.WriteFile(filepath.Join(dir, walletStampFile), []byte(first+"\n"), 0o644))
		require.Empty(t, staleNames())
	})

	t.Run("another active wallet needs a restart", func(t *testing.T) {
		_, err := svc.GenerateWallet("B", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
		require.NoError(t, err)
		require.NotEqual(t, first, svc.SidechainWalletID())
		require.Equal(t, []string{cfg.Name}, staleNames())
	})
}

func TestStatusNamesTheLoadedSidechainWallet(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	svc := newSeededWalletService(t)
	o.WalletSvc = svc
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)

	require.Empty(t, o.Status(cfg.Name).LoadedWalletID, "a sidechain that never started holds no wallet")

	require.NoError(t, alignWalletState(dir, "", svc.SidechainWalletID(), svc.StarterWalletID()))
	require.Equal(t, svc.SidechainWalletID(), o.Status(cfg.Name).LoadedWalletID)
	require.Empty(t, o.Status("enforcer").LoadedWalletID)
}

// A wallet change between the swap and the seed file must not give the node a
// seed that does not match the wallet.mdb.
func TestStarterFollowsTheAlignedWallet(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	svc := newSeededWalletService(t)
	o.WalletSvc = svc
	first := svc.SidechainWalletID()
	cfg := thunderConfig(t, o)

	walletID, err := o.alignSidechainState(cfg)
	require.NoError(t, err)
	require.Equal(t, first, walletID)

	_, err = svc.GenerateWallet("B", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)
	require.NotEqual(t, first, svc.SidechainWalletID())

	var opts StartOpts
	o.injectSidechainStarter(cfg, &opts, walletID)
	starter := ""
	for _, arg := range opts.TargetArgs {
		if path, ok := strings.CutPrefix(arg, "--mnemonic-seed-phrase-path="); ok {
			starter = path
		}
	}
	require.NotEmpty(t, starter, "no starter in %v", opts.TargetArgs)
	want, err := svc.GetOrDeriveSidechainStarterFor(first, 9, "Thunder")
	require.NoError(t, err)
	require.Equal(t, want, readState(t, starter))
}

// A refused wallet.mdb is handled before a wallet change moves another wallet's
// file in, so the refusal never parks a valid wallet.
func TestRefusalIsHandledBeforeTheSwap(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	svc := newSeededWalletService(t)
	o.WalletSvc = svc
	first := svc.SidechainWalletID()
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)

	_, err := o.alignSidechainState(cfg)
	require.NoError(t, err)
	writeWallet(t, dir, "wallet A")
	second, err := svc.GenerateWallet("B", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)
	_, err = o.alignSidechainState(cfg)
	require.NoError(t, err)
	writeWallet(t, dir, "refused by the node")

	o.process.mu.Lock()
	o.process.lastExited[cfg.Name] = refusedRun("Error: " + seedRefusal)
	o.process.mu.Unlock()

	require.NoError(t, svc.SwitchWallet(first))
	walletID, err := o.alignSidechainState(cfg)
	require.NoError(t, err)
	require.Equal(t, first, walletID)
	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
	require.Equal(t, "refused by the node", readState(t, filepath.Join(dir, "wallet.mdb.network-wallet-external")))
	require.NoFileExists(t, filepath.Join(dir, "wallet.mdb.network-wallet-"+second.ID))

	// The start hook sees the same run, and must not park the restored wallet.
	require.NoError(t, o.parkRefusedWallet(cfg))
	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, sidechainWalletFile)))
}

func TestEachWalletHasItsOwnStarterFile(t *testing.T) {
	svc := newSeededWalletService(t)
	first := svc.SidechainWalletID()
	second, err := svc.GenerateWallet("B", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)

	pathA, err := svc.WriteSidechainStarterFor(first, 9)
	require.NoError(t, err)
	pathB, err := svc.WriteSidechainStarterFor(second.ID, 9)
	require.NoError(t, err)

	require.NotEqual(t, pathA, pathB)
	starterA, err := svc.GetOrDeriveSidechainStarterFor(first, 9, "Thunder")
	require.NoError(t, err)
	require.Equal(t, starterA, readState(t, pathA), "a later start for another wallet changed the file")
}

func TestStatusShowsAnExternalWallet(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSeededWalletService(t)
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)

	require.False(t, o.Status(cfg.Name).HasExternalWallet)
	writeWallet(t, dir, "made by hand")
	require.NoError(t, parkWallet(filepath.Join(dir, sidechainWalletFile), walletParkKey(externalWalletID, "")))
	require.True(t, o.Status(cfg.Name).HasExternalWallet)
}

// A refusal on one eCash network must not park the saved wallet of the next.
func TestRefusalOnOneECashNetworkStaysWithThatNetwork(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	o.WalletSvc = newSeededWalletService(t)
	o.setNetwork(string(config.NetworkECash))
	setECashID := func(id string) {
		o.mu.Lock()
		o.ecashID = id
		o.mu.Unlock()
	}
	setECashID("alphanet")
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)

	_, err := o.alignSidechainState(cfg)
	require.NoError(t, err)
	writeWallet(t, dir, "refused on alphanet")
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.mdb.network-ecash-betanet"), []byte("saved on betanet"), 0o644))
	o.process.mu.Lock()
	o.process.lastExited[cfg.Name] = refusedRun("Error: " + seedRefusal)
	o.process.mu.Unlock()

	setECashID("betanet")
	_, err = o.alignSidechainState(cfg)
	require.NoError(t, err)

	require.Equal(t, "saved on betanet", readState(t, filepath.Join(dir, sidechainWalletFile)))
	require.Equal(t, "refused on alphanet", readState(t, filepath.Join(dir, "wallet.mdb.network-"+walletParkKey(externalWalletID, "alphanet"))))
}

func TestCoreSidechainHoldsTheStarterWallet(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	svc := newSeededWalletService(t)
	o.WalletSvc = svc
	starter := svc.StarterWalletID()
	_, err := svc.GenerateWallet("B", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)

	bbc, err := o.getConfig("bbc")
	require.NoError(t, err)
	loaded, err := o.LoadedSidechainWallet(bbc)
	require.NoError(t, err)
	require.Equal(t, starter, loaded)

	// FreeBank keeps a wallet of its own, which no BitWindow seed restores.
	freebank, err := o.getConfig("freebank")
	require.NoError(t, err)
	loaded, err = o.LoadedSidechainWallet(freebank)
	require.NoError(t, err)
	require.Empty(t, loaded)
}

// A daemon the swap skipped while it ran gets the wallet and the seed of the
// active wallet once it stops, never the old seed against the new file.
func TestRealignGivesAStoppedDaemonTheActiveWallet(t *testing.T) {
	useTempHome(t)
	o := newTestOrchestrator(t)
	svc := newSeededWalletService(t)
	o.WalletSvc = svc
	first := svc.SidechainWalletID()
	cfg := thunderConfig(t, o)
	dir, _, ok := o.sidechainWalletDir(cfg)
	require.True(t, ok)
	_, err := o.alignSidechainState(cfg)
	require.NoError(t, err)
	writeWallet(t, dir, "wallet A")

	second, err := svc.GenerateWallet("B", "", "", []wallet.SidechainSlot{{Slot: 9, Name: "Thunder"}})
	require.NoError(t, err)
	opts := StartOpts{TargetArgs: []string{"--headless", "--mnemonic-seed-phrase-path=/old/starter"}}
	require.NoError(t, o.realignSidechainWallet(cfg, &opts))

	require.Equal(t, second.ID+"\n", readState(t, filepath.Join(dir, walletStampFile)))
	require.Equal(t, "wallet A", readState(t, filepath.Join(dir, "wallet.mdb.network-wallet-"+first)))
	var starters []string
	for _, arg := range opts.TargetArgs {
		if path, ok := strings.CutPrefix(arg, "--mnemonic-seed-phrase-path="); ok {
			starters = append(starters, path)
		}
	}
	require.Len(t, starters, 1)
	want, err := svc.GetOrDeriveSidechainStarterFor(second.ID, 9, "Thunder")
	require.NoError(t, err)
	require.Equal(t, want, readState(t, starters[0]))
}
