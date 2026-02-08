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
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	miscv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
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
	timestampEngine *engines.TimestampEngine,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
) *Server {
	return &Server{
		database:        database,
		wallet:          wallet,
		timestampEngine: timestampEngine,
		bitcoind:        bitcoind,
	}
}

type Server struct {
	database        *sql.DB
	wallet          *service.Service[validatorrpc.WalletServiceClient]
	timestampEngine *engines.TimestampEngine
	bitcoind        *service.Service[corerpc.BitcoinServiceClient]
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
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	topicID, err := opreturns.ValidNewsTopicID(req.Msg.Topic)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if req.Msg.Headline == "" {
		err := errors.New("headline must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if len([]byte(req.Msg.Headline)) > 64 {
		err := errors.New("headline cannot be longer than 64 bytes")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	exists, err := opreturns.TopicExists(ctx, s.database, topicID)
	if err != nil {
		return nil, fmt.Errorf("check if topic exists: %w", err)
	}
	if !exists {
		err := errors.New("topic does not exist")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

	sendReq := &validatorpb.SendTransactionRequest{
		OpReturnMessage: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: hex.EncodeToString(
					opreturns.EncodeNewsMessage(
						topicID, req.Msg.Headline, req.Msg.Content,
					),
				),
			},
		},
	}

	// Set fee rate if specified
	if req.Msg.FeeSatPerVbyte > 0 {
		sendReq.FeeRate = &validatorpb.SendTransactionRequest_FeeRate{
			Fee: &validatorpb.SendTransactionRequest_FeeRate_SatPerVbyte{
				SatPerVbyte: req.Msg.FeeSatPerVbyte,
			},
		}
	} else if req.Msg.FeeSats > 0 {
		sendReq.FeeRate = &validatorpb.SendTransactionRequest_FeeRate{
			Fee: &validatorpb.SendTransactionRequest_FeeRate_Sats{
				Sats: req.Msg.FeeSats,
			},
		}
	}

	resp, err := wallet.SendTransaction(ctx, connect.NewRequest(sendReq))
	if err != nil {
		return nil, fmt.Errorf("broadcast news: %w", err)
	}

	log := zerolog.Ctx(ctx)
	log.Info().
		Hex("topic", topicID[:]).
		Str("headline", req.Msg.Headline).
		Str("txid", resp.Msg.Txid.String()).
		Msg("broadcast news transaction")

	return connect.NewResponse(&miscv1.BroadcastNewsResponse{
		Txid: resp.Msg.Txid.Hex.Value,
	}), nil
}

// CreateTopic implements miscv1connect.MiscServiceHandler.
func (s *Server) CreateTopic(ctx context.Context, req *connect.Request[miscv1.CreateTopicRequest]) (*connect.Response[miscv1.CreateTopicResponse], error) {
	topicID, err := opreturns.ValidNewsTopicID(req.Msg.Topic)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if req.Msg.Name == "" {
		err := errors.New("title must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if req.Msg.Name == "" {
		err := errors.New("title must be set")
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create topic: title must be set")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	if len([]byte(req.Msg.Name)) > 64 {
		err := errors.New("title cannot be longer than 64 bytes")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	exists, err := opreturns.TopicExists(ctx, s.database, topicID)
	if err != nil {
		return nil, err
	}

	if exists {
		err := errors.New("topic already exists")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// Calculate retention days (default to 7)
	retentionDays := req.Msg.RetentionDays
	if retentionDays == 0 {
		retentionDays = 7 // Default to 7 days
	}

	// Send the transaction
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := wallet.SendTransaction(ctx,
		connect.NewRequest(&validatorpb.SendTransactionRequest{
			OpReturnMessage: &commonv1.Hex{
				Hex: &wrapperspb.StringValue{
					Value: hex.EncodeToString(
						opreturns.EncodeTopicCreationMessage(topicID, req.Msg.Name, retentionDays),
					),
				},
			},
		}))
	if err != nil {
		return nil, fmt.Errorf("broadcast topic creation: %w", err)
	}
	txid := resp.Msg.Txid.Hex.Value

	// Insert topic into database immediately so it's available in the UI
	// before the transaction is mined
	if err := opreturns.CreateTopic(ctx, s.database, topicID, req.Msg.Name, txid, false, retentionDays); err != nil {
		// Log but don't fail - topic will also be created when block is processed
		zerolog.Ctx(ctx).Warn().Err(err).Msg("failed to insert topic immediately")
	}

	log := zerolog.Ctx(ctx)
	log.Info().
		Stringer("topic", topicID).
		Str("title", req.Msg.Name).
		Str("txid", txid).
		Msg("broadcast create topic transaction")

	return connect.NewResponse(&miscv1.CreateTopicResponse{
		Txid: txid,
	}), nil
}

// ListTopics implements miscv1connect.MiscServiceHandler.
func (s *Server) ListTopics(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[miscv1.ListTopicsResponse], error) {
	topics, err := opreturns.ListTopics(ctx, s.database)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&miscv1.ListTopicsResponse{
		Topics: lo.Map(topics, topicToProto),
	}), nil
}

func topicToProto(topic opreturns.Topic, _ int) *miscv1.Topic {
	return &miscv1.Topic{
		Id:            topic.ID,
		Topic:         topic.Topic.String(),
		Name:          topic.Name,
		CreateTime:    timestamppb.New(topic.CreatedAt),
		Confirmed:     topic.Confirmed,
		Txid:          topic.Txid,
		RetentionDays: topic.RetentionDays,
	}
}

// ListCoinNews implements miscv1connect.MiscServiceHandler.
func (s *Server) ListCoinNews(ctx context.Context, req *connect.Request[miscv1.ListCoinNewsRequest]) (*connect.Response[miscv1.ListCoinNewsResponse], error) {
	var topicID opreturns.TopicID
	if req.Msg.Topic != nil {
		var err error
		topicID, err = opreturns.ValidNewsTopicID(*req.Msg.Topic)
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
	}
	news, err := opreturns.ListCoinNews(ctx, s.database)
	if err != nil {
		return nil, fmt.Errorf("list coin news: %w", err)
	}

	// Filter by topic if provided
	if req.Msg.Topic != nil {
		news = lo.Filter(news, func(coinNews opreturns.CoinNews, _ int) bool {
			return coinNews.Topic == topicID
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
	// Sanitize strings to valid UTF-8 for protobuf marshalling
	headline := strings.ToValidUTF8(coinNews.Headline, "")
	content := strings.ToValidUTF8(coinNews.Content, "")

	return &miscv1.CoinNews{
		Id:         coinNews.ID,
		Topic:      coinNews.Topic.String(),
		Headline:   headline,
		Content:    content,
		FeeSats:    int64(coinNews.Fee),
		CreateTime: timestamppb.New(lo.FromPtr(coinNews.CreatedAt)),
	}
}

// TimestampFile implements miscv1connect.MiscServiceHandler.
func (s *Server) TimestampFile(ctx context.Context, req *connect.Request[miscv1.TimestampFileRequest]) (*connect.Response[miscv1.TimestampFileResponse], error) {
	if req.Msg.Filename == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("filename must be set"))
	}
	if len(req.Msg.FileData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("file data must be set"))
	}

	ts, err := s.timestampEngine.TimestampFile(ctx, req.Msg.Filename, req.Msg.FileData)
	if err != nil {
		return nil, fmt.Errorf("timestamp file: %w", err)
	}

	txid := ""
	if ts.TxID != nil {
		txid = *ts.TxID
	}

	return connect.NewResponse(&miscv1.TimestampFileResponse{
		Id:       ts.ID,
		FileHash: ts.FileHash,
		Txid:     txid,
	}), nil
}

// ListTimestamps implements miscv1connect.MiscServiceHandler.
func (s *Server) ListTimestamps(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[miscv1.ListTimestampsResponse], error) {
	tsList, err := s.timestampEngine.ListTimestamps(ctx)
	if err != nil {
		return nil, fmt.Errorf("list timestamps: %w", err)
	}

	currentBlockHeight := s.getCurrentBlockHeight(ctx)

	return connect.NewResponse(&miscv1.ListTimestampsResponse{
		Timestamps: lo.Map(tsList, func(ts timestamps.FileTimestamp, _ int) *miscv1.FileTimestamp {
			return timestampToProto(ts, currentBlockHeight)
		}),
	}), nil
}

func timestampToProto(ts timestamps.FileTimestamp, currentBlockHeight int64) *miscv1.FileTimestamp {
	proto := &miscv1.FileTimestamp{
		Id:        ts.ID,
		Filename:  ts.Filename,
		FileHash:  ts.FileHash,
		Status:    string(ts.Status),
		CreatedAt: timestamppb.New(ts.CreatedAt),
	}

	if ts.TxID != nil {
		proto.Txid = ts.TxID
	}
	if ts.BlockHeight != nil {
		proto.BlockHeight = ts.BlockHeight
		if currentBlockHeight > 0 {
			proto.Confirmations = uint32(currentBlockHeight - *ts.BlockHeight + 1)
		}
	}
	if ts.ConfirmedAt != nil {
		proto.ConfirmedAt = timestamppb.New(*ts.ConfirmedAt)
	}

	return proto
}

// VerifyTimestamp implements miscv1connect.MiscServiceHandler.
func (s *Server) VerifyTimestamp(ctx context.Context, req *connect.Request[miscv1.VerifyTimestampRequest]) (*connect.Response[miscv1.VerifyTimestampResponse], error) {
	if len(req.Msg.FileData) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("file data must be set"))
	}

	filename := ""
	if req.Msg.Filename != nil {
		filename = *req.Msg.Filename
	}

	ts, err := s.timestampEngine.VerifyTimestamp(ctx, req.Msg.FileData, filename)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}

	currentBlockHeight := s.getCurrentBlockHeight(ctx)

	return connect.NewResponse(&miscv1.VerifyTimestampResponse{
		Timestamp: timestampToProto(*ts, currentBlockHeight),
		Message:   fmt.Sprintf("File verified! Transaction: %s", *ts.TxID),
	}), nil
}

func (s *Server) getCurrentBlockHeight(ctx context.Context) int64 {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return 0
	}
	info, err := bitcoind.GetBlockchainInfo(ctx, &connect.Request[corepb.GetBlockchainInfoRequest]{})
	if err != nil {
		return 0
	}
	return int64(info.Msg.Blocks)
}
