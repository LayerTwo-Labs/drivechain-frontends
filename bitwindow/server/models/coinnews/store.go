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
	"math"
	"slices"
	"time"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

// HNScore is the spec §13 Hacker-News rank:
//
//	score = (upvotes − downvotes − 1) / (age_hours + 2)^1.8
//
// age_hours = max(0, (now − block_time)/3600). Making the formula part
// of the spec is what lets independent indexers agree on ordering.
func HNScore(upvotes, downvotes int64, blockTime time.Time) float64 {
	ageHours := time.Since(blockTime).Hours()
	if ageHours < 0 {
		ageHours = 0
	}
	return float64(upvotes-downvotes-1) / math.Pow(ageHours+2, 1.8)
}

// Comment is one node in a reply thread (spec §7), with its on-chain
// vote tally and §13 score.
type Comment struct {
	ItemID     string // hex 12-byte ItemID
	ParentID   string // hex 12-byte parent ItemID
	Author     string // hex 32-byte x-only pubkey
	Body       string
	URL        string
	Lang       string
	ReplyQuote string
	Upvotes    int64
	Downvotes  int64
	Score      float64
	CreatedAt  time.Time
}

// ListThread returns every Comment transitively rooted at `root` (a
// story or comment ItemID), ranked by descending §13 score. Callers
// build the reply tree from each Comment's ParentID.
func ListThread(ctx context.Context, db *sql.DB, root codec.ItemID) ([]Comment, error) {
	rows, err := db.QueryContext(ctx, `
		WITH RECURSIVE thread(item_id) AS (
			SELECT item_id FROM cn_comments WHERE parent_id = ?
			UNION
			SELECT c.item_id FROM cn_comments c JOIN thread t ON c.parent_id = t.item_id
		)
		SELECT
			lower(hex(cm.item_id)),
			lower(hex(cm.parent_id)),
			lower(hex(cm.author_xpk)),
			COALESCE(cm.body, ''),
			COALESCE(cm.url, ''),
			COALESCE(cm.lang, ''),
			COALESCE(cm.reply_quote, ''),
			i.block_time,
			COALESCE(v.upvotes, 0),
			COALESCE(v.downvotes, 0)
		FROM thread t
		JOIN cn_comments cm ON cm.item_id = t.item_id
		JOIN cn_items i ON i.item_id = cm.item_id
		LEFT JOIN (
			SELECT target_id,
				SUM(CASE WHEN kind = 4 THEN 1 ELSE 0 END) AS upvotes,
				SUM(CASE WHEN kind = 5 THEN 1 ELSE 0 END) AS downvotes
			FROM cn_votes GROUP BY target_id
		) v ON v.target_id = cm.item_id
	`, root[:])
	if err != nil {
		return nil, fmt.Errorf("coinnews: query thread: %w", err)
	}
	defer rows.Close()

	var out []Comment
	for rows.Next() {
		var c Comment
		if err := rows.Scan(
			&c.ItemID, &c.ParentID, &c.Author,
			&c.Body, &c.URL, &c.Lang, &c.ReplyQuote,
			&c.CreatedAt, &c.Upvotes, &c.Downvotes,
		); err != nil {
			return nil, fmt.Errorf("coinnews: scan comment: %w", err)
		}
		c.Score = HNScore(c.Upvotes, c.Downvotes, c.CreatedAt)
		out = append(out, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("coinnews: iterate thread: %w", err)
	}
	slices.SortFunc(out, func(a, b Comment) int {
		switch {
		case a.Score > b.Score:
			return -1
		case a.Score < b.Score:
			return 1
		default:
			return 0
		}
	})
	return out, nil
}

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

// Index dispatches one decoded CoinNews Message into the right
// table(s). Idempotent on `(txid, vout)` collisions: re-running over
// the same block leaves the DB unchanged (engine resync safety).
//
// Caller MUST have already verified Comment and Vote signatures, and
// the resolvability of any parent/target/head reference (spec §4.1),
// via the engine — Index trusts what it gets.
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
			(head_id, seq, chunk, block_height, tx_index, vout_index)
		VALUES (?, ?, ?, ?, ?, ?)
	`, c.Head[:], c.Seq, c.Chunk, pos.BlockHeight, pos.TxIndex, pos.VoutIndex)
	if err != nil {
		return fmt.Errorf("coinnews: insert cn_continuations: %w", err)
	}
	return nil
}

// ReassembleTLVs returns the full TLV list for a head Item, splicing in
// any Continuation chunks (spec §9). headRawTLV is the head's on-chain
// trailing TLV bytes; chunks are appended in seq order to form the
// complete TLV byte stream, which is re-parsed.
//
// The chunk set is accepted only if it conforms to §9: seq 0-indexed
// and contiguous, chunks in strictly increasing scan order (so they
// physically appear in seq order on chain), and the reassembled TLV
// section ≤ 8 KiB. A non-conforming or unparseable set is ignored and
// the head's own TLVs are returned unchanged. (Same-block placement and
// after-head ordering are enforced at index time before a chunk is
// stored, so they are not re-checked here.)
func ReassembleTLVs(ctx context.Context, db *sql.DB, headID codec.ItemID, headRawTLV []byte) ([]codec.TLV, error) {
	headTLVs, err := codec.DecodeTLVs(headRawTLV)
	if err != nil {
		return nil, fmt.Errorf("coinnews: decode head tlv: %w", err)
	}

	rows, err := db.QueryContext(ctx, `
		SELECT seq, chunk, tx_index, vout_index
		FROM cn_continuations WHERE head_id = ? ORDER BY seq
	`, headID[:])
	if err != nil {
		return nil, fmt.Errorf("coinnews: query continuations: %w", err)
	}
	defer rows.Close()

	full := append([]byte{}, headRawTLV...)
	var (
		wantSeq  int
		havePrev bool
		prevPos  ItemRef
	)
	for rows.Next() {
		var (
			seq   int
			chunk []byte
			pos   ItemRef
		)
		if err := rows.Scan(&seq, &chunk, &pos.TxIndex, &pos.VoutIndex); err != nil {
			return nil, fmt.Errorf("coinnews: scan continuation: %w", err)
		}
		if seq != wantSeq {
			return headTLVs, nil // gap or non-zero start ⇒ drop the chunk set
		}
		if havePrev && !prevPos.Before(pos) {
			return headTLVs, nil // not in physical seq order ⇒ drop
		}
		full = append(full, chunk...)
		if len(full) > codec.MaxReassembledLen {
			return headTLVs, nil // exceeds the 8 KiB reassembly cap ⇒ drop
		}
		wantSeq++
		havePrev = true
		prevPos = pos
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("coinnews: iterate continuations: %w", err)
	}
	if wantSeq == 0 {
		return headTLVs, nil // no continuations
	}

	tlvs, err := codec.DecodeTLVs(full)
	if err != nil {
		return headTLVs, nil // reassembled bytes aren't valid TLVs ⇒ drop
	}
	return tlvs, nil
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
