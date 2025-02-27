package explorer

import (
	"context"
	"encoding/json"

	"connectrpc.com/connect"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/rs/zerolog"

	pb "github.com/LayerTwo-Labs/sidesail/servers/faucet/gen/explorer/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/faucet/gen/explorer/v1/explorerv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/faucet/jsonrpc"
)

var _ rpc.ExplorerServiceHandler = new(Server)

func New(
	mainchain *coreproxy.Bitcoind,
	thunder *jsonrpc.Client,
) *Server {
	return &Server{
		thunder,
		mainchain,
	}
}

type Server struct {
	thunder   *jsonrpc.Client
	mainchain *coreproxy.Bitcoind
}

func (s *Server) GetChainTips(ctx context.Context, req *connect.Request[pb.GetChainTipsRequest]) (*connect.Response[pb.GetChainTipsResponse], error) {
	info, err := s.mainchain.GetBlockchainInfo(
		ctx, connect.NewRequest(&btcpb.GetBlockchainInfoRequest{}),
	)
	if err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("fetching best mainchain block: %q", info.Msg.BestBlockHash)

	bestMainchainBlock, err := s.mainchain.GetBlock(ctx, connect.NewRequest(&btcpb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: btcpb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, err
	}

	// Don't let this crash us out!
	thunderTip, err := s.getThunderTip(ctx, bestMainchainBlock.Msg)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Msgf("failed to get thunder tip: %s", err)
	}

	return connect.NewResponse(&pb.GetChainTipsResponse{
		Mainchain: &pb.ChainTip{
			Height:    uint64(bestMainchainBlock.Msg.Height),
			Hash:      bestMainchainBlock.Msg.Hash,
			Timestamp: bestMainchainBlock.Msg.Time,
		},
		Thunder: thunderTip,
	}), nil
}

func (s *Server) getThunderTip(ctx context.Context, bestMainchainBlock *btcpb.GetBlockResponse) (*pb.ChainTip, error) {
	bestThunderMainchainBlock, err := s.getBestThunderMainchainBlock(ctx, bestMainchainBlock)
	if err != nil {
		return nil, err
	}

	rawThunderHeight, err := s.thunder.Call(ctx, "getblockcount")
	if err != nil {
		return nil, err
	}

	var thunderHeight int
	if err := json.Unmarshal(rawThunderHeight, &thunderHeight); err != nil {
		return nil, err
	}

	rawBestThunderSidechainHash, err := s.thunder.Call(ctx, "get_best_sidechain_block_hash")
	if err != nil {
		return nil, err
	}

	var bestThunderSidechainHash string
	if err := json.Unmarshal(rawBestThunderSidechainHash, &bestThunderSidechainHash); err != nil {
		return nil, err
	}

	return &pb.ChainTip{
		Height:    uint64(thunderHeight),
		Hash:      bestThunderSidechainHash,
		Timestamp: bestThunderMainchainBlock.Time,
	}, nil
}

// Fetch the best mainchain block, as seen by Thunder
func (s *Server) getBestThunderMainchainBlock(ctx context.Context, bestMainchainBlock *btcpb.GetBlockResponse) (*btcpb.GetBlockResponse, error) {

	rawHash, err := s.thunder.Call(ctx, "get_best_mainchain_block_hash")
	if err != nil {
		return nil, err
	}

	var hash string
	if err := json.Unmarshal(rawHash, &hash); err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("best thunder mainchain block: %q", hash)

	if hash == bestMainchainBlock.Hash {
		return bestMainchainBlock, nil
	}

	fetched, err := s.mainchain.GetBlock(ctx, connect.NewRequest(&btcpb.GetBlockRequest{
		Hash:      hash,
		Verbosity: btcpb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, err
	}

	return fetched.Msg, nil
}
