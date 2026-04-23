package engines

import (
	"context"
	"slices"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

func TestOpReturnHandling(t *testing.T) {
	t.Parallel()

	ctx := context.Background()

	db := database.Test(t)

	knownTopicID, err := opreturns.ValidNewsTopicID("deadbeef")
	require.NoError(t, err)

	require.NoError(t, opreturns.CreateTopic(ctx, db, knownTopicID, "The Known Topic", "txid", true, 7))

	unknownTopicID, err := opreturns.ValidNewsTopicID("12345678")
	require.NoError(t, err)

	newTopicID, err := opreturns.ValidNewsTopicID("87654321")
	require.NoError(t, err)

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))

	parser := &Parser{
		db: db,
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
		topics: []opreturns.TopicInfo{
			// One known topic
			{
				ID:   knownTopicID,
				Name: "The Known Topic",
			},
		},
	}

	tx := &wire.MsgTx{
		// have to have at least one input, otherwise it's a coinbase transaction
		// and those are skipped during handling
		TxIn: []*wire.TxIn{
			{
				PreviousOutPoint: wire.OutPoint{
					Hash:  chainhash.Hash{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32},
					Index: 0,
				},
			},
		},
		TxOut: []*wire.TxOut{
			{
				Value:    0,
				PkScript: pkScript(t, opreturns.EncodeNewsMessage(knownTopicID, "The Known Topic", "The Known Content")),
			},
			{
				Value:    0,
				PkScript: pkScript(t, opreturns.EncodeNewsMessage(unknownTopicID, "The Unknown Topic", "The Unknown Content")),
			},
			{
				Value:    0,
				PkScript: pkScript(t, opreturns.EncodeTopicCreationMessage(newTopicID, "The New Topic", 7)),
			},
			{
				Value:    0,
				PkScript: pkScript(t, opreturns.EncodeNewsMessage(newTopicID, "The New Topic", "The New Content")),
			},
		},
	}

	core.EXPECT().
		GetRawTransaction(gomock.Any(), tests.Connect(&corepb.GetRawTransactionRequest{
			Txid:      tx.TxHash().String(),
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_INFO,
		})).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{
			Fee: 0.001,
		}), nil)

	// Verify that we:
	// 1. Persisted coin news for the known topic
	// 2. Skipped coins news for an unknown topic
	// 3. Created the brand new topic
	// 4. Persisted coin news for the new topic
	require.NoError(t, parser.opReturnForTXID(ctx, tx, nil, nil))

	assert.Len(t, parser.topics, 2)

	assert.True(t, lo.ContainsBy(parser.topics, func(t opreturns.TopicInfo) bool {
		return t.ID.String() == knownTopicID.String()
	}))
	assert.True(t, lo.ContainsBy(parser.topics, func(t opreturns.TopicInfo) bool {
		return t.ID.String() == newTopicID.String()
	}))

	news, err := opreturns.ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 2)

	slices.SortFunc(news, func(a, b opreturns.CoinNews) int {
		return strings.Compare(a.Headline, b.Headline)
	})

	assert.Equal(t, btcutil.Amount(100_000), news[0].Fee)
	assert.Equal(t, btcutil.Amount(100_000), news[1].Fee)

	assert.Equal(t, "The Known Topic", news[0].Headline)
	assert.Equal(t, "The New Topic", news[1].Headline)
}

func pkScript(t *testing.T, data []byte) []byte {
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData(data).Script()
	require.NoError(t, err)
	return script
}

// TestOpReturnHandling_HeadlineEdgeCases exercises the full engine
// pipeline (raw OP_RETURN tx → parseOPReturnData → persist →
// ListCoinNews) for the headline payloads that have surfaced in user
// reports. The round-trip must preserve the sender's bytes exactly.
func TestOpReturnHandling_HeadlineEdgeCases(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	db := database.Test(t)

	topicID, err := opreturns.ValidNewsTopicID("a1a1a1a1")
	require.NoError(t, err)
	require.NoError(t, opreturns.CreateTopic(ctx, db, topicID, "US Weekly", "topic_txid", true, 7))

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	parser := &Parser{
		db: db,
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
		topics: []opreturns.TopicInfo{{ID: topicID, Name: "US Weekly"}},
	}

	cases := []struct {
		name          string
		headline      string
		content       string
		wantHeadline  string
		expectListed  bool
		expectCreates bool // true if engine treats as topic creation
	}{
		{
			name:         "standard headline",
			headline:     "Bitcoin hits new ATH",
			content:      "body",
			wantHeadline: "Bitcoin hits new ATH",
			expectListed: true,
		},
		{
			name:         "exactly 64 bytes",
			headline:     "ABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCD",
			content:      "body",
			wantHeadline: "ABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCD",
			expectListed: true,
		},
		{
			name:         "non-ascii utf-8",
			headline:     "日本の最新ニュース",
			content:      "body",
			wantHeadline: "日本の最新ニュース",
			expectListed: true,
		},
		{
			name:          "headline starts with 'new' (known false-positive)",
			headline:      "new protocol launched",
			content:       "body",
			expectListed:  false, // KNOWN BUG: IsCreateTopic eats this
			expectCreates: true,
		},
	}

	for i, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			txid := chainhash.Hash{byte(i + 1)}

			tx := &wire.MsgTx{
				TxIn: []*wire.TxIn{{PreviousOutPoint: wire.OutPoint{Hash: txid, Index: 0}}},
				TxOut: []*wire.TxOut{{
					Value:    0,
					PkScript: pkScript(t, opreturns.EncodeNewsMessage(topicID, tc.headline, tc.content)),
				}},
			}

			core.EXPECT().
				GetRawTransaction(gomock.Any(), tests.Connect(&corepb.GetRawTransactionRequest{
					Txid:      tx.TxHash().String(),
					Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_INFO,
				})).
				Return(connect.NewResponse(&corepb.GetRawTransactionResponse{Fee: 0.001}), nil).
				Times(1)

			require.NoError(t, parser.opReturnForTXID(ctx, tx, nil, nil))

			news, err := opreturns.ListCoinNews(ctx, db)
			require.NoError(t, err)

			var matched *opreturns.CoinNews
			for i := range news {
				if news[i].TopicName == "US Weekly" && news[i].Headline == tc.wantHeadline &&
					news[i].Content == tc.content {
					matched = &news[i]
					break
				}
			}

			if tc.expectListed {
				require.NotNil(t, matched, "news item not found in ListCoinNews output (headline=%q)", tc.headline)
				assert.Equal(t, btcutil.Amount(100_000), matched.Fee)
			} else {
				assert.Nil(t, matched,
					"news item unexpectedly listed (known bug: 'new'-prefixed headlines are dropped as topic creations)")
			}
		})
	}
}

// TestOpReturnHandling_WhitespaceHeadlineLooksBlank simulates the
// live-reported screenshot: every row's title cell appears empty.
// A whitespace-only headline round-trips to a whitespace string the
// UI can't distinguish from empty. This test locks in the footgun so
// a future validation/trim fix has a reproducer.
func TestOpReturnHandling_WhitespaceHeadlineLooksBlank(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	db := database.Test(t)

	topicID, err := opreturns.ValidNewsTopicID("a1a1a1a1")
	require.NoError(t, err)
	require.NoError(t, opreturns.CreateTopic(ctx, db, topicID, "US Weekly", "topic_txid", true, 7))

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	parser := &Parser{
		db: db,
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
		topics: []opreturns.TopicInfo{{ID: topicID, Name: "US Weekly"}},
	}

	tx := &wire.MsgTx{
		TxIn: []*wire.TxIn{{PreviousOutPoint: wire.OutPoint{Hash: chainhash.Hash{9}, Index: 0}}},
		TxOut: []*wire.TxOut{{
			Value:    0,
			PkScript: pkScript(t, opreturns.EncodeNewsMessage(topicID, "   ", "body")),
		}},
	}
	core.EXPECT().
		GetRawTransaction(gomock.Any(), tests.Connect(&corepb.GetRawTransactionRequest{
			Txid:      tx.TxHash().String(),
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_INFO,
		})).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{Fee: 0.001}), nil)

	require.NoError(t, parser.opReturnForTXID(ctx, tx, nil, nil))

	news, err := opreturns.ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 1)
	assert.Equal(t, "   ", news[0].Headline,
		"whitespace-only broadcast produces a row whose Title cell renders as blank — validation or TrimSpace needed")
}
