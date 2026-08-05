package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// Every drynet hostname is built from the generation, so a new drynet is an
// endpoint change rather than a code change.
func TestDrynetURLsFollowTheGeneration(t *testing.T) {
	original := DrynetGeneration()
	t.Cleanup(func() { SetDrynetGeneration(original) })

	SetDrynetGeneration("drynet3")
	urls := EsploraURLsForNetwork(NetworkDrynet)
	if len(urls) != 1 || urls[0] != "https://esplora.drynet3.drivechain.dev" {
		t.Errorf("EsploraURLsForNetwork(drynet) = %v, want the drynet3 host", urls)
	}

	m := &BitcoinConfManager{Network: NetworkDrynet}
	if got := m.DrynetPeer(); got != "drynet3.drivechain.dev:8335" {
		t.Errorf("DrynetPeer() = %q, want the drynet3 peer", got)
	}
}

// The enforcer namespaces its datadir per --network-preset, so the paths a
// reset resolves have to carry the generation too. Mainnet and forknet run
// without a preset and keep the bare name.
func TestEnforcerChainDirNameFollowsTheGeneration(t *testing.T) {
	original := DrynetGeneration()
	t.Cleanup(func() { SetDrynetGeneration(original) })

	SetDrynetGeneration("drynet3")
	if got := EnforcerChainDirName(NetworkDrynet); got != "bitcoin-drynet3" {
		t.Errorf("EnforcerChainDirName(drynet) = %q, want bitcoin-drynet3", got)
	}

	SetDrynetGeneration("drynet4")
	if got := EnforcerChainDirName(NetworkDrynet); got != "bitcoin-drynet4" {
		t.Errorf("EnforcerChainDirName(drynet) = %q, want bitcoin-drynet4", got)
	}

	for network, want := range map[Network]string{
		NetworkMainnet: "bitcoin",
		NetworkForknet: "bitcoin",
		NetworkSignet:  "signet",
		NetworkRegtest: "regtest",
		NetworkTestnet: "testnet",
	} {
		if got := EnforcerChainDirName(network); got != want {
			t.Errorf("EnforcerChainDirName(%s) = %q, want %q", network, got, want)
		}
	}
}

// Reset gathers the enforcer's chain and wallet state by path; both must land
// in the generation's namespace or a drynet reset silently clears nothing.
func TestEnforcerResetPathsCarryTheGeneration(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	original := DrynetGeneration()
	t.Cleanup(func() { SetDrynetGeneration(original) })
	SetDrynetGeneration("drynet3")

	root := EnforcerDirs.RootDir()
	chain := filepath.Join(root, "validator", "bitcoin-drynet3")
	wallet := filepath.Join(root, "wallet", "bitcoin-drynet3")
	for _, d := range []string{chain, wallet} {
		if err := os.MkdirAll(d, 0o755); err != nil {
			t.Fatal(err)
		}
	}

	dataPaths := EnforcerDirs.GetBlockchainDataPaths(root, NetworkDrynet, zerolog.Nop())
	require.Contains(t, dataPaths, chain)

	walletPaths := EnforcerDirs.GetWalletPaths(root, NetworkDrynet, zerolog.Nop())
	require.Contains(t, walletPaths, wallet)
}

// Before the catalog resolves, the embedded generation keeps the URLs valid.
func TestDrynetGenerationFallsBackToEmbedded(t *testing.T) {
	original := DrynetGeneration()
	t.Cleanup(func() { SetDrynetGeneration(original) })

	SetDrynetGeneration("")
	if got := DrynetGeneration(); got == "" {
		t.Fatal("DrynetGeneration() must fall back to the embedded catalog")
	}
	if urls := EsploraURLsForNetwork(NetworkDrynet); len(urls) == 0 {
		t.Error("drynet must still resolve an esplora URL before the catalog loads")
	}
}
