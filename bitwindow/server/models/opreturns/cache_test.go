package opreturns

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// List(..., limit) must cap rows at the requested limit.
func TestList_LimitCaps(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	const total = 50
	const limit = 10
	rows := make([]OPReturn, 0, total)
	for i := 0; i < total; i++ {
		h := uint32(i + 1)
		now := time.Now().Add(time.Duration(i) * time.Millisecond)
		rows = append(rows, OPReturn{
			Height:    &h,
			TxID:      fmt.Sprintf("tx-%d", i),
			Vout:      0,
			Data:      []byte("payload"),
			CreatedAt: &now,
		})
	}
	require.NoError(t, Persist(ctx, db, rows))

	got, err := List(ctx, db, limit)
	require.NoError(t, err)
	assert.Len(t, got, limit)
}

// List(..., 0) is the explicit "full table" escape hatch (bitdrive).
func TestList_LimitZeroIsUnbounded(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	const n = 50
	rows := make([]OPReturn, 0, n)
	for i := 0; i < n; i++ {
		h := uint32(i + 1)
		now := time.Now().Add(time.Duration(i) * time.Millisecond)
		rows = append(rows, OPReturn{
			Height:    &h,
			TxID:      fmt.Sprintf("tx-%d", i),
			Vout:      0,
			Data:      []byte("payload"),
			CreatedAt: &now,
		})
	}
	require.NoError(t, Persist(ctx, db, rows))

	got, err := List(ctx, db, 0)
	require.NoError(t, err)
	assert.Len(t, got, n)
}

// Closing the DB after the first call proves the second read is served
// purely from cache (a real query would fail).
func TestListCache_HitAfterMiss(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	h := uint32(1)
	now := time.Now()
	require.NoError(t, Persist(ctx, db, []OPReturn{{
		Height: &h, TxID: "tx", Vout: 0, Data: []byte("hi"), CreatedAt: &now,
	}}))

	first, err := List(ctx, db, 100)
	require.NoError(t, err)
	require.Len(t, first, 1)

	require.NoError(t, db.Close())

	// If the cache wasn't honored, this would error with "sql: database is closed".
	second, err := List(ctx, db, 100)
	require.NoError(t, err, "second call must hit the cache, not the closed DB")
	assert.Equal(t, first, second)
}

// Persist must drop the cache so the next read sees the new row.
func TestListCache_InvalidatedByPersist(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	first, err := List(ctx, db, 100)
	require.NoError(t, err)
	require.Empty(t, first, "fresh DB must list empty")

	h := uint32(1)
	now := time.Now()
	require.NoError(t, Persist(ctx, db, []OPReturn{{
		Height: &h, TxID: "tx", Vout: 0, Data: []byte("hi"), CreatedAt: &now,
	}}))

	second, err := List(ctx, db, 100)
	require.NoError(t, err)
	assert.Len(t, second, 1, "Persist must invalidate the cached empty result")
}

// Cache must not bleed entries across DBs.
func TestListCache_PerDBIsolation(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	dbA := database.Test(t)
	dbB := database.Test(t)

	h := uint32(1)
	now := time.Now()
	require.NoError(t, Persist(ctx, dbA, []OPReturn{{
		Height: &h, TxID: "in-a", Vout: 0, Data: []byte("a"), CreatedAt: &now,
	}}))

	gotA, err := List(ctx, dbA, 100)
	require.NoError(t, err)
	require.Len(t, gotA, 1)

	gotB, err := List(ctx, dbB, 100)
	require.NoError(t, err)
	assert.Empty(t, gotB, "dbB must not see dbA's rows via shared cache")
}

// ListCoinNews reads from the canonical CoinNews tables, not raw
// op_returns rows.
func TestListCoinNews_ReadsCanonicalStories(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topic := mustTopicID(t, "a1a1a1a1")
	seedCurrentTopic(t, ctx, db, topic, "Known", 0, 1)
	seedCurrentNews(t, ctx, db, topic, "headline", "body", "matching", 0, 2, time.Now())

	got, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, got, 1)
	assert.Equal(t, "headline", got[0].Headline)
	assert.Equal(t, "body", got[0].Content)
	assert.Equal(t, "Known", got[0].TopicName)
}

// Per-topic retention is applied at SQL time; rows past the cutoff drop.
func TestListCoinNews_RetentionFilteredAtSQL(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topic := mustTopicID(t, "b2b2b2b2")
	// 7-day retention.
	seedCurrentTopic(t, ctx, db, topic, "Weekly", 7, 1)

	old := time.Now().AddDate(0, 0, -30) // way past the 7-day cutoff
	fresh := time.Now()
	seedCurrentNews(t, ctx, db, topic, "stale", "stale", "old-news", 0, 2, old)
	seedCurrentNews(t, ctx, db, topic, "fresh", "fresh", "fresh-news", 1, 3, fresh)

	got, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, got, 1)
	assert.Equal(t, "fresh", got[0].Headline)
}

// A caller mutating the returned slice must not corrupt the cache.
func TestList_CallerCannotPoisonCache(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	h := uint32(1)
	now := time.Now()
	require.NoError(t, Persist(ctx, db, []OPReturn{{
		Height: &h, TxID: "real", Vout: 0, Data: []byte("real"), CreatedAt: &now,
	}}))

	first, err := List(ctx, db, 100)
	require.NoError(t, err)
	require.Len(t, first, 1)

	// Mutate the returned slice — clobber the row, then append junk.
	first[0] = OPReturn{TxID: "POISONED"}
	_ = append(first, OPReturn{TxID: "EXTRA"})

	second, err := List(ctx, db, 100)
	require.NoError(t, err)
	require.Len(t, second, 1, "cache must not absorb caller's append")
	assert.Equal(t, "real", second[0].TxID, "cache must not absorb caller's mutation")
}

// Same mutation guard for the ListCoinNews path.
func TestListCoinNews_CallerCannotPoisonCache(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topic := mustTopicID(t, "d4d4d4d4")
	seedCurrentTopic(t, ctx, db, topic, "T", 0, 1)
	seedCurrentNews(t, ctx, db, topic, "real-headline", "real-body", "tx", 0, 2, time.Now())

	first, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, first, 1)

	first[0] = CoinNews{Headline: "POISONED"}
	_ = append(first, CoinNews{Headline: "EXTRA"})

	second, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, second, 1)
	assert.Equal(t, "real-headline", second[0].Headline)
}

// Topic creations live in cn_topics, not cn_stories, so they never
// surface as articles.
func TestListCoinNews_TopicCreationRowFiltered(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topic := mustTopicID(t, "e5e5e5e5")
	seedCurrentTopic(t, ctx, db, topic, "T", 0, 1)
	seedCurrentNews(t, ctx, db, topic, "real", "real", "news-row", 1, 2, time.Now())

	got, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, got, 1, "topic-creation row must not surface as news")
	assert.Equal(t, "real", got[0].Headline)
}

// retention_days = 0 means "keep forever" — even years-old rows must
// come back. The SQL WHERE clause uses an OR for this case; if it
// regressed to a strict cutoff the row would silently drop.
func TestListCoinNews_ZeroRetentionKeepsForever(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topic := mustTopicID(t, "f6f6f6f6")
	seedCurrentTopic(t, ctx, db, topic, "Forever", 0, 1)

	ancient := time.Now().AddDate(-5, 0, 0)
	seedCurrentNews(t, ctx, db, topic, "old", "old", "ancient", 0, 2, ancient)

	got, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, got, 1, "retention_days=0 must keep ancient rows")
	assert.Equal(t, "old", got[0].Headline)
}

// Junk rows where headline is blank-or-padding-only must not surface.
func TestListCoinNews_EmptyPayloadFiltered(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topic := mustTopicID(t, "07070707")
	seedCurrentTopic(t, ctx, db, topic, "T", 0, 1)
	seedCurrentNews(t, ctx, db, topic, "", "", "junk", 0, 2, time.Now())
	seedCurrentNews(t, ctx, db, topic, "real", "real", "real", 1, 3, time.Now())

	got, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, got, 1, "empty-payload row must not surface")
	assert.Equal(t, "real", got[0].Headline)
}

// Multi-topic, multi-row check that the JOIN populates TopicName
// correctly per row (rather than e.g. carrying over the previous row's
// topic). Catches a class of JOIN-mapping bug.
func TestListCoinNews_TopicNameMatchesEachRow(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	topicA := mustTopicID(t, "aaaaaaaa")
	topicB := mustTopicID(t, "bbbbbbbb")
	seedCurrentTopic(t, ctx, db, topicA, "A name", 0, 1)
	seedCurrentTopic(t, ctx, db, topicB, "B name", 0, 2)

	seedCurrentNews(t, ctx, db, topicA, "ha", "ba", "txA", 0, 3, time.Now())
	seedCurrentNews(t, ctx, db, topicB, "hb", "bb", "txB", 1, 4, time.Now())

	got, err := ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, got, 2)
	byHeadline := map[string]CoinNews{}
	for _, n := range got {
		byHeadline[n.Headline] = n
	}
	assert.Equal(t, "A name", byHeadline["ha"].TopicName)
	assert.Equal(t, "B name", byHeadline["hb"].TopicName)
	assert.Equal(t, topicA, byHeadline["ha"].Topic)
	assert.Equal(t, topicB, byHeadline["hb"].Topic)
}
