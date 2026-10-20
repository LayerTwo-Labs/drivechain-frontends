package m4

import (
	"context"
	"encoding/hex"
	"fmt"
	"sync"

	"connectrpc.com/connect/v2"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	m4pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

type Server struct {
	m4Engine      *engines.M4Engine
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient]
	upvoteMu      sync.Mutex
}

func NewServer(m4Engine *engines.M4Engine, blockProducer *service.Service[validatorrpc.BlockProducerServiceClient]) *Server {
	return &Server{m4Engine: m4Engine, blockProducer: blockProducer}
}

func (s *Server) GetM4History(
	ctx context.Context,
	req *m4pb.GetM4HistoryRequest,
) (*m4pb.GetM4HistoryResponse, error) {
	limit := int(req.Limit)
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
				BundleHash:    vote.BundleHash,
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

	return &m4pb.GetM4HistoryResponse{
		History: pbHistory,
	}, nil
}

func (s *Server) GetVotes(
	ctx context.Context,
	req *m4pb.GetVotesRequest,
) (*m4pb.GetVotesResponse, error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("block producer: %w", err)
	}
	state, err := producer.GetBlockProducerState(ctx, &validatorpb.GetBlockProducerStateRequest{})
	if err != nil {
		return nil, fmt.Errorf("get block producer state: %w", err)
	}

	upvotes := lo.Map(state.GetExplicitBundleAcks(), func(ack *validatorpb.WithdrawalBundleAck, _ int) *m4pb.BundleUpvote {
		return &m4pb.BundleUpvote{
			SidechainSlot: ack.GetSidechainNumber().GetValue(),
			M6Id:          ack.GetM6Id().GetHex().GetValue(),
		}
	})

	return &m4pb.GetVotesResponse{
		Policy:  votePolicyFromEnforcer[state.GetWithdrawalBundlePolicy()],
		Upvotes: upvotes,
	}, nil
}

func (s *Server) SetBundleUpvote(
	ctx context.Context,
	req *m4pb.SetBundleUpvoteRequest,
) (*m4pb.SetBundleUpvoteResponse, error) {
	slot := req.SidechainSlot
	if slot > 255 {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "invalid sidechain slot: %d", slot)
	}
	if req.M6Id != nil {
		m6id, err := hex.DecodeString(req.GetM6Id())
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("decode m6id %q: %s", req.GetM6Id(), err)).WithCause(err)
		}
		if len(m6id) != 32 {
			return nil, connect.Errorf(connect.CodeInvalidArgument, "m6id %q is %d bytes, want 32", req.GetM6Id(), len(m6id))
		}
	}

	s.upvoteMu.Lock()
	defer s.upvoteMu.Unlock()

	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("block producer: %w", err)
	}
	state, err := producer.GetBlockProducerState(ctx, &validatorpb.GetBlockProducerStateRequest{})
	if err != nil {
		return nil, fmt.Errorf("get block producer state: %w", err)
	}

	// The enforcer upvotes the first ACKed bundle of a sidechain, so a sidechain must hold one ACK at most.
	for _, ack := range state.GetExplicitBundleAcks() {
		m6id := ack.GetM6Id().GetHex().GetValue()
		if ack.GetSidechainNumber().GetValue() != slot || m6id == req.GetM6Id() {
			continue
		}
		if err := setBundleAck(ctx, producer, slot, m6id, false); err != nil {
			return nil, err
		}
	}
	if req.M6Id != nil {
		if err := setBundleAck(ctx, producer, slot, req.GetM6Id(), true); err != nil {
			return nil, err
		}
	}

	return &m4pb.SetBundleUpvoteResponse{}, nil
}

func (s *Server) SetVotePolicy(
	ctx context.Context,
	req *m4pb.SetVotePolicyRequest,
) (*m4pb.SetVotePolicyResponse, error) {
	policy, ok := lo.FindKey(votePolicyFromEnforcer, req.Policy)
	if !ok || req.Policy == m4pb.VotePolicy_VOTE_POLICY_UNSPECIFIED {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "invalid vote policy: %s", req.Policy)
	}

	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("block producer: %w", err)
	}
	if _, err := producer.SetWithdrawalBundlePolicy(ctx, &validatorpb.SetWithdrawalBundlePolicyRequest{
		Policy: policy,
	}); err != nil {
		return nil, fmt.Errorf("set withdrawal bundle policy: %w", err)
	}

	return &m4pb.SetVotePolicyResponse{}, nil
}

var votePolicyFromEnforcer = map[validatorpb.WithdrawalBundlePolicy]m4pb.VotePolicy{
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_UNSPECIFIED: m4pb.VotePolicy_VOTE_POLICY_UNSPECIFIED,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_NONE:        m4pb.VotePolicy_VOTE_POLICY_ABSTAIN,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_KNOWN:       m4pb.VotePolicy_VOTE_POLICY_UPVOTE_KNOWN,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_ALL:         m4pb.VotePolicy_VOTE_POLICY_UPVOTE_ALL,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_ALARM:       m4pb.VotePolicy_VOTE_POLICY_ALARM,
}

func setBundleAck(ctx context.Context, producer validatorrpc.BlockProducerServiceClient, slot uint32, m6id string, ack bool) error {
	_, err := producer.SetWithdrawalBundleAck(ctx, &validatorpb.SetWithdrawalBundleAckRequest{
		SidechainNumber: wrapperspb.UInt32(slot),
		M6Id:            &commonv1.ConsensusHex{Hex: wrapperspb.String(m6id)},
		Ack:             ack,
	})
	if err != nil {
		return fmt.Errorf("set withdrawal bundle ack for sidechain %d: %w", slot, err)
	}
	return nil
}
