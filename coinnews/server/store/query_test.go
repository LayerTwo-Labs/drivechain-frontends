package store

import (
	"context"
	"crypto/rand"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

func TestListFeed_TopicFilter(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	defer db.Close() //nolint:errcheck

	a := codec.Topic{'A', 'A', 'A', 'A'}
	b := codec.Topic{'B', 'B', 'B', 'B'}
	for i, top := range []codec.Topic{a, b} {
		require.NoError(t, Index(ctx, db, IndexEnv{
			Pos: pos(uint32(100+i*10), 0, 0), TypeTag: codec.TypeTopicCreation,
			Msg: &codec.TopicCreation{Topic: top, RetentionDays: 7, Name: string(top[:])},
		}))
		require.NoError(t, Index(ctx, db, IndexEnv{
			Pos: pos(uint32(101+i*10), 0, 0), TypeTag: codec.TypeStory,
			Msg:  &codec.Story{Topic: top, Headline: "h-" + string(top[:])},
		}))
	}

	all, err := ListFeed(ctx, db, FeedFilter{Sort: SortNewest})
	require.NoError(t, err)
	assert.Len(t, all, 2)

	onlyA, err := ListFeed(ctx, db, FeedFilter{Sort: SortNewest, Topic: &a})
	require.NoError(t, err)
	require.Len(t, onlyA, 1)
	assert.Equal(t, "h-AAAA", onlyA[0].Headline)
}

func TestListFeed_SubtypeFilter(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	defer db.Close() //nolint:errcheck

	topic := codec.Topic{'X', 'X', 'X', 'X'}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(200, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "x"},
	}))
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(201, 0, 0), TypeTag: codec.TypeStory,
		Msg: &codec.Story{Topic: topic, Headline: "ask one", TLVs: []codec.TLV{
			{Tag: codec.TLVSubtype, Value: []byte{byte(codec.SubtypeAsk)}},
		}},
	}))
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(202, 0, 0), TypeTag: codec.TypeStory,
		Msg: &codec.Story{Topic: topic, Headline: "show one", TLVs: []codec.TLV{
			{Tag: codec.TLVSubtype, Value: []byte{byte(codec.SubtypeShow)}},
		}},
	}))

	ask := codec.SubtypeAsk
	got, err := ListFeed(ctx, db, FeedFilter{Sort: SortNewest, Subtype: &ask})
	require.NoError(t, err)
	require.Len(t, got, 1)
	assert.Equal(t, "ask one", got[0].Headline)
}

func TestListFeed_FrontPageOrdering(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	defer db.Close() //nolint:errcheck

	topic := codec.Topic{1, 2, 3, 4}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(300, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "t"},
	}))
	for i := uint32(0); i < 3; i++ {
		require.NoError(t, Index(ctx, db, IndexEnv{
			Pos: pos(301+i, 0, 0), TypeTag: codec.TypeStory,
			Msg:  &codec.Story{Topic: topic, Headline: "story"},
		}))
	}
	feed, err := ListFeed(ctx, db, FeedFilter{Sort: SortScoreDesc})
	require.NoError(t, err)
	assert.Len(t, feed, 3)
}

func TestListThread_RecursiveWalk(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db, err := Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	defer db.Close() //nolint:errcheck

	topic := codec.Topic{'T', 'T', 'T', 'T'}
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(400, 0, 0), TypeTag: codec.TypeTopicCreation,
		Msg: &codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "t"},
	}))
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(401, 0, 0), TypeTag: codec.TypeStory,
		Msg:  &codec.Story{Topic: topic, Headline: "root"},
	}))
	feed, err := ListFeed(ctx, db, FeedFilter{Sort: SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)
	root := feed[0].ItemID

	var xpkA, xpkB [32]byte
	_, _ = rand.Read(xpkA[:])
	_, _ = rand.Read(xpkB[:])
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(402, 0, 0), TypeTag: codec.TypeComment,
		Msg: &codec.Comment{Parent: root, AuthorXPK: xpkA, TLVs: []codec.TLV{
			{Tag: codec.TLVBody, Value: []byte("first")},
		}},
	}))
	cs, err := ListThread(ctx, db, root)
	require.NoError(t, err)
	require.Len(t, cs, 1)
	require.NoError(t, Index(ctx, db, IndexEnv{
		Pos: pos(403, 0, 0), TypeTag: codec.TypeComment,
		Msg: &codec.Comment{Parent: cs[0].ItemID, AuthorXPK: xpkB, TLVs: []codec.TLV{
			{Tag: codec.TLVBody, Value: []byte("nested")},
		}},
	}))
	cs, err = ListThread(ctx, db, root)
	require.NoError(t, err)
	assert.Len(t, cs, 2, "recursive walk picks up the nested reply")
}
