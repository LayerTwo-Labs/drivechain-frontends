package api_drivechain

import (
	"context"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/datasource"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	v1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

const testActivationHeight uint32 = 50

// chainReader is a DrivechainReader backed by an in-memory active chain, so a
// test can reorg it and see which start block the handler asks peg data from.
type chainReader struct {
	datasource.DrivechainReader
	tipHeight uint32
	chain     map[uint32]string // height -> block hash on the active chain
	pegStarts []string
	pegErr    error
}

func newChainReader() *chainReader {
	f := &chainReader{tipHeight: 100, chain: make(map[uint32]string)}
	for h := testActivationHeight; h <= f.tipHeight; h++ {
		f.chain[h] = fmt.Sprintf("a%d", h)
	}
	return f
}

func header(height uint32, hash string) *v1.BlockHeaderInfo {
	return &v1.BlockHeaderInfo{
		Height:    height,
		BlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String(hash)},
	}
}

func (f *chainReader) ChainTip(context.Context, *v1.GetChainTipRequest) (*v1.GetChainTipResponse, error) {
	return &v1.GetChainTipResponse{
		BlockHeaderInfo: header(f.tipHeight, f.chain[f.tipHeight]),
	}, nil
}

func (f *chainReader) Sidechains(context.Context, *v1.GetSidechainsRequest) (*v1.GetSidechainsResponse, error) {
	return &v1.GetSidechainsResponse{
		Sidechains: []*v1.GetSidechainsResponse_SidechainInfo{{
			SidechainNumber:  wrapperspb.UInt32(0),
			ActivationHeight: wrapperspb.UInt32(testActivationHeight),
		}},
	}, nil
}

func (f *chainReader) BlockHeaderInfo(_ context.Context, req *v1.GetBlockHeaderInfoRequest) (*v1.GetBlockHeaderInfoResponse, error) {
	var infos []*v1.BlockHeaderInfo
	for h := f.tipHeight; h >= f.tipHeight-req.GetMaxAncestors(); h-- {
		infos = append(infos, header(h, f.chain[h]))
	}
	return &v1.GetBlockHeaderInfoResponse{HeaderInfos: infos}, nil
}

func (f *chainReader) TwoWayPegData(_ context.Context, req *v1.GetTwoWayPegDataRequest) (*v1.GetTwoWayPegDataResponse, error) {
	if f.pegErr != nil {
		return nil, f.pegErr
	}
	f.pegStarts = append(f.pegStarts, req.GetStartBlockHash().GetHex().GetValue())
	return &v1.GetTwoWayPegDataResponse{}, nil
}

func listWithdrawals(t *testing.T, s *Server) error {
	t.Helper()
	_, err := s.ListWithdrawals(context.Background(), connect.NewRequest(&pb.ListWithdrawalsRequest{
		SidechainId: 0,
	}))
	return err
}

// TestListWithdrawalsRescansAfterReorg proves a reorg that orphans the cached
// block makes the handler rescan from activation, instead of forever asking peg
// data from a block that is no longer on the chain.
func TestListWithdrawalsRescansAfterReorg(t *testing.T) {
	t.Run("orphaned cache rescans from activation", func(t *testing.T) {
		fake := newChainReader()
		s := &Server{data: fake, withdrawalCaches: make(map[uint32]*withdrawalCache)}

		require.NoError(t, listWithdrawals(t, s))
		require.Equal(t, []string{"a50"}, fake.pegStarts)

		// A reorg replaces the block the cache ended on, and extends the chain.
		fake.tipHeight = 101
		fake.chain[100] = "b100"
		fake.chain[101] = "b101"

		require.NoError(t, listWithdrawals(t, s))
		require.Equal(t, []string{"a50", "a50"}, fake.pegStarts,
			"an orphaned cached block must not be reused as the incremental start")
	})

	t.Run("cached block still on chain fetches incrementally", func(t *testing.T) {
		fake := newChainReader()
		s := &Server{data: fake, withdrawalCaches: make(map[uint32]*withdrawalCache)}

		require.NoError(t, listWithdrawals(t, s))

		fake.tipHeight = 101
		fake.chain[101] = "a101"

		require.NoError(t, listWithdrawals(t, s))
		require.Equal(t, []string{"a50", "a100"}, fake.pegStarts)
	})
}

// TestListWithdrawalsDropsCacheOnPegDataError proves a failed incremental fetch
// leaves no cache behind, so the next call rescans rather than re-sending a
// start block the enforcer just rejected.
func TestListWithdrawalsDropsCacheOnPegDataError(t *testing.T) {
	fake := newChainReader()
	s := &Server{data: fake, withdrawalCaches: make(map[uint32]*withdrawalCache)}

	require.NoError(t, listWithdrawals(t, s))

	fake.tipHeight = 101
	fake.chain[101] = "a101"
	fake.pegErr = fmt.Errorf("start block is not an ancestor of the end block")

	require.Error(t, listWithdrawals(t, s))

	s.withdrawalCacheMu.RLock()
	defer s.withdrawalCacheMu.RUnlock()
	require.NotContains(t, s.withdrawalCaches, uint32(0))
}
