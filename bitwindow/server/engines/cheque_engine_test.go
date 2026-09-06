package engines

import (
	"context"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

const chequeWalletID = "80CEBA2163224572BDEADD2D2181C51B"

func testChequeEngine(t *testing.T, chain ChequeChain) *ChequeEngine {
	t.Helper()

	dir := t.TempDir()
	walletData, err := json.Marshal(map[string]any{
		"version":        1,
		"activeWalletId": chequeWalletID,
		"wallets": []map[string]any{{
			"version":     1,
			"master":      map[string]any{"seed_hex": "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"},
			"id":          chequeWalletID,
			"name":        "test",
			"wallet_type": "bitcoinCore",
		}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletData, 0o600))

	walletEngine := NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return nil, nil },
		dir,
		&chaincfg.SigNetParams,
	)
	return NewChequeEngine(database.Test(t), walletEngine, &chaincfg.SigNetParams, chain)
}

func TestScanForFundsReportsFundedIndex(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	engine := testChequeEngine(t, chain)

	address, err := engine.DeriveChequeAddress(chequeWalletID, 3)
	require.NoError(t, err)
	chain.funded[address] = testUTXOs()

	recoveries, err := engine.ScanForFunds(context.Background(), chequeWalletID, 20)
	require.NoError(t, err)
	require.Len(t, recoveries, 1)
	require.Equal(t, uint32(3), recoveries[0].Index)
	require.Equal(t, address, recoveries[0].Address)
	require.Equal(t, uint64(100_000), recoveries[0].Amount)
	require.Equal(t, []string{testUTXOs()[0].TxID}, recoveries[0].Txids)
	require.Len(t, chain.queried, 20, "the scan reads every index up to the count")
}

// A cheque that only exists on chain must come back into the DB under the
// scanning wallet, and must not be duplicated by a second scan.
func TestRecoverChequesOnUnlockPersistsFundedCheques(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	engine := testChequeEngine(t, chain)
	ctx := context.Background()

	address, err := engine.DeriveChequeAddress(chequeWalletID, 0)
	require.NoError(t, err)
	chain.funded[address] = testUTXOs()

	// The unencrypted fixture auto-unlocks; without it the recovery blocks.
	require.True(t, engine.walletEngine.IsUnlocked())

	engine.recoverChequesOnUnlock(ctx)
	engine.recoverChequesOnUnlock(ctx)

	list, err := cheques.List(ctx, engine.db, chequeWalletID)
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, uint32(0), list[0].DerivationIndex)
	require.Equal(t, address, list[0].Address)
	require.Equal(t, []string{testUTXOs()[0].TxID}, list[0].FundedTxids)
	require.True(t, list[0].IsFunded())

	next, err := cheques.GetNextIndex(ctx, engine.db, chequeWalletID)
	require.NoError(t, err)
	require.Equal(t, uint32(1), next)
}

// A chain read that fails means the electrum backend is down, so the scan must
// not report an empty wallet.
func TestScanForFundsReturnsChainError(t *testing.T) {
	chain := &fakeChain{err: errors.New("electrum backend not configured")}
	engine := testChequeEngine(t, chain)

	_, err := engine.ScanForFunds(context.Background(), chequeWalletID, 20)
	require.ErrorContains(t, err, "electrum backend not configured")
}
