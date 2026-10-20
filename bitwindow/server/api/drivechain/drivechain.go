package drivechain

import (
	"cmp"
	"context"
	"encoding/hex"
	"fmt"
	"slices"
	"sync"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
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

func New(
	enforcer *service.Service[validatorrpc.ValidatorServiceClient],
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient],
	walletEngine *engines.WalletEngine,
	bundleMaxAge uint32,
) *Server {
	s := &Server{
		enforcer:         enforcer,
		blockProducer:    blockProducer,
		walletEngine:     walletEngine,
		bundleMaxAge:     bundleMaxAge,
		withdrawalCaches: make(map[uint32]*withdrawalCache),
	}
	return s
}

type Server struct {
	enforcer      *service.Service[validatorrpc.ValidatorServiceClient]
	blockProducer *service.Service[validatorrpc.BlockProducerServiceClient]
	walletEngine  *engines.WalletEngine
	// bundleMaxAge is the number of blocks a withdrawal bundle has for its votes.
	bundleMaxAge uint32

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

// chainTip gives the enforcer client and its chain tip. Errors keep the code of the enforcer.
func (s *Server) chainTip(ctx context.Context) (validatorrpc.ValidatorServiceClient, *validatorpb.BlockHeaderInfo, error) {
	enforcer, err := s.enforcer.Get(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("enforcer: %w", err)
	}

	chainTipResp, err := enforcer.GetChainTip(ctx, &validatorpb.GetChainTipRequest{})
	if err != nil {
		return nil, nil, fmt.Errorf("get chain tip: %w", err)
	}

	tip := chainTipResp.BlockHeaderInfo
	if tip.GetBlockHash().GetHex() == nil {
		return nil, nil, connect.NewError(connect.CodeInternal, "chain tip missing block hash")
	}
	return enforcer, tip, nil
}

// ListSidechainProposals implements drivechainv1connect.DrivechainServiceHandler.
// Uses caching to avoid repeated enforcer calls.
func (s *Server) ListSidechainProposals(ctx context.Context, c *pb.ListSidechainProposalsRequest) (*pb.ListSidechainProposalsResponse, error) {
	log := zerolog.Ctx(ctx)

	enforcer, tip, err := s.chainTip(ctx)
	if err != nil {
		return nil, err
	}
	currentBlockHash := tip.BlockHash.Hex.Value

	// Check if we have a valid cache
	s.proposalsCacheMu.RLock()
	cache := s.proposalsCache
	s.proposalsCacheMu.RUnlock()

	if cache != nil && cache.lastBlockHash == currentBlockHash {
		log.Debug().Msg("ListSidechainProposals: returning cached data")
		return &pb.ListSidechainProposalsResponse{
			Proposals: cache.proposals,
		}, nil
	}

	// Cache miss - fetch fresh data
	sidechainProposals, err := enforcer.GetSidechainProposals(ctx, &validatorpb.GetSidechainProposalsRequest{})
	if err != nil {
		err = fmt.Errorf("enforcer/validator: get sidechain proposals: %w", err)
		return nil, err
	}

	proposals := make([]*pb.SidechainProposal, 0, len(sidechainProposals.SidechainProposals))
	for _, proposal := range sidechainProposals.SidechainProposals {
		data, err := hex.DecodeString(proposal.Description.Hex.Value)
		if err != nil {
			return nil, fmt.Errorf("decode description of sidechain proposal %d: %w", proposal.SidechainNumber.Value, err)
		}
		proposals = append(proposals, &pb.SidechainProposal{
			Slot:           proposal.SidechainNumber.Value,
			Data:           data,
			DataHash:       proposal.DescriptionSha256DHash.Hex.Value,
			VoteCount:      proposal.VoteCount.Value,
			ProposalHeight: proposal.ProposalHeight.Value,
			ProposalAge:    proposal.ProposalAge.Value,
		})
	}

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

	return &pb.ListSidechainProposalsResponse{
		Proposals: proposals,
	}, nil
}

// ListSidechains implements drivechainv1connect.DrivechainServiceHandler.
// Uses caching to avoid repeated enforcer calls for GetCtip on every sidechain.
func (s *Server) ListSidechains(ctx context.Context, _ *pb.ListSidechainsRequest) (*pb.ListSidechainsResponse, error) {
	enforcer, tip, err := s.chainTip(ctx)
	if err != nil {
		return nil, err
	}
	currentBlockHash := tip.BlockHash.Hex.Value

	// Check if we have a valid cache
	s.sidechainsCacheMu.RLock()
	cache := s.sidechainsCache
	s.sidechainsCacheMu.RUnlock()

	if cache != nil && cache.lastBlockHash == currentBlockHash {
		return &pb.ListSidechainsResponse{
			Sidechains: cache.sidechains,
		}, nil
	}

	sidechains, err := enforcer.GetSidechains(ctx, &validatorpb.GetSidechainsRequest{})
	if err != nil {
		err = fmt.Errorf("enforcer/validator: get sidechains: %w", err)
		return nil, err
	}

	// Loop over all sidechains and get their chaintip if available
	sidechainList := make([]*pb.ListSidechainsResponse_Sidechain, 0, len(sidechains.Sidechains))
	for _, sidechain := range sidechains.Sidechains {
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

		// A sidechain with no deposits has no ctip.
		ctipResponse, err := enforcer.GetCtip(ctx,
			&validatorpb.GetCtipRequest{SidechainNumber: wrapperspb.UInt32(sc.Slot)},
		)
		switch {
		case err != nil && connect.CodeOf(err) == connect.CodeNotFound:
		case err != nil:
			return nil, fmt.Errorf("get ctip of sidechain %d: %w", sc.Slot, err)
		case ctipResponse.Ctip != nil:
			ctip := ctipResponse.Ctip
			txidHash, err := chainhash.NewHashFromStr(ctip.GetTxid().GetHex().GetValue())
			if err != nil {
				return nil, fmt.Errorf("parse ctip txid of sidechain %d: %w", sc.Slot, err)
			}
			sc.Nversion = uint32(ctip.SequenceNumber)
			sc.BalanceSatoshi = int64(ctip.Value)
			sc.ChaintipTxid = txidHash.String()
			sc.ChaintipVout = ctip.Vout
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

	return &pb.ListSidechainsResponse{
		Sidechains: sidechainList,
	}, nil
}

// ProposeSidechain implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ProposeSidechain(
	ctx context.Context,
	c *pb.ProposeSidechainRequest,
) (*pb.ProposeSidechainResponse, error) {
	// Validation
	if c.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"slot must be 0-255")
	}
	if c.Title == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"title required")
	}
	if c.Hashid1 != "" && len(c.Hashid1) != 64 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"hashid1 must be 64 hex chars (256 bits)")
	}
	if c.Hashid2 != "" && len(c.Hashid2) != 40 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"hashid2 must be 40 hex chars (160 bits)")
	}

	if err := s.walletEngine.RequireFullNode(ctx, "proposing a sidechain"); err != nil {
		return nil, err
	}

	producer, err := s.blockProducer.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Sprintf("block producer unavailable: %s", err)).WithCause(err)
	}

	// Build SidechainDeclaration V0
	declarationV0 := &validatorpb.SidechainDeclaration_V0{
		Title:       wrapperspb.String(c.Title),
		Description: wrapperspb.String(c.Description),
	}

	// Add hash IDs if provided
	if c.Hashid1 != "" {
		declarationV0.HashId_1 = &commonpb.ConsensusHex{
			Hex: wrapperspb.String(c.Hashid1),
		}
	}
	if c.Hashid2 != "" {
		declarationV0.HashId_2 = &commonpb.Hex{
			Hex: wrapperspb.String(c.Hashid2),
		}
	}

	declaration := &validatorpb.SidechainDeclaration{
		SidechainDeclaration: &validatorpb.SidechainDeclaration_V0_{
			V0: declarationV0,
		},
	}

	_, err = producer.SubmitSidechainProposal(ctx, &validatorpb.SubmitSidechainProposalRequest{
		SidechainId: wrapperspb.UInt32(c.Slot),
		Declaration: declaration,
	})
	if err != nil {
		return nil, fmt.Errorf("propose sidechain: %w", err)
	}

	return &pb.ProposeSidechainResponse{
		Success: true,
		Message: fmt.Sprintf("Sidechain %d proposal saved. It goes into the chain only when this node mines a block.", c.Slot),
	}, nil
}

// ListWithdrawals implements drivechainv1connect.DrivechainServiceHandler.
// Uses caching to avoid re-scanning the entire blockchain on every call.
func (s *Server) ListWithdrawals(
	ctx context.Context,
	c *pb.ListWithdrawalsRequest,
) (*pb.ListWithdrawalsResponse, error) {
	log := zerolog.Ctx(ctx)

	sidechainID := c.SidechainId

	enforcer, tip, err := s.chainTip(ctx)
	if err != nil {
		return nil, err
	}
	currentHeight := tip.Height
	currentBlockHash := tip.BlockHash.Hex.Value

	// Check if we have a valid cache
	s.withdrawalCacheMu.RLock()
	cache := s.withdrawalCaches[sidechainID]
	s.withdrawalCacheMu.RUnlock()

	// If cache exists and is up to date, return cached data with updated ages
	if cache != nil && cache.lastBlockHash == currentBlockHash {
		log.Debug().
			Uint32("sidechain", sidechainID).
			Uint32("height", currentHeight).
			Msg("ListWithdrawals: returning cached data")
		return &pb.ListWithdrawalsResponse{
			Bundles: s.updateBundleAges(cache.bundles, currentHeight),
		}, nil
	}

	// Get sidechains to find activation height
	sidechainsResp, err := enforcer.GetSidechains(ctx, &validatorpb.GetSidechainsRequest{})
	if err != nil {
		return nil, fmt.Errorf("get sidechains: %w", err)
	}

	// Find the sidechain we're looking for
	sidechain, found := lo.Find(sidechainsResp.Sidechains, func(sc *validatorpb.GetSidechainsResponse_SidechainInfo) bool {
		return sc.SidechainNumber != nil && sc.SidechainNumber.Value == sidechainID
	})

	if !found || sidechain.ActivationHeight == nil {
		return nil, connect.Errorf(connect.CodeNotFound,
			"sidechain %d not found", sidechainID)
	}

	activationHeight := sidechain.ActivationHeight.Value

	if currentHeight < activationHeight {
		return nil, connect.Errorf(connect.CodeInternal,
			"activation height %d is greater than current height %d", activationHeight, currentHeight)
	}

	// Determine start block for fetching
	var startBlockHash string
	var existingBundles []*pb.WithdrawalBundle

	reuseCache := false
	if cache != nil && cache.activationHeight == activationHeight &&
		cache.lastBlockHeight > 0 && cache.lastBlockHeight <= currentHeight {
		ancestors := currentHeight - cache.lastBlockHeight
		headersResp, err := enforcer.GetBlockHeaderInfo(ctx, &validatorpb.GetBlockHeaderInfoRequest{
			BlockHash:    tip.BlockHash,
			MaxAncestors: &ancestors,
		})
		if err != nil {
			return nil, fmt.Errorf("get cached block header: %w", err)
		}
		reuseCache = cacheOnChain(cache, headersResp.HeaderInfos)
		if !reuseCache {
			log.Info().
				Uint32("sidechain", sidechainID).
				Uint32("cachedHeight", cache.lastBlockHeight).
				Str("cachedHash", cache.lastBlockHash).
				Msg("ListWithdrawals: cached block left the active chain, read again from activation")
		}
	}

	if reuseCache {
		// We have a cache - only fetch new blocks since last fetch
		// Start from the block AFTER our last cached block
		startBlockHash = cache.lastBlockHash
		existingBundles = cache.bundles
		log.Debug().
			Uint32("sidechain", sidechainID).
			Uint32("fromHeight", cache.lastBlockHeight).
			Uint32("toHeight", currentHeight).
			Int("cachedBundles", len(existingBundles)).
			Msg("ListWithdrawals: incremental fetch")
	} else {
		// No cache or activation height changed - need full fetch from activation
		// Get the activation block hash
		ancestorsNeeded := currentHeight - activationHeight
		activationBlockResp, err := enforcer.GetBlockHeaderInfo(ctx, &validatorpb.GetBlockHeaderInfoRequest{
			BlockHash:    tip.BlockHash,
			MaxAncestors: &ancestorsNeeded,
		})
		if err != nil {
			return nil, fmt.Errorf("get activation block header: %w", err)
		}

		activationBlock, found := lo.Find(activationBlockResp.HeaderInfos, func(headerInfo *validatorpb.BlockHeaderInfo) bool {
			return headerInfo.Height == activationHeight
		})

		if !found || activationBlock.BlockHash == nil || activationBlock.BlockHash.Hex == nil {
			return nil, connect.Errorf(connect.CodeInternal,
				"no block at activation height %d", activationHeight)
		}

		startBlockHash = activationBlock.BlockHash.Hex.Value
		existingBundles = nil
		log.Debug().
			Uint32("sidechain", sidechainID).
			Uint32("activationHeight", activationHeight).
			Uint32("currentHeight", currentHeight).
			Msg("ListWithdrawals: full fetch from activation")
	}

	// Fetch peg data from start to current tip
	pegData, err := enforcer.GetTwoWayPegData(ctx, &validatorpb.GetTwoWayPegDataRequest{
		SidechainId:    wrapperspb.UInt32(sidechainID),
		StartBlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String(startBlockHash)},
		EndBlockHash:   &commonpb.ReverseHex{Hex: wrapperspb.String(currentBlockHash)},
	})
	if err != nil {
		return nil, fmt.Errorf("get two-way peg data: %w", err)
	}

	// Process new blocks and extract withdrawal bundle events
	newBundles := s.processPegDataBlocks(pegData.Blocks, sidechainID)

	// Merge existing and new bundles
	allBundles := s.mergeBundles(existingBundles, newBundles)

	// Update cache
	s.withdrawalCacheMu.Lock()
	s.withdrawalCaches[sidechainID] = &withdrawalCache{
		bundles:          allBundles,
		lastBlockHash:    currentBlockHash,
		lastBlockHeight:  currentHeight,
		activationHeight: activationHeight,
	}
	s.withdrawalCacheMu.Unlock()

	return &pb.ListWithdrawalsResponse{
		Bundles: s.updateBundleAges(allBundles, currentHeight),
	}, nil
}

// cacheOnChain reports whether the cached block is in headers, the ancestors
// of the current tip. A reorg or a network switch takes it out.
func cacheOnChain(cache *withdrawalCache, headers []*validatorpb.BlockHeaderInfo) bool {
	return lo.ContainsBy(headers, func(h *validatorpb.BlockHeaderInfo) bool {
		return h.Height == cache.lastBlockHeight &&
			h.BlockHash != nil && h.BlockHash.Hex != nil &&
			h.BlockHash.Hex.Value == cache.lastBlockHash
	})
}

// processPegDataBlocks extracts withdrawal bundles from peg data blocks
func (s *Server) processPegDataBlocks(blocks []*validatorpb.GetTwoWayPegDataResponse_ResponseItem, sidechainID uint32) []*pb.WithdrawalBundle {
	bundles := make([]*pb.WithdrawalBundle, 0)

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
				SidechainId: sidechainID,
				BlockHeight: blockHeight,
				MaxAge:      s.bundleMaxAge,
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
	slices.SortFunc(result, func(a, b *pb.WithdrawalBundle) int {
		return cmp.Or(cmp.Compare(a.BlockHeight, b.BlockHeight), cmp.Compare(a.M6Id, b.M6Id))
	})

	return result
}

// updateBundleAges recalculates age and blocks_left for pending bundles
func (s *Server) updateBundleAges(bundles []*pb.WithdrawalBundle, currentHeight uint32) []*pb.WithdrawalBundle {
	result := make([]*pb.WithdrawalBundle, len(bundles))
	for i, b := range bundles {
		bundleCopy := proto.Clone(b).(*pb.WithdrawalBundle)
		if bundleCopy.Status == "pending" {
			bundleCopy.Age = currentHeight - bundleCopy.BlockHeight
			if bundleCopy.Age < s.bundleMaxAge {
				bundleCopy.BlocksLeft = s.bundleMaxAge - bundleCopy.Age
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
	_ *pb.ListRecentActionsRequest,
) (*pb.ListRecentActionsResponse, error) {
	return &pb.ListRecentActionsResponse{}, nil
}
