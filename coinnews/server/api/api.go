// Package api implements the ConnectRPC handlers for CoinNewsService.
// Pure projection of store/* rows into proto messages — no business
// logic, no caching. The store enforces the spec's first-wins rules;
// the API just renders.
package api

import (
	"context"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"

	"connectrpc.com/connect/v2"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	pb "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

// Handler implements coinnewsv1connect.CoinNewsServiceHandler.
type Handler struct {
	DB  *sql.DB
	Log zerolog.Logger
}

func (h *Handler) ListFrontPage(ctx context.Context, req *pb.ListFrontPageRequest) (*pb.ListFrontPageResponse, error) {
	filter, err := feedFilter(req.Limit, req.Offset, store.SortScoreDesc, req.Subtype, req.TopicHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	items, err := store.ListFeed(ctx, h.DB, filter)
	if err != nil {
		return nil, h.errInternal(err)
	}
	return &pb.ListFrontPageResponse{Items: marshalItems(items)}, nil
}

func (h *Handler) ListNewFeed(ctx context.Context, req *pb.ListNewFeedRequest) (*pb.ListNewFeedResponse, error) {
	filter, err := feedFilter(req.Limit, req.Offset, store.SortNewest, req.Subtype, req.TopicHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	items, err := store.ListFeed(ctx, h.DB, filter)
	if err != nil {
		return nil, h.errInternal(err)
	}
	return &pb.ListNewFeedResponse{Items: marshalItems(items)}, nil
}

func (h *Handler) GetItem(ctx context.Context, req *pb.GetItemRequest) (*pb.GetItemResponse, error) {
	id, err := codec.ParseItemID(req.ItemIdHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	fi, err := store.GetItem(ctx, h.DB, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, connect.Errorf(connect.CodeNotFound, "item %s not found", id)
	}
	if err != nil {
		return nil, h.errInternal(err)
	}
	return &pb.GetItemResponse{Item: marshalItem(fi)}, nil
}

func (h *Handler) ListThread(ctx context.Context, req *pb.ListThreadRequest) (*pb.ListThreadResponse, error) {
	id, err := codec.ParseItemID(req.RootIdHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	rows, err := store.ListThread(ctx, h.DB, id)
	if err != nil {
		return nil, h.errInternal(err)
	}
	out := make([]*pb.Comment, len(rows))
	for i, r := range rows {
		out[i] = marshalComment(r)
	}
	return &pb.ListThreadResponse{Comments: out}, nil
}

func (h *Handler) ListByAuthor(ctx context.Context, req *pb.ListByAuthorRequest) (*pb.ListByAuthorResponse, error) {
	xpkBytes, err := hex.DecodeString(req.AuthorXpkHex)
	if err != nil || len(xpkBytes) != 32 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "author_xpk_hex must be 32 bytes hex")
	}
	var xpk [32]byte
	copy(xpk[:], xpkBytes)
	items, err := store.ListByAuthor(ctx, h.DB, xpk, req.Limit, req.Offset)
	if err != nil {
		return nil, h.errInternal(err)
	}
	return &pb.ListByAuthorResponse{Items: marshalItems(items)}, nil
}

func (h *Handler) ListByTopic(ctx context.Context, req *pb.ListByTopicRequest) (*pb.ListByTopicResponse, error) {
	topic, err := parseTopic(req.TopicHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	items, err := store.ListFeed(ctx, h.DB, store.FeedFilter{
		Topic:  &topic,
		Sort:   store.SortNewest,
		Limit:  req.Limit,
		Offset: req.Offset,
	})
	if err != nil {
		return nil, h.errInternal(err)
	}
	return &pb.ListByTopicResponse{Items: marshalItems(items)}, nil
}

func (h *Handler) ListTopics(ctx context.Context, _ *emptypb.Empty) (*pb.ListTopicsResponse, error) {
	topics, err := store.ListTopics(ctx, h.DB)
	if err != nil {
		return nil, h.errInternal(err)
	}
	out := make([]*pb.Topic, len(topics))
	for i, t := range topics {
		out[i] = &pb.Topic{
			TopicHex:      hex.EncodeToString(t.Topic[:]),
			Name:          t.Name,
			RetentionDays: t.RetentionDays,
			CreatedHeight: t.CreatedHeight,
			Txid:          t.TxID,
		}
	}
	return &pb.ListTopicsResponse{Topics: out}, nil
}

func feedFilter(limit, offset uint32, sort store.FeedSort, sub *pb.Subtype, topicHex *string) (store.FeedFilter, error) {
	f := store.FeedFilter{Sort: sort, Limit: limit, Offset: offset}
	if sub != nil {
		s := codec.Subtype(*sub)
		f.Subtype = &s
	}
	if topicHex != nil && *topicHex != "" {
		t, err := parseTopic(*topicHex)
		if err != nil {
			return store.FeedFilter{}, err
		}
		f.Topic = &t
	}
	return f, nil
}

func parseTopic(s string) (codec.Topic, error) {
	raw, err := hex.DecodeString(s)
	if err != nil || len(raw) != 4 {
		return codec.Topic{}, fmt.Errorf("topic_hex must be 4 bytes hex")
	}
	var t codec.Topic
	copy(t[:], raw)
	return t, nil
}

func marshalItems(in []store.FeedItem) []*pb.Item {
	out := make([]*pb.Item, len(in))
	for i, fi := range in {
		out[i] = marshalItem(fi)
	}
	return out
}

func marshalItem(fi store.FeedItem) *pb.Item {
	return &pb.Item{
		ItemIdHex:    hex.EncodeToString(fi.ItemID[:]),
		TopicHex:     hex.EncodeToString(fi.Topic[:]),
		Headline:     fi.Headline,
		Url:          fi.URL,
		Body:         fi.Body,
		Subtype:      pb.Subtype(fi.Subtype),
		Lang:         fi.Lang,
		Nsfw:         fi.NSFW,
		AuthorXpkHex: hex.EncodeToString(fi.AuthorXPK[:]),
		BlockHeight:  fi.BlockHeight,
		BlockTime:    timestamppb.New(fi.BlockTime),
		Points:       int32(fi.Points),
		CommentCount: int32(fi.CommentCount),
		Score:        fi.Score,
		Txid:         fi.TxID,
		Vout:         fi.Vout,
		Upvotes:      int32(fi.Upvotes),
		Downvotes:    int32(fi.Downvotes),
	}
}

func marshalComment(c store.CommentRow) *pb.Comment {
	return &pb.Comment{
		ItemIdHex:    hex.EncodeToString(c.ItemID[:]),
		ParentIdHex:  hex.EncodeToString(c.Parent[:]),
		AuthorXpkHex: hex.EncodeToString(c.AuthorXPK[:]),
		Body:         c.Body,
		Url:          c.URL,
		Lang:         c.Lang,
		ReplyQuote:   c.ReplyQuote,
		BlockHeight:  c.BlockHeight,
		BlockTime:    timestamppb.New(c.BlockTime),
		Points:       int32(c.Points),
		Score:        c.Score,
		Txid:         c.TxID,
		Vout:         c.Vout,
	}
}

func (h *Handler) errInternal(err error) error {
	h.Log.Error().Err(err).Msg("api call failed")
	return connect.NewError(connect.CodeInternal, "internal error")
}
