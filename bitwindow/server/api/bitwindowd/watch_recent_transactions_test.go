package bitwindowd_test

import (
	"context"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	v1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	mempoolpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1"
	mempoolrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1/mempoolv1connect"
)

// feedMempool sends an empty snapshot, then one added change per tx on added.
type feedMempool struct {
	*fakeMempool
	added chan *mempoolpb.Transaction
}

func (f *feedMempool) WatchTransactions(ctx context.Context, _ *mempoolpb.WatchTransactionsRequest, stream mempoolrpc.MempoolServiceWatchTransactionsServerStream) error {
	if err := stream.Send(&mempoolpb.WatchTransactionsResponse{Snapshot: &mempoolpb.Snapshot{}}); err != nil {
		return err
	}
	for {
		select {
		case <-ctx.Done():
			return nil
		case tx := <-f.added:
			f.mu.Lock()
			f.txs = append([]*mempoolpb.Transaction{tx}, f.txs...)
			f.mu.Unlock()
			change := &mempoolpb.Change{Change: &mempoolpb.Change_Added{Added: tx}}
			if err := stream.Send(&mempoolpb.WatchTransactionsResponse{Changes: []*mempoolpb.Change{change}}); err != nil {
				return err
			}
		}
	}
}

func TestWatchRecentTransactionsSendsEachNewTx(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	bitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	apitests.ExpectCoreWalletSetup(bitcoind)
	bitcoind.EXPECT().
		GetBlockchainInfo(gomock.Any(), gomock.Any()).
		Return(&connectv1.Response[corepb.GetBlockchainInfoResponse]{
			Msg: &corepb.GetBlockchainInfoResponse{Blocks: 1, BestBlockHash: "blockhash1"},
		}, nil).
		AnyTimes()
	bitcoind.EXPECT().
		GetBlock(gomock.Any(), gomock.Any()).
		Return(&connectv1.Response[corepb.GetBlockResponse]{
			Msg: &corepb.GetBlockResponse{Height: 1, Hash: "blockhash1", Time: timestamppb.New(time.Unix(1, 0))},
		}, nil).
		Times(1)

	mempool := &feedMempool{fakeMempool: &fakeMempool{}, added: make(chan *mempoolpb.Transaction)}
	cli := v1connect.NewBitwindowdServiceClient(apitests.RPC(t, database.Test(t), apitests.WithBitcoind(bitcoind), apitests.WithMempool(mempool)))
	ctx, cancel := context.WithTimeout(t.Context(), 10*time.Second)
	defer cancel()
	stream, err := cli.WatchRecentTransactions(ctx, &v1.ListRecentTransactionsRequest{Count: 20})
	require.NoError(t, err)

	first, err := stream.Receive()
	require.NoError(t, err)
	require.Empty(t, first.GetTransactions())

	for n, txid := range []string{"tx1", "tx2", "tx3"} {
		start := time.Now()
		mempool.added <- &mempoolpb.Transaction{Txid: txid, Vsize: 100, FeeSats: 200, Time: timestamppb.New(time.Unix(int64(10+n), 0))}
		next, err := stream.Receive()
		require.NoError(t, err)
		require.False(t, next.GetHeartbeat())
		require.Less(t, time.Since(start), 2*time.Second, "the feed sends the change, not the recheck")
		require.Len(t, next.GetTransactions(), n+1)
		require.Equal(t, txid, next.GetTransactions()[0].GetTxid())
	}
	for _, count := range mempool.counts() {
		require.Equal(t, uint32(20), count, "drivechaind sends only the newest count")
	}
}

func TestWatchRecentTransactionsEndsWithTheFeed(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	bitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	apitests.ExpectCoreWalletSetup(bitcoind)

	cli := v1connect.NewBitwindowdServiceClient(apitests.RPC(t, database.Test(t), apitests.WithBitcoind(bitcoind), apitests.WithMempool(&fakeMempool{})))
	ctx, cancel := context.WithTimeout(t.Context(), 10*time.Second)
	defer cancel()
	stream, err := cli.WatchRecentTransactions(ctx, &v1.ListRecentTransactionsRequest{Count: 20})
	require.NoError(t, err)
	for {
		_, err = stream.Receive()
		if err != nil {
			break
		}
	}
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err), "the code of drivechaind is not the code of bitwindowd")
	require.ErrorContains(t, err, "drivechaind: watch mempool")
}
