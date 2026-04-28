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

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	pb "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

// Handler implements coinnewsv1connect.CoinNewsServiceHandler.
type Handler struct {
	DB *sql.DB
}

func (h *Handler) ListFrontPage(ctx context.Context, req *connect.Request[pb.ListFrontPageRequest]) (*connect.Response[pb.ListFrontPageResponse], error) {
	items, err := store.ListFeed(ctx, h.DB, feedFilter(req.Msg.Limit, req.Msg.Offset, store.SortScoreDesc, req.Msg.Subtype, req.Msg.TopicHex))
	if err != nil {
		return nil, errInternal(err)
	}
	return connect.NewResponse(&pb.ListFrontPageResponse{Items: marshalItems(items)}), nil
}

func (h *Handler) ListNewFeed(ctx context.Context, req *connect.Request[pb.ListNewFeedRequest]) (*connect.Response[pb.ListNewFeedResponse], error) {
	items, err := store.ListFeed(ctx, h.DB, feedFilter(req.Msg.Limit, req.Msg.Offset, store.SortNewest, req.Msg.Subtype, req.Msg.TopicHex))
	if err != nil {
		return nil, errInternal(err)
	}
	return connect.NewResponse(&pb.ListNewFeedResponse{Items: marshalItems(items)}), nil
}

func (h *Handler) GetItem(ctx context.Context, req *connect.Request[pb.GetItemRequest]) (*connect.Response[pb.GetItemResponse], error) {
	id, err := codec.ParseItemID(req.Msg.ItemIdHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	fi, err := store.GetItem(ctx, h.DB, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("item %s not found", id))
	}
	if err != nil {
		return nil, errInternal(err)
	}
	return connect.NewResponse(&pb.GetItemResponse{Item: marshalItem(fi)}), nil
}

func (h *Handler) ListThread(ctx context.Context, req *connect.Request[pb.ListThreadRequest]) (*connect.Response[pb.ListThreadResponse], error) {
	id, err := codec.ParseItemID(req.Msg.RootIdHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	rows, err := store.ListThread(ctx, h.DB, id)
	if err != nil {
		return nil, errInternal(err)
	}
	out := make([]*pb.Comment, len(rows))
	for i, r := range rows {
		out[i] = marshalComment(r)
	}
	return connect.NewResponse(&pb.ListThreadResponse{Comments: out}), nil
}

func (h *Handler) ListByAuthor(ctx context.Context, req *connect.Request[pb.ListByAuthorRequest]) (*connect.Response[pb.ListByAuthorResponse], error) {
	xpkBytes, err := hex.DecodeString(req.Msg.AuthorXpkHex)
	if err != nil || len(xpkBytes) != 32 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("author_xpk_hex must be 32 bytes hex"))
	}
	var xpk [32]byte
	copy(xpk[:], xpkBytes)
	items, err := store.ListByAuthor(ctx, h.DB, xpk, req.Msg.Limit, req.Msg.Offset)
	if err != nil {
		return nil, errInternal(err)
	}
	return connect.NewResponse(&pb.ListByAuthorResponse{Items: marshalItems(items)}), nil
}

func (h *Handler) ListByTopic(ctx context.Context, req *connect.Request[pb.ListByTopicRequest]) (*connect.Response[pb.ListByTopicResponse], error) {
	topic, err := parseTopic(req.Msg.TopicHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	items, err := store.ListFeed(ctx, h.DB, store.FeedFilter{
		Topic:  &topic,
		Sort:   store.SortNewest,
		Limit:  req.Msg.Limit,
		Offset: req.Msg.Offset,
	})
	if err != nil {
		return nil, errInternal(err)
	}
	return connect.NewResponse(&pb.ListByTopicResponse{Items: marshalItems(items)}), nil
}

func (h *Handler) ListTopics(ctx context.Context, _ *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListTopicsResponse], error) {
	topics, err := store.ListTopics(ctx, h.DB)
	if err != nil {
		return nil, errInternal(err)
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
	return connect.NewResponse(&pb.ListTopicsResponse{Topics: out}), nil
}

func feedFilter(limit, offset uint32, sort store.FeedSort, sub *pb.Subtype, topicHex *string) store.FeedFilter {
	f := store.FeedFilter{Sort: sort, Limit: limit, Offset: offset}
	if sub != nil {
		s := codec.Subtype(*sub)
		f.Subtype = &s
	}
	if topicHex != nil && *topicHex != "" {
		t, err := parseTopic(*topicHex)
		if err == nil {
			f.Topic = &t
		}
	}
	return f
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
	}
}

func errInternal(err error) error {
	return connect.NewError(connect.CodeInternal, err)
}
