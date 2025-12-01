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
	// Get all pending withdrawal bundles
	bundles, err := s.m4Engine.GetWithdrawalBundles(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("get withdrawal bundles: %w", err)
	}

	// Group bundles by sidechain
	bundlesBySidechain := make(map[uint8][]m4models.WithdrawalBundle)
	for _, b := range bundles {
		if b.Status == "pending" {
			bundlesBySidechain[b.SidechainSlot] = append(bundlesBySidechain[b.SidechainSlot], b)
		}
	}

	// If no pending bundles, M4 is not required
	if len(bundlesBySidechain) == 0 {
		return connect.NewResponse(&m4pb.GenerateM4BytesResponse{
			Hex:            "",
			Interpretation: "Not required - no pending withdrawal bundles.",
		}), nil
	}

	// Get user's vote preferences
	prefs, err := s.m4Engine.GetVotePreferences(ctx)
	if err != nil {
		return nil, fmt.Errorf("get vote preferences: %w", err)
	}

	// Build preference map for quick lookup
	prefMap := make(map[uint8]m4models.VotePreference)
	for _, p := range prefs {
		prefMap[p.SidechainSlot] = p
	}

	// Generate M4 bytes using version 0x02 (2 bytes per sidechain)
	// Only include sidechains that have pending bundles
	var m4Bytes []byte
	m4Bytes = append(m4Bytes, 0x02) // Version

	var interpretation string
	interpretation = "M4 Vote Bytes:\n\n"

	// Process sidechains in order
	for slot := 0; slot <= 255; slot++ {
		sidechainBundles, hasBundles := bundlesBySidechain[uint8(slot)]
		if !hasBundles {
			continue
		}

		pref, hasPreference := prefMap[uint8(slot)]

		var voteBytes [2]byte
		var voteDesc string

		switch {
		case !hasPreference || pref.VoteType == m4models.VoteTypeAbstain:
			// Abstain: 0xFFFF
			voteBytes[0] = 0xFF
			voteBytes[1] = 0xFF
			voteDesc = "Abstain from all withdrawals"
		case pref.VoteType == m4models.VoteTypeAlarm:
			// Alarm (downvote all): 0xFFFE
			voteBytes[0] = 0xFE
			voteBytes[1] = 0xFF
			voteDesc = "Alarm - Downvote all withdrawals"
		case pref.VoteType == m4models.VoteTypeUpvote:
			// Find bundle index by hash
			bundleIndex := uint16(0xFFFF) // Default to abstain if not found
			if pref.BundleHash != nil {
				for i, b := range sidechainBundles {
					if b.BundleHash == *pref.BundleHash {
						bundleIndex = uint16(i)
						break
					}
				}
			}
			if bundleIndex == 0xFFFF {
				voteBytes[0] = 0xFF
				voteBytes[1] = 0xFF
				voteDesc = "Abstain (bundle not found)"
			} else {
				// Little-endian encoding
				voteBytes[0] = byte(bundleIndex & 0xFF)
				voteBytes[1] = byte(bundleIndex >> 8)
				voteDesc = fmt.Sprintf("Upvote withdrawal #%d", bundleIndex)
				if pref.BundleHash != nil {
					hash := *pref.BundleHash
					if len(hash) > 16 {
						hash = hash[:16] + "..."
					}
					voteDesc += fmt.Sprintf(" (%s)", hash)
				}
			}
		}

		m4Bytes = append(m4Bytes, voteBytes[0], voteBytes[1])
		interpretation += fmt.Sprintf("Sidechain #%d: %02x%02x\n  %s\n  (%d pending bundles)\n\n",
			slot, voteBytes[0], voteBytes[1], voteDesc, len(sidechainBundles))
	}

	hexStr := hex.EncodeToString(m4Bytes)

	return connect.NewResponse(&m4pb.GenerateM4BytesResponse{
		Hex:            hexStr,
		Interpretation: interpretation,
	}), nil
}
