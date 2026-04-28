package engines

import (
	"context"
	"crypto/rand"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// newCoinNewsParser builds a Parser with a fresh in-memory database
// for direct calls into indexCoinNewsBlocks / indexCoinNewsForBlock.
func newCoinNewsParser(t *testing.T) *Parser {
	t.Helper()
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().GetRawTransaction(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{Fee: 0.0001}), nil).
		AnyTimes()
	return &Parser{
		db: database.Test(t),
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
}

// TestCoinNewsIndexer_StoryAndVoteAcrossBlocks: a Story in block N,
// a signed Vote in block N+1, both land in cn_*. Replaying the Vote
// (same author, same target) leaves cn_votes at exactly one row —
// the spec §8 dedup invariant.
func TestCoinNewsIndexer_StoryAndVoteAcrossBlocks(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	p := newCoinNewsParser(t)

	// Story (block N).
	storyBytes, err := codec.EncodeStory(codec.Story{
		Topic:    codec.Topic{0x48, 0x4e, 0x53, 0x21},
		Headline: "Hello CoinNews",
		TLVs: []codec.TLV{
			{Tag: codec.TLVURL, Value: []byte("https://example.com/story")},
			{Tag: codec.TLVSubtype, Value: []byte{byte(codec.SubtypeLink)}},
		},
	})
	require.NoError(t, err)
	storyBlock := blockOf(t, [][]byte{storyBytes}, time.Date(2026, 4, 27, 12, 0, 0, 0, time.UTC))
	storyTxHash := storyBlock.Transactions[0].TxHash()
	var storyTxidNatural [32]byte
	copy(storyTxidNatural[:], storyTxHash[:])
	storyItem := codec.ComputeItemID(storyTxidNatural, 0)

	// Vote (block N+1).
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	digest := codec.VoteSigHash(codec.TypeUpvote, storyItem)
	sig, err := schnorr.Sign(priv, digest[:])
	require.NoError(t, err)

	var v codec.Vote
	v.Kind = codec.TypeUpvote
	v.Target = storyItem
	copy(v.AuthorXPK[:], schnorr.SerializePubKey(priv.PubKey()))
	copy(v.Sig[:], sig.Serialize())
	voteBytes, err := codec.EncodeVote(v)
	require.NoError(t, err)
	voteBlock := blockOfWithPrevHash(t, [][]byte{voteBytes},
		time.Date(2026, 4, 27, 12, 10, 0, 0, time.UTC),
		chainhash.Hash{99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99},
	)

	require.NoError(t, p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(800_000), storyBlock),
		lo.T2(uint32(800_001), voteBlock),
	}))

	var rowCount int
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_items`).Scan(&rowCount))
	assert.Equal(t, 2, rowCount, "Story + Vote both in cn_items")

	var headline, url string
	var subtype int
	require.NoError(t, p.db.QueryRowContext(ctx,
		`SELECT headline, subtype, COALESCE(url, '') FROM cn_stories WHERE item_id = ?`, storyItem[:]).
		Scan(&headline, &subtype, &url))
	assert.Equal(t, "Hello CoinNews", headline)
	assert.Equal(t, int(codec.SubtypeLink), subtype)
	assert.Equal(t, "https://example.com/story", url)

	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_votes WHERE target_id = ?`, storyItem[:]).Scan(&rowCount))
	assert.Equal(t, 1, rowCount, "Vote with valid sig persists exactly once")

	// Replay the Vote — dedup MUST hold.
	require.NoError(t, p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(800_001), voteBlock),
	}))
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_votes WHERE target_id = ?`, storyItem[:]).Scan(&rowCount))
	assert.Equal(t, 1, rowCount, "(author, target) dedup MUST hold across replays")
}

// TestCoinNewsIndexer_SortsBatchByHeight proves that even when blocks
// arrive in non-sorted order (the parallel fetcher above us doesn't
// promise ordering), indexCoinNewsBlocks reorders to canonical
// height-ascending. Two TopicCreations at the same TopicID land in
// blocks N and N+1; whichever block is "first" by height MUST win the
// row regardless of input ordering.
func TestCoinNewsIndexer_SortsBatchByHeight(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	p := newCoinNewsParser(t)

	topic := codec.Topic{0xaa, 0xaa, 0xaa, 0xaa}
	earlyBytes, _ := codec.EncodeTopicCreation(codec.TopicCreation{Topic: topic, RetentionDays: 7, Name: "early"})
	lateBytes, _ := codec.EncodeTopicCreation(codec.TopicCreation{Topic: topic, RetentionDays: 30, Name: "late"})
	early := blockOf(t, [][]byte{earlyBytes}, time.Now().UTC())
	late := blockOfWithPrevHash(t, [][]byte{lateBytes}, time.Now().UTC().Add(time.Hour),
		chainhash.Hash{0xfe, 0xed, 0xfa, 0xce, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28},
	)

	// Hand them in REVERSE order.
	require.NoError(t, p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(900_001), late),
		lo.T2(uint32(900_000), early),
	}))

	var name string
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT name FROM cn_topics WHERE topic = ?`, topic[:]).Scan(&name))
	assert.Equal(t, "early", name, "earliest-by-height TopicCreation MUST win even when batch input is unordered")
}

// TestCoinNewsIndexer_DropsBadSignature: a forged-sig Vote MUST NOT
// land in cn_votes, and there must be NO cn_items row for it either —
// signature verification gates persistence end to end.
func TestCoinNewsIndexer_DropsBadSignature(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	p := newCoinNewsParser(t)

	var target codec.ItemID
	_, _ = rand.Read(target[:])

	var v codec.Vote
	v.Kind = codec.TypeUpvote
	v.Target = target
	_, _ = rand.Read(v.AuthorXPK[:])
	_, _ = rand.Read(v.Sig[:])
	voteBytes, err := codec.EncodeVote(v)
	require.NoError(t, err)

	block := blockOf(t, [][]byte{voteBytes}, time.Now().UTC())
	require.NoError(t, p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(900_002), block),
	}))

	var rowCount int
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_votes`).Scan(&rowCount))
	assert.Zero(t, rowCount, "forged-sig Vote MUST NOT persist")
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_items`).Scan(&rowCount))
	assert.Zero(t, rowCount, "no cn_items row for a dropped Vote")
}

// TestCoinNewsIndexer_SkipsNonCoinNewsTraffic: random OP_RETURN bytes
// don't pollute cn_*; the legacy News Message path keeps working.
func TestCoinNewsIndexer_SkipsNonCoinNewsTraffic(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	p := newCoinNewsParser(t)

	junk := make([]byte, 20)
	_, _ = rand.Read(junk)
	block := blockOf(t, [][]byte{junk}, time.Now().UTC())
	require.NoError(t, p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(900_003), block),
	}))

	var rowCount int
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_items`).Scan(&rowCount))
	assert.Zero(t, rowCount, "non-CoinNews OP_RETURN must not pollute cn_items")
}

// TestCoinNewsIndexer_PurgeAtOrAbove proves the reorg purge wipes
// rows from blocks at or above the rewind target — without this,
// orphaned rows from the pre-reorg chain block first-wins inserts on
// the replayed range.
func TestCoinNewsIndexer_PurgeAtOrAbove(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	p := newCoinNewsParser(t)

	keepTopic := codec.Topic{0x11, 0x11, 0x11, 0x11}
	purgeTopic := codec.Topic{0x22, 0x22, 0x22, 0x22}
	keepBytes, _ := codec.EncodeTopicCreation(codec.TopicCreation{Topic: keepTopic, RetentionDays: 7, Name: "keep"})
	purgeBytes, _ := codec.EncodeTopicCreation(codec.TopicCreation{Topic: purgeTopic, RetentionDays: 7, Name: "purge"})
	keepBlock := blockOf(t, [][]byte{keepBytes}, time.Now().UTC())
	purgeBlock := blockOfWithPrevHash(t, [][]byte{purgeBytes}, time.Now().UTC(),
		chainhash.Hash{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 99},
	)

	require.NoError(t, p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(100), keepBlock),
		lo.T2(uint32(200), purgeBlock),
	}))

	require.NoError(t, p.purgeCoinNewsAtOrAbove(ctx, 200))

	var rowCount int
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_topics WHERE topic = ?`, keepTopic[:]).Scan(&rowCount))
	assert.Equal(t, 1, rowCount, "rows below rewind target survive")
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_topics WHERE topic = ?`, purgeTopic[:]).Scan(&rowCount))
	assert.Zero(t, rowCount, "rows at-or-above rewind target are wiped")
}

// TestCoinNewsIndexer_ErrorsBubble verifies that a hard persistence
// failure (e.g. a malformed payload that survives to the SQL layer)
// surfaces as a non-nil error rather than being logged-and-dropped.
// We trigger one by closing the DB before indexing — every subsequent
// transaction fails to begin, and that error must reach the caller.
func TestCoinNewsIndexer_ErrorsBubble(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	p := newCoinNewsParser(t)

	storyBytes, err := codec.EncodeStory(codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: "h"})
	require.NoError(t, err)
	block := blockOf(t, [][]byte{storyBytes}, time.Now().UTC())

	require.NoError(t, p.db.Close())
	err = p.indexCoinNewsBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(900_004), block),
	})
	require.Error(t, err, "persistence failures MUST surface, not log-and-continue")
}

// blockOf wraps one or more OP_RETURN payloads into a wire.MsgBlock
// suitable for the indexer. Single-tx blocks are skipped by the
// parser (treated as coinbase-only), so we always include a stub
// non-coinbase tx alongside.
func blockOf(t *testing.T, datas [][]byte, blockTime time.Time) *wire.MsgBlock {
	return blockOfWithPrevHash(t, datas, blockTime, chainhash.Hash{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32})
}

func blockOfWithPrevHash(t *testing.T, datas [][]byte, blockTime time.Time, prevHash chainhash.Hash) *wire.MsgBlock {
	t.Helper()
	tx := &wire.MsgTx{
		TxIn: []*wire.TxIn{{
			PreviousOutPoint: wire.OutPoint{Hash: prevHash, Index: 0},
		}},
	}
	for _, d := range datas {
		tx.TxOut = append(tx.TxOut, &wire.TxOut{Value: 0, PkScript: pkScript(t, d)})
	}
	return &wire.MsgBlock{
		Header:       wire.BlockHeader{Timestamp: blockTime},
		Transactions: []*wire.MsgTx{tx},
	}
}
