package engines

import (
	"bytes"
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	orchwallet "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const esploraPollInterval = 30 * time.Second

// esploraBlockSource reads the catalog one time, on the first light-mode poll.
// A network with a CoinNews indexer gets no client: the API reads the indexer.
func esploraBlockSource(network string) func(context.Context) *orchwallet.EsploraClient {
	var (
		once   sync.Once
		client *orchwallet.EsploraClient
	)
	return func(ctx context.Context) *orchwallet.EsploraClient {
		once.Do(func() {
			net, ok := netcatalog.Resolve(ctx).ForNetwork(network)
			if !ok || net.Services.CoinNews.URL != "" {
				return
			}
			url := net.BackendURL(netcatalog.KindEsplora)
			if url == "" {
				return
			}
			// The client logs each request at info.
			client = orchwallet.NewEsploraClient([]string{url}, zerolog.Ctx(ctx).Level(zerolog.WarnLevel))
		})
		return client
	}
}

// handleEsploraTick is handleBlockTick for an install with no local Core. It
// keeps the same processed-block state, so a mode switch scans no block twice.
func (p *Parser) handleEsploraTick(ctx context.Context, esplora *orchwallet.EsploraClient) error {
	tipHeight, err := esplora.TipHeight(ctx)
	if err != nil {
		return fmt.Errorf("get tip height: %w", err)
	}
	tip := uint32(tipHeight)

	processed, err := blocks.GetProcessedTip(ctx, p.db)
	if err != nil {
		return fmt.Errorf("get processed tip: %w", err)
	}
	var (
		lastHeight uint32
		lastHash   string
	)
	if processed != nil {
		lastHeight, lastHash = processed.Height, processed.Hash.String()
	}

	holdsBlock := func(ctx context.Context, height uint32, hash string) (bool, error) {
		if height > tip {
			return false, nil
		}
		got, err := esplora.BlockHash(ctx, int(height))
		if err != nil {
			return false, fmt.Errorf("get block hash %d: %w", height, err)
		}
		return got == hash, nil
	}
	fork, err := p.forkPoint(ctx, holdsBlock, lastHeight, lastHash)
	if err != nil {
		return fmt.Errorf("check for a fork: %w", err)
	}
	if fork > 0 {
		zerolog.Ctx(ctx).Warn().
			Uint32("fork_height", fork).
			Uint32("processed_tip", lastHeight).
			Msg("bitcoind_engine/parser: esplora chain forked below our processed tip, replaying from there")
		replayFrom, err := p.purgeAtOrAbove(ctx, fork)
		if err != nil {
			return err
		}
		lastHeight = replayFrom - 1
	}

	batchStart := max(lastHeight+1, p.scanFloor(tip))
	for ; batchStart <= tip; batchStart += blockBatchSize {
		batchEnd := min(batchStart+blockBatchSize-1, tip)
		batch := make([]lo.Tuple2[uint32, *wire.MsgBlock], 0, batchEnd-batchStart+1)
		for height := batchStart; height <= batchEnd; height++ {
			block, err := esploraBlock(ctx, esplora, height)
			if err != nil {
				return err
			}
			batch = append(batch, lo.T2(height, block))
		}
		if err := p.processBlocks(ctx, batch); err != nil {
			return fmt.Errorf("process blocks: %w", err)
		}
	}
	return nil
}

func esploraBlock(ctx context.Context, esplora *orchwallet.EsploraClient, height uint32) (*wire.MsgBlock, error) {
	hash, err := esplora.BlockHash(ctx, int(height))
	if err != nil {
		return nil, fmt.Errorf("get block hash %d: %w", height, err)
	}
	raw, err := esplora.RawBlock(ctx, hash)
	if err != nil {
		return nil, fmt.Errorf("get block %d: %w", height, err)
	}
	var block wire.MsgBlock
	if err := block.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, fmt.Errorf("deserialize block %d: %w", height, err)
	}
	return &block, nil
}
