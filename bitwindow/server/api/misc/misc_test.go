package api_misc_test

import (
	"context"
	"encoding/hex"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	miscv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1"
	miscv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestService_ListOPReturn(t *testing.T) {
	t.Parallel()

	t.Run("list empty op returns", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListOPReturn(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.OpReturns)
	})

	t.Run("list op returns with data", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// Insert test data using the Persist function
		ctx := context.Background()
		height := uint32(100)
		err := opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "txid1",
				Vout:   0,
				Data:   []byte("test message"),
			},
		})
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListOPReturn(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.OpReturns, 1)
		assert.Equal(t, "test message", resp.Msg.OpReturns[0].Message)
		assert.Equal(t, "txid1", resp.Msg.OpReturns[0].Txid)
		assert.EqualValues(t, 0, resp.Msg.OpReturns[0].Vout)
		assert.EqualValues(t, 100, lo.FromPtr(resp.Msg.OpReturns[0].Height))
	})
}

func TestService_BroadcastNews(t *testing.T) {
	t.Parallel()

	t.Run("broadcast news success", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)

		mockWallet.EXPECT().
			SendTransaction(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.SendTransactionResponse]{
				Msg: &pb.SendTransactionResponse{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: "test-txid"},
					},
				},
			}, nil)

		database := database.Test(t)
		// First create a topic using the CreateTopic function
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic", "topic_txid")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet)))

		resp, err := cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "12345678",
			Headline: "Test News Headline",
			Content:  "https://example.com/news",
		}))
		require.NoError(t, err)
		assert.NotEmpty(t, resp.Msg.Txid)
	})

	t.Run("broadcast news with empty topic", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err := cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "",
			Headline: "Test News Headline",
			Content:  "https://example.com/news",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "topic must be set")
	})

	t.Run("broadcast news with invalid topic format", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err := cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "123", // Too short, should be 8 hex characters
			Headline: "Test News Headline",
			Content:  "https://example.com/news",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "topic not on valid format")
	})

	t.Run("broadcast news with empty headline", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create a topic
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic", "topic_txid")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err = cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "12345678",
			Headline: "",
			Content:  "https://example.com/news",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "headline must be set")
	})

	t.Run("broadcast news with headline too long", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create a topic
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic", "topic_txid")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		longHeadline := strings.Repeat("a", 65) // 65 characters, exceeds 64 limit
		_, err = cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "12345678",
			Headline: longHeadline,
			Content:  "https://example.com/news",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "headline cannot be longer than 64 characters")
	})

	t.Run("broadcast news with non-existent topic", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err := cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "87654321", // Non-existent topic
			Headline: "Test News Headline",
			Content:  "https://example.com/news",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "topic does not exist")
	})

	t.Run("broadcast news with text content", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)

		mockWallet.EXPECT().
			SendTransaction(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.SendTransactionResponse]{
				Msg: &pb.SendTransactionResponse{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: "test-txid"},
					},
				},
			}, nil)

		database := database.Test(t)
		// First create a topic
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic", "topic_txid")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet)))

		resp, err := cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "12345678",
			Headline: "Test News Headline",
			Content:  "This is the news content",
		}))
		require.NoError(t, err)
		assert.NotEmpty(t, resp.Msg.Txid)
	})

	t.Run("broadcast news with hex content", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)

		mockWallet.EXPECT().
			SendTransaction(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.SendTransactionResponse]{
				Msg: &pb.SendTransactionResponse{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: "test-txid"},
					},
				},
			}, nil)

		database := database.Test(t)
		// First create a topic
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic", "topic_txid")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet)))

		hexContent := hex.EncodeToString([]byte("hex content"))
		resp, err := cli.BroadcastNews(context.Background(), connect.NewRequest(&miscv1.BroadcastNewsRequest{
			Topic:    "12345678",
			Headline: "Test News Headline",
			Content:  hexContent,
		}))
		require.NoError(t, err)
		assert.NotEmpty(t, resp.Msg.Txid)
	})
}

func TestService_CreateTopic(t *testing.T) {
	t.Parallel()

	t.Run("create topic success", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockWallet := mocks.NewMockWalletServiceClient(ctrl)

		mockWallet.EXPECT().
			SendTransaction(gomock.Any(), gomock.Any()).
			Return(&connect.Response[pb.SendTransactionResponse]{
				Msg: &pb.SendTransactionResponse{
					Txid: &commonv1.ReverseHex{
						Hex: &wrapperspb.StringValue{Value: "test-txid"},
					},
				},
			}, nil)

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database, apitests.WithWallet(mockWallet)))

		resp, err := cli.CreateTopic(context.Background(), connect.NewRequest(&miscv1.CreateTopicRequest{
			Topic: "12345678",
			Name:  "Test Topic",
		}))
		require.NoError(t, err)
		assert.NotEmpty(t, resp.Msg.Txid)
	})

	t.Run("create topic with empty topic", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err := cli.CreateTopic(context.Background(), connect.NewRequest(&miscv1.CreateTopicRequest{
			Topic: "",
			Name:  "Test Topic",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "topic must be set")
	})

	t.Run("create topic with invalid format", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err := cli.CreateTopic(context.Background(), connect.NewRequest(&miscv1.CreateTopicRequest{
			Topic: "123", // Too short, should be 8 hex characters
			Name:  "Test Topic",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "topic not on valid format")
	})

	t.Run("create topic with empty name", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err := cli.CreateTopic(context.Background(), connect.NewRequest(&miscv1.CreateTopicRequest{
			Topic: "12345678",
			Name:  "",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "title must be set")
	})

	t.Run("create topic with name too long", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		longName := strings.Repeat("a", 33) // 33 characters, exceeds 32 limit
		_, err := cli.CreateTopic(context.Background(), connect.NewRequest(&miscv1.CreateTopicRequest{
			Topic: "12345678",
			Name:  longName,
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "title cannot be longer than 32 characters")
	})

	t.Run("create duplicate topic", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create a topic
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Existing Topic", "topic_txid")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		_, err = cli.CreateTopic(context.Background(), connect.NewRequest(&miscv1.CreateTopicRequest{
			Topic: "12345678",
			Name:  "New Topic",
		}))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "topic already exists")
	})
}

func TestService_ListTopics(t *testing.T) {
	t.Parallel()

	t.Run("list empty topics", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListTopics(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Topics, 2)
	})

	t.Run("list topics with data", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// Insert test topics
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "Norway Weekly", "Topic 3", "a3a3a3a3")
		require.NoError(t, err)
		err = opreturns.CreateTopic(ctx, database, "Bitcoin Weekly", "Topic 4", "a4a4a4a4")
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListTopics(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Topics, 4)

		// Check first topic
		found1 := false
		found2 := false
		for _, topic := range resp.Msg.Topics {
			if topic.Topic == "Norway Weekly" {
				assert.Equal(t, "Topic 3", topic.Name)
				found1 = true
			}
			if topic.Topic == "Bitcoin Weekly" {
				assert.Equal(t, "Topic 4", topic.Name)
				found2 = true
			}
		}
		assert.True(t, found1, "Norway Weekly not found")
		assert.True(t, found2, "Bitcoin Weekly not found")
	})
}

func TestService_ListCoinNews(t *testing.T) {
	t.Parallel()

	t.Run("list empty coin news", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListCoinNews(context.Background(), connect.NewRequest(&miscv1.ListCoinNewsRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.CoinNews)
	})

	t.Run("list coin news with data", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create topics
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic 1", "topic_txid1")
		require.NoError(t, err)
		err = opreturns.CreateTopic(ctx, database, "87654321", "Test Topic 2", "topic_txid2")
		require.NoError(t, err)

		// Insert coin news as OP_RETURN data
		// Format: 8-byte topic + 64-byte headline (padded) + content
		headline1 := "News Headline 1"
		paddedHeadline1 := headline1 + string(make([]byte, 64-len(headline1)))
		newsData1 := []byte("12345678" + paddedHeadline1 + "Content for news 1")
		height := uint32(100)
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid1",
				Vout:   0,
				Data:   newsData1,
			},
		})
		require.NoError(t, err)

		headline2 := "News Headline 2"
		paddedHeadline2 := headline2 + string(make([]byte, 64-len(headline2)))
		newsData2 := []byte("87654321" + paddedHeadline2 + "Content for news 2")
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid2",
				Vout:   0,
				Data:   newsData2,
			},
		})
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListCoinNews(context.Background(), connect.NewRequest(&miscv1.ListCoinNewsRequest{}))
		require.NoError(t, err)
		assert.Len(t, resp.Msg.CoinNews, 2)
		// Should be sorted by most recent first
		assert.Equal(t, "87654321", resp.Msg.CoinNews[0].Topic)
		assert.Equal(t, "News Headline 2"+string(make([]byte, 64-len("News Headline 2"))), resp.Msg.CoinNews[0].Headline)
		assert.Equal(t, "Content for news 2", resp.Msg.CoinNews[0].Content)
		assert.Equal(t, "12345678", resp.Msg.CoinNews[1].Topic)
		assert.Equal(t, "News Headline 1"+string(make([]byte, 64-len("News Headline 1"))), resp.Msg.CoinNews[1].Headline)
		assert.Equal(t, "Content for news 1", resp.Msg.CoinNews[1].Content)
	})

	t.Run("list coin news filtered by topic", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create topics
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic 1", "topic_txid1")
		require.NoError(t, err)
		err = opreturns.CreateTopic(ctx, database, "87654321", "Test Topic 2", "topic_txid2")
		require.NoError(t, err)

		// Insert coin news for both topics
		headline1 := "News Headline 1"
		paddedHeadline1 := headline1 + string(make([]byte, 64-len(headline1)))
		newsData1 := []byte("12345678" + paddedHeadline1 + "Content for news 1")
		height := uint32(100)
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid1",
				Vout:   0,
				Data:   newsData1,
			},
		})
		require.NoError(t, err)

		headline2 := "News Headline 2"
		paddedHeadline2 := headline2 + string(make([]byte, 64-len(headline2)))
		newsData2 := []byte("87654321" + paddedHeadline2 + "Content for news 2")
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid2",
				Vout:   0,
				Data:   newsData2,
			},
		})
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		// Filter by topic
		topic := "12345678"
		resp, err := cli.ListCoinNews(context.Background(), connect.NewRequest(&miscv1.ListCoinNewsRequest{
			Topic: &topic,
		}))
		require.NoError(t, err)
		assert.Len(t, resp.Msg.CoinNews, 1)
		assert.Equal(t, "12345678", resp.Msg.CoinNews[0].Topic)
		assert.Equal(t, paddedHeadline1, resp.Msg.CoinNews[0].Headline)
	})

	t.Run("list coin news sorted by recency", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create topics
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic 1", "topic_txid1")
		require.NoError(t, err)
		err = opreturns.CreateTopic(ctx, database, "87654321", "Test Topic 2", "topic_txid2")
		require.NoError(t, err)

		// Insert coin news with specific timestamps
		headline1 := "Old News"
		paddedHeadline1 := headline1 + string(make([]byte, 64-len(headline1)))
		newsData1 := []byte("12345678" + paddedHeadline1 + "Content for old news")
		height := uint32(100)
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid1",
				Vout:   0,
				Data:   newsData1,
			},
		})
		require.NoError(t, err)

		headline2 := "Recent News"
		paddedHeadline2 := headline2 + string(make([]byte, 64-len(headline2)))
		newsData2 := []byte("12345678" + paddedHeadline2 + "Content for recent news")
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid2",
				Vout:   0,
				Data:   newsData2,
			},
		})
		require.NoError(t, err)

		headline3 := "Latest News"
		paddedHeadline3 := headline3 + string(make([]byte, 64-len(headline3)))
		newsData3 := []byte("12345678" + paddedHeadline3 + "Content for latest news")
		err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
			{
				Height: &height,
				TxID:   "news_txid3",
				Vout:   0,
				Data:   newsData3,
			},
		})
		require.NoError(t, err)

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListCoinNews(context.Background(), connect.NewRequest(&miscv1.ListCoinNewsRequest{}))
		require.NoError(t, err)
		assert.Len(t, resp.Msg.CoinNews, 3)

		// Check that news is sorted by recency (most recent first)
		assert.Equal(t, "Latest News"+string(make([]byte, 64-len("Latest News"))), resp.Msg.CoinNews[0].Headline)
		assert.Equal(t, "Recent News"+string(make([]byte, 64-len("Recent News"))), resp.Msg.CoinNews[1].Headline)
		assert.Equal(t, "Old News"+string(make([]byte, 64-len("Old News"))), resp.Msg.CoinNews[2].Headline)
	})

	t.Run("list coin news limited to 100 entries", func(t *testing.T) {
		t.Parallel()

		database := database.Test(t)
		// First create topics
		ctx := context.Background()
		err := opreturns.CreateTopic(ctx, database, "12345678", "Test Topic 1", "topic_txid1")
		require.NoError(t, err)
		err = opreturns.CreateTopic(ctx, database, "87654321", "Test Topic 2", "topic_txid2")
		require.NoError(t, err)

		// Insert 105 coin news entries
		for i := 0; i < 105; i++ {
			headline := "News"
			paddedHeadline := headline + string(make([]byte, 64-len(headline)))
			newsData := []byte("12345678" + paddedHeadline + "Content for news")
			height := uint32(100)
			err = opreturns.Persist(ctx, database, []opreturns.OPReturn{
				{
					Height: &height,
					TxID:   "news_txid",
					Vout:   int32(i),
					Data:   newsData,
				},
			})
			require.NoError(t, err)
		}

		cli := miscv1connect.NewMiscServiceClient(apitests.API(t, database))

		resp, err := cli.ListCoinNews(context.Background(), connect.NewRequest(&miscv1.ListCoinNewsRequest{}))
		require.NoError(t, err)
		// Should be limited to 100 entries
		assert.Len(t, resp.Msg.CoinNews, 100)
	})
}
