package scanner

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/rs/zerolog"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

// Scanner walks blocks from a Bitcoin Core node and feeds CoinNews
// payloads through the codec into the store. Sequential by design —
// canonical scan order (spec §4.2) requires it.
type Scanner struct {
	Client *Client
	DB     *sql.DB
	Log    zerolog.Logger

	// PollInterval is how often we re-check the tip after catching up.
	PollInterval time.Duration
}

// Run blocks until ctx is cancelled. Catches up to the tip, then
// polls. Errors during a single block bubble — the caller decides
// whether to crash-loop or back off.
func (s *Scanner) Run(ctx context.Context) error {
	if s.PollInterval == 0 {
		s.PollInterval = 5 * time.Second
	}
	for {
		if err := s.catchUp(ctx); err != nil {
			if errors.Is(err, context.Canceled) {
				return nil
			}
			s.Log.Warn().Err(err).Msg("coinnews-scanner: catchUp failed; retrying after poll interval")
		}
		select {
		case <-ctx.Done():
			return nil
		case <-time.After(s.PollInterval):
		}
	}
}

func (s *Scanner) catchUp(ctx context.Context) error {
	tip, err := s.Client.GetBlockCount(ctx)
	if err != nil {
		return fmt.Errorf("getblockcount: %w", err)
	}

	cursor, _, err := store.LoadCursor(ctx, s.DB)
	if err != nil {
		return fmt.Errorf("load cursor: %w", err)
	}
	if cursor >= tip {
		return nil
	}

	s.Log.Info().Uint32("from", cursor+1).Uint32("to", tip).Msg("coinnews-scanner: catching up")

	for h := cursor + 1; h <= tip; h++ {
		if err := s.indexHeight(ctx, h); err != nil {
			return fmt.Errorf("index height %d: %w", h, err)
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}
	}
	return nil
}

func (s *Scanner) indexHeight(ctx context.Context, height uint32) error {
	hash, err := s.Client.GetBlockHash(ctx, height)
	if err != nil {
		return fmt.Errorf("getblockhash %d: %w", height, err)
	}
	block, err := s.Client.GetBlock(ctx, hash)
	if err != nil {
		return fmt.Errorf("getblock %s: %w", hash, err)
	}

	blockTime := time.Unix(block.Time, 0).UTC()

	for txIdx, tx := range block.Tx {
		for vout, out := range tx.Vout {
			data, ok := opReturnPayload(out.ScriptPubKey.Hex, out.ScriptPubKey.Type)
			if !ok {
				continue
			}
			pos := store.BlockPos{
				BlockHeight: height,
				TxIndex:     uint32(txIdx),
				VoutIndex:   uint32(vout),
				BlockTime:   blockTime,
				TxID:        tx.Txid,
			}
			if err := s.indexPayload(ctx, data, pos); err != nil {
				return err
			}
		}
	}

	hashBytes, err := decodeHashLE(hash)
	if err != nil {
		return err
	}
	return store.SaveCursor(ctx, s.DB, height, hashBytes)
}

// indexPayload classifies one OP_RETURN payload and persists it.
// Mirrors bitwindow's engine hook: signature verification gates
// persistence, malformed and non-CoinNews payloads are dropped
// silently.
func (s *Scanner) indexPayload(ctx context.Context, data []byte, pos store.BlockPos) error {
	tag, msg, err := codec.DecodeMessage(data)
	if err != nil {
		if errors.Is(err, codec.ErrNotCoinNews) || errors.Is(err, codec.ErrUnknownTypeTag) {
			return nil
		}
		s.Log.Debug().Err(err).Str("txid", pos.TxID).Uint32("vout", pos.VoutIndex).
			Msg("coinnews-scanner: malformed payload, dropping")
		return nil
	}
	switch m := msg.(type) {
	case *codec.Comment:
		if err := codec.VerifyComment(m); err != nil {
			s.Log.Debug().Err(err).Str("txid", pos.TxID).Msg("coinnews-scanner: comment sig invalid")
			return nil
		}
	case *codec.Vote:
		if err := codec.VerifyVote(m); err != nil {
			s.Log.Debug().Err(err).Str("txid", pos.TxID).Msg("coinnews-scanner: vote sig invalid")
			return nil
		}
	}
	return store.Index(ctx, s.DB, store.IndexEnv{Pos: pos, TypeTag: tag, Msg: msg})
}

// opReturnPayload extracts the data bytes pushed by a single-push
// OP_RETURN. Returns ok=false for any other script. Bitcoin Core's
// scriptPubKey.type is "nulldata" for OP_RETURN; we cross-check
// the leading opcode to be defensive.
func opReturnPayload(scriptHex, scriptType string) ([]byte, bool) {
	if scriptType != "nulldata" {
		return nil, false
	}
	raw, err := hex.DecodeString(scriptHex)
	if err != nil || len(raw) < 2 || raw[0] != 0x6a /* OP_RETURN */ {
		return nil, false
	}
	return parsePush(raw[1:])
}

// parsePush walks one push opcode after OP_RETURN and returns the
// pushed bytes. Supports the small pushes (1–75) and the explicit
// OP_PUSHDATA1/2 forms. Anything else (multi-push, OP_DRIVECHAIN,
// padded data) returns false.
func parsePush(b []byte) ([]byte, bool) {
	if len(b) == 0 {
		return nil, false
	}
	op := b[0]
	switch {
	case op >= 0x01 && op <= 0x4b:
		n := int(op)
		if len(b) < 1+n {
			return nil, false
		}
		return b[1 : 1+n], true
	case op == 0x4c: // OP_PUSHDATA1
		if len(b) < 2 {
			return nil, false
		}
		n := int(b[1])
		if len(b) < 2+n {
			return nil, false
		}
		return b[2 : 2+n], true
	case op == 0x4d: // OP_PUSHDATA2
		if len(b) < 3 {
			return nil, false
		}
		n := int(b[1]) | int(b[2])<<8
		if len(b) < 3+n {
			return nil, false
		}
		return b[3 : 3+n], true
	}
	return nil, false
}

func decodeHashLE(hexStr string) ([32]byte, error) {
	raw, err := hex.DecodeString(hexStr)
	if err != nil || len(raw) != 32 {
		return [32]byte{}, fmt.Errorf("invalid block hash hex %q", hexStr)
	}
	var out [32]byte
	copy(out[:], raw)
	return out, nil
}
