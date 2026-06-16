package engines

import (
	"context"
	"fmt"
	"slices"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// seedTopic indexes a TopicCreation directly into cn_topics so stories
// for it carry a topic name through ListCoinNews.
func seedTopic(t *testing.T, ctx context.Context, parser *Parser, topic opreturns.TopicID, name string, height uint32) {
	t.Helper()
	var ct codec.Topic
	copy(ct[:], topic[:])
	require.NoError(t, cnstore.Index(ctx, parser.db, cnstore.IndexEnv{
		Pos: cnstore.BlockPos{
			BlockHeight: height,
			TxIndex:     0,
			VoutIndex:   0,
			BlockTime:   time.Now(),
			TxID:        fmt.Sprintf("%064x", height),
		},
		TypeTag: codec.TypeTopicCreation,
		Msg:     &codec.TopicCreation{Topic: ct, RetentionDays: 7, Name: name},
	}))
}

func TestOpReturnHandling(t *testing.T) {
	t.Parallel()

	ctx := context.Background()

	db := database.Test(t)

	knownTopicID, err := opreturns.ValidNewsTopicID("deadbeef")
	require.NoError(t, err)

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))

	parser := &Parser{
		db: db,
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
	seedTopic(t, ctx, parser, knownTopicID, "The Known Topic", 50)

	knownStory, err := opreturns.EncodeNewsMessageNewFormat(knownTopicID, "The Known Topic", "The Known Content")
	require.NoError(t, err)

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
				PkScript: pkScript(t, knownStory),
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

	require.NoError(t, parser.opReturnForTXID(ctx, tx, nil, nil))
	require.NoError(t, parser.indexCoinNewsForBlock(ctx, 100, &wire.MsgBlock{
		Header:       wire.BlockHeader{Timestamp: time.Now()},
		Transactions: []*wire.MsgTx{tx},
	}))

	news, err := opreturns.ListCoinNews(ctx, db)
	require.NoError(t, err)
	require.Len(t, news, 1)

	slices.SortFunc(news, func(a, b opreturns.CoinNews) int {
		return strings.Compare(a.Headline, b.Headline)
	})

	assert.Equal(t, btcutil.Amount(100_000), news[0].Fee)
	assert.Equal(t, "The Known Topic", news[0].Headline)
	assert.Equal(t, "The Known Topic", news[0].TopicName)
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

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	parser := &Parser{
		db: db,
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
	seedTopic(t, ctx, parser, topicID, "US Weekly", 50)

	cases := []struct {
		name         string
		headline     string
		content      string
		wantHeadline string
		expectListed bool
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
			name:         "headline starts with 'new'",
			headline:     "new protocol launched",
			content:      "body",
			wantHeadline: "new protocol launched",
			expectListed: true,
		},
	}

	for i, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			txid := chainhash.Hash{byte(i + 1)}

			story, err := opreturns.EncodeNewsMessageNewFormat(topicID, tc.headline, tc.content)
			require.NoError(t, err)

			tx := &wire.MsgTx{
				TxIn: []*wire.TxIn{{PreviousOutPoint: wire.OutPoint{Hash: txid, Index: 0}}},
				TxOut: []*wire.TxOut{{
					Value:    0,
					PkScript: pkScript(t, story),
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
			require.NoError(t, parser.indexCoinNewsForBlock(ctx, uint32(200+i), &wire.MsgBlock{
				Header:       wire.BlockHeader{Timestamp: time.Now()},
				Transactions: []*wire.MsgTx{tx},
			}))

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
				assert.Nil(t, matched, "news item unexpectedly listed")
			}
		})
	}
}

// TestOpReturnHandling_WhitespaceHeadlineLooksBlank covers the
// blank-title footgun: a whitespace-only headline must not surface as a
// canonical story with an invisible title.
func TestOpReturnHandling_WhitespaceHeadlineLooksBlank(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	db := database.Test(t)

	topicID, err := opreturns.ValidNewsTopicID("a1a1a1a1")
	require.NoError(t, err)

	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	parser := &Parser{
		db: db,
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
	seedTopic(t, ctx, parser, topicID, "US Weekly", 50)

	story, err := opreturns.EncodeNewsMessageNewFormat(topicID, "   ", "body")
	require.NoError(t, err)

	tx := &wire.MsgTx{
		TxIn: []*wire.TxIn{{PreviousOutPoint: wire.OutPoint{Hash: chainhash.Hash{9}, Index: 0}}},
		TxOut: []*wire.TxOut{{
			Value:    0,
			PkScript: pkScript(t, story),
		}},
	}
	core.EXPECT().
		GetRawTransaction(gomock.Any(), tests.Connect(&corepb.GetRawTransactionRequest{
			Txid:      tx.TxHash().String(),
			Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_INFO,
		})).
		Return(connect.NewResponse(&corepb.GetRawTransactionResponse{Fee: 0.001}), nil)

	require.NoError(t, parser.opReturnForTXID(ctx, tx, nil, nil))
	require.NoError(t, parser.indexCoinNewsForBlock(ctx, 300, &wire.MsgBlock{
		Header:       wire.BlockHeader{Timestamp: time.Now()},
		Transactions: []*wire.MsgTx{tx},
	}))

	news, err := opreturns.ListCoinNews(ctx, db)
	require.NoError(t, err)
	assert.Empty(t, news, "whitespace-only headlines must not surface as canonical stories")
}
