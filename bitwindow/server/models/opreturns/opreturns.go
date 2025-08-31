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
	"time"
	"unicode"

	sq "github.com/Masterminds/squirrel"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
)

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

func List(ctx context.Context, db *sql.DB) ([]OPReturn, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, txid, vout, unhex(op_return_data), fee_sats, height, created_at
		FROM op_returns
		ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("list: query op_returns: %w", err)
	}
	defer rows.Close()

	var opReturns []OPReturn
	for rows.Next() {
		var (
			opReturn OPReturn
		)
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

	if len(decode) != topicIdLength {
		return TopicID{}, fmt.Errorf("topic ID %q is not 8 bytes: %d", topic, len(decode))
	}

	return TopicID(decode), nil
}

type TopicInfo struct {
	ID   TopicID
	Name string
}

var newTopicTag = []byte("new")

const topicIdLength = 8

func IsCreateTopic(data []byte) (TopicInfo, bool) {
	if len(data) < topicIdLength+len(newTopicTag) {
		return TopicInfo{}, false
	}

	// First 8 chars should be the hex topic
	topic := hex.EncodeToString(data[:topicIdLength])
	topicID, err := ValidNewsTopicID(topic)
	if err != nil {
		return TopicInfo{}, false
	}

	// Check if "new" follows the topic
	name, ok := bytes.CutPrefix(data[topicIdLength:], newTopicTag)
	return TopicInfo{
		ID:   topicID,
		Name: string(name),
	}, ok
}

func CreateTopic(ctx context.Context, db *sql.DB, topic TopicID, name string, txid string) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO coin_news_topics (
			topic,
			name,
			txid
		) VALUES (?, ?, ?)
		 ON CONFLICT (topic) DO NOTHING
	`, topic.String(), name, txid)
	if err != nil {
		return fmt.Errorf("create topic: %w", err)
	}

	return nil
}

type Topic struct {
	ID    int64
	Topic TopicID
	Name  string

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
	SELECT id, topic, name, created_at
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
		err := rows.Scan(&topic.ID, &rawTopicID, &topic.Name, &topic.CreatedAt)
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

// Format for OP_RETURN message: <topic (8 bytes)><headline (64 bytes)><message (arbitrary length)>
func EncodeNewsMessage(topic TopicID, headline string, content string) []byte {
	paddedHeadline := headline + string(make([]byte, 64-len(headline)))
	return slices.Concat(
		topic[:], []byte(paddedHeadline), []byte(content),
	)
}

// Format for OP_RETURN message: <topic>new<title>
func EncodeTopicCreationMessage(topic TopicID, name string) []byte {
	return slices.Concat(
		topic[:], newTopicTag, []byte(name),
	)
}

type TopicID [topicIdLength]byte

func (t TopicID) String() string {
	return hex.EncodeToString(t[:])
}

func extractTopic(topics []Topic, topic TopicID) (Topic, bool) {
	for _, t := range topics {
		if t.Topic == topic {
			return t, true
		}
	}
	return Topic{}, false
}

func ListCoinNews(ctx context.Context, db *sql.DB) ([]CoinNews, error) {
	opReturns, err := List(ctx, db)
	if err != nil {
		return nil, err
	}

	topics, err := ListTopics(ctx, db)
	if err != nil {
		return nil, err
	}

	var coinNews []CoinNews
	for _, opReturn := range opReturns {
		if len(opReturn.Data) < topicIdLength {
			continue
		}

		// Skip over all topic creation OP_RETURNs
		if _, ok := IsCreateTopic(opReturn.Data); ok {
			continue
		}

		topic, ok := extractTopic(topics, TopicID(opReturn.Data[:topicIdLength]))
		if !ok {
			continue
		}

		var (
			headline string
			content  string
		)
		switch {
		case len(opReturn.Data) >= 72:
			headline = strings.TrimRight(string(opReturn.Data[topicIdLength:72]), " ")
			content = string(opReturn.Data[72:])

		default:
			headline = strings.TrimRight(string(opReturn.Data[topicIdLength:]), " ")
		}

		// Remove all the whitespace padding
		headline = strings.TrimRight(headline, string([]byte{0}))

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

	return coinNews, nil
}
