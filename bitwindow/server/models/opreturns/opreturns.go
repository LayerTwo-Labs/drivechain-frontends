package opreturns

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"slices"
	"strings"
	"sync"
	"time"
	"unicode"

	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	sq "github.com/Masterminds/squirrel"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
)

// Backstop TTL for cached List / ListCoinNews — the contract is that
// Persist invalidates; TTL only matters if a query races a write.
const listCacheTTL = 2 * time.Second

// Caches are keyed by *sql.DB so parallel tests with their own DBs
// don't share entries. Production has one *sql.DB per network so this
// is effectively a singleton.

type listCacheEntry struct {
	rows []OPReturn
	at   time.Time
}

type coinNewsCacheEntry struct {
	rows []CoinNews
	at   time.Time
}

var (
	listCacheMu      sync.RWMutex
	listCacheEntries = map[*sql.DB]map[int]listCacheEntry{}

	coinNewsCacheMu      sync.RWMutex
	coinNewsCacheEntries = map[*sql.DB]coinNewsCacheEntry{}
)

// invalidateCaches drops cached List / ListCoinNews entries for db.
// Called from Persist.
func invalidateCaches(db *sql.DB) {
	listCacheMu.Lock()
	delete(listCacheEntries, db)
	listCacheMu.Unlock()

	InvalidateCoinNewsCache(db)
}

func InvalidateCoinNewsCache(db *sql.DB) {
	coinNewsCacheMu.Lock()
	delete(coinNewsCacheEntries, db)
	coinNewsCacheMu.Unlock()
}

func Persist(
	ctx context.Context, db *sql.DB, values []OPReturn,
) error {
	if len(values) == 0 {
		return nil
	}

	start := time.Now()
	builder := sq.
		Insert("op_returns").
		Columns("txid", "vout", "op_return_data", "fee_sats", "height", "created_at")

	for _, value := range values {
		createdAt := time.Now()
		if value.CreatedAt != nil {
			createdAt = *value.CreatedAt
		}
		builder = builder.Values(
			value.TxID, value.Vout,
			// Much easier to work with hex strings in the database! We're
			// storing this in a string column, should've been BLOB?
			hex.EncodeToString(value.Data),
			value.Fee, value.Height, createdAt,
		)
	}

	builder = builder.Suffix(
		`ON CONFLICT (txid, vout) DO UPDATE SET 
			op_return_data = excluded.op_return_data, 
			height = COALESCE(excluded.height, op_returns.height), 
			fee_sats = excluded.fee_sats,
			created_at = CASE
				WHEN excluded.height IS NOT NULL THEN excluded.created_at
				ELSE op_returns.created_at
			END`,
	)

	sql, args := builder.MustSql()
	if _, err := db.ExecContext(ctx, sql, args...); err != nil {
		return fmt.Errorf("persist %d OP_RETURN(s): %w", len(values), err)
	}

	invalidateCaches(db)

	zerolog.Ctx(ctx).Debug().
		Msgf("opreturns: persisted %d OP_RETURN(s) in %s", len(values), time.Since(start))

	return nil
}

type OPReturn struct {
	ID        int64
	TxID      string
	Vout      int32
	Data      []byte
	Fee       btcutil.Amount // 0 can either mean zero fee or unknown fee
	Height    *uint32
	CreatedAt *time.Time
}

// List returns the most-recent OP_RETURNs, ordered by created_at desc,
// capped at `limit`. Pass 0 (or any value <= 0) to skip the cap — only
// do that when the caller genuinely needs the full table; this table
// grows linearly with chain height. The returned slice is freshly
// allocated; element values are shared, so OPReturn fields must be
// treated read-only.
func List(ctx context.Context, db *sql.DB, limit int) ([]OPReturn, error) {
	listCacheMu.RLock()
	cached, hit := listCacheEntries[db][limit]
	listCacheMu.RUnlock()
	if hit && time.Since(cached.at) < listCacheTTL {
		out := make([]OPReturn, len(cached.rows))
		copy(out, cached.rows)
		return out, nil
	}

	query := `
		SELECT id, txid, vout, unhex(op_return_data), fee_sats, height, created_at
		FROM op_returns
		ORDER BY created_at DESC
	`
	args := []any{}
	if limit > 0 {
		query += "\nLIMIT ?"
		args = append(args, limit)
	}

	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list: query op_returns: %w", err)
	}
	defer rows.Close()

	var opReturns []OPReturn
	for rows.Next() {
		var opReturn OPReturn
		err := rows.Scan(
			&opReturn.ID, &opReturn.TxID, &opReturn.Vout,
			&opReturn.Data, &opReturn.Fee, &opReturn.Height, &opReturn.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("list: scan op_return: %w", err)
		}
		opReturns = append(opReturns, opReturn)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list: iterate op_returns: %w", err)
	}

	snapshot := make([]OPReturn, len(opReturns))
	copy(snapshot, opReturns)
	listCacheMu.Lock()
	byLimit, ok := listCacheEntries[db]
	if !ok {
		byLimit = map[int]listCacheEntry{}
		listCacheEntries[db] = byLimit
	}
	byLimit[limit] = listCacheEntry{rows: snapshot, at: time.Now()}
	listCacheMu.Unlock()

	return opReturns, nil
}

func OPReturnToReadable(data []byte) string {
	// First try to decode as hex
	decoded, err := hex.DecodeString(string(data))
	if err == nil {
		// Check if decoded data is human readable
		isHumanReadable := true
		for _, r := range string(decoded) {
			if !unicode.IsPrint(r) || r > 127 {
				isHumanReadable = false
				break
			}
		}
		if isHumanReadable {
			return string(decoded)
		}
	}

	// If not hex or not human readable when decoded, try direct string
	str := string(data)
	isHumanReadable := true
	for _, r := range str {
		if !unicode.IsPrint(r) || r > 127 {
			isHumanReadable = false
			break
		}
	}
	if isHumanReadable {
		return str
	}

	// If all else fails, return as hex
	return hex.EncodeToString(data)
}

func ValidNewsTopicID(topic string) (TopicID, error) {
	if topic == "" {
		return TopicID{}, errors.New("topic ID is empty")
	}

	decode, err := hex.DecodeString(topic)
	if err != nil {
		return TopicID{}, fmt.Errorf("topic ID %q is not hex: %w", topic, err)
	}

	if len(decode) != TopicIdLength {
		return TopicID{}, fmt.Errorf("topic ID %q is not 4 bytes: %d", topic, len(decode))
	}

	return TopicID(decode), nil
}

const TopicIdLength = 4

type Topic struct {
	ID            int64
	Topic         TopicID
	Name          string
	Confirmed     bool
	Txid          string
	RetentionDays int32

	CreatedAt time.Time
}

type CoinNews struct {
	ID        int64
	Topic     TopicID
	TopicName string
	Headline  string
	Content   string
	Fee       btcutil.Amount
	ItemID    string // hex-encoded 12-byte ItemID; vote target
	Upvotes   int64
	Downvotes int64
	Score     float64 // Hacker-News rank (spec §13)
	URL       string  // optional link (TLV §10)
	Subtype   int32   // 0=link,1=text,2=ask,3=show,4=poll,5=job
	NSFW      bool

	CreatedAt *time.Time
}

func ListTopics(ctx context.Context, db *sql.DB) ([]Topic, error) {
	rows, err := db.QueryContext(ctx, `
	SELECT 0, lower(hex(topic)), name, 1, COALESCE(txid, ''), retention_days,
		(SELECT i.block_time FROM cn_items i WHERE i.txid = cn_topics.txid ORDER BY i.block_time ASC LIMIT 1) AS created_at
	FROM cn_topics
	ORDER BY created_at ASC
`)
	if err != nil {
		return nil, fmt.Errorf("list topics: query: %w", err)
	}
	defer rows.Close()

	var topics []Topic
	for rows.Next() {
		var topic Topic
		var rawTopicID string
		var createdAt sql.NullTime
		err := rows.Scan(&topic.ID, &rawTopicID, &topic.Name, &topic.Confirmed, &topic.Txid, &topic.RetentionDays, &createdAt)
		if err != nil {
			return nil, fmt.Errorf("list topics: scan: %w", err)
		}
		if createdAt.Valid {
			topic.CreatedAt = createdAt.Time
		} else {
			topic.CreatedAt = time.Now()
		}

		topicID, err := ValidNewsTopicID(rawTopicID)
		if err != nil {
			return nil, fmt.Errorf("list topics: invalid topic ID: %w", err)
		}
		topic.Topic = topicID

		topics = append(topics, topic)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list topics: iterate: %w", err)
	}

	return topics, nil
}

func TopicExists(ctx context.Context, db *sql.DB, topic TopicID) (bool, error) {
	var exists bool
	err := db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM cn_topics WHERE lower(hex(topic)) = ?)
	`, topic.String()).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("topic exists: %w", err)
	}
	return exists, nil
}

// EncodeNewsMessageNewFormat produces the current CoinNews Story wire
// format used by BroadcastNews and decoded by the cn_* block parser.
func EncodeNewsMessageNewFormat(topic TopicID, headline string, content string) ([]byte, error) {
	return EncodeNewsMessageWithOptions(topic, headline, content, StoryOptions{})
}

// StoryOptions carries the optional Story TLVs (spec §6, §10): a link
// URL, language, content subtype, and the NSFW flag.
type StoryOptions struct {
	URL     string
	Lang    string
	Subtype int32
	NSFW    bool
}

// EncodeNewsMessageWithOptions builds a Story payload with the body and
// any provided optional TLVs, in the canonical order body, url, lang,
// subtype, nsfw.
func EncodeNewsMessageWithOptions(topic TopicID, headline, content string, opts StoryOptions) ([]byte, error) {
	var t codec.Topic
	copy(t[:], topic[:])
	story := codec.Story{Topic: t, Headline: headline}
	if content != "" {
		story.TLVs = append(story.TLVs, codec.TLV{Tag: codec.TLVBody, Value: []byte(content)})
	}
	if opts.URL != "" {
		story.TLVs = append(story.TLVs, codec.TLV{Tag: codec.TLVURL, Value: []byte(opts.URL)})
	}
	if opts.Lang != "" {
		story.TLVs = append(story.TLVs, codec.TLV{Tag: codec.TLVLang, Value: []byte(opts.Lang)})
	}
	if opts.Subtype != 0 {
		story.TLVs = append(story.TLVs, codec.TLV{Tag: codec.TLVSubtype, Value: []byte{byte(opts.Subtype)}})
	}
	if opts.NSFW {
		story.TLVs = append(story.TLVs, codec.TLV{Tag: codec.TLVNSFW, Value: []byte{0x01}})
	}
	return codec.EncodeStory(story)
}

// EncodeTopicCreationMessageNewFormat produces the current CoinNews
// TopicCreation wire format. Retention days are clamped to the
// single-byte field.
func EncodeTopicCreationMessageNewFormat(topic TopicID, name string, retentionDays int32) ([]byte, error) {
	if retentionDays < 0 {
		retentionDays = 0
	}
	if retentionDays > 255 {
		retentionDays = 255
	}
	var t codec.Topic
	copy(t[:], topic[:])
	return codec.EncodeTopicCreation(codec.TopicCreation{
		Topic:         t,
		RetentionDays: byte(retentionDays),
		Name:          name,
	})
}

type TopicID [TopicIdLength]byte

func (t TopicID) String() string {
	return hex.EncodeToString(t[:])
}

// ListCoinNews returns articles from the canonical CoinNews tables.
func ListCoinNews(ctx context.Context, db *sql.DB) ([]CoinNews, error) {
	coinNewsCacheMu.RLock()
	cached, hit := coinNewsCacheEntries[db]
	coinNewsCacheMu.RUnlock()
	if hit && time.Since(cached.at) < listCacheTTL {
		out := make([]CoinNews, len(cached.rows))
		copy(out, cached.rows)
		return out, nil
	}

	coinNews, err := listCoinNewsNewFormat(ctx, db)
	if err != nil {
		return nil, err
	}
	rankCoinNews(coinNews)

	snapshot := make([]CoinNews, len(coinNews))
	copy(snapshot, coinNews)
	coinNewsCacheMu.Lock()
	coinNewsCacheEntries[db] = coinNewsCacheEntry{rows: snapshot, at: time.Now()}
	coinNewsCacheMu.Unlock()

	return coinNews, nil
}

func listCoinNewsNewFormat(ctx context.Context, db *sql.DB) ([]CoinNews, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT
			i.rowid,
			s.topic,
			COALESCE(ct.name, ''),
			s.headline,
			COALESCE(s.body, ''),
			COALESCE(o.fee_sats, 0),
			i.block_time,
			lower(hex(s.item_id)),
			COALESCE(v.upvotes, 0),
			COALESCE(v.downvotes, 0),
			COALESCE(s.raw_tlv, x''),
			COALESCE(s.url, ''),
			s.subtype,
			s.nsfw
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		LEFT JOIN cn_topics ct ON ct.topic = s.topic
		LEFT JOIN op_returns o ON o.txid = i.txid AND o.vout = i.vout
		LEFT JOIN (
			SELECT target_id,
				SUM(CASE WHEN kind = 4 THEN 1 ELSE 0 END) AS upvotes,
				SUM(CASE WHEN kind = 5 THEN 1 ELSE 0 END) AS downvotes
			FROM cn_votes GROUP BY target_id
		) v ON v.target_id = s.item_id
		WHERE
			trim(s.headline) != ''
			AND
			CASE
				WHEN ct.topic IS NOT NULL THEN
					ct.retention_days = 0
					OR i.block_time >= datetime('now', '-' || ct.retention_days || ' days')
				ELSE 1
			END
	`)
	if err != nil {
		return nil, fmt.Errorf("list coin news: query new-format stories: %w", err)
	}
	defer rows.Close()

	type continuationTarget struct {
		idx    int
		itemID string
		rawTLV []byte
	}
	var out []CoinNews
	var toReassemble []continuationTarget
	for rows.Next() {
		var (
			id        int64
			rawTopic  []byte
			topicName string
			headline  string
			content   string
			fee       btcutil.Amount
			blockTime time.Time
			itemID    string
			upvotes   int64
			downvotes int64
			rawTLV    []byte
			url       string
			subtype   int32
			nsfw      bool
		)
		if err := rows.Scan(&id, &rawTopic, &topicName, &headline, &content, &fee, &blockTime, &itemID, &upvotes, &downvotes, &rawTLV, &url, &subtype, &nsfw); err != nil {
			return nil, fmt.Errorf("list coin news: scan new-format story: %w", err)
		}
		if len(rawTopic) != TopicIdLength {
			return nil, fmt.Errorf("list coin news: invalid new-format topic length: %d", len(rawTopic))
		}
		if strings.TrimSpace(headline) == "" {
			continue
		}
		var topic TopicID
		copy(topic[:], rawTopic)
		out = append(out, CoinNews{
			ID:        id,
			Topic:     topic,
			TopicName: topicName,
			Headline:  headline,
			Content:   content,
			Fee:       fee,
			ItemID:    itemID,
			Upvotes:   upvotes,
			Downvotes: downvotes,
			Score:     cnstore.HNScore(upvotes, downvotes, blockTime),
			URL:       url,
			Subtype:   subtype,
			NSFW:      nsfw,
			CreatedAt: &blockTime,
		})
		toReassemble = append(toReassemble, continuationTarget{idx: len(out) - 1, itemID: itemID, rawTLV: rawTLV})
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list coin news: iterate new-format stories: %w", err)
	}
	// Release the single DB connection this result set holds before issuing
	// any follow-up query. The pool is MaxOpenConns(1): querying continuations
	// while these rows are still open deadlocks — the follow-up waits forever
	// for the one connection this result set is holding.
	rows.Close()

	// §9: splice in any Continuation chunks to recover long bodies that didn't
	// fit in the head's 80-byte OP_RETURN.
	hasContinuations, err := anyContinuations(ctx, db)
	if err != nil {
		return nil, err
	}
	if hasContinuations {
		for _, t := range toReassemble {
			if body, ok := reassembledBody(ctx, db, t.itemID, t.rawTLV); ok {
				out[t.idx].Content = body
			}
		}
	}
	return out, nil
}

func anyContinuations(ctx context.Context, db *sql.DB) (bool, error) {
	var exists bool
	if err := db.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM cn_continuations)`).Scan(&exists); err != nil {
		return false, fmt.Errorf("list coin news: check continuations: %w", err)
	}
	return exists, nil
}

// reassembledBody returns the spec §9 reassembled body for a story when
// continuations extend it, and ok=false when there's nothing to splice
// (no continuations, or no body TLV in the reassembled section).
func reassembledBody(ctx context.Context, db *sql.DB, itemIDHex string, rawTLV []byte) (string, bool) {
	raw, err := hex.DecodeString(itemIDHex)
	if err != nil || len(raw) != codec.ItemIDLen {
		return "", false
	}
	var headID codec.ItemID
	copy(headID[:], raw)

	tlvs, err := cnstore.ReassembleTLVs(ctx, db, headID, rawTLV)
	if err != nil {
		return "", false
	}
	if t := codec.FindFirst(tlvs, codec.TLVBody); t != nil {
		return string(t.Value), true
	}
	return "", false
}

// rankCoinNews orders the feed by descending §13 score, breaking ties
// with the newer item first.
func rankCoinNews(news []CoinNews) {
	slices.SortFunc(news, func(a, b CoinNews) int {
		if a.Score != b.Score {
			if a.Score > b.Score {
				return -1
			}
			return 1
		}
		at, bt := time.Time{}, time.Time{}
		if a.CreatedAt != nil {
			at = *a.CreatedAt
		}
		if b.CreatedAt != nil {
			bt = *b.CreatedAt
		}
		switch {
		case at.After(bt):
			return -1
		case bt.After(at):
			return 1
		default:
			return 0
		}
	})
}
