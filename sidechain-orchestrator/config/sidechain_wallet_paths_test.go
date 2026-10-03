package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// A wallet reset must reach the wallet.mdb of every BitWindow wallet, not only
// the one the sidechain holds.
func TestWalletPathsIncludeTheParkedWalletOfEachWallet(t *testing.T) {
	// A glob character in the path must not change what the sweep finds.
	dir := filepath.Join(t.TempDir(), "data[1]")
	for _, name := range []string{"wallet.mdb", "wallet.mdb.network-wallet-A", "wallet.mdb.network-wallet-external", "wallet.mdb.network-ecash-alphanet", "data.mdb", "data.mdb.network-ecash-alphanet"} {
		require.NoError(t, os.MkdirAll(filepath.Join(dir, name), 0o755))
	}

	thunder, ok := DirConfigByName("thunder")
	require.True(t, ok)
	got := thunder.GetWalletPaths(dir, NetworkSignet, zerolog.Nop())

	require.ElementsMatch(t, []string{
		filepath.Join(dir, "wallet.mdb"),
		filepath.Join(dir, "wallet.mdb.network-wallet-A"),
		filepath.Join(dir, "wallet.mdb.network-wallet-external"),
		filepath.Join(dir, "wallet.mdb.network-ecash-alphanet"),
	}, got)
}
