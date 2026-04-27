// Package coinnews persists CoinNews messages decoded by the
// `bitwindow/server/coinnews` codec. The two packages are deliberately
// split: the codec is pure bytes, the store is database/SQL only. The
// engine's parser glues them together (see `bitwindow/server/engines`).
package coinnews

import (
	"context"
	"database/sql"
	"encoding/hex"
	"fmt"
	"slices"
	"time"

	codec "github.com/LayerTwo-Labs/sidesail/bitwindow/server/coinnews"
)

// BlockPos locates an Item in canonical scan order (spec §4.2). Always
// fully populated when an Item is being indexed — making this a value
// type (not a pointer) prevents the partial-nil bug classes the
// previous shape was vulnerable to.
type BlockPos struct {
	BlockHeight uint32
	TxIndex     uint32
	VoutIndex   uint32
	BlockTime   time.Time
	TxID        string
}

// IndexEnv is everything the persistence layer needs about a single
// decoded Message: where it lives on chain (BlockPos) plus the typed
// payload returned by codec.DecodeMessage.
type IndexEnv struct {
	Pos     BlockPos
	TypeTag codec.TypeTag
	Msg     any // *codec.TopicCreation | *codec.Story | *codec.Comment | *codec.Vote | *codec.Continuation
}

// Index dispatches one decoded CoinNews Message into the right
// table(s). Idempotent on `(txid, vout)` collisions: re-running over
// the same block leaves the DB unchanged (engine resync safety).
//
// Caller MUST have already verified Comment and Vote signatures via
// codec.VerifyComment / codec.VerifyVote — Index trusts what it gets.
func Index(ctx context.Context, db *sql.DB, env IndexEnv) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("coinnews: begin tx: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck // committed on success path

	itemID, err := registerItem(ctx, tx, env)
	if err != nil {
		return err
	}

	switch m := env.Msg.(type) {
	case *codec.TopicCreation:
		if err := indexTopic(ctx, tx, env.Pos, m); err != nil {
			return err
		}
	case *codec.Story:
		if err := indexStory(ctx, tx, itemID, m); err != nil {
			return err
		}
	case *codec.Comment:
		if err := indexComment(ctx, tx, itemID, m); err != nil {
			return err
		}
	case *codec.Vote:
		if err := indexVote(ctx, tx, env.Pos, m); err != nil {
			return err
		}
	case *codec.Continuation:
		if err := indexContinuation(ctx, tx, env.Pos, m); err != nil {
			return err
		}
	default:
		return fmt.Errorf("coinnews: unhandled message type %T", env.Msg)
	}

	return tx.Commit()
}

// registerItem inserts the row in cn_items and returns the ItemID it
// was indexed by. Every confirmed CoinNews Message — including Topic
// Creations — gets a row here so the determinism budget (spec §4.2)
// can hash a stable items_by_id tuple.
func registerItem(ctx context.Context, tx *sql.Tx, env IndexEnv) (codec.ItemID, error) {
	var txidBytes [32]byte
	raw, err := hex.DecodeString(env.Pos.TxID)
	if err != nil || len(raw) != 32 {
		return codec.ItemID{}, fmt.Errorf("coinnews: invalid txid %q: %w", env.Pos.TxID, err)
	}
	// Bitcoin Core gives us txids in display (reversed) hex; reverse
	// to natural byte order for the SHA-256 input the spec defines.
	slices.Reverse(raw)
	copy(txidBytes[:], raw)
	id := codec.ComputeItemID(txidBytes, env.Pos.VoutIndex)

	_, err = tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_items
			(item_id, txid, vout, block_height, tx_index, vout_index, type_tag, block_time)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`, id[:], env.Pos.TxID, env.Pos.VoutIndex, env.Pos.BlockHeight, env.Pos.TxIndex, env.Pos.VoutIndex, byte(env.TypeTag), env.Pos.BlockTime)
	if err != nil {
		return codec.ItemID{}, fmt.Errorf("coinnews: insert cn_items: %w", err)
	}
	return id, nil
}

func indexTopic(ctx context.Context, tx *sql.Tx, pos BlockPos, t *codec.TopicCreation) error {
	// Earliest confirmed creation per topic wins. PRIMARY KEY conflict
	// ⇒ silently ignored — exactly the spec §5 semantics.
	_, err := tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_topics
			(topic, name, retention_days, created_height, txid)
		VALUES (?, ?, ?, ?, ?)
	`, t.Topic[:], t.Name, t.RetentionDays, pos.BlockHeight, pos.TxID)
	if err != nil {
		return fmt.Errorf("coinnews: insert cn_topics: %w", err)
	}
	return nil
}

func indexStory(ctx context.Context, tx *sql.Tx, id codec.ItemID, s *codec.Story) error {
	url, body, lang, nsfw, mediaHash, subtype := extractStoryTLV(s.TLVs)
	rawTLV, err := codec.SerialiseTLVs(s.TLVs)
	if err != nil {
		return fmt.Errorf("coinnews: serialise story tlvs: %w", err)
	}
	_, err = tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_stories
			(item_id, topic, headline, subtype, url, body, lang, nsfw, media_hash, raw_tlv)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, id[:], s.Topic[:], s.Headline, byte(subtype),
		nullableString(url), nullableString(body), nullableString(lang),
		nsfw, nullableBytes(mediaHash), rawTLV)
	if err != nil {
		return fmt.Errorf("coinnews: insert cn_stories: %w", err)
	}
	return nil
}

func indexComment(ctx context.Context, tx *sql.Tx, id codec.ItemID, c *codec.Comment) error {
	url, body, lang, replyQuote := extractCommentTLV(c.TLVs)
	rawTLV, err := codec.SerialiseTLVs(c.TLVs)
	if err != nil {
		return fmt.Errorf("coinnews: serialise comment tlvs: %w", err)
	}
	_, err = tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_comments
			(item_id, parent_id, author_xpk, body, url, lang, reply_quote, raw_tlv)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`, id[:], c.Parent[:], c.AuthorXPK[:],
		nullableString(body), nullableString(url), nullableString(lang),
		nullableString(replyQuote), rawTLV)
	if err != nil {
		return fmt.Errorf("coinnews: insert cn_comments: %w", err)
	}
	return nil
}

func indexVote(ctx context.Context, tx *sql.Tx, pos BlockPos, v *codec.Vote) error {
	// First-vote-wins: PRIMARY KEY (target_id, author_xpk) makes
	// the conflict path an ignored insert.
	_, err := tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_votes
			(target_id, author_xpk, kind, block_height, tx_index, vout_index, block_time)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`, v.Target[:], v.AuthorXPK[:], byte(v.Kind),
		pos.BlockHeight, pos.TxIndex, pos.VoutIndex, pos.BlockTime)
	if err != nil {
		return fmt.Errorf("coinnews: insert cn_votes: %w", err)
	}
	return nil
}

func indexContinuation(ctx context.Context, tx *sql.Tx, pos BlockPos, c *codec.Continuation) error {
	_, err := tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_continuations
			(head_id, seq, chunk, block_height)
		VALUES (?, ?, ?, ?)
	`, c.Head[:], c.Seq, c.Chunk, pos.BlockHeight)
	if err != nil {
		return fmt.Errorf("coinnews: insert cn_continuations: %w", err)
	}
	return nil
}

// extractStoryTLV pulls the columns we hoist out of the Story TLV blob
// for fast feed queries. Anything we don't hoist remains in raw_tlv so
// schema upgrades can re-derive without re-scanning the chain.
func extractStoryTLV(tlvs []codec.TLV) (url, body, lang string, nsfw bool, mediaHash []byte, subtype codec.Subtype) {
	if t := codec.FindFirst(tlvs, codec.TLVURL); t != nil {
		url = string(t.Value)
	}
	if t := codec.FindFirst(tlvs, codec.TLVBody); t != nil {
		body = string(t.Value)
	}
	if t := codec.FindFirst(tlvs, codec.TLVLang); t != nil {
		lang = string(t.Value)
	}
	if t := codec.FindFirst(tlvs, codec.TLVNSFW); t != nil {
		nsfw = len(t.Value) > 0 && t.Value[0] != 0
	}
	if t := codec.FindFirst(tlvs, codec.TLVMediaHash); t != nil && len(t.Value) == 32 {
		mediaHash = append([]byte{}, t.Value...)
	}
	if t := codec.FindFirst(tlvs, codec.TLVSubtype); t != nil && len(t.Value) > 0 {
		subtype = codec.Subtype(t.Value[0])
	}
	return
}

func extractCommentTLV(tlvs []codec.TLV) (url, body, lang, replyQuote string) {
	if t := codec.FindFirst(tlvs, codec.TLVURL); t != nil {
		url = string(t.Value)
	}
	if t := codec.FindFirst(tlvs, codec.TLVBody); t != nil {
		body = string(t.Value)
	}
	if t := codec.FindFirst(tlvs, codec.TLVLang); t != nil {
		lang = string(t.Value)
	}
	if t := codec.FindFirst(tlvs, codec.TLVReplyQuote); t != nil {
		replyQuote = string(t.Value)
	}
	return
}

func nullableString(s string) any {
	if s == "" {
		return nil
	}
	return s
}

func nullableBytes(b []byte) any {
	if len(b) == 0 {
		return nil
	}
	return b
}
