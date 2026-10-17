package walletpsbt_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/walletpsbt"
)

func TestSaveGeneratesIDAndTimestamps(t *testing.T) {
	store := walletpsbt.NewStore(database.Test(t))
	ctx := t.Context()

	saved, err := store.Save(ctx, walletpsbt.Draft{
		WalletID:   "wallet-1",
		PSBTBase64: "cHNidP8B",
	})
	require.NoError(t, err)
	assert.Len(t, saved.ID, 16)
	assert.NotZero(t, saved.CreatedAt)
	assert.Equal(t, saved.CreatedAt, saved.UpdatedAt)
}

func TestSaveSetsCreatedAtForANewClientID(t *testing.T) {
	store := walletpsbt.NewStore(database.Test(t))

	saved, err := store.Save(t.Context(), walletpsbt.Draft{
		ID:         "client-id",
		WalletID:   "wallet-1",
		PSBTBase64: "cHNidP8B",
	})
	require.NoError(t, err)
	assert.Equal(t, "client-id", saved.ID)
	assert.NotZero(t, saved.CreatedAt)
	assert.Equal(t, saved.CreatedAt, saved.UpdatedAt)
}

func TestSaveRefusesADraftOfAnotherWallet(t *testing.T) {
	store := walletpsbt.NewStore(database.Test(t))
	ctx := t.Context()

	first, err := store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "aaa"})
	require.NoError(t, err)

	_, err = store.Save(ctx, walletpsbt.Draft{ID: first.ID, WalletID: "wallet-2", PSBTBase64: "bbb"})
	require.ErrorIs(t, err, walletpsbt.ErrOtherWallet)

	drafts, err := store.List(ctx, "wallet-1")
	require.NoError(t, err)
	require.Len(t, drafts, 1)
	assert.Equal(t, "aaa", drafts[0].PSBTBase64)
}

func TestSaveRequiresWalletID(t *testing.T) {
	store := walletpsbt.NewStore(database.Test(t))

	_, err := store.Save(t.Context(), walletpsbt.Draft{PSBTBase64: "cHNidP8B"})
	require.ErrorContains(t, err, "wallet id is required")
}

func TestListByWallet(t *testing.T) {
	store := walletpsbt.NewStore(database.Test(t))
	ctx := t.Context()

	_, err := store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "aaa"})
	require.NoError(t, err)
	_, err = store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "bbb"})
	require.NoError(t, err)
	_, err = store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-2", PSBTBase64: "ccc"})
	require.NoError(t, err)

	one, err := store.List(ctx, "wallet-1")
	require.NoError(t, err)
	assert.Len(t, one, 2)

	two, err := store.List(ctx, "wallet-2")
	require.NoError(t, err)
	assert.Len(t, two, 1)
	assert.Equal(t, "ccc", two[0].PSBTBase64)
}

func TestSecondSaveReplacesPSBTAndMovesUpdatedAt(t *testing.T) {
	db := database.Test(t)
	store := walletpsbt.NewStore(db)
	ctx := t.Context()

	first, err := store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "before"})
	require.NoError(t, err)

	const age = 5000
	_, err = db.ExecContext(ctx, `UPDATE wallet_psbt_drafts SET updated_at = updated_at - ?`, age)
	require.NoError(t, err)
	first.PSBTBase64 = "after"
	first.Label = "Rent for August"
	second, err := store.Save(ctx, first)
	require.NoError(t, err)

	assert.Equal(t, first.ID, second.ID)
	assert.Equal(t, "after", second.PSBTBase64)
	assert.Equal(t, "Rent for August", second.Label)
	assert.Equal(t, first.CreatedAt, second.CreatedAt)

	drafts, err := store.List(ctx, "wallet-1")
	require.NoError(t, err)
	require.Len(t, drafts, 1)
	assert.Greater(t, drafts[0].UpdatedAt, first.UpdatedAt-age)
}

func TestDelete(t *testing.T) {
	store := walletpsbt.NewStore(database.Test(t))
	ctx := t.Context()

	saved, err := store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "aaa"})
	require.NoError(t, err)

	require.NoError(t, store.Delete(ctx, saved.ID))

	drafts, err := store.List(ctx, "wallet-1")
	require.NoError(t, err)
	assert.Empty(t, drafts)

	// A second delete of the same id is a no-op.
	require.NoError(t, store.Delete(ctx, saved.ID))
}
