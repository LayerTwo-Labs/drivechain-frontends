package engines

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

func newM4PayoutParser(t *testing.T) (*Parser, *mocks.MockValidatorServiceClient, *uint32) {
	t.Helper()
	db := database.Test(t)
	validator := mocks.NewMockValidatorServiceClient(gomock.NewController(t))
	tip := new(uint32)
	validator.EXPECT().GetChainTip(gomock.Any(), gomock.Any()).
		DoAndReturn(func(context.Context, *validatorpb.GetChainTipRequest) (*validatorpb.GetChainTipResponse, error) {
			return &validatorpb.GetChainTipResponse{BlockHeaderInfo: &validatorpb.BlockHeaderInfo{Height: *tip}}, nil
		}).AnyTimes()
	validator.EXPECT().GetSidechains(gomock.Any(), gomock.Any()).
		Return(&validatorpb.GetSidechainsResponse{Sidechains: []*validatorpb.GetSidechainsResponse_SidechainInfo{
			{SidechainNumber: wrapperspb.UInt32(0), ActivationHeight: wrapperspb.UInt32(10)},
			{SidechainNumber: wrapperspb.UInt32(9), ActivationHeight: wrapperspb.UInt32(20)},
			{SidechainNumber: wrapperspb.UInt32(5), ActivationHeight: wrapperspb.UInt32(20_000)},
		}}, nil).AnyTimes()
	return &Parser{
		db:          db,
		chainParams: &chaincfg.RegressionNetParams,
		m4Engine:    NewM4Engine(db, config.NetworkRegtest, ""),
		enforcer: service.New("enforcer", func(context.Context) (validatorrpc.ValidatorServiceClient, error) {
			return validator, nil
		}),
	}, validator, tip
}

func m4PayoutBlocks(t *testing.T, sameHeightVote bool) (map[uint32]*wire.MsgBlock, [32]byte, string, string) {
	t.Helper()
	var raw [32]byte
	for i := range raw {
		raw[i] = byte(i + 1)
	}
	proposalA := m3ProposalScript(t, 9, raw)
	proposalB := m3ProposalScript(t, 9, [32]byte{0x91, 0x82, 0x73})
	a, err := m4.ParseM3Bytes(proposalA)
	require.NoError(t, err)
	b, err := m4.ParseM3Bytes(proposalB)
	require.NoError(t, err)
	require.NotEqual(t, a.BundleHash, hex.EncodeToString(raw[:]))

	blocks := make(map[uint32]*wire.MsgBlock)
	var previous chainhash.Hash
	for height := uint32(100); height <= 109; height++ {
		var script []byte
		switch {
		case height == 100:
			script = proposalA
		case height == 101:
			script = proposalB
		case height <= 106 || height == 108 || height == 107 && sameHeightVote:
			script = m4Script(t, 0xff, 0x00)
		}
		block := coinbaseBlockOf(script, time.Unix(1_700_000_000+int64(height)*600, 0))
		block.Header.PrevBlock = previous
		previous = block.BlockHash()
		blocks[height] = block
	}
	return blocks, raw, a.BundleHash, b.BundleHash
}

func storeM4PayoutBlocks(t *testing.T, p *Parser, blocks map[uint32]*wire.MsgBlock, from, to uint32) {
	t.Helper()
	var batch []lo.Tuple2[uint32, *wire.MsgBlock]
	for height := from; height <= to; height++ {
		batch = append(batch, lo.T2(height, blocks[height]))
	}
	require.NoError(t, p.processBlocks(t.Context(), batch))
}

func expectM4PegRange(
	t *testing.T, validator *mocks.MockValidatorServiceClient, blocks map[uint32]*wire.MsgBlock,
	from, to uint32, payout *validatorpb.GetTwoWayPegDataResponse_ResponseItem, rpcErr error,
) {
	t.Helper()
	for _, slot := range []uint32{0, 9} {
		validator.EXPECT().GetTwoWayPegData(gomock.Any(), gomock.Cond(func(req *validatorpb.GetTwoWayPegDataRequest) bool {
			return req.GetSidechainId().GetValue() == slot &&
				req.GetStartBlockHash().GetHex().GetValue() == blocks[from].BlockHash().String() &&
				req.GetEndBlockHash().GetHex().GetValue() == blocks[to].BlockHash().String()
		})).DoAndReturn(func(context.Context, *validatorpb.GetTwoWayPegDataRequest) (*validatorpb.GetTwoWayPegDataResponse, error) {
			if slot == 9 && rpcErr != nil {
				return nil, rpcErr
			}
			response := &validatorpb.GetTwoWayPegDataResponse{}
			if slot == 9 && payout != nil {
				response.Blocks = []*validatorpb.GetTwoWayPegDataResponse_ResponseItem{payout}
			}
			return response, nil
		})
	}
}

func m4PayoutEvent(block *wire.MsgBlock, height uint32, raw [32]byte) *validatorpb.GetTwoWayPegDataResponse_ResponseItem {
	return &validatorpb.GetTwoWayPegDataResponse_ResponseItem{
		BlockHeaderInfo: &validatorpb.BlockHeaderInfo{
			Height:    height,
			BlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String(block.BlockHash().String())},
		},
		BlockInfo: &validatorpb.BlockInfo{Events: []*validatorpb.BlockInfo_Event{{
			Event: &validatorpb.BlockInfo_Event_WithdrawalBundle{WithdrawalBundle: &validatorpb.WithdrawalBundleEvent{
				M6Id: &commonpb.ConsensusHex{Hex: wrapperspb.String(hex.EncodeToString(raw[:]))},
				Event: &validatorpb.WithdrawalBundleEvent_Event{Event: &validatorpb.WithdrawalBundleEvent_Event_Succeeded_{
					Succeeded: &validatorpb.WithdrawalBundleEvent_Event_Succeeded{SequenceNumber: wrapperspb.UInt64(1)},
				}},
			}},
		}}},
	}
}

func TestParserM4PayoutOrder(t *testing.T) {
	for _, test := range []struct {
		name           string
		sameHeightVote bool
		delayed        bool
	}{
		{name: "payout without M4"},
		{name: "M4 before payout", sameHeightVote: true},
		{name: "delayed payout without M4", delayed: true},
		{name: "delayed M4 before payout", sameHeightVote: true, delayed: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			p, validator, tip := newM4PayoutParser(t)
			blocks, raw, hashA, hashB := m4PayoutBlocks(t, test.sameHeightVote)
			storeM4PayoutBlocks(t, p, blocks, 100, 109)
			from := uint32(100)
			if !test.delayed {
				*tip = 106
				expectM4PegRange(t, validator, blocks, 100, 106, nil, nil)
				require.NoError(t, p.applyPendingM4(t.Context()))
				score, _, status := bundleState(t, t.Context(), p.m4Engine, hashA)
				require.Equal(t, 6, score)
				require.Equal(t, "approved", status)
				from = 106
			}

			payout := m4PayoutEvent(blocks[107], 107, raw)
			wantScoreA := 6
			if test.sameHeightVote {
				*tip = 107
				expectM4PegRange(t, validator, blocks, from, 107, payout, nil)
				require.NoError(t, p.applyPendingM4(t.Context()))
				score, _, status := bundleState(t, t.Context(), p.m4Engine, hashA)
				require.Equal(t, 7, score)
				require.Equal(t, "succeeded", status)
				from = 107
				payout = nil
				wantScoreA++
			}
			*tip = 109
			expectM4PegRange(t, validator, blocks, from, 108, payout, nil)
			require.NoError(t, p.applyPendingM4(t.Context()))
			scoreA, _, statusA := bundleState(t, t.Context(), p.m4Engine, hashA)
			require.Equal(t, wantScoreA, scoreA)
			require.Equal(t, "succeeded", statusA)
			scoreB, _, statusB := bundleState(t, t.Context(), p.m4Engine, hashB)
			require.Equal(t, 1, scoreB)
			require.Equal(t, "pending", statusB)

			history, err := p.m4Engine.GetM4History(t.Context(), 2)
			require.NoError(t, err)
			require.Len(t, history, 2)
			require.Equal(t, uint32(108), history[0].BlockHeight)
			require.Len(t, history[0].Votes, 2)
			require.Equal(t, uint8(9), history[0].Votes[1].SidechainSlot)
			require.Equal(t, &hashB, history[0].Votes[1].BundleHash)
			if test.sameHeightVote {
				require.Equal(t, uint32(107), history[1].BlockHeight)
				require.Equal(t, &hashA, history[1].Votes[1].BundleHash)
			}

			require.NoError(t, p.applyPendingM4(t.Context()))
			scoreA, _, statusA = bundleState(t, t.Context(), p.m4Engine, hashA)
			require.Equal(t, wantScoreA, scoreA)
			require.Equal(t, "succeeded", statusA)
			scoreB, _, _ = bundleState(t, t.Context(), p.m4Engine, hashB)
			require.Equal(t, 1, scoreB)
		})
	}
}

func TestParserM4PayoutEqualBounds(t *testing.T) {
	p, validator, tip := newM4PayoutParser(t)
	blocks, _, hashA, _ := m4PayoutBlocks(t, false)
	blocks[100].Transactions[0].AddTxOut(wire.NewTxOut(0, m4Script(t, 0xff, 0xff)))
	storeM4PayoutBlocks(t, p, blocks, 100, 100)
	*tip = 100
	expectM4PegRange(t, validator, blocks, 100, 100, nil, nil)
	require.NoError(t, p.applyPendingM4(t.Context()))
	score, _, status := bundleState(t, t.Context(), p.m4Engine, hashA)
	require.Equal(t, 1, score)
	require.Equal(t, "pending", status)
}

func TestParserM4PayoutRPCErrorKeepsVotes(t *testing.T) {
	p, validator, tip := newM4PayoutParser(t)
	blocks, _, hashA, hashB := m4PayoutBlocks(t, false)
	storeM4PayoutBlocks(t, p, blocks, 100, 106)
	*tip = 106
	rpcErr := errors.New("peg data unavailable")
	expectM4PegRange(t, validator, blocks, 100, 106, nil, rpcErr)
	require.ErrorIs(t, p.applyPendingM4(t.Context()), rpcErr)
	for _, hash := range []string{hashA, hashB} {
		score, _, status := bundleState(t, t.Context(), p.m4Engine, hash)
		require.Equal(t, 1, score)
		require.Equal(t, "pending", status)
	}
	var votes, applied int
	require.NoError(t, p.db.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM m4_votes`).Scan(&votes))
	require.NoError(t, p.db.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM m4_messages WHERE applied = 1`).Scan(&applied))
	require.Zero(t, votes)
	require.Zero(t, applied)

	expectM4PegRange(t, validator, blocks, 100, 106, nil, nil)
	require.NoError(t, p.applyPendingM4(t.Context()))
	score, _, status := bundleState(t, t.Context(), p.m4Engine, hashA)
	require.Equal(t, 6, score)
	require.Equal(t, "approved", status)
}

func TestParserM4PayoutUsesRetainedProposalHash(t *testing.T) {
	p, validator, tip := newM4PayoutParser(t)
	p.m4Engine = NewM4Engine(p.db, config.NetworkMainnet, "")
	blocks, _, hashA, _ := m4PayoutBlocks(t, false)
	storeM4PayoutBlocks(t, p, blocks, 100, 100)
	_, err := p.db.ExecContext(t.Context(), `DELETE FROM processed_blocks`)
	require.NoError(t, err)
	for height := uint32(200); height <= 1208; height++ {
		var script []byte
		if height == 1208 {
			script = m4Script(t, 0xff, 0x00)
		}
		blocks[height] = coinbaseBlockOf(script, time.Unix(1_700_000_000+int64(height)*600, 0))
	}
	storeM4PayoutBlocks(t, p, blocks, 200, 1208)
	*tip = 1208
	expectM4PegRange(t, validator, blocks, 100, 1208, nil, nil)
	require.NoError(t, p.applyPendingM4(t.Context()))
	score, _, status := bundleState(t, t.Context(), p.m4Engine, hashA)
	require.Equal(t, 2, score)
	require.Equal(t, "pending", status)
}

func TestParserM4PayoutRestoresOldProposalOrder(t *testing.T) {
	for _, test := range []struct {
		name       string
		m4First    bool
		scoreB     int
		voteHeight uint32
	}{
		{name: "M3 before M4", scoreB: 0, voteHeight: 101},
		{name: "M4 before M3", m4First: true, scoreB: 1, voteHeight: 102},
	} {
		t.Run(test.name, func(t *testing.T) {
			p, validator, tip := newM4PayoutParser(t)
			blocks, _, hashA, hashB := m4PayoutBlocks(t, false)
			proposal := blocks[101].Transactions[0].TxOut[0].PkScript
			vote := m4Script(t, 0xff, 0x00)
			first, second := proposal, vote
			if test.m4First {
				first, second = vote, proposal
			}
			block := coinbaseBlockOf(first, blocks[101].Header.Timestamp)
			block.Header.PrevBlock = blocks[100].BlockHash()
			block.Transactions[0].AddTxOut(wire.NewTxOut(0, second))
			blocks[101] = block
			storeM4PayoutBlocks(t, p, blocks, 100, 101)
			_, err := p.db.ExecContext(t.Context(), `UPDATE m3_messages SET vote_height = NULL WHERE block_height = 101`)
			require.NoError(t, err)
			_, err = p.db.ExecContext(t.Context(), `UPDATE withdrawal_bundles SET last_updated_height = first_seen_height - 1`)
			require.NoError(t, err)

			var raw bytes.Buffer
			require.NoError(t, block.Serialize(&raw))
			core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			core.EXPECT().GetBlockHash(gomock.Any(), gomock.Cond(func(req *connect.Request[corepb.GetBlockHashRequest]) bool {
				return req.Msg.Height == 101
			})).Return(connect.NewResponse(&corepb.GetBlockHashResponse{Hash: block.BlockHash().String()}), nil)
			core.EXPECT().GetBlock(gomock.Any(), gomock.Cond(func(req *connect.Request[corepb.GetBlockRequest]) bool {
				return req.Msg.Hash == block.BlockHash().String() && req.Msg.Verbosity == corepb.GetBlockRequest_VERBOSITY_RAW_DATA
			})).Return(connect.NewResponse(&corepb.GetBlockResponse{Hex: hex.EncodeToString(raw.Bytes())}), nil)
			p.bitcoind = service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
				return core, nil
			})
			*tip = 101
			expectM4PegRange(t, validator, blocks, 100, 101, nil, nil)
			for range 2 {
				require.NoError(t, p.applyPendingM4(t.Context()))
				scoreA, _, statusA := bundleState(t, t.Context(), p.m4Engine, hashA)
				require.Equal(t, 2, scoreA)
				require.Equal(t, "pending", statusA)
				scoreB, _, statusB := bundleState(t, t.Context(), p.m4Engine, hashB)
				require.Equal(t, test.scoreB, scoreB)
				require.Equal(t, "pending", statusB)
			}
			var voteHeight uint32
			require.NoError(t, p.db.QueryRowContext(t.Context(),
				`SELECT vote_height FROM m3_messages WHERE block_height = 101`,
			).Scan(&voteHeight))
			require.Equal(t, test.voteHeight, voteHeight)
		})
	}
}
