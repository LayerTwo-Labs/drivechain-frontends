package orchestrator

import (
	"os"
	"testing"
)

func thunderConfig(t *testing.T, o *Orchestrator) BinaryConfig {
	t.Helper()
	config, err := o.getConfig("thunder")
	if err != nil {
		t.Fatalf("thunder config: %v", err)
	}
	if config.ChainLayer != 2 {
		t.Fatalf("thunder reads as layer %d, want 2", config.ChainLayer)
	}
	return config
}

// A light install runs no sidechain daemon, but the user still opens the
// chain's own window. The two calls differ only by ForceBackend.
func TestOpensSidechainWindowSplitsWindowFromDaemon(t *testing.T) {
	o := newTestOrchestrator(t)
	config := thunderConfig(t, o)
	o.process.SidechainVariant = func(BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: "test-thunder"}, true
	}

	if !o.opensSidechainWindow(config, StartOpts{}) {
		t.Error("a frontend call must open the window")
	}
	if o.opensSidechainWindow(config, StartOpts{ForceBackend: true}) {
		t.Error("a backend call asks for the daemon, and must open no window")
	}
}

// A chain with no app bundle has no window, whoever asks.
func TestOpensNoWindowWithoutABundle(t *testing.T) {
	o := newTestOrchestrator(t)
	config := thunderConfig(t, o)
	o.process.SidechainVariant = func(BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{}, false
	}

	if o.opensSidechainWindow(config, StartOpts{}) {
		t.Error("a chain that ships no bundle must open no window")
	}
}

// Bitcoin Core is layer 1. It has no window of its own to open.
func TestOpensNoWindowForAnL1Binary(t *testing.T) {
	o := newTestOrchestrator(t)
	config, err := o.getConfig("bitcoind")
	if err != nil {
		t.Fatalf("bitcoind config: %v", err)
	}
	o.process.SidechainVariant = func(BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: "test-thunder"}, true
	}

	if o.opensSidechainWindow(config, StartOpts{}) {
		t.Error("an L1 binary must open no sidechain window")
	}
}

// A user who quits bitwindow keeps the chain windows they opened. The next
// start adopts them again through their PID files.
func TestOwnerExitLeavesTheChainWindowsOpen(t *testing.T) {
	running := []string{"bitcoind", "thunder-gui", "enforcer", "thunder", "bitnames-gui"}

	got := shutdownList(running, true)

	want := []string{"bitcoind", "enforcer", "thunder"}
	if len(got) != len(want) {
		t.Fatalf("stop list is %v, want %v", got, want)
	}
	for i, name := range want {
		if got[i] != name {
			t.Errorf("stop list is %v, want %v", got, want)
			break
		}
	}
}

// The stop-all command stops everything it manages, windows included, or it
// reports a completion that is not true.
func TestStopAllStopsTheChainWindowsToo(t *testing.T) {
	running := []string{"bitcoind", "thunder-gui", "enforcer"}
	if got := shutdownList(running, false); len(got) != 3 {
		t.Errorf("stop list is %v, want every slot", got)
	}
}

// Only a chain with a light backend opens a window with no daemon. A window
// with no wallet under it is worse than no window.
func TestLightWalletRegistrationGatesTheWindow(t *testing.T) {
	o := newTestOrchestrator(t)

	if o.servesLightWallet("thunder") {
		t.Error("no chain serves a light wallet before it registers one")
	}

	readsIndex := true
	o.RegisterLightWallet("thunder", func() bool { return readsIndex })

	if !o.servesLightWallet("thunder") {
		t.Error("a registered chain must serve a light wallet")
	}
	if o.servesLightWallet("bitnames") {
		t.Error("bitnames registers no light wallet, so it must not serve one")
	}

	// Only eCash carries a thunder index. A network without one reads the
	// local node, and the answer moves with the network.
	readsIndex = false
	if o.servesLightWallet("thunder") {
		t.Error("a network with no index must not serve a light wallet")
	}
}

// The frontend reads the window through the binary status, because the GUI
// runs under its own process slot and ListBinaries never lists that slot.
func TestStatusReportsAnOpenWindow(t *testing.T) {
	o := newTestOrchestrator(t)

	if o.Status("thunder").WindowOpen {
		t.Fatal("a chain with no window reads as open")
	}

	// AdoptOrphans registers a window under its own slot, from its own PID file.
	guiName := sidechainGUIProcessName("thunder")
	window := thunderConfig(t, o)
	window.Name = guiName
	o.process.AdoptProcessResolved(window, os.Getpid(), "", guiName, false)
	defer o.process.Remove(guiName)

	if !o.Status("thunder").WindowOpen {
		t.Error("an open window must read as open")
	}
	if o.Status("thunder").Running {
		t.Error("a window is not a daemon, so Running must stay false")
	}
}

// Bitcoin Core has no window, so it never reports one.
func TestStatusReportsNoWindowForAnL1Binary(t *testing.T) {
	o := newTestOrchestrator(t)
	if o.Status("bitcoind").WindowOpen {
		t.Error("an L1 binary must report no window")
	}
}

// Bo's own complaint: a light install has no Bitcoin data directory, and that
// must not stop it from opening a chain window.
func TestLightModeNeedsNoDataDirectory(t *testing.T) {
	o := newTestOrchestrator(t)
	if err := WriteNodeMode(o.BitwindowDir, NodeModeLight); err != nil {
		t.Fatalf("write node mode: %v", err)
	}

	plan := o.PlanNetworkChange(NetworkChangeRequest{})

	if plan.MustSelectDatadir {
		t.Error("light mode runs no local chain, so it must ask for no directory")
	}
	if plan.NeedsLocalBackends {
		t.Error("light mode must not read as needing local backends")
	}
}
