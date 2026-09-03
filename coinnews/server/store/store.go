// Package store is the SQLite persistence layer for the CoinNews
// indexer. Every write enforces the spec's first-wins / last-wins
// rules at the SQL level (PRIMARY KEY + INSERT OR IGNORE) so two
// indexers agree byte-for-byte on the resulting tuple.
package store

import (
	"context"
	"database/sql"
	_ "embed"
	"encoding/hex"
	"fmt"
	"math"
	"slices"
	"strings"
	"sync"
	"time"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/mattn/go-sqlite3"
)

//go:embed schema.sql
var schemaSQL string

const driverName = "sqlite3-coinnews"

var registerOnce sync.Once

// registerDriver registers a sqlite3 driver variant that exposes the
// `pow` function the front-page ranker needs. SQLite's default build
// omits math functions; registering a Go-side `pow` keeps the SQL
// portable and keeps us off CGO build tags.
func registerDriver() {
	registerOnce.Do(func() {
		sql.Register(driverName, &sqlite3.SQLiteDriver{
			ConnectHook: func(c *sqlite3.SQLiteConn) error {
				return c.RegisterFunc("pow", math.Pow, true)
			},
		})
	})
}

// Open opens (or creates) the SQLite database at `path`, applies
// the schema if missing, and returns a ready *sql.DB. Safe to call
// repeatedly — `CREATE TABLE IF NOT EXISTS` makes the schema apply
// idempotent.
func Open(ctx context.Context, path string) (*sql.DB, error) {
	registerDriver()
	db, err := sql.Open(driverName, path+"?_journal=WAL&_busy_timeout=5000&_foreign_keys=on")
	if err != nil {
		return nil, fmt.Errorf("open sqlite: %w", err)
	}
	if _, err := db.ExecContext(ctx, schemaSQL); err != nil {
		_ = db.Close()
		return nil, fmt.Errorf("apply schema: %w", err)
	}
	return db, nil
}

// BlockPos locates an Item in canonical scan order (spec §4.2). Always
// fully populated when an Item is being indexed.
type BlockPos struct {
	BlockHeight uint32
	TxIndex     uint32
	VoutIndex   uint32
	BlockTime   time.Time
	TxID        string // display-hex (Bitcoin Core RPC form)
}

// IndexEnv is everything the persistence layer needs about a single
// decoded Message: where it lives on chain plus the typed payload.
type IndexEnv struct {
	Pos     BlockPos
	TypeTag codec.TypeTag
	Msg     any    // *codec.TopicCreation | *codec.Story | *codec.Comment | *codec.Vote | *codec.Continuation
	Payload []byte // the raw OP_RETURN bytes Msg was decoded from
}

// ItemRef is an indexed Item's canonical scan position (spec §4.2):
// (block_height, tx_index, vout_index).
type ItemRef struct {
	BlockHeight uint32
	TxIndex     uint32
	VoutIndex   uint32
}

// Before reports whether a is strictly earlier than b in canonical scan
// order. This is the spec's only notion of "earlier" (spec §4.2).
func (a ItemRef) Before(b ItemRef) bool {
	if a.BlockHeight != b.BlockHeight {
		return a.BlockHeight < b.BlockHeight
	}
	if a.TxIndex != b.TxIndex {
		return a.TxIndex < b.TxIndex
	}
	return a.VoutIndex < b.VoutIndex
}

// ResolveItem looks up an ItemID in the index (items_by_id, spec §4.1)
// and returns its scan position plus whether it is present. References
// to absent ItemIDs are unresolvable and the referring Message MUST be
// dropped (spec §4.1, §7, §8).
func ResolveItem(ctx context.Context, db *sql.DB, id codec.ItemID) (ItemRef, bool, error) {
	var ref ItemRef
	err := db.QueryRowContext(ctx,
		`SELECT block_height, tx_index, vout_index FROM cn_items WHERE item_id = ?`,
		id[:],
	).Scan(&ref.BlockHeight, &ref.TxIndex, &ref.VoutIndex)
	switch err {
	case nil:
		return ref, true, nil
	case sql.ErrNoRows:
		return ItemRef{}, false, nil
	default:
		return ItemRef{}, false, fmt.Errorf("coinnews: resolve item: %w", err)
	}
}

// Index dispatches one decoded CoinNews Message into the right table(s).
// Caller MUST have already verified Comment and Vote signatures, and the
// resolvability of any parent/target/head reference (spec §4.1).
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

func registerItem(ctx context.Context, tx *sql.Tx, env IndexEnv) (codec.ItemID, error) {
	// INSERT OR IGNORE below would swallow the NOT NULL violation and leave
	// every dependent insert to fail on the foreign key instead.
	if len(env.Payload) == 0 {
		return codec.ItemID{}, fmt.Errorf("coinnews: empty payload for %s:%d", env.Pos.TxID, env.Pos.VoutIndex)
	}

	var txidBytes [32]byte
	raw, err := hex.DecodeString(strings.TrimSpace(env.Pos.TxID))
	if err != nil || len(raw) != 32 {
		return codec.ItemID{}, fmt.Errorf("coinnews: invalid txid %q: %w", env.Pos.TxID, err)
	}
	// Bitcoin Core gives us txids in display (reversed) hex; reverse to
	// natural byte order for the SHA-256 input the spec defines.
	slices.Reverse(raw)
	copy(txidBytes[:], raw)
	id := codec.ComputeItemID(txidBytes, env.Pos.VoutIndex)

	_, err = tx.ExecContext(ctx, `
		INSERT OR IGNORE INTO cn_items
			(item_id, txid, vout, block_height, tx_index, vout_index, type_tag, block_time, raw_payload)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, id[:], env.Pos.TxID, env.Pos.VoutIndex, env.Pos.BlockHeight, env.Pos.TxIndex, env.Pos.VoutIndex, byte(env.TypeTag), env.Pos.BlockTime, env.Payload)
	if err != nil {
		return codec.ItemID{}, fmt.Errorf("coinnews: insert cn_items: %w", err)
	}
	return id, nil
}

func indexTopic(ctx context.Context, tx *sql.Tx, pos BlockPos, t *codec.TopicCreation) error {
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

// PurgeAtOrAbove deletes every cn_* row originating from a block at
// or above `fromHeight`. Called on reorg detection before replay.
func PurgeAtOrAbove(ctx context.Context, db *sql.DB, fromHeight uint32) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck // committed on success

	for _, q := range []string{
		`DELETE FROM cn_stories       WHERE item_id IN (SELECT item_id FROM cn_items WHERE block_height >= ?)`,
		`DELETE FROM cn_comments      WHERE item_id IN (SELECT item_id FROM cn_items WHERE block_height >= ?)`,
		`DELETE FROM cn_votes         WHERE block_height >= ?`,
		`DELETE FROM cn_continuations WHERE block_height >= ?`,
		`DELETE FROM cn_topics        WHERE created_height >= ?`,
		`DELETE FROM cn_items         WHERE block_height >= ?`,
	} {
		if _, err := tx.ExecContext(ctx, q, fromHeight); err != nil {
			return err
		}
	}
	return tx.Commit()
}

// SaveCursor records the highest block we've ingested so a restart
// resumes from where it left off.
func SaveCursor(ctx context.Context, db *sql.DB, height uint32, hash [32]byte) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO cn_scanner_cursor (id, last_height, last_hash) VALUES (1, ?, ?)
		ON CONFLICT(id) DO UPDATE SET last_height = excluded.last_height, last_hash = excluded.last_hash
	`, height, hash[:])
	return err
}

// LoadCursor returns (height, hash) of the last block we ingested,
// or (0, zero) if the table is empty.
func LoadCursor(ctx context.Context, db *sql.DB) (uint32, [32]byte, error) {
	var height uint32
	var hash []byte
	err := db.QueryRowContext(ctx, `SELECT last_height, last_hash FROM cn_scanner_cursor WHERE id = 1`).
		Scan(&height, &hash)
	if err == sql.ErrNoRows {
		return 0, [32]byte{}, nil
	}
	if err != nil {
		return 0, [32]byte{}, err
	}
	var out [32]byte
	copy(out[:], hash)
	return height, out, nil
}

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

// HashTxIDLE hashes a Bitcoin Core display-hex txid into a 32-byte
// natural-order array — convenience for tests building outpoints.
func HashTxIDLE(displayHex string) ([32]byte, error) {
	raw, err := hex.DecodeString(displayHex)
	if err != nil || len(raw) != 32 {
		return [32]byte{}, fmt.Errorf("invalid txid hex")
	}
	slices.Reverse(raw)
	var out [32]byte
	copy(out[:], raw)
	return out, nil
}
