package api_misc

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strings"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	miscv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.MiscServiceHandler = new(Server)

// New creates a new misc Server. Misc is a horrible name, but can't think of
// anything else just yet.
func New(
	database *sql.DB,
	wallet *service.Service[validatorrpc.WalletServiceClient],
) *Server {
	return &Server{
		database: database,
		wallet:   wallet,
	}
}

type Server struct {
	database *sql.DB
	wallet   *service.Service[validatorrpc.WalletServiceClient]
}

// ListOPReturn implements miscv1connect.MiscServiceHandler.
func (s *Server) ListOPReturn(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[miscv1.ListOPReturnResponse], error) {
	opReturns, err := opreturns.List(ctx, s.database)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list op returns")
		return nil, err
	}

	return connect.NewResponse(&miscv1.ListOPReturnResponse{
		OpReturns: lo.Map(opReturns, opReturnToProto),
	}), nil
}

func opReturnToProto(opReturn opreturns.OPReturn, _ int) *miscv1.OPReturn {
	var height *int32
	if opReturn.Height != nil {
		height = lo.ToPtr(int32(*opReturn.Height))
	}
	return &miscv1.OPReturn{
		Id:         opReturn.ID,
		Message:    opreturns.OPReturnToReadable(opReturn.Data),
		Txid:       opReturn.TxID,
		Vout:       opReturn.Vout,
		Height:     height,
		CreateTime: timestamppb.New(lo.FromPtr(opReturn.CreatedAt)),
	}
}

// BroadcastNews implements miscv1connect.MiscServiceHandler.
func (s *Server) BroadcastNews(ctx context.Context, req *connect.Request[miscv1.BroadcastNewsRequest]) (*connect.Response[miscv1.BroadcastNewsResponse], error) {
	if req.Msg.Topic == "" {
		err := errors.New("topic must be set")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast news: topic must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if !opreturns.ValidNewsTopic(req.Msg.Topic) {
		err := errors.New("topic not on valid format, expected 4 bytes (8 hex characters)")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast news: invalid topic format")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if req.Msg.Headline == "" {
		err := errors.New("headline must be set")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast news: headline must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if len(req.Msg.Headline) > 64 {
		err := errors.New("headline cannot be longer than 64 characters")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast news: headline too long")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	exists, err := opreturns.TopicExists(ctx, s.database, req.Msg.Topic)
	if err != nil {
		err = fmt.Errorf("could not check if topic exists: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not check if topic exists")
		return nil, err
	}
	if !exists {
		err := errors.New("topic does not exist")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast news: topic does not exist")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// pad headline to always be 64 bytes
	headline := make([]byte, 64)
	for i := range headline {
		headline[i] = 0x20 // Fill with spaces
	}
	copy(headline, []byte(req.Msg.Headline))

	// Format the OP_RETURN message: <topic (8 bytes)><headline (64 bytes)><message>
	message := []byte(req.Msg.Topic)
	message = append(message, headline...)

	// add content
	message = append(message, []byte(req.Msg.Content)...)

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := wallet.SendTransaction(ctx,
		connect.NewRequest(&validatorpb.SendTransactionRequest{
			OpReturnMessage: &commonv1.Hex{
				Hex: &wrapperspb.StringValue{
					Value: hex.EncodeToString(message),
				},
			},
		}))
	if err != nil {
		err = fmt.Errorf("enforcer/wallet: could not broadcast news: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast news")
		return nil, err
	}

	log := zerolog.Ctx(ctx)
	log.Info().
		Str("topic", req.Msg.Topic).
		Str("headline", req.Msg.Headline).
		Str("txid", resp.Msg.Txid.String()).
		Msg("broadcast news transaction")

	return connect.NewResponse(&miscv1.BroadcastNewsResponse{
		Txid: resp.Msg.Txid.Hex.Value,
	}), nil
}

// CreateTopic implements miscv1connect.MiscServiceHandler.
func (s *Server) CreateTopic(ctx context.Context, req *connect.Request[miscv1.CreateTopicRequest]) (*connect.Response[miscv1.CreateTopicResponse], error) {
	if req.Msg.Topic == "" {
		err := errors.New("topic must be set")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create topic: topic must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if !opreturns.ValidNewsTopic(req.Msg.Topic) {
		err := errors.New("topic not on valid format, expected 4 bytes (8 hex characters)")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create topic: invalid topic format")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if req.Msg.Name == "" {
		err := errors.New("title must be set")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create topic: title must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if len(req.Msg.Name) > 32 {
		err := errors.New("title cannot be longer than 32 characters")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create topic: title too long")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	exists, err := opreturns.TopicExists(ctx, s.database, req.Msg.Topic)
	if err != nil {
		err = fmt.Errorf("could not check if topic exists: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not check if topic exists")
		return nil, err
	}
	if exists {
		err := errors.New("topic already exists")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create topic: topic already exists")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	// Format the 'create topic' OP_RETURN message: <topic>new<title>
	var message strings.Builder
	message.WriteString(req.Msg.Topic)
	message.WriteString("new")
	message.WriteString(req.Msg.Name)

	// Send the transaction
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := wallet.SendTransaction(ctx,
		connect.NewRequest(&validatorpb.SendTransactionRequest{
			OpReturnMessage: &commonv1.Hex{
				Hex: &wrapperspb.StringValue{
					Value: hex.EncodeToString([]byte(message.String())),
				},
			},
		}))
	if err != nil {
		err = fmt.Errorf("enforcer/wallet: could not broadcast topic creation: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not broadcast topic creation")
		return nil, err
	}

	log := zerolog.Ctx(ctx)
	log.Info().
		Str("topic", req.Msg.Topic).
		Str("title", req.Msg.Name).
		Str("txid", resp.Msg.Txid.String()).
		Msg("broadcast create topic transaction")

	return connect.NewResponse(&miscv1.CreateTopicResponse{
		Txid: resp.Msg.Txid.Hex.Value,
	}), nil
}

// ListTopics implements miscv1connect.MiscServiceHandler.
func (s *Server) ListTopics(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[miscv1.ListTopicsResponse], error) {
	topics, err := opreturns.ListTopics(ctx, s.database)
	if err != nil {
		err = fmt.Errorf("could not list topics: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list topics")
		return nil, err
	}

	return connect.NewResponse(&miscv1.ListTopicsResponse{
		Topics: lo.Map(topics, topicToProto),
	}), nil
}

func topicToProto(topic opreturns.Topic, _ int) *miscv1.Topic {
	return &miscv1.Topic{
		Id:         topic.ID,
		Topic:      topic.Topic,
		Name:       topic.Name,
		CreateTime: timestamppb.New(topic.CreatedAt),
	}
}

// ListCoinNews implements miscv1connect.MiscServiceHandler.
func (s *Server) ListCoinNews(ctx context.Context, req *connect.Request[miscv1.ListCoinNewsRequest]) (*connect.Response[miscv1.ListCoinNewsResponse], error) {
	news, err := opreturns.ListCoinNews(ctx, s.database)
	if err != nil {
		err = fmt.Errorf("could not list coin news: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list coin news")
		return nil, err
	}

	// Filter by topic if provided
	if req.Msg.Topic != nil {
		news = lo.Filter(news, func(coinNews opreturns.CoinNews, _ int) bool {
			return coinNews.Topic == *req.Msg.Topic
		})
	}

	// Sort all news by recency (most recent first)
	sort.Slice(news, func(i, j int) bool {
		return lo.FromPtr(news[i].CreatedAt).After(lo.FromPtr(news[j].CreatedAt))
	})

	// Take up to 100 entries
	if len(news) > 100 {
		news = news[:100]
	}

	return connect.NewResponse(&miscv1.ListCoinNewsResponse{
		CoinNews: lo.Map(news, coinNewsToProto),
	}), nil
}

func coinNewsToProto(coinNews opreturns.CoinNews, _ int) *miscv1.CoinNews {
	return &miscv1.CoinNews{
		Id:         coinNews.ID,
		Topic:      coinNews.Topic,
		Headline:   coinNews.Headline,
		Content:    coinNews.Content,
		CreateTime: timestamppb.New(lo.FromPtr(coinNews.CreatedAt)),
	}
}
