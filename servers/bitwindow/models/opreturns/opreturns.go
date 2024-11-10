package opreturns

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"
	"unicode"
)

func Persist(
	ctx context.Context, db *sql.DB, height *int32, txid string, vout int32,
	data []byte, feeSatoshi int64, createdAt time.Time,
) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO op_returns (
			txid,
			vout,
			op_return_data,
			fee_sats,
			height,
			created_at
		) VALUES (?, ?, ?, ?, ?, ?)
		ON CONFLICT (txid, vout) DO UPDATE SET
			op_return_data = excluded.op_return_data,
			height = excluded.height,
			fee_sats = excluded.fee_sats
	`, txid, vout, data, feeSatoshi, height, createdAt)
	if err != nil {
		return fmt.Errorf("could not persist op_return: %w", err)
	}

	return nil
}

type OPReturn struct {
	ID        int64
	TxID      string
	Vout      int32
	Data      []byte
	FeeSats   int64
	Height    *int32
	CreatedAt time.Time
}

func List(ctx context.Context, db *sql.DB) ([]OPReturn, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, txid, vout, op_return_data, fee_sats, height, created_at
		FROM op_returns
		ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("could not query op_returns: %w", err)
	}
	defer rows.Close()

	var opReturns []OPReturn
	for rows.Next() {
		var opReturn OPReturn
		err := rows.Scan(&opReturn.ID, &opReturn.TxID, &opReturn.Vout, &opReturn.Data, &opReturn.FeeSats, &opReturn.Height, &opReturn.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("could not scan op_return: %w", err)
		}
		opReturns = append(opReturns, opReturn)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("could not iterate op_returns: %w", err)
	}

	return opReturns, nil
}

func OPReturnToReadable(data []byte) string {
	// Convert to string first to properly handle UTF-8 encoding
	str := string(data)

	isHumanReadable := true
	for _, r := range str {
		// Check if character is printable AND in basic ASCII range
		// This prevents invalid UTF-8 sequences from being considered readable
		if !unicode.IsPrint(r) || r > 127 {
			isHumanReadable = false
			break
		}
	}

	if isHumanReadable {
		return str
	}

	return hex.EncodeToString(data)
}

func ValidNewsTopic(topic string) bool {
	// Check if length is exactly 8 characters (4 bytes in hex)
	if len(topic) != 8 {
		return false
	}

	// Check if string is valid hex
	_, err := hex.DecodeString(topic)
	return err == nil
}

func IsCreateTopic(data []byte) bool {
	if len(data) < 11 {
		return false
	}

	// First 8 chars should be the hex topic
	topic := string(data[:8])
	if !ValidNewsTopic(topic) {
		return false
	}

	// Check if "new" follows the topic
	return string(data[8:11]) == "new"
}

func NameFromCreateTopic(data []byte) (string, error) {
	if !IsCreateTopic(data) {
		return "", errors.New("not a create topic")
	}
	// Skip the 8-char topic and the 3-char "new" prefix
	return string(data[11:]), nil
}

func ContentFromReturn(data []byte) (string, error) {
	if !IsCreateTopic(data) {
		return "", errors.New("not a create topic")
	}
	return string(data[7:]), nil
}

func TitleFromReturn(data []byte) (string, error) {
	// first 8 bytes are the topic
	if len(data) < 8 {
		return "", errors.New("data too short")
	}
	return hex.EncodeToString(data[:8]), nil
}

func CreateTopic(ctx context.Context, db *sql.DB, topic string, name string, txid string) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO coin_news_topics (
			topic,
			name,
			txid
		) VALUES (?, ?, ?)
		 ON CONFLICT (topic) DO NOTHING
	`, topic, name, txid)
	if err != nil {
		return fmt.Errorf("could not create topic: %w", err)
	}

	return nil
}

type Topic struct {
	ID    int64
	Topic string
	Name  string

	CreatedAt time.Time
}

type CoinNews struct {
	ID        int64
	Topic     string
	TopicName string
	Headline  string
	Content   string
	FeeSats   int64

	CreatedAt time.Time
}

func ListTopics(ctx context.Context, db *sql.DB) ([]Topic, error) {
	rows, err := db.QueryContext(ctx, `
	SELECT id, topic, name, created_at
	FROM coin_news_topics
	ORDER BY created_at ASC
`)
	if err != nil {
		return nil, fmt.Errorf("could not query op_returns: %w", err)
	}
	defer rows.Close()

	var topics []Topic
	for rows.Next() {
		var topic Topic
		err := rows.Scan(&topic.ID, &topic.Topic, &topic.Name, &topic.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("could not scan topic: %w", err)
		}
		topics = append(topics, topic)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("could not iterate topics: %w", err)
	}

	return topics, nil
}

func TopicExists(ctx context.Context, db *sql.DB, topic string) (bool, error) {
	var exists bool
	err := db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM coin_news_topics WHERE topic = ?)
	`, topic).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("could not check if topic exists: %w", err)
	}
	return exists, nil
}

func extractTopic(topics []Topic, topic string) (Topic, bool) {
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
		return nil, fmt.Errorf("could not select op returns: %w", err)
	}

	topics, err := ListTopics(ctx, db)
	if err != nil {
		return nil, fmt.Errorf("could not select topics: %w", err)
	}

	var coinNews []CoinNews
	for _, opReturn := range opReturns {
		if len(opReturn.Data) < 8 {
			continue
		}

		if IsCreateTopic(opReturn.Data) {
			continue
		}

		topicBytes := opReturn.Data[:8]
		topic, ok := extractTopic(topics, string(topicBytes))
		if !ok {
			continue
		}

		var headline string
		if len(opReturn.Data) >= 72 {
			headline = strings.TrimRight(string(opReturn.Data[8:72]), " ")
		} else {
			headline = strings.TrimRight(string(opReturn.Data[8:]), " ")
		}

		var content string
		if len(opReturn.Data) > 72 {
			content = string(opReturn.Data[72:])
		}

		coinNews = append(coinNews, CoinNews{
			ID:        opReturn.ID,
			Topic:     string(topicBytes),
			TopicName: topic.Name,
			Headline:  headline,
			Content:   content,
			FeeSats:   opReturn.FeeSats,
			CreatedAt: opReturn.CreatedAt,
		})
	}

	return coinNews, nil
}
