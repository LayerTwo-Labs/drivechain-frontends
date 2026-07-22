package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// The drynet rollover can fire while the user is on another network, so it
// must only touch data that is actually partitioned by network. Sidechains
// keep a flat datadir shared across every network; wiping it here would
// destroy signet's sidechain state during a drynet generation change.
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

	config.WipeNetworkScopedChainDataSync(config.NetworkDrynet, datadir, zerolog.Nop())

	if _, err := os.Stat(blocks); err == nil {
		t.Error("drynet blocks should have been renamed aside")
	}
	if _, err := os.Stat(sidechain); err != nil {
		t.Errorf("sidechain data must survive a drynet generation change: %v", err)
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
	// drynet maps onto the "bitcoin" network name in the enforcer's layout.
	chain := filepath.Join(root, "validator", "bitcoin")
	wallet := filepath.Join(root, "wallet", "bitcoin")
	for _, d := range []string{chain, wallet} {
		if err := os.MkdirAll(d, 0o755); err != nil {
			t.Fatal(err)
		}
	}

	config.WipeEnforcerChainDataSync(config.NetworkDrynet, zerolog.Nop())

	if _, err := os.Stat(chain); err == nil {
		t.Error("enforcer validator chain should have been renamed aside")
	}
	if _, err := os.Stat(wallet); err != nil {
		t.Errorf("enforcer wallet must survive a drynet generation change: %v", err)
	}
}
