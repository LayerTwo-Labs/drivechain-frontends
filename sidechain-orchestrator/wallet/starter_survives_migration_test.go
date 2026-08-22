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

// The migration rewrites a passphrase wallet's seed to reach the enforcer's
// coins. Sidechain starters derive from that seed, so a re-derivation would
// hand every sidechain a different seed and strand the user's L2 coins.
func TestSidechainStartersSurviveTheSeedRewrite(t *testing.T) {
	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	const passphrase = "one the enforcer never saw"
	const thunderStarter = "the starter thunder already runs on"

	dir := t.TempDir()
	legacy := map[string]any{
		"wallets": []map[string]any{{
			"id":          "OLD",
			"name":        "Enforcer",
			"wallet_type": "enforcer",
			"master": map[string]any{
				"mnemonic": mnemonic,
				"seed_hex": hex.EncodeToString(MnemonicToSeed(mnemonic, passphrase)),
			},
			"sidechains": []map[string]any{
				{"slot": 9, "name": "Thunder", "mnemonic": thunderStarter},
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

	got, err := svc.GetOrDeriveSidechainStarter(9, "Thunder")
	require.NoError(t, err)
	assert.Equal(t, thunderStarter, got, "a stored starter is authoritative")

	// A slot with no starter yet still gets one.
	fresh, err := svc.GetOrDeriveSidechainStarter(5, "BitNames")
	require.NoError(t, err)
	assert.NotEmpty(t, fresh)
	assert.NotEqual(t, thunderStarter, fresh)
}
