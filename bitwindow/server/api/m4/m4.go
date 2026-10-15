package m4

import (
	"context"
	"encoding/hex"
	"fmt"
	"sync"

	"connectrpc.com/connect"
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

func (s *Server) GetVotes(
	ctx context.Context,
	req *connect.Request[m4pb.GetVotesRequest],
) (*connect.Response[m4pb.GetVotesResponse], error) {
	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("block producer: %w", err)
	}
	state, err := producer.GetBlockProducerState(ctx, connect.NewRequest(&validatorpb.GetBlockProducerStateRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get block producer state: %w", err)
	}

	upvotes := lo.Map(state.Msg.GetExplicitBundleAcks(), func(ack *validatorpb.WithdrawalBundleAck, _ int) *m4pb.BundleUpvote {
		return &m4pb.BundleUpvote{
			SidechainSlot: ack.GetSidechainNumber().GetValue(),
			M6Id:          ack.GetM6Id().GetHex().GetValue(),
		}
	})

	return connect.NewResponse(&m4pb.GetVotesResponse{
		Policy:  votePolicyFromEnforcer[state.Msg.GetWithdrawalBundlePolicy()],
		Upvotes: upvotes,
	}), nil
}

func (s *Server) SetBundleUpvote(
	ctx context.Context,
	req *connect.Request[m4pb.SetBundleUpvoteRequest],
) (*connect.Response[m4pb.SetBundleUpvoteResponse], error) {
	slot := req.Msg.SidechainSlot
	if slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid sidechain slot: %d", slot))
	}
	if req.Msg.M6Id != nil {
		m6id, err := hex.DecodeString(req.Msg.GetM6Id())
		if err != nil || len(m6id) != 32 {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid m6id: %q", req.Msg.GetM6Id()))
		}
	}

	s.upvoteMu.Lock()
	defer s.upvoteMu.Unlock()

	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("block producer: %w", err)
	}
	state, err := producer.GetBlockProducerState(ctx, connect.NewRequest(&validatorpb.GetBlockProducerStateRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get block producer state: %w", err)
	}

	// The enforcer upvotes the first ACKed bundle of a sidechain, so a sidechain must hold one ACK at most.
	for _, ack := range state.Msg.GetExplicitBundleAcks() {
		m6id := ack.GetM6Id().GetHex().GetValue()
		if ack.GetSidechainNumber().GetValue() != slot || m6id == req.Msg.GetM6Id() {
			continue
		}
		if err := setBundleAck(ctx, producer, slot, m6id, false); err != nil {
			return nil, err
		}
	}
	if req.Msg.M6Id != nil {
		if err := setBundleAck(ctx, producer, slot, req.Msg.GetM6Id(), true); err != nil {
			return nil, err
		}
	}

	return connect.NewResponse(&m4pb.SetBundleUpvoteResponse{}), nil
}

func (s *Server) SetVotePolicy(
	ctx context.Context,
	req *connect.Request[m4pb.SetVotePolicyRequest],
) (*connect.Response[m4pb.SetVotePolicyResponse], error) {
	policy, ok := lo.FindKey(votePolicyFromEnforcer, req.Msg.Policy)
	if !ok || req.Msg.Policy == m4pb.VotePolicy_VOTE_POLICY_UNSPECIFIED {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("invalid vote policy: %s", req.Msg.Policy))
	}

	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("block producer: %w", err)
	}
	if _, err := producer.SetWithdrawalBundlePolicy(ctx, connect.NewRequest(&validatorpb.SetWithdrawalBundlePolicyRequest{
		Policy: policy,
	})); err != nil {
		return nil, fmt.Errorf("set withdrawal bundle policy: %w", err)
	}

	return connect.NewResponse(&m4pb.SetVotePolicyResponse{}), nil
}

var votePolicyFromEnforcer = map[validatorpb.WithdrawalBundlePolicy]m4pb.VotePolicy{
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_UNSPECIFIED: m4pb.VotePolicy_VOTE_POLICY_UNSPECIFIED,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_NONE:        m4pb.VotePolicy_VOTE_POLICY_ABSTAIN,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_KNOWN:       m4pb.VotePolicy_VOTE_POLICY_UPVOTE_KNOWN,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_ALL:         m4pb.VotePolicy_VOTE_POLICY_UPVOTE_ALL,
	validatorpb.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_ALARM:       m4pb.VotePolicy_VOTE_POLICY_ALARM,
}

func setBundleAck(ctx context.Context, producer validatorrpc.BlockProducerServiceClient, slot uint32, m6id string, ack bool) error {
	_, err := producer.SetWithdrawalBundleAck(ctx, connect.NewRequest(&validatorpb.SetWithdrawalBundleAckRequest{
		SidechainNumber: wrapperspb.UInt32(slot),
		M6Id:            &commonv1.ConsensusHex{Hex: wrapperspb.String(m6id)},
		Ack:             ack,
	}))
	if err != nil {
		return fmt.Errorf("set withdrawal bundle ack for sidechain %d: %w", slot, err)
	}
	return nil
}
