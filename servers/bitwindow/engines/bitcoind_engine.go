package bitcoind_engine

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/opreturns"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
)

func New(
	bitcoind *coreproxy.Bitcoind,
	db *sql.DB,
) *Parser {
	return &Parser{
		bitcoind: bitcoind,
		db:       db,
	}
}

// Parser is responsible for parsing blocks from bitcoind and storing OP_RETURN data in SQLite
type Parser struct {
	bitcoind *coreproxy.Bitcoind
	db       *sql.DB
}

// Run runs the engine. It checks if a new block has been mined,
// and if so, handles it!
//
// Should be started in a goroutine.
func (p *Parser) Run(ctx context.Context) error {
	// Check every other second. We wouldn't wanna miss a nice rate, now would we
	alertTicker := time.NewTicker(2 * time.Second)
	defer alertTicker.Stop()

	zerolog.Ctx(ctx).Info().
		Msgf("bitcoind_engine/parser: starting parser ticker")

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

			processing = true
			p.handleTick(ctx)
			processing = false
		}
	}
}

func (p *Parser) handleTick(ctx context.Context) {
	if err := p.detectChainDeletion(ctx); err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not detect chain deletion")
		return
	}

	// Get latest processed height
	lastProcessedHeight, lastProcessedHash, err := blocks.LatestProcessedHeight(ctx, p.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get latest processed height")
		return
	}

	// Get current blockchain height
	currentHeight, currentHash, err := p.currentHeight(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get current height")
		return
	}

	if lastProcessedHeight == currentHeight && lastProcessedHash != currentHash {
		// probably some sort of reorg, process the last 20 blocks again!
		// doesnt handle very deep reorgs, but thats okay
		lastProcessedHeight -= 20
	}

	// Process all new blocks
	for height := lastProcessedHeight + 1; height <= currentHeight; height++ {
		if err := p.processBlock(ctx, height); err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not process block %d", height)
			continue
		}
	}
}

func (p *Parser) processBlock(ctx context.Context, height int32) error {
	zerolog.Ctx(ctx).Info().
		Int32("height", height).
		Msgf("bitcoind_engine/parser: processing block")

	block, err := p.getBlock(ctx, height)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get block at height %d", height)
		return err
	}

	// Process each transaction in the block
	for _, tx := range block.Txids {
		rawTx, err := p.getRawTransaction(ctx, tx)
		if err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not get transaction %s", tx)
			return err
		}

		if err := p.findAndPersistOPReturns(ctx, tx, rawTx, block); err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not find and persist op returns for tx %s", tx)
			return err
		}
	}

	// Mark block as processed
	if err := blocks.MarkBlockProcessed(ctx, p.db, height, block.Hash); err != nil {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not mark block %d as processed", height)
		return err
	}

	zerolog.Ctx(ctx).Info().
		Int32("height", height).
		Msgf("bitcoind_engine/parser: processed block")

	return nil
}

func (p *Parser) currentHeight(ctx context.Context) (int32, string, error) {
	resp, err := p.bitcoind.GetBlockchainInfo(ctx, &connect.Request[corepb.GetBlockchainInfoRequest]{})
	if err != nil {
		return 0, "", fmt.Errorf("current height: %w", err)
	}

	return int32(resp.Msg.Blocks), resp.Msg.BestBlockHash, nil
}

func (p *Parser) getBlock(ctx context.Context, height int32) (*corepb.GetBlockResponse, error) {
	resp, err := p.bitcoind.GetBlock(ctx, &connect.Request[corepb.GetBlockRequest]{
		Msg: &corepb.GetBlockRequest{
			Height:    &height,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("get block: %w", err)
	}

	return resp.Msg, nil
}

func (p *Parser) getRawTransaction(ctx context.Context, txid string) (*corepb.RawTransaction, error) {
	resp, err := p.bitcoind.GetRawTransaction(ctx, &connect.Request[corepb.GetRawTransactionRequest]{
		Msg: &corepb.GetRawTransactionRequest{
			Txid: txid,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("get raw transaction: %w", err)
	}

	return resp.Msg.Tx, nil
}

func (p *Parser) findAndPersistOPReturns(
	ctx context.Context, txid string, tx *corepb.RawTransaction, block *corepb.GetBlockResponse,
) error {
	decodedTx, err := btcutil.NewTxFromBytes(tx.Data)
	if err != nil {
		return fmt.Errorf("could not decode raw transaction: %w", err)
	}

	isCoinbase := len(decodedTx.MsgTx().TxIn) > 0 && decodedTx.MsgTx().TxIn[0].PreviousOutPoint.Hash.String() == "0000000000000000000000000000000000000000000000000000000000000000"
	// every coinbase transaction has a OP_RETURN output we don't care about
	if isCoinbase && len(decodedTx.MsgTx().TxOut) == 2 {
		zerolog.Ctx(ctx).Info().
			Str("txid", txid).
			Int32("height", int32(block.Height)).
			Msgf("bitcoind_engine/parser: skipping coinbase transaction with no extra outputs")

		return nil
	}

	for vout, txout := range decodedTx.MsgTx().TxOut {
		if len(txout.PkScript) < 2 {
			continue
		}

		isOPReturn := txout.PkScript[0] == txscript.OP_RETURN
		isCoinbaseReturn := isOPReturn && txout.PkScript[1] == txscript.OP_DATA_36
		if isCoinbaseReturn {
			zerolog.Ctx(ctx).Info().
				Str("txid", txid).
				Int32("height", int32(block.Height)).
				Msgf("bitcoind_engine/parser: skipping coinbase OP_RETURN")
			continue
		}

		if isOPReturn {
			// Calculate fee by getting all inputs and outputs
			var inputSum int64
			for _, txin := range decodedTx.MsgTx().TxIn {
				if isCoinbase {
					continue // Coinbase input has no previous output to look up
				}
				// Get the previous transaction to find the output amount
				prevTx, err := p.getRawTransaction(ctx, txin.PreviousOutPoint.Hash.String())
				if err != nil {
					return fmt.Errorf("could not get previous transaction: %w", err)
				}
				prevDecodedTx, err := btcutil.NewTxFromBytes(prevTx.Data)
				if err != nil {
					return fmt.Errorf("could not decode previous transaction: %w", err)
				}
				inputSum += prevDecodedTx.MsgTx().TxOut[txin.PreviousOutPoint.Index].Value
			}

			var outputSum int64
			for _, txout := range decodedTx.MsgTx().TxOut {
				outputSum += txout.Value
			}

			fee := inputSum - outputSum

			data := txout.PkScript[2:]
			// Log both hex and string representation for easier debugging
			logger := zerolog.Ctx(ctx).Info()
			logger.
				Str("data_hex", hex.EncodeToString(data)).
				Str("data", opreturns.OPReturnToReadable(data)).
				Str("txid", txid).
				Int32("height", int32(block.Height)).
				Msgf("bitcoind_engine/parser: found op_return")

			height := int32(block.Height)
			if err := opreturns.Persist(ctx, p.db, &height, txid, int32(vout), data, fee, block.Time.AsTime()); err != nil {
				return err
			}
		}
	}

	return nil
}

// detectChainDeletion checks if the hash of block at height 1 differs
// from whats in our database. If so, it wipes everything in processed_blocks,
// to force a re-sync.
func (p *Parser) detectChainDeletion(ctx context.Context) error {
	// Get block at height 1 to check for chain switch
	block1, err := p.getBlock(ctx, 1)
	if err != nil {
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

	if savedBlock1.Hash != "" && savedBlock1.Hash != block1.Hash {
		zerolog.Ctx(ctx).Info().
			Msgf("bitcoind_engine/parser: detected chain switch, reprocessing all blocks")
		return blocks.WipeProcessedBlocks(ctx, p.db)
	}

	return nil
}
