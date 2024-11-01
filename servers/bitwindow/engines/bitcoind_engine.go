package bitcoind_engine

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"connectrpc.com/connect"
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
	lastProcessedHeight, lastProcessedHash, err := p.latestProcessedHeight(ctx)
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

		if err := p.findAndPersistOPReturns(ctx, tx, rawTx, height); err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not find and persist op returns for tx %s", tx)
			return err
		}
	}

	// Mark block as processed
	if err := p.markBlockProcessed(ctx, height, block.Hash); err != nil {
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

func (p *Parser) latestProcessedHeight(ctx context.Context) (int32, string, error) {
	var height int32
	var blockHash string
	err := p.db.QueryRowContext(ctx, `
		SELECT height, block_hash 
		FROM processed_blocks 
		ORDER BY height DESC 
		LIMIT 1
	`).Scan(&height, &blockHash)
	if errors.Is(err, sql.ErrNoRows) {
		return -1, "", nil
	} else if err != nil {
		return 0, "", fmt.Errorf("latest processed height: %w", err)
	}

	return height, blockHash, nil
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

func (p *Parser) findAndPersistOPReturns(ctx context.Context, txid string, tx *corepb.RawTransaction, height int32) error {
	decodedTx, err := btcutil.NewTxFromBytes(tx.Data)
	if err != nil {
		return fmt.Errorf("could not decode raw transaction: %w", err)
	}

	isCoinbase := len(decodedTx.MsgTx().TxIn) > 0 && decodedTx.MsgTx().TxIn[0].PreviousOutPoint.Hash.String() == "0000000000000000000000000000000000000000000000000000000000000000"
	// every coinbase transaction has a OP_RETURN output we don't care about
	if isCoinbase && len(decodedTx.MsgTx().TxOut) == 2 {
		zerolog.Ctx(ctx).Info().
			Str("txid", txid).
			Int32("height", height).
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
				Int32("height", height).
				Msgf("bitcoind_engine/parser: skipping coinbase OP_RETURN")
			continue
		}

		if isOPReturn {
			data := txout.PkScript[1:]
			zerolog.Ctx(ctx).Info().
				Str("txid", txid).
				Int32("height", height).
				Str("hex", hex.EncodeToString(data)).
				Str("string", string(data)).
				Msgf("bitcoind_engine/parser: found op_return")

			if err := p.persistOPReturn(ctx, height, txid, int32(vout), data); err != nil {
				return fmt.Errorf("could not persist op_return: %w", err)
			}
		}
	}

	return nil
}

func (p *Parser) persistOPReturn(ctx context.Context, height int32, txid string, vout int32, data []byte) error {
	_, err := p.db.ExecContext(ctx, `
		INSERT INTO op_returns (
			txid,
			vout,
			op_return_data,
			height
		) VALUES (?, ?, ?, ?)
		ON CONFLICT (txid, vout) DO UPDATE SET
			op_return_data = excluded.op_return_data
	`, txid, vout, data, height)
	if err != nil {
		return fmt.Errorf("could not persist op_return: %w", err)
	}

	return nil
}

func (p *Parser) markBlockProcessed(ctx context.Context, height int32, hash string) error {
	_, err := p.db.ExecContext(ctx, `
		REPLACE INTO processed_blocks (height, block_hash) 
		VALUES (?, ?)
	`, height, hash)
	if err != nil {
		return fmt.Errorf("mark block processed: %w", err)
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

	// Check if we need to reprocess everything due to chain switch
	var savedBlock1Hash string
	err = p.db.QueryRowContext(ctx, `SELECT block_hash FROM processed_blocks WHERE height = 1`).Scan(&savedBlock1Hash)
	if err != nil && err != sql.ErrNoRows {
		zerolog.Ctx(ctx).Error().
			Err(err).
			Msgf("bitcoind_engine/parser: could not get saved block 1 hash")
		return fmt.Errorf("detect chain deletion: %w", err)
	}

	if savedBlock1Hash != "" && savedBlock1Hash != block1.Hash {
		zerolog.Ctx(ctx).Info().
			Msgf("bitcoind_engine/parser: detected chain switch, reprocessing all blocks")
		return p.wipeProcessedBlocks(ctx)
	}

	return nil
}

func (p *Parser) wipeProcessedBlocks(ctx context.Context) error {
	_, err := p.db.ExecContext(ctx, `DELETE FROM processed_blocks`)
	if err != nil {
		return fmt.Errorf("wipe processed blocks: %w", err)
	}
	return nil
}
