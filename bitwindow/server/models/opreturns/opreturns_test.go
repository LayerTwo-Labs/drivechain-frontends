// Coin-news encode/decode and topic-classification tests. The live bug
// these target: users reported "Title" column blank in the latest release
// on all news rows. Tests cover edge cases that can silently turn a real
// headline into an empty string (whitespace-only payload, TrimRight
// interactions, null padding), and cases where a news message's headline
// could be misclassified as a topic creation ("new"-prefixed headlines).

package opreturns

import (
	"context"
	"database/sql"
	"encoding/hex"
	"fmt"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

func mustTopicID(t *testing.T, hex string) TopicID {
	t.Helper()
	id, err := ValidNewsTopicID(hex)
	require.NoError(t, err)
	return id
}

func seedTopicAndNews(t *testing.T, topic TopicID, topicName, headline, content string) *sql.DB {
	t.Helper()
	ctx := t.Context()
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, topicName, 7, 99)
	seedCurrentNews(t, ctx, db, topic, headline, content, "news_txid", 0, 100, time.Now())
	return db
}

func seedCurrentTopic(
	t *testing.T, ctx context.Context, db *sql.DB,
	topic TopicID, name string, retentionDays int32, height uint32,
) {
	t.Helper()
	var ct codec.Topic
	copy(ct[:], topic[:])
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: height,
			TxIndex:     0,
			VoutIndex:   0,
			BlockTime:   time.Now(),
			TxID:        fmt.Sprintf("%064x", height),
		},
		TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{
			Topic:         ct,
			RetentionDays: byte(retentionDays),
			Name:          name,
		},
	}))
}

func seedCurrentNews(
	t *testing.T, ctx context.Context, db *sql.DB,
	topic TopicID, headline, content, txid string, vout, height uint32, blockTime time.Time,
) {
	t.Helper()
	var ct codec.Topic
	copy(ct[:], topic[:])
	story := &codec.Story{Topic: ct, Headline: headline}
	if content != "" {
		story.TLVs = append(story.TLVs, codec.TLV{Tag: codec.TLVBody, Value: []byte(content)})
	}
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: height,
			TxIndex:     0,
			VoutIndex:   vout,
			BlockTime:   blockTime,
			TxID:        canonicalTxID(txid),
		},
		TypeTag: codec.TypeStory,
		Msg:     story,
	}))
}

// TestListTopics_SurfacesChainIndexedTopics proves a chain-indexed topic
// (cn_topics) — including ones created by other wallets — appears in
// ListTopics and satisfies TopicExists.
func TestListTopics_SurfacesChainIndexedTopics(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	external := mustTopicID(t, "beefbeef")
	var ct codec.Topic
	copy(ct[:], external[:])
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: 100, TxIndex: 0, VoutIndex: 0,
			BlockTime: time.Now(), TxID: fmt.Sprintf("%064x", 100),
		},
		TypeTag: codec.TypeTopicCreation,
		Msg:     &codec.TopicCreation{Topic: ct, RetentionDays: 7, Name: "Foreign Topic"},
	}))

	topics, err := ListTopics(ctx, db)
	require.NoError(t, err)
	found, ok := lo.Find(topics, func(tp Topic) bool { return tp.Topic == external })
	require.True(t, ok)
	assert.Equal(t, "Foreign Topic", found.Name)
	assert.True(t, found.Confirmed)
	assert.NotZero(t, found.ID)

	exists, err := TopicExists(ctx, db, external)
	require.NoError(t, err)
	assert.True(t, exists)

	exists, err = TopicExists(ctx, db, mustTopicID(t, "deaddead"))
	require.NoError(t, err)
	assert.False(t, exists)
}

func TestListTopics_RefusesShortTopicID(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	_, err := db.ExecContext(ctx, `
		INSERT INTO cn_topics (topic, name, retention_days, created_height, txid)
		VALUES (x'010203', 'Short', 0, 1, 'txid')`)
	require.NoError(t, err)

	_, err = ListTopics(ctx, db)
	require.ErrorContains(t, err, "topic ID 010203 is 3 bytes, want 4")
}

// TestListCoinNews_SurfacesStoryTLVs proves a Story's url/subtype/nsfw
// TLVs (spec §10) round-trip through ListCoinNews.
func TestListCoinNews_SurfacesStoryTLVs(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	topic := mustTopicID(t, "a1a1a1a1")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)

	var ct codec.Topic
	copy(ct[:], topic[:])
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: 100, TxIndex: 0, VoutIndex: 0,
			BlockTime: time.Now(), TxID: fmt.Sprintf("%064x", 100),
		},
		TypeTag: codec.TypeStory,
		Msg: &codec.Story{Topic: ct, Headline: "Link post", TLVs: []codec.TLV{
			{Tag: codec.TLVURL, Value: []byte("https://example.com")},
			{Tag: codec.TLVSubtype, Value: []byte{byte(codec.SubtypeLink)}},
			{Tag: codec.TLVNSFW, Value: []byte{0x01}},
		}},
	}))

	news, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, "https://example.com", news[0].URL)
	assert.Equal(t, int32(codec.SubtypeLink), news[0].Subtype)
	assert.True(t, news[0].NSFW)
}

// TestListCoinNews_ReassemblesContinuationBody proves spec §9: a head
// Story with no in-line body plus Continuation chunks carrying a long
// body TLV is rendered with the full reassembled body.
func TestListCoinNews_ReassemblesContinuationBody(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	topic := mustTopicID(t, "a1a1a1a1")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)
	// Head story: headline only, no body.
	seedCurrentNews(t, ctx, db, topic, "Headline", "", "story1", 0, 100, time.Now())

	var itemID []byte
	require.NoError(t, db.QueryRowContext(ctx, `SELECT item_id FROM cn_stories`).Scan(&itemID))
	var head codec.ItemID
	copy(head[:], itemID)

	longBody := strings.Repeat("the full body that did not fit in eighty bytes. ", 4)
	tlvBytes, err := codec.SerialiseTLVs([]codec.TLV{{Tag: codec.TLVBody, Value: []byte(longBody)}})
	require.NoError(t, err)

	// Split into ≤63-byte chunks, indexed in seq order, same block as
	// the head, at increasing scan positions.
	for seq, off := 0, 0; off < len(tlvBytes); seq, off = seq+1, off+codec.ContinuationChunk {
		end := off + codec.ContinuationChunk
		if end > len(tlvBytes) {
			end = len(tlvBytes)
		}
		require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
			Pos: cnstore.BlockPos{
				BlockHeight: 100,
				TxIndex:     0,
				VoutIndex:   uint32(seq + 1),
				BlockTime:   time.Now(),
				TxID:        fmt.Sprintf("%064x", 5000+seq),
			},
			TypeTag: codec.TypeContinuation,
			Msg:     &codec.Continuation{Head: head, Seq: byte(seq), Chunk: tlvBytes[off:end]},
		}))
	}

	news, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, longBody, news[0].Content)
}

func TestListCoinNews_ReturnsReassemblyError(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	topic := mustTopicID(t, "a2a2a2a2")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)
	seedCurrentNews(t, ctx, db, topic, "Headline", "", "story1", 0, 100, time.Now())

	var itemID []byte
	require.NoError(t, db.QueryRowContext(ctx, `SELECT item_id FROM cn_stories`).Scan(&itemID))
	var head codec.ItemID
	copy(head[:], itemID)
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: 100,
			VoutIndex:   1,
			BlockTime:   time.Now(),
			TxID:        fmt.Sprintf("%064x", 6000),
		},
		TypeTag: codec.TypeContinuation,
		Msg:     &codec.Continuation{Head: head, Seq: 0, Chunk: []byte{0x01}},
	}))
	_, err := db.ExecContext(ctx, `UPDATE cn_stories SET raw_tlv = x'ff'`)
	require.NoError(t, err)

	_, err = ListCoinNews(ctx, db)
	require.ErrorContains(t, err, "decode head tlv")
}

func TestListCoinNews_ReassemblesOnlyContinuationHeads(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	topic := mustTopicID(t, "a3a3a3a3")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)
	seedCurrentNews(t, ctx, db, topic, "Head", "", "story1", 0, 100, time.Now())
	seedCurrentNews(t, ctx, db, topic, "Plain", "plain body", "story2", 0, 101, time.Now())

	var itemID []byte
	require.NoError(t, db.QueryRowContext(ctx, `SELECT item_id FROM cn_stories WHERE headline = 'Head'`).Scan(&itemID))
	var head codec.ItemID
	copy(head[:], itemID)
	tlvBytes, err := codec.SerialiseTLVs([]codec.TLV{{Tag: codec.TLVBody, Value: []byte("long body")}})
	require.NoError(t, err)
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: 100,
			VoutIndex:   1,
			BlockTime:   time.Now(),
			TxID:        fmt.Sprintf("%064x", 7000),
		},
		TypeTag: codec.TypeContinuation,
		Msg:     &codec.Continuation{Head: head, Seq: 0, Chunk: tlvBytes},
	}))
	// A reassembly of the plain story fails, so the feed proves that it skips that story.
	_, err = db.ExecContext(ctx, `UPDATE cn_stories SET raw_tlv = x'ff' WHERE headline = 'Plain'`)
	require.NoError(t, err)

	news, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	got := lo.SliceToMap(news, func(n CoinNews) (string, string) { return n.Headline, n.Content })
	assert.Equal(t, map[string]string{"Head": "long body", "Plain": "plain body"}, got)
}

// TestListCoinNews_RanksByFee proves the feed lists the highest fee first,
// newest first on a tie, and that each story's ItemID round-trips as hex.
func TestListCoinNews_RanksByFee(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	topic := mustTopicID(t, "a1a1a1a1")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)
	now := time.Now()
	stories := []struct {
		headline string
		fee      int64
		age      time.Duration
	}{
		{"Older tie", 100, 2 * time.Hour},
		{"Dear", 5000, 3 * time.Hour},
		{"Newer tie", 100, time.Hour},
	}
	for i, st := range stories {
		txid := canonicalTxID(st.headline)
		seedCurrentNews(t, ctx, db, topic, st.headline, "", txid, 0, uint32(100+i), now.Add(-st.age))
		_, err := db.ExecContext(ctx,
			`INSERT INTO op_returns (txid, vout, op_return_data, fee_sats) VALUES (?, 0, '', ?)`, txid, st.fee)
		require.NoError(t, err)
	}

	news, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	assert.Equal(t, []string{"Dear", "Newer tie", "Older tie"}, lo.Map(news, func(n CoinNews, _ int) string { return n.Headline }))
	assert.EqualValues(t, 5000, news[0].Fee)

	var itemID []byte
	require.NoError(t, db.QueryRowContext(ctx, `SELECT item_id FROM cn_stories WHERE headline = 'Dear'`).Scan(&itemID))
	assert.Equal(t, hex.EncodeToString(itemID), news[0].ItemID)
}

func canonicalTxID(label string) string {
	if len(label) == 64 {
		return label
	}
	var sum byte
	for i := 0; i < len(label); i++ {
		sum += label[i]
	}
	return fmt.Sprintf("%064x", sum)
}

func TestListCoinNews_RoundTripHeadlines(t *testing.T) {
	cases := []struct {
		name     string
		headline string
		content  string
	}{
		{"short", "Hi", "body"},
		{"standard", "Bitcoin price up", "body"},
		{"exact 64 bytes", string(make([]byte, 64-len("pad"))) + "pad", "body"}, //nolint:govet // intentional
		{"with trailing spaces in content (not headline)", "Hello", "body   "},
		{"non-ascii utf-8", "世界のニュース", "body"},
		{"one char", "A", "body"},
		{"digit-only", "12345", "body"},
		{"contains spaces mid-word", "Hello world", "body"},
		{"uppercase NEW prefix (not the topic-creation marker)", "NEWS FLASH", "body"},
		{"lowercase new in middle of headline", "anew era", "body"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			db := seedTopicAndNews(t, mustTopicID(t, "deadbeef"), "Test Topic", tc.headline, tc.content)

			news, err := ListCoinNews(t.Context(), db)
			require.NoError(t, err)
			require.Len(t, news, 1)
			assert.Equal(t, tc.headline, news[0].Headline)
		})
	}
}

// TestListCoinNews_FullWidth64ByteHeadline ensures a max-length
// headline (exactly 64 bytes, no null padding) decodes to the full
// payload, not to one that happens to match a substring.
func TestListCoinNews_FullWidth64ByteHeadline(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	full := "ABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCD" // 64 chars
	require.Equal(t, 64, len(full))

	db := seedTopicAndNews(t, topic, "Test Topic", full, "body")

	news, err := ListCoinNews(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, full, news[0].Headline)
	assert.Equal(t, "body", news[0].Content)
}

// TestListCoinNews_HeadlineStartingWithNewIsNotTopicCreation guards the
// headline/topic-creation ambiguity. A news message whose headline
// starts with "new" (e.g. "news flash about X") must NOT be classified
// as a topic-creation OP_RETURN and dropped from the news list. The
// classifier now looks for NULL bytes inside the 64-byte headline slot
// — news messages always have them (unless the headline is the full 64
// bytes), topic-creation names never do.
func TestListCoinNews_HeadlineStartingWithNewIsNotTopicCreation(t *testing.T) {
	topic := mustTopicID(t, "a1a1a1a1")
	headline := "news flash about drivechain"
	db := seedTopicAndNews(t, topic, "US Weekly", headline, "body")

	news, err := ListCoinNews(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, headline, news[0].Headline)
}

// TestListCoinNews_WhitespaceOnlyHeadline documents the defensive read
// filter: current broadcasts reject these, and the legacy adapter
// avoids inserting them, but a hand-written canonical row still must
// not render as a blank title.
func TestListCoinNews_WhitespaceOnlyHeadline(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	db := seedTopicAndNews(t, topic, "Test Topic", "   ", "body")

	news, err := ListCoinNews(t.Context(), db)
	require.NoError(t, err)
	assert.Empty(t, news)
}

// TestListCoinNews_EmptyHeadline mirrors the above for empty headline
// rows. They are invalid for normal broadcasts and hidden on read.
func TestListCoinNews_EmptyHeadline(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	db := seedTopicAndNews(t, topic, "Test Topic", "", "body")

	news, err := ListCoinNews(t.Context(), db)
	require.NoError(t, err)
	assert.Empty(t, news)
}

// TestListCoinNews_ShortHeadline keeps the reader honest for a compact
// current-format Story.
func TestListCoinNews_ShortMessageBelowHeadlineEnd(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	db := seedTopicAndNews(t, topic, "Test Topic", "short!!!", "")

	news, err := ListCoinNews(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, "short!!!", news[0].Headline)
}

// TestListCoinNews_NewPrefixedHeadlineSurvivesDecode locks in the
// classifier fix: a 'new'-prefixed headline round-trips through
// ListCoinNews instead of being dropped as a misclassified topic
// creation.
func TestListCoinNews_NewPrefixedHeadlineSurvivesDecode(t *testing.T) {
	topic := mustTopicID(t, "a1a1a1a1")
	headline := "new partnership announced"
	db := seedTopicAndNews(t, topic, "US Weekly", headline, "body")

	news, err := ListCoinNews(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, headline, news[0].Headline)
}

// TestBackfillCoinNewsBlockTime regresses #1655: pre-fix, op_returns.created_at
// was stamped with sync wall time instead of the block time. Migration 033
// rewrites confirmed rows from processed_blocks.block_time. Mempool rows
// (height NULL) and rows with no matching processed_blocks entry are left
// alone.
//
// SQL is duplicated from migrations/033_coin_news_block_time_backfill.sql —
// keep them in sync.
func TestBackfillCoinNewsBlockTime(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	confirmedHeight := uint32(800000)
	orphanHeight := uint32(800001) // no processed_blocks row
	blockTime := time.Date(2024, 1, 1, 12, 0, 0, 0, time.UTC)
	syncTime := time.Date(2026, 4, 25, 8, 0, 0, 0, time.UTC)

	_, err := db.ExecContext(ctx, `
		INSERT INTO processed_blocks (height, block_hash, block_time, txids)
		VALUES (?, ?, ?, ?)
	`, confirmedHeight, "deadbeef", blockTime, "")
	require.NoError(t, err)

	require.NoError(t, Persist(ctx, db, []OPReturn{
		{Height: &confirmedHeight, TxID: "confirmed", Vout: 0, Data: []byte{0xa1, 0xa1, 0xa1, 0xa1}, CreatedAt: &syncTime},
		{Height: &orphanHeight, TxID: "orphan", Vout: 0, Data: []byte{0xa1, 0xa1, 0xa1, 0xa1}, CreatedAt: &syncTime},
		{Height: nil, TxID: "mempool", Vout: 0, Data: []byte{0xa1, 0xa1, 0xa1, 0xa1}, CreatedAt: &syncTime},
	}))

	const backfillSQL = `
		UPDATE op_returns
		SET created_at = (
			SELECT block_time FROM processed_blocks
			WHERE processed_blocks.height = op_returns.height
		)
		WHERE op_returns.height IS NOT NULL
		  AND EXISTS (
			SELECT 1 FROM processed_blocks
			WHERE processed_blocks.height = op_returns.height
		);`
	_, err = db.ExecContext(ctx, backfillSQL)
	require.NoError(t, err)

	got := func(txid string) time.Time {
		t.Helper()
		var ts time.Time
		require.NoError(t, db.QueryRowContext(ctx,
			`SELECT created_at FROM op_returns WHERE txid = ?`, txid,
		).Scan(&ts))
		return ts
	}

	assert.WithinDuration(t, blockTime, got("confirmed"), time.Second)
	assert.WithinDuration(t, syncTime, got("orphan"), time.Second)
	assert.WithinDuration(t, syncTime, got("mempool"), time.Second)
}

// A mempool OP_RETURN that never got mined must stop being listed once
// it is past the point where any mempool could still be holding it.
func TestReapExpiredMempool(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	height := uint32(800000)
	stale := time.Now().Add(-mempoolExpiry - time.Hour)
	recent := time.Now().Add(-time.Hour)

	require.NoError(t, Persist(ctx, db, []OPReturn{
		{TxID: "expired-mempool", Vout: 0, Data: []byte{0x01}, CreatedAt: &stale},
		{TxID: "pending-mempool", Vout: 0, Data: []byte{0x02}, CreatedAt: &recent},
		{TxID: "old-confirmed", Vout: 0, Data: []byte{0x03}, Height: &height, CreatedAt: &stale},
	}))

	require.NoError(t, ReapExpiredMempool(ctx, db, func() ([]string, error) { return nil, nil }))

	got, err := List(ctx, db, 0)
	require.NoError(t, err)

	txids := lo.Map(got, func(o OPReturn, _ int) string { return o.TxID })
	slices.Sort(txids)
	assert.Equal(t, []string{"old-confirmed", "pending-mempool"}, txids)
}

func TestPersistConfirmedConflictUpdatesCreateTimeToBlockTime(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)

	height := uint32(800000)
	syncTime := time.Date(2026, 4, 25, 8, 0, 0, 0, time.UTC)
	blockTime := time.Date(2024, 1, 1, 12, 0, 0, 0, time.UTC)
	laterMempoolTime := time.Date(2026, 4, 26, 8, 0, 0, 0, time.UTC)

	require.NoError(t, Persist(ctx, db, []OPReturn{{
		Height:    nil,
		TxID:      "same-txid",
		Vout:      0,
		Data:      []byte{0xa1, 0xa1, 0xa1, 0xa1},
		CreatedAt: &syncTime,
	}}))
	require.NoError(t, Persist(ctx, db, []OPReturn{{
		Height:    &height,
		TxID:      "same-txid",
		Vout:      0,
		Data:      []byte{0xa1, 0xa1, 0xa1, 0xa1},
		CreatedAt: &blockTime,
	}}))

	var gotCreatedAt time.Time
	var gotHeight sql.NullInt64
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT created_at, height FROM op_returns WHERE txid = ? AND vout = ?`,
		"same-txid", 0,
	).Scan(&gotCreatedAt, &gotHeight))
	assert.WithinDuration(t, blockTime, gotCreatedAt, time.Second)
	require.True(t, gotHeight.Valid)
	assert.Equal(t, int64(height), gotHeight.Int64)

	require.NoError(t, Persist(ctx, db, []OPReturn{{
		Height:    nil,
		TxID:      "same-txid",
		Vout:      0,
		Data:      []byte{0xa1, 0xa1, 0xa1, 0xa1},
		CreatedAt: &laterMempoolTime,
	}}))

	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT created_at, height FROM op_returns WHERE txid = ? AND vout = ?`,
		"same-txid", 0,
	).Scan(&gotCreatedAt, &gotHeight))
	assert.WithinDuration(t, blockTime, gotCreatedAt, time.Second)
	require.True(t, gotHeight.Valid)
	assert.Equal(t, int64(height), gotHeight.Int64)
}

func TestOPReturnToReadable(t *testing.T) {
	cases := []struct {
		name string
		in   []byte
		want string
	}{
		{name: "hex of printable text", in: []byte(hex.EncodeToString([]byte("hello"))), want: "hello"},
		{name: "printable text", in: []byte("hello world"), want: "hello world"},
		{name: "binary", in: []byte{0x00, 0xff}, want: "00ff"},
		{name: "non-ASCII text", in: []byte("blåbær"), want: hex.EncodeToString([]byte("blåbær"))},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, OPReturnToReadable(tc.in))
		})
	}
}

func TestGetByTxID(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	now := time.Now()
	require.NoError(t, Persist(t.Context(), db, []OPReturn{
		{TxID: "tx-a", Vout: 1, Data: []byte("second"), CreatedAt: &now},
		{TxID: "tx-a", Vout: 0, Data: []byte("first"), CreatedAt: &now},
		{TxID: "tx-b", Vout: 0, Data: []byte("other"), CreatedAt: &now},
	}))

	t.Run("gives the lowest vout", func(t *testing.T) {
		got, err := GetByTxID(t.Context(), db, "tx-a")
		require.NoError(t, err)
		require.NotNil(t, got)
		assert.Equal(t, "tx-a", got.TxID)
		assert.Equal(t, int32(0), got.Vout)
		assert.Equal(t, []byte("first"), got.Data)
	})

	t.Run("gives nil for an unknown txid", func(t *testing.T) {
		got, err := GetByTxID(t.Context(), db, "tx-missing")
		require.NoError(t, err)
		assert.Nil(t, got)
	})
}
