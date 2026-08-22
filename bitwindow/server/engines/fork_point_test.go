package engines

import (
	"context"
	"testing"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// hashAt is a distinct block hash per height and chain.
func hashAt(height uint32, chain byte) chainhash.Hash {
	var h chainhash.Hash
	h[0] = chain
	h[1] = byte(height)
	h[2] = byte(height >> 8)
	return h
}

// forkParser wires a Parser to a Core that serves `chain` at every height.
func forkParser(t *testing.T, chain byte) *Parser {
	t.Helper()
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	p := &Parser{
		db: database.Test(t),
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
	core.EXPECT().
		GetBlockHash(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[corepb.GetBlockHashRequest]) (*connect.Response[corepb.GetBlockHashResponse], error) {
			return connect.NewResponse(&corepb.GetBlockHashResponse{Hash: hashAt(req.Msg.Height, chain).String()}), nil
		}).
		AnyTimes()
	return p
}

// seedProcessed records a contiguous processed chain on `chain`.
func seedProcessed(t *testing.T, ctx context.Context, p *Parser, tip uint32, chain byte) {
	t.Helper()
	for h := uint32(1); h <= tip; h++ {
		_, err := p.db.ExecContext(ctx, `
			INSERT INTO processed_blocks (height, block_hash, txids, block_time)
			VALUES (?, ?, '[]', 0)`, h, hashAt(h, chain).String())
		require.NoError(t, err)
	}
}

// A datadir regenerated from scratch differs from block 1 up. Anchoring the
// search at height 1 would assume it matches and keep that marker for good.
func TestForkPointFindsADivergenceAtBlockOne(t *testing.T) {
	ctx := context.Background()
	p := forkParser(t, 'b')
	seedProcessed(t, ctx, p, 10, 'a')

	fork, err := p.forkPoint(ctx, 10, hashAt(10, 'a').String())
	require.NoError(t, err)
	require.Equal(t, uint32(1), fork, "the whole processed chain belongs to another datadir")
}

// The ordinary case: the chains agree below the fork and part above it.
func TestForkPointFindsTheFirstDivergentBlock(t *testing.T) {
	ctx := context.Background()
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	p := &Parser{
		db: database.Test(t),
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
	// Core keeps chain 'a' up to 6, then follows chain 'b'.
	core.EXPECT().
		GetBlockHash(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[corepb.GetBlockHashRequest]) (*connect.Response[corepb.GetBlockHashResponse], error) {
			chain := byte('a')
			if req.Msg.Height > 6 {
				chain = 'b'
			}
			return connect.NewResponse(&corepb.GetBlockHashResponse{Hash: hashAt(req.Msg.Height, chain).String()}), nil
		}).
		AnyTimes()
	seedProcessed(t, ctx, p, 10, 'a')

	fork, err := p.forkPoint(ctx, 10, hashAt(10, 'a').String())
	require.NoError(t, err)
	require.Equal(t, uint32(7), fork)
}

// Core still holds everything we processed, so there is no fork and no purge.
func TestForkPointReportsNoneWhenTheChainsAgree(t *testing.T) {
	ctx := context.Background()
	p := forkParser(t, 'a')
	seedProcessed(t, ctx, p, 10, 'a')

	fork, err := p.forkPoint(ctx, 10, hashAt(10, 'a').String())
	require.NoError(t, err)
	require.Zero(t, fork)
}
