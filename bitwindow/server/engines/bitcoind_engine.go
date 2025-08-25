package engines

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
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
	"github.com/btcsuite/btcd/txscript"
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
				zerolog.Ctx(ctx).Trace().
					Msgf("bitcoind_engine/parser: still processing block, skipping alert tick")
				continue
			}

			// nolint:ineffassign
			processing = true

			zerolog.Ctx(ctx).Trace().
				Msgf("bitcoind_engine/parser: processing block tick")

			if err := p.handleBlockTick(ctx); err != nil {
				return err
			}

			zerolog.Ctx(ctx).Trace().
				Msgf("bitcoind_engine/parser: finished processing block tick")
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

	err := p.ensureSyncIsHealthy(ctx)
	if err != nil && strings.Contains(err.Error(), "Block height out of range") {
		zerolog.Ctx(ctx).Info().
			Msgf("bitcoind_engine/parser: still in IBD, waiting for header download..")
		return nil
	} else if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not detect chain deletion")
		return nil
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
		lastProcessedHash   string
	)
	if lastProcessedBlock != nil {
		lastProcessedHeight = uint32(lastProcessedBlock.Height)
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

		pool := logpool.NewWithResults[*corepb.GetBlockResponse](ctx, "bitcoind_engine/processBlocks").
			WithCancelOnError().
			WithFirstError()

		for height := batchStart; height <= batchEnd; height++ {
			pool.Go(fmt.Sprintf("block-%d", height), func(ctx context.Context) (*corepb.GetBlockResponse, error) {
				ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
				defer cancel()

				zerolog.Ctx(ctx).Trace().
					Msgf("bitcoind_engine/parser: processing block %d", height)

				block, err := p.getBlock(ctx, height)
				if err != nil {
					zerolog.Ctx(ctx).Error().
						Err(err).
						Msgf("bitcoind_engine/parser: could not get block %d", height)
					return nil, err
				}

				// If the block only has one transaction it's uninteresting,
				// because it only has a coinbase transaction, e.g: an empty block
				if len(block.Txids) > 1 {
					zerolog.Ctx(ctx).Info().
						Int32("height", int32(block.Height)).
						Msgf("bitcoind_engine/parser: block has more than one transaction, inspecting transactions for OP returns")

					height := int32(block.Height)
					for _, txid := range block.Txids {
						if err := p.opReturnForTXID(ctx, txid, &height, block.Time.AsTime()); err != nil {
							zerolog.Ctx(ctx).Error().
								Err(err).
								Msgf("bitcoind_engine/parser: could not process transaction %s", txid)
						}
					}

					zerolog.Ctx(ctx).Trace().
						Int32("height", int32(block.Height)).
						Msgf("bitcoind_engine/parser: finished processing transactions for block %d", block.Height)
				}

				return block, nil
			})
		}

		zerolog.Ctx(ctx).Trace().
			Msgf("bitcoind_engine/parser: waiting for block processing to finish")
		results, err := pool.Wait(ctx)
		if err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not process blocks")
			return fmt.Errorf("could not process blocks: %w", err)
		}

		if err := p.processBlocks(ctx, results); err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not process blocks")
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
func (p *Parser) processBlocks(ctx context.Context, coreBlocks []*corepb.GetBlockResponse) error {

	// Insert the processed blocks
	if err := blocks.MarkBlocksProcessed(ctx, p.db, lo.Map(coreBlocks, func(block *corepb.GetBlockResponse, _ int) blocks.ProcessedBlock {
		return blocks.ProcessedBlock{
			Height:    int32(block.Height),
			Hash:      block.Hash,
			BlockTime: block.Time.AsTime(),
			Txids:     block.Txids,
		}
	})); err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not insert block")
		return err
	}

	zerolog.Ctx(ctx).Trace().
		Int32("height", int32(len(coreBlocks))).
		Msgf("bitcoind_engine/parser: successfully inserted blocks")

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

func (p *Parser) currentHeight(ctx context.Context) (uint32, string, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return 0, "", err
	}

	resp, err := bitcoind.GetBlockchainInfo(ctx, &connect.Request[corepb.GetBlockchainInfoRequest]{})
	if err != nil {
		return 0, "", fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}

	return resp.Msg.Blocks, resp.Msg.BestBlockHash, nil
}

func (p *Parser) getBlock(ctx context.Context, height uint32) (*corepb.GetBlockResponse, error) {
	bitcoind, err := p.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	resp, err := bitcoind.GetBlock(ctx, &connect.Request[corepb.GetBlockRequest]{
		Msg: &corepb.GetBlockRequest{
			Height:    lo.ToPtr(int32(height)),
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
