package scanner

import (
	"context"
	"database/sql"
	"encoding/hex"
	"fmt"
	"testing"
	"time"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

func TestParsePush_OpPushBytes(t *testing.T) {
	t.Parallel()
	// 0x05 (PUSH 5 bytes) followed by "hello"
	got, ok := parsePush([]byte{0x05, 'h', 'e', 'l', 'l', 'o'})
	require.True(t, ok)
	assert.Equal(t, []byte("hello"), got)
}

func TestParsePush_OpPushBytes_Truncated(t *testing.T) {
	t.Parallel()
	_, ok := parsePush([]byte{0x05, 'h', 'i'})
	assert.False(t, ok)
}

func TestParsePush_PushData1(t *testing.T) {
	t.Parallel()
	payload := make([]byte, 200)
	for i := range payload {
		payload[i] = byte(i)
	}
	b := append([]byte{0x4c, byte(len(payload))}, payload...)
	got, ok := parsePush(b)
	require.True(t, ok)
	assert.Equal(t, payload, got)
}

func TestParsePush_PushData2(t *testing.T) {
	t.Parallel()
	payload := make([]byte, 1000)
	for i := range payload {
		payload[i] = byte(i)
	}
	b := append([]byte{0x4d, byte(1000 & 0xff), byte(1000 >> 8)}, payload...)
	got, ok := parsePush(b)
	require.True(t, ok)
	assert.Equal(t, payload, got)
}

func TestParsePush_Empty(t *testing.T) {
	t.Parallel()
	_, ok := parsePush(nil)
	assert.False(t, ok)
}

func TestParsePush_UnsupportedOp(t *testing.T) {
	t.Parallel()
	_, ok := parsePush([]byte{0x4e}) // OP_PUSHDATA4 — we don't support it
	assert.False(t, ok)
}

func TestParsePush_TrailingPush(t *testing.T) {
	t.Parallel()
	// PUSH 5 "hello" followed by a second push — multi-push is not a payload.
	_, ok := parsePush([]byte{0x05, 'h', 'e', 'l', 'l', 'o', 0x01, 0x99})
	assert.False(t, ok)
}

func TestParsePush_PushData1_TrailingPush(t *testing.T) {
	t.Parallel()
	payload := make([]byte, 200)
	b := append([]byte{0x4c, byte(len(payload))}, payload...)
	_, ok := parsePush(append(b, 0x01, 0x99))
	assert.False(t, ok)
}

func TestParsePush_PushData2_TrailingPush(t *testing.T) {
	t.Parallel()
	payload := make([]byte, 1000)
	b := append([]byte{0x4d, byte(1000 & 0xff), byte(1000 >> 8)}, payload...)
	_, ok := parsePush(append(b, 0x01, 0x99))
	assert.False(t, ok)
}

func TestOpReturnPayload_NotNullData(t *testing.T) {
	t.Parallel()
	_, ok := opReturnPayload("6a05hello", "scripthash")
	assert.False(t, ok)
}

func TestOpReturnPayload_BadHex(t *testing.T) {
	t.Parallel()
	_, ok := opReturnPayload("zzzz", "nulldata")
	assert.False(t, ok)
}

func TestOpReturnPayload_NotOpReturn(t *testing.T) {
	t.Parallel()
	// Starts with something other than 0x6a
	_, ok := opReturnPayload("00010203", "nulldata")
	assert.False(t, ok)
}

func TestOpReturnPayload_OK(t *testing.T) {
	t.Parallel()
	// OP_RETURN OP_PUSHBYTES_5 "hello"
	script := append([]byte{0x6a, 0x05}, []byte("hello")...)
	got, ok := opReturnPayload(hex.EncodeToString(script), "nulldata")
	require.True(t, ok)
	assert.Equal(t, []byte("hello"), got)
}

// A real encoded story is accepted on its own, and rejected once a
// second push is appended — a multi-push script is not a payload.
func TestOpReturnPayload_Story_TrailingPush(t *testing.T) {
	t.Parallel()
	storyBytes, err := codec.EncodeStory(codec.Story{
		Topic:    codec.Topic{1, 2, 3, 4},
		Headline: "multi-push",
	})
	require.NoError(t, err)
	require.LessOrEqual(t, len(storyBytes), 0x4b)

	script := append([]byte{0x6a, byte(len(storyBytes))}, storyBytes...)
	got, ok := opReturnPayload(hex.EncodeToString(script), "nulldata")
	require.True(t, ok)
	assert.Equal(t, storyBytes, got)

	_, ok = opReturnPayload(hex.EncodeToString(append(script, 0x01, 0x99)), "nulldata")
	assert.False(t, ok)
}

func TestDecodeHashLE(t *testing.T) {
	t.Parallel()
	in := "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"
	got, err := decodeHashLE(in)
	require.NoError(t, err)
	assert.Equal(t, byte(0x01), got[0])
	assert.Equal(t, byte(0x20), got[31])

	_, err = decodeHashLE("notahash")
	assert.Error(t, err)
}

// indexPayload integration: a Story payload built via the codec must
// land in the store; an unknown blob must be silently dropped.
func TestIndexPayload_Story_GetsIndexed(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := store.Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	s := &Scanner{DB: db, Log: zerolog.Nop()}

	storyBytes, err := codec.EncodeStory(codec.Story{
		Topic:    codec.Topic{1, 2, 3, 4},
		Headline: "indexed via scanner",
	})
	require.NoError(t, err)

	pos := store.BlockPos{
		BlockHeight: 7,
		TxIndex:     0,
		VoutIndex:   0,
		BlockTime:   time.Date(2026, 4, 28, 12, 0, 0, 0, time.UTC),
		TxID:        "aa" + hexZero(62),
	}
	require.NoError(t, s.indexPayload(ctx, storyBytes, pos))

	feed, err := store.ListFeed(ctx, db, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)
	assert.Equal(t, "indexed via scanner", feed[0].Headline)
}

func TestIndexPayload_NotCoinNews_Drops(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := store.Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	s := &Scanner{DB: db, Log: zerolog.Nop()}

	pos := store.BlockPos{
		BlockHeight: 1,
		BlockTime:   time.Now().UTC(),
		TxID:        "bb" + hexZero(62),
	}
	require.NoError(t, s.indexPayload(ctx, []byte("not coinnews"), pos))

	feed, err := store.ListFeed(ctx, db, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	assert.Empty(t, feed)
}

// TestIndexPayload_DropsUnresolvableComment: a validly-signed Comment
// whose parent was never indexed MUST be dropped (spec §4.1, §7).
func TestIndexPayload_DropsUnresolvableComment(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, s := newScanner(t)

	var parent codec.ItemID
	parent[0] = 0xde // never indexed
	require.NoError(t, s.indexPayload(ctx, signedComment(t, parent), posAt(9, 0, 0)))

	assert.Zero(t, countRows(t, db, "cn_comments"), "comment with unresolvable parent MUST NOT persist")
	assert.Zero(t, countRows(t, db, "cn_items"), "no cn_items row for a dropped comment")
}

// TestIndexPayload_DropsUnresolvableVote: a validly-signed Vote against
// a target that was never indexed MUST be dropped (spec §4.1, §8).
func TestIndexPayload_DropsUnresolvableVote(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, s := newScanner(t)

	var target codec.ItemID
	target[0] = 0xad // never indexed
	require.NoError(t, s.indexPayload(ctx, signedVote(t, target), posAt(9, 0, 0)))

	assert.Zero(t, countRows(t, db, "cn_votes"), "vote against unresolvable target MUST NOT persist")
	assert.Zero(t, countRows(t, db, "cn_items"), "no cn_items row for a dropped vote")
}

// TestIndexPayload_DropsCommentOnLaterParent: a parent that exists but
// sits later in canonical scan order is not "earlier" (spec §4.2), so
// the Comment MUST be dropped.
func TestIndexPayload_DropsCommentOnLaterParent(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, s := newScanner(t)

	storyPos := posAt(20, 0, 0)
	require.NoError(t, s.indexPayload(ctx, story(t, "later story"), storyPos))

	// Comment sits in an earlier block than the story it replies to.
	require.NoError(t, s.indexPayload(ctx, signedComment(t, itemIDAt(t, storyPos)), posAt(10, 0, 0)))

	assert.Zero(t, countRows(t, db, "cn_comments"), "comment referencing a later parent MUST NOT persist")
	assert.Equal(t, 1, countRows(t, db, "cn_items"), "only the story is indexed")
}

// TestIndexPayload_DropsContinuationInOtherBlock: §9 confines a
// Continuation to the head's own block, after it in scan order.
func TestIndexPayload_DropsContinuationInOtherBlock(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, s := newScanner(t)

	headPos := posAt(30, 0, 0)
	require.NoError(t, s.indexPayload(ctx, story(t, "head story"), headPos))

	chunk, err := codec.EncodeContinuation(codec.Continuation{Head: itemIDAt(t, headPos), Seq: 0, Chunk: []byte{0x02, 0x01, 'x'}})
	require.NoError(t, err)
	require.NoError(t, s.indexPayload(ctx, chunk, posAt(31, 0, 0)))

	assert.Zero(t, countRows(t, db, "cn_continuations"), "continuation in a different block MUST NOT persist")
}

// TestIndexPayload_IndexesResolvableRefs is the positive control: an
// earlier, resolvable reference still gets indexed.
func TestIndexPayload_IndexesResolvableRefs(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, s := newScanner(t)

	storyPos := posAt(40, 0, 0)
	require.NoError(t, s.indexPayload(ctx, story(t, "root story"), storyPos))
	storyID := itemIDAt(t, storyPos)

	require.NoError(t, s.indexPayload(ctx, signedComment(t, storyID), posAt(41, 0, 0)))
	require.NoError(t, s.indexPayload(ctx, signedVote(t, storyID), posAt(42, 0, 0)))

	chunk, err := codec.EncodeContinuation(codec.Continuation{Head: storyID, Seq: 0, Chunk: []byte{0x02, 0x01, 'x'}})
	require.NoError(t, err)
	require.NoError(t, s.indexPayload(ctx, chunk, posAt(40, 0, 1)))

	assert.Equal(t, 1, countRows(t, db, "cn_comments"), "comment on an earlier parent persists")
	assert.Equal(t, 1, countRows(t, db, "cn_votes"), "vote on an earlier target persists")
	assert.Equal(t, 1, countRows(t, db, "cn_continuations"), "continuation after its same-block head persists")
}

func newScanner(t *testing.T) (*sql.DB, *Scanner) {
	t.Helper()
	db, err := store.Open(context.Background(), t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })
	return db, &Scanner{DB: db, Log: zerolog.Nop()}
}

// posAt returns a BlockPos whose txid is unique to the scan position,
// so cn_items rows don't collide across a scenario.
func posAt(height, txIdx, voutIdx uint32) store.BlockPos {
	return store.BlockPos{
		BlockHeight: height,
		TxIndex:     txIdx,
		VoutIndex:   voutIdx,
		BlockTime:   time.Date(2026, 4, 28, 12, 0, 0, 0, time.UTC),
		TxID:        fmt.Sprintf("%064x", uint64(height)<<32|uint64(txIdx)<<16|uint64(voutIdx)),
	}
}

// itemIDAt is the ItemID a message at `pos` is indexed under.
func itemIDAt(t *testing.T, pos store.BlockPos) codec.ItemID {
	t.Helper()
	natural, err := store.HashTxIDLE(pos.TxID)
	require.NoError(t, err)
	return codec.ComputeItemID(natural, pos.VoutIndex)
}

func story(t *testing.T, headline string) []byte {
	t.Helper()
	out, err := codec.EncodeStory(codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: headline})
	require.NoError(t, err)
	return out
}

func signedComment(t *testing.T, parent codec.ItemID) []byte {
	t.Helper()
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	tlvs := []codec.TLV{{Tag: codec.TLVBody, Value: []byte("reply")}}
	blob, err := codec.SerialiseTLVs(tlvs)
	require.NoError(t, err)
	digest := codec.CommentSigHash(parent, blob)
	sig, err := schnorr.Sign(priv, digest[:])
	require.NoError(t, err)

	c := codec.Comment{Parent: parent, TLVs: tlvs}
	copy(c.AuthorXPK[:], schnorr.SerializePubKey(priv.PubKey()))
	copy(c.Sig[:], sig.Serialize())
	out, err := codec.EncodeComment(c)
	require.NoError(t, err)
	return out
}

func signedVote(t *testing.T, target codec.ItemID) []byte {
	t.Helper()
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	digest := codec.VoteSigHash(codec.TypeUpvote, target)
	sig, err := schnorr.Sign(priv, digest[:])
	require.NoError(t, err)

	v := codec.Vote{Kind: codec.TypeUpvote, Target: target}
	copy(v.AuthorXPK[:], schnorr.SerializePubKey(priv.PubKey()))
	copy(v.Sig[:], sig.Serialize())
	out, err := codec.EncodeVote(v)
	require.NoError(t, err)
	return out
}

func countRows(t *testing.T, db *sql.DB, table string) int {
	t.Helper()
	var n int
	require.NoError(t, db.QueryRowContext(context.Background(), `SELECT COUNT(*) FROM `+table).Scan(&n))
	return n
}

func hexZero(n int) string {
	out := make([]byte, n)
	for i := range out {
		out[i] = '0'
	}
	return string(out)
}
