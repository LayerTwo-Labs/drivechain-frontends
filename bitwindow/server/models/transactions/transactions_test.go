package transactions_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
)

// The same transaction can appear in two of the user's wallets. A note written
// on one must not show up on the other.
func TestSetNote_ScopedToWallet(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	const sharedTxid = "shared-txid"
	require.NoError(t, transactions.SetNote(ctx, db, "wallet-a", sharedTxid, "note for A"))
	require.NoError(t, transactions.SetNote(ctx, db, "wallet-b", sharedTxid, "note for B"))

	notesA, err := transactions.ListByWallet(ctx, db, "wallet-a")
	require.NoError(t, err)
	require.Len(t, notesA, 1)
	require.Equal(t, "note for A", notesA[0].Note)

	notesB, err := transactions.ListByWallet(ctx, db, "wallet-b")
	require.NoError(t, err)
	require.Len(t, notesB, 1)
	require.Equal(t, "note for B", notesB[0].Note, "wallet B must keep its own note for the same txid")

	notesC, err := transactions.ListByWallet(ctx, db, "wallet-c")
	require.NoError(t, err)
	require.Empty(t, notesC, "a wallet with no notes must see none")
}

// Writing the same txid twice on one wallet updates rather than duplicates.
func TestSetNote_UpsertsWithinWallet(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	require.NoError(t, transactions.SetNote(ctx, db, "wallet-a", "txid-1", "first"))
	require.NoError(t, transactions.SetNote(ctx, db, "wallet-a", "txid-1", "second"))

	notes, err := transactions.ListByWallet(ctx, db, "wallet-a")
	require.NoError(t, err)
	require.Len(t, notes, 1)
	require.Equal(t, "second", notes[0].Note)
}

func TestSetNote_RequiresWalletAndTxid(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	require.Panics(t, func() { _ = transactions.SetNote(ctx, db, "", "txid-1", "note") })
	require.ErrorIs(t, transactions.SetNote(ctx, db, "wallet-a", "", "note"), transactions.ErrEmptyTxID)
}
