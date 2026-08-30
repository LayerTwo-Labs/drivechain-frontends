package engines

import (
	"bytes"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	logpool "github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

func NewBitcoind(
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	db *sql.DB,
	conf config.Config,
) *Parser {
	return &Parser{
		bitcoind: bitcoind,
		db:       db,
		conf:     conf,
		m4Engine: NewM4Engine(db),
	}
}

// Parser is responsible for parsing blocks from bitcoind and storing OP_RETURN data in SQLite
type Parser struct {
	bitcoind *service.Service[corerpc.BitcoinServiceClient]
	db       *sql.DB
	conf     config.Config

	m4Engine *M4Engine
	nodeMode *NodeMode

	// Dedicated sink for coinnews sync events. Nil => logging disabled.
	coinnewsLog *zerolog.Logger
}

// SetNodeMode gates the block tick on the node mode. Light mode runs no local
// Bitcoin Core, so there is nothing to parse.
func (p *Parser) SetNodeMode(nodeMode *NodeMode) {
	p.nodeMode = nodeMode
}

// SetCoinnewsLogger attaches a dedicated logger for coinnews sync events.
// Passing nil disables coinnews-sync logging.
func (p *Parser) SetCoinnewsLogger(logger *zerolog.Logger) {
	p.coinnewsLog = logger
}

// Run runs the engine. It checks if a new block has been mined,
// and if so, handles it!
//
// Should be started in a goroutine.
func (p *Parser) Run(ctx context.Context) error {
	alertTicker := time.NewTicker(2 * time.Second)
	defer alertTicker.Stop()

	// Unconfirmed OP_RETURNs never expire on their own. Sweep on the first
	// tick that reads full mode — sessions are often shorter than the hourly
	// tick, and the orchestrator answers the mode a moment after boot.
	reapTicker := time.NewTicker(time.Hour)
	defer reapTicker.Stop()
	sweptOnStart := false

	zerolog.Ctx(ctx).Info().
		Msgf("bitcoind_engine/parser: started parser ticker")

	for {
		select {
		case <-ctx.Done():
			zerolog.Ctx(ctx).Info().Err(ctx.Err()).
				Msgf("bitcoind_engine/parser: stopping parser ticker")
			return nil

		case <-reapTicker.C:
			if p.nodeMode.RunsLocalNode(ctx) {
				p.sweepMempool(ctx)
			}

		case <-alertTicker.C:
			if !p.nodeMode.RunsLocalNode(ctx) {
				continue
			}
			if !sweptOnStart {
				// Bitcoin Core can still boot when the mode reads full. Mark
				// the sweep done only once it reaches the mempool.
				sweptOnStart = p.sweepMempool(ctx)
			}

			zerolog.Ctx(ctx).Trace().
				Msgf("bitcoind_engine/parser: processing block tick")

			if err := p.handleBlockTick(ctx); err != nil {
				// Don't log Bitcoin Core startup errors (e.g., "-28: Loading block index")
				if !isBitcoinCoreStartupError(err.Error()) {
					zerolog.Ctx(ctx).Err(err).Msgf("unable to handle block tick")
				}
				continue
			}

			zerolog.Ctx(ctx).Trace().
				Msgf("bitcoind_engine/parser: finished processing block tick")

		}
	}
}

// sweepMempool drops expired unconfirmed OP_RETURNs and reports whether it
// finished, so the caller can try again. A failure means Bitcoin Core is
// unreachable, which the block tick reports on the same cadence.
func (p *Parser) sweepMempool(ctx context.Context) bool {
	if err := p.reapExpiredMempool(ctx); err != nil {
		zerolog.Ctx(ctx).Debug().Err(err).Msg("could not reap expired mempool OP_RETURNs")
		return false
	}
	return true
}

// reapExpiredMempool drops unconfirmed OP_RETURNs that can no longer confirm.
func (p *Parser) reapExpiredMempool(ctx context.Context) error {
	mempoolTxIDs := func() ([]string, error) {
		bitcoind, err := p.bitcoind.Get(ctx)
		if err != nil {
			return nil, err
		}
		res, err := bitcoind.GetRawMempool(ctx, connect.NewRequest(&corepb.GetRawMempoolRequest{}))
		if err != nil {
			return nil, err
		}
		return res.Msg.Txids, nil
	}
	return opreturns.ReapExpiredMempool(ctx, p.db, mempoolTxIDs)
}

// BlockResult represents the result of processing a single block
type BlockResult struct {
	Height int32
	Error  error
}

// resetProcessedChain drops every processed block and everything derived from
// them; the derived inserts ignore conflicts, so stale rows would survive the
// rescan.
func (p *Parser) resetProcessedChain(ctx context.Context) error {
	_, err := p.purgeAtOrAbove(ctx, 0)
	return err
}

// purgeAtOrAbove drops every row derived from a block at height or above, so a
// replay of that range rebuilds them against the chain Core now follows.
//
// One transaction. A partial purge would delete the processed markers that make
// the fork detectable while orphan rows survive, and the first-wins inserts on
// replay would then keep them for good.
// It returns the height the replay has to start from, which the M4 purge can
// take below height: a bundle whose score the orphan branch moved only rebuilds
// by replaying the blocks that built it.
func (p *Parser) purgeAtOrAbove(ctx context.Context, height uint32) (uint32, error) {
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, fmt.Errorf("open the fork purge: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck // committed on success

	replayFrom, err := purgeM4AtOrAboveTx(ctx, tx, height)
	if err != nil {
		return 0, fmt.Errorf("purge m4 on fork: %w", err)
	}
	if err := blocks.DeleteProcessedBlocksAtOrAboveTx(ctx, tx, replayFrom); err != nil {
		return 0, fmt.Errorf("delete processed blocks on fork: %w", err)
	}
	if err := purgeCoinNewsAtOrAboveTx(ctx, tx, height); err != nil {
		return 0, fmt.Errorf("purge coinnews on fork: %w", err)
	}
	if err := purgeChainDerivedAtOrAboveTx(ctx, tx, height); err != nil {
		return 0, fmt.Errorf("purge chain-derived rows on fork: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("commit the fork purge: %w", err)
	}
	return replayFrom, nil
}

// forkPoint returns the lowest processed height whose block Core no longer
// holds, or 0 when Core still agrees with everything we processed.
//
// The common case costs one RPC: the processed tip usually still matches. A
// mismatch then binary-searches the processed range for the first block the two
// chains disagree on, which is where a replay has to start.
func (p *Parser) forkPoint(ctx context.Context, processedTip uint32, processedHash string) (uint32, error) {
	if processedTip == 0 || processedHash == "" {
		return 0, nil
	}
	switch same, err := p.coreHoldsBlock(ctx, processedTip, processedHash); {
	case err != nil:
		return 0, err
	case same:
		return 0, nil
	}

	// Anchored at 0, a height nothing processes, so height 1 is searched like
	// any other. A regenerated regtest datadir differs from block 1 up.
	lo, hi := uint32(0), processedTip
	for lo+1 < hi {
		mid := lo + (hi-lo)/2
		stored, err := blocks.GetProcessedBlock(ctx, p.db, mid)
		if err != nil {
			// A gap in the processed range tells us nothing about the fork.
			// Treat everything above it as suspect.
			hi = mid
			continue
		}
		switch same, err := p.coreHoldsBlock(ctx, mid, stored.Hash.String()); {
		case err != nil:
			return 0, err
		case same:
			lo = mid
		default:
			hi = mid
		}
	}
	return hi, nil
}

// coreHoldsBlock reports whether Core's block at height is the one we recorded.
func (p *Parser) coreHoldsBlock(ctx context.Context, height uint32, hash string) (bool, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return false, err
	}
	res, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{Height: height}))
	if err != nil {
		if strings.Contains(err.Error(), "out of range") {
			// Core is shorter than we processed, so it holds no such block.
			return false, nil
		}
		return false, fmt.Errorf("get block hash %d: %w", height, err)
	}
	return res.Msg.Hash == hash, nil
}

func (p *Parser) handleBlockTick(ctx context.Context) error {

	switch err := p.ensureSyncIsHealthy(ctx); {
	case err != nil &&
		strings.Contains(err.Error(), "Block height out of range"):

		// Core has no block 1: a fresh regtest, or a datadir that was wiped and
		// is back to syncing. Everything we processed is above its tip.
		if err := p.resetProcessedChain(ctx); err != nil {
			return fmt.Errorf("reset processed chain on empty chain: %w", err)
		}

		zerolog.Ctx(ctx).Debug().
			Msgf("bitcoind_engine/parser: no block 1 yet, waiting for chain to advance..")
		return nil

	case connect.CodeOf(err) == connect.CodeUnavailable:
		zerolog.Ctx(ctx).Debug().
			Msgf("bitcoind_engine/parser: bitcoin core is not available, waiting for connection..")
		return nil

	case err != nil:
		return err
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bitcoind_engine/parser: detected chain deletion")

	// Get latest processed height
	lastProcessedBlock, err := blocks.GetProcessedTip(ctx, p.db)
	if err != nil {
		return fmt.Errorf("get latest processed height: %w", err)
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bitcoind_engine/parser: found last processed tip")

	var (
		lastProcessedHeight uint32
		lastProcessedHash   chainhash.Hash
	)
	if lastProcessedBlock != nil {
		lastProcessedHeight = lastProcessedBlock.Height
		lastProcessedHash = lastProcessedBlock.Hash
	}

	// Get current blockchain height + IBD flag.
	currentHeight, _, inIBD, err := p.currentChainState(ctx)
	if err != nil {
		return fmt.Errorf("fetch current height: %w", err)
	}

	// A node shorter than our processed tip means the chain was wiped. A healthy
	// node — and a fresh install (processed tip 0) — is never shorter than
	// what we've already processed, so this only fires on a real wipe, not on
	// the pruning/reindex/restart blips that keep the tip high. Left stale,
	// the scanner reprocesses against blocks the node no longer has and pins
	// bitcoind, which starves getblockchaininfo and the wallet readiness probe
	// ("Backend not ready after 60s"). Drop the stale state and re-scan the
	// node's actual chain from scratch.
	if currentHeight < lastProcessedHeight {
		zerolog.Ctx(ctx).Warn().
			Uint32("processed_tip", lastProcessedHeight).
			Uint32("node_tip", currentHeight).
			Msg("bitcoind_engine/parser: node is behind our processed tip — chain wiped, resetting processed_blocks")
		if err := p.resetProcessedChain(ctx); err != nil {
			return fmt.Errorf("reset processed chain on chain wipe: %w", err)
		}
		return nil
	}

	// Before the IBD guard below. A switch leaves the replacement fork in IBD
	// while it downloads from the rewind point, and every tick that returns
	// early keeps serving rows from the fork that went away. The purge is a few
	// queries; only the replay under it is expensive, and that still waits.
	//
	// A height compare cannot see an eCash fork switch: both forks descend from
	// mainnet, so the tip stays as high or higher. Only the hash at a height we
	// already processed says the chain moved under us.
	switch fork, err := p.forkPoint(ctx, lastProcessedHeight, lastProcessedHash.String()); {
	case err != nil:
		zerolog.Ctx(ctx).Warn().Err(err).
			Msg("bitcoind_engine/parser: could not check for a fork, retrying next tick")
		return nil

	case fork > 0:
		zerolog.Ctx(ctx).Warn().
			Uint32("fork_height", fork).
			Uint32("processed_tip", lastProcessedHeight).
			Msg("bitcoind_engine/parser: the chain forked below our processed tip, replaying from there")
		replayFrom, err := p.purgeAtOrAbove(ctx, fork)
		if err != nil {
			return err
		}
		lastProcessedHeight = replayFrom - 1
	}

	// While Core is still doing initial block download on a *full* chain
	// (mainnet / forknet / eCash), skip the OP_RETURN scan entirely. Each scan
	// fans out a parallel batch of blocks and issues per-tx
	// GetRawTransaction calls (needed for fee), all of which queue behind
	// cs_main. During IBD on a populated chain that's enough pressure to
	// push getblockchaininfo past its client timeout, which trips the
	// orchestrator's connection-lost monitor and freezes the UI height.
	// Catching up runs in one batch the first tick after IBD clears.
	//
	// Signet / testnet / regtest blocks are small or empty, so the scan
	// is cheap even mid-sync — keep running there so the user sees recent
	// OP_RETURN activity while Core finishes catching up.
	if inIBD && config.IsFullChainNetwork(p.conf.BitcoinCoreNetwork) {
		zerolog.Ctx(ctx).Debug().
			Uint32("tip", currentHeight).
			Uint32("processed", lastProcessedHeight).
			Str("network", string(p.conf.BitcoinCoreNetwork)).
			Msg("bitcoind_engine/parser: skipping scan while Core is in IBD")
		return nil
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bitcoind_engine/parser: found current height: %d", currentHeight)

	const batchSize = 30

	zerolog.Ctx(ctx).Trace().
		Uint32("last-processed-height", lastProcessedHeight).
		Uint32("batch-size", batchSize).
		Msgf("bitcoind_engine/parser: processing blocks")

	batchStart := lastProcessedHeight + 1
	if floor := p.scanFloor(currentHeight); floor > batchStart {
		zerolog.Ctx(ctx).Info().
			Uint32("scan_floor", floor).
			Uint32("processed", lastProcessedHeight).
			Uint32("tip", currentHeight).
			Msg("bitcoind_engine/parser: skipping ahead to the scan floor")
		batchStart = floor
	}

	for ; batchStart <= currentHeight; batchStart += batchSize {
		batchEnd := min(batchStart+batchSize-1, currentHeight)
		if p.conf.SyncToHeight > 0 {
			batchEnd = min(batchEnd, p.conf.SyncToHeight)
		}

		// Make sure to not apply any timeouts here. Bitcoin Core can hang in
		// instances of Core being busy processing blocks, where RPC requests
		// go unanswered for a little while.
		pool := logpool.NewWithResults[lo.Tuple2[uint32, *wire.MsgBlock]](ctx, "bitcoind_engine/processBlocks").
			WithCancelOnError().
			WithFirstError()

		for height := batchStart; height <= batchEnd; height++ {
			pool.Go(fmt.Sprintf("block-%d", height), func(ctx context.Context) (lo.Tuple2[uint32, *wire.MsgBlock], error) {
				log := zerolog.Ctx(ctx).With().
					Int32("height", int32(height)).
					Logger()

				ctx = log.WithContext(ctx)

				start := time.Now()

				zerolog.Ctx(ctx).Trace().
					Msgf("bitcoind_engine/parser: processing block %d", height)

				block, err := p.getBlock(ctx, height)
				if err != nil {
					return lo.Tuple2[uint32, *wire.MsgBlock]{}, err
				}

				// If the block only has one transaction it's uninteresting,
				// because it only has a coinbase transaction, e.g: an empty block
				if len(block.Transactions) <= 1 {
					return lo.T2(height, block), nil
				}

				log.Trace().
					Msgf("bitcoind_engine/parser: block has more than one transaction, inspecting transactions for OP returns")

				for _, tx := range block.Transactions {
					blockTime := block.Header.Timestamp
					if err := p.opReturnForTXID(ctx, tx, &height, &blockTime); err != nil {
						return lo.Tuple2[uint32, *wire.MsgBlock]{}, fmt.Errorf("process transaction %s: %w", tx.TxID(), err)
					}
				}

				log.Trace().
					Msgf("bitcoind_engine/parser: finished processing %d transactions for block %d in %s",
						len(block.Transactions), height, time.Since(start),
					)

				return lo.T2(height, block), nil
			})
		}

		zerolog.Ctx(ctx).Trace().
			Msgf("bitcoind_engine/parser: waiting for block processing to finish")

		results, err := pool.Wait(ctx)
		if err != nil {
			return fmt.Errorf("process blocks: %w", err)
		}

		if err := p.processBlocks(ctx, results); err != nil {
			return fmt.Errorf("process blocks: %w", err)
		}

		if p.conf.SyncToHeight > 0 && batchEnd >= p.conf.SyncToHeight {
			return fmt.Errorf("reached sync-to-height goal: %d", p.conf.SyncToHeight)
		}
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bitcoind_engine/parser: finished processing blocks")

	return nil
}

// processBlock processes a single block: checks if it contains any OP_RETURN transactions, inserts any found into the database,
// and marks the block as processed.
func (p *Parser) processBlocks(ctx context.Context, coreBlocks []lo.Tuple2[uint32, *wire.MsgBlock]) error {

	// CoinNews indexing must commit BEFORE the block is marked processed:
	// if it fails, we want the next sync attempt to retry, not skip the
	// block as already-done. Sequential, canonical-order pass — see
	// indexCoinNewsBlocks for the spec rationale.
	if err := p.indexCoinNewsBlocks(ctx, coreBlocks); err != nil {
		return fmt.Errorf("index coinnews: %w", err)
	}

	// Insert the processed blocks
	if err := blocks.MarkBlocksProcessed(ctx, p.db, lo.Map(coreBlocks, func(t lo.Tuple2[uint32, *wire.MsgBlock], _ int) blocks.ProcessedBlock {
		height, block := t.Unpack()
		return blocks.ProcessedBlock{
			Height:    height,
			Hash:      block.Header.BlockHash(),
			BlockTime: block.Header.Timestamp,
			Txids: lo.Map(block.Transactions, func(tx *wire.MsgTx, _ int) chainhash.Hash {
				return tx.TxHash()
			}),
		}
	})); err != nil {
		return fmt.Errorf("insert processed blocks: %w", err)
	}

	zerolog.Ctx(ctx).Trace().
		Int32("height", int32(len(coreBlocks))).
		Msgf("bitcoind_engine/parser: successfully inserted blocks")

	// Process M4 messages from blocks
	for _, t := range coreBlocks {
		height, block := t.Unpack()
		if err := p.m4Engine.ProcessBlock(ctx, height, block); err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).
				Uint32("height", height).
				Msg("bitcoind_engine/parser: failed to process M4 message")
			// Don't fail the whole batch for M4 errors
		}
	}

	return nil
}

// HandleNewRawTransaction can be called on a brand new transaction
// from the mempool.
func (p *Parser) HandleNewRawTransaction(
	ctx context.Context, tx *wire.MsgTx,
) error {
	now := time.Now()
	if err := p.opReturnForTXID(ctx, tx, nil, &now); err != nil {
		return fmt.Errorf("find op return for txid: %w", err)
	}

	return nil
}

// Nil height means unconfirmed. Nil time means we don't know the TX time.
// CoinNews indexing runs separately, in canonical scan order, after all
// blocks in a batch are fetched (see processBlocks).
func (p *Parser) opReturnForTXID(
	ctx context.Context, tx *wire.MsgTx,
	height *uint32, createdAt *time.Time,
) error {
	if createdAt != nil && createdAt.IsZero() {
		panic("PROGRAMMER ERROR: non-nil, zero create time")
	}

	opReturns, err := p.handleOpReturns(ctx, tx, height, createdAt)
	if err != nil {
		return fmt.Errorf("find OP_RETURNs: %w", err)
	}

	if err := opreturns.Persist(ctx, p.db, opReturns); err != nil {
		return err
	}

	return nil
}

func (p *Parser) handleTimestamp(
	ctx context.Context, data []byte, txid string, height *uint32,
) error {
	// Check if data starts with "STAMP" prefix (5 bytes) followed by 32-byte hash
	if len(data) != 37 { // 5 bytes prefix + 32 bytes hash
		return nil
	}

	prefix := string(data[:5])
	if prefix != TimestampPrefix {
		return nil
	}

	// Extract the 32-byte SHA256 hash
	hashBytes := data[5:]
	if len(hashBytes) != sha256.Size {
		return nil
	}

	fileHash := hex.EncodeToString(hashBytes)

	// Fetch the actual block time from the transaction
	var confirmedAt *time.Time
	var blockHeight *int64

	bitcoind, err := p.bitcoind.Get(ctx)
	if err == nil {
		resp, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
			Txid:      txid,
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
		}))
		if err == nil && resp.Msg.Blockhash != "" {
			blockResp, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
				Hash:      resp.Msg.Blockhash,
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
			}))
			if err == nil {
				if blockResp.Msg.Time != nil {
					t := blockResp.Msg.Time.AsTime()
					confirmedAt = &t
				}
				h := int64(blockResp.Msg.Height)
				blockHeight = &h
			}
		}
	}

	// Fallback to passed height if we couldn't fetch
	if blockHeight == nil && height != nil {
		h := int64(*height)
		blockHeight = &h
	}

	// Check if we already have this timestamp
	existing, err := timestamps.GetByHash(ctx, p.db, fileHash)
	if err != nil {
		return fmt.Errorf("check existing timestamp: %w", err)
	}
	if existing != nil {
		// Already exists - update block height and confirmed time if missing
		if (existing.BlockHeight == nil && blockHeight != nil) || (existing.ConfirmedAt == nil && confirmedAt != nil) {
			newConfirmedAt := existing.ConfirmedAt
			if newConfirmedAt == nil {
				newConfirmedAt = confirmedAt
			}
			// Record the transaction being processed, not the stored one. After
			// a reorg the replacement branch can carry a different transaction
			// for the same file hash, and the stored id then points at a
			// transaction that no longer exists.
			if err := timestamps.Update(ctx, p.db, existing.ID, &txid, blockHeight, timestamps.StatusConfirmed, newConfirmedAt); err != nil {
				return fmt.Errorf("update existing timestamp: %w", err)
			}
		}
		return nil
	}

	// Create discovered timestamp
	now := time.Now()
	timestamp := timestamps.FileTimestamp{
		Filename:    "", // Unknown for discovered timestamps
		FileHash:    fileHash,
		TxID:        &txid,
		BlockHeight: blockHeight,
		Status:      timestamps.StatusConfirmed,
		CreatedAt:   now,
		ConfirmedAt: confirmedAt,
	}

	id, err := timestamps.Create(ctx, p.db, timestamp)
	if err != nil {
		return fmt.Errorf("create discovered timestamp: %w", err)
	}

	zerolog.Ctx(ctx).Info().
		Int64("id", id).
		Str("hash", fileHash).
		Str("txid", txid).
		Msg("discovered timestamp on blockchain")

	return nil
}

// isBitcoinCoreStartupError is kept as a package-private alias of the shared
// helper so existing call sites in this file don't need to change.
func isBitcoinCoreStartupError(errMsg string) bool {
	return IsBitcoinCoreStartupError(errMsg)
}

// currentChainState returns the tip plus the IBD flag in one RPC. Callers
// that want to gate heavy work on "Core has caught up" use the inIBD
// return so they don't pay the cost of a second getblockchaininfo.
func (p *Parser) currentChainState(ctx context.Context) (uint32, chainhash.Hash, bool, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return 0, chainhash.Hash{}, false, err
	}

	resp, err := bitcoind.GetBlockchainInfo(ctx, &connect.Request[corepb.GetBlockchainInfoRequest]{})
	if err != nil {
		return 0, chainhash.Hash{}, false, err
	}

	hash, err := chainhash.NewHashFromStr(resp.Msg.BestBlockHash)
	if err != nil {
		return 0, chainhash.Hash{}, false, fmt.Errorf("parse best block hash: %w", err)
	}

	return resp.Msg.Blocks, *hash, resp.Msg.InitialBlockDownload, nil
}

func (p *Parser) getBlock(ctx context.Context, height uint32) (*wire.MsgBlock, error) {
	start := time.Now()

	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	hash, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
		Height: height,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: get block hash %d: %w", height, err)
	}

	// We want to minimize the network call count. We therefore fetch the raw
	// block, and deserialize into wire.MsgTx objects in-process without calling
	// out go `getrawtransaction` for each transaction.
	const verbosity = corepb.GetBlockRequest_VERBOSITY_RAW_DATA
	resp, err := bitcoind.GetBlock(ctx, &connect.Request[corepb.GetBlockRequest]{
		Msg: &corepb.GetBlockRequest{
			Hash:      hash.Msg.Hash,
			Verbosity: verbosity,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: get block %d: %w", height, err)
	}
	blockBytes, err := hex.DecodeString(resp.Msg.Hex)
	if err != nil {
		return nil, fmt.Errorf("decode block hex: %w", err)
	}

	var msgBlock wire.MsgBlock
	if err := msgBlock.Deserialize(bytes.NewReader(blockBytes)); err != nil {
		return nil, fmt.Errorf("deserialize block: %w", err)
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bitcoind_engine/parser: fetched block %d in %s", height, time.Since(start))

	return &msgBlock, nil
}

// finds all OP_RETURN outputs for a specific tx
func (p *Parser) handleOpReturns(
	ctx context.Context, tx *wire.MsgTx, height *uint32, createdAt *time.Time,
) ([]opreturns.OPReturn, error) {
	txid := tx.TxID()

	var emptyHash chainhash.Hash
	isCoinbase := len(tx.TxIn) > 0 && tx.TxIn[0].PreviousOutPoint.Hash.IsEqual(&emptyHash)
	// a coinbase OP_RETURN is always consensus data — the witness commitment,
	// a BIP300/301 message or a miner tag — never a user payload
	if isCoinbase {
		return nil, nil
	}

	// Check outputs for OP_NOP5
	for _, txout := range tx.TxOut {
		script := txout.PkScript
		if len(script) > 0 && script[0] == txscript.OP_NOP5 {
			return nil, nil // OP_DRIVECHAIN, skipping
		}
	}

	// Only fetch this a single time if handling multiple outputs
	var rawTx *corepb.GetRawTransactionResponse

	var opReturns []opreturns.OPReturn
	for vout, txout := range tx.TxOut {
		if len(txout.PkScript) < 2 {
			continue
		}

		isOPReturn := txout.PkScript[0] == txscript.OP_RETURN
		if isWitnessCommitment(txout.PkScript) {
			continue
		}
		if shouldSkip(txout.PkScript) {
			continue
		}

		if !isOPReturn {
			continue
		}

		// Parse the OP_RETURN data correctly, just skip if we're unable
		// to parse. Lots of strange data on the blockchain!
		data, ok := parseOPReturnData(txout.PkScript)
		if !ok {
			continue
		}

		// Check if this is a timestamp with STAMP prefix
		if err := p.handleTimestamp(ctx, data, txid, height); err != nil {
			zerolog.Ctx(ctx).Warn().
				Err(err).
				Str("txid", txid).
				Msg("handle timestamp")
		}

		zerolog.Ctx(ctx).Debug().
			Str("txid", txid).
			Int("vout", vout).
			Msgf("bitcoind_engine/parser: found OP_RETURN")

		p.logCoinnews(ctx, txid, vout, data, height)

		// CoinNews indexing happens elsewhere — we cannot do it here
		// because handleOpReturns runs concurrently across blocks in
		// a batch, and the spec's first-wins/last-wins rules require
		// canonical (height, tx_index, vout_index) order. See
		// processBlocks → indexCoinNewsBlocks.

		// Always fetch fee for OP_RETURN transactions. This avoids a race
		// condition where blocks are processed in parallel and a topic
		// created in one block isn't yet registered when a news article
		// in a later block (same batch) checks isKnownTopic.
		if rawTx == nil {
			core, err := p.bitcoind.Get(ctx)
			if err != nil {
				return nil, fmt.Errorf("get bitcoind: %w", err)
			}
			res, err := core.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				// verbosity=2 needed for fee info to be included.
				// btc-buf only maps TX_INFO to verbosity 2.
				Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_INFO,
				Txid:      txid,
			}))
			if err != nil {
				return nil, fmt.Errorf("get raw transaction %q: %w", txid, err)
			}
			rawTx = res.Msg
		}

		fee, err := btcutil.NewAmount(rawTx.GetFee())
		if err != nil {
			return nil, err
		}

		opReturns = append(opReturns, opreturns.OPReturn{
			TxID:      txid,
			Data:      data,
			Vout:      int32(vout),
			Height:    height,
			Fee:       fee,
			CreatedAt: createdAt,
		})
	}

	return opReturns, nil
}

// recentScanWindow is how far back a lagging scan reaches: about a week at ten
// minutes a block.
const recentScanWindow uint32 = 144 * 7

// scanFloor is the first block worth scanning. The feed shows recent posts, so
// a lagging scan on a populated chain starts a week back instead of at genesis.
// Signet, testnet and regtest blocks are small or empty, so those scan whole.
// Zero scans from the start.
//
// The loop also feeds M4Engine, so a fresh install holds no withdrawal-vote
// history below the floor. Votes still read as they appeared on chain.
func (p *Parser) scanFloor(currentHeight uint32) uint32 {
	// An explicit target asks for history, and a floor above it would leave
	// every batch empty while the run still reports the goal as reached.
	if p.conf.SyncToHeight > 0 {
		return 0
	}
	if !config.IsFullChainNetwork(p.conf.BitcoinCoreNetwork) {
		return 0
	}
	if currentHeight <= recentScanWindow {
		return 0
	}
	return currentHeight - recentScanWindow
}

// logCoinnews emits a detailed line to the dedicated coinnews-sync log when
// the OP_RETURN's first 4 bytes match a known cn_topics entry.
// No-op if no logger is attached (SetCoinnewsLogger not called).
func (p *Parser) logCoinnews(ctx context.Context, txid string, vout int, data []byte, height *uint32) {
	if p.coinnewsLog == nil || len(data) < 4 {
		return
	}

	topicHex := hex.EncodeToString(data[:4])
	var topicName string
	if err := p.db.QueryRowContext(ctx,
		`SELECT name FROM cn_topics WHERE lower(hex(topic)) = ?`, topicHex,
	).Scan(&topicName); err != nil {
		return // not a known topic, or lookup failed
	}

	if topicName == "" {
		return // not a coinnews entry
	}

	// Skip topic-creation OP_RETURNs — bytes 5..7 == "new" (0x6e6577).
	if len(data) >= 8 && bytes.Equal(data[4:7], []byte("new")) {
		return
	}

	payload := data[4:]
	payloadHex := hex.EncodeToString(payload)
	// Trim trailing NULs for the text preview; those are padding, not content.
	textPreview := string(bytes.TrimRight(payload, "\x00"))
	if len(textPreview) > 120 {
		textPreview = textPreview[:120]
	}

	heightVal := int64(-1)
	if height != nil {
		heightVal = int64(*height)
	}

	evt := p.coinnewsLog.Info().
		Str("txid", txid).
		Int("vout", vout).
		Int64("height", heightVal).
		Str("topic_hex", topicHex).
		Str("topic_name", topicName).
		Int("payload_bytes", len(payload)).
		Str("payload_hex", payloadHex).
		Str("text_preview", textPreview)
	if height == nil {
		evt = evt.Str("source", "mempool")
	}
	evt.Msg("coinnews synced")
}

// parseOPReturnData extracts the actual data from an OP_RETURN script by handling
// different PUSHDATA opcodes correctly
func parseOPReturnData(script []byte) ([]byte, bool) {
	if len(script) < 2 || script[0] != txscript.OP_RETURN {
		return nil, false
	}

	// Skip OP_RETURN
	script = script[1:]

	// Handle different PUSHDATA opcodes
	opcode := script[0]
	script = script[1:] // Skip the opcode

	switch {
	case opcode >= txscript.OP_DATA_1 && opcode <= txscript.OP_DATA_75:
		// OP_DATA_1 through OP_DATA_75 directly push X bytes
		dataLen := int(opcode)
		if len(script) < dataLen {
			return nil, false
		}
		return script[:dataLen], true

	case opcode == txscript.OP_PUSHDATA1:
		if len(script) < 1 {
			return nil, false
		}
		dataLen := int(script[0])
		script = script[1:] // Skip length byte
		if len(script) < dataLen {
			return nil, false
		}
		return script[:dataLen], true

	case opcode == txscript.OP_PUSHDATA2:
		if len(script) < 2 {
			return nil, false
		}
		dataLen := int(script[0]) | int(script[1])<<8
		script = script[2:] // Skip length bytes
		if len(script) < dataLen {
			return nil, false
		}
		return script[:dataLen], true

	case opcode == txscript.OP_PUSHDATA4:
		if len(script) < 4 {
			return nil, false
		}
		dataLen := int(script[0]) | int(script[1])<<8 | int(script[2])<<16 | int(script[3])<<24
		script = script[4:] // Skip length bytes
		if len(script) < dataLen {
			return nil, false
		}
		return script[:dataLen], true

	default:
		return nil, false
	}
}

// witnessCommitmentMagic prefixes the coinbase segwit commitment push (BIP141).
var witnessCommitmentMagic = []byte{0xaa, 0x21, 0xa9, 0xed}

// isWitnessCommitment reports whether a script is the coinbase segwit
// commitment. The 36-byte push length alone isn't enough — real payloads
// can also be exactly 36 bytes.
func isWitnessCommitment(pkScript []byte) bool {
	return len(pkScript) >= 6 &&
		pkScript[0] == txscript.OP_RETURN &&
		pkScript[1] == txscript.OP_DATA_36 &&
		bytes.Equal(pkScript[2:6], witnessCommitmentMagic)
}

// BIP300/301 message tags. A payload carrying one of these is sidechain
// consensus data, not a user OP_RETURN.
const (
	tagM1ProposeSidechain = "d5e0c4af"
	tagM2AckSidechain     = "d6e1c5df"
	tagM3ProposeBundle    = "d45aa943"
	tagM4AckBundleV1      = "d77d177601"
	tagM7                 = "d1617368"
)

func shouldSkip(pkScript []byte) bool {
	data := opreturns.OPReturnToReadable(pkScript[2:])
	switch {
	case strings.HasPrefix(data, tagM1ProposeSidechain),
		strings.HasPrefix(data, tagM2AckSidechain),
		strings.HasPrefix(data, tagM3ProposeBundle),
		strings.HasPrefix(data, tagM4AckBundleV1),
		strings.HasPrefix(data, tagM7):
		return true
	case data == "64656164626565664e6f7277656769616e2042c3b8726765204272656e6465206265636f6d657320707265736964656e74206f6620574546":
		return true
	}
	return false
}

// ensureSyncIsHealthy detects a true chain switch — i.e. the user pointed
// bitwindowd at a different chain — by comparing the hash bitcoind reports
// for block 1 against what we stored. Only that exact case justifies wiping
// processed_blocks; normal shallow reorgs are handled by the rewind-20 path
// in handleBlockTick. Transient bitcoind errors ("Block not found on disk"
// during pruning/reindex/restart, RPC unavailability) are NOT chain switches
// — they're a data-availability blip on bitcoind's side, and the right
// response is "skip this tick, try again next time."
func (p *Parser) ensureSyncIsHealthy(ctx context.Context) error {
	block1, err := p.getBlock(ctx, 1)
	if err != nil {
		if strings.Contains(err.Error(), "Block not found on disk") {
			// bitcoind has the block in its index but the on-disk data is
			// unavailable right now (pruning, reindex, recent restart, etc.).
			// Not a chain switch. Leave processed_blocks alone and retry.
			zerolog.Ctx(ctx).Warn().Err(err).
				Msgf("bitcoind_engine/parser: getblock(1) reported missing on disk; deferring sync-health check")
			return nil
		}
		return fmt.Errorf("detect chain deletion: get block 1: %w", err)
	}

	savedBlock1, err := blocks.GetProcessedBlock(ctx, p.db, 1)
	if errors.Is(err, sql.ErrNoRows) {
		// Nothing processed yet — no health check to do.
		return nil
	}
	if err != nil {
		return fmt.Errorf("detect chain deletion: get latest processed height: %w", err)
	}

	if !savedBlock1.Hash.IsEqual(lo.ToPtr(block1.Header.BlockHash())) {
		zerolog.Ctx(ctx).Warn().
			Str("stored_hash", savedBlock1.Hash.String()).
			Str("current_hash", block1.Header.BlockHash().String()).
			Msgf("bitcoind_engine/parser: block 1 hash differs from stored — chain switch detected, reprocessing all blocks")
		return p.resetProcessedChain(ctx)
	}

	return nil
}
