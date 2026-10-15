package cheques_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
)

const testWalletID = "wallet-1"

func TestCreate_PanicsOnEmptyInput(t *testing.T) {
	db := database.Test(t)

	t.Run("empty wallet id", func(t *testing.T) {
		require.Panics(t, func() { _, _ = cheques.Create(t.Context(), db, "", 0, 1000, "addr-0") })
	})
	t.Run("empty address", func(t *testing.T) {
		require.Panics(t, func() { _, _ = cheques.Create(t.Context(), db, testWalletID, 0, 1000, "") })
	})
}

func TestGetNextIndex_SkipsDeletedSweptIndex(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()

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

	require.NoError(t, cheques.UpdateSwept(ctx, db, testWalletID, id, "bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000"))
	require.NoError(t, cheques.Delete(ctx, db, testWalletID, id))

	third, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	assert.EqualValues(t, 2, third)
}

func TestGetNextIndex_SkipsDeletedRecoveredIndex(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()

	txid := "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000"
	require.NoError(t, cheques.CreateOrUpdateFromRecovery(ctx, db, testWalletID, 4, "addr-4", []cheques.FundingOutput{{Txid: txid}}, 1000))

	recovered, err := cheques.GetByAddress(ctx, db, testWalletID, "addr-4")
	require.NoError(t, err)
	require.NoError(t, cheques.Delete(ctx, db, testWalletID, recovered.ID))

	next, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	assert.EqualValues(t, 5, next)
}

func TestGetNextIndex_PerWallet(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()

	_, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "addr-0")
	require.NoError(t, err)

	next, err := cheques.GetNextIndex(ctx, db, "wallet-2")
	require.NoError(t, err)
	assert.EqualValues(t, 0, next)
}

func TestUpdateFunding(t *testing.T) {
	db := database.Test(t)
	txid := "cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000"

	t.Run("records outputs and raises height", func(t *testing.T) {
		ctx := t.Context()
		id, err := cheques.Create(ctx, db, testWalletID, 10, 1000, "addr-10")
		require.NoError(t, err)

		require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id, []cheques.FundingOutput{{Txid: txid}}, 1000))
		require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id, []cheques.FundingOutput{{Txid: txid, BlockHeight: 7}}, 1000))

		got, err := cheques.Get(ctx, db, testWalletID, id)
		require.NoError(t, err)
		assert.Equal(t, []string{txid}, got.FundedTxids)
		require.NotNil(t, got.ActualAmountSats)
		assert.EqualValues(t, 1000, *got.ActualAmountSats)

		var height int64
		require.NoError(t, db.QueryRowContext(ctx, `SELECT block_height FROM cheque_funding_outputs WHERE cheque_id = ?`, id).Scan(&height))
		assert.EqualValues(t, 7, height)
	})

	t.Run("rolls back the amount when an output fails", func(t *testing.T) {
		ctx := t.Context()
		id, err := cheques.Create(ctx, db, testWalletID, 11, 1000, "addr-11")
		require.NoError(t, err)
		_, err = db.ExecContext(ctx, `
			CREATE TRIGGER reject_bad_output BEFORE INSERT ON cheque_funding_outputs
			WHEN NEW.txid = 'bad' BEGIN SELECT RAISE(ABORT, 'bad output'); END`)
		require.NoError(t, err)

		err = cheques.UpdateFunding(ctx, db, testWalletID, id, []cheques.FundingOutput{{Txid: "bad"}}, 1000)
		require.ErrorContains(t, err, "bad output")

		got, err := cheques.Get(ctx, db, testWalletID, id)
		require.NoError(t, err)
		assert.Nil(t, got.ActualAmountSats)
		assert.Nil(t, got.FundedAt)
	})
}

func TestList_AttachesEachChequeItsOwnOutputs(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	txA := "dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000dddd0000"
	txB := "eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000"

	idA, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "addr-a")
	require.NoError(t, err)
	idB, err := cheques.Create(ctx, db, testWalletID, 1, 1000, "addr-b")
	require.NoError(t, err)
	require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, idA, []cheques.FundingOutput{{Txid: txA}}, 1000))
	require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, idB, []cheques.FundingOutput{{Txid: txB}}, 1000))

	list, err := cheques.List(ctx, db, testWalletID)
	require.NoError(t, err)
	got := map[int64][]string{}
	for _, c := range list {
		got[c.ID] = c.FundedTxids
	}
	assert.Equal(t, map[int64][]string{idA: {txA}, idB: {txB}}, got)

	single, err := cheques.Get(ctx, db, testWalletID, idB)
	require.NoError(t, err)
	assert.Equal(t, []string{txB}, single.FundedTxids)
}
