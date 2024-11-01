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
	// Get latest processed height
	lastProcessed, lastProcessedHash, err := p.latestProcessedHeight(ctx)
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

	if lastProcessed == currentHeight && lastProcessedHash != currentHash {
		// probably some sort of reorg, process the block again!
		// doesnt handle deep reorgs, but thats okay
		lastProcessed--
	}

	// Process all new blocks
	for height := lastProcessed + 1; height <= currentHeight; height++ {
		zerolog.Ctx(ctx).Info().
			Int32("last_processed", lastProcessed).
			Int32("current", currentHeight).
			Int32("height", height).
			Msgf("bitcoind_engine/parser: processing block")

		block, err := p.getBlock(ctx, height)
		if err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not get block at height %d", height)
			continue
		}

		// Process each transaction in the block
		for _, tx := range block.Txids {
			rawTx, err := p.getRawTransaction(ctx, tx)
			if err != nil {
				zerolog.Ctx(ctx).Error().
					Err(err).
					Msgf("bitcoind_engine/parser: could not get transaction %s", tx)
				continue
			}

			if err := p.findAndPersistOPReturns(ctx, tx, rawTx, height); err != nil {
				zerolog.Ctx(ctx).Error().
					Err(err).
					Msgf("bitcoind_engine/parser: could not find and persist op returns for tx %s", tx)
				continue
			}
		}

		// Mark block as processed
		if err := p.markBlockProcessed(ctx, height, block.Hash); err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msgf("bitcoind_engine/parser: could not mark block %d as processed", height)
			continue
		}

		zerolog.Ctx(ctx).Info().
			Int32("height", height).
			Msgf("bitcoind_engine/parser: processed block")
	}
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

	// Skip if this is a coinbase transaction
	if len(decodedTx.MsgTx().TxIn) > 0 && decodedTx.MsgTx().TxIn[0].PreviousOutPoint.Hash.String() == "0000000000000000000000000000000000000000000000000000000000000000" {
		fmt.Printf("%+v\n", decodedTx.MsgTx().TxIn[0])
		zerolog.Ctx(ctx).Info().
			Str("txid", txid).
			Int32("height", height).
			Msgf("bitcoind_engine/parser: skipping coinbase transaction")

		return nil
	}

	for vout, txout := range decodedTx.MsgTx().TxOut {
		if len(txout.PkScript) > 0 && txout.PkScript[0] == txscript.OP_RETURN {
			zerolog.Ctx(ctx).Info().
				Str("txid", txid).
				Int32("height", height).
				Str("data", hex.EncodeToString(txout.PkScript[1:])).
				Msgf("bitcoind_engine/parser: found op_return")

			// This is an OP_RETURN output
			data := txout.PkScript[1:]
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
			op_return_data
			height,
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
		INSERT INTO processed_blocks (height, block_hash) 
		VALUES (?, ?)
	`, height, hash)
	if err != nil {
		return fmt.Errorf("mark block processed: %w", err)
	}
	return nil
}
