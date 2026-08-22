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

// The enforcer derived m/84'/1'/0' on every network, mainnet included. Losing
// that account would show a zero balance over untouched mainnet coins.
func TestEnforcerWalletMigratesToElectrumAndKeepsItsAccount(t *testing.T) {
	dir := t.TempDir()
	legacy := map[string]any{
		"wallets": []map[string]any{{
			"id":          "OLD",
			"name":        "Enforcer",
			"wallet_type": "enforcer",
			"master":      map[string]any{"mnemonic": "abandon abandon about"},
		}},
		"active_wallet_id": "OLD",
	}
	body, err := json.Marshal(legacy)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork(string(config.NetworkMainnet))
	require.NoError(t, svc.Init())
	defer svc.Close()

	w := svc.GetWalletByID("OLD")
	require.NotNil(t, w)
	assert.Equal(t, WalletTypeElectrum, w.WalletType)
	assert.Empty(t, w.DerivationPath, "the user's wallet keeps the account this network uses")
}

// Regtest serves no Esplora, so an electrum wallet there could never read a
// chain. The account still has to survive.
func TestEnforcerWalletMigratesToCoreWhereNoEsplora(t *testing.T) {
	dir := t.TempDir()
	legacy := map[string]any{
		"wallets": []map[string]any{{
			"id":          "OLD",
			"name":        "Enforcer",
			"wallet_type": "enforcer",
			"master":      map[string]any{"mnemonic": "abandon abandon about"},
		}},
		"active_wallet_id": "OLD",
	}
	body, err := json.Marshal(legacy)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork(string(config.NetworkRegtest))
	require.NoError(t, svc.Init())
	defer svc.Close()

	w := svc.GetWalletByID("OLD")
	require.NotNil(t, w)
	assert.Equal(t, WalletTypeBitcoinCore, w.WalletType)
	assert.Empty(t, w.DerivationPath, "the user's wallet keeps the account this network uses")
}

// A second run must not touch a wallet the first run already moved.
func TestEnforcerWalletMigrationRunsTwiceSafely(t *testing.T) {
	dir := t.TempDir()
	legacy := map[string]any{
		"wallets": []map[string]any{{
			"id":              "OLD",
			"name":            "Enforcer",
			"wallet_type":     "enforcer",
			"derivation_path": "m/84'/0'/7'",
			"master":          map[string]any{"mnemonic": "abandon abandon about"},
		}},
		"active_wallet_id": "OLD",
	}
	body, err := json.Marshal(legacy)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork(string(config.NetworkMainnet))
	require.NoError(t, svc.Init())
	svc.Close()

	svc2 := NewService(dir, zerolog.Nop())
	svc2.SetNetwork(string(config.NetworkMainnet))
	require.NoError(t, svc2.Init())
	defer svc2.Close()

	w := svc2.GetWalletByID("OLD")
	require.NotNil(t, w)
	assert.Equal(t, WalletTypeElectrum, w.WalletType)
	assert.Equal(t, "m/84'/0'/7'", w.DerivationPath, "a path the user set stays their own")
	assert.Len(t, svc2.GetAllWallets(), 2, "a second run adds no second enforcer wallet")
}

// The enforcer derived from the bare mnemonic on an account BitWindow would
// never use. Pinning the user's wallet there would carry that bug forward, so
// the coins arrive in a second wallet instead, and the user's own wallet keeps
// its seed and its per-network path.
func TestEnforcerCoinsArriveInTheirOwnWallet(t *testing.T) {
	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	const passphrase = "one the enforcer never saw"

	withPassphrase := hex.EncodeToString(MnemonicToSeed(mnemonic, passphrase))
	whatTheEnforcerUsed := hex.EncodeToString(MnemonicToSeed(mnemonic, ""))
	require.NotEqual(t, withPassphrase, whatTheEnforcerUsed)

	dir := t.TempDir()
	legacy := map[string]any{
		"wallets": []map[string]any{{
			"id":          "OLD",
			"name":        "My Wallet",
			"wallet_type": "enforcer",
			"master": map[string]any{
				"mnemonic": mnemonic,
				"seed_hex": withPassphrase,
			},
		}},
		"active_wallet_id": "OLD",
	}
	body, err := json.Marshal(legacy)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork(string(config.NetworkMainnet))
	require.NoError(t, svc.Init())
	defer svc.Close()

	own := svc.GetWalletByID("OLD")
	require.NotNil(t, own)
	assert.Equal(t, WalletTypeElectrum, own.WalletType)
	assert.Equal(t, withPassphrase, own.Master.SeedHex, "the user's own seed is untouched")
	assert.Empty(t, own.DerivationPath, "so it derives the account this network uses")

	wallets := svc.GetAllWallets()
	require.Len(t, wallets, 2, "the enforcer's own coins get a wallet")

	var found *WalletData
	for i := range wallets {
		if wallets[i].ImportedFromEnforcer {
			found = &wallets[i]
		}
	}
	require.NotNil(t, found, "the enforcer wallet must be marked")
	assert.Equal(t, EnforcerAccountPath, found.DerivationPath)
	assert.Equal(t, whatTheEnforcerUsed, found.Master.SeedHex)
	assert.Contains(t, found.Name, "enforcer")
}
