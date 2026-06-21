package explorer

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"
	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/sourcegraph/conc/pool"

	"github.com/LayerTwo-Labs/sidesail/faucet/server/connector"
	validatorpb "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/explorer/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/explorer/v1/explorerv1connect"
	"github.com/LayerTwo-Labs/sidesail/faucet/server/jsonrpc"
)

// Sidechain slot numbers (the BIP300 sidechain number) for each chain we know
// about. These are what the enforcer reports as activated.
const (
	slotBitnames  = 2
	slotBitassets = 4
	slotThunder   = 9
	slotTruthcoin = 13
	slotZside     = 98
	slotPhoton    = 99
	slotCoinshift = 255
)

var _ rpc.ExplorerServiceHandler = new(Server)

type RpcClients struct {
	Thunder   *jsonrpc.Client
	BitAssets *jsonrpc.Client
	BitNames  *jsonrpc.Client
	Zside     *jsonrpc.Client
	CoinShift *jsonrpc.Client
	Photon    *jsonrpc.Client
	Truthcoin *jsonrpc.Client
}

func New(
	mainchain bitcoindv1alphaconnect.BitcoinServiceClient,
	rpcClients *RpcClients,
	validator *connector.Service[validatorrpc.ValidatorServiceClient],
) *Server {
	return &Server{
		mainchain,
		validator,
		rpcClients.Thunder,
		rpcClients.BitAssets,
		rpcClients.BitNames,
		rpcClients.Zside,
		rpcClients.CoinShift,
		rpcClients.Photon,
		rpcClients.Truthcoin,
	}
}

type Server struct {
	mainchain bitcoindv1alphaconnect.BitcoinServiceClient
	validator *connector.Service[validatorrpc.ValidatorServiceClient]
	thunder   *jsonrpc.Client
	bitassets *jsonrpc.Client
	bitnames  *jsonrpc.Client
	zside     *jsonrpc.Client
	coinshift *jsonrpc.Client
	photon    *jsonrpc.Client
	truthcoin *jsonrpc.Client
}

func (s *Server) GetChainTips(ctx context.Context, req *connect.Request[pb.GetChainTipsRequest]) (*connect.Response[pb.GetChainTipsResponse], error) {
	info, err := s.mainchain.GetBlockchainInfo(
		ctx, connect.NewRequest(&btcpb.GetBlockchainInfoRequest{}),
	)
	if err != nil {
		return nil, fmt.Errorf("get blockchain info: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("fetching best mainchain block: %q", info.Msg.BestBlockHash)

	bestMainchainBlock, err := s.mainchain.GetBlock(ctx, connect.NewRequest(&btcpb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: btcpb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf(
			"get best mainchain block %q: %w", info.Msg.BestBlockHash, err,
		)
	}

	zerolog.Ctx(ctx).
		Info().Msgf("best mainchain block: %s", bestMainchainBlock.Msg)

	res := &pb.GetChainTipsResponse{
		Mainchain: &pb.ChainTip{
			Status:    pb.ChainTipStatus_CHAIN_TIP_STATUS_ACTIVE,
			Height:    uint64(bestMainchainBlock.Msg.Height),
			Hash:      bestMainchainBlock.Msg.Hash,
			Timestamp: bestMainchainBlock.Msg.Time,
		},
	}

	isActivated, err := s.sidechainActivation(ctx)
	if err != nil {
		return nil, fmt.Errorf("get sidechain activation: %w", err)
	}

	sidechains := []struct {
		name   string
		slot   uint32
		client *jsonrpc.Client
		set    func(*pb.ChainTip)
	}{
		{"thunder", slotThunder, s.thunder, func(t *pb.ChainTip) { res.Thunder = t }},
		{"bitassets", slotBitassets, s.bitassets, func(t *pb.ChainTip) { res.Bitassets = t }},
		{"bitnames", slotBitnames, s.bitnames, func(t *pb.ChainTip) { res.Bitnames = t }},
		{"zside", slotZside, s.zside, func(t *pb.ChainTip) { res.Zside = t }},
		{"coinshift", slotCoinshift, s.coinshift, func(t *pb.ChainTip) { res.Coinshift = t }},
		{"photon", slotPhoton, s.photon, func(t *pb.ChainTip) { res.Photon = t }},
		{"truthcoin", slotTruthcoin, s.truthcoin, func(t *pb.ChainTip) { res.Truthcoin = t }},
	}

	p := pool.New().WithContext(ctx)
	for _, sc := range sidechains {
		p.Go(func(ctx context.Context) error {
			// If the enforcer told us the slot isn't activated, there's no point
			// hitting the node.
			if !isActivated(sc.slot) {
				sc.set(&pb.ChainTip{Status: pb.ChainTipStatus_CHAIN_TIP_STATUS_NOT_ACTIVATED})
				return nil
			}

			fetched, err := s.getSidechainTip(ctx, lo.T2(sc.name, sc.client), bestMainchainBlock.Msg)
			if err != nil {
				return fmt.Errorf("get %s tip: %w", sc.name, err)
			}
			sc.set(fetched)
			return nil
		})
	}

	// Avoid erroring out here. Just log, and continue. Don't want a single bad
	// sidechain cause the entire request to fail.
	if err := p.Wait(); err != nil {
		zerolog.Ctx(ctx).Err(err).Msg("failed to get sidechain tips")
	}

	return connect.NewResponse(res), nil
}

// ListSidechains reports BIP300 sidechain slot proposals that are still being
// voted on, plus the sidechains that are currently activated. Everything is
// sourced from the CUSF mainchain enforcer.
func (s *Server) ListSidechains(ctx context.Context, req *connect.Request[pb.ListSidechainsRequest]) (*connect.Response[pb.ListSidechainsResponse], error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("connect to enforcer: %w", err)
	}

	// Consensus constants (activation thresholds) are network-specific and the
	// enforcer is the source of truth. Older enforcer builds don't report them;
	// in that case we leave the threshold as zero ("unknown") rather than
	// guessing.
	var consts *validatorpb.GetChainInfoResponse_Bip300Constants
	if info, err := validator.GetChainInfo(ctx, connect.NewRequest(&validatorpb.GetChainInfoRequest{})); err != nil {
		return nil, fmt.Errorf("get chain info from enforcer: %w", err)
	} else {
		consts = info.Msg.GetBip300Constants()
	}

	activeResp, err := validator.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("list active sidechains from enforcer: %w", err)
	}

	proposalsResp, err := validator.GetSidechainProposals(ctx, connect.NewRequest(&validatorpb.GetSidechainProposalsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("list sidechain proposals from enforcer: %w", err)
	}

	res := &pb.ListSidechainsResponse{}

	activeSlots := make(map[uint32]bool, len(activeResp.Msg.GetSidechains()))
	for _, sc := range activeResp.Msg.GetSidechains() {
		slot := sc.GetSidechainNumber().GetValue()
		activeSlots[slot] = true
		res.Active = append(res.Active, &pb.ActiveSidechain{
			SidechainNumber:  slot,
			Title:            declarationTitle(sc.GetDeclaration()),
			ProposalHeight:   sc.GetProposalHeight().GetValue(),
			ActivationHeight: sc.GetActivationHeight().GetValue(),
			VoteCount:        sc.GetVoteCount().GetValue(),
		})
	}

	for _, p := range proposalsResp.Msg.GetSidechainProposals() {
		slot := p.GetSidechainNumber().GetValue()
		var description string
		if v0 := p.GetDeclaration().GetV0(); v0 != nil {
			description = v0.GetDescription().GetValue()
		}
		res.Proposals = append(res.Proposals, &pb.SidechainProposal{
			SidechainNumber:     slot,
			Title:               declarationTitle(p.GetDeclaration()),
			Description:         description,
			DescriptionHash:     p.GetDescriptionSha256DHash().GetHex().GetValue(),
			VoteCount:           p.GetVoteCount().GetValue(),
			ProposalHeight:      p.GetProposalHeight().GetValue(),
			ProposalAge:         p.GetProposalAge().GetValue(),
			ActivationThreshold: activationThreshold(consts, activeSlots[slot]),
		})
	}

	return connect.NewResponse(res), nil
}

// activationThreshold returns the number of ACKs a proposal needs to activate.
// A proposal for a slot that is currently occupied (a replacement) uses the
// "used slot" threshold; a proposal for an empty slot uses the "unused slot"
// threshold. Returns 0 if the enforcer didn't report consensus constants.
func activationThreshold(consts *validatorpb.GetChainInfoResponse_Bip300Constants, slotInUse bool) uint32 {
	if consts == nil {
		return 0
	}
	if slotInUse {
		return consts.GetUsedSidechainSlotActivationThreshold()
	}
	return consts.GetUnusedSidechainSlotActivationThreshold()
}

// declarationTitle pulls the human-readable title out of an M1 declaration,
// tolerating nil declarations and unknown declaration versions.
func declarationTitle(d *validatorpb.SidechainDeclaration) string {
	return d.GetV0().GetTitle().GetValue()
}

// sidechainActivation asks the enforcer which sidechain slots are currently
// activated on L1 and returns a predicate reporting activation per slot.
func (s *Server) sidechainActivation(ctx context.Context) (func(slot uint32) bool, error) {
	validator, err := s.validator.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("connect to enforcer: %w", err)
	}

	sidechains, err := validator.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("list active sidechains from enforcer: %w", err)
	}

	active := lo.SliceToMap(sidechains.Msg.Sidechains, func(sc *validatorpb.GetSidechainsResponse_SidechainInfo) (uint32, bool) {
		return sc.GetSidechainNumber().GetValue(), true
	})

	return func(slot uint32) bool { return active[slot] }, nil
}

func (s *Server) getSidechainTip(ctx context.Context, sidechain lo.Tuple2[string, *jsonrpc.Client], bestMainchainBlock *btcpb.GetBlockResponse) (*pb.ChainTip, error) {
	name, client := sidechain.Unpack()

	// This call doubles as a reachability probe: a transport error means we
	// can't reach the node at all. Whether the sidechain is _activated_ is
	// decided by the enforcer in GetChainTips, not here.
	rawBestSidechainHash, err := client.Call(ctx, "get_best_sidechain_block_hash")
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).
			Msgf("could not reach %s sidechain, marking unreachable", name)
		return &pb.ChainTip{
			Status: pb.ChainTipStatus_CHAIN_TIP_STATUS_UNREACHABLE,
		}, nil
	}

	var bestSidechainHash string

	// No blocks on the sidechain means the best sidechain block hash is null.
	if !bytes.Equal(rawBestSidechainHash, []byte("null")) {
		if err := json.Unmarshal(rawBestSidechainHash, &bestSidechainHash); err != nil {
			return nil, fmt.Errorf("unmarshal best sidechain block hash: %w", err)
		}
	}

	bestSidechainMainchainBlock, err := s.getBestSidechainMainchainBlock(
		ctx, sidechain, bestMainchainBlock,
	)
	if err != nil {
		return nil, fmt.Errorf("best mainchain block as seen by sidechain: %w", err)
	}

	rawHeight, err := client.Call(ctx, "getblockcount")
	if err != nil {
		return nil, fmt.Errorf("get sidechain block count: %w", err)
	}

	var height int
	if err := json.Unmarshal(rawHeight, &height); err != nil {
		return nil, err
	}

	return &pb.ChainTip{
		Status:    pb.ChainTipStatus_CHAIN_TIP_STATUS_ACTIVE,
		Height:    uint64(height),
		Hash:      bestSidechainHash,
		Timestamp: bestSidechainMainchainBlock.GetTime(), // can be nil in case of no blocks
	}, nil
}

// Fetch the best mainchain block, as seen by the sidechain
func (s *Server) getBestSidechainMainchainBlock(
	ctx context.Context, sidechain lo.Tuple2[string, *jsonrpc.Client],
	bestMainchainBlock *btcpb.GetBlockResponse,
) (*btcpb.GetBlockResponse, error) {
	name, client := sidechain.Unpack()

	rawHash, err := client.Call(ctx, "get_best_mainchain_block_hash")
	if err != nil {
		return nil, err
	}

	// If there are no blocks on the sidechain, this is what we get
	if bytes.Equal(rawHash, []byte("null")) {
		return nil, nil
	}

	var hash string
	if err := json.Unmarshal(rawHash, &hash); err != nil {
		return nil, err
	}

	if hash == "" {
		return nil, fmt.Errorf("best mainchain block hash returned by sidechain is empty: %s", rawHash)
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("best sidechain mainchain block seen from %s: %q", name, hash)

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
