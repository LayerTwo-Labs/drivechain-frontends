package engines

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	logpool "github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
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
	}
}

// Parser is responsible for parsing blocks from bitcoind and storing OP_RETURN data in SQLite
type Parser struct {
	bitcoind *service.Service[corerpc.BitcoinServiceClient]
	db       *sql.DB
	conf     config.Config

	mu     sync.Mutex
	topics []opreturns.TopicInfo
}

func (p *Parser) isKnownTopic(data []byte) bool {
	p.mu.Lock()
	defer p.mu.Unlock()

	if len(data) < opreturns.TopicIdLength {
		return false
	}

	return lo.ContainsBy(p.topics, func(t opreturns.TopicInfo) bool {
		return bytes.HasPrefix(data, t.ID[:])
	})
}

// Run runs the engine. It checks if a new block has been mined,
// and if so, handles it!
//
// Should be started in a goroutine.
func (p *Parser) Run(ctx context.Context) error {
	alertTicker := time.NewTicker(2 * time.Second)
	defer alertTicker.Stop()

	topics, err := opreturns.ListTopics(ctx, p.db)
	if err != nil {
		return fmt.Errorf("list topics: %w", err)
	}
	p.topics = lo.Map(topics, func(t opreturns.Topic, _ int) opreturns.TopicInfo {
		return opreturns.TopicInfo{
			ID:   t.Topic,
			Name: t.Name,
		}
	})

	zerolog.Ctx(ctx).Info().
		Msgf("bitcoind_engine/parser: started parser ticker")

	for {
		select {
		case <-ctx.Done():
			zerolog.Ctx(ctx).Info().Err(ctx.Err()).
				Msgf("bitcoind_engine/parser: stopping parser ticker")
			return nil

		case <-alertTicker.C:

			zerolog.Ctx(ctx).Trace().
				Msgf("bitcoind_engine/parser: processing block tick")

			if err := p.handleBlockTick(ctx); err != nil {
				zerolog.Ctx(ctx).Err(err).Msgf("unable to handle block tick")
				continue
			}

			zerolog.Ctx(ctx).Trace().
				Msgf("bitcoind_engine/parser: finished processing block tick")

		}
	}
}

// BlockResult represents the result of processing a single block
type BlockResult struct {
	Height int32
	Error  error
}

func (p *Parser) handleBlockTick(ctx context.Context) error {

	switch err := p.ensureSyncIsHealthy(ctx); {
	case err != nil &&
		strings.Contains(err.Error(), "Block height out of range"):

		zerolog.Ctx(ctx).Info().
			Msgf("bitcoind_engine/parser: still in IBD, waiting for header download..")
		return nil

	case connect.CodeOf(err) == connect.CodeUnavailable:
		zerolog.Ctx(ctx).Warn().Err(err).
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

	// Get current blockchain height
	currentHeight, currentHash, err := p.currentHeight(ctx)
	if err != nil {
		return fmt.Errorf("fetch current height: %w", err)
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bitcoind_engine/parser: found current height: %d", currentHeight)

	if lastProcessedHeight == currentHeight && lastProcessedHash != currentHash {
		// probably some sort of reorg, process the last 20 blocks again!
		// doesnt handle very deep reorgs, but thats okay
		lastProcessedHeight -= 20
		zerolog.Ctx(ctx).Trace().
			Msgf("bitcoind_engine/parser: detected reorg, processing last 20 blocks")
	}

	const batchSize = 30

	zerolog.Ctx(ctx).Trace().
		Uint32("last-processed-height", lastProcessedHeight).
		Uint32("batch-size", batchSize).
		Msgf("bitcoind_engine/parser: processing blocks")

	for batchStart := lastProcessedHeight + 1; batchStart <= currentHeight; batchStart += batchSize {
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

	return nil
}

// HandleNewRawTransaction can be called on a brand new transaction
// from the mempool.
func (p *Parser) HandleNewRawTransaction(
	ctx context.Context, tx *wire.MsgTx,
) error {
	if err := p.opReturnForTXID(ctx, tx, nil, nil); err != nil {
		return fmt.Errorf("find op return for txid: %w", err)
	}

	return nil
}

// Nil height means unconfirmed. Nil time means we don't know the TX time
func (p *Parser) opReturnForTXID(
	ctx context.Context, tx *wire.MsgTx,
	height *uint32, createdAt *time.Time,
) error {
	if createdAt != nil && createdAt.IsZero() {
		panic("PROGRAMMER ERROR: non-nil, zero create time")
	}

	opReturns, err := p.handleOpReturns(ctx, tx, height)
	if err != nil {
		return fmt.Errorf("find OP_RETURNs: %w", err)
	}

	if err := opreturns.Persist(ctx, p.db, opReturns); err != nil {
		return err
	}

	return nil
}

func (p *Parser) handleCreateTopic(
	ctx context.Context, info opreturns.TopicInfo, txid string,
) error {

	zerolog.Ctx(ctx).Info().
		Msgf("bitcoind_engine/parser: found create topic: %s", info.Name)

	if err := opreturns.CreateTopic(
		ctx, p.db, info.ID, info.Name, txid,
	); err != nil {
		return fmt.Errorf("persist create topic: %w", err)
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	p.topics = append(p.topics, opreturns.TopicInfo{
		ID:   info.ID,
		Name: info.Name,
	})

	return nil
}

func (p *Parser) currentHeight(ctx context.Context) (uint32, chainhash.Hash, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return 0, chainhash.Hash{}, err
	}

	resp, err := bitcoind.GetBlockchainInfo(ctx, &connect.Request[corepb.GetBlockchainInfoRequest]{})
	if err != nil {
		return 0, chainhash.Hash{}, err
	}

	hash, err := chainhash.NewHashFromStr(resp.Msg.BestBlockHash)
	if err != nil {
		return 0, chainhash.Hash{}, fmt.Errorf("parse best block hash: %w", err)
	}

	return resp.Msg.Blocks, *hash, nil
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
	ctx context.Context, tx *wire.MsgTx, height *uint32,
) ([]opreturns.OPReturn, error) {
	txid := tx.TxID()

	var emptyHash chainhash.Hash
	isCoinbase := len(tx.TxIn) > 0 && tx.TxIn[0].PreviousOutPoint.Hash.IsEqual(&emptyHash)
	// every coinbase transaction has a OP_RETURN output we don't care about
	if isCoinbase && len(tx.TxOut) == 2 {
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
		isCoinbaseReturn := isOPReturn && txout.PkScript[1] == txscript.OP_DATA_36
		if isCoinbaseReturn {
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

		if info, ok := opreturns.IsCreateTopic(data); ok {
			if err := p.handleCreateTopic(ctx, info, txid); err != nil {
				return nil, err
			}
		}

		zerolog.Ctx(ctx).Debug().
			Str("txid", txid).
			Int("vout", vout).
			Msgf("bitcoind_engine/parser: found OP_RETURN")

		var fee btcutil.Amount

		// If this is a coin news message, we need to figoure out the fee
		// paid.
		if p.isKnownTopic(data) {
			if rawTx == nil {
				core, err := p.bitcoind.Get(ctx)
				if err != nil {
					return nil, fmt.Errorf("get bitcoind: %w", err)
				}
				res, err := core.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
					// needed for fee info the be included
					Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
					Txid:      txid,
				}))
				if err != nil {
					return nil, fmt.Errorf("get raw transaction %q: %w", txid, err)
				}
				rawTx = res.Msg
			}

			var err error
			fee, err = btcutil.NewAmount(rawTx.GetFee())
			if err != nil {
				return nil, err
			}
		}

		opReturns = append(opReturns, opreturns.OPReturn{
			TxID:   txid,
			Data:   data,
			Vout:   int32(vout),
			Height: height,
			Fee:    fee,
		})
	}

	return opReturns, nil
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

func shouldSkip(pkScript []byte) bool {
	data := pkScript[2:]
	// heck if i know what these are, but they are related to sidechains!
	switch {
	case strings.HasPrefix(opreturns.OPReturnToReadable(data), "d1617368"):
		return true
	case strings.HasPrefix(opreturns.OPReturnToReadable(data), "d77d177601"):
		return true
		// thunder sidechain creation
	case opreturns.OPReturnToReadable(data) == "d6e1c5df09879b5f8ebc8bab50ca9218849c2e173a596d1ac0e84b9f10981c3078da6571af":
		return true
	case opreturns.OPReturnToReadable(data) == "d6e1c5df02f82573d5420e910fe350d5e1b61da16551a269d682b51f35f2343c265285c056":
		return true
	case opreturns.OPReturnToReadable(data) == "64656164626565664e6f7277656769616e2042c3b8726765204272656e6465206265636f6d657320707265736964656e74206f6620574546":
		return true
	case opreturns.OPReturnToReadable(data) == "d5e0c4af0900077468756e6465727468756e646572206465736372697074696f6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000":
		return true
	case opreturns.OPReturnToReadable(data) == "d45aa943091303c6de5739c2fb3a021a8bd2b8c9fa8bcd8f8c18954bec00aa8f9b2cf13602":
		return true
	}
	return false
}

// ensureSyncIsHealthy checks if the hash of block at height 1 differs
// from whats in our database. If so, it wipes everything in processed_blocks,
// to force a re-sync.
func (p *Parser) ensureSyncIsHealthy(ctx context.Context) error {
	// Get block at height 1 to check for chain switch
	block1, err := p.getBlock(ctx, 1)
	if err != nil && strings.Contains(err.Error(), "Block not found on disk") {
		// someone wiped the chain, and bitcoind can't find the block we're requesting
		zerolog.Ctx(ctx).Warn().
			Err(err).
			Msgf("bitcoind_engine/parser: complete reorg detected, wiping processed blocks")
	} else if err != nil {
		return fmt.Errorf("detect chain deletion: get block 1: %w", err)
	}

	savedBlock1, err := blocks.GetProcessedBlock(ctx, p.db, 1)
	if errors.Is(err, sql.ErrNoRows) {
		// no blocks have been processed yet
	} else if err != nil {
		return fmt.Errorf("detect chain deletion: get latest processed height: %w", err)
	}

	if block1 == nil || !savedBlock1.Hash.IsEqual(lo.ToPtr(block1.Header.BlockHash())) {
		zerolog.Ctx(ctx).Info().
			Msgf("bitcoind_engine/parser: detected chain switch, reprocessing all blocks")
		return blocks.WipeProcessedBlocks(ctx, p.db)
	}

	return nil
}
