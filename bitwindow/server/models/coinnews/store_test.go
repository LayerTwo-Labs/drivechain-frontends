package coinnews

import (
	"context"
	"crypto/rand"
	"database/sql"
	"fmt"
	"testing"
	"time"

	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

// pos returns a BlockPos seeded for tests. Callers tweak fields they
// care about (height, tx_index, vout_index) so per-test ordering is
// explicit.
func pos(height, txIdx, voutIdx uint32) BlockPos {
	return BlockPos{
		BlockHeight: height,
		TxIndex:     txIdx,
		VoutIndex:   voutIdx,
		BlockTime:   time.Date(2026, 4, 27, 12, 0, 0, 0, time.UTC),
		TxID:        "1111111111111111111111111111111111111111111111111111111111111111",
	}
}

// TestStore_ListThread builds a story → comment → reply chain and proves
// ListThread returns the full transitive thread rooted at the story.
func TestStore_ListThread(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 0), TypeTag: codec.TypeStory,
		Msg: &codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: "Head"},
	}))
	story := itemIDOf(t, ctx, db, "cn_stories")

	var a1, a2 codec.XOnlyPubKey
	_, _ = rand.Read(a1[:])
	_, _ = rand.Read(a2[:])

	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 1), TypeTag: codec.TypeComment,
		Msg: &codec.Comment{Parent: story, AuthorXPK: a1, TLVs: []codec.TLV{{Tag: codec.TLVBody, Value: []byte("first")}}},
	}))
	comment1 := itemIDOf(t, ctx, db, "cn_comments")

	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 2), TypeTag: codec.TypeComment,
		Msg: &codec.Comment{Parent: comment1, AuthorXPK: a2, TLVs: []codec.TLV{{Tag: codec.TLVBody, Value: []byte("reply")}}},
	}))

	thread, err := ListThread(ctx, db, story)
	require.NoError(t, err)
	require.Len(t, thread, 2)

	assert.True(t, lo.ContainsBy(thread, func(c Comment) bool { return c.Body == "first" }))
	assert.True(t, lo.ContainsBy(thread, func(c Comment) bool { return c.Body == "reply" }))
}

// TestStore_ListThread_RanksByFee proves the thread lists the highest fee first,
// and a comment without a known fee last.
func TestStore_ListThread_RanksByFee(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 0), TypeTag: codec.TypeStory,
		Msg: &codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: "Head"},
	}))
	story := itemIDOf(t, ctx, db, "cn_stories")

	var author codec.XOnlyPubKey
	_, _ = rand.Read(author[:])
	for i, body := range []string{"cheap", "dear", "unknown"} {
		require.NoError(t, Index(ctx, db, IndexEnv{
			Pos: pos(100, 0, uint32(i+1)), TypeTag: codec.TypeComment,
			Msg: &codec.Comment{Parent: story, AuthorXPK: author, TLVs: []codec.TLV{{Tag: codec.TLVBody, Value: []byte(body)}}},
		}))
	}
	for vout, fee := range map[int]int64{1: 500, 2: 2000} {
		_, err := db.ExecContext(ctx,
			`INSERT INTO op_returns (txid, vout, op_return_data, fee_sats) VALUES (?, ?, '', ?)`,
			pos(0, 0, 0).TxID, vout, fee)
		require.NoError(t, err)
	}

	thread, err := ListThread(ctx, db, story)
	require.NoError(t, err)
	require.Len(t, thread, 3)
	assert.Equal(t, []string{"dear", "cheap", "unknown"}, lo.Map(thread, func(c Comment, _ int) string { return c.Body }))
	assert.Equal(t, []int64{2000, 500, 0}, lo.Map(thread, func(c Comment, _ int) int64 { return c.FeeSats }))
}

// itemIDOf returns the most recently inserted item_id in the given cn_*
// table.
func itemIDOf(t *testing.T, ctx context.Context, db *sql.DB, table string) codec.ItemID {
	t.Helper()
	var id []byte
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT item_id FROM `+table+` ORDER BY rowid DESC LIMIT 1`).Scan(&id))
	var item codec.ItemID
	copy(item[:], id)
	return item
}

// TestStore_TopicCreation_EarliestWins guards spec §5: when two
// creations race for the same TopicID, only the first confirmed one
// keeps the name. The second insert is silently ignored — exactly
// what `INSERT OR IGNORE` against the PRIMARY KEY gives us.
func TestStore_TopicCreation_EarliestWins(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	first := &codec.TopicCreation{
		Topic:         codec.Topic{0xa1, 0xa2, 0xa3, 0xa4},
		RetentionDays: 7,
		Name:          "First Wins",
	}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 0), TypeTag: codec.TypeTopicCreation, Msg: first,
	}))

	second := &codec.TopicCreation{
		Topic:         codec.Topic{0xa1, 0xa2, 0xa3, 0xa4}, // same TopicID
		RetentionDays: 30,
		Name:          "Second Loses",
	}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(101, 0, 0), TypeTag: codec.TypeTopicCreation, Msg: second,
	}))

	var name string
	var ret int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT name, retention_days FROM cn_topics WHERE topic = ?`,
		first.Topic[:],
	).Scan(&name, &ret))
	assert.Equal(t, "First Wins", name)
	assert.Equal(t, 7, ret)
}

// TestStore_Story_HoistsCommonTLVs proves the TLV-to-column extraction:
// a Story carrying url/body/lang/nsfw/subtype lands them in their hot
// columns AND keeps a verbatim copy in raw_tlv (so future schema
// upgrades can re-derive new fields without a chain rescan).
func TestStore_Story_HoistsCommonTLVs(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	// Topic must exist in cn_topics first; while the spec doesn't
	// mandate this for Stories (only for indexer presentation), we
	// register it so a UI rendering the row can resolve the topic.
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(50, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: codec.Topic{1, 2, 3, 4}, Name: "T", RetentionDays: 7},
	}))

	story := &codec.Story{
		Topic:    codec.Topic{1, 2, 3, 4},
		Headline: "the headline",
		TLVs: []codec.TLV{
			{Tag: codec.TLVURL, Value: []byte("https://example.com/a")},
			{Tag: codec.TLVBody, Value: []byte("the body text")},
			{Tag: codec.TLVLang, Value: []byte("en")},
			{Tag: codec.TLVNSFW, Value: []byte{0x01}},
			{Tag: codec.TLVSubtype, Value: []byte{byte(codec.SubtypeShow)}},
		},
	}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 0), TypeTag: codec.TypeStory, Msg: story,
	}))

	// Compute the ItemID we expect.
	var txid [32]byte
	for i := range txid {
		txid[31-i] = 0x11 // mirror reversed→natural step
	}
	id := codec.ComputeItemID(txid, 0)

	var (
		headline, url, body, lang string
		subtype                   int
		nsfw                      bool
		mediaHash                 []byte
		rawTLV                    []byte
	)
	require.NoError(t, db.QueryRowContext(ctx, `
		SELECT headline, COALESCE(url, ''), COALESCE(body, ''), COALESCE(lang, ''),
		       subtype, nsfw, COALESCE(media_hash, X''), raw_tlv
		FROM cn_stories WHERE item_id = ?
	`, id[:]).Scan(&headline, &url, &body, &lang, &subtype, &nsfw, &mediaHash, &rawTLV))

	assert.Equal(t, "the headline", headline)
	assert.Equal(t, "https://example.com/a", url)
	assert.Equal(t, "the body text", body)
	assert.Equal(t, "en", lang)
	assert.Equal(t, int(codec.SubtypeShow), subtype)
	assert.True(t, nsfw)
	assert.Empty(t, mediaHash)

	// raw_tlv preserves the full payload for schema upgrades.
	expectedRaw, err := codec.SerialiseTLVs(story.TLVs)
	require.NoError(t, err)
	assert.Equal(t, expectedRaw, rawTLV)
}

// TestStore_Comment_PersistsAllExtractedFields hoists each TLV onto
// its own column and keeps the raw blob. Acceptance test for a thread-
// rendering query that fetches a comment by item_id.
func TestStore_Comment_PersistsAllExtractedFields(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	var parent codec.ItemID
	_, _ = rand.Read(parent[:])
	var xpk codec.XOnlyPubKey
	_, _ = rand.Read(xpk[:])

	comment := &codec.Comment{
		Parent:    parent,
		AuthorXPK: xpk,
		TLVs: []codec.TLV{
			{Tag: codec.TLVBody, Value: []byte("body text")},
			{Tag: codec.TLVURL, Value: []byte("https://reply.example/x")},
			{Tag: codec.TLVLang, Value: []byte("en")},
			{Tag: codec.TLVReplyQuote, Value: []byte("> the parent's words")},
		},
	}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(200, 1, 0), TypeTag: codec.TypeComment, Msg: comment,
	}))

	// Recompute ItemID for the comment.
	var txid [32]byte
	for i := range txid {
		txid[31-i] = 0x11
	}
	id := codec.ComputeItemID(txid, 0)

	var body, url, lang, replyQuote string
	require.NoError(t, db.QueryRowContext(ctx, `
		SELECT COALESCE(body, ''), COALESCE(url, ''), COALESCE(lang, ''), COALESCE(reply_quote, '')
		FROM cn_comments WHERE item_id = ?
	`, id[:]).Scan(&body, &url, &lang, &replyQuote))
	assert.Equal(t, "body text", body)
	assert.Equal(t, "https://reply.example/x", url)
	assert.Equal(t, "en", lang)
	assert.Equal(t, "> the parent's words", replyQuote)
}

// TestStore_Continuation_StoresChunksByHeadAndSeq locks down the
// (head_id, seq) PRIMARY KEY: inserting two chunks at the same seq
// for the same head MUST leave the original chunk in place.
func TestStore_Continuation_StoresChunksByHeadAndSeq(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	var head codec.ItemID
	_, _ = rand.Read(head[:])

	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(300, 0, 1), TypeTag: codec.TypeContinuation,
		Msg: &codec.Continuation{Head: head, Seq: 0, Chunk: []byte("chunk-zero")},
	}))
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(300, 0, 2), TypeTag: codec.TypeContinuation,
		Msg: &codec.Continuation{Head: head, Seq: 1, Chunk: []byte("chunk-one")},
	}))
	// Re-insert seq 0 with different bytes — must be ignored.
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(301, 0, 0), TypeTag: codec.TypeContinuation,
		Msg: &codec.Continuation{Head: head, Seq: 0, Chunk: []byte("REPLAY")},
	}))

	var rowCount int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM cn_continuations WHERE head_id = ?`, head[:]).Scan(&rowCount))
	assert.Equal(t, 2, rowCount)

	var chunk0 []byte
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT chunk FROM cn_continuations WHERE head_id = ? AND seq = 0`, head[:]).Scan(&chunk0))
	assert.Equal(t, []byte("chunk-zero"), chunk0)
}

// TestStore_Item_RegistersTxidVoutWithCanonicalOrder asserts that
// every non-Topic insert ALSO registers a row in cn_items with the
// canonical (height, tx_index, vout_index) triple — that's the index
// every feed query depends on for stable ordering across indexers.
func TestStore_Item_RegistersTxidVoutWithCanonicalOrder(t *testing.T) {
	t.Parallel()
	ctx := t.Context()
	db := database.Test(t)

	story := &codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: "h"}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos:     BlockPos{BlockHeight: 9, TxIndex: 3, VoutIndex: 2, BlockTime: time.Now().UTC(), TxID: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"},
		TypeTag: codec.TypeStory,
		Msg:     story,
	}))

	var (
		gotTxid               string
		gotVout               int
		gotHeight             int
		gotTxIndex, gotVoutIx int
		gotType               int
	)
	require.NoError(t, db.QueryRowContext(ctx, `
		SELECT txid, vout, block_height, tx_index, vout_index, type_tag
		FROM cn_items LIMIT 1
	`).Scan(&gotTxid, &gotVout, &gotHeight, &gotTxIndex, &gotVoutIx, &gotType))

	assert.Equal(t, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", gotTxid)
	assert.Equal(t, 2, gotVout)
	assert.Equal(t, 9, gotHeight)
	assert.Equal(t, 3, gotTxIndex)
	assert.Equal(t, 2, gotVoutIx)
	assert.Equal(t, int(codec.TypeStory), gotType)
}

func TestStore_Item_RejectsBadTxid(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	cases := []struct {
		name    string
		txid    string
		wantErr string
	}{
		{name: "not hex", txid: "zz", wantErr: "decode txid"},
		{name: "short", txid: "0123", wantErr: `txid "0123" is 2 bytes, want 32`},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			err := Index(t.Context(), db, IndexEnv{
				Pos:     BlockPos{BlockHeight: 9, BlockTime: time.Now().UTC(), TxID: tc.txid},
				TypeTag: codec.TypeStory,
				Msg:     &codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: "h"},
			})
			require.ErrorContains(t, err, tc.wantErr)
		})
	}
}

func TestCountStoriesSince(t *testing.T) {
	t.Parallel()
	db := database.Test(t)
	now := time.Now()

	story := func(height uint32, blockTime time.Time, headline string) IndexEnv {
		p := pos(height, 0, 0)
		p.BlockTime = blockTime
		p.TxID = fmt.Sprintf("%064x", height)
		return IndexEnv{Pos: p, TypeTag: codec.TypeStory, Msg: &codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: headline}}
	}
	require.NoError(t, Index(t.Context(), db, story(1, now.Add(-8*24*time.Hour), "Old")))
	require.NoError(t, Index(t.Context(), db, story(2, now.Add(-time.Hour), "New")))
	require.NoError(t, Index(t.Context(), db, story(3, now, "   ")))

	count, err := CountStoriesSince(t.Context(), db, now.Add(-7*24*time.Hour))
	require.NoError(t, err)
	require.Equal(t, int64(1), count)

	t.Run("compares across a time zone offset", func(t *testing.T) {
		db := database.Test(t)
		oslo := time.FixedZone("CEST", 2*60*60)
		at := time.Date(2026, 7, 1, 12, 0, 0, 0, time.UTC)
		require.NoError(t, Index(t.Context(), db, story(1, at.In(oslo), "Before")))
		require.NoError(t, Index(t.Context(), db, story(2, at.Add(time.Hour), "After")))

		count, err := CountStoriesSince(t.Context(), db, at.Add(30*time.Minute))
		require.NoError(t, err)
		assert.Equal(t, int64(1), count)

		count, err = CountStoriesSince(t.Context(), db, at.Add(30*time.Minute).In(oslo))
		require.NoError(t, err)
		assert.Equal(t, int64(1), count)
	})
}
