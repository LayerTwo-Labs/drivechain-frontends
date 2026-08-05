package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// SwapNetwork's purge resolves the enforcer root from HOME and os.RemoveAll's
// validator/ and wallet/ under it, so a test suite that runs against the real
// HOME deletes the developer's own enforcer state.
func TestRealDatadirsAreOutOfReach(t *testing.T) {
	require.NotEmpty(t, realEnforcerRoot)
	require.NotEqual(t, realEnforcerRoot, config.EnforcerDirs.RootDir(),
		"TestMain must redirect HOME before any test resolves a datadir")
}

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

// A drynet rollover clears the retiring generation's validator chain so its
// blocks don't outlive it. Its wallet, like bitcoind's, must survive.
func TestRolloverWipesEnforcerChainButKeepsWallet(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	root := config.EnforcerDirs.RootDir()
	// --network-preset gives each generation its own namespace under the
	// "bitcoin" chain name drynet shares with mainnet.
	dir := config.EnforcerChainDirName(config.NetworkDrynet)
	chain := filepath.Join(root, "validator", dir)
	wallet := filepath.Join(root, "wallet", dir)
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
