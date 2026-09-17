package api_bitwindowd_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
)

// GetSyncInfo reports the wait the parser takes, so the daemon card says why
// its heights stand still.
func TestGetSyncInfoWaitsForCore(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		network config.Network
		inIBD   bool
		want    bool
	}{
		{"mainnet in IBD waits", config.NetworkMainnet, true, true},
		{"mainnet past IBD does not wait", config.NetworkMainnet, false, false},
		{"regtest in IBD does not wait", config.NetworkRegtest, true, false},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			db := database.Test(t)
			ctrl := gomock.NewController(t)

			bitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
			apitests.ExpectCoreWalletSetup(bitcoind)
			bitcoind.EXPECT().
				GetBlockchainInfo(gomock.Any(), gomock.Any()).
				Return(&connect.Response[corepb.GetBlockchainInfoResponse]{
					Msg: &corepb.GetBlockchainInfoResponse{
						Blocks:               900_000,
						Headers:              967_362,
						InitialBlockDownload: tc.inIBD,
					},
				}, nil).
				AnyTimes()
			bitcoind.EXPECT().
				GetRawMempool(gomock.Any(), gomock.Any()).
				Return(&connect.Response[corepb.GetRawMempoolResponse]{
					Msg: &corepb.GetRawMempoolResponse{},
				}, nil).
				AnyTimes()
			bitcoind.EXPECT().
				GetBlockHash(gomock.Any(), gomock.Any()).
				Return(nil, assert.AnError).
				AnyTimes()

			cli := v1connect.NewBitwindowdServiceClient(apitests.API(t, db,
				apitests.WithBitcoind(bitcoind),
				apitests.WithNetwork(tc.network),
			))

			res, err := cli.GetSyncInfo(context.Background(), connect.NewRequest(&emptypb.Empty{}))
			require.NoError(t, err)
			assert.Equal(t, tc.want, res.Msg.WaitsForCore)
			assert.Equal(t, int64(967_362), res.Msg.HeaderHeight)
		})
	}
}
