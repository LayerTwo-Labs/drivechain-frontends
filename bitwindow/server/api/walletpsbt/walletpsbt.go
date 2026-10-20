package walletpsbt

import (
	"context"
	"database/sql"

	"connectrpc.com/connect/v2"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1/walletpsbtv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/walletpsbt"
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
	req *pb.ListDraftsRequest,
) (*pb.ListDraftsResponse, error) {
	if req.WalletId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "wallet id is required")
	}

	drafts, err := s.store.List(ctx, req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.ListDraftsResponse{
		Drafts: lo.Map(drafts, func(d walletpsbt.Draft, _ int) *pb.PsbtDraft {
			return draftToProto(d)
		}),
	}, nil
}

func (s *Server) SaveDraft(
	ctx context.Context,
	req *pb.SaveDraftRequest,
) (*pb.SaveDraftResponse, error) {
	pd := req.Draft
	if pd == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, "draft is required")
	}
	if pd.WalletId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "wallet id is required")
	}
	if pd.PsbtBase64 == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "psbt is required")
	}

	saved, err := s.store.Save(ctx, walletpsbt.Draft{
		ID:         pd.Id,
		WalletID:   pd.WalletId,
		Label:      pd.Label,
		PSBTBase64: pd.PsbtBase64,
		Txid:       pd.Txid,
	})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.SaveDraftResponse{Draft: draftToProto(saved)}, nil
}

func (s *Server) DeleteDraft(
	ctx context.Context,
	req *pb.DeleteDraftRequest,
) (*emptypb.Empty, error) {
	if req.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "draft id is required")
	}
	if err := s.store.Delete(ctx, req.Id); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &emptypb.Empty{}, nil
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
