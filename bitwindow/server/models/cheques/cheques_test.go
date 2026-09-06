package cheques_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
)

const testWalletID = "wallet-1"

// Each index maps to one HD address, so reissuing a deleted cheque's index
// would send new funds to an address an old payer may still hold.
func TestGetNextIndex_SkipsDeletedIndex(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	first, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	assert.EqualValues(t, 0, first)
	_, err = cheques.Create(ctx, db, testWalletID, first, 1000, "addr-0")
	require.NoError(t, err)

	second, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	assert.EqualValues(t, 1, second)
	id, err := cheques.Create(ctx, db, testWalletID, second, 1000, "addr-1")
	require.NoError(t, err)

	require.NoError(t, cheques.Delete(ctx, db, testWalletID, id))

	third, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	assert.EqualValues(t, 2, third, "a deleted cheque's index must not be handed out again")
}

func TestGetNextIndex_SkipsDeletedRecoveredIndex(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	txid := "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000"
	require.NoError(t, cheques.CreateOrUpdateFromRecovery(ctx, db, testWalletID, 4, "addr-4", []string{txid}, 1000))

	recovered, err := cheques.GetByAddress(ctx, db, testWalletID, "addr-4")
	require.NoError(t, err)
	require.NoError(t, cheques.Delete(ctx, db, testWalletID, recovered.ID))

	next, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	assert.EqualValues(t, 5, next)
}

func TestGetNextIndex_PerWallet(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	_, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "addr-0")
	require.NoError(t, err)

	next, err := cheques.GetNextIndex(ctx, db, "wallet-2")
	require.NoError(t, err)
	assert.EqualValues(t, 0, next, "another wallet's cheques must not advance this one")
}
