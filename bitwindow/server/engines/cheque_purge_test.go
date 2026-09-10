package engines

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/stretchr/testify/require"
)

func TestAForkPurgeKeepsChequeHistoryBelowTheFork(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	const wallet = "w1"

	_, err := db.ExecContext(ctx, `INSERT INTO processed_blocks (height, block_hash, txids, block_time) VALUES
		(90, 'h90', '["fundShared","sweepShared","fundKept","fundSplitShared"]', CURRENT_TIMESTAMP),
		(110, 'h110', '["fundOld","sweepOld","fundSplitOld"]', CURRENT_TIMESTAMP)`)
	require.NoError(t, err)

	cheque := func(index uint32, funds []cheques.FundingOutput, sweep string) int64 {
		id, err := cheques.Create(ctx, db, wallet, index, 1000, "addr"+funds[0].Txid)
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(ctx, db, wallet, id, funds, 1000))
		if sweep != "" {
			require.NoError(t, cheques.UpdateSwept(ctx, db, wallet, id, sweep))
		}
		return id
	}
	fundedOnOldFork := cheque(0, []cheques.FundingOutput{{Txid: "fundOld"}}, "swept_externally")
	fundedOnOldForkLight := cheque(1, []cheques.FundingOutput{{Txid: "fundLight", BlockHeight: 105}}, "")
	sweptBeforeFork := cheque(2, []cheques.FundingOutput{{Txid: "fundShared"}}, "sweepShared")
	sweptOnOldFork := cheque(3, []cheques.FundingOutput{{Txid: "fundKept"}}, "sweepOld")
	fundedAtUnknownHeight := cheque(4, []cheques.FundingOutput{{Txid: "fundUnknown"}}, "")
	fundedOnBothSides := cheque(5, []cheques.FundingOutput{{Txid: "fundSplitShared"}, {Txid: "fundSplitOld"}}, "")

	require.NoError(t, ResetChainData(ctx, db, 100))

	get := func(id int64) *cheques.Cheque {
		c, err := cheques.Get(ctx, db, wallet, id)
		require.NoError(t, err)
		return c
	}
	for _, id := range []int64{fundedOnOldFork, fundedOnOldForkLight} {
		c := get(id)
		require.False(t, c.IsFunded(), "cheque %d", id)
		require.Nil(t, c.ActualAmountSats, "cheque %d", id)
		require.Nil(t, c.FundedAt, "cheque %d", id)
		require.Empty(t, c.FundedTxids, "cheque %d", id)
		require.Nil(t, c.SweptTxid, "cheque %d", id)
	}

	c := get(sweptBeforeFork)
	require.True(t, c.IsFunded())
	require.Equal(t, []string{"fundShared"}, c.FundedTxids)
	require.Equal(t, "sweepShared", *c.SweptTxid)

	c = get(sweptOnOldFork)
	require.True(t, c.IsFunded())
	require.Nil(t, c.SweptTxid)

	c = get(fundedAtUnknownHeight)
	require.True(t, c.IsFunded())
	require.Equal(t, []string{"fundUnknown"}, c.FundedTxids)

	c = get(fundedOnBothSides)
	require.Nil(t, c.ActualAmountSats, "the total counted an output the new chain lacks")
	require.NotNil(t, c.FundedAt)
	require.Equal(t, []string{"fundSplitShared"}, c.FundedTxids)
}
