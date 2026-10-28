package store

import (
	"context"
	"database/sql"
	"fmt"
	"sort"
	"time"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

// FeedItem is the row returned by every list-feed query.
type FeedItem struct {
	ItemID       codec.ItemID
	Topic        codec.Topic
	Headline     string
	URL          string
	Body         string
	Lang         string
	NSFW         bool
	Subtype      codec.Subtype
	AuthorXPK    [32]byte // zero if Story (Stories are unsigned)
	BlockHeight  uint32
	BlockTime    time.Time
	CommentCount int
	FeeSats      int64
	TxID         string
	Vout         uint32
}

// FeedSort selects the ordering for ListFeed.
type FeedSort int

const (
	SortNewest FeedSort = iota
	SortFeeDesc
)

// FeedFilter scopes a feed query.
type FeedFilter struct {
	Topic       *codec.Topic
	Subtype     *codec.Subtype
	IncludeNSFW bool
	Sort        FeedSort
	Limit       uint32
	Offset      uint32
}

// ListFeed runs the canonical feed query (spec §13). Two indexers from
// the same chain tip return the same rows in the same order.
func ListFeed(ctx context.Context, db *sql.DB, f FeedFilter) ([]FeedItem, error) {
	const query = `
		SELECT s.item_id, s.topic, s.headline,
		       COALESCE(s.url, ''), COALESCE(s.body, ''), COALESCE(s.lang, ''),
		       s.nsfw, s.subtype,
		       i.block_height, i.block_time, i.txid, i.vout, i.fee_sats,
		       COALESCE((SELECT COUNT(*) FROM cn_comments WHERE parent_id = s.item_id), 0) AS comments
		FROM cn_stories s
		JOIN cn_items   i ON i.item_id = s.item_id
		WHERE 1 = 1
		  AND (? IS NULL OR s.topic = ?)
		  AND (? IS NULL OR s.subtype = ?)
		  AND (? OR s.nsfw = 0)
	`
	args := []any{
		nullableTopic(f.Topic), nullableTopic(f.Topic),
		nullableSubtype(f.Subtype), nullableSubtype(f.Subtype),
		f.IncludeNSFW,
	}
	var orderClause string
	switch f.Sort {
	case SortFeeDesc:
		orderClause = ` ORDER BY i.fee_sats DESC, i.block_height DESC, i.tx_index DESC, i.vout_index DESC `
	default:
		orderClause = ` ORDER BY i.block_height DESC, i.tx_index DESC, i.vout_index DESC `
	}
	limit := f.Limit
	if limit == 0 {
		limit = 30
	}
	args = append(args, limit, f.Offset)

	rows, err := db.QueryContext(ctx, query+orderClause+` LIMIT ? OFFSET ? `, args...)
	if err != nil {
		return nil, fmt.Errorf("ListFeed: %w", err)
	}
	return scanFeedRows(rows)
}

// GetItem returns one Story keyed by ItemID. Returns sql.ErrNoRows if
// the ItemID isn't a Story (could be a Comment or a TopicCreation).
func GetItem(ctx context.Context, db *sql.DB, id codec.ItemID) (FeedItem, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT s.item_id, s.topic, s.headline,
		       COALESCE(s.url, ''), COALESCE(s.body, ''), COALESCE(s.lang, ''),
		       s.nsfw, s.subtype,
		       i.block_height, i.block_time, i.txid, i.vout, i.fee_sats,
		       COALESCE((SELECT COUNT(*) FROM cn_comments WHERE parent_id = s.item_id), 0)
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		WHERE s.item_id = ?
	`, id[:])
	if err != nil {
		return FeedItem{}, err
	}
	items, err := scanFeedRows(rows)
	if err != nil {
		return FeedItem{}, err
	}
	if len(items) == 0 {
		return FeedItem{}, sql.ErrNoRows
	}
	return items[0], nil
}

// CommentRow is the materialised view of a comment.
type CommentRow struct {
	ItemID      codec.ItemID
	Parent      codec.ItemID
	AuthorXPK   [32]byte
	Body        string
	URL         string
	Lang        string
	ReplyQuote  string
	BlockHeight uint32
	BlockTime   time.Time
	FeeSats     int64
	TxID        string
	Vout        uint32
}

// ListThread returns every comment descendant of `root`, depth-first.
// Siblings come highest fee first, then in canonical scan order.
func ListThread(ctx context.Context, db *sql.DB, root codec.ItemID) ([]CommentRow, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT c.item_id, c.parent_id, c.author_xpk,
		       COALESCE(c.body, ''), COALESCE(c.url, ''), COALESCE(c.lang, ''), COALESCE(c.reply_quote, ''),
		       i.block_height, i.block_time, i.txid, i.vout, i.fee_sats
		FROM cn_comments c
		JOIN cn_items i ON i.item_id = c.item_id
		ORDER BY i.block_height ASC, i.tx_index ASC, i.vout_index ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close() //nolint:errcheck

	all := map[codec.ItemID][]CommentRow{}
	for rows.Next() {
		var (
			c              CommentRow
			itemID, parent []byte
			xpk            []byte
		)
		if err := rows.Scan(&itemID, &parent, &xpk, &c.Body, &c.URL, &c.Lang, &c.ReplyQuote,
			&c.BlockHeight, &c.BlockTime, &c.TxID, &c.Vout, &c.FeeSats); err != nil {
			return nil, err
		}
		copy(c.ItemID[:], itemID)
		copy(c.Parent[:], parent)
		copy(c.AuthorXPK[:], xpk)
		all[c.Parent] = append(all[c.Parent], c)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	var out []CommentRow
	var walk func(parent codec.ItemID)
	walk = func(parent codec.ItemID) {
		children := all[parent]
		sort.SliceStable(children, func(i, j int) bool {
			return children[i].FeeSats > children[j].FeeSats
		})
		for _, c := range children {
			out = append(out, c)
			walk(c.ItemID)
		}
	}
	walk(root)
	return out, nil
}

// ListByAuthor returns the Stories that xpk commented on directly.
// Stories are unsigned, so they have no author of their own.
func ListByAuthor(ctx context.Context, db *sql.DB, xpk [32]byte, limit, offset uint32) ([]FeedItem, error) {
	if limit == 0 {
		limit = 30
	}
	rows, err := db.QueryContext(ctx, `
		WITH author_items AS (
			SELECT DISTINCT s.item_id
			FROM cn_stories s
			JOIN cn_comments c ON c.parent_id = s.item_id AND c.author_xpk = ?
		)
		SELECT s.item_id, s.topic, s.headline,
		       COALESCE(s.url, ''), COALESCE(s.body, ''), COALESCE(s.lang, ''),
		       s.nsfw, s.subtype,
		       i.block_height, i.block_time, i.txid, i.vout, i.fee_sats,
		       COALESCE((SELECT COUNT(*) FROM cn_comments WHERE parent_id = s.item_id), 0)
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		WHERE s.item_id IN (SELECT item_id FROM author_items)
		ORDER BY i.block_height DESC, i.tx_index DESC, i.vout_index DESC
		LIMIT ? OFFSET ?
	`, xpk[:], limit, offset)
	if err != nil {
		return nil, err
	}
	return scanFeedRows(rows)
}

// Topic is the materialised topic row.
type TopicRow struct {
	Topic         codec.Topic
	Name          string
	RetentionDays uint32
	CreatedHeight uint32
	TxID          string
}

// ListTopics returns every known topic, ordered by creation height.
func ListTopics(ctx context.Context, db *sql.DB) ([]TopicRow, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT topic, name, retention_days, created_height, txid
		FROM cn_topics
		ORDER BY created_height ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close() //nolint:errcheck

	var out []TopicRow
	for rows.Next() {
		var t TopicRow
		var topic []byte
		if err := rows.Scan(&topic, &t.Name, &t.RetentionDays, &t.CreatedHeight, &t.TxID); err != nil {
			return nil, err
		}
		copy(t.Topic[:], topic)
		out = append(out, t)
	}
	return out, rows.Err()
}

func scanFeedRows(rows *sql.Rows) ([]FeedItem, error) {
	defer rows.Close() //nolint:errcheck
	var out []FeedItem
	for rows.Next() {
		var (
			fi            FeedItem
			itemID, topic []byte
			subtype       byte
		)
		if err := rows.Scan(&itemID, &topic, &fi.Headline, &fi.URL, &fi.Body, &fi.Lang,
			&fi.NSFW, &subtype, &fi.BlockHeight, &fi.BlockTime, &fi.TxID, &fi.Vout,
			&fi.FeeSats, &fi.CommentCount); err != nil {
			return nil, err
		}
		copy(fi.ItemID[:], itemID)
		copy(fi.Topic[:], topic)
		fi.Subtype = codec.Subtype(subtype)
		out = append(out, fi)
	}
	return out, rows.Err()
}

func nullableTopic(t *codec.Topic) any {
	if t == nil {
		return nil
	}
	return t[:]
}

func nullableSubtype(s *codec.Subtype) any {
	if s == nil {
		return nil
	}
	return byte(*s)
}
