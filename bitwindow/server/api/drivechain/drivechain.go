package api_drivechain

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"sync"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	orchconfig "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.DrivechainServiceHandler = new(Server)

// withdrawalCache stores cached withdrawal data per sidechain
type withdrawalCache struct {
	bundles          []*pb.WithdrawalBundle
	lastBlockHash    string
	lastBlockHeight  uint32
	activationHeight uint32
}

// sidechainsCache stores cached sidechain list data
type sidechainsCache struct {
	sidechains    []*pb.ListSidechainsResponse_Sidechain
	lastBlockHash string
}

// proposalsCache stores cached sidechain proposals data
type proposalsCache struct {
	proposals     []*pb.SidechainProposal
	lastBlockHash string
}

// New creates a new Server
func New(
	enforcer *service.Service[validatorrpc.ValidatorServiceClient],
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient],
	db *sql.DB,
	conf config.Config,
	walletEngine *engines.WalletEngine,
) *Server {
	s := &Server{
		enforcer:         enforcer,
		blockProducer:    blockProducer,
		db:               db,
		conf:             conf,
		walletEngine:     walletEngine,
		withdrawalCaches: make(map[uint32]*withdrawalCache),
	}
	return s
}

type Server struct {
	enforcer      *service.Service[validatorrpc.ValidatorServiceClient]
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient]
	db            *sql.DB
	conf          config.Config
	walletEngine  *engines.WalletEngine

	// Cache for withdrawal bundles per sidechain ID
	withdrawalCacheMu sync.RWMutex
	withdrawalCaches  map[uint32]*withdrawalCache

	// Cache for sidechains list
	sidechainsCacheMu sync.RWMutex
	sidechainsCache   *sidechainsCache

	// Cache for sidechain proposals
	proposalsCacheMu sync.RWMutex
	proposalsCache   *proposalsCache
}

// ListSidechainProposals implements drivechainv1connect.DrivechainServiceHandler.
// Uses caching to avoid repeated enforcer calls.
func (s *Server) ListSidechainProposals(ctx context.Context, c *connect.Request[pb.ListSidechainProposalsRequest]) (*connect.Response[pb.ListSidechainProposalsResponse], error) {
	log := zerolog.Ctx(ctx)

	// A proposal is escrow state. With no enforcer there are none to show, and
	// an error here would empty the sidechain list beside it.
	if s.readsNoEscrow(ctx) {
		return connect.NewResponse(&pb.ListSidechainProposalsResponse{}), nil
	}

	enforcer, err := s.enforcer.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer: %w", err))
	}

	// Get current block hash to check cache validity
	chainTipResp, err := enforcer.GetChainTip(ctx, connect.NewRequest(&validatorpb.GetChainTipRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("get chain tip: %w", err))
	}

	if chainTipResp.Msg.BlockHeaderInfo == nil ||
		chainTipResp.Msg.BlockHeaderInfo.BlockHash == nil ||
		chainTipResp.Msg.BlockHeaderInfo.BlockHash.Hex == nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("chain tip missing block hash"))
	}

	currentBlockHash := chainTipResp.Msg.BlockHeaderInfo.BlockHash.Hex.Value

	// Check if we have a valid cache
	s.proposalsCacheMu.RLock()
	cache := s.proposalsCache
	s.proposalsCacheMu.RUnlock()

	if cache != nil && cache.lastBlockHash == currentBlockHash {
		log.Debug().Msg("ListSidechainProposals: returning cached data")
		return connect.NewResponse(&pb.ListSidechainProposalsResponse{
			Proposals: cache.proposals,
		}), nil
	}

	// Cache miss - fetch fresh data
	sidechainProposals, err := enforcer.GetSidechainProposals(ctx, connect.NewRequest(&validatorpb.GetSidechainProposalsRequest{}))
	if err != nil {
		err = fmt.Errorf("enforcer/validator: could not get sidechain proposals: %w", err)
		log.Error().Err(err).Msg("could not get sidechain proposals")
		return nil, err
	}

	proposals := lo.Map(sidechainProposals.Msg.SidechainProposals, func(proposal *validatorpb.GetSidechainProposalsResponse_SidechainProposal, _ int) *pb.SidechainProposal {
		return &pb.SidechainProposal{
			Slot:           proposal.SidechainNumber.Value,
			Data:           []byte(proposal.Description.Hex.Value),
			DataHash:       proposal.DescriptionSha256DHash.Hex.Value,
			VoteCount:      proposal.VoteCount.Value,
			ProposalHeight: proposal.ProposalHeight.Value,
			ProposalAge:    proposal.ProposalAge.Value,
		}
	})

	// Update cache
	s.proposalsCacheMu.Lock()
	s.proposalsCache = &proposalsCache{
		proposals:     proposals,
		lastBlockHash: currentBlockHash,
	}
	s.proposalsCacheMu.Unlock()

	log.Debug().
		Int("count", len(proposals)).
		Msg("ListSidechainProposals: fetched and cached")

	return connect.NewResponse(&pb.ListSidechainProposalsResponse{
		Proposals: proposals,
	}), nil
}

// ListSidechains implements drivechainv1connect.DrivechainServiceHandler.
// Uses caching to avoid repeated enforcer calls for GetCtip on every sidechain.
func (s *Server) ListSidechains(ctx context.Context, _ *connect.Request[pb.ListSidechainsRequest]) (*connect.Response[pb.ListSidechainsResponse], error) {
	log := zerolog.Ctx(ctx)

	// A light install runs no enforcer, and a hosted index reads one on its
	// behalf. Every sidechain here comes from the chain, never from a list this
	// build carries.
	if s.readsNoEscrow(ctx) {
		chains, err := s.escrowFromIndex(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeUnavailable, err)
		}
		return connect.NewResponse(&pb.ListSidechainsResponse{Sidechains: chains}), nil
	}

	enforcer, err := s.enforcer.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer: %w", err))
	}

	// Get current block hash to check cache validity
	chainTipResp, err := enforcer.GetChainTip(ctx, connect.NewRequest(&validatorpb.GetChainTipRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("get chain tip: %w", err))
	}

	if chainTipResp.Msg.BlockHeaderInfo == nil ||
		chainTipResp.Msg.BlockHeaderInfo.BlockHash == nil ||
		chainTipResp.Msg.BlockHeaderInfo.BlockHash.Hex == nil {
		log.Error().Msg("chain tip missing block hash")
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("chain tip missing block hash"))
	}

	currentBlockHash := chainTipResp.Msg.BlockHeaderInfo.BlockHash.Hex.Value

	// Check if we have a valid cache
	s.sidechainsCacheMu.RLock()
	cache := s.sidechainsCache
	s.sidechainsCacheMu.RUnlock()

	if cache != nil && cache.lastBlockHash == currentBlockHash {
		return connect.NewResponse(&pb.ListSidechainsResponse{
			Sidechains: cache.sidechains,
		}), nil
	}

	sidechains, err := enforcer.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		err = fmt.Errorf("enforcer/validator: could not get sidechains: %w", err)
		log.Error().Err(err).Msg("could not get sidechains")
		return nil, err
	}

	// Loop over all sidechains and get their chaintip if available
	sidechainList := make([]*pb.ListSidechainsResponse_Sidechain, 0, len(sidechains.Msg.Sidechains))
	for _, sidechain := range sidechains.Msg.Sidechains {
		// The enforcer reports a nil declaration for descriptions that aren't a v0
		// declaration, which is legal. Use nil-safe getters throughout.
		declaration := sidechain.GetDeclaration().GetV0()

		sc := &pb.ListSidechainsResponse_Sidechain{
			Title:            declaration.GetTitle().GetValue(),
			Description:      declaration.GetDescription().GetValue(),
			Hashid1:          declaration.GetHashId_1().GetHex().GetValue(),
			Hashid2:          declaration.GetHashId_2().GetHex().GetValue(),
			Slot:             sidechain.GetSidechainNumber().GetValue(),
			VoteCount:        sidechain.GetVoteCount().GetValue(),
			ProposalHeight:   sidechain.GetProposalHeight().GetValue(),
			ActivationHeight: sidechain.GetActivationHeight().GetValue(),
			DescriptionHex:   sidechain.GetDescription().GetHex().GetValue(),
		}

		// Try to get ctip (may not exist if no deposits yet)
		ctipResponse, err := enforcer.GetCtip(ctx,
			connect.NewRequest(&validatorpb.GetCtipRequest{SidechainNumber: wrapperspb.UInt32(sc.Slot)}),
		)
		if err == nil && ctipResponse.Msg.Ctip != nil && ctipResponse.Msg.Ctip.Txid != nil {
			txidHash, err := chainhash.NewHashFromStr(ctipResponse.Msg.Ctip.Txid.Hex.Value)
			if err == nil {
				sc.Nversion = uint32(ctipResponse.Msg.Ctip.SequenceNumber)
				sc.BalanceSatoshi = int64(ctipResponse.Msg.Ctip.Value)
				sc.ChaintipTxid = txidHash.String()
				sc.ChaintipVout = ctipResponse.Msg.Ctip.Vout
			}
		}

		sidechainList = append(sidechainList, sc)
	}

	// Update cache
	s.sidechainsCacheMu.Lock()
	s.sidechainsCache = &sidechainsCache{
		sidechains:    sidechainList,
		lastBlockHash: currentBlockHash,
	}
	s.sidechainsCacheMu.Unlock()

	return connect.NewResponse(&pb.ListSidechainsResponse{
		Sidechains: sidechainList,
	}), nil
}

// ProposeSidechain implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ProposeSidechain(
	ctx context.Context,
	c *connect.Request[pb.ProposeSidechainRequest],
) (*connect.Response[pb.ProposeSidechainResponse], error) {
	// Validation
	if c.Msg.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("slot must be 0-255"))
	}
	if c.Msg.Title == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("title required"))
	}
	if c.Msg.Hashid1 != "" && len(c.Msg.Hashid1) != 64 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("hashid1 must be 64 hex chars (256 bits)"))
	}
	if c.Msg.Hashid2 != "" && len(c.Msg.Hashid2) != 40 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("hashid2 must be 40 hex chars (160 bits)"))
	}

	if err := s.walletEngine.RequireFullNode(ctx, "proposing a sidechain"); err != nil {
		return nil, err
	}

	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("block producer unavailable: %w", err))
	}

	// Build SidechainDeclaration V0
	declarationV0 := &validatorpb.SidechainDeclaration_V0{
		Title:       wrapperspb.String(c.Msg.Title),
		Description: wrapperspb.String(c.Msg.Description),
	}

	// Add hash IDs if provided
	if c.Msg.Hashid1 != "" {
		declarationV0.HashId_1 = &commonpb.ConsensusHex{
			Hex: wrapperspb.String(c.Msg.Hashid1),
		}
	}
	if c.Msg.Hashid2 != "" {
		declarationV0.HashId_2 = &commonpb.Hex{
			Hex: wrapperspb.String(c.Msg.Hashid2),
		}
	}

	declaration := &validatorpb.SidechainDeclaration{
		SidechainDeclaration: &validatorpb.SidechainDeclaration_V0_{
			V0: declarationV0,
		},
	}

	// Call wallet's CreateSidechainProposal - this returns a stream
	proposalReq := &validatorpb.CreateSidechainProposalRequest{
		SidechainId: wrapperspb.UInt32(c.Msg.Slot),
		Declaration: declaration,
	}

	stream, err := producer.CreateSidechainProposal(ctx, connect.NewRequest(proposalReq))
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("propose sidechain failed")
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("propose sidechain: %w", err))
	}

	// Read the first response from the stream to confirm it was accepted
	// The stream will continue sending updates as the proposal gets mined
	if stream.Receive() {
		response := stream.Msg()
		zerolog.Ctx(ctx).Info().
			Uint32("slot", c.Msg.Slot).
			Interface("response", response).
			Msg("sidechain proposal created")
	}

	// Close the stream since we only need confirmation
	if err := stream.Close(); err != nil && err != io.EOF {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("error closing proposal stream")
	}

	return connect.NewResponse(&pb.ProposeSidechainResponse{
		Success: true,
		Message: fmt.Sprintf("Sidechain %d proposal created. Will be included in the next mined block.", c.Msg.Slot),
	}), nil
}

// ListWithdrawals implements drivechainv1connect.DrivechainServiceHandler.
// Uses caching to avoid re-scanning the entire blockchain on every call.
func (s *Server) ListWithdrawals(
	ctx context.Context,
	c *connect.Request[pb.ListWithdrawalsRequest],
) (*connect.Response[pb.ListWithdrawalsResponse], error) {
	log := zerolog.Ctx(ctx)

	// A withdrawal is escrow state, and no enforcer holds it here.
	if s.readsNoEscrow(ctx) {
		return connect.NewResponse(&pb.ListWithdrawalsResponse{}), nil
	}

	sidechainId := c.Msg.SidechainId

	enforcer, err := s.enforcer.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer: %w", err))
	}

	// Get chain tip
	chainTipResp, err := enforcer.GetChainTip(ctx, connect.NewRequest(&validatorpb.GetChainTipRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("get chain tip: %w", err))
	}

	if chainTipResp.Msg.BlockHeaderInfo == nil ||
		chainTipResp.Msg.BlockHeaderInfo.BlockHash == nil ||
		chainTipResp.Msg.BlockHeaderInfo.BlockHash.Hex == nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("chain tip missing block hash"))
	}

	currentHeight := chainTipResp.Msg.BlockHeaderInfo.Height
	currentBlockHash := chainTipResp.Msg.BlockHeaderInfo.BlockHash.Hex.Value

	// Check if we have a valid cache
	s.withdrawalCacheMu.RLock()
	cache := s.withdrawalCaches[sidechainId]
	s.withdrawalCacheMu.RUnlock()

	// If cache exists and is up to date, return cached data with updated ages
	if cache != nil && cache.lastBlockHash == currentBlockHash {
		log.Debug().
			Uint32("sidechain", sidechainId).
			Uint32("height", currentHeight).
			Msg("ListWithdrawals: returning cached data")
		return connect.NewResponse(&pb.ListWithdrawalsResponse{
			Bundles: s.updateBundleAges(cache.bundles, currentHeight),
		}), nil
	}

	// Get sidechains to find activation height
	sidechainsResp, err := enforcer.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("get sidechains: %w", err))
	}

	// Find the sidechain we're looking for
	sidechain, found := lo.Find(sidechainsResp.Msg.Sidechains, func(sc *validatorpb.GetSidechainsResponse_SidechainInfo) bool {
		return sc.SidechainNumber != nil && sc.SidechainNumber.Value == sidechainId
	})

	if !found || sidechain.ActivationHeight == nil {
		return nil, connect.NewError(connect.CodeNotFound,
			fmt.Errorf("sidechain %d not found", sidechainId))
	}

	activationHeight := sidechain.ActivationHeight.Value

	if currentHeight < activationHeight {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("activation height %d is greater than current height %d", activationHeight, currentHeight))
	}

	// Determine start block for fetching
	var startBlockHash string
	var existingBundles []*pb.WithdrawalBundle

	if cache != nil && cache.activationHeight == activationHeight && cache.lastBlockHeight > 0 {
		// We have a cache - only fetch new blocks since last fetch
		// Start from the block AFTER our last cached block
		startBlockHash = cache.lastBlockHash
		existingBundles = cache.bundles
		log.Debug().
			Uint32("sidechain", sidechainId).
			Uint32("fromHeight", cache.lastBlockHeight).
			Uint32("toHeight", currentHeight).
			Int("cachedBundles", len(existingBundles)).
			Msg("ListWithdrawals: incremental fetch")
	} else {
		// No cache or activation height changed - need full fetch from activation
		// Get the activation block hash
		ancestorsNeeded := currentHeight - activationHeight
		activationBlockResp, err := enforcer.GetBlockHeaderInfo(ctx, connect.NewRequest(&validatorpb.GetBlockHeaderInfoRequest{
			BlockHash:    chainTipResp.Msg.BlockHeaderInfo.BlockHash,
			MaxAncestors: &ancestorsNeeded,
		}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal,
				fmt.Errorf("get activation block header: %w", err))
		}

		activationBlock, found := lo.Find(activationBlockResp.Msg.HeaderInfos, func(headerInfo *validatorpb.BlockHeaderInfo) bool {
			return headerInfo.Height == activationHeight
		})

		if !found || activationBlock.BlockHash == nil || activationBlock.BlockHash.Hex == nil {
			return nil, connect.NewError(connect.CodeInternal,
				fmt.Errorf("could not find block at activation height %d", activationHeight))
		}

		startBlockHash = activationBlock.BlockHash.Hex.Value
		existingBundles = nil
		log.Debug().
			Uint32("sidechain", sidechainId).
			Uint32("activationHeight", activationHeight).
			Uint32("currentHeight", currentHeight).
			Msg("ListWithdrawals: full fetch from activation")
	}

	// Fetch peg data from start to current tip
	pegData, err := enforcer.GetTwoWayPegData(ctx, connect.NewRequest(&validatorpb.GetTwoWayPegDataRequest{
		SidechainId:    wrapperspb.UInt32(sidechainId),
		StartBlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String(startBlockHash)},
		EndBlockHash:   &commonpb.ReverseHex{Hex: wrapperspb.String(currentBlockHash)},
	}))
	if err != nil {
		log.Error().Err(err).Msg("could not get two-way peg data")
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("get two-way peg data: %w", err))
	}

	// Process new blocks and extract withdrawal bundle events
	newBundles := s.processPegDataBlocks(pegData.Msg.Blocks, sidechainId)

	// Merge existing and new bundles
	allBundles := s.mergeBundles(existingBundles, newBundles)

	// Update cache
	s.withdrawalCacheMu.Lock()
	s.withdrawalCaches[sidechainId] = &withdrawalCache{
		bundles:          allBundles,
		lastBlockHash:    currentBlockHash,
		lastBlockHeight:  currentHeight,
		activationHeight: activationHeight,
	}
	s.withdrawalCacheMu.Unlock()

	return connect.NewResponse(&pb.ListWithdrawalsResponse{
		Bundles: s.updateBundleAges(allBundles, currentHeight),
	}), nil
}

// BIP300 withdrawal verification period (max age for a bundle)
const withdrawalVerificationPeriod uint32 = 26300

// processPegDataBlocks extracts withdrawal bundles from peg data blocks
func (s *Server) processPegDataBlocks(blocks []*validatorpb.GetTwoWayPegDataResponse_ResponseItem, sidechainId uint32) []*pb.WithdrawalBundle {
	bundles := make([]*pb.WithdrawalBundle, 0)
	bundleSubmissionBlock := make(map[string]uint32)

	for _, block := range blocks {
		if block.BlockInfo == nil || block.BlockHeaderInfo == nil {
			continue
		}

		blockHeight := block.BlockHeaderInfo.Height

		for _, event := range block.BlockInfo.Events {
			withdrawalEvent := event.GetWithdrawalBundle()
			if withdrawalEvent == nil {
				continue
			}

			m6id := withdrawalEvent.M6Id.Hex.Value

			bundle := &pb.WithdrawalBundle{
				M6Id:        m6id,
				SidechainId: sidechainId,
				BlockHeight: blockHeight,
				MaxAge:      withdrawalVerificationPeriod,
			}

			switch e := withdrawalEvent.Event.Event.(type) {
			case *validatorpb.WithdrawalBundleEvent_Event_Succeeded_:
				bundle.Status = "succeeded"
				if e.Succeeded.SequenceNumber != nil {
					bundle.SequenceNumber = e.Succeeded.SequenceNumber.Value
				}
				if e.Succeeded.Transaction != nil {
					bundle.TransactionHex = e.Succeeded.Transaction.Hex.Value
				}
			case *validatorpb.WithdrawalBundleEvent_Event_Failed_:
				bundle.Status = "failed"
			case *validatorpb.WithdrawalBundleEvent_Event_Submitted_:
				bundle.Status = "pending"
				bundleSubmissionBlock[m6id] = blockHeight
			default:
				bundle.Status = "pending"
			}

			bundles = append(bundles, bundle)
		}
	}

	return bundles
}

// mergeBundles merges existing cached bundles with new bundles, updating statuses
func (s *Server) mergeBundles(existing, new []*pb.WithdrawalBundle) []*pb.WithdrawalBundle {
	if len(existing) == 0 {
		return new
	}

	// Create a map of existing bundles by M6Id for quick lookup
	bundleMap := lo.KeyBy(existing, func(b *pb.WithdrawalBundle) string {
		return b.M6Id
	})

	// Update or add new bundles. The existing entries belong to the shared
	// cache, and a concurrent reader still holds them, so update a copy.
	for _, b := range new {
		existingBundle, ok := bundleMap[b.M6Id]
		if !ok {
			bundleMap[b.M6Id] = b
			continue
		}
		switch b.Status {
		case "succeeded", "failed":
			merged := proto.Clone(existingBundle).(*pb.WithdrawalBundle)
			merged.Status = b.Status
			merged.SequenceNumber = b.SequenceNumber
			merged.TransactionHex = b.TransactionHex
			bundleMap[b.M6Id] = merged
		case "pending":
			// A bundle can be re-proposed after it expires, which opens a fresh
			// voting window at the new submission height.
			merged := proto.Clone(existingBundle).(*pb.WithdrawalBundle)
			merged.Status = b.Status
			merged.BlockHeight = b.BlockHeight
			merged.SequenceNumber = b.SequenceNumber
			merged.TransactionHex = b.TransactionHex
			bundleMap[b.M6Id] = merged
		}
	}

	// Convert map back to slice
	result := make([]*pb.WithdrawalBundle, 0, len(bundleMap))
	for _, b := range bundleMap {
		result = append(result, b)
	}

	return result
}

// updateBundleAges recalculates age and blocks_left for pending bundles
func (s *Server) updateBundleAges(bundles []*pb.WithdrawalBundle, currentHeight uint32) []*pb.WithdrawalBundle {
	result := make([]*pb.WithdrawalBundle, len(bundles))
	for i, b := range bundles {
		// Create a new proto message to avoid mutating cached data
		// (protobuf messages contain sync.Mutex so we can't just copy them)
		bundleCopy := &pb.WithdrawalBundle{
			M6Id:           b.M6Id,
			SidechainId:    b.SidechainId,
			BlockHeight:    b.BlockHeight,
			Status:         b.Status,
			MaxAge:         b.MaxAge,
			SequenceNumber: b.SequenceNumber,
			TransactionHex: b.TransactionHex,
			Age:            b.Age,
			BlocksLeft:     b.BlocksLeft,
		}
		if bundleCopy.Status == "pending" {
			bundleCopy.Age = currentHeight - bundleCopy.BlockHeight
			if bundleCopy.Age < withdrawalVerificationPeriod {
				bundleCopy.BlocksLeft = withdrawalVerificationPeriod - bundleCopy.Age
			} else {
				bundleCopy.BlocksLeft = 0
			}
		}
		result[i] = bundleCopy
	}
	return result
}

// ListRecentActions implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListRecentActions(
	ctx context.Context,
	_ *connect.Request[pb.ListRecentActionsRequest],
) (*connect.Response[pb.ListRecentActionsResponse], error) {
	return connect.NewResponse(&pb.ListRecentActionsResponse{}), nil
}

// readsNoEscrow is true when no enforcer answers, so no BIP300 state exists to
// read. Every drivechain read answers what it can rather than failing, or one
// unreadable call empties the whole page.
func (s *Server) readsNoEscrow(ctx context.Context) bool {
	return s.walletEngine != nil && !s.walletEngine.NodeMode().RunsLocalNode(ctx)
}

// escrowFromIndex reads the sidechain escrow through a hosted index. A network
// with no index has no source, and says so rather than inventing a list.
func (s *Server) escrowFromIndex(ctx context.Context) ([]*pb.ListSidechainsResponse_Sidechain, error) {
	network, known := orchconfig.LookupNetwork(string(s.conf.BitcoinCoreNetwork))
	if !known {
		return nil, fmt.Errorf("the network %q is not known", s.conf.BitcoinCoreNetwork)
	}
	url := orchconfig.DrivechainIndexURLForNetwork(network)
	if url == "" {
		return nil, fmt.Errorf("light mode reads the sidechains from a hosted index, and %s has none",
			network)
	}
	chains, err := newEscrowIndex(url).Sidechains(ctx)
	if err != nil {
		return nil, fmt.Errorf("read the sidechains from %s: %w", url, err)
	}
	return chains, nil
}
