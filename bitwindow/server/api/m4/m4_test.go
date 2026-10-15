package m4_test

import (
	"context"
	"fmt"
	"slices"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	m4pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1/m4v1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

func TestService_GetM4History(t *testing.T) {
	t.Parallel()

	t.Run("returns empty history when no blocks processed", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.GetM4History(t.Context(), connect.NewRequest(&m4pb.GetM4HistoryRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.History)
	})

	t.Run("respects limit parameter", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		// Request with limit=0 (should default to 6)
		resp, err := cli.GetM4History(t.Context(), connect.NewRequest(&m4pb.GetM4HistoryRequest{
			Limit: 0,
		}))
		require.NoError(t, err)
		// With no data, it will just be empty
		assert.Empty(t, resp.Msg.History)
	})
}

func TestM4Engine_GetM4History(t *testing.T) {
	t.Parallel()

	t.Run("empty history", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := t.Context()
		engine := engines.NewM4Engine(db)

		history, err := engine.GetM4History(ctx, 10)
		require.NoError(t, err)
		assert.Empty(t, history)
	})
}

func TestM4Engine_GetWithdrawalBundles(t *testing.T) {
	t.Parallel()

	t.Run("empty bundles", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := t.Context()
		engine := engines.NewM4Engine(db)

		bundles, err := engine.GetWithdrawalBundles(ctx, nil)
		require.NoError(t, err)
		assert.Empty(t, bundles)
	})

	t.Run("filter by sidechain slot", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := t.Context()
		engine := engines.NewM4Engine(db)

		// Query for specific sidechain (should be empty)
		slot := uint8(0)
		bundles, err := engine.GetWithdrawalBundles(ctx, &slot)
		require.NoError(t, err)
		assert.Empty(t, bundles)
	})
}

const (
	m6idA = "aa00000000000000000000000000000000000000000000000000000000000000"
	m6idB = "bb00000000000000000000000000000000000000000000000000000000000000"
)

type fakeProducer struct {
	mainchainv1connect.BlockProducerServiceClient
	mu     sync.Mutex
	policy mainchainv1.WithdrawalBundlePolicy
	acks   []*mainchainv1.WithdrawalBundleAck
}

func (f *fakeProducer) GetBlockProducerState(context.Context, *connect.Request[mainchainv1.GetBlockProducerStateRequest]) (*connect.Response[mainchainv1.GetBlockProducerStateResponse], error) {
	f.mu.Lock()
	resp := &mainchainv1.GetBlockProducerStateResponse{
		WithdrawalBundlePolicy: f.policy,
		ExplicitBundleAcks:     slices.Clone(f.acks),
	}
	f.mu.Unlock()
	// Widen the gap between a read and the write that follows it.
	time.Sleep(time.Millisecond)
	return connect.NewResponse(resp), nil
}

func (f *fakeProducer) SetWithdrawalBundleAck(_ context.Context, req *connect.Request[mainchainv1.SetWithdrawalBundleAckRequest]) (*connect.Response[mainchainv1.SetWithdrawalBundleAckResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.acks = slices.DeleteFunc(f.acks, func(ack *mainchainv1.WithdrawalBundleAck) bool {
		return ack.GetSidechainNumber().GetValue() == req.Msg.GetSidechainNumber().GetValue() &&
			ack.GetM6Id().GetHex().GetValue() == req.Msg.GetM6Id().GetHex().GetValue()
	})
	if req.Msg.Ack {
		f.acks = append(f.acks, &mainchainv1.WithdrawalBundleAck{
			SidechainNumber: req.Msg.SidechainNumber,
			M6Id:            req.Msg.M6Id,
		})
	}
	return connect.NewResponse(&mainchainv1.SetWithdrawalBundleAckResponse{}), nil
}

func (f *fakeProducer) SetWithdrawalBundlePolicy(_ context.Context, req *connect.Request[mainchainv1.SetWithdrawalBundlePolicyRequest]) (*connect.Response[mainchainv1.SetWithdrawalBundlePolicyResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.policy = req.Msg.Policy
	return connect.NewResponse(&mainchainv1.SetWithdrawalBundlePolicyResponse{}), nil
}

func ack(slot uint32, m6id string) *mainchainv1.WithdrawalBundleAck {
	return &mainchainv1.WithdrawalBundleAck{
		SidechainNumber: wrapperspb.UInt32(slot),
		M6Id:            &commonv1.ConsensusHex{Hex: wrapperspb.String(m6id)},
	}
}

func newClient(t *testing.T, producer *fakeProducer) m4v1connect.M4ServiceClient {
	return m4v1connect.NewM4ServiceClient(apitests.API(t, database.Test(t), apitests.WithBlockProducer(producer)))
}

func TestService_GetVotes(t *testing.T) {
	t.Parallel()

	producer := &fakeProducer{
		policy: mainchainv1.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_ALARM,
		acks:   []*mainchainv1.WithdrawalBundleAck{ack(9, m6idA)},
	}
	resp, err := newClient(t, producer).GetVotes(t.Context(), connect.NewRequest(&m4pb.GetVotesRequest{}))
	require.NoError(t, err)
	assert.Equal(t, m4pb.VotePolicy_VOTE_POLICY_ALARM, resp.Msg.Policy)
	require.Len(t, resp.Msg.Upvotes, 1)
	assert.Equal(t, uint32(9), resp.Msg.Upvotes[0].SidechainSlot)
	assert.Equal(t, m6idA, resp.Msg.Upvotes[0].M6Id)
}

func TestService_SetBundleUpvote(t *testing.T) {
	t.Parallel()

	upvoted := func(producer *fakeProducer) []string {
		return lo.Map(producer.acks, func(a *mainchainv1.WithdrawalBundleAck, _ int) string {
			return fmt.Sprintf("%d:%s", a.GetSidechainNumber().GetValue(), a.GetM6Id().GetHex().GetValue()[:2])
		})
	}

	t.Run("upvotes a bundle", func(t *testing.T) {
		t.Parallel()

		producer := &fakeProducer{}
		m6id := m6idA
		_, err := newClient(t, producer).SetBundleUpvote(t.Context(), connect.NewRequest(&m4pb.SetBundleUpvoteRequest{
			SidechainSlot: 9,
			M6Id:          &m6id,
		}))
		require.NoError(t, err)
		assert.Equal(t, []string{"9:aa"}, upvoted(producer))
	})

	t.Run("moves the upvote and keeps other sidechains", func(t *testing.T) {
		t.Parallel()

		producer := &fakeProducer{acks: []*mainchainv1.WithdrawalBundleAck{ack(9, m6idA), ack(2, m6idB)}}
		m6id := m6idB
		_, err := newClient(t, producer).SetBundleUpvote(t.Context(), connect.NewRequest(&m4pb.SetBundleUpvoteRequest{
			SidechainSlot: 9,
			M6Id:          &m6id,
		}))
		require.NoError(t, err)
		assert.ElementsMatch(t, []string{"2:bb", "9:bb"}, upvoted(producer))
	})

	t.Run("keeps one upvote when two requests overlap", func(t *testing.T) {
		t.Parallel()

		producer := &fakeProducer{}
		cli := newClient(t, producer)
		var wg sync.WaitGroup
		for i := range 20 {
			m6id := []string{m6idA, m6idB}[i%2]
			wg.Go(func() {
				_, err := cli.SetBundleUpvote(t.Context(), connect.NewRequest(&m4pb.SetBundleUpvoteRequest{
					SidechainSlot: 9,
					M6Id:          &m6id,
				}))
				assert.NoError(t, err)
			})
		}
		wg.Wait()
		assert.Len(t, producer.acks, 1)
	})

	t.Run("clears the upvote", func(t *testing.T) {
		t.Parallel()

		producer := &fakeProducer{acks: []*mainchainv1.WithdrawalBundleAck{ack(9, m6idA), ack(2, m6idB)}}
		_, err := newClient(t, producer).SetBundleUpvote(t.Context(), connect.NewRequest(&m4pb.SetBundleUpvoteRequest{
			SidechainSlot: 9,
		}))
		require.NoError(t, err)
		assert.Equal(t, []string{"2:bb"}, upvoted(producer))
	})

	t.Run("rejects a malformed m6id", func(t *testing.T) {
		t.Parallel()

		m6id := "bundle-a"
		_, err := newClient(t, &fakeProducer{}).SetBundleUpvote(t.Context(), connect.NewRequest(&m4pb.SetBundleUpvoteRequest{
			SidechainSlot: 9,
			M6Id:          &m6id,
		}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("rejects a slot above 255", func(t *testing.T) {
		t.Parallel()

		_, err := newClient(t, &fakeProducer{}).SetBundleUpvote(t.Context(), connect.NewRequest(&m4pb.SetBundleUpvoteRequest{
			SidechainSlot: 256,
		}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

func TestService_SetVotePolicy(t *testing.T) {
	t.Parallel()

	t.Run("sets the enforcer policy", func(t *testing.T) {
		t.Parallel()

		producer := &fakeProducer{}
		_, err := newClient(t, producer).SetVotePolicy(t.Context(), connect.NewRequest(&m4pb.SetVotePolicyRequest{
			Policy: m4pb.VotePolicy_VOTE_POLICY_UPVOTE_ALL,
		}))
		require.NoError(t, err)
		assert.Equal(t, mainchainv1.WithdrawalBundlePolicy_WITHDRAWAL_BUNDLE_POLICY_ALL, producer.policy)
	})

	t.Run("rejects an unspecified policy", func(t *testing.T) {
		t.Parallel()

		_, err := newClient(t, &fakeProducer{}).SetVotePolicy(t.Context(), connect.NewRequest(&m4pb.SetVotePolicyRequest{}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}
