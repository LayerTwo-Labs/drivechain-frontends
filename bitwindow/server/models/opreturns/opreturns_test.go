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
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func mustTopicID(t *testing.T, hex string) TopicID {
	t.Helper()
	id, err := ValidNewsTopicID(hex)
	require.NoError(t, err)
	return id
}

func seedTopicAndNews(t *testing.T, topic TopicID, topicName, headline, content string) *sql.DB {
	t.Helper()
	ctx := context.Background()
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

func seedVote(
	t *testing.T, ctx context.Context, db *sql.DB,
	target codec.ItemID, kind codec.TypeTag, authorSeed byte, height uint32,
) {
	t.Helper()
	var xpk codec.XOnlyPubKey
	for i := range xpk {
		xpk[i] = authorSeed
	}
	require.NoError(t, cnstore.Index(ctx, db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: height,
			TxIndex:     0,
			VoutIndex:   0,
			BlockTime:   time.Now(),
			TxID:        fmt.Sprintf("%064x", height),
		},
		TypeTag: kind,
		Msg:     &codec.Vote{Kind: kind, Target: target, AuthorXPK: xpk},
	}))
}

// TestListCoinNews_SurfacesStoryTLVs proves a Story's url/subtype/nsfw
// TLVs (spec §10) round-trip through ListCoinNews.
func TestListCoinNews_SurfacesStoryTLVs(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
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
	ctx := context.Background()
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
	assert.Equal(t, longBody, news[0].Content, "continuation chunks reassemble into the full body")
}

// TestListCoinNews_RanksByScoreAndCountsDownvotes proves spec §13: the
// feed is ordered by HN score, and downvotes (kind=5) are tallied.
func TestListCoinNews_RanksByScoreAndCountsDownvotes(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	topic := mustTopicID(t, "a1a1a1a1")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)
	now := time.Now()
	seedCurrentNews(t, ctx, db, topic, "Upvoted", "", "storyA", 0, 100, now)
	seedCurrentNews(t, ctx, db, topic, "Downvoted", "", "storyB", 0, 100, now)

	itemIDs := map[string]codec.ItemID{}
	rows, err := db.QueryContext(ctx, `SELECT headline, item_id FROM cn_stories`)
	require.NoError(t, err)
	for rows.Next() {
		var headline string
		var id []byte
		require.NoError(t, rows.Scan(&headline, &id))
		var item codec.ItemID
		copy(item[:], id)
		itemIDs[headline] = item
	}
	require.NoError(t, rows.Close())

	seedVote(t, ctx, db, itemIDs["Upvoted"], codec.TypeUpvote, 0x10, 200)
	seedVote(t, ctx, db, itemIDs["Upvoted"], codec.TypeUpvote, 0x11, 201)
	seedVote(t, ctx, db, itemIDs["Upvoted"], codec.TypeUpvote, 0x12, 202)
	seedVote(t, ctx, db, itemIDs["Downvoted"], codec.TypeDownvote, 0x20, 203)
	seedVote(t, ctx, db, itemIDs["Downvoted"], codec.TypeDownvote, 0x21, 204)

	news, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 2)
	assert.Equal(t, "Upvoted", news[0].Headline, "higher-scored story ranks first")
	assert.Equal(t, int64(3), news[0].Upvotes)
	assert.Equal(t, "Downvoted", news[1].Headline)
	assert.Equal(t, int64(2), news[1].Downvotes)
	assert.Greater(t, news[0].Score, news[1].Score)
}

// TestListCoinNews_CountsUpvotes proves upvotes (kind=4) are tallied per
// story while downvotes are excluded, and the story's ItemID round-trips
// to the hex column the UI votes against.
func TestListCoinNews_CountsUpvotes(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	topic := mustTopicID(t, "a1a1a1a1")
	db := database.Test(t)
	seedCurrentTopic(t, ctx, db, topic, "Topic", 0, 99)
	seedCurrentNews(t, ctx, db, topic, "Headline", "body", "story1", 0, 100, time.Now())

	var itemID []byte
	require.NoError(t, db.QueryRowContext(ctx, `SELECT item_id FROM cn_stories`).Scan(&itemID))
	var target codec.ItemID
	copy(target[:], itemID)

	seedVote(t, ctx, db, target, codec.TypeUpvote, 0xaa, 200)
	seedVote(t, ctx, db, target, codec.TypeUpvote, 0xbb, 201)
	seedVote(t, ctx, db, target, codec.TypeDownvote, 0xcc, 202) // must not count

	news, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, int64(2), news[0].Upvotes)
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

// TestEncodeNewsMessage_Layout pins the on-wire byte layout so a future
// refactor can't silently shift the headline slice and blank out the
// UI column.
func TestEncodeNewsMessage_Layout(t *testing.T) {
	topic := mustTopicID(t, "a1a1a1a1")
	headline := "Hello"
	content := "body"

	data := EncodeNewsMessage(topic, headline, content)
	require.Len(t, data, TopicIdLength+64+len(content),
		"wire format must be <4 topic><64 headline><N content>")
	assert.Equal(t, topic[:], data[:TopicIdLength])
	assert.Equal(t, []byte(headline), data[TopicIdLength:TopicIdLength+len(headline)])
	// Padding must be NULL bytes — not spaces — because decoders trim
	// trailing \x00 explicitly.
	for i := TopicIdLength + len(headline); i < TopicIdLength+64; i++ {
		assert.Equal(t, byte(0), data[i], "expected NULL padding at byte %d", i)
	}
	assert.Equal(t, []byte(content), data[TopicIdLength+64:])
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

			news, err := ListCoinNews(context.Background(), db)
			require.NoError(t, err)
			require.Len(t, news, 1, "expected one news row for headline %q", tc.headline)
			assert.Equal(t, tc.headline, news[0].Headline,
				"round-trip must preserve the original headline bytes")
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

	news, err := ListCoinNews(context.Background(), db)
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

	news, err := ListCoinNews(context.Background(), db)
	require.NoError(t, err)
	require.Len(t, news, 1, "news message with 'new'-prefixed headline must not be dropped as a topic-creation")
	assert.Equal(t, headline, news[0].Headline)
}

// TestListCoinNews_WhitespaceOnlyHeadline documents the defensive read
// filter: current broadcasts reject these, and the legacy adapter
// avoids inserting them, but a hand-written canonical row still must
// not render as a blank title.
func TestListCoinNews_WhitespaceOnlyHeadline(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	db := seedTopicAndNews(t, topic, "Test Topic", "   ", "body")

	news, err := ListCoinNews(context.Background(), db)
	require.NoError(t, err)
	assert.Empty(t, news)
}

// TestListCoinNews_EmptyHeadline mirrors the above for empty headline
// rows. They are invalid for normal broadcasts and hidden on read.
func TestListCoinNews_EmptyHeadline(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	db := seedTopicAndNews(t, topic, "Test Topic", "", "body")

	news, err := ListCoinNews(context.Background(), db)
	require.NoError(t, err)
	assert.Empty(t, news)
}

// TestListCoinNews_ShortHeadline keeps the reader honest for a compact
// current-format Story.
func TestListCoinNews_ShortMessageBelowHeadlineEnd(t *testing.T) {
	topic := mustTopicID(t, "deadbeef")
	db := seedTopicAndNews(t, topic, "Test Topic", "short!!!", "")

	news, err := ListCoinNews(context.Background(), db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, "short!!!", news[0].Headline)
}

// TestIsCreateTopic_RejectsNewsMessage makes sure the topic classifier
// doesn't false-positive on a standard news message. The 64-byte
// NULL-padded headline slot means a news message with any headline
// shorter than 64 bytes always has NULLs in the headline region —
// which the classifier now treats as the news signal.
func TestIsCreateTopic_RejectsNewsMessage(t *testing.T) {
	topic := mustTopicID(t, "a1a1a1a1")
	headlines := []string{
		"Hello",
		"",
		"   ",
		"news flash",
		"new coin launched",
		"newly launched protocol",
	}
	for _, h := range headlines {
		t.Run(h, func(t *testing.T) {
			data := EncodeNewsMessage(topic, h, "content")
			_, isTopic := IsCreateTopic(data)
			assert.False(t, isTopic, "news must not be classified as topic creation (headline=%q)", h)
		})
	}
}

// TestIsCreateTopic_RecognizesRealTopicCreation is the positive twin
// of the above: real topic-creation OP_RETURNs must still be picked up.
func TestIsCreateTopic_RecognizesRealTopicCreation(t *testing.T) {
	topic := mustTopicID(t, "cafebabe")
	data := EncodeTopicCreationMessage(topic, "Test Topic Name", 14)

	info, ok := IsCreateTopic(data)
	require.True(t, ok)
	assert.Equal(t, topic, info.ID)
	assert.Equal(t, "Test Topic Name", info.Name)
	assert.Equal(t, int32(14), info.RetentionDays)
}

// TestListCoinNews_NewPrefixedHeadlineSurvivesDecode locks in the
// classifier fix: a 'new'-prefixed headline round-trips through
// ListCoinNews instead of being dropped as a misclassified topic
// creation.
func TestListCoinNews_NewPrefixedHeadlineSurvivesDecode(t *testing.T) {
	topic := mustTopicID(t, "a1a1a1a1")
	headline := "new partnership announced"
	db := seedTopicAndNews(t, topic, "US Weekly", headline, "body")

	news, err := ListCoinNews(context.Background(), db)
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
	ctx := context.Background()
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

	assert.WithinDuration(t, blockTime, got("confirmed"), time.Second,
		"confirmed row with matching processed_blocks must adopt block_time")
	assert.WithinDuration(t, syncTime, got("orphan"), time.Second,
		"row without a matching processed_blocks entry must be left alone")
	assert.WithinDuration(t, syncTime, got("mempool"), time.Second,
		"mempool row (NULL height) must be left alone")
}

func TestPersistConfirmedConflictUpdatesCreateTimeToBlockTime(t *testing.T) {
	ctx := context.Background()
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
	assert.WithinDuration(t, blockTime, gotCreatedAt, time.Second,
		"confirmed conflict must adopt the timestamp extracted from the block")
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
	assert.WithinDuration(t, blockTime, gotCreatedAt, time.Second,
		"mempool replay must not overwrite a confirmed block timestamp")
	require.True(t, gotHeight.Valid)
	assert.Equal(t, int64(height), gotHeight.Int64)
}
