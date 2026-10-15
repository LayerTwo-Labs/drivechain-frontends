package m4

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	m4models "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	m4pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/samber/lo"
)

type Server struct {
	m4Engine *engines.M4Engine
	enforcer *service.Service[validatorrpc.ValidatorServiceClient]
}

func NewServer(m4Engine *engines.M4Engine, enforcer *service.Service[validatorrpc.ValidatorServiceClient]) *Server {
	return &Server{m4Engine: m4Engine, enforcer: enforcer}
}

func (s *Server) GetM4History(
	ctx context.Context,
	req *connect.Request[m4pb.GetM4HistoryRequest],
) (*connect.Response[m4pb.GetM4HistoryResponse], error) {
	limit := int(req.Msg.Limit)
	if limit == 0 {
		limit = 6 // Default to last 6 blocks
	}

	history, err := s.m4Engine.GetM4History(ctx, limit)
	if err != nil {
		return nil, fmt.Errorf("get M4 history: %w", err)
	}

	pbHistory := make([]*m4pb.M4HistoryEntry, len(history))
	for i, msg := range history {
		pbVotes := make([]*m4pb.M4Vote, len(msg.Votes))
		for j, vote := range msg.Votes {
			pbVote := &m4pb.M4Vote{
				SidechainSlot: uint32(vote.SidechainSlot),
				VoteType:      string(vote.VoteType),
			}
			if vote.BundleHash != nil {
				pbVote.BundleHash = vote.BundleHash
			}
			if vote.BundleIndex != nil {
				idx := uint32(*vote.BundleIndex)
				pbVote.BundleIndex = &idx
			}
			pbVotes[j] = pbVote
		}

		pbHistory[i] = &m4pb.M4HistoryEntry{
			BlockHeight: msg.BlockHeight,
			BlockHash:   msg.BlockHash,
			BlockTime:   msg.BlockTime.Unix(),
			Version:     uint32(msg.Version),
			Votes:       pbVotes,
		}
	}

	return connect.NewResponse(&m4pb.GetM4HistoryResponse{
		History: pbHistory,
	}), nil
}

func (s *Server) GetVotePreferences(
	ctx context.Context,
	req *connect.Request[m4pb.GetVotePreferencesRequest],
) (*connect.Response[m4pb.GetVotePreferencesResponse], error) {
	prefs, err := s.m4Engine.GetVotePreferences(ctx)
	if err != nil {
		return nil, fmt.Errorf("get vote preferences: %w", err)
	}

	pbPrefs := lo.Map(prefs, func(pref m4models.VotePreference, _ int) *m4pb.M4Vote {
		pbPref := &m4pb.M4Vote{
			SidechainSlot: uint32(pref.SidechainSlot),
			VoteType:      string(pref.VoteType),
		}
		if pref.BundleHash != nil {
			pbPref.BundleHash = pref.BundleHash
		}
		return pbPref
	})

	return connect.NewResponse(&m4pb.GetVotePreferencesResponse{
		Preferences: pbPrefs,
	}), nil
}

func (s *Server) SetVotePreference(
	ctx context.Context,
	req *connect.Request[m4pb.SetVotePreferenceRequest],
) (*connect.Response[m4pb.SetVotePreferenceResponse], error) {
	voteType := m4models.VoteType(req.Msg.VoteType)

	// Validate vote type
	if voteType != m4models.VoteTypeAbstain &&
		voteType != m4models.VoteTypeAlarm &&
		voteType != m4models.VoteTypeUpvote {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid vote type: %s", req.Msg.VoteType))
	}

	// Validate sidechain slot (0-255) before narrowing to uint8
	if req.Msg.SidechainSlot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid sidechain slot: %d (must be 0-255)", req.Msg.SidechainSlot))
	}

	var bundleHash *string
	if req.Msg.BundleHash != nil {
		bundleHash = req.Msg.BundleHash
	}

	err := s.m4Engine.SetVotePreference(
		ctx,
		uint8(req.Msg.SidechainSlot),
		voteType,
		bundleHash,
	)
	if err != nil {
		return nil, fmt.Errorf("set vote preference: %w", err)
	}

	return connect.NewResponse(&m4pb.SetVotePreferenceResponse{
		Success: true,
	}), nil
}

func (s *Server) GenerateM4Bytes(
	ctx context.Context,
	req *connect.Request[m4pb.GenerateM4BytesRequest],
) (*connect.Response[m4pb.GenerateM4BytesResponse], error) {
	hexStr, interpretation, err := s.m4Engine.GenerateM4Bytes(ctx, s.enforcer)
	if err != nil {
		return nil, fmt.Errorf("generate M4 bytes: %w", err)
	}

	return connect.NewResponse(&m4pb.GenerateM4BytesResponse{
		Hex:            hexStr,
		Interpretation: interpretation,
	}), nil
}
