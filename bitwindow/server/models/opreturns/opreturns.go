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

	sq "github.com/Masterminds/squirrel"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
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
			hex.EncodeToString(value.Data),
			value.Fee, value.Height, createdAt,
		)
	}

	builder = builder.Suffix(
		`ON CONFLICT (txid, vout) DO UPDATE SET 
			op_return_data = excluded.op_return_data, 
			height = COALESCE(excluded.height, op_returns.height), 
			-- Zero reads as unknown: a scan on a node with no txindex cannot
			-- fetch the fee, and must not erase one the mempool already gave us.
			fee_sats = COALESCE(NULLIF(excluded.fee_sats, 0), op_returns.fee_sats),
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
	ID        int64          `db:"id"`
	TxID      string         `db:"txid"`
	Vout      int32          `db:"vout"`
	Data      []byte         `db:"op_return_data"`
	Fee       btcutil.Amount `db:"fee_sats"` // 0 can either mean zero fee or unknown fee
	Height    *uint32        `db:"height"`
	CreatedAt *time.Time     `db:"created_at"`
}

// GetByTxID returns the OP_RETURN of the transaction with the lowest vout, or nil
// when the transaction has none.
func GetByTxID(ctx context.Context, db *sql.DB, txid string) (*OPReturn, error) {
	opReturn, err := database.Get[OPReturn](ctx, db, `
		SELECT id, txid, vout, unhex(op_return_data) AS op_return_data, fee_sats, height, created_at
		FROM op_returns
		WHERE txid = ?
		ORDER BY vout
		LIMIT 1
	`, txid)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, nil
	case err != nil:
		return nil, fmt.Errorf("get op_return %s: %w", txid, err)
	}
	return &opReturn, nil
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
		SELECT id, txid, vout, unhex(op_return_data) AS op_return_data, fee_sats, height, created_at
		FROM op_returns
		ORDER BY created_at DESC
	`
	args := []any{}
	if limit > 0 {
		query += "\nLIMIT ?"
		args = append(args, limit)
	}

	opReturns, err := database.Select[OPReturn](ctx, db, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list op_returns: %w", err)
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

// mempoolExpiry mirrors Core's default -mempoolexpiry. An unconfirmed
// OP_RETURN older than that is gone from every mempool and is never
// going to confirm.
const mempoolExpiry = 336 * time.Hour

// ReapExpiredMempool deletes unconfirmed OP_RETURNs past Core's mempool
// expiry. Mempool rows arrive over ZMQ with a NULL height and only ever get one
// when the transaction is mined, so a broadcast that was replaced, dropped or
// double-spent would otherwise sit in List forever.
//
// mempoolTxIDs reports what the node still holds. It is only called when a row
// is old enough to delete, because a node can run a longer -mempoolexpiry than
// the default, and `Persist` keeps the original created_at across a rebroadcast,
// so age alone does not prove the transaction is gone.
func ReapExpiredMempool(ctx context.Context, db *sql.DB, mempoolTxIDs func() ([]string, error)) error {
	cutoff := time.Now().Add(-mempoolExpiry)

	candidates, err := database.Select[string](ctx, db, `
		SELECT txid FROM op_returns
		WHERE height IS NULL AND datetime(created_at) < datetime(?)
	`, cutoff)
	if err != nil {
		return fmt.Errorf("select expired mempool OP_RETURNs: %w", err)
	}
	if len(candidates) == 0 {
		return nil
	}

	txids, err := mempoolTxIDs()
	if err != nil {
		return fmt.Errorf("read mempool: %w", err)
	}
	live := map[string]bool{}
	for _, txid := range txids {
		live[txid] = true
	}

	reaped := 0
	for _, txid := range candidates {
		if live[txid] {
			continue
		}
		if _, err := db.ExecContext(ctx,
			`DELETE FROM op_returns WHERE txid = ? AND height IS NULL`, txid,
		); err != nil {
			return fmt.Errorf("reap expired mempool OP_RETURN %s: %w", txid, err)
		}
		reaped++
	}

	if reaped > 0 {
		invalidateCaches(db)

		zerolog.Ctx(ctx).Info().
			Msgf("opreturns: reaped %d expired mempool OP_RETURN(s)", reaped)
	}

	return nil
}

func OPReturnToReadable(data []byte) string {
	// First try to decode as hex
	decoded, err := hex.DecodeString(string(data))
	if err == nil && isPrintableASCII(string(decoded)) {
		return string(decoded)
	}

	// If not hex or not human readable when decoded, try direct string
	if isPrintableASCII(string(data)) {
		return string(data)
	}

	// If all else fails, return as hex
	return hex.EncodeToString(data)
}

func isPrintableASCII(s string) bool {
	for _, r := range s {
		if !unicode.IsPrint(r) || r > 127 {
			return false
		}
	}
	return true
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
	SELECT 0, topic, name, 1, COALESCE(txid, ''), retention_days,
		(SELECT i.block_time FROM cn_items i WHERE i.txid = cn_topics.txid ORDER BY i.block_time ASC LIMIT 1) AS created_at
	FROM cn_topics
	ORDER BY created_at ASC
`)
	if err != nil {
		return nil, fmt.Errorf("list topics: query: %w", err)
	}
	defer database.SafeDefer(ctx, rows.Close)

	var topics []Topic
	for rows.Next() {
		var topic Topic
		var createdAt sql.NullTime
		err := rows.Scan(&topic.ID, &topic.Topic, &topic.Name, &topic.Confirmed, &topic.Txid, &topic.RetentionDays, &createdAt)
		if err != nil {
			return nil, fmt.Errorf("list topics: scan: %w", err)
		}
		if createdAt.Valid {
			topic.CreatedAt = createdAt.Time
		} else {
			topic.CreatedAt = time.Now()
		}

		topics = append(topics, topic)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list topics: iterate: %w", err)
	}

	return topics, nil
}

func TopicExists(ctx context.Context, db *sql.DB, topic TopicID) (bool, error) {
	exists, err := database.Get[bool](ctx, db, `
		SELECT EXISTS(SELECT 1 FROM cn_topics WHERE topic = ?)
	`, topic[:])
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

// StoryOptions holds the optional Story TLVs (spec §6, §10): a link
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

func (t *TopicID) Scan(src any) error {
	b, ok := src.([]byte)
	if !ok {
		return fmt.Errorf("topic ID is %T, want []byte", src)
	}
	if len(b) != TopicIdLength {
		return fmt.Errorf("topic ID %x is %d bytes, want %d", b, len(b), TopicIdLength)
	}
	copy(t[:], b)
	return nil
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
	type storyRow struct {
		ID        int64          `db:"id"`
		Topic     TopicID        `db:"topic"`
		TopicName string         `db:"topic_name"`
		Headline  string         `db:"headline"`
		Content   string         `db:"content"`
		Fee       btcutil.Amount `db:"fee"`
		BlockTime time.Time      `db:"block_time"`
		ItemID    string         `db:"item_id"`
		Upvotes   int64          `db:"upvotes"`
		Downvotes int64          `db:"downvotes"`
		RawTLV    []byte         `db:"raw_tlv"`
		URL       string         `db:"url"`
		Subtype   int32          `db:"subtype"`
		NSFW      bool           `db:"nsfw"`
	}
	rows, err := database.Select[storyRow](ctx, db, `
		SELECT
			i.rowid AS id,
			s.topic AS topic,
			COALESCE(ct.name, '') AS topic_name,
			s.headline AS headline,
			COALESCE(s.body, '') AS content,
			COALESCE(o.fee_sats, 0) AS fee,
			i.block_time AS block_time,
			lower(hex(s.item_id)) AS item_id,
			COALESCE(v.upvotes, 0) AS upvotes,
			COALESCE(v.downvotes, 0) AS downvotes,
			COALESCE(s.raw_tlv, x'') AS raw_tlv,
			COALESCE(s.url, '') AS url,
			s.subtype AS subtype,
			s.nsfw AS nsfw
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		LEFT JOIN cn_topics ct ON ct.topic = s.topic
		LEFT JOIN op_returns o ON o.txid = i.txid AND o.vout = i.vout
		LEFT JOIN (`+cnstore.VoteTally+`) v ON v.target_id = s.item_id
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

	type continuationTarget struct {
		idx    int
		itemID string
		rawTLV []byte
	}
	var out []CoinNews
	var toReassemble []continuationTarget
	for _, row := range rows {
		if strings.TrimSpace(row.Headline) == "" {
			continue
		}
		blockTime := row.BlockTime
		out = append(out, CoinNews{
			ID:        row.ID,
			Topic:     row.Topic,
			TopicName: row.TopicName,
			Headline:  row.Headline,
			Content:   row.Content,
			Fee:       row.Fee,
			ItemID:    row.ItemID,
			Upvotes:   row.Upvotes,
			Downvotes: row.Downvotes,
			Score:     cnstore.HNScore(row.Upvotes, row.Downvotes, row.BlockTime),
			URL:       row.URL,
			Subtype:   row.Subtype,
			NSFW:      row.NSFW,
			CreatedAt: &blockTime,
		})
		toReassemble = append(toReassemble, continuationTarget{idx: len(out) - 1, itemID: row.ItemID, rawTLV: row.RawTLV})
	}

	// §9: splice in any Continuation chunks to recover long bodies that didn't
	// fit in the head's 80-byte OP_RETURN.
	hasContinuations, err := anyContinuations(ctx, db)
	if err != nil {
		return nil, err
	}
	if hasContinuations {
		for _, t := range toReassemble {
			body, ok, err := reassembledBody(ctx, db, t.itemID, t.rawTLV)
			if err != nil {
				return nil, fmt.Errorf("list coin news: %w", err)
			}
			if ok {
				out[t.idx].Content = body
			}
		}
	}
	return out, nil
}

func anyContinuations(ctx context.Context, db *sql.DB) (bool, error) {
	exists, err := database.Get[bool](ctx, db, `SELECT EXISTS(SELECT 1 FROM cn_continuations)`)
	if err != nil {
		return false, fmt.Errorf("list coin news: check continuations: %w", err)
	}
	return exists, nil
}

// reassembledBody returns the spec §9 reassembled body for a story when
// continuations extend it, and ok=false when there's nothing to splice
// (no continuations, or no body TLV in the reassembled section).
func reassembledBody(ctx context.Context, db *sql.DB, itemIDHex string, rawTLV []byte) (string, bool, error) {
	raw, err := hex.DecodeString(itemIDHex)
	if err != nil {
		return "", false, fmt.Errorf("decode item id %q: %w", itemIDHex, err)
	}
	if len(raw) != codec.ItemIDLen {
		return "", false, fmt.Errorf("item id %q is %d bytes, want %d", itemIDHex, len(raw), codec.ItemIDLen)
	}
	var headID codec.ItemID
	copy(headID[:], raw)

	tlvs, err := cnstore.ReassembleTLVs(ctx, db, headID, rawTLV)
	if err != nil {
		return "", false, fmt.Errorf("reassemble story %s: %w", itemIDHex, err)
	}
	if t := codec.FindFirst(tlvs, codec.TLVBody); t != nil {
		return string(t.Value), true, nil
	}
	return "", false, nil
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
