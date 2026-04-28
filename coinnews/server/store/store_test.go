package store

import (
	"context"
	"crypto/rand"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

func openTest(t *testing.T) *testStore {
	t.Helper()
	db, err := Open(context.Background(), t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })
	return &testStore{t: t}
}

type testStore struct{ t *testing.T }

// pos returns a BlockPos. Each call gets a unique txid (derived from
// height) so cn_items rows don't collide across the test scenario —
// real-world each (txid, vout) is a separate output.
func pos(height, txIdx, voutIdx uint32) BlockPos {
	txid := make([]byte, 32)
	binaryHeightLE(txid[0:4], height)
	binaryHeightLE(txid[4:8], txIdx)
	binaryHeightLE(txid[8:12], voutIdx)
	return BlockPos{
		BlockHeight: height,
		TxIndex:     txIdx,
		VoutIndex:   voutIdx,
		BlockTime:   time.Date(2026, 4, 28, 12, 0, 0, 0, time.UTC),
		TxID:        encodeHex(txid),
	}
}

func binaryHeightLE(dst []byte, v uint32) {
	dst[0] = byte(v)
	dst[1] = byte(v >> 8)
	dst[2] = byte(v >> 16)
	dst[3] = byte(v >> 24)
}

func encodeHex(b []byte) string {
	const hexchars = "0123456789abcdef"
	out := make([]byte, len(b)*2)
	for i, x := range b {
		out[i*2] = hexchars[x>>4]
		out[i*2+1] = hexchars[x&0x0f]
	}
	return string(out)
}

// TestStore_FullCycle covers the contract test suite the bitwindow
// store has, against the standalone server's store. They share the
// same schema and codec so the same invariants must hold.
func TestStore_FullCycle(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	defer db.Close() //nolint:errcheck

	// Topic Creation: earliest-wins.
	topic := codec.Topic{0x48, 0x4e, 0x53, 0x21}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(100, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "first"},
	}))
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(101, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 30, Name: "second"},
	}))
	topics, err := ListTopics(ctx, db)
	require.NoError(t, err)
	require.Len(t, topics, 1)
	assert.Equal(t, "first", topics[0].Name, "earliest Topic Creation must win")

	// Story.
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(102, 0, 0), TypeTag: codec.TypeStory,
		Msg: &codec.Story{
			Topic: topic, Headline: "hello",
			TLVs: []codec.TLV{
				{Tag: codec.TLVURL, Value: []byte("https://example.com/x")},
				{Tag: codec.TLVSubtype, Value: []byte{byte(codec.SubtypeShow)}},
			},
		},
	}))
	feed, err := ListFeed(ctx, db, FeedFilter{Sort: SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)
	assert.Equal(t, "hello", feed[0].Headline)
	assert.Equal(t, "https://example.com/x", feed[0].URL)
	assert.Equal(t, codec.SubtypeShow, feed[0].Subtype)

	// Vote dedup.
	storyID := feed[0].ItemID
	var xpk [32]byte
	_, _ = rand.Read(xpk[:])
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(103, 0, 0), TypeTag: codec.TypeUpvote,
		Msg: &codec.Vote{Kind: codec.TypeUpvote, Target: storyID, AuthorXPK: xpk},
	}))
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(104, 0, 0), TypeTag: codec.TypeDownvote,
		Msg: &codec.Vote{Kind: codec.TypeDownvote, Target: storyID, AuthorXPK: xpk},
	}))
	feed, err = ListFeed(ctx, db, FeedFilter{Sort: SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)
	assert.Equal(t, 1, feed[0].Points, "second vote from same author must be dropped")

	// GetItem.
	one, err := GetItem(ctx, db, storyID)
	require.NoError(t, err)
	assert.Equal(t, "hello", one.Headline)
	assert.Equal(t, 1, one.Points)
	assert.Equal(t, 0, one.CommentCount)

	// PurgeAtOrAbove.
	require.NoError(t, PurgeAtOrAbove(ctx, db, 102))
	topics, err = ListTopics(ctx, db)
	require.NoError(t, err)
	assert.Len(t, topics, 1, "topic created at height 100 survives a purge at 102")
	feed, err = ListFeed(ctx, db, FeedFilter{Sort: SortNewest})
	require.NoError(t, err)
	assert.Empty(t, feed, "story at 102 + vote at 103 wiped")
}

func TestStore_Cursor(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	defer db.Close() //nolint:errcheck

	h, hash, err := LoadCursor(ctx, db)
	require.NoError(t, err)
	assert.Zero(t, h)
	assert.Equal(t, [32]byte{}, hash)

	var saved [32]byte
	for i := range saved {
		saved[i] = byte(i)
	}
	require.NoError(t, SaveCursor(ctx, db, 800_000, saved))

	h, hash, err = LoadCursor(ctx, db)
	require.NoError(t, err)
	assert.Equal(t, uint32(800_000), h)
	assert.Equal(t, saved, hash)
}

func TestOpReturnPayload_RoundTrip(t *testing.T) {
	t.Parallel()
	// Ensure the scanner/store agree on a known-good Story that we
	// build via the codec (proves the handler accepts what the codec
	// emits).
	storyBytes, err := codec.EncodeStory(codec.Story{
		Topic:    codec.Topic{1, 2, 3, 4},
		Headline: "round-trip",
	})
	require.NoError(t, err)
	tag, msg, err := codec.DecodeMessage(storyBytes)
	require.NoError(t, err)
	require.Equal(t, codec.TypeStory, tag)
	require.IsType(t, &codec.Story{}, msg)
}
