package wallet

import (
	"encoding/hex"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func loadEnforcerWallet(t *testing.T, network config.Network, passphrase string) *Service {
	t.Helper()
	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

	dir := t.TempDir()
	body, err := json.Marshal(map[string]any{
		"wallets": []map[string]any{{
			"id":          "OLD",
			"name":        "My Wallet",
			"wallet_type": "enforcer",
			"master": map[string]any{
				"mnemonic": mnemonic,
				"seed_hex": hex.EncodeToString(MnemonicToSeed(mnemonic, passphrase)),
			},
		}},
		"active_wallet_id": "OLD",
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork(string(network))
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	return svc
}

// On a network whose coin type is 1 the enforcer's account is the standard one,
// so the companion is a duplicate view of the wallet beside it. It is still
// written: the migration only runs once, and the next boot may be mainnet.
func TestCompanionEvenWhereTheEnforcerAccountIsStandard(t *testing.T) {
	svc := loadEnforcerWallet(t, config.NetworkSignet, "")
	require.Len(t, svc.GetAllWallets(), 2)
}

// wallet.json outlives the boot that migrated it, and the migration never runs
// again. A first boot on signet must still leave the enforcer's account on
// disk, or a later mainnet boot — which derives m/84'/0'/0' — reads a zero
// balance over untouched coins.
func TestTheEnforcerAccountOutlivesTheBootNetwork(t *testing.T) {
	first := loadEnforcerWallet(t, config.NetworkSignet, "")
	dir := first.bitwindowDir
	first.Close()

	later := NewService(dir, zerolog.Nop())
	later.SetNetwork(string(config.NetworkMainnet))
	require.NoError(t, later.Init())
	t.Cleanup(func() { later.Close() })

	wallets := later.GetAllWallets()
	var found *WalletData
	for i := range wallets {
		if wallets[i].ImportedFromEnforcer {
			found = &wallets[i]
		}
	}
	require.NotNil(t, found, "the enforcer's account must outlive the boot network")
	assert.Equal(t, EnforcerAccountPath, found.DerivationPath)
}

// On mainnet the enforcer's coin type 1 is not the standard account, so its
// coins live in a tree the wallet would never scan.
func TestCompanionOnMainnetWhereTheAccountDiffers(t *testing.T) {
	svc := loadEnforcerWallet(t, config.NetworkMainnet, "")
	require.Len(t, svc.GetAllWallets(), 2)
}

// A passphrase changes the seed, so the enforcer's tree differs on every
// network — including one whose coin type already matches.
func TestCompanionWhenAPassphraseChangesTheSeed(t *testing.T) {
	svc := loadEnforcerWallet(t, config.NetworkSignet, "a passphrase the enforcer never saw")
	require.Len(t, svc.GetAllWallets(), 2)
}

// Forknet and ecash run on mainnet params, so their coin type is 0. The
// enforcer still held coin type 1 there, and both networks serve an Esplora,
// so a user reaches them in light mode with real coins.
func TestCompanionOnNetworksThatRunMainnetParams(t *testing.T) {
	for _, network := range []config.Network{config.NetworkForknet, config.NetworkECash} {
		t.Run(string(network), func(t *testing.T) {
			svc := loadEnforcerWallet(t, network, "")
			require.Len(t, svc.GetAllWallets(), 2)
		})
	}
}

// The enforcer funded these wallets before BitWindow ever imported them into
// Core. Core imports a descriptor with importTimestamp, which reads "now" for a
// freshly generated seed and scans nothing before the tip. A migrated wallet
// that keeps that default reads a zero balance, which is what the migration
// exists to prevent.
func TestMigratedWalletsRescanFromGenesis(t *testing.T) {
	// Regtest has no chain source, so the migration lands these on Core, which
	// is the backend the birthday matters to.
	svc := loadEnforcerWallet(t, config.NetworkRegtest, "a passphrase the enforcer never saw")

	wallets := svc.GetAllWallets()
	require.Len(t, wallets, 2)
	for _, w := range wallets {
		assert.True(t, w.Imported, "%s must rescan, not start at the tip", w.Name)
		assert.Equal(t, int64(0), importTimestamp(&w), "%s must import from genesis", w.Name)
	}
}
