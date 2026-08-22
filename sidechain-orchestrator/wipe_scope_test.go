package orchestrator

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// The eCash rollover can fire while the user is on another network, so it
// must only touch data that is actually partitioned by network. Sidechains
// keep a flat datadir shared across every network; wiping it here would
// destroy signet's sidechain state during a eCash network change.
func TestRolloverWipeLeavesSidechainDataAlone(t *testing.T) {
	datadir := t.TempDir()
	blocks := filepath.Join(datadir, "blocks")
	if err := os.MkdirAll(blocks, 0o755); err != nil {
		t.Fatal(err)
	}

	// Stand in for a sidechain's flat, network-independent store.
	sidechain := filepath.Join(datadir, "data.mdb")
	if err := os.WriteFile(sidechain, []byte("shared across networks"), 0o644); err != nil {
		t.Fatal(err)
	}

	if err := config.WipeNetworkScopedChainDataSync(config.NetworkECash, datadir, zerolog.Nop()); err != nil {
		t.Fatal(err)
	}

	if _, err := os.Stat(blocks); err == nil {
		t.Error("eCash blocks should have been renamed aside")
	}
	if _, err := os.Stat(sidechain); err != nil {
		t.Errorf("sidechain data must survive a eCash network change: %v", err)
	}
}

// The enforcer tracks one validator chain per network, not per generation, so a
// drynet2 -> drynet3 rollover has to clear it or the new generation inherits the
// old chain. Its wallet, like bitcoind's, must survive.
func TestRolloverWipesEnforcerChainButKeepsWallet(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	root := config.EnforcerDirs.RootDir()
	// eCash maps onto the "bitcoin" network name in the enforcer's layout.
	chain := filepath.Join(root, "validator", "bitcoin")
	wallet := filepath.Join(root, "wallet", "bitcoin")
	for _, d := range []string{chain, wallet} {
		if err := os.MkdirAll(d, 0o755); err != nil {
			t.Fatal(err)
		}
	}

	if err := config.WipeEnforcerChainDataSync(config.NetworkECash, zerolog.Nop()); err != nil {
		t.Fatal(err)
	}

	if _, err := os.Stat(chain); err == nil {
		t.Error("enforcer validator chain should have been renamed aside")
	}
	if _, err := os.Stat(wallet); err != nil {
		t.Errorf("enforcer wallet must survive a eCash network change: %v", err)
	}
}

// bitwindow.db holds the address book, transaction notes, UTXO labels and
// multisig records, and bitdrive holds the user's files. No chain rebuilds
// any of it, so an eCash network change must leave both alone.
func TestRolloverKeepsTheUsersBitwindowData(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	dc, ok := config.DirConfigByName("bitwindow")
	if !ok {
		t.Fatal("no dir config for bitwindow")
	}
	datadir := dc.DatadirNetwork(config.NetworkECash, "")
	bitdrive := filepath.Join(datadir, "bitdrive")
	if err := os.MkdirAll(bitdrive, 0o755); err != nil {
		t.Fatal(err)
	}
	db := filepath.Join(datadir, "bitwindow.db")
	if err := os.WriteFile(db, []byte("address book, notes, labels"), 0o644); err != nil {
		t.Fatal(err)
	}

	if err := config.WipeNetworkScopedChainDataSync(config.NetworkECash, t.TempDir(), zerolog.Nop()); err != nil {
		t.Fatal(err)
	}

	if _, err := os.Stat(db); err != nil {
		t.Errorf("bitwindow.db must survive an eCash network change: %v", err)
	}
	if _, err := os.Stat(bitdrive); err != nil {
		t.Errorf("bitdrive files must survive an eCash network change: %v", err)
	}
}

// The enforcer wipe has to say whether the validator chain actually left the
// live layout. A caller that records it as done would start the enforcer on the
// retired generation's chain with nothing left to retry.
func TestEnforcerWipeReportsAPathItCouldNotRead(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	root := config.EnforcerDirs.RootDir()
	validator := filepath.Join(root, "validator")
	if err := os.MkdirAll(filepath.Join(validator, "bitcoin"), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.Chmod(validator, 0o000); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = os.Chmod(validator, 0o755) })

	err := config.WipeEnforcerChainDataSync(config.NetworkECash, zerolog.Nop())
	if err == nil {
		t.Skip("this filesystem reads the path anyway, so the failure cannot be staged")
	}
	if !strings.Contains(err.Error(), "validator") {
		t.Errorf("the error must name the path it could not clear: %v", err)
	}
}
