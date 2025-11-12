package m4

import (
	"context"
	"encoding/hex"
	"fmt"

	"connectrpc.com/connect"
	m4models "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	m4pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1"
)

type Server struct {
	m4Engine *engines.M4Engine
}

func NewServer(m4Engine *engines.M4Engine) *Server {
	return &Server{m4Engine: m4Engine}
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

	pbPrefs := make([]*m4pb.M4Vote, len(prefs))
	for i, pref := range prefs {
		pbPref := &m4pb.M4Vote{
			SidechainSlot: uint32(pref.SidechainSlot),
			VoteType:      string(pref.VoteType),
		}
		if pref.BundleHash != nil {
			pbPref.BundleHash = pref.BundleHash
		}
		pbPrefs[i] = pbPref
	}

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
		return nil, fmt.Errorf("invalid vote type: %s", req.Msg.VoteType)
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
	prefs, err := s.m4Engine.GetVotePreferences(ctx)
	if err != nil {
		return nil, fmt.Errorf("get vote preferences: %w", err)
	}

	m4Bytes := m4models.EncodeVotePreferences(prefs)
	hexStr := hex.EncodeToString(m4Bytes)

	// Generate human-readable interpretation
	interpretation := generateInterpretation(prefs)

	return connect.NewResponse(&m4pb.GenerateM4BytesResponse{
		Hex:            hexStr,
		Interpretation: interpretation,
	}), nil
}

func generateInterpretation(prefs []m4models.VotePreference) string {
	if len(prefs) == 0 {
		return "No vote preferences set"
	}

	var result string
	result += "M4 Vote Settings:\n\n"

	for _, pref := range prefs {
		result += fmt.Sprintf("Sidechain #%d:\n", pref.SidechainSlot)
		switch pref.VoteType {
		case m4models.VoteTypeAbstain:
			result += "  Abstain from all withdrawals\n"
		case m4models.VoteTypeAlarm:
			result += "  Alarm - Downvote all withdrawals\n"
		case m4models.VoteTypeUpvote:
			if pref.BundleHash != nil {
				result += fmt.Sprintf("  Upvote withdrawal: %s\n", *pref.BundleHash)
			} else {
				result += "  Upvote (bundle hash not set)\n"
			}
		}
		result += "\n"
	}

	return result
}
