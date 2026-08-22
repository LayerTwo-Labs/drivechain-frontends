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

// The seed makes the wallet; the path only says where to look first. On a
// network whose coin type is 1 the enforcer's account is the standard one, so a
// companion would be an exact duplicate of the wallet beside it.
func TestNoCompanionWhereTheEnforcerAccountIsStandard(t *testing.T) {
	svc := loadEnforcerWallet(t, config.NetworkSignet, "")
	assert.Len(t, svc.GetAllWallets(), 1, "the wallet already looks where the coins are")
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
