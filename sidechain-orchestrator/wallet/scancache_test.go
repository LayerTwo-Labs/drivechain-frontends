package wallet

import (
	"context"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// Mainnet, forknet and drynet derive identical addresses, so a scan surviving a
// switch would report the previous chain's balance and UTXOs.
func TestClearElectrumScansDropsPersistedChainState(t *testing.T) {
	ctx := context.Background()

	db, err := OpenElectrumDB(ctx, filepath.Join(t.TempDir(), "electrum.db"))
	require.NoError(t, err)
	defer func() { _ = db.Close() }()

	svc := &Service{electrumDB: db}

	const walletID = "wallet-1"
	scan := &persistedScan{
		WalletID: walletID,
		Addrs: []persistedAddr{{
			Address: "bc1qexampleaddress",
			UTXOs:   []EsploraUTXO{{TxID: "deadbeef", Vout: 0, Value: 100000}},
		}},
	}
	require.NoError(t, svc.saveElectrumScan(walletID, scan))

	_, ok := svc.loadElectrumScan(walletID)
	require.True(t, ok, "scan must be persisted before the switch")

	require.NoError(t, svc.clearElectrumScans())

	_, ok = svc.loadElectrumScan(walletID)
	require.False(t, ok, "a network switch must not leave the previous chain's scan on disk")
}
