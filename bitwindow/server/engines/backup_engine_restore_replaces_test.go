package engines

import (
	"archive/zip"
	"bytes"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"github.com/stretchr/testify/require"
)

// Group IDs are short hashes, so a restored group can collide with one already
// in the DB. Restoring must replace the multisig data, not merge into it, or
// the previous wallet's transactions are read back as the restored group's.
func TestRestoreBackup_ReplacesExistingMultisigData(t *testing.T) {
	ctx := testCtx()
	db := database.Test(t)
	store := multisig.NewStore(db)
	e := &BackupEngine{db: db, walletDir: t.TempDir(), multisigStore: store}

	// The wallet being replaced: one group colliding with the backup's, one not.
	require.NoError(t, store.SaveGroup(ctx, multisig.Group{ID: "shared-id", Name: "Old Group", N: 2, M: 2}))
	require.NoError(t, store.SaveGroup(ctx, multisig.Group{ID: "old-only", Name: "Other Old Group", N: 2, M: 2}))
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: multisig.Transaction{ID: "tx-old", GroupID: "shared-id", InitialPSBT: "psbt-old", Status: 1, Type: 1},
		Inputs:      []multisig.TxInput{{TransactionID: "tx-old", Txid: "old-input", Vout: 0, Amount: 1.0}},
	}))
	require.NoError(t, store.AddSoloKey(ctx, multisig.SoloKey{Xpub: "tpubOld", DerivationPath: "m/84'/1'/0'"}))

	multisigJSON := []byte(`{
		"groups": [
			{
				"id": "shared-id",
				"name": "Restored Group",
				"n": 2,
				"m": 3,
				"created": 1751400000,
				"transaction_ids": ["tx-new"]
			}
		],
		"solo_keys": []
	}`)
	txJSON := []byte(`[
		{
			"id": "tx-new",
			"groupId": "shared-id",
			"initialPSBT": "psbt-new",
			"status": "needsSignatures",
			"type": "deposit",
			"created": "2025-07-01T00:00:00Z"
		}
	]`)

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	require.NoError(t, addToZip(zw, "wallet.json", []byte(`{"master":"restored seed","l1":"restored key"}`)))
	require.NoError(t, addToZip(zw, "multisig/multisig.json", multisigJSON))
	require.NoError(t, addToZip(zw, "transactions.json", txJSON))
	require.NoError(t, zw.Close())

	require.NoError(t, e.RestoreBackup(ctx, buf.Bytes(), "backup.zip"))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1, "groups from the replaced wallet must not survive")
	require.Equal(t, "shared-id", groups[0].ID)
	require.Equal(t, "Restored Group", groups[0].Name)

	txns, err := store.ListTransactions(ctx, "shared-id")
	require.NoError(t, err)
	require.Len(t, txns, 1, "the replaced wallet's transaction must not be attributed to the restored group")
	require.Equal(t, "tx-new", txns[0].ID)

	inputs, err := store.ListTxInputs(ctx, "tx-old")
	require.NoError(t, err)
	require.Empty(t, inputs, "child rows of the replaced wallet's transactions must go too")

	soloKeys, err := store.ListSoloKeys(ctx)
	require.NoError(t, err)
	require.Empty(t, soloKeys, "solo keys from the replaced wallet must not survive")
}

// A backup that fails to import must not leave the multisig tables cleared.
func TestRestoreBackup_FailedImport_KeepsExistingMultisigData(t *testing.T) {
	ctx := testCtx()
	db := database.Test(t)
	store := multisig.NewStore(db)
	e := &BackupEngine{db: db, walletDir: t.TempDir(), multisigStore: store}

	require.NoError(t, store.SaveGroup(ctx, multisig.Group{ID: "old-only", Name: "Old Group", N: 2, M: 2}))

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	require.NoError(t, addToZip(zw, "wallet.json", []byte(`{"master":"backup seed","l1":"backup key"}`)))
	require.NoError(t, addToZip(zw, "multisig/multisig.json", []byte(`"not an object"`)))
	require.NoError(t, zw.Close())

	require.Error(t, e.RestoreBackup(ctx, buf.Bytes(), "backup.zip"))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1, "a failed restore must roll the clear back")
	require.Equal(t, "old-only", groups[0].ID)
}
