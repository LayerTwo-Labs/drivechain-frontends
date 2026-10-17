package engines

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
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
	ctx := t.Context()
	p := forkParser(t, 'b')
	seedProcessed(t, ctx, p, 10, 'a')

	fork, err := p.forkPoint(ctx, 10, hashAt(10, 'a').String())
	require.NoError(t, err)
	require.Equal(t, uint32(1), fork, "the whole processed chain belongs to another datadir")
}

// The ordinary case: the chains agree below the fork and part above it.
func TestForkPointFindsTheFirstDivergentBlock(t *testing.T) {
	ctx := t.Context()
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
	ctx := t.Context()
	p := forkParser(t, 'a')
	seedProcessed(t, ctx, p, 10, 'a')

	fork, err := p.forkPoint(ctx, 10, hashAt(10, 'a').String())
	require.NoError(t, err)
	require.Zero(t, fork)
}

// shortCoreParser wires a Parser to a Core that holds `chain` up to `tip` and
// reports every height above it as out of range.
func shortCoreParser(t *testing.T, chain byte, tip uint32) *Parser {
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
			if req.Msg.Height > tip {
				return nil, errors.New("Block height out of range")
			}
			return connect.NewResponse(&corepb.GetBlockHashResponse{Hash: hashAt(req.Msg.Height, chain).String()}), nil
		}).
		AnyTimes()
	return p
}

// A Core shorter than our processed chain needs no height compare: the hash
// search alone lands the purge right above the blocks Core still holds.
func TestForkPointFindsTheTipOfAShorterCore(t *testing.T) {
	ctx := t.Context()
	// A wide gap, so the hash search walks several steps down to Core's tip.
	p := shortCoreParser(t, 'c', 6)
	seedProcessed(t, ctx, p, 40, 'c')

	fork, err := p.forkPoint(ctx, 40, hashAt(40, 'c').String())
	require.NoError(t, err)
	require.Equal(t, uint32(7), fork, "the purge must start right above the blocks Core holds")
}

// A failed read is not a gap, so it must not move the fork down and purge rows.
func TestForkPointReturnsADatabaseError(t *testing.T) {
	ctx := t.Context()
	p := forkParser(t, 'b')
	seedProcessed(t, ctx, p, 10, 'a')
	_, err := p.db.ExecContext(ctx, `ALTER TABLE processed_blocks RENAME TO processed_blocks_gone`)
	require.NoError(t, err)

	_, err = p.forkPoint(ctx, 10, hashAt(10, 'a').String())
	require.ErrorContains(t, err, "no such table")
}

// A new install on a full chain holds rows only from its scan floor up. The
// search must stay inside those rows, or a one-block reorg purges from height 1.
func TestForkPointStaysAboveTheLowestProcessedRow(t *testing.T) {
	ctx := t.Context()
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
			chain := byte('a')
			if req.Msg.Height >= 1000 {
				chain = 'b'
			}
			return connect.NewResponse(&corepb.GetBlockHashResponse{Hash: hashAt(req.Msg.Height, chain).String()}), nil
		}).
		AnyTimes()
	for h := uint32(900); h <= 1000; h++ {
		_, err := p.db.ExecContext(ctx, `
			INSERT INTO processed_blocks (height, block_hash, txids, block_time)
			VALUES (?, ?, '[]', 0)`, h, hashAt(h, 'a').String())
		require.NoError(t, err)
	}

	fork, err := p.forkPoint(ctx, 1000, hashAt(1000, 'a').String())
	require.NoError(t, err)
	assert.Equal(t, uint32(1000), fork)
}

// servedChain is the block Core serves at each height.
type servedChain map[uint32]*wire.MsgBlock

// extend adds a block at each height from `from` to `to`. Each block links to
// the one below it, and the first one links to parent.
func (c servedChain) extend(from, to uint32, branch int32, parent chainhash.Hash) {
	for h := from; h <= to; h++ {
		block := &wire.MsgBlock{
			Header: wire.BlockHeader{
				Version:   branch,
				PrevBlock: parent,
				Nonce:     h,
				Timestamp: time.Unix(1700000000+int64(h), 0),
			},
			Transactions: []*wire.MsgTx{{TxIn: []*wire.TxIn{{}}}},
		}
		c[h] = block
		parent = block.BlockHash()
	}
}

func (c servedChain) hash(height uint32) chainhash.Hash {
	return c[height].BlockHash()
}

// tickParser wires a mainnet Parser to a Core that serves chain up to tip.
func tickParser(t *testing.T, chain servedChain, tip uint32) *Parser {
	t.Helper()
	byHash := map[string]*wire.MsgBlock{}
	for _, block := range chain {
		byHash[block.BlockHash().String()] = block
	}
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().
		GetBlockchainInfo(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetBlockchainInfoResponse{
			Blocks:        tip,
			BestBlockHash: chain.hash(tip).String(),
		}), nil).
		AnyTimes()
	core.EXPECT().
		GetBlockHash(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[corepb.GetBlockHashRequest]) (*connect.Response[corepb.GetBlockHashResponse], error) {
			block, ok := chain[req.Msg.Height]
			if !ok || req.Msg.Height > tip {
				return nil, errors.New("Block height out of range")
			}
			return connect.NewResponse(&corepb.GetBlockHashResponse{Hash: block.BlockHash().String()}), nil
		}).
		AnyTimes()
	core.EXPECT().
		GetRawTransaction(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{Fee: 0.0001}), nil).
		AnyTimes()
	core.EXPECT().
		GetBlock(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[corepb.GetBlockRequest]) (*connect.Response[corepb.GetBlockResponse], error) {
			block, ok := byHash[req.Msg.Hash]
			if !ok {
				return nil, errors.New("Block not found")
			}
			var buf bytes.Buffer
			if err := block.Serialize(&buf); err != nil {
				return nil, err
			}
			return connect.NewResponse(&corepb.GetBlockResponse{Hex: hex.EncodeToString(buf.Bytes())}), nil
		}).
		AnyTimes()
	db := database.Test(t)
	return &Parser{
		db:          db,
		conf:        config.Config{BitcoinCoreNetwork: config.NetworkMainnet},
		chainParams: &chaincfg.MainNetParams,
		m4Engine:    NewM4Engine(db, config.NetworkMainnet, ""),
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
}

func markProcessed(t *testing.T, ctx context.Context, p *Parser, chain servedChain, from, to uint32) {
	t.Helper()
	var rows []blocks.ProcessedBlock
	for h := from; h <= to; h++ {
		rows = append(rows, blocks.ProcessedBlock{Height: h, Hash: chain.hash(h), BlockTime: chain[h].Header.Timestamp})
	}
	require.NoError(t, blocks.MarkBlocksProcessed(ctx, p.db, rows))
}

func processedHeights(t *testing.T, ctx context.Context, p *Parser) (lowest, highest, count uint32) {
	t.Helper()
	require.NoError(t, p.db.QueryRowContext(ctx,
		`SELECT MIN(height), MAX(height), COUNT(*) FROM processed_blocks`,
	).Scan(&lowest, &highest, &count))
	return lowest, highest, count
}

func TestHandleBlockTick(t *testing.T) {
	const tip = uint32(2010)

	// The floor of a fresh install at this tip is above the old rows. A replay
	// after a fork must not jump to it, or the history below the floor goes.
	t.Run("fork replay keeps the history below the scan floor", func(t *testing.T) {
		ctx := t.Context()
		require.Greater(t, tip-recentScanWindow, uint32(1000))

		old := servedChain{}
		old.extend(1, 1000, 1, chainhash.Hash{})
		chain := servedChain{}
		chain.extend(1, 999, 1, chainhash.Hash{})
		chain.extend(1000, tip, 2, chain.hash(999))

		p := tickParser(t, chain, tip)
		markProcessed(t, ctx, p, old, 900, 1000)
		seedBundleRow(t, ctx, p.db, "bundle-a", 950, 1000, 3)

		require.NoError(t, p.handleBlockTick(ctx))

		lowest, highest, count := processedHeights(t, ctx, p)
		assert.Equal(t, uint32(900), lowest)
		assert.Equal(t, tip, highest)
		assert.Equal(t, tip-900+1, count)
		stored, err := blocks.GetProcessedBlock(ctx, p.db, 1000)
		require.NoError(t, err)
		assert.Equal(t, chain.hash(1000), stored.Hash)
	})

	// Core moved to another branch during the fetch: blocks up to 1005 are
	// from the old branch and the blocks above it are from the new one.
	t.Run("a batch across two branches stores nothing", func(t *testing.T) {
		ctx := t.Context()
		chain := servedChain{}
		chain.extend(1, 1005, 1, chainhash.Hash{})
		chain[1003].Transactions = append(chain[1003].Transactions, &wire.MsgTx{
			TxIn:  []*wire.TxIn{{PreviousOutPoint: wire.OutPoint{Hash: chainhash.Hash{7}}}},
			TxOut: []*wire.TxOut{{PkScript: opReturnScript(t, []byte("stale branch"))}},
		})
		chain.extend(1004, 1005, 1, chain.hash(1003))
		chain.extend(1006, 1020, 2, chainhash.Hash{0xff})
		p := tickParser(t, chain, 1020)
		markProcessed(t, ctx, p, chain, 1, 1000)

		require.NoError(t, p.handleBlockTick(ctx))

		_, highest, _ := processedHeights(t, ctx, p)
		assert.Equal(t, uint32(1000), highest)
		var opReturns int
		require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM op_returns`).Scan(&opReturns))
		assert.Zero(t, opReturns)
	})

	t.Run("a batch that does not link to the processed tip stores nothing", func(t *testing.T) {
		ctx := t.Context()
		chain := servedChain{}
		chain.extend(1, 1000, 1, chainhash.Hash{})
		chain.extend(1001, 1020, 2, chainhash.Hash{0xff})
		p := tickParser(t, chain, 1020)
		markProcessed(t, ctx, p, chain, 1, 1000)

		require.NoError(t, p.handleBlockTick(ctx))

		_, highest, _ := processedHeights(t, ctx, p)
		assert.Equal(t, uint32(1000), highest)
	})

	t.Run("a fresh install starts at the scan floor", func(t *testing.T) {
		ctx := t.Context()
		chain := servedChain{}
		chain.extend(1, tip, 1, chainhash.Hash{})
		p := tickParser(t, chain, tip)

		require.NoError(t, p.handleBlockTick(ctx))

		lowest, highest, _ := processedHeights(t, ctx, p)
		assert.Equal(t, tip-recentScanWindow, lowest)
		assert.Equal(t, tip, highest)
	})
}
