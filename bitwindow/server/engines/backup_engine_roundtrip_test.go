package engines

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"github.com/stretchr/testify/require"
)

// Exporting and re-importing transactions.json must preserve every field.
func TestExportTransactionsJSON_RoundTrip(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	store := multisig.NewStore(db)
	e := &BackupEngine{db: db, walletDir: t.TempDir(), multisigStore: store}

	require.NoError(t, store.SaveGroup(ctx, multisig.Group{
		ID:   "group-1",
		Name: "Test Group",
	}))

	broadcastTime := int64(1751600000)
	signedAt := int64(1751500000)
	want := multisig.Transaction{
		ID:                 "tx-1",
		GroupID:            "group-1",
		InitialPSBT:        "cHNidP8BAHECAAAAinitial",
		CombinedPSBT:       "cHNidP8BAHECAAAAcombined",
		FinalHex:           "0200000001abcd",
		Txid:               "f00dbabe",
		Status:             5, // broadcasted
		Type:               2, // withdrawal
		Created:            1751400000,
		BroadcastTime:      &broadcastTime,
		Amount:             1.5,
		Destination:        "bc1qexampledestination",
		Fee:                0.0001,
		Confirmations:      3,
		RequiredSignatures: 2,
	}
	wantPSBTs := []multisig.TxKeyPSBT{
		{TransactionID: "tx-1", KeyID: "key-a", PSBT: "cHNidP8BAHECAAAAa", IsSigned: true, SignedAt: &signedAt},
		{TransactionID: "tx-1", KeyID: "key-b", PSBT: "cHNidP8BAHECAAAAb", IsSigned: false},
	}
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: want,
		KeyPSBTs:    wantPSBTs,
		Inputs: []multisig.TxInput{
			{TransactionID: "tx-1", Txid: "input-txid", Vout: 1, Address: "bc1qinput", Amount: 2.0, Confirmations: 6},
		},
	}))

	txJSON, err := e.exportTransactionsJSON(ctx)
	require.NoError(t, err)
	require.NotNil(t, txJSON)

	// Wipe the transaction, then restore it from the exported file.
	_, err = db.ExecContext(ctx, `DELETE FROM multisig_transactions WHERE id = ?`, want.ID)
	require.NoError(t, err)
	require.NoError(t, store.ImportTransactionsFromJSON(ctx, txJSON))

	got, err := store.GetTransaction(ctx, want.ID)
	require.NoError(t, err)
	require.NotNil(t, got)

	require.Equal(t, want.InitialPSBT, got.InitialPSBT)
	require.Equal(t, want.CombinedPSBT, got.CombinedPSBT)
	require.Equal(t, want.FinalHex, got.FinalHex)
	require.Equal(t, want.Txid, got.Txid)
	require.Equal(t, want.Status, got.Status, "status must survive the round trip")
	require.Equal(t, want.Type, got.Type, "type must survive the round trip")
	require.Equal(t, want.Created, got.Created, "created must survive the round trip")
	require.NotNil(t, got.BroadcastTime, "broadcastTime must survive the round trip")
	require.Equal(t, broadcastTime, *got.BroadcastTime)
	require.Equal(t, want.Amount, got.Amount)
	require.Equal(t, want.Destination, got.Destination)
	require.Equal(t, want.Fee, got.Fee)

	gotPSBTs, err := store.ListTxKeyPSBTs(ctx, want.ID)
	require.NoError(t, err)
	require.Len(t, gotPSBTs, 2)

	byKey := map[string]multisig.TxKeyPSBT{}
	for _, kp := range gotPSBTs {
		byKey[kp.KeyID] = kp
	}
	require.Equal(t, "cHNidP8BAHECAAAAa", byKey["key-a"].PSBT)
	require.True(t, byKey["key-a"].IsSigned, "isSigned must survive the round trip")
	require.NotNil(t, byKey["key-a"].SignedAt, "signedAt must survive the round trip")
	require.Equal(t, signedAt, *byKey["key-a"].SignedAt)
	require.False(t, byKey["key-b"].IsSigned)
}
