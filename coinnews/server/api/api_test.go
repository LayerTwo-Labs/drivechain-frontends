package api

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	pb "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

func newHandler(t *testing.T) *Handler {
	t.Helper()
	db, err := store.Open(context.Background(), t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })
	return &Handler{DB: db}
}

func pos(height, txIdx, voutIdx uint32) store.BlockPos {
	txid := make([]byte, 32)
	binaryHeightLE(txid[0:4], height)
	binaryHeightLE(txid[4:8], txIdx)
	binaryHeightLE(txid[8:12], voutIdx)
	return store.BlockPos{
		BlockHeight: height,
		TxIndex:     txIdx,
		VoutIndex:   voutIdx,
		BlockTime:   time.Date(2026, 4, 28, 12, 0, 0, 0, time.UTC),
		TxID:        hex.EncodeToString(txid),
	}
}

func binaryHeightLE(dst []byte, v uint32) {
	dst[0] = byte(v)
	dst[1] = byte(v >> 8)
	dst[2] = byte(v >> 16)
	dst[3] = byte(v >> 24)
}

func TestHandler_ListTopicsAndFeed(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	h := newHandler(t)
	topic := codec.Topic{'B', 'T', 'C', '!'}

	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(10, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 30, Name: "Bitcoin"},
	}))
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(11, 0, 0), TypeTag: codec.TypeStory,
		Msg: &codec.Story{Topic: topic, Headline: "hello", TLVs: []codec.TLV{
			{Tag: codec.TLVURL, Value: []byte("https://example.com/x")},
		}},
	}))

	topicsRes, err := h.ListTopics(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Len(t, topicsRes.Msg.Topics, 1)
	assert.Equal(t, "Bitcoin", topicsRes.Msg.Topics[0].Name)
	assert.Equal(t, "42544321", topicsRes.Msg.Topics[0].TopicHex)

	frontRes, err := h.ListFrontPage(ctx, connect.NewRequest(&pb.ListFrontPageRequest{Limit: 10}))
	require.NoError(t, err)
	require.Len(t, frontRes.Msg.Items, 1)
	assert.Equal(t, "hello", frontRes.Msg.Items[0].Headline)
	assert.Equal(t, "https://example.com/x", frontRes.Msg.Items[0].Url)

	newRes, err := h.ListNewFeed(ctx, connect.NewRequest(&pb.ListNewFeedRequest{Limit: 10}))
	require.NoError(t, err)
	require.Len(t, newRes.Msg.Items, 1)
}

func TestHandler_GetItem_NotFound(t *testing.T) {
	t.Parallel()
	h := newHandler(t)
	missing := make([]byte, codec.ItemIDLen)
	missing[0] = 0xde
	_, err := h.GetItem(context.Background(), connect.NewRequest(&pb.GetItemRequest{
		ItemIdHex: hex.EncodeToString(missing),
	}))
	require.Error(t, err)
	var ce *connect.Error
	require.ErrorAs(t, err, &ce)
	assert.Equal(t, connect.CodeNotFound, ce.Code())
}

func TestHandler_GetItem_BadID(t *testing.T) {
	t.Parallel()
	h := newHandler(t)
	_, err := h.GetItem(context.Background(), connect.NewRequest(&pb.GetItemRequest{
		ItemIdHex: "not-hex",
	}))
	require.Error(t, err)
	var ce *connect.Error
	require.ErrorAs(t, err, &ce)
	assert.Equal(t, connect.CodeInvalidArgument, ce.Code())
}

func TestHandler_GetItem_RoundTrip(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	h := newHandler(t)
	topic := codec.Topic{'X', 'Y', 'Z', 0}

	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(20, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "xyz"},
	}))
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(21, 0, 0), TypeTag: codec.TypeStory,
		Msg:  &codec.Story{Topic: topic, Headline: "hn-clone"},
	}))

	feed, err := store.ListFeed(ctx, h.DB, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)

	got, err := h.GetItem(ctx, connect.NewRequest(&pb.GetItemRequest{
		ItemIdHex: hex.EncodeToString(feed[0].ItemID[:]),
	}))
	require.NoError(t, err)
	assert.Equal(t, "hn-clone", got.Msg.Item.Headline)
}

func TestHandler_ListByAuthor_BadHex(t *testing.T) {
	t.Parallel()
	h := newHandler(t)
	_, err := h.ListByAuthor(context.Background(), connect.NewRequest(&pb.ListByAuthorRequest{
		AuthorXpkHex: "deadbeef", // not 32 bytes
	}))
	require.Error(t, err)
	var ce *connect.Error
	require.ErrorAs(t, err, &ce)
	assert.Equal(t, connect.CodeInvalidArgument, ce.Code())
}

func TestHandler_ListByAuthor_OK(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	h := newHandler(t)
	topic := codec.Topic{'X', 'Y', 'Z', 0}
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(30, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "xyz"},
	}))
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(31, 0, 0), TypeTag: codec.TypeStory,
		Msg:  &codec.Story{Topic: topic, Headline: "story"},
	}))
	feed, err := store.ListFeed(ctx, h.DB, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)
	storyID := feed[0].ItemID

	var xpk [32]byte
	_, _ = rand.Read(xpk[:])
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(32, 0, 0), TypeTag: codec.TypeComment,
		Msg: &codec.Comment{
			Parent:    storyID,
			AuthorXPK: xpk,
			TLVs:      []codec.TLV{{Tag: codec.TLVBody, Value: []byte("agree")}},
		},
	}))

	res, err := h.ListByAuthor(ctx, connect.NewRequest(&pb.ListByAuthorRequest{
		AuthorXpkHex: hex.EncodeToString(xpk[:]),
		Limit:        10,
	}))
	require.NoError(t, err)
	require.Len(t, res.Msg.Items, 1, "story author list pulls in stories the author commented on")
}

func TestHandler_ListByTopic_BadHex(t *testing.T) {
	t.Parallel()
	h := newHandler(t)
	_, err := h.ListByTopic(context.Background(), connect.NewRequest(&pb.ListByTopicRequest{
		TopicHex: "zz",
	}))
	require.Error(t, err)
	var ce *connect.Error
	require.ErrorAs(t, err, &ce)
	assert.Equal(t, connect.CodeInvalidArgument, ce.Code())
}

func TestHandler_ListThread(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	h := newHandler(t)
	topic := codec.Topic{'B', 'T', 'C', '!'}
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(50, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "btc"},
	}))
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(51, 0, 0), TypeTag: codec.TypeStory,
		Msg:  &codec.Story{Topic: topic, Headline: "root"},
	}))
	feed, err := store.ListFeed(ctx, h.DB, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)

	var xpk [32]byte
	_, _ = rand.Read(xpk[:])
	require.NoError(t, store.Index(ctx, h.DB, store.IndexEnv{
		Pos: pos(52, 0, 0), TypeTag: codec.TypeComment,
		Msg: &codec.Comment{
			Parent:    feed[0].ItemID,
			AuthorXPK: xpk,
			TLVs:      []codec.TLV{{Tag: codec.TLVBody, Value: []byte("+1")}},
		},
	}))

	res, err := h.ListThread(ctx, connect.NewRequest(&pb.ListThreadRequest{
		RootIdHex: hex.EncodeToString(feed[0].ItemID[:]),
	}))
	require.NoError(t, err)
	require.Len(t, res.Msg.Comments, 1)
	assert.Equal(t, "+1", res.Msg.Comments[0].Body)
}
