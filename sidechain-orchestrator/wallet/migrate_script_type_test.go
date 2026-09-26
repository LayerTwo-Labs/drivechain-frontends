package wallet

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Core imported the kind a standard path names, so a Core wallet stores that
// kind. An electrum wallet keeps the chain it already scans.
func TestCoreWalletStoresTheScriptTypeOfItsPath(t *testing.T) {
	dir := t.TempDir()
	body, err := json.Marshal(map[string]any{
		"wallets": []map[string]any{
			{"id": "CORE44", "name": "Core legacy", "wallet_type": "bitcoinCore", "derivation_path": "m/44'/1'/0'"},
			{"id": "CORE86", "name": "Core taproot", "wallet_type": "bitcoinCore", "derivation_path": "m/86'/1'/0'", "script_type": "taproot"},
			{"id": "ELEC86", "name": "Electrum", "wallet_type": "electrum", "derivation_path": "m/86'/1'/0'"},
		},
		"activeWalletId": "CORE44",
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))

	for range 2 {
		svc := NewService(dir, zerolog.Nop())
		svc.SetNetwork(string(config.NetworkSignet))
		require.NoError(t, svc.Init())

		assert.Equal(t, "legacy", svc.GetWalletByID("CORE44").ScriptType)
		assert.Equal(t, "taproot", svc.GetWalletByID("CORE86").ScriptType)
		elec := svc.GetWalletByID("ELEC86")
		assert.Empty(t, elec.ScriptType)
		assert.Equal(t, []ScriptKind{ScriptNativeSegwit}, ReceiveKinds(elec))
		svc.Close()
	}
}
