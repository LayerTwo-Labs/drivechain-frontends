package scanner

import (
	"context"
	"encoding/hex"
	"testing"
	"time"

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

func hexZero(n int) string {
	out := make([]byte, n)
	for i := range out {
		out[i] = '0'
	}
	return string(out)
}
