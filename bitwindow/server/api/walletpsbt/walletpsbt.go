package api_walletpsbt

import (
	"context"
	"database/sql"
	"fmt"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1/walletpsbtv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/walletpsbt"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
)

var _ rpc.WalletPsbtServiceHandler = new(Server)

type Server struct {
	store *walletpsbt.Store
}

func New(db *sql.DB) *Server {
	return &Server{store: walletpsbt.NewStore(db)}
}

func (s *Server) ListDrafts(
	ctx context.Context,
	req *connect.Request[pb.ListDraftsRequest],
) (*connect.Response[pb.ListDraftsResponse], error) {
	if req.Msg.WalletId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("wallet id is required"))
	}

	drafts, err := s.store.List(ctx, req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.ListDraftsResponse{
		Drafts: lo.Map(drafts, func(d walletpsbt.Draft, _ int) *pb.PsbtDraft {
			return draftToProto(d)
		}),
	}), nil
}

func (s *Server) SaveDraft(
	ctx context.Context,
	req *connect.Request[pb.SaveDraftRequest],
) (*connect.Response[pb.SaveDraftResponse], error) {
	pd := req.Msg.Draft
	if pd == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("draft is required"))
	}
	if pd.WalletId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("wallet id is required"))
	}
	if pd.PsbtBase64 == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("psbt is required"))
	}

	saved, err := s.store.Save(ctx, walletpsbt.Draft{
		ID:         pd.Id,
		WalletID:   pd.WalletId,
		Label:      pd.Label,
		PSBTBase64: pd.PsbtBase64,
		Txid:       pd.Txid,
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.SaveDraftResponse{Draft: draftToProto(saved)}), nil
}

func (s *Server) DeleteDraft(
	ctx context.Context,
	req *connect.Request[pb.DeleteDraftRequest],
) (*connect.Response[emptypb.Empty], error) {
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("draft id is required"))
	}
	if err := s.store.Delete(ctx, req.Msg.Id); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&emptypb.Empty{}), nil
}

func draftToProto(d walletpsbt.Draft) *pb.PsbtDraft {
	return &pb.PsbtDraft{
		Id:         d.ID,
		WalletId:   d.WalletID,
		Label:      d.Label,
		PsbtBase64: d.PSBTBase64,
		CreatedAt:  d.CreatedAt,
		UpdatedAt:  d.UpdatedAt,
		Txid:       d.Txid,
	}
}
