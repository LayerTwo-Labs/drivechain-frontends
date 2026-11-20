package bitwindowd_test

import (
	"context"
	"sync/atomic"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

func TestWatchSyncInfoSendsAChange(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	ctrl := gomock.NewController(t)
	var headers atomic.Int32
	headers.Store(100)

	bitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	apitests.ExpectCoreWalletSetup(bitcoind)
	bitcoind.EXPECT().
		GetBlockchainInfo(gomock.Any(), gomock.Any()).
		DoAndReturn(func(context.Context, *connectv1.Request[corepb.GetBlockchainInfoRequest]) (*connectv1.Response[corepb.GetBlockchainInfoResponse], error) {
			return &connectv1.Response[corepb.GetBlockchainInfoResponse]{
				Msg: &corepb.GetBlockchainInfoResponse{Blocks: 90, Headers: uint32(headers.Load())},
			}, nil
		}).
		AnyTimes()
	bitcoind.EXPECT().
		GetRawMempool(gomock.Any(), gomock.Any()).
		Return(&connectv1.Response[corepb.GetRawMempoolResponse]{Msg: &corepb.GetRawMempoolResponse{}}, nil).
		AnyTimes()
	bitcoind.EXPECT().
		GetBlockHash(gomock.Any(), gomock.Any()).
		Return(nil, assert.AnError).
		AnyTimes()

	cli := v1connect.NewBitwindowdServiceClient(apitests.RPC(t, db, apitests.WithBitcoind(bitcoind)))
	ctx, cancel := context.WithTimeout(t.Context(), 10*time.Second)
	defer cancel()
	stream, err := cli.WatchSyncInfo(ctx, &emptypb.Empty{})
	require.NoError(t, err)

	first, err := stream.Receive()
	require.NoError(t, err)
	assert.Equal(t, int64(100), first.GetInfo().GetHeaderHeight())

	headers.Store(101)
	for {
		next, err := stream.Receive()
		require.NoError(t, err)
		if next.GetHeartbeat() {
			continue
		}
		assert.Equal(t, int64(101), next.GetInfo().GetHeaderHeight())
		return
	}
}
