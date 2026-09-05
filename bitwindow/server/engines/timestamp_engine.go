package engines

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
)

const (
	// TimestampPrefix is prepended to SHA256 hash in OP_RETURN to identify timestamp transactions
	TimestampPrefix = "STAMP"

	// timestampFailureGrace is how long a confirming timestamp is given before
	// bitcoind not knowing its txid is treated as terminal. Core's default
	// mempool expiry is 336 hours, so a transaction it still has never heard
	// of after that window is never going to confirm.
	timestampFailureGrace = 14 * 24 * time.Hour
)

// txNotFoundPatterns are the shapes Core's -5 "unknown transaction" error
// arrives in. Unlike an RPC outage this answer is deterministic: bitcoind has
// neither a mempool entry nor an indexed transaction, so retrying the same
// txid cannot change it.
var txNotFoundPatterns = []string{
	"-5:",
	"-5 -",
	"No such mempool",
}

// isTxNotFoundError reports whether bitcoind answered "I don't know this txid"
// rather than failing for a transient reason (still starting up, connection
// refused, timeout).
func isTxNotFoundError(errMsg string) bool {
	if IsBitcoinCoreStartupError(errMsg) {
		return false
	}
	for _, p := range txNotFoundPatterns {
		if strings.Contains(errMsg, p) {
			return true
		}
	}
	return false
}

type TimestampEngine struct {
	db       *sql.DB
	log      zerolog.Logger
	wallet   WalletService
	bitcoind *service.Service[corerpc.BitcoinServiceClient]
	nodeMode *NodeMode
}

// SetNodeMode gates the confirmation watch on the node mode. Light mode runs no
// local Bitcoin Core, so it holds no confirmations to read.
func (e *TimestampEngine) SetNodeMode(nodeMode *NodeMode) {
	e.nodeMode = nodeMode
}

// WalletService interface for sending transactions
type WalletService interface {
	SendTransaction(ctx context.Context, opReturnData []byte) (string, error)
}

func NewTimestampEngine(
	db *sql.DB,
	log zerolog.Logger,
	wallet WalletService,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
) *TimestampEngine {
	return &TimestampEngine{
		db:       db,
		log:      log.With().Str("component", "timestamp_engine").Logger(),
		wallet:   wallet,
		bitcoind: bitcoind,
	}
}

func (e *TimestampEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	e.log.Info().Msg("timestamp engine started")

	for {
		select {
		case <-ctx.Done():
			e.log.Info().Msg("timestamp engine stopped")
			return ctx.Err()
		case <-ticker.C:
			if !e.nodeMode.RunsLocalNode(ctx) {
				continue
			}
			if err := e.checkConfirmations(ctx); err != nil {
				e.log.Warn().Err(err).Msg("check confirmations")
			}
		}
	}
}

func (e *TimestampEngine) checkConfirmations(ctx context.Context) error {
	confirmingTimestamps, err := timestamps.List(ctx, e.db, timestamps.WithStatus(timestamps.StatusConfirming))
	if err != nil {
		return fmt.Errorf("list confirming timestamps: %w", err)
	}

	if len(confirmingTimestamps) == 0 {
		return nil
	}

	bitcoind, err := e.bitcoind.Get(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	chainInfo, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return fmt.Errorf("get blockchain info: %w", err)
	}
	inIBD := chainInfo.Msg.InitialBlockDownload

	e.log.Debug().
		Int("count", len(confirmingTimestamps)).
		Msg("checking confirmations for timestamps")

	for _, ts := range confirmingTimestamps {
		if ts.TxID == nil {
			continue
		}

		resp, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
			Txid:      *ts.TxID,
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
		}))
		if err != nil {
			// A syncing node reports the same unknown-txid error for blocks it
			// has not downloaded yet, so the terminal transition waits for IBD.
			if isTxNotFoundError(err.Error()) && !inIBD && time.Since(ts.CreatedAt) > timestampFailureGrace {
				if err := timestamps.Update(
					ctx,
					e.db,
					ts.ID,
					ts.TxID,
					nil,
					timestamps.StatusFailed,
					nil,
				); err != nil {
					e.log.Warn().
						Err(err).
						Int64("id", ts.ID).
						Msg("update timestamp")
					continue
				}

				e.log.Info().
					Int64("id", ts.ID).
					Str("txid", *ts.TxID).
					Time("created_at", ts.CreatedAt).
					Msg("timestamp transaction unknown to bitcoind past grace period, marked failed")
				continue
			}

			e.log.Warn().
				Err(err).
				Str("txid", *ts.TxID).
				Msg("get raw transaction")
			continue
		}

		confirmations := resp.Msg.Confirmations

		if confirmations >= 1 {
			var blockHeight *int64
			var confirmedAt *time.Time

			// Get block height and time from blockhash if available
			if resp.Msg.Blockhash != "" {
				blockResp, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
					Hash:      resp.Msg.Blockhash,
					Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				}))
				if err != nil {
					e.log.Warn().
						Err(err).
						Str("blockhash", resp.Msg.Blockhash).
						Msg("get block")
				} else {
					height := int64(blockResp.Msg.Height)
					blockHeight = &height
					if blockResp.Msg.Time != nil {
						t := blockResp.Msg.Time.AsTime()
						confirmedAt = &t
					}
				}
			}

			if err := timestamps.Update(
				ctx,
				e.db,
				ts.ID,
				ts.TxID,
				blockHeight,
				timestamps.StatusConfirmed,
				confirmedAt,
			); err != nil {
				e.log.Warn().
					Err(err).
					Int64("id", ts.ID).
					Msg("update timestamp")
				continue
			}

			e.log.Info().
				Int64("id", ts.ID).
				Str("txid", *ts.TxID).
				Uint32("confirmations", confirmations).
				Msg("timestamp confirmed")
		}
	}

	return nil
}

func (e *TimestampEngine) TimestampFile(ctx context.Context, filename string, fileData []byte) (*timestamps.FileTimestamp, error) {
	hash := sha256.Sum256(fileData)
	fileHash := hex.EncodeToString(hash[:])

	e.log.Info().
		Str("filename", filename).
		Str("hash", fileHash).
		Int("size", len(fileData)).
		Msg("creating timestamp for file")

	// Check if already timestamped
	existing, err := timestamps.GetByHash(ctx, e.db, fileHash)
	if err != nil {
		return nil, fmt.Errorf("check existing timestamp: %w", err)
	}
	if existing != nil && existing.Status != timestamps.StatusFailed {
		e.log.Info().
			Str("filename", filename).
			Str("hash", fileHash).
			Int64("existing_id", existing.ID).
			Msg("file already timestamped")
		return existing, nil
	}

	// Create Bitcoin OP_RETURN transaction with prefixed file hash
	if e.wallet == nil {
		return nil, fmt.Errorf("wallet service not available")
	}

	// Prepend TMSTAMP prefix to hash for protocol identification
	opReturnData := append([]byte(TimestampPrefix), hash[:]...)

	txid, err := e.wallet.SendTransaction(ctx, opReturnData)
	if err != nil {
		return nil, fmt.Errorf("send timestamp transaction: %w", err)
	}

	e.log.Info().
		Str("txid", txid).
		Str("hash", fileHash).
		Msg("created timestamp transaction on blockchain")

	createdAt := time.Now()

	if existing != nil {
		if err := timestamps.Retry(ctx, e.db, existing.ID, txid, createdAt); err != nil {
			return nil, fmt.Errorf("retry timestamp record: %w", err)
		}

		existing.TxID = &txid
		existing.Status = timestamps.StatusConfirming
		existing.CreatedAt = createdAt
		existing.BlockHeight = nil
		existing.ConfirmedAt = nil

		e.log.Info().
			Int64("id", existing.ID).
			Str("filename", existing.Filename).
			Str("txid", txid).
			Msg("failed file timestamp retried")

		return existing, nil
	}

	// Store timestamp metadata in database
	timestamp := timestamps.FileTimestamp{
		Filename:  filename,
		FileHash:  fileHash,
		TxID:      &txid,
		Status:    timestamps.StatusConfirming,
		CreatedAt: createdAt,
	}

	id, err := timestamps.Create(ctx, e.db, timestamp)
	if err != nil {
		return nil, fmt.Errorf("create timestamp record: %w", err)
	}

	timestamp.ID = id

	e.log.Info().
		Int64("id", id).
		Str("filename", filename).
		Str("hash", fileHash).
		Str("txid", txid).
		Msg("file timestamp created")

	return &timestamp, nil
}

func (e *TimestampEngine) ListTimestamps(ctx context.Context) ([]timestamps.FileTimestamp, error) {
	return timestamps.List(ctx, e.db)
}

func (e *TimestampEngine) GetTimestamp(ctx context.Context, id int64) (*timestamps.FileTimestamp, error) {
	timestamp, err := timestamps.Get(ctx, e.db, id)
	if err != nil {
		return nil, fmt.Errorf("get timestamp: %w", err)
	}
	if timestamp == nil {
		return nil, fmt.Errorf("timestamp not found")
	}

	return timestamp, nil
}

func (e *TimestampEngine) VerifyTimestamp(ctx context.Context, fileData []byte, filename string) (*timestamps.FileTimestamp, error) {
	hash := sha256.Sum256(fileData)
	fileHash := hex.EncodeToString(hash[:])

	// Look up timestamp by hash
	timestamp, err := timestamps.GetByHash(ctx, e.db, fileHash)
	if err != nil {
		return nil, fmt.Errorf("lookup timestamp: %w", err)
	}
	if timestamp == nil {
		return nil, fmt.Errorf("no timestamp found for this file")
	}

	// If this is a discovered timestamp with no filename, update it
	if timestamp.Filename == "" && filename != "" {
		if err := timestamps.UpdateFilename(ctx, e.db, timestamp.ID, filename); err != nil {
			e.log.Warn().
				Err(err).
				Int64("id", timestamp.ID).
				Msg("update filename for discovered timestamp")
		} else {
			timestamp.Filename = filename
		}
	}

	e.log.Info().
		Str("hash", fileHash).
		Str("txid", *timestamp.TxID).
		Str("filename", timestamp.Filename).
		Msg("file timestamp verified")

	return timestamp, nil
}
