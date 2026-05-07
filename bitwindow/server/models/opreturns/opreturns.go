package opreturns

import (
	"bytes"
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
)

// Backstop TTL for cached List / ListCoinNews — the contract is that
// Persist and CreateTopic invalidate; TTL only matters if a query
// races a write.
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
// Called from Persist and CreateTopic.
func invalidateCaches(db *sql.DB) {
	listCacheMu.Lock()
	delete(listCacheEntries, db)
	listCacheMu.Unlock()

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
			height = excluded.height, 
			fee_sats = excluded.fee_sats`,
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

type TopicInfo struct {
	ID            TopicID
	Name          string
	RetentionDays int32
}

var newTopicTag = []byte("new")

const TopicIdLength = 4

func IsCreateTopic(data []byte) (TopicInfo, bool) {
	if len(data) < TopicIdLength+len(newTopicTag) {
		return TopicInfo{}, false
	}

	// First 4 bytes are the topic ID
	topicID, err := ValidNewsTopicID(hex.EncodeToString(data[:TopicIdLength]))
	if err != nil {
		return TopicInfo{}, false
	}

	// Check if "new" follows the topic ID
	rest := data[TopicIdLength:]
	if !bytes.HasPrefix(rest, newTopicTag) {
		return TopicInfo{}, false
	}

	// Disambiguate from news messages that happen to start with "new".
	// News wire format is <4 topic><64 NULL-padded headline><content>, so
	// any NULL in the 64-byte headline slot marks this as news, not a
	// topic creation. Topic-creation names are user-entered text and
	// contain no NULL bytes. Skip byte 7 (retention) which may legitimately
	// be 0x00 in the new format.
	nameStart := TopicIdLength + len(newTopicTag) + 1 // skip retention byte
	headlineEnd := TopicIdLength + 64
	if headlineEnd > len(data) {
		headlineEnd = len(data)
	}
	for i := nameStart; i < headlineEnd; i++ {
		if data[i] == 0 {
			return TopicInfo{}, false
		}
	}

	afterNew := rest[len(newTopicTag):]

	// New format: <retention_1byte><name>
	// Old format (legacy): <name> directly
	//
	// Detection: Old topic names always start with printable ASCII (>= 32).
	// New format uses first byte as retention (0-255).
	// If first byte < 32 (control char) or > 127 (non-ASCII), it's the new format.
	// Otherwise it's the legacy format (name starts directly).
	var name string
	var retentionDays int32 = 7 // default for legacy topics

	if len(afterNew) > 0 {
		firstByte := afterNew[0]
		if firstByte >= 32 && firstByte <= 127 {
			// Legacy format - first byte is printable ASCII, entire thing is name
			name = string(afterNew)
		} else {
			// New format - first byte is retention days (0-31 or 128-255)
			retentionDays = int32(firstByte)
			if len(afterNew) > 1 {
				name = string(afterNew[1:])
			}
		}
	}

	// Legacy topic created without double "new" prefix
	if name == "sflashbitcoinsucks" {
		name = "newsflashbitcoinsucks"
	}

	return TopicInfo{
		ID:            topicID,
		Name:          name,
		RetentionDays: retentionDays,
	}, true
}

func CreateTopic(ctx context.Context, db *sql.DB, topic TopicID, name string, txid string, confirmed bool, retentionDays int32) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO coin_news_topics (
			topic,
			name,
			txid,
			confirmed,
			retention_days
		) VALUES (?, ?, ?, ?, ?)
		ON CONFLICT (topic) DO UPDATE SET confirmed = excluded.confirmed OR coin_news_topics.confirmed
	`, topic.String(), name, txid, confirmed, retentionDays)
	if err != nil {
		return fmt.Errorf("create topic: %w", err)
	}

	// Topic changes alter which rows the ListCoinNews JOIN matches.
	invalidateCaches(db)

	return nil
}

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

	CreatedAt *time.Time
}

func ListTopics(ctx context.Context, db *sql.DB) ([]Topic, error) {
	rows, err := db.QueryContext(ctx, `
	SELECT id, topic, name, confirmed, COALESCE(txid, ''), COALESCE(retention_days, 7), created_at
	FROM coin_news_topics
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
		err := rows.Scan(&topic.ID, &rawTopicID, &topic.Name, &topic.Confirmed, &topic.Txid, &topic.RetentionDays, &topic.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("list topics: scan: %w", err)
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
		SELECT EXISTS(SELECT 1 FROM coin_news_topics WHERE topic = ?)
	`, topic.String()).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("topic exists: %w", err)
	}
	return exists, nil
}

// Format for OP_RETURN message: <topic (4 bytes)><headline (64 bytes)><message (arbitrary length)>
func EncodeNewsMessage(topic TopicID, headline string, content string) []byte {
	paddedHeadline := headline + string(make([]byte, 64-len(headline)))
	return slices.Concat(
		topic[:], []byte(paddedHeadline), []byte(content),
	)
}

// Format for OP_RETURN message: <topic>new<retention_days_1byte><title>
// retention_days is stored as a single byte (0-255, where 0 = infinite)
func EncodeTopicCreationMessage(topic TopicID, name string, retentionDays int32) []byte {
	// Clamp retention days to 0-255
	if retentionDays < 0 {
		retentionDays = 0
	}
	if retentionDays > 255 {
		retentionDays = 255
	}
	return slices.Concat(
		topic[:], newTopicTag, []byte{byte(retentionDays)}, []byte(name),
	)
}

type TopicID [TopicIdLength]byte

func (t TopicID) String() string {
	return hex.EncodeToString(t[:])
}

// ListCoinNews returns OP_RETURNs that match a known topic, with the
// per-topic retention cutoff applied. Topic match (first 4 bytes /
// 8 hex chars of op_return_data) and retention are done in SQL; the Go
// pass only strips topic-creation rows and empty payloads.
func ListCoinNews(ctx context.Context, db *sql.DB) ([]CoinNews, error) {
	coinNewsCacheMu.RLock()
	cached, hit := coinNewsCacheEntries[db]
	coinNewsCacheMu.RUnlock()
	if hit && time.Since(cached.at) < listCacheTTL {
		out := make([]CoinNews, len(cached.rows))
		copy(out, cached.rows)
		return out, nil
	}

	// retention_days = 0 means keep forever.
	rows, err := db.QueryContext(ctx, `
		SELECT
			o.id, o.txid, o.vout, unhex(o.op_return_data), o.fee_sats, o.height, o.created_at,
			t.id, t.topic, t.name, t.confirmed, COALESCE(t.txid, ''), COALESCE(t.retention_days, 7), t.created_at
		FROM op_returns o
		INNER JOIN coin_news_topics t
			ON SUBSTR(o.op_return_data, 1, 8) = t.topic
		WHERE
			t.retention_days = 0
			OR o.created_at >= datetime('now', '-' || t.retention_days || ' days')
		ORDER BY o.created_at DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("list coin news: query: %w", err)
	}
	defer rows.Close()

	var coinNews []CoinNews
	for rows.Next() {
		var (
			opReturn   OPReturn
			topic      Topic
			rawTopicID string
		)
		err := rows.Scan(
			&opReturn.ID, &opReturn.TxID, &opReturn.Vout,
			&opReturn.Data, &opReturn.Fee, &opReturn.Height, &opReturn.CreatedAt,
			&topic.ID, &rawTopicID, &topic.Name, &topic.Confirmed, &topic.Txid, &topic.RetentionDays, &topic.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("list coin news: scan: %w", err)
		}

		topicID, err := ValidNewsTopicID(rawTopicID)
		if err != nil {
			return nil, fmt.Errorf("list coin news: invalid topic ID: %w", err)
		}
		topic.Topic = topicID

		if len(opReturn.Data) < TopicIdLength {
			continue
		}
		// Topic-creation rows match the prefix but aren't news.
		if _, ok := IsCreateTopic(opReturn.Data); ok {
			continue
		}

		var (
			headline string
			content  string
		)
		headlineEnd := TopicIdLength + 64
		switch {
		case len(opReturn.Data) >= headlineEnd:
			headline = strings.TrimRight(string(opReturn.Data[TopicIdLength:headlineEnd]), " ")
			content = string(opReturn.Data[headlineEnd:])

		default:
			headline = strings.TrimRight(string(opReturn.Data[TopicIdLength:]), " ")
		}

		// Remove all the whitespace padding
		headline = strings.TrimRight(headline, string([]byte{0}))
		content = strings.TrimRight(content, string([]byte{0}))

		// Skip empty entries — junk posts where the payload is just a
		// space+null padding (headline blank, content blank).
		if strings.TrimSpace(headline) == "" && strings.TrimSpace(content) == "" {
			continue
		}

		coinNews = append(coinNews, CoinNews{
			ID:        opReturn.ID,
			Topic:     topic.Topic,
			TopicName: topic.Name,
			Headline:  headline,
			Content:   content,
			Fee:       opReturn.Fee,
			CreatedAt: opReturn.CreatedAt,
		})
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list coin news: iterate: %w", err)
	}

	snapshot := make([]CoinNews, len(coinNews))
	copy(snapshot, coinNews)
	coinNewsCacheMu.Lock()
	coinNewsCacheEntries[db] = coinNewsCacheEntry{rows: snapshot, at: time.Now()}
	coinNewsCacheMu.Unlock()

	return coinNews, nil
}
