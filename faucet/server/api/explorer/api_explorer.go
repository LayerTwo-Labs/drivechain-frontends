package explorer

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/rs/zerolog"

	pb "github.com/LayerTwo-Labs/sidesail/servers/faucet/gen/explorer/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/faucet/gen/explorer/v1/explorerv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/faucet/jsonrpc"
)

var _ rpc.ExplorerServiceHandler = new(Server)

type RpcClients struct {
	Thunder   *jsonrpc.Client
	BitAssets *jsonrpc.Client
	BitNames  *jsonrpc.Client
}

func New(
	mainchain *coreproxy.Bitcoind,
	rpcClients *RpcClients,
) *Server {
	return &Server{
		mainchain,
		rpcClients.Thunder,
		rpcClients.BitAssets,
		rpcClients.BitNames,
	}
}

type Server struct {
	mainchain *coreproxy.Bitcoind
	thunder   *jsonrpc.Client
	bitassets *jsonrpc.Client
	bitnames  *jsonrpc.Client
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

	zerolog.Ctx(ctx).
		Info().Msgf("best mainchain block: %s", bestMainchainBlock.Msg)

	// Don't let this crash us out!
	thunderTip, err := s.getSidechainTip(ctx, s.thunder, bestMainchainBlock.Msg)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Msgf("failed to get thunder tip: %s", err)
	}

	bitassetsTip, err := s.getSidechainTip(ctx, s.bitassets, bestMainchainBlock.Msg)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Msgf("failed to get bitassets tip: %s", err)
	}

	bitnamesTip, err := s.getSidechainTip(ctx, s.bitnames, bestMainchainBlock.Msg)
	if err != nil {
		zerolog.Ctx(ctx).Error().
			Msgf("failed to get bitnames tip: %s", err)
	}

	return connect.NewResponse(&pb.GetChainTipsResponse{
		Mainchain: &pb.ChainTip{
			Height:    uint64(bestMainchainBlock.Msg.Height),
			Hash:      bestMainchainBlock.Msg.Hash,
			Timestamp: bestMainchainBlock.Msg.Time,
		},
		Thunder:   thunderTip,
		Bitassets: bitassetsTip,
		Bitnames:  bitnamesTip,
	}), nil
}

func (s *Server) getSidechainTip(ctx context.Context, sidechain *jsonrpc.Client, bestMainchainBlock *btcpb.GetBlockResponse) (*pb.ChainTip, error) {
	bestSidechainMainchainBlock, err := s.getBestSidechainMainchainBlock(
		ctx, sidechain, bestMainchainBlock,
	)
	if err != nil {
		return nil, fmt.Errorf("best mainchain block as seen by sidechain: %w", err)
	}

	rawHeight, err := sidechain.Call(ctx, "getblockcount")
	if err != nil {
		return nil, fmt.Errorf("get sidechain block count: %w", err)
	}

	var height int
	if err := json.Unmarshal(rawHeight, &height); err != nil {
		return nil, err
	}

	rawBestSidechainHash, err := sidechain.Call(ctx, "get_best_sidechain_block_hash")
	if err != nil {
		return nil, fmt.Errorf("get sidechain best block hash: %w", err)
	}

	var bestSidechainHash string
	if err := json.Unmarshal(rawBestSidechainHash, &bestSidechainHash); err != nil {
		return nil, err
	}

	return &pb.ChainTip{
		Height:    uint64(height),
		Hash:      bestSidechainHash,
		Timestamp: bestSidechainMainchainBlock.Time,
	}, nil
}

// Fetch the best mainchain block, as seen by the sidechain
func (s *Server) getBestSidechainMainchainBlock(
	ctx context.Context, sidechain *jsonrpc.Client,
	bestMainchainBlock *btcpb.GetBlockResponse,
) (*btcpb.GetBlockResponse, error) {

	rawHash, err := sidechain.Call(ctx, "get_best_mainchain_block_hash")
	if err != nil {
		return nil, err
	}

	var hash string
	if err := json.Unmarshal(rawHash, &hash); err != nil {
		return nil, err
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("best sidechain mainchain block: %q", hash)

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
