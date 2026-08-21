package walletpsbt_test

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/walletpsbt"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func setupTestDB(t *testing.T) *sql.DB {
	t.Helper()

	db, err := sql.Open("sqlite3", ":memory:?_foreign_keys=on")
	require.NoError(t, err)

	// Replicate the schema from migration 045.
	_, err = db.Exec(`CREATE TABLE wallet_psbt_drafts (
		id TEXT PRIMARY KEY,
		wallet_id TEXT NOT NULL,
		label TEXT NOT NULL DEFAULT '',
		psbt_base64 TEXT NOT NULL,
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL,
		txid TEXT NOT NULL DEFAULT ''
	)`)
	require.NoError(t, err)

	t.Cleanup(func() { _ = db.Close() })
	return db
}

func TestSaveGeneratesIDAndTimestamps(t *testing.T) {
	store := walletpsbt.NewStore(setupTestDB(t))
	ctx := context.Background()

	saved, err := store.Save(ctx, walletpsbt.Draft{
		WalletID:   "wallet-1",
		PSBTBase64: "cHNidP8B",
	})
	require.NoError(t, err)
	assert.Len(t, saved.ID, 16)
	assert.NotZero(t, saved.CreatedAt)
	assert.Equal(t, saved.CreatedAt, saved.UpdatedAt)
}

func TestSaveRequiresWalletID(t *testing.T) {
	store := walletpsbt.NewStore(setupTestDB(t))

	_, err := store.Save(context.Background(), walletpsbt.Draft{PSBTBase64: "cHNidP8B"})
	require.Error(t, err)
}

func TestListByWallet(t *testing.T) {
	store := walletpsbt.NewStore(setupTestDB(t))
	ctx := context.Background()

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
	store := walletpsbt.NewStore(setupTestDB(t))
	ctx := context.Background()

	base := time.Now()
	store.SetClock(func() time.Time { return base })

	first, err := store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "before"})
	require.NoError(t, err)

	store.SetClock(func() time.Time { return base.Add(5 * time.Second) })
	first.PSBTBase64 = "after"
	first.Label = "Rent for August"
	second, err := store.Save(ctx, first)
	require.NoError(t, err)

	assert.Equal(t, first.ID, second.ID)
	assert.Equal(t, "after", second.PSBTBase64)
	assert.Equal(t, "Rent for August", second.Label)
	assert.Equal(t, first.CreatedAt, second.CreatedAt)
	assert.Greater(t, second.UpdatedAt, first.UpdatedAt)

	drafts, err := store.List(ctx, "wallet-1")
	require.NoError(t, err)
	assert.Len(t, drafts, 1)
}

func TestDelete(t *testing.T) {
	store := walletpsbt.NewStore(setupTestDB(t))
	ctx := context.Background()

	saved, err := store.Save(ctx, walletpsbt.Draft{WalletID: "wallet-1", PSBTBase64: "aaa"})
	require.NoError(t, err)

	require.NoError(t, store.Delete(ctx, saved.ID))

	drafts, err := store.List(ctx, "wallet-1")
	require.NoError(t, err)
	assert.Empty(t, drafts)

	// A second delete of the same id is a no-op.
	require.NoError(t, store.Delete(ctx, saved.ID))
}
