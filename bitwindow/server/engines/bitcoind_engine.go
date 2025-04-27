package engines

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	logpool "github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
)

func NewBitcoind(
	bitcoind *service.Service[*coreproxy.Bitcoind],
	db *sql.DB,
) *Parser {
	return &Parser{
		bitcoind: bitcoind,
		db:       db,
	}
}

// Parser is responsible for parsing blocks from bitcoind and storing OP_RETURN data in SQLite
type Parser struct {
	bitcoind *service.Service[*coreproxy.Bitcoind]
	db       *sql.DB
}

// Run runs the engine. It checks if a new block has been mined,
// and if so, handles it!
//
// Should be started in a goroutine.
func (p *Parser) Run(ctx context.Context) error {
	alertTicker := time.NewTicker(2 * time.Second)
	defer alertTicker.Stop()

	mempoolTicker := time.NewTicker(1 * time.Second)
	defer mempoolTicker.Stop()

	zerolog.Ctx(ctx).Info().
		Msgf("bitcoind_engine/parser: started parser ticker")

	processing := false
	for {
		select {
		case <-ctx.Done():
			zerolog.Ctx(ctx).Info().
				Msgf("bitcoind_engine/parser: stopping parser ticker")
			return nil

		case <-alertTicker.C:
			if processing {
				continue
			}

			// nolint:ineffassign
			processing = true
			if err := p.handleBlockTick(ctx); err != nil {
				zerolog.Ctx(ctx).Error().
					Err(err).
					Msgf("bitcoind_engine/parser: could not handle tick")
				continue
			}
			processing = false

		case <-mempoolTicker.C:
			if err := p.handleMempoolTick(ctx); err != nil {
				zerolog.Ctx(ctx).Error().
					Err(err).
					Msgf("bitcoind_engine/parser: could not handle mempool tick")
				continue
			}
		}
	}
}

// BlockResult represents the result of processing a single block
type BlockResult struct {
	Height int32
	Error  error
}

func (p *Parser) handleBlockTick(ctx context.Context) error {
	if err := p.detectChainDeletion(ctx); err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not detect chain deletion")
		return nil
	}

	// Get latest processed height
	lastProcessedBlock, err := blocks.GetProcessedTip(ctx, p.db)
	if err != nil {
		return fmt.Errorf("get latest processed height: %w", err)
	}

	var lastProcessedHeight int32 = -1
	var lastProcessedHash string
	if lastProcessedBlock != nil {
		lastProcessedHeight = lastProcessedBlock.Height
		lastProcessedHash = lastProcessedBlock.Hash
	}

	// Get current blockchain height
	currentHeight, currentHash, err := p.currentHeight(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get current height")
		return nil
	}

	if lastProcessedHeight == currentHeight && lastProcessedHash != currentHash {
		// probably some sort of reorg, process the last 20 blocks again!
		// doesnt handle very deep reorgs, but thats okay
		lastProcessedHeight -= 20
	}

	// Create a channel for processed blocks
	processedBlocksChan := make(chan processedBlockWithData, 200)
	doneChan := make(chan struct{})

	// Start a single goroutine that both processes blocks and handles database insertion
	go p.processBlocks(ctx, processedBlocksChan, doneChan)

	// Process blocks in batches of 100
	batchSize := int32(100)
	for startHeight := lastProcessedHeight + 1; startHeight <= currentHeight; startHeight += batchSize {
		endHeight := startHeight + batchSize - 1
		if endHeight > currentHeight {
			endHeight = currentHeight
		}

		// Fetch blocks in parallel
		newBlocks, err := p.getBlocksFromCore(ctx, startHeight, endHeight)
		if err != nil {
			return fmt.Errorf("get blocks: %w", err)
		}

		// Process fetched blocks
		for _, block := range newBlocks {
			processedBlock := processedBlockWithData{
				ProcessedBlock: blocks.ProcessedBlock{
					Height: int32(block.Height),
					Hash:   block.Hash,
				},
				Block: block,
			}
			processedBlocksChan <- processedBlock
		}
	}

	// Signal completion and wait for inserter to finish
	close(processedBlocksChan)
	<-doneChan

	return nil
}

// processedBlockWithData is a local type that includes the full block data
type processedBlockWithData struct {
	blocks.ProcessedBlock
	Block *corepb.GetBlockResponse
}

// processBlocks checks if a block contains any OP_RETURN transcations, inserts any found into the database,
// and marks the block as processed.
func (p *Parser) processBlocks(ctx context.Context, processedBlocksChan <-chan processedBlockWithData, doneChan chan<- struct{}) {
	// batch insert any processed blocks every time this ticker ticks
	ticker := time.NewTicker(200 * time.Millisecond)
	defer ticker.Stop()

	var blocksToInsert []blocks.ProcessedBlock
	for {
		select {
		case <-ctx.Done():
			// context cancelled, abort
			return

		case block, ok := <-processedBlocksChan:
			if !ok {
				if err := insertBlocks(ctx, p.db, blocksToInsert); err != nil {
					zerolog.Ctx(ctx).Error().
						Err(err).
						Msgf("bitcoind_engine/parser: could not insert blocks after channel closed")
				}

				// release the done channel to unblock the main loop
				close(doneChan)
				return
			}

			// add the block to the list of blocks to insert,
			// for the ticker to batch insert
			blocksToInsert = append(blocksToInsert, block.ProcessedBlock)

			// if the block only has one transaction it's uninteresting,
			// because it only has a coinbase transaction, e.g: an empty block
			if len(block.Block.Txids) != 1 {
				zerolog.Ctx(ctx).Trace().
					Int32("height", block.Height).
					Msgf("bitcoind_engine/parser: block has more than one transaction, inspecting transactions for OP returns")

				for _, txid := range block.Block.Txids {
					if err := p.opReturnForTXID(ctx, txid, &block.Height, block.Block.Time.AsTime()); err != nil {
						zerolog.Ctx(ctx).Error().
							Err(err).
							Msgf("bitcoind_engine/parser: could not process transaction %s", txid)
						continue
					}
				}
			}

		case <-ticker.C:
			if len(blocksToInsert) > 0 {
				if err := insertBlocks(ctx, p.db, blocksToInsert); err != nil {
					zerolog.Ctx(ctx).Error().
						Err(err).
						Msgf("bitcoind_engine/parser: could not insert blocks")
				}

				// reset the list of blocks to insert
				blocksToInsert = blocksToInsert[:0]
			}
		}
	}
}

func insertBlocks(ctx context.Context, db *sql.DB, blocksToInsert []blocks.ProcessedBlock) error {
	if len(blocksToInsert) == 0 {
		return nil
	}

	// batch insert all processed blocks
	if err := blocks.MarkBlocksProcessed(ctx, db, blocksToInsert); err != nil {
		return fmt.Errorf("mark blocks processed: %w", err)
	}

	zerolog.Ctx(ctx).Trace().
		Int("block_count", len(blocksToInsert)).
		Msgf("bitcoind_engine/parser: processed batch of blocks")

	return nil
}

func (p *Parser) handleMempoolTick(ctx context.Context) error {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return err
	}

	mempoolRes, err := bitcoind.GetRawMempool(ctx, connect.NewRequest(&corepb.GetRawMempoolRequest{
		Verbose: true,
	}))
	if err != nil {
		return fmt.Errorf("bitcoind: could not get mempool: %w", err)
	}

	for txid, tx := range mempoolRes.Msg.Transactions {
		if err := p.opReturnForTXID(ctx, txid, nil, tx.Time.AsTime()); err != nil {
			return fmt.Errorf("find op return for txid: %w", err)
		}
	}

	return nil
}

func (p *Parser) opReturnForTXID(ctx context.Context, txid string, height *int32, createdAt time.Time) error {
	rawTx, err := p.getRawTransaction(ctx, txid)
	if err != nil {
		return fmt.Errorf("get raw transaction: %w", err)
	}

	opReturns, err := p.findOPReturns(ctx, rawTx, height, createdAt)
	if err != nil {
		return fmt.Errorf("find and persist op returns: %w", err)
	}

	if err := p.persistOPReturns(ctx, opReturns); err != nil {
		return fmt.Errorf("persist op returns: %w", err)
	}

	if err := p.handleCreateTopics(ctx, opReturns); err != nil {
		return fmt.Errorf("handle create topics: %w", err)
	}

	return nil
}

func (p *Parser) persistOPReturns(ctx context.Context, opReturns []opreturns.OPReturn) error {
	for _, opReturn := range opReturns {
		if err := opreturns.Persist(ctx, p.db, opReturn.Height, opReturn.TxID, opReturn.Vout, opReturn.Data, opReturn.FeeSats, opReturn.CreatedAt); err != nil {
			return fmt.Errorf("persist op return: %w", err)
		}
	}

	return nil
}

func (p *Parser) handleCreateTopics(ctx context.Context, opReturns []opreturns.OPReturn) error {
	for _, opReturn := range opReturns {
		if opreturns.IsCreateTopic(opReturn.Data) {
			zerolog.Ctx(ctx).Info().
				Str("txid", opReturn.TxID).
				Msgf("bitcoind_engine/parser: found create topic")

			name, err := opreturns.NameFromCreateTopic(opReturn.Data)
			if err != nil {
				return fmt.Errorf("extract name from create topic: %w", err)
			}

			if err := opreturns.CreateTopic(ctx, p.db, string(opReturn.Data[:8]), name, opReturn.TxID); err != nil {
				return fmt.Errorf("create topic: %w", err)
			}

			zerolog.Ctx(ctx).Info().
				Str("txid", opReturn.TxID).
				Msgf("bitcoind_engine/parser: created topic")
		}
	}

	return nil
}

func (p *Parser) currentHeight(ctx context.Context) (int32, string, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return 0, "", err
	}

	resp, err := bitcoind.GetBlockchainInfo(ctx, &connect.Request[corepb.GetBlockchainInfoRequest]{})
	if err != nil {
		return 0, "", fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}

	return int32(resp.Msg.Blocks), resp.Msg.BestBlockHash, nil
}

func (p *Parser) getBlock(ctx context.Context, height int32) (*corepb.GetBlockResponse, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	resp, err := bitcoind.GetBlock(ctx, &connect.Request[corepb.GetBlockRequest]{
		Msg: &corepb.GetBlockRequest{
			Height:    &height,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get block: %w", err)
	}

	return resp.Msg, nil
}

func (p *Parser) getRawTransaction(ctx context.Context, txid string) (*corepb.RawTransaction, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	resp, err := bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
		Msg: &corepb.GetRawTransactionRequest{
			Txid: txid,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get raw transaction: %w", err)
	}

	return resp.Msg.Tx, nil
}

// finds all OP_RETURN outputs for a specific tx
func (p *Parser) findOPReturns(
	ctx context.Context, tx *corepb.RawTransaction, height *int32,
	createdAt time.Time,
) ([]opreturns.OPReturn, error) {
	decodedTx, err := btcutil.NewTxFromBytes(tx.Data)
	if err != nil {
		return nil, fmt.Errorf("could not decode raw transaction: %w", err)
	}
	msgTx := decodedTx.MsgTx()
	txid := msgTx.TxID()

	isCoinbase := len(msgTx.TxIn) > 0 && msgTx.TxIn[0].PreviousOutPoint.Hash.String() == "0000000000000000000000000000000000000000000000000000000000000000"
	// every coinbase transaction has a OP_RETURN output we don't care about
	if isCoinbase && len(msgTx.TxOut) == 2 {
		return nil, nil
	}

	// Check outputs for OP_NOP5
	for _, txout := range msgTx.TxOut {
		script := txout.PkScript
		if len(script) > 0 && script[0] == txscript.OP_NOP5 {
			return nil, nil // OP_DRIVECHAIN, skipping
		}
	}

	var opReturns []opreturns.OPReturn
	for vout, txout := range msgTx.TxOut {
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

		if isOPReturn {
			// Calculate fee by getting all inputs and outputs
			var inputSum int64
			for _, txin := range msgTx.TxIn {
				if isCoinbase {
					continue // Coinbase input has no previous output to look up
				}
				// Get the previous transaction to find the output amount
				prevTx, err := p.getRawTransaction(ctx, txin.PreviousOutPoint.Hash.String())
				if err != nil {
					return nil, fmt.Errorf("could not get previous transaction: %w", err)
				}
				prevDecodedTx, err := btcutil.NewTxFromBytes(prevTx.Data)
				if err != nil {
					return nil, fmt.Errorf("could not decode previous transaction: %w", err)
				}
				inputSum += prevDecodedTx.MsgTx().TxOut[txin.PreviousOutPoint.Index].Value
			}

			var outputSum int64
			for _, txout := range msgTx.TxOut {
				outputSum += txout.Value
			}

			fee := inputSum - outputSum

			// Parse the OP_RETURN data correctly
			data, err := parseOPReturnData(txout.PkScript)
			if err != nil {
				return nil, fmt.Errorf("could not parse OP_RETURN data: %w", err)
			}

			// Log both hex and string representation for easier debugging
			logger := zerolog.Ctx(ctx).Info()
			logger.
				Str("data_hex", hex.EncodeToString(data)).
				Str("data", opreturns.OPReturnToReadable(data)).
				Str("txid", txid).
				Msgf("bitcoind_engine/parser: found op_return")

			opReturns = append(opReturns, opreturns.OPReturn{
				TxID:      txid,
				Data:      data,
				FeeSats:   fee,
				Vout:      int32(vout),
				Height:    height,
				CreatedAt: createdAt,
			})
		}
	}

	return opReturns, nil
}

// parseOPReturnData extracts the actual data from an OP_RETURN script by handling
// different PUSHDATA opcodes correctly
func parseOPReturnData(script []byte) ([]byte, error) {
	if len(script) < 2 || script[0] != txscript.OP_RETURN {
		return nil, fmt.Errorf("not an OP_RETURN script")
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
			return nil, fmt.Errorf("script too short for OP_DATA_%d: need %d bytes but have %d", dataLen, dataLen, len(script))
		}
		return script[:dataLen], nil

	case opcode == txscript.OP_PUSHDATA1:
		if len(script) < 1 {
			return nil, fmt.Errorf("script too short for PUSHDATA1")
		}
		dataLen := int(script[0])
		script = script[1:] // Skip length byte
		if len(script) < dataLen {
			return nil, fmt.Errorf("script too short for PUSHDATA1: need %d bytes but have %d", dataLen, len(script))
		}
		return script[:dataLen], nil

	case opcode == txscript.OP_PUSHDATA2:
		if len(script) < 2 {
			return nil, fmt.Errorf("script too short for PUSHDATA2")
		}
		dataLen := int(script[0]) | int(script[1])<<8
		script = script[2:] // Skip length bytes
		if len(script) < dataLen {
			return nil, fmt.Errorf("script too short for PUSHDATA2: need %d bytes but have %d", dataLen, len(script))
		}
		return script[:dataLen], nil

	case opcode == txscript.OP_PUSHDATA4:
		if len(script) < 4 {
			return nil, fmt.Errorf("script too short for PUSHDATA4")
		}
		dataLen := int(script[0]) | int(script[1])<<8 | int(script[2])<<16 | int(script[3])<<24
		script = script[4:] // Skip length bytes
		if len(script) < dataLen {
			return nil, fmt.Errorf("script too short for PUSHDATA4: need %d bytes but have %d", dataLen, len(script))
		}
		return script[:dataLen], nil

	default:
		return nil, fmt.Errorf("unexpected opcode 0x%x after OP_RETURN", opcode)
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

// detectChainDeletion checks if the hash of block at height 1 differs
// from whats in our database. If so, it wipes everything in processed_blocks,
// to force a re-sync.
func (p *Parser) detectChainDeletion(ctx context.Context) error {
	// Get block at height 1 to check for chain switch
	block1, err := p.getBlock(ctx, 1)
	if err != nil && strings.Contains(err.Error(), "Block not found on disk") {
		// someone wiped the chain, and bitcoind can't find the block we're requesting
		zerolog.Ctx(ctx).Warn().
			Err(err).
			Msgf("bitcoind_engine/parser: complete reorg detected, wiping processed blocks")
	} else if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get block at height 1")
		return fmt.Errorf("detect chain deletion: %w", err)
	}

	savedBlock1, err := blocks.GetProcessedBlock(ctx, p.db, 1)
	if errors.Is(err, sql.ErrNoRows) {
		// no blocks have been processed yet
	} else if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get latest processed height")
		return fmt.Errorf("detect chain deletion: %w", err)
	}

	if block1 == nil || (savedBlock1.Hash != "" && savedBlock1.Hash != block1.Hash) {
		zerolog.Ctx(ctx).Info().
			Msgf("bitcoind_engine/parser: detected chain switch, reprocessing all blocks")
		return blocks.WipeProcessedBlocks(ctx, p.db)
	}

	return nil
}

// getBlocksFromCore fetches multiple blocks in parallel
func (p *Parser) getBlocksFromCore(ctx context.Context, startHeight, endHeight int32) ([]*corepb.GetBlockResponse, error) {
	// Calculate number of blocks to fetch
	numBlocks := endHeight - startHeight + 1
	if numBlocks <= 0 {
		return nil, nil
	}

	// Create a pool for parallel fetching
	pool := logpool.NewWithResults[*corepb.GetBlockResponse](ctx, "bitcoind_engine/getBlocks")

	// Fetch blocks in parallel
	for height := startHeight; height <= endHeight; height++ {
		pool.Go(fmt.Sprintf("block-%d", height), func(ctx context.Context) (*corepb.GetBlockResponse, error) {
			return p.getBlock(ctx, height)
		})
	}

	// Wait for all blocks to be fetched
	blocks, err := pool.Wait(ctx)
	if err != nil {
		return nil, fmt.Errorf("wait for blocks: %w", err)
	}

	return blocks, nil
}
