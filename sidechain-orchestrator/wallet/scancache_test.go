package wallet

import (
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func newScanCacheService(t *testing.T, dir string) *Service {
	t.Helper()
	svc := NewService(dir, zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.openElectrumDB())
	t.Cleanup(svc.Close)
	return svc
}

func scanWithAddress(walletID, address string, sats int64) *persistedScan {
	return &persistedScan{
		WalletID: walletID,
		Addrs: []persistedAddr{{
			Kind:    ScriptNativeSegwit,
			Address: address,
			Status:  "status-" + address,
			UTXOs:   []EsploraUTXO{{TxID: "deadbeef", Vout: 0, Value: sats}},
			Txs:     []EsploraTx{{TxID: "deadbeef"}},
		}},
	}
}

// Mainnet, forknet and drynet derive identical addresses, so a scan reachable
// from another network would report the previous chain's balance and UTXOs.
func TestNetworkScopedScanIsolation(t *testing.T) {
	dir := t.TempDir()
	svc := newScanCacheService(t, dir)

	const walletID = "wallet-1"
	require.NoError(t, svc.saveElectrumScan("signet", walletID, scanWithAddress(walletID, "bc1qsignet", 100000), 900))

	_, ok := svc.loadElectrumScan("signet", walletID)
	require.True(t, ok, "scan must be persisted for the network it was taken on")

	require.NoError(t, svc.RebindNetwork("drynet"))
	require.Equal(t, "drynet", svc.Network())

	_, ok = svc.loadElectrumScan("drynet", walletID)
	require.False(t, ok, "the previous network's scan must not be reachable")

	_, _, ok = svc.firstUnusedAddress("drynet", walletID, ScriptNativeSegwit, false)
	require.False(t, ok, "the previous network's addresses must not be served")

	require.FileExists(t, filepath.Join(dir, "electrum.db"))
}

// A wallet exists on every chain, so its history must survive a swap away and
// back rather than being re-walked from scratch.
func TestScanHistoryIsKeptPerNetwork(t *testing.T) {
	svc := newScanCacheService(t, t.TempDir())

	const walletID = "wallet-1"
	require.NoError(t, svc.saveElectrumScan("signet", walletID, scanWithAddress(walletID, "bc1qsignet", 100000), 900))
	require.NoError(t, svc.saveElectrumScan("drynet", walletID, scanWithAddress(walletID, "bc1qdrynet", 250000), 40))

	signet, ok := svc.loadElectrumScan("signet", walletID)
	require.True(t, ok)
	require.Equal(t, "bc1qsignet", signet.Addrs[0].Address)
	require.Equal(t, int64(100000), signet.Addrs[0].UTXOs[0].Value)
	require.Equal(t, "status-bc1qsignet", signet.Addrs[0].Status)

	drynet, ok := svc.loadElectrumScan("drynet", walletID)
	require.True(t, ok)
	require.Equal(t, "bc1qdrynet", drynet.Addrs[0].Address)
	require.Equal(t, int64(250000), drynet.Addrs[0].UTXOs[0].Value)
}

func TestSyncCheckpointRoundTrip(t *testing.T) {
	svc := newScanCacheService(t, t.TempDir())

	const walletID = "wallet-1"
	_, ok := svc.loadSyncCheckpoint("signet", walletID)
	require.False(t, ok, "no checkpoint before the first scan")

	require.NoError(t, svc.saveElectrumScan("signet", walletID, scanWithAddress(walletID, "bc1qsignet", 1), 900))
	require.NoError(t, svc.saveElectrumScan("drynet", walletID, scanWithAddress(walletID, "bc1qdrynet", 1), 40))

	tip, ok := svc.loadSyncCheckpoint("signet", walletID)
	require.True(t, ok)
	require.Equal(t, 900, tip)

	tip, ok = svc.loadSyncCheckpoint("drynet", walletID)
	require.True(t, ok)
	require.Equal(t, 40, tip, "each chain resumes from its own height")
}

// Deleting a wallet deletes it everywhere, so no chain may keep its rows.
func TestDeleteScanClearsEveryNetwork(t *testing.T) {
	svc := newScanCacheService(t, t.TempDir())

	const walletID = "wallet-1"
	require.NoError(t, svc.saveElectrumScan("signet", walletID, scanWithAddress(walletID, "bc1qsignet", 1), 900))
	require.NoError(t, svc.saveElectrumScan("drynet", walletID, scanWithAddress(walletID, "bc1qdrynet", 1), 40))

	svc.deleteElectrumScan(walletID)

	_, ok := svc.loadElectrumScan("signet", walletID)
	require.False(t, ok)
	_, ok = svc.loadElectrumScan("drynet", walletID)
	require.False(t, ok)
	_, ok = svc.loadSyncCheckpoint("signet", walletID)
	require.False(t, ok)
}

// A re-scan replaces the stored rows rather than accumulating them.
func TestSaveScanReplacesPreviousRows(t *testing.T) {
	svc := newScanCacheService(t, t.TempDir())

	const walletID = "wallet-1"
	require.NoError(t, svc.saveElectrumScan("signet", walletID, scanWithAddress(walletID, "bc1qold", 1), 900))
	require.NoError(t, svc.saveElectrumScan("signet", walletID, scanWithAddress(walletID, "bc1qnew", 2), 901))

	ps, ok := svc.loadElectrumScan("signet", walletID)
	require.True(t, ok)
	require.Len(t, ps.Addrs, 1)
	require.Equal(t, "bc1qnew", ps.Addrs[0].Address)
}
