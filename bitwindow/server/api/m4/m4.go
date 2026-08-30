package m4

import (
	"context"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"slices"

	"connectrpc.com/connect"
	m4models "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	m4pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
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
		return nil, fmt.Errorf("invalid vote type: %s", req.Msg.VoteType)
	}

	// Validate sidechain slot (0-255) before narrowing to uint8
	if req.Msg.SidechainSlot > 255 {
		return nil, fmt.Errorf("invalid sidechain slot: %d (must be 0-255)", req.Msg.SidechainSlot)
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
	prefMap := lo.KeyBy(prefs, func(p m4models.VotePreference) uint8 {
		return p.SidechainSlot
	})

	enforcer, err := s.enforcer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("enforcer: %w", err)
	}
	sidechains, err := enforcer.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get sidechains: %w", err)
	}
	slots := lo.Map(sidechains.Msg.GetSidechains(), func(sc *validatorpb.GetSidechainsResponse_SidechainInfo, _ int) uint8 {
		return uint8(sc.GetSidechainNumber().GetValue())
	})
	slices.Sort(slots)

	votes := make([]uint16, len(slots))
	descs := make([]string, len(slots))
	for i, slot := range slots {
		sidechainBundles := bundlesBySidechain[slot]
		pref, hasPreference := prefMap[slot]

		votes[i] = m4models.VoteAbstain
		descs[i] = "Abstain from all withdrawals"
		switch {
		case !hasPreference || pref.VoteType == m4models.VoteTypeAbstain:
		case pref.VoteType == m4models.VoteTypeAlarm:
			votes[i] = m4models.VoteAlarm
			descs[i] = "Alarm - Downvote all withdrawals"
		case pref.VoteType == m4models.VoteTypeUpvote:
			descs[i] = "Abstain (bundle not found)"
			if pref.BundleHash == nil {
				break
			}
			for j, b := range sidechainBundles {
				if b.BundleHash != *pref.BundleHash {
					continue
				}
				votes[i] = uint16(j)
				hash := *pref.BundleHash
				if len(hash) > 16 {
					hash = hash[:16] + "..."
				}
				descs[i] = fmt.Sprintf("Upvote withdrawal #%d (%s)", j, hash)
				break
			}
		}
	}

	// The enforcer rejects a two-byte vector when every vote fits in one byte.
	oneByte := lo.EveryBy(votes, func(v uint16) bool {
		return v <= 253 || v >= m4models.VoteAlarm
	})

	m4Bytes := []byte{0x02}
	if oneByte {
		m4Bytes = []byte{0x01}
	}
	interpretation := "M4 Vote Bytes:\n\n"
	for i, slot := range slots {
		var voteBytes []byte
		if oneByte {
			voteBytes = []byte{byte(votes[i])}
		} else {
			voteBytes = binary.LittleEndian.AppendUint16(nil, votes[i])
		}
		m4Bytes = append(m4Bytes, voteBytes...)
		interpretation += fmt.Sprintf("Sidechain #%d: %x\n  %s\n  (%d pending bundles)\n\n",
			slot, voteBytes, descs[i], len(bundlesBySidechain[slot]))
	}

	hexStr := hex.EncodeToString(m4Bytes)

	return connect.NewResponse(&m4pb.GenerateM4BytesResponse{
		Hex:            hexStr,
		Interpretation: interpretation,
	}), nil
}
