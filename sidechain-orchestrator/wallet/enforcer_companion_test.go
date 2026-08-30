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

// The migration runs once, so a coin-type-1 network writes the companion too.
func TestCompanionEvenWhereTheEnforcerAccountIsStandard(t *testing.T) {
	svc := loadEnforcerWallet(t, config.NetworkSignet, "")
	require.Len(t, svc.GetAllWallets(), 2)
}

func TestCompanionOnTestnetWithoutPanic(t *testing.T) {
	svc := loadEnforcerWallet(t, config.NetworkTestnet, "")
	require.Len(t, svc.GetAllWallets(), 2)
}

// A first boot on signet must still leave the enforcer account for a later mainnet boot.
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

// eCash runs on mainnet params, so its coin type is 0. The
// enforcer still held coin type 1 there, and both networks serve an Esplora,
// so a user reaches them in light mode with real coins.
func TestCompanionOnNetworksThatRunMainnetParams(t *testing.T) {
	for _, network := range []config.Network{config.NetworkECash} {
		t.Run(string(network), func(t *testing.T) {
			svc := loadEnforcerWallet(t, network, "")
			require.Len(t, svc.GetAllWallets(), 2)
		})
	}
}

// The enforcer funded these wallets before BitWindow ever imported them into
// Core. Core imports a descriptor with importTimestamp, which reads a generated
// seed's birth and scans nothing before it. A migrated wallet
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

// Each migrated wallet gets its own companion: one with no passphrase must not
// hide the enforcer coins of a later wallet that has one.
func TestCompanionForEachMigratedWallet(t *testing.T) {
	const plain = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	const guarded = "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong"
	wallet := func(id, mnemonic, passphrase string) map[string]any {
		return map[string]any{
			"id":          id,
			"name":        id,
			"wallet_type": "enforcer",
			"master": map[string]any{
				"mnemonic": mnemonic,
				"seed_hex": hex.EncodeToString(MnemonicToSeed(mnemonic, passphrase)),
			},
		}
	}
	dir := t.TempDir()
	body, err := json.Marshal(map[string]any{
		"wallets":          []map[string]any{wallet("FIRST", plain, ""), wallet("SECOND", guarded, "a passphrase")},
		"active_wallet_id": "FIRST",
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork(string(config.NetworkSignet))
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	companions := map[string]string{}
	for _, w := range svc.GetAllWallets() {
		if w.ImportedFromEnforcer {
			companions[w.Master.Mnemonic] = w.Master.SeedHex
		}
	}
	assert.Equal(t, map[string]string{
		plain:   hex.EncodeToString(MnemonicToSeed(plain, "")),
		guarded: hex.EncodeToString(MnemonicToSeed(guarded, "")),
	}, companions)
}
