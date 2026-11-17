package walletpsbt

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/types/known/emptypb"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1/walletpsbtv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/walletpsbt"
)

var _ rpc.WalletPsbtServiceHandler = new(Server)

type Server struct {
	store *walletpsbt.Store
	// lockCoins hands the orchestrator the coins of every saved transaction.
	lockCoins func(context.Context) error
}

func New(db *sql.DB, lockCoins func(context.Context) error) *Server {
	return &Server{store: walletpsbt.NewStore(db), lockCoins: lockCoins}
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

	out := make([]*pb.PsbtDraft, 0, len(drafts))
	for _, d := range drafts {
		draft, err := draftToProto(d)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
		}
		out = append(out, draft)
	}
	return &pb.ListDraftsResponse{Drafts: out}, nil
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
	if _, err := walletpsbt.Inputs(pd.PsbtBase64); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
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
	if err := s.lockCoins(ctx); err != nil {
		// The caller gets no id for a new draft that failed, so it must not stay.
		if pd.Id == "" {
			if derr := s.store.Delete(ctx, saved.ID); derr != nil {
				err = errors.Join(err, derr)
			}
		}
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Sprintf("lock the coins of the draft: %s", err)).WithCause(err)
	}

	draft, err := draftToProto(saved)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.SaveDraftResponse{Draft: draft}, nil
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
	if err := s.lockCoins(ctx); err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Sprintf("free the coins of the draft: %s", err)).WithCause(err)
	}
	return &emptypb.Empty{}, nil
}

func draftToProto(d walletpsbt.Draft) (*pb.PsbtDraft, error) {
	inputs, err := walletpsbt.Inputs(d.PSBTBase64)
	if err != nil {
		return nil, fmt.Errorf("draft %s: %w", d.ID, err)
	}
	return &pb.PsbtDraft{
		Id:         d.ID,
		WalletId:   d.WalletID,
		Label:      d.Label,
		PsbtBase64: d.PSBTBase64,
		CreatedAt:  d.CreatedAt,
		UpdatedAt:  d.UpdatedAt,
		Txid:       d.Txid,
		Inputs:     inputs,
	}, nil
}
