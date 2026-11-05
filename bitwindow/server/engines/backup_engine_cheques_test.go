package engines

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
)

func TestBackupKeepsChequeRecoveryRange(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	source := testChequeEngine(t, chain)
	address, err := source.DeriveChequeAddress(t.Context(), chequeWalletID, 25)
	require.NoError(t, err)
	id, err := cheques.Create(t.Context(), source.db, chequeWalletID, 25, 100_000, address)
	require.NoError(t, err)
	_, err = source.db.ExecContext(t.Context(), `UPDATE cheques SET funded_txid = 'old-receipt' WHERE id = ?`, id)
	require.NoError(t, err)
	chain.funded[address] = testUTXOs()
	before, err := source.ScanForFunds(t.Context(), chequeWalletID, chequeGapLimit)
	require.NoError(t, err)
	require.Len(t, before, 1)
	sourceDir := t.TempDir()
	walletData := []byte(fmt.Sprintf(`{"wallets":[{"id":%q,"master":{"seed_hex":%q},"l1":{}}]}`, chequeWalletID, chequeSeedHex))
	require.NoError(t, os.WriteFile(filepath.Join(sourceDir, "wallet.json"), walletData, 0o600))
	data, filename, err := NewBackupEngine(source.db, sourceDir, "signet").CreateBackup(t.Context())
	require.NoError(t, err)
	restored := testChequeEngine(t, chain)
	restoreDir := t.TempDir()
	require.NoError(t, NewBackupEngine(restored.db, restoreDir, "signet").RestoreBackup(t.Context(), data, filename))
	row, err := cheques.GetByAddress(t.Context(), restored.db, chequeWalletID, address)
	require.NoError(t, err)
	require.NotNil(t, row.LegacyFundedTxid)
	require.Equal(t, "old-receipt", *row.LegacyFundedTxid)
	gotWallet, err := os.ReadFile(filepath.Join(restoreDir, "wallet.json"))
	require.NoError(t, err)
	require.Equal(t, walletData, gotWallet)
	index, err := cheques.GetNextIndex(t.Context(), restored.db, chequeWalletID)
	require.NoError(t, err)
	t.Logf("restored cheque counter: %d", index)
	after, err := restored.ScanForFunds(t.Context(), chequeWalletID, chequeGapLimit)
	require.NoError(t, err)
	require.Equal(t, before, after)
}

func TestBackupDoesNotReuseChequeKey(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	source := testChequeEngine(t, chain)
	oldAddress, err := source.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	oldKey, err := source.DeriveChequePrivateKey(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	id, err := cheques.Create(t.Context(), source.db, chequeWalletID, 0, 100_000, oldAddress)
	require.NoError(t, err)
	require.NoError(t, cheques.UpdateFunding(t.Context(), source.db, chequeWalletID, id,
		[]cheques.FundingOutput{{Txid: "receipt", ValueSats: 100_000}}, 100_000))
	require.NoError(t, cheques.UpdateSwept(t.Context(), source.db, chequeWalletID, id, "paid"))
	sourceDir := t.TempDir()
	walletData := []byte(fmt.Sprintf(`{"wallets":[{"id":%q,"master":{"seed_hex":%q},"l1":{}}]}`, chequeWalletID, chequeSeedHex))
	require.NoError(t, os.WriteFile(filepath.Join(sourceDir, "wallet.json"), walletData, 0o600))
	data, filename, err := NewBackupEngine(source.db, sourceDir, "signet").CreateBackup(t.Context())
	require.NoError(t, err)
	restored := testChequeEngine(t, chain)
	require.NoError(t, NewBackupEngine(restored.db, t.TempDir(), "signet").RestoreBackup(t.Context(), data, filename))
	restored.recoverChequesOnUnlock(t.Context())
	index, err := cheques.GetNextIndex(t.Context(), restored.db, chequeWalletID)
	require.NoError(t, err)
	newKey, err := restored.DeriveChequePrivateKey(t.Context(), chequeWalletID, index)
	require.NoError(t, err)
	if newKey == oldKey {
		t.Fatalf("restored wallet reused cheque index %d and its disclosed private key", index)
	}
}

func TestBackupKeepsDeletedChequeIndexes(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	source := testChequeEngine(t, chain)
	id, err := cheques.Create(t.Context(), source.db, chequeWalletID, 25, 100_000, "issued")
	require.NoError(t, err)
	require.NoError(t, cheques.Delete(t.Context(), source.db, chequeWalletID, id))
	dir := t.TempDir()
	walletData := []byte(fmt.Sprintf(`{"wallets":[{"id":%q,"master":{"seed_hex":%q},"l1":{}}]}`, chequeWalletID, chequeSeedHex))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletData, 0o600))
	data, filename, err := NewBackupEngine(source.db, dir, "signet").CreateBackup(t.Context())
	require.NoError(t, err)
	restored := testChequeEngine(t, chain)
	backup := NewBackupEngine(restored.db, t.TempDir(), "signet")
	require.NoError(t, backup.RestoreBackup(t.Context(), data, filename))
	index, err := cheques.GetNextIndex(t.Context(), restored.db, chequeWalletID)
	require.NoError(t, err)
	require.Equal(t, uint32(26), index)
	id, err = cheques.Create(t.Context(), restored.db, chequeWalletID, 40, 100_000, "later")
	require.NoError(t, err)
	require.NoError(t, cheques.Delete(t.Context(), restored.db, chequeWalletID, id))
	require.NoError(t, backup.RestoreBackup(t.Context(), data, filename))
	index, err = cheques.GetNextIndex(t.Context(), restored.db, chequeWalletID)
	require.NoError(t, err)
	require.Equal(t, uint32(41), index)
}

func TestBackupRejectsChequesFromAnotherNetwork(t *testing.T) {
	source := testChequeEngine(t, &fakeChain{})
	_, err := cheques.Create(t.Context(), source.db, chequeWalletID, 25, 100_000, "issued")
	require.NoError(t, err)
	dir := t.TempDir()
	walletData := []byte(fmt.Sprintf(`{"wallets":[{"id":%q,"master":{"seed_hex":%q},"l1":{}}]}`, chequeWalletID, chequeSeedHex))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletData, 0o600))
	data, filename, err := NewBackupEngine(source.db, dir, "signet").CreateBackup(t.Context())
	require.NoError(t, err)
	restored := testChequeEngine(t, &fakeChain{})
	destination := t.TempDir()
	backup := NewBackupEngine(restored.db, destination, "mainnet")
	require.ErrorContains(t, backup.RestoreBackup(t.Context(), data, filename), "cheque backup uses network")
	_, err = os.Stat(filepath.Join(destination, "wallet.json"))
	require.ErrorIs(t, err, os.ErrNotExist)
	index, err := cheques.GetNextIndex(t.Context(), restored.db, chequeWalletID)
	require.NoError(t, err)
	require.Zero(t, index)
}
