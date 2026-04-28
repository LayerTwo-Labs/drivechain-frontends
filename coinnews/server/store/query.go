package store

import (
	"context"
	"database/sql"
	"fmt"
	"math"
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
	Points       int
	CommentCount int
	Score        float64
}

// FeedSort selects the ordering for ListFeed.
type FeedSort int

const (
	SortNewest FeedSort = iota
	SortScoreDesc
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

// ListFeed runs the canonical feed query. Score formula = HN rank
// (spec §13). Two indexers from the same chain tip return the same
// rows in the same order.
func ListFeed(ctx context.Context, db *sql.DB, f FeedFilter) ([]FeedItem, error) {
	const query = `
		WITH tally AS (
			SELECT target_id,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS up,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS dn
			FROM cn_votes GROUP BY target_id
		)
		SELECT s.item_id, s.topic, s.headline,
		       COALESCE(s.url, ''), COALESCE(s.body, ''), COALESCE(s.lang, ''),
		       s.nsfw, s.subtype,
		       i.block_height, i.block_time,
		       COALESCE(t.up, 0) AS up,
		       COALESCE(t.dn, 0) AS dn,
		       COALESCE((SELECT COUNT(*) FROM cn_comments WHERE parent_id = s.item_id), 0) AS comments
		FROM cn_stories s
		JOIN cn_items   i ON i.item_id = s.item_id
		LEFT JOIN tally t ON t.target_id = s.item_id
		WHERE 1 = 1
		  AND (? IS NULL OR s.topic = ?)
		  AND (? IS NULL OR s.subtype = ?)
		  AND (? OR s.nsfw = 0)
	`
	args := []any{
		byte(codec.TypeUpvote), byte(codec.TypeDownvote),
		nullableTopic(f.Topic), nullableTopic(f.Topic),
		nullableSubtype(f.Subtype), nullableSubtype(f.Subtype),
		f.IncludeNSFW,
	}
	var orderClause string
	switch f.Sort {
	case SortScoreDesc:
		orderClause = `
			ORDER BY (CAST(COALESCE(t.up, 0) - COALESCE(t.dn, 0) - 1 AS REAL))
			       / POW((CAST(strftime('%s','now') AS REAL) - CAST(strftime('%s', i.block_time) AS REAL))/3600.0 + 2.0, 1.8)
			DESC, i.block_height DESC
		`
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
	defer rows.Close() //nolint:errcheck

	var out []FeedItem
	for rows.Next() {
		var (
			fi              FeedItem
			itemID          []byte
			topic           []byte
			subtype         byte
			up, dn, ccount  int
		)
		if err := rows.Scan(&itemID, &topic, &fi.Headline, &fi.URL, &fi.Body, &fi.Lang,
			&fi.NSFW, &subtype, &fi.BlockHeight, &fi.BlockTime, &up, &dn, &ccount); err != nil {
			return nil, err
		}
		copy(fi.ItemID[:], itemID)
		copy(fi.Topic[:], topic)
		fi.Subtype = codec.Subtype(subtype)
		fi.Points = up - dn
		fi.CommentCount = ccount
		ageHours := time.Since(fi.BlockTime).Hours()
		if ageHours < 0 {
			ageHours = 0
		}
		fi.Score = float64(fi.Points-1) / math.Pow(ageHours+2, 1.8)
		out = append(out, fi)
	}
	return out, rows.Err()
}

// GetItem returns one Story keyed by ItemID. Returns sql.ErrNoRows if
// the ItemID isn't a Story (could be a Comment or a TopicCreation).
func GetItem(ctx context.Context, db *sql.DB, id codec.ItemID) (FeedItem, error) {
	rows, err := db.QueryContext(ctx, `
		WITH tally AS (
			SELECT target_id,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS up,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS dn
			FROM cn_votes WHERE target_id = ?
			GROUP BY target_id
		)
		SELECT s.item_id, s.topic, s.headline,
		       COALESCE(s.url, ''), COALESCE(s.body, ''), COALESCE(s.lang, ''),
		       s.nsfw, s.subtype,
		       i.block_height, i.block_time,
		       COALESCE(t.up, 0), COALESCE(t.dn, 0),
		       COALESCE((SELECT COUNT(*) FROM cn_comments WHERE parent_id = s.item_id), 0)
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		LEFT JOIN tally t ON t.target_id = s.item_id
		WHERE s.item_id = ?
	`, byte(codec.TypeUpvote), byte(codec.TypeDownvote), id[:], id[:])
	if err != nil {
		return FeedItem{}, err
	}
	defer rows.Close() //nolint:errcheck

	if !rows.Next() {
		return FeedItem{}, sql.ErrNoRows
	}
	var (
		fi              FeedItem
		itemID, topic   []byte
		subtype         byte
		up, dn, ccount  int
	)
	if err := rows.Scan(&itemID, &topic, &fi.Headline, &fi.URL, &fi.Body, &fi.Lang,
		&fi.NSFW, &subtype, &fi.BlockHeight, &fi.BlockTime, &up, &dn, &ccount); err != nil {
		return FeedItem{}, err
	}
	copy(fi.ItemID[:], itemID)
	copy(fi.Topic[:], topic)
	fi.Subtype = codec.Subtype(subtype)
	fi.Points = up - dn
	fi.CommentCount = ccount
	ageHours := time.Since(fi.BlockTime).Hours()
	if ageHours < 0 {
		ageHours = 0
	}
	fi.Score = float64(fi.Points-1) / math.Pow(ageHours+2, 1.8)
	return fi, nil
}

// CommentRow is the materialised view of a comment plus its tally.
type CommentRow struct {
	ItemID       codec.ItemID
	Parent       codec.ItemID
	AuthorXPK    [32]byte
	Body         string
	URL          string
	Lang         string
	ReplyQuote   string
	BlockHeight  uint32
	BlockTime    time.Time
	Points       int
	Score        float64
}

// ListThread returns every comment descendant of `root`, walking
// parent_id pointers. Caller renders the tree.
func ListThread(ctx context.Context, db *sql.DB, root codec.ItemID) ([]CommentRow, error) {
	rows, err := db.QueryContext(ctx, `
		WITH tally AS (
			SELECT target_id,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS up,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS dn
			FROM cn_votes GROUP BY target_id
		)
		SELECT c.item_id, c.parent_id, c.author_xpk,
		       COALESCE(c.body, ''), COALESCE(c.url, ''), COALESCE(c.lang, ''), COALESCE(c.reply_quote, ''),
		       i.block_height, i.block_time,
		       COALESCE(t.up, 0), COALESCE(t.dn, 0)
		FROM cn_comments c
		JOIN cn_items i ON i.item_id = c.item_id
		LEFT JOIN tally t ON t.target_id = c.item_id
	`, byte(codec.TypeUpvote), byte(codec.TypeDownvote))
	if err != nil {
		return nil, err
	}
	defer rows.Close() //nolint:errcheck

	all := map[codec.ItemID][]CommentRow{}
	for rows.Next() {
		var (
			c                 CommentRow
			itemID, parent    []byte
			xpk               []byte
			up, dn            int
		)
		if err := rows.Scan(&itemID, &parent, &xpk, &c.Body, &c.URL, &c.Lang, &c.ReplyQuote,
			&c.BlockHeight, &c.BlockTime, &up, &dn); err != nil {
			return nil, err
		}
		copy(c.ItemID[:], itemID)
		copy(c.Parent[:], parent)
		copy(c.AuthorXPK[:], xpk)
		c.Points = up - dn
		ageHours := time.Since(c.BlockTime).Hours()
		if ageHours < 0 {
			ageHours = 0
		}
		c.Score = float64(c.Points-1) / math.Pow(ageHours+2, 1.8)
		all[c.Parent] = append(all[c.Parent], c)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	var out []CommentRow
	var walk func(parent codec.ItemID)
	walk = func(parent codec.ItemID) {
		for _, c := range all[parent] {
			out = append(out, c)
			walk(c.ItemID)
		}
	}
	walk(root)
	return out, nil
}

// ListByAuthor returns Stories authored by xpk (matched against the
// Comment paths — Stories proper are unsigned). Surfaces an author's
// public-comment activity. Limited; clients paginate.
func ListByAuthor(ctx context.Context, db *sql.DB, xpk [32]byte, limit, offset uint32) ([]FeedItem, error) {
	if limit == 0 {
		limit = 30
	}
	rows, err := db.QueryContext(ctx, `
		WITH author_items AS (
			SELECT DISTINCT s.item_id
			FROM cn_stories s
			JOIN cn_comments c ON c.parent_id = s.item_id AND c.author_xpk = ?
		), tally AS (
			SELECT target_id,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS up,
			       SUM(CASE WHEN kind = ? THEN 1 ELSE 0 END) AS dn
			FROM cn_votes GROUP BY target_id
		)
		SELECT s.item_id, s.topic, s.headline,
		       COALESCE(s.url, ''), COALESCE(s.body, ''), COALESCE(s.lang, ''),
		       s.nsfw, s.subtype,
		       i.block_height, i.block_time,
		       COALESCE(t.up, 0), COALESCE(t.dn, 0),
		       COALESCE((SELECT COUNT(*) FROM cn_comments WHERE parent_id = s.item_id), 0)
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		LEFT JOIN tally t ON t.target_id = s.item_id
		WHERE s.item_id IN (SELECT item_id FROM author_items)
		ORDER BY i.block_height DESC, i.tx_index DESC, i.vout_index DESC
		LIMIT ? OFFSET ?
	`, xpk[:], byte(codec.TypeUpvote), byte(codec.TypeDownvote), limit, offset)
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
			fi              FeedItem
			itemID, topic   []byte
			subtype         byte
			up, dn, ccount  int
		)
		if err := rows.Scan(&itemID, &topic, &fi.Headline, &fi.URL, &fi.Body, &fi.Lang,
			&fi.NSFW, &subtype, &fi.BlockHeight, &fi.BlockTime, &up, &dn, &ccount); err != nil {
			return nil, err
		}
		copy(fi.ItemID[:], itemID)
		copy(fi.Topic[:], topic)
		fi.Subtype = codec.Subtype(subtype)
		fi.Points = up - dn
		fi.CommentCount = ccount
		ageHours := time.Since(fi.BlockTime).Hours()
		if ageHours < 0 {
			ageHours = 0
		}
		fi.Score = float64(fi.Points-1) / math.Pow(ageHours+2, 1.8)
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
