package api_bitwindowd_test

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect"
	api_bitwindowd "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitwindowd"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	v1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/miningpools"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// offlineRegistry keeps a test off the network: every refresh fails, so the
// registry serves its built-in list.
func offlineRegistry(context.Context, string) ([]byte, error) {
	return nil, errors.New("the test has no network")
}

const regtestPools = `{
  "network": "regtest",
  "pools": [
    {"name": "Alpha Pool", "mode": "pplns", "fee_bps": 100, "coinbase_tag": "/alpha/",
     "stratum_url": "stratum+tcp://alpha.example:3334"},
    {"name": "Beta Pool", "mode": "solo", "fee_bps": 0, "coinbase_tag": "/beta/"}
  ]
}`

// regtestRegistry serves the pools of a regtest datadir file, once the first
// refresh read it.
func regtestRegistry(t *testing.T) *miningpools.Registry {
	t.Helper()
	datadir := t.TempDir()
	path := filepath.Join(datadir, miningpools.RegtestFile)
	require.NoError(t, os.WriteFile(path, []byte(regtestPools), 0o600))

	registry := miningpools.New(context.Background(), config.NetworkRegtest, "", datadir, nil)
	require.Eventually(t, func() bool {
		return registry.Pools().Source == "file://"+path
	}, 5*time.Second, 10*time.Millisecond)
	return registry
}

func coinbase(height uint32, hash, tag string, at time.Time, txCount uint32) coinbases.Coinbase {
	return coinbases.Coinbase{
		Height:    height,
		Hash:      hash,
		BlockTime: at,
		Bits:      0x207fffff,
		TxCount:   txCount,
		Script:    []byte("\x03\x01\x02\x03" + tag),
	}
}

func TestService_ListMiningPools(t *testing.T) {
	t.Parallel()

	t.Run("splits the window by pool", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		now := time.Now()
		require.NoError(t, coinbases.Put(context.Background(), db, []coinbases.Coinbase{
			coinbase(10, "old", "/alpha/", now.Add(-48*time.Hour), 2),
			coinbase(11, "h11", "/alpha/", now.Add(-3*time.Hour), 2),
			coinbase(12, "h12", "/alpha/", now.Add(-2*time.Hour), 1),
			coinbase(13, "h13", "/nobody/", now.Add(-1*time.Hour), 3),
		}))
		server := api_bitwindowd.New(nil, db, nil, nil, regtestRegistry(t), config.Config{}, nil)

		response, err := server.ListMiningPools(context.Background(), connect.NewRequest(&v1.ListMiningPoolsRequest{}))
		require.NoError(t, err)

		msg := response.Msg
		assert.EqualValues(t, 3, msg.BlockCount)
		assert.EqualValues(t, 11, msg.FromHeight)
		assert.EqualValues(t, 13, msg.ToHeight)
		assert.True(t, msg.RegistryAvailable)
		assert.Contains(t, msg.RegistrySource, miningpools.RegtestFile)
		assert.Positive(t, msg.NetworkHashrate)

		require.Len(t, msg.Pools, 3)
		alpha := msg.Pools[0]
		assert.Equal(t, "Alpha Pool", alpha.Pool.Name)
		assert.Equal(t, "alphapool", alpha.Pool.Slug)
		assert.Equal(t, "stratum+tcp://alpha.example:3334", alpha.Pool.StratumUrl)
		assert.EqualValues(t, 100, alpha.Pool.FeeBps)
		assert.EqualValues(t, 2, alpha.BlockCount)
		assert.EqualValues(t, 1, alpha.EmptyBlocks)
		assert.InDelta(t, 2.0/3, alpha.Share, 1e-9)
		assert.InDelta(t, msg.NetworkHashrate*2/3, alpha.EstimatedHashrate, 1e-3)

		assert.Equal(t, miningpools.Unknown.Name, msg.Pools[1].Pool.Name)
		assert.EqualValues(t, 1, msg.Pools[1].BlockCount)
		assert.Equal(t, "Beta Pool", msg.Pools[2].Pool.Name)
		assert.Zero(t, msg.Pools[2].BlockCount)
	})

	t.Run("the week window reaches older blocks", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		now := time.Now()
		require.NoError(t, coinbases.Put(context.Background(), db, []coinbases.Coinbase{
			coinbase(10, "h10", "/beta/", now.Add(-48*time.Hour), 2),
			coinbase(11, "h11", "/alpha/", now.Add(-time.Hour), 2),
		}))
		server := api_bitwindowd.New(nil, db, nil, nil, regtestRegistry(t), config.Config{}, nil)

		response, err := server.ListMiningPools(context.Background(), connect.NewRequest(&v1.ListMiningPoolsRequest{
			Window: v1.MiningPoolWindow_MINING_POOL_WINDOW_1W,
		}))
		require.NoError(t, err)
		assert.EqualValues(t, 2, response.Msg.BlockCount)
		assert.EqualValues(t, 10, response.Msg.FromHeight)
	})

	t.Run("a network with no registry lists only Unknown", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		require.NoError(t, coinbases.Put(context.Background(), db, []coinbases.Coinbase{
			coinbase(10, "h10", "/alpha/", time.Now(), 2),
		}))
		registry := miningpools.New(context.Background(), config.NetworkSignet, "", "", offlineRegistry)
		server := api_bitwindowd.New(nil, db, nil, nil, registry, config.Config{}, nil)

		response, err := server.ListMiningPools(context.Background(), connect.NewRequest(&v1.ListMiningPoolsRequest{}))
		require.NoError(t, err)
		assert.False(t, response.Msg.RegistryAvailable)
		require.Len(t, response.Msg.Pools, 1)
		assert.Equal(t, miningpools.Unknown.Name, response.Msg.Pools[0].Pool.Name)
	})
}

func TestService_ListBlocksNamesThePool(t *testing.T) {
	t.Parallel()

	for _, test := range []struct {
		name     string
		hash     string
		wantPool string
	}{
		{name: "a recorded coinbase names its pool", hash: "hash100", wantPool: "Alpha Pool"},
		{name: "a coinbase of a replaced block names no pool", hash: "stale", wantPool: ""},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			db := database.Test(t)
			require.NoError(t, coinbases.Put(context.Background(), db, []coinbases.Coinbase{
				coinbase(100, test.hash, "/alpha/", time.Now(), 2),
			}))

			mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			mockBitcoind.EXPECT().GetBlockchainInfo(gomock.Any(), gomock.Any()).
				Return(connect.NewResponse(&corepb.GetBlockchainInfoResponse{Blocks: 100, BestBlockHash: "hash100"}), nil)
			mockBitcoind.EXPECT().GetBlockHash(gomock.Any(), gomock.Any()).
				DoAndReturn(func(_ context.Context, req *connect.Request[corepb.GetBlockHashRequest]) (*connect.Response[corepb.GetBlockHashResponse], error) {
					return connect.NewResponse(&corepb.GetBlockHashResponse{Hash: fmt.Sprintf("hash%d", req.Msg.Height)}), nil
				}).AnyTimes()
			mockBitcoind.EXPECT().GetBlock(gomock.Any(), gomock.Any()).
				DoAndReturn(func(_ context.Context, req *connect.Request[corepb.GetBlockRequest]) (*connect.Response[corepb.GetBlockResponse], error) {
					return connect.NewResponse(&corepb.GetBlockResponse{Height: 100, Hash: req.Msg.Hash}), nil
				}).AnyTimes()
			core := service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
				return mockBitcoind, nil
			})
			conf := config.Config{BitcoinCoreNetwork: config.NetworkRegtest}
			server := api_bitwindowd.New(nil, db, core, nil, regtestRegistry(t), conf, nil)

			response, err := server.ListBlocks(context.Background(), connect.NewRequest(&v1.ListBlocksRequest{PageSize: 1}))
			require.NoError(t, err)
			require.Len(t, response.Msg.RecentBlocks, 1)
			assert.Equal(t, test.wantPool, response.Msg.RecentBlocks[0].GetPool().GetName())
		})
	}
}
