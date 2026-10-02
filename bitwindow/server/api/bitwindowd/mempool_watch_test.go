package api_bitwindowd_test

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
)

func TestService_MempoolWatch(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	db := database.Test(t)
	require.NoError(t, mempooltx.UpsertPending(ctx, db, []mempooltx.Tx{
		{Txid: "low", FeeSats: 100, Vsize: 100, FeeRate: 1, FirstSeenAt: time.Now(), FirstSeenHeight: 10},
		{Txid: "high", FeeSats: 5000, Vsize: 100, FeeRate: 50, FirstSeenAt: time.Now(), FirstSeenHeight: 10},
	}))
	require.NoError(t, mempooltx.MarkMined(ctx, db, []string{"low"}, 12))
	require.NoError(t, mempooltx.UpsertSeen(ctx, db, []string{"blind"}, 12, time.Now()))
	require.NoError(t, mempooltx.PutBlockStats(ctx, db, 11, 20, 20_000_000))
	require.NoError(t, mempooltx.PutBlockStats(ctx, db, 12, 1, 5_000_000))

	mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	apitests.ExpectOrchestratorReads(mockOrch)
	cli := bitwindowdv1connect.NewBitwindowdServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	status, err := cli.GetMempoolWatchStatus(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.False(t, status.Msg.Enabled)
	require.EqualValues(t, 2, status.Msg.PendingCount)
	require.EqualValues(t, 1, status.Msg.MinedCount)

	list, err := cli.ListMempoolTransactions(ctx, connect.NewRequest(&v1.ListMempoolTransactionsRequest{
		SortBy:         v1.MempoolTxSort_MEMPOOL_TX_SORT_FEE_RATE,
		SortDescending: true,
	}))
	require.NoError(t, err)
	require.EqualValues(t, 3, list.Msg.Total)
	require.Equal(t, "high", list.Msg.Transactions[0].Txid)
	require.Equal(t, v1.MempoolTxStatus_MEMPOOL_TX_STATUS_PENDING, list.Msg.Transactions[0].Status)
	require.True(t, list.Msg.Transactions[0].HasDetails)
	require.Equal(t, v1.MempoolTxStatus_MEMPOOL_TX_STATUS_MINED, list.Msg.Transactions[1].Status)
	require.EqualValues(t, 12, list.Msg.Transactions[1].GetResolvedHeight())
	require.NotNil(t, list.Msg.Transactions[1].ResolvedAt)
	require.Equal(t, "blind", list.Msg.Transactions[2].Txid)
	require.False(t, list.Msg.Transactions[2].HasDetails)
	require.Nil(t, list.Msg.Transactions[0].ResolvedHeight)

	stats, err := cli.ListBlockStats(ctx, connect.NewRequest(&v1.ListBlockStatsRequest{FromHeight: 11, ToHeight: 12}))
	require.NoError(t, err)
	require.Len(t, stats.Msg.Blocks, 2)
	require.EqualValues(t, 20, stats.Msg.Blocks[0].MinFeeRate)
	require.EqualValues(t, 5_000_000, stats.Msg.Blocks[1].TotalFeeSats)

	list, err = cli.ListMempoolTransactions(ctx, connect.NewRequest(&v1.ListMempoolTransactionsRequest{
		MinFeeRate: 10,
	}))
	require.NoError(t, err)
	require.EqualValues(t, 1, list.Msg.Total)
	require.Equal(t, "high", list.Msg.Transactions[0].Txid)

	_, err = cli.SetMempoolWatch(ctx, connect.NewRequest(&v1.SetMempoolWatchRequest{Enabled: true}))
	require.NoError(t, err)
	status, err = cli.GetMempoolWatchStatus(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.True(t, status.Msg.Enabled)

	_, err = cli.SetMempoolWatch(ctx, connect.NewRequest(&v1.SetMempoolWatchRequest{Enabled: false}))
	require.NoError(t, err)
	status, err = cli.GetMempoolWatchStatus(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.False(t, status.Msg.Enabled)
	require.False(t, status.Msg.Running)
}
