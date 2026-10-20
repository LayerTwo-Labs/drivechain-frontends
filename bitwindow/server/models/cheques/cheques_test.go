package cheques_test

import (
	"database/sql"
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

func TestUpdateFundingClearsSweep(t *testing.T) {
	for _, recovery := range []bool{false, true} {
		name := "a funding check clears the sweep"
		if recovery {
			name = "recovery clears the sweep"
		}
		t.Run(name, func(t *testing.T) {
			db := database.Test(t)
			ctx := t.Context()
			id, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "addr-0")
			require.NoError(t, err)
			require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id,
				[]cheques.FundingOutput{{Txid: "first", ValueSats: 1000}}, 1000))
			first, err := cheques.Get(ctx, db, testWalletID, id)
			require.NoError(t, err)
			require.NoError(t, cheques.UpdateSwept(ctx, db, testWalletID, id, "sweep"))

			outputs := []cheques.FundingOutput{{Txid: "second", Vout: 2, ValueSats: 500}}
			if recovery {
				err = cheques.CreateOrUpdateFromRecovery(ctx, db, testWalletID, 0, "addr-0", outputs, 500)
			} else {
				err = cheques.UpdateFunding(ctx, db, testWalletID, id, outputs, 500)
			}
			require.NoError(t, err)

			got, err := cheques.Get(ctx, db, testWalletID, id)
			require.NoError(t, err)
			assert.Nil(t, got.SweptTxid)
			assert.Nil(t, got.SweptAt)
			assert.Equal(t, first.FundedAt, got.FundedAt)
			assert.Equal(t, uint64(1000), got.ExpectedAmountSats)
			require.NotNil(t, got.ActualAmountSats)
			assert.Equal(t, uint64(500), *got.ActualAmountSats)
			assert.ElementsMatch(t, []string{"first", "second"}, got.FundedTxids)
		})
	}
}

func TestUpdateFundingKeepsDistinctOutputs(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	id, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "addr-0")
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `
		INSERT INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats, block_height)
		VALUES (?, 'old', 0, 0, 5), (?, 'current', 0, 0, 7)
	`, id, id)
	require.NoError(t, err)

	outputs := []cheques.FundingOutput{
		{Txid: "current", ValueSats: 600, BlockHeight: 7},
		{Txid: "current", Vout: 2, ValueSats: 400, BlockHeight: 7},
	}
	for range 2 {
		require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id, outputs, 1000))
	}
	outputs[0].BlockHeight = 0
	outputs[1].BlockHeight = 0
	require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id, outputs, 1000))

	type outputRow struct {
		Txid        string `db:"txid"`
		Vout        int32  `db:"vout"`
		ValueSats   int64  `db:"value_sats"`
		BlockHeight uint32 `db:"block_height"`
	}
	rows, err := database.Select[outputRow](ctx, db, `
		SELECT txid, vout, value_sats, block_height
		FROM cheque_funding_outputs WHERE cheque_id = ? ORDER BY txid, vout
	`, id)
	require.NoError(t, err)
	assert.Equal(t, []outputRow{
		{Txid: "current", ValueSats: 600, BlockHeight: 7},
		{Txid: "current", Vout: 2, ValueSats: 400, BlockHeight: 7},
		{Txid: "old", BlockHeight: 5},
	}, rows)

	got, err := cheques.Get(ctx, db, testWalletID, id)
	require.NoError(t, err)
	assert.ElementsMatch(t, []string{"old", "current"}, got.FundedTxids)
}

func TestUpdateFundingKeepsSweepOnError(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	id, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "addr-0")
	require.NoError(t, err)
	require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id,
		[]cheques.FundingOutput{{Txid: "first", ValueSats: 1000}}, 1000))
	require.NoError(t, cheques.UpdateSwept(ctx, db, testWalletID, id, "sweep"))
	first, err := cheques.Get(ctx, db, testWalletID, id)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `
		CREATE TRIGGER reject_output BEFORE INSERT ON cheque_funding_outputs
		BEGIN SELECT RAISE(ABORT, 'output error'); END
	`)
	require.NoError(t, err)

	err = cheques.UpdateFunding(ctx, db, testWalletID, id,
		[]cheques.FundingOutput{{Txid: "second", ValueSats: 500}}, 500)
	require.ErrorContains(t, err, "output error")

	got, err := cheques.Get(ctx, db, testWalletID, id)
	require.NoError(t, err)
	assert.Equal(t, first, got)
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

func TestGet(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	id, err := cheques.Create(t.Context(), db, testWalletID, 0, 1000, "addr-get")
	require.NoError(t, err)

	for _, tt := range []struct {
		name     string
		walletID string
		id       int64
		wantErr  error
	}{
		{name: "an own cheque reads", walletID: testWalletID, id: id},
		{name: "a missing id is no rows", walletID: testWalletID, id: id + 1, wantErr: sql.ErrNoRows},
		{name: "another wallet is no rows", walletID: "wallet-2", id: id, wantErr: sql.ErrNoRows},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			cheque, err := cheques.Get(t.Context(), db, tt.walletID, tt.id)
			if tt.wantErr != nil {
				require.ErrorIs(t, err, tt.wantErr)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, id, cheque.ID)
			assert.Equal(t, "addr-get", cheque.Address)
			assert.Equal(t, uint64(1000), cheque.ExpectedAmountSats)
		})
	}
}

func TestGetByAddress(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	id, err := cheques.Create(t.Context(), db, testWalletID, 0, 1000, "addr-by-address")
	require.NoError(t, err)

	for _, tt := range []struct {
		name     string
		walletID string
		address  string
		wantErr  error
	}{
		{name: "an own address reads", walletID: testWalletID, address: "addr-by-address"},
		{name: "a missing address is no rows", walletID: testWalletID, address: "addr-missing", wantErr: sql.ErrNoRows},
		{name: "another wallet is no rows", walletID: "wallet-2", address: "addr-by-address", wantErr: sql.ErrNoRows},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			cheque, err := cheques.GetByAddress(t.Context(), db, tt.walletID, tt.address)
			if tt.wantErr != nil {
				require.ErrorIs(t, err, tt.wantErr)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, id, cheque.ID)
		})
	}
}

func TestUpdateSwept(t *testing.T) {
	t.Parallel()

	const txid = "cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000cccc0000"
	for _, tt := range []struct {
		name     string
		walletID string
		idOffset int64
		wantErr  error
	}{
		{name: "an own cheque becomes swept", walletID: testWalletID},
		{name: "a missing id is no rows", walletID: testWalletID, idOffset: 1, wantErr: sql.ErrNoRows},
		{name: "another wallet is no rows", walletID: "wallet-2", wantErr: sql.ErrNoRows},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			db := database.Test(t)
			id, err := cheques.Create(t.Context(), db, testWalletID, 0, 1000, "addr-swept")
			require.NoError(t, err)

			err = cheques.UpdateSwept(t.Context(), db, tt.walletID, id+tt.idOffset, txid)
			cheque, getErr := cheques.Get(t.Context(), db, testWalletID, id)
			require.NoError(t, getErr)
			if tt.wantErr != nil {
				require.ErrorIs(t, err, tt.wantErr)
				assert.Nil(t, cheque.SweptTxid)
				return
			}
			require.NoError(t, err)
			require.NotNil(t, cheque.SweptTxid)
			assert.Equal(t, txid, *cheque.SweptTxid)
			assert.NotNil(t, cheque.SweptAt)
		})
	}
}

func TestDelete(t *testing.T) {
	db := database.Test(t)
	txid := "ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000"

	countOutputs := func(t *testing.T, id int64) int {
		var n int
		require.NoError(t, db.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM cheque_funding_outputs WHERE cheque_id = ?`, id).Scan(&n))
		return n
	}

	t.Run("deletes the funding outputs", func(t *testing.T) {
		ctx := t.Context()
		id, err := cheques.Create(ctx, db, testWalletID, 20, 1000, "addr-20")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id, []cheques.FundingOutput{{Txid: txid}}, 1000))

		require.NoError(t, cheques.Delete(ctx, db, testWalletID, id))

		assert.Zero(t, countOutputs(t, id))
		_, err = cheques.Get(ctx, db, testWalletID, id)
		require.ErrorIs(t, err, sql.ErrNoRows)
	})

	t.Run("other wallet keeps the cheque and its outputs", func(t *testing.T) {
		ctx := t.Context()
		id, err := cheques.Create(ctx, db, testWalletID, 21, 1000, "addr-21")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(ctx, db, testWalletID, id, []cheques.FundingOutput{{Txid: txid}}, 1000))

		err = cheques.Delete(ctx, db, "wallet-2", id)
		require.ErrorIs(t, err, sql.ErrNoRows)

		assert.Equal(t, 1, countOutputs(t, id))
		_, err = cheques.Get(ctx, db, testWalletID, id)
		require.NoError(t, err)
	})

	t.Run("a missing id is no rows", func(t *testing.T) {
		ctx := t.Context()
		id, err := cheques.Create(ctx, db, testWalletID, 22, 1000, "addr-22")
		require.NoError(t, err)

		err = cheques.Delete(ctx, db, testWalletID, id+1)
		require.ErrorIs(t, err, sql.ErrNoRows)

		_, err = cheques.Get(ctx, db, testWalletID, id)
		require.NoError(t, err)
	})
}
