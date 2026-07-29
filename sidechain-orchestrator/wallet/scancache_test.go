package wallet

import (
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// Mainnet, forknet and drynet derive identical addresses, so a scan reachable
// from another network would report the previous chain's balance and UTXOs.
func TestPerNetworkDBIsolation(t *testing.T) {
	dir := t.TempDir()
	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.openElectrumDB())
	defer svc.Close()

	const walletID = "wallet-1"
	scan := &persistedScan{
		WalletID: walletID,
		Addrs: []persistedAddr{{
			Kind:    ScriptNativeSegwit,
			Address: "bc1qexampleaddress",
			UTXOs:   []EsploraUTXO{{TxID: "deadbeef", Vout: 0, Value: 100000}},
		}},
	}
	require.NoError(t, svc.saveElectrumScan(walletID, scan))
	_, ok := svc.loadElectrumScan(walletID)
	require.True(t, ok, "scan must be persisted before the swap")

	require.NoError(t, svc.RebindNetwork("drynet"))

	_, ok = svc.loadElectrumScan(walletID)
	require.False(t, ok, "the previous network's scan must not be reachable")

	_, _, ok = svc.firstUnusedAddress(walletID, ScriptNativeSegwit, false)
	require.False(t, ok, "the previous network's addresses must not be served")

	require.FileExists(t, filepath.Join(dir, "drynet", "electrum.db"))
	require.FileExists(t, filepath.Join(dir, "signet", "electrum.db"))
}
