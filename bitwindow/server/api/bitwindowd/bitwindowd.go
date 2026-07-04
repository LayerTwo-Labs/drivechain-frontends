package api_bitwindowd

import (
	"cmp"
	"context"
	"database/sql"
	"fmt"
	"net/http"
	"os/exec"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/cpuminer"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bip329"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/utxometadata"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/utils/bandwidth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/datasource"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/sourcegraph/conc/pool"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.BitwindowdServiceHandler = new(Server)

// New creates a new Server. recycle hot-swaps bitwindowd's per-network
// runtime (DB, engines, sub-handlers) in-process when UpdateNetwork is
// called — bitwindowd never exits across a network swap.
func New(
	data datasource.DataSource,
	onShutdown func(ctx context.Context),
	db *sql.DB,
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	walletEngine *engines.WalletEngine,
	config config.Config,
	recycle func(ctx context.Context, network config.Network) error,
) *Server {
	s := &Server{
		data:             data,
		onShutdown:       onShutdown,
		db:               db,
		validator:        validator,
		wallet:           wallet,
		bitcoind:         bitcoind,
		walletEngine:     walletEngine,
		bandwidthTracker: bandwidth.NewTracker(),
		recycle:          recycle,

		config: config,
	}
	return s
}

type Server struct {
	data             datasource.DataSource
	onShutdown       func(ctx context.Context)
	db               *sql.DB
	validator        *service.Service[validatorrpc.ValidatorServiceClient]
	wallet           *service.Service[validatorrpc.WalletServiceClient]
	bitcoind         *service.Service[corerpc.BitcoinServiceClient]
	walletEngine     *engines.WalletEngine
	bandwidthTracker *bandwidth.Tracker
	recycle          func(ctx context.Context, network config.Network) error

	config config.Config

	// Memoizes ListBlocks responses. Validity gated on (height, hash) —
	// hash too, so same-height reorgs invalidate.
	listBlocksCache sync.Map // listBlocksCacheKey -> *listBlocksCacheEntry
	listBlocksTip   atomic.Pointer[blocksTip]
}

type listBlocksCacheKey struct {
	startHeight uint32
	pageSize    uint32
}

type listBlocksCacheEntry struct {
	blocks  []*pb.Block
	hasMore bool
	tip     blocksTip
}

type blocksTip struct {
	height uint32
	hash   string
}

// observeTip records the current tip and returns true the first time we
// see a new (height, hash) pair. Same-height reorgs are caught because
// the hash changes.
func (s *Server) observeTip(height uint32, hash string) (changed bool) {
	next := blocksTip{height: height, hash: hash}
	for {
		prev := s.listBlocksTip.Load()
		if prev != nil && *prev == next {
			return false
		}
		if s.listBlocksTip.CompareAndSwap(prev, &next) {
			return true
		}
	}
}

// UpdateNetwork swaps bitcoind to a new network and recycles bitwindowd's
// per-network runtime in-process — bitwindowd never exits.
//
// Sequence:
//  1. Forward to orchestratord's SetBitcoinConfigNetwork. orchestratord
//     rewrites bitcoin.conf, restarts bitcoind on the new chain, and
//     atomically rebuilds its hosted bitcoin proxy. All `service.Service`
//     reconnect loops (bitcoind, enforcer, wallet) reconverge automatically.
//  2. Hand off to recycle: closes the old DB, opens a new network-scoped
//     one, rebuilds engines + sub-handlers, atomic-swaps the listener mux.
//     The HTTP server stays bound to the same port across the swap.
//  3. Return success.
func (s *Server) UpdateNetwork(ctx context.Context, req *connect.Request[pb.UpdateNetworkRequest]) (*connect.Response[pb.UpdateNetworkResponse], error) {
	if req.Msg.Network == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("network required"))
	}
	if s.config.OrchestratorAddr == "" {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("orchestrator.addr not configured"))
	}
	if s.recycle == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, fmt.Errorf("recycle callback not wired"))
	}

	network := config.Network(req.Msg.Network)
	if !isKnownNetwork(network) {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("unknown network: %q", req.Msg.Network))
	}

	confClient := orchrpc.NewBitcoinConfServiceClient(
		http.DefaultClient,
		s.config.OrchestratorAddr,
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(s.config.BitwindowDir())),
	)
	if _, err := confClient.SetBitcoinConfigNetwork(ctx, connect.NewRequest(&orchpb.SetBitcoinConfigNetworkRequest{
		Network: req.Msg.Network,
	})); err != nil {
		return nil, connect.NewError(connect.CodeOf(err), fmt.Errorf("orchestrator.SetBitcoinConfigNetwork: %w", err))
	}

	if err := s.recycle(ctx, network); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("recycle runtime to %s: %w", network, err))
	}

	zerolog.Ctx(ctx).Info().Str("network", req.Msg.Network).Msg("network swap complete (in-process)")
	return connect.NewResponse(&pb.UpdateNetworkResponse{}), nil
}

func isKnownNetwork(n config.Network) bool {
	switch n {
	case config.NetworkMainnet, config.NetworkForknet, config.NetworkSignet, config.NetworkTestnet, config.NetworkRegtest:
		return true
	}
	return false
}

// Stop implements drivechainv1connect.DrivechainServiceHandler.
// Stop is the window-close hook + clean-exit entry point. Relays to
// orchestratord.Shutdown — orchestratord is detached and drains
// bitcoind/enforcer in the background over ~90s — then triggers bitwindowd's
// own teardown. Acks the frontend in milliseconds so the window can
// windowManager.destroy() immediately. With skip_downstream=true the
// orchestratord stack stays running (only bitwindowd dies).
func (s *Server) Stop(ctx context.Context, req *connect.Request[pb.BitwindowdServiceStopRequest]) (*connect.Response[emptypb.Empty], error) {
	log := zerolog.Ctx(ctx)

	if req.Msg.SkipDownstream {
		log.Info().Msg("skip_downstream=true, bitwindowd-only exit (orchestratord stays running)")
	} else if s.config.OrchestratorAddr != "" {
		client := orchrpc.NewOrchestratorServiceClient(
			http.DefaultClient,
			s.config.OrchestratorAddr,
			connect.WithGRPC(),
			connect.WithInterceptors(localauth.Interceptor(s.config.BitwindowDir())),
		)
		// Fresh context — the inbound ctx may be cancelled by the frontend
		// the moment we return. Short timeout because orchestratord acks
		// immediately (the drain runs in its own goroutine).
		rpcCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if _, err := client.Shutdown(rpcCtx, connect.NewRequest(&orchpb.ShutdownRequest{})); err != nil {
			log.Warn().Err(err).Msg("relay Shutdown to orchestratord (continuing with bitwindowd teardown)")
		} else {
			log.Info().Msg("orchestratord Shutdown relayed; it will drain children in the background")
		}
	}

	// Kick off bitwindowd's own teardown after we return the ack to the
	// frontend.
	defer func() {
		log.Info().Msg("bitwindowd shutting down")
		s.onShutdown(context.Background())
	}()

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) CreateDenial(
	ctx context.Context,
	req *connect.Request[pb.CreateDenialRequest],
) (*connect.Response[emptypb.Empty], error) {
	if req.Msg.DelaySeconds <= 0 {
		err := fmt.Errorf("delay_seconds must be positive")
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid delay_seconds")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if req.Msg.NumHops <= 0 {
		err := fmt.Errorf("num_hops must be positive")
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid num_hops")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// Get active wallet to determine routing
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get active wallet")
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("could not get active wallet: %w", err))
	}

	// Deniability requires spending, which a watch-only wallet cannot do.
	if activeWallet.IsWatchOnly() {
		err := fmt.Errorf("deniability is not supported for watch-only wallets")
		zerolog.Ctx(ctx).Error().Err(err).Msg("unsupported wallet type")
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	// List UTXOs based on wallet type
	var utxoExists bool
	switch activeWallet.WalletType {
	case engines.WalletTypeEnforcer:
		utxoExists, err = s.checkEnforcerUTXO(ctx, req.Msg.Txid, req.Msg.Vout)
	case engines.WalletTypeBitcoinCore:
		utxoExists, err = s.checkBitcoinCoreUTXO(ctx, activeWallet.ID, req.Msg.Txid, req.Msg.Vout)
	case engines.WalletTypeElectrum:
		err = fmt.Errorf("deniability is not supported for electrum wallets")
	default:
		err = fmt.Errorf("unknown wallet type: %s", activeWallet.WalletType)
	}

	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not check UTXO")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	if !utxoExists {
		err := fmt.Errorf("utxo %s:%d not found in wallet", req.Msg.Txid, req.Msg.Vout)
		zerolog.Ctx(ctx).Error().Err(err).Msg("utxo not found in wallet")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	denial, err := deniability.GetByTip(ctx, s.db, req.Msg.Txid, lo.ToPtr(int32(req.Msg.Vout)))
	if err != nil {
		err = fmt.Errorf("could not get by tip: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get denial by tip")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	if denial != nil {
		zerolog.Ctx(ctx).Info().
			Int64("denial_id", denial.ID).
			Str("txid", req.Msg.Txid).
			Uint32("vout", req.Msg.Vout).
			Int32("delay_seconds", req.Msg.DelaySeconds).
			Int32("num_hops", req.Msg.NumHops).
			Msg("CreateDenial: found existing denial, updating values")

		// a denial for this utxo already exists. Let's piggy back on that by updating its values
		if err := deniability.Update(
			ctx, s.db, denial.ID, time.Duration(req.Msg.DelaySeconds)*time.Second, req.Msg.NumHops, req.Msg.Txid, int32(req.Msg.Vout),
		); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not update denial")
			return nil, connect.NewError(connect.CodeInternal, err)
		}

		return connect.NewResponse(&emptypb.Empty{}), nil
	}

	zerolog.Ctx(ctx).Info().
		Str("txid", req.Msg.Txid).
		Uint32("vout", req.Msg.Vout).
		Int32("delay_seconds", req.Msg.DelaySeconds).
		Int32("num_hops", req.Msg.NumHops).
		Str("wallet_id", activeWallet.ID).
		Ints64("target_utxo_sizes", req.Msg.TargetUtxoSizes).
		Msg("CreateDenial: creating new denial")

	// UTXO exists, create the denial with the wallet ID
	_, err = deniability.Create(
		ctx,
		s.db,
		activeWallet.ID,
		req.Msg.Txid,
		int32(req.Msg.Vout),
		time.Duration(req.Msg.DelaySeconds)*time.Second,
		req.Msg.NumHops,
		req.Msg.TargetUtxoSizes,
	)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not create denial")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) CancelDenial(
	ctx context.Context,
	req *connect.Request[pb.CancelDenialRequest],
) (*connect.Response[emptypb.Empty], error) {
	// Scope the mutation to the active wallet so one wallet cannot cancel
	// another wallet's deniability plan.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get active wallet")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	err = deniability.Cancel(ctx, s.db, activeWallet.ID, req.Msg.Id, "cancelled by user")
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not cancel denial")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) PauseDenial(
	ctx context.Context,
	req *connect.Request[pb.PauseDenialRequest],
) (*connect.Response[emptypb.Empty], error) {
	// Scope the mutation to the active wallet so one wallet cannot pause
	// another wallet's deniability plan.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get active wallet")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	err = deniability.Pause(ctx, s.db, activeWallet.ID, req.Msg.Id)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not pause denial")
		return nil, err
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) ResumeDenial(
	ctx context.Context,
	req *connect.Request[pb.ResumeDenialRequest],
) (*connect.Response[emptypb.Empty], error) {
	// Scope the mutation to the active wallet so one wallet cannot resume
	// another wallet's deniability plan.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get active wallet")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	err = deniability.Resume(ctx, s.db, activeWallet.ID, req.Msg.Id)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not resume denial")
		return nil, err
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) CreateAddressBookEntry(ctx context.Context, req *connect.Request[pb.CreateAddressBookEntryRequest]) (*connect.Response[pb.CreateAddressBookEntryResponse], error) {
	direction, err := addressbook.DirectionFromProto(req.Msg.Direction)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid direction")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	addr := strings.TrimSpace(req.Msg.Address)
	kind := addressbook.ClassifyAddress(addr)
	if kind == pb.AddressType_ADDRESS_TYPE_UNKNOWN || kind == pb.AddressType_ADDRESS_TYPE_UNSPECIFIED {
		err := fmt.Errorf(
			"invalid address %q: must be (1) a Bitcoin address on any network, "+
				"(2) a Drivechain deposit address s<slot>_<addr>_<checksum>, or "+
				"(3) a BIP47 v3 payment code", addr,
		)
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid address format")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// A label must map to a single address — reject collisions with a
	// different address (re-saving the same address still upserts below).
	label := strings.TrimSpace(req.Msg.Label)
	if label != "" {
		existing, err := addressbook.List(ctx, s.db)
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not list address book entries")
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		for _, entry := range existing {
			if strings.EqualFold(strings.TrimSpace(entry.Label), label) && entry.Address != addr {
				err := fmt.Errorf("an address book entry with label %q already exists", label)
				return nil, connect.NewError(connect.CodeAlreadyExists, err)
			}
		}
	}

	// User-added addresses don't belong to a specific wallet (nil walletId)
	if err := addressbook.Create(ctx, s.db, nil, req.Msg.Label, addr, direction); err != nil {
		// Check if this is a unique constraint error for address+direction
		if err.Error() == addressbook.ErrUniqueAddress {
			// Get the existing entry to update
			entries, err := addressbook.List(ctx, s.db)
			if err != nil {
				zerolog.Ctx(ctx).Error().Err(err).Msg("could not list address book entries")
				return nil, connect.NewError(connect.CodeInternal, err)
			}

			// Find the entry with matching address and direction
			for _, entry := range entries {
				if entry.Address == addr && entry.Direction == direction {
					// Update its label instead
					if err := addressbook.UpdateLabel(ctx, s.db, entry.ID, req.Msg.Label); err != nil {
						zerolog.Ctx(ctx).Error().Err(err).Msg("could not update address book entry label")
						return nil, connect.NewError(connect.CodeInternal, err)
					}
					break // this break will move us to the list --> find --> return
				}
			}
		} else {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not create address book entry")
			return nil, connect.NewError(connect.CodeInternal, err)
		}
	}

	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get address book entry")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	entry, ok := lo.Find(entries, func(entry addressbook.Entry) bool {
		return entry.Address == addr && entry.Direction == direction
	})
	if !ok {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not find newly created address book entry")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.CreateAddressBookEntryResponse{
		Entry: EntryToProto(&entry),
	}), nil
}

func EntryToProto(entry *addressbook.Entry) *pb.AddressBookEntry {
	walletId := ""
	if entry.WalletID != nil {
		walletId = *entry.WalletID
	}
	return &pb.AddressBookEntry{
		Id:         entry.ID,
		Label:      entry.Label,
		Address:    entry.Address,
		Direction:  addressbook.DirectionToProto(entry.Direction),
		CreateTime: timestamppb.New(entry.CreatedAt),
		WalletId:   walletId,
		Type:       addressbook.ClassifyAddress(entry.Address),
	}
}

func (s *Server) ListAddressBook(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListAddressBookResponse], error) {
	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list address book entries")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var pbEntries []*pb.AddressBookEntry
	for i := range entries {
		pbEntries = append(pbEntries, EntryToProto(&entries[i]))
	}

	return connect.NewResponse(&pb.ListAddressBookResponse{
		Entries: pbEntries,
	}), nil
}

func (s *Server) UpdateAddressBookEntry(ctx context.Context, req *connect.Request[pb.UpdateAddressBookEntryRequest]) (*connect.Response[emptypb.Empty], error) {
	label := strings.TrimSpace(req.Msg.Label)
	if label != "" {
		existing, err := addressbook.List(ctx, s.db)
		if err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not list address book entries")
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		for _, entry := range existing {
			if entry.ID != req.Msg.Id && strings.EqualFold(strings.TrimSpace(entry.Label), label) {
				err := fmt.Errorf("an address book entry with label %q already exists", label)
				return nil, connect.NewError(connect.CodeAlreadyExists, err)
			}
		}
	}

	if err := addressbook.UpdateLabel(ctx, s.db, req.Msg.Id, req.Msg.Label); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not update address book entry")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) DeleteAddressBookEntry(ctx context.Context, req *connect.Request[pb.DeleteAddressBookEntryRequest]) (*connect.Response[emptypb.Empty], error) {
	if err := addressbook.Delete(ctx, s.db, req.Msg.Id); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not delete address book entry")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// GetSyncInfo implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) GetSyncInfo(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetSyncInfoResponse], error) {
	tip, err := s.data.BlockchainInfo(ctx, &corepb.GetBlockchainInfoRequest{})
	if err != nil {
		// Bitcoin Core returns -28 from every RPC while it's still loading the
		// block index, verifying blocks, or rescanning the wallet. Treat that
		// as "still booting" and surface the message so the UI can render
		// "Verifying blocks…" instead of a misleading "0 / 0 blocks" state.
		if msg := engines.ExtractBitcoindStartupMessage(err.Error()); msg != "" {
			return connect.NewResponse(&pb.GetSyncInfoResponse{
				StartupMessage: msg,
			}), nil
		}
		return nil, err
	}

	processedTip, err := blocks.GetProcessedTip(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get processed tip")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	if processedTip == nil {
		return connect.NewResponse(&pb.GetSyncInfoResponse{
			TipBlockHeight:      0,
			TipBlockTime:        0,
			TipBlockHash:        "",
			TipBlockProcessedAt: &timestamppb.Timestamp{},
			HeaderHeight:        int64(tip.Headers),
			SyncProgress:        0,
		}), nil
	}

	return connect.NewResponse(&pb.GetSyncInfoResponse{
		TipBlockHeight:      int64(processedTip.Height),
		TipBlockTime:        processedTip.ProcessedAt.Unix(),
		TipBlockHash:        processedTip.Hash.String(),
		TipBlockProcessedAt: timestamppb.New(processedTip.ProcessedAt),
		SyncProgress:        float64(processedTip.Height) / float64(tip.Blocks),
		HeaderHeight:        int64(tip.Headers),
	}), nil
}

// SetTransactionNote implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) SetTransactionNote(ctx context.Context, req *connect.Request[pb.SetTransactionNoteRequest]) (*connect.Response[emptypb.Empty], error) {
	// Notes are private, wallet-local metadata. Scope them to the wallet the
	// user is currently viewing (the active wallet) so a note written here does
	// not surface in another wallet's transaction list.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get active wallet")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	if err := transactions.SetNote(ctx, s.db, activeWallet.ID, req.Msg.Txid, req.Msg.Note); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not set transaction note")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

// ExportLabels implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) ExportLabels(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.ExportLabelsResponse], error) {
	addrs, err := addressbook.List(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list address book entries")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	notes, err := transactions.List(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list transaction notes")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	utxos, err := utxometadata.Get(ctx, s.db, nil)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list utxo metadata")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var labels []bip329.Label
	for _, a := range addrs {
		if strings.TrimSpace(a.Label) == "" {
			continue
		}
		labels = append(labels, bip329.Label{Type: bip329.TypeAddr, Ref: a.Address, Label: a.Label})
	}
	for _, n := range notes {
		if strings.TrimSpace(n.Note) == "" {
			continue
		}
		labels = append(labels, bip329.Label{Type: bip329.TypeTx, Ref: n.TxID, Label: n.Note})
	}
	for _, u := range utxos {
		if strings.TrimSpace(u.Label) == "" {
			continue
		}
		labels = append(labels, bip329.Label{Type: bip329.TypeOutput, Ref: u.Outpoint, Label: u.Label})
	}

	jsonl, err := bip329.Encode(labels)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not encode labels")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.ExportLabelsResponse{Jsonl: jsonl}), nil
}

// ImportLabels implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) ImportLabels(ctx context.Context, req *connect.Request[pb.ImportLabelsRequest]) (*connect.Response[pb.ImportLabelsResponse], error) {
	// Transaction notes are wallet-scoped; BIP329 tx labels carry only a txid,
	// so import them into the wallet the user is currently viewing.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get active wallet")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	labels, skipped := bip329.Decode(req.Msg.Jsonl)

	resp := &pb.ImportLabelsResponse{Skipped: int64(skipped)}

	for _, l := range labels {
		ref := strings.TrimSpace(l.Ref)
		label := strings.TrimSpace(l.Label)
		if ref == "" || label == "" {
			resp.Skipped++
			continue
		}

		switch l.Type {
		case bip329.TypeAddr:
			if err := s.importAddressLabel(ctx, ref, l.Label); err != nil {
				zerolog.Ctx(ctx).Error().Err(err).Str("ref", ref).Msg("could not import address label")
				resp.Skipped++
				continue
			}
			resp.ImportedAddresses++

		case bip329.TypeTx:
			if err := transactions.SetNote(ctx, s.db, activeWallet.ID, ref, l.Label); err != nil {
				zerolog.Ctx(ctx).Error().Err(err).Str("ref", ref).Msg("could not import transaction note")
				resp.Skipped++
				continue
			}
			resp.ImportedTransactions++

		case bip329.TypeOutput:
			lbl := l.Label
			if err := utxometadata.Set(ctx, s.db, ref, nil, &lbl); err != nil {
				zerolog.Ctx(ctx).Error().Err(err).Str("ref", ref).Msg("could not import utxo label")
				resp.Skipped++
				continue
			}
			resp.ImportedOutputs++

		default:
			resp.Skipped++
		}
	}

	return connect.NewResponse(resp), nil
}

// importAddressLabel upserts an address-book label for an address, classifying
// the address the same way CreateAddressBookEntry does. Unclassifiable
// addresses are rejected so a bad ref is skipped rather than stored.
func (s *Server) importAddressLabel(ctx context.Context, address, label string) error {
	addr := strings.TrimSpace(address)
	kind := addressbook.ClassifyAddress(addr)
	if kind == pb.AddressType_ADDRESS_TYPE_UNKNOWN || kind == pb.AddressType_ADDRESS_TYPE_UNSPECIFIED {
		return fmt.Errorf("invalid address %q", addr)
	}

	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if e.Address == addr {
			return addressbook.UpdateLabel(ctx, s.db, e.ID, label)
		}
	}

	return addressbook.Create(ctx, s.db, nil, label, addr, addressbook.DirectionReceive)
}

// GetFireplaceStats implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) GetFireplaceStats(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetFireplaceStatsResponse], error) {
	// Calculate block count in last 24 hours
	blockCount24h, err := s.getBlockCount24h(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get block count: %w", err))
	}

	// Calculate transaction count in last 24 hours
	txCount24h, err := s.getTransactionCount24h(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get transaction count: %w", err))
	}

	// Calculate coinnews count in last 7 days
	coinnewsCount7d, err := s.getCoinnewsCount7d(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to get coinnews count: %w", err))
	}

	return connect.NewResponse(&pb.GetFireplaceStatsResponse{
		TransactionCount_24H: txCount24h,
		CoinnewsCount_7D:     coinnewsCount7d,
		BlockCount_24H:       blockCount24h,
	}), nil
}

// getBlockCount24h returns the number of blocks in the last 24 hours
func (s *Server) getBlockCount24h(ctx context.Context) (int64, error) {
	cutoffTime := time.Now().Add(-24 * time.Hour)

	var count int64
	err := s.db.QueryRowContext(ctx, `
		SELECT COUNT(*) 
		FROM processed_blocks 
		WHERE block_time >= ?
	`, cutoffTime).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("query block count: %w", err)
	}

	return count, nil
}

// getTransactionCount24h returns the total number of transactions in the last 24 hours
func (s *Server) getTransactionCount24h(ctx context.Context) (int64, error) {
	cutoffTime := time.Now().Add(-24 * time.Hour)

	// Count total txids and subtract number of blocks (thereby excluding coinbase transactions)
	var count int64
	err := s.db.QueryRowContext(ctx, `
		SELECT 
			COALESCE(SUM(json_array_length(txids)) - COUNT(*), 0)
		FROM processed_blocks 
		WHERE block_time >= ?
	`, cutoffTime).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("query transaction count: %w", err)
	}

	return count, nil
}

// getCoinnewsCount7d returns the number of coin news entries in the last 7 days
func (s *Server) getCoinnewsCount7d(ctx context.Context) (int64, error) {
	cutoffTime := time.Now().Add(-7 * 24 * time.Hour)

	var count int64
	err := s.db.QueryRowContext(ctx, `
		SELECT COUNT(*)
		FROM cn_stories s
		JOIN cn_items i ON i.item_id = s.item_id
		WHERE i.block_time >= ?
		  AND trim(s.headline) != ''
	`, cutoffTime).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("query coinnews count: %w", err)
	}

	return count, nil
}

func (s *Server) ListBlocks(ctx context.Context, c *connect.Request[pb.ListBlocksRequest]) (*connect.Response[pb.ListBlocksResponse], error) {
	info, err := s.data.BlockchainInfo(ctx, &corepb.GetBlockchainInfoRequest{})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}
	currentTip := info.Blocks
	currentHash := info.BestBlockHash

	// Default to most recent blocks if no pagination
	startHeight := currentTip
	if c.Msg.StartHeight > 0 {
		startHeight = c.Msg.StartHeight
	}

	// Default page size
	pageSize := uint32(50)
	if c.Msg.PageSize > 0 {
		pageSize = c.Msg.PageSize
	}

	currentValidity := blocksTip{height: currentTip, hash: currentHash}
	if s.observeTip(currentTip, currentHash) {
		s.listBlocksCache.Range(func(k, _ any) bool {
			s.listBlocksCache.Delete(k)
			return true
		})
	}
	cacheKey := listBlocksCacheKey{startHeight: startHeight, pageSize: pageSize}
	if v, ok := s.listBlocksCache.Load(cacheKey); ok {
		entry := v.(*listBlocksCacheEntry)
		if entry.tip == currentValidity {
			// Slice header is freshly allocated; *pb.Block elements
			// are shared and must be treated read-only by the caller.
			out := make([]*pb.Block, len(entry.blocks))
			copy(out, entry.blocks)
			return connect.NewResponse(&pb.ListBlocksResponse{
				RecentBlocks: out,
				HasMore:      entry.hasMore,
			}), nil
		}
	}

	p := pool.NewWithResults[*pb.Block]().
		WithContext(ctx).
		WithCancelOnError().
		WithFirstError()

	for i := uint32(0); i < pageSize; i++ {
		p.Go(func(ctx context.Context) (*pb.Block, error) {
			height := int(startHeight) - int(i)
			// Stop if we hit genesis block
			if height < 0 {
				return nil, nil
			}
			hash, err := s.data.BlockHash(ctx, &corepb.GetBlockHashRequest{
				Height: uint32(height),
			})
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get block hash %d: %w", height, err)
			}

			block, err := s.data.Block(ctx, &corepb.GetBlockRequest{
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				Hash:      hash.Hash,
			})
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get block %s: %w", hash.Hash, err)
			}

			return &pb.Block{
				BlockTime:         block.Time,
				Height:            block.Height,
				Hash:              block.Hash,
				Confirmations:     block.Confirmations,
				Version:           block.Version,
				VersionHex:        block.VersionHex,
				MerkleRoot:        block.MerkleRoot,
				Nonce:             block.Nonce,
				Bits:              block.Bits,
				Difficulty:        block.Difficulty,
				PreviousBlockHash: block.PreviousBlockHash,
				NextBlockHash:     block.NextBlockHash,
				StrippedSize:      block.StrippedSize,
				Size:              block.Size,
				Weight:            block.Weight,
				Txids:             block.Txids,
			}, nil
		})
	}

	blocks, err := p.Wait()
	if err != nil {
		return nil, err
	}

	// Filter out nil blocks (from hitting genesis)
	blocks = lo.Filter(blocks, func(b *pb.Block, _ int) bool {
		return b != nil
	})

	slices.SortFunc(blocks, func(a, b *pb.Block) int {
		return -cmp.Compare(a.Height, b.Height)
	})

	hasMore := startHeight > uint32(len(blocks))
	s.listBlocksCache.Store(cacheKey, &listBlocksCacheEntry{
		blocks:  blocks,
		hasMore: hasMore,
		tip:     currentValidity,
	})

	out := make([]*pb.Block, len(blocks))
	copy(out, blocks)
	return connect.NewResponse(&pb.ListBlocksResponse{
		RecentBlocks: out,
		HasMore:      hasMore,
	}), nil
}

func (s *Server) ListRecentTransactions(ctx context.Context, c *connect.Request[pb.ListRecentTransactionsRequest]) (*connect.Response[pb.ListRecentTransactionsResponse], error) {
	// First get mempool transactions
	mempoolRes, err := s.data.RawMempool(ctx, &corepb.GetRawMempoolRequest{
		Verbose: true,
	})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get mempool: %w", err)
	}

	var transactions []*pb.RecentTransaction

	// Add mempool transactions
	for txid, tx := range mempoolRes.Transactions {
		fee, err := btcutil.NewAmount(tx.Fees.Base)
		if err != nil {
			return nil, fmt.Errorf("could not parse fee: %w", err)
		}

		transactions = append(transactions, &pb.RecentTransaction{
			VirtualSize:      tx.VirtualSize,
			Time:             tx.Time,
			Txid:             txid,
			FeeSats:          uint64(fee),
			ConfirmedInBlock: nil,
		})
	}
	info, err := s.data.BlockchainInfo(ctx, &corepb.GetBlockchainInfoRequest{})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}

	// While Core is in IBD on a populated chain (mainnet / forknet), the
	// historical block walk below is the single biggest source of cs_main
	// pressure on this whole codebase: it issues a per-tx
	// GetRawTransaction for every tx in up to 100 recent blocks. During
	// IBD that storms Core badly enough to push getblockchaininfo past
	// its client timeout. The user has nothing useful to look at in that
	// window anyway — return mempool only and bail.
	if info.InitialBlockDownload && config.IsFullChainNetwork(s.config.BitcoinCoreNetwork) {
		return connect.NewResponse(&pb.ListRecentTransactionsResponse{
			Transactions: transactions,
		}), nil
	}

	// Resolve the requested count up front so the block walk can stop as
	// soon as we have enough.
	count := int64(100)
	if c.Msg.Count > 0 {
		count = c.Msg.Count
	}

	// Get block at latest height
	blockHashRes, err := s.data.Block(ctx, &corepb.GetBlockRequest{
		Hash:      info.BestBlockHash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	})
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get block at height %d: %w", info.Blocks, err)
	}

	// Walk recent blocks, fetching per-tx fee info, until we have `count`
	// non-coinbase transactions. Cap the walk at maxBlocks so an empty
	// signet/regtest chain doesn't run away. Previously this always
	// scanned 100 blocks regardless and threw away the surplus — on
	// mainnet that meant ~300k GetRawTransaction RPCs per call, every
	// 5s, all serialised behind cs_main on Core.
	const maxBlocks = 100
	currentHash := blockHashRes.Hash
walkBlocks:
	for i := 0; i < maxBlocks && currentHash != ""; i++ {
		blockRes, err := s.data.Block(ctx, &corepb.GetBlockRequest{
			Hash:      currentHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO,
		})
		if err != nil {
			return nil, fmt.Errorf("bitcoind: could not get block: %w", err)
		}
		for idx, txid := range blockRes.Txids {
			// Skip coinbase before we pay for GetRawTransaction.
			if idx == 0 {
				continue
			}

			txRes, err := s.data.RawTransaction(ctx, &corepb.GetRawTransactionRequest{
				Txid:      txid,
				Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
			})
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get transaction %s: %w", txid, err)
			}

			fee, err := btcutil.NewAmount(txRes.Fee)
			if err != nil {
				return nil, err
			}

			transactions = append(transactions, &pb.RecentTransaction{
				VirtualSize:      uint32(txRes.Vsize),
				Time:             blockRes.Time,
				Txid:             txid,
				FeeSats:          uint64(fee),
				ConfirmedInBlock: &blockRes.Height,
			})

			if int64(len(transactions)) >= count {
				break walkBlocks
			}
		}

		currentHash = blockRes.PreviousBlockHash
	}

	// Sort by time, newest first
	slices.SortFunc(transactions, func(a, b *pb.RecentTransaction) int {
		return cmp.Compare(b.Time.AsTime().Unix(), a.Time.AsTime().Unix())
	})

	// Limit to requested count
	if count > int64(len(transactions)) {
		count = int64(len(transactions))
	}
	transactions = transactions[:count]

	return connect.NewResponse(&pb.ListRecentTransactionsResponse{
		Transactions: transactions,
	}), nil
}

// getCoinbaseAddress gets a new address from the active wallet for mining rewards
func (s *Server) getCoinbaseAddress(ctx context.Context) (string, error) {
	// Get the active wallet from wallet engine
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		return "", fmt.Errorf("get active wallet: %w", err)
	}

	// Get wallet type
	walletType, err := s.walletEngine.GetWalletBackendType(ctx, activeWallet.ID)
	if err != nil {
		return "", fmt.Errorf("get wallet type: %w", err)
	}

	// get bitcoind-client here because we need it for both watch-only wallets and core wallets
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return "", err
	}

	switch walletType {
	case engines.WalletTypeEnforcer:
		// Get address from enforcer wallet
		wallet, err := s.wallet.Get(ctx)
		if err != nil {
			return "", err
		}
		resp, err := wallet.CreateNewAddress(ctx, connect.NewRequest(&validatorpb.CreateNewAddressRequest{}))
		if err != nil {
			return "", fmt.Errorf("enforcer: create new address: %w", err)
		}
		return resp.Msg.Address, nil

	case engines.WalletTypeBitcoinCore:
		// Watch-only Core wallets import a descriptor; full wallets use the
		// seed-derived wallet. Both serve addresses from Bitcoin Core.
		var walletName string
		var err error
		if activeWallet.IsWatchOnly() {
			walletName, err = s.walletEngine.EnsureWatchOnlyWallet(ctx, activeWallet.ID)
		} else {
			walletName, err = s.walletEngine.GetBitcoinCoreWalletName(ctx, activeWallet.ID)
		}
		if err != nil {
			return "", fmt.Errorf("ensure core wallet: %w", err)
		}
		addr, err := bitcoind.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
			Wallet: walletName,
		}))
		if err != nil {
			return "", err
		}
		return addr.Msg.Address, nil

	case engines.WalletTypeElectrum:
		// Electrum derives the address in the orchestrator (Esplora-backed).
		return s.walletEngine.GetElectrumReceiveAddress(ctx, activeWallet.ID)

	default:
		return "", fmt.Errorf("unsupported wallet type: %s", walletType)
	}
}

func (s *Server) MineBlocks(ctx context.Context, req *connect.Request[emptypb.Empty], stream *connect.ServerStream[pb.MineBlocksResponse]) error {
	// Verify we're actually able to connect to Bitcoin Core
	info, err := s.data.BlockchainInfo(ctx, &corepb.GetBlockchainInfoRequest{})
	if err != nil {
		return err
	}

	switch info.Chain {
	case "regtest", "testnet3", "testnet4", "forknet":
	default:
		return connect.NewError(
			connect.CodeFailedPrecondition,
			fmt.Errorf(
				"generating blocks on %s is not supported",
				cmp.Or(info.Chain, "unknown network"),
			),
		)
	}

	// Get a payout address from the active wallet for mining rewards
	address, err := s.getCoinbaseAddress(ctx)
	if err != nil {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("get mining address: %w", err))
	}

	// cpuminer talks raw bitcoind JSON-RPC; pull the live creds from
	// orchestratord so we always match whatever bitcoind is running with.
	confClient := orchrpc.NewBitcoinConfServiceClient(
		http.DefaultClient,
		s.config.OrchestratorAddr,
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(s.config.BitwindowDir())),
	)
	confResp, err := confClient.GetBitcoinConfig(ctx, connect.NewRequest(&orchpb.GetBitcoinConfigRequest{}))
	if err != nil {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf("read bitcoin config from orchestrator: %w", err))
	}
	miner, err := cpuminer.New(cpuminer.Config{
		RpcURL:          fmt.Sprintf("http://localhost:%d", confResp.Msg.RpcPort),
		RpcUser:         confResp.Msg.RpcUser,
		RpcPass:         confResp.Msg.RpcPassword,
		Routines:        1, // Single routine sufficient for regtest/testnet mining
		CoinbaseAddress: address,
	})
	if err != nil {
		return fmt.Errorf("create miner: %w", err)
	}

	errs := make(chan error)

	start := time.Now()

	go func() {
		for block := range miner.AcceptedBlocks() {
			if err := stream.Send(&pb.MineBlocksResponse{
				Event: &pb.MineBlocksResponse_BlockFound_{
					BlockFound: &pb.MineBlocksResponse_BlockFound{
						BlockHash: block.String(),
					},
				},
			}); err != nil {
				errs <- fmt.Errorf("send block found update: %w", err)
			}
		}
	}()

	go func() {
		if err := miner.Start(ctx); err != nil {
			errs <- err
		}
	}()

	hashRateTicker := time.NewTicker(time.Second * 5)
	defer hashRateTicker.Stop()

	go func() {
		for range hashRateTicker.C {
			hashRate := miner.GetHashes()
			if err := stream.Send(&pb.MineBlocksResponse{
				Event: &pb.MineBlocksResponse_HashRate_{
					HashRate: &pb.MineBlocksResponse_HashRate{
						HashRate: float64(hashRate) / time.Since(start).Seconds(),
					},
				},
			}); err != nil {
				errs <- fmt.Errorf("send hash rate update: %w", err)
			}
		}
	}()

	return <-errs
}

func (s *Server) GetNetworkStats(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.GetNetworkStatsResponse], error) {
	// Fetch blockchain info
	blockchainInfo, err := s.data.BlockchainInfo(ctx, &corepb.GetBlockchainInfoRequest{})
	if err != nil {
		// -28 / wallet-loading errors mean bitcoind is still booting. Return
		// Unavailable so the Dart caller treats this as "still warming up" and
		// keeps its previous stats instead of toasting an Internal error.
		if engines.IsBitcoinCoreStartupError(err.Error()) {
			return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get blockchain info: %w", err))
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get blockchain info: %w", err))
	}

	// Calculate average block time from last 144 blocks
	avgBlockTime, err := s.calculateAverageBlockTime(ctx, int64(blockchainInfo.Blocks))
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("calculate average block time")
		avgBlockTime = 600.0 // Default to 10 minutes
	}

	// Get difficulty from latest block
	difficulty := 0.0
	if blockchainInfo.Blocks > 0 {
		hash, err := s.data.BlockHash(ctx, &corepb.GetBlockHashRequest{
			Height: blockchainInfo.Blocks,
		})
		if err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).Msg("get latest block hash for difficulty")
		} else {
			block, err := s.data.Block(ctx, &corepb.GetBlockRequest{
				Hash:      hash.Hash,
				Verbosity: 1,
			})
			if err != nil {
				zerolog.Ctx(ctx).Warn().Err(err).Msg("get latest block for difficulty")
			} else {
				difficulty = block.Difficulty
			}
		}
	}

	// Get network info for version and subversion
	networkInfo, err := s.data.NetworkInfo(ctx, &corepb.GetNetworkInfoRequest{})
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("get network info")
	}

	// Get net totals for bandwidth statistics
	netTotals, err := s.data.NetTotals(ctx, &corepb.GetNetTotalsRequest{})
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("get net totals")
	}

	// Get peer info
	peerInfo, err := s.data.PeerInfo(ctx, &corepb.GetPeerInfoRequest{})
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get peer info: %w", err))
	}

	// Count connections by direction
	connectionsIn := int32(0)
	connectionsOut := int32(0)
	for _, peer := range peerInfo.Peers {
		if peer.Inbound {
			connectionsIn++
		} else {
			connectionsOut++
		}
	}

	// Extract network info fields
	networkVersion := int32(0)
	subversion := ""
	if networkInfo != nil {
		networkVersion = networkInfo.Version
		subversion = networkInfo.Subversion
	}

	// Extract bandwidth statistics
	totalBytesReceived := uint64(0)
	totalBytesSent := uint64(0)
	if netTotals != nil {
		totalBytesReceived = netTotals.TotalBytesRecv
		totalBytesSent = netTotals.TotalBytesSent
	}

	// Get per-process bandwidth statistics
	var bitcoindBandwidth *pb.ProcessBandwidth
	bitcoindPID := findPIDByName("bitcoind")
	if bitcoindPID > 0 {
		stats, err := s.bandwidthTracker.GetStats(bitcoindPID, "bitcoind")
		if err == nil {
			bitcoindBandwidth = &pb.ProcessBandwidth{
				ProcessName:     stats.ProcessName,
				Pid:             int32(stats.PID),
				RxBytesPerSec:   stats.RxBytesPerSec,
				TxBytesPerSec:   stats.TxBytesPerSec,
				TotalRxBytes:    stats.TotalRxBytes,
				TotalTxBytes:    stats.TotalTxBytes,
				ConnectionCount: stats.ConnectionCount,
			}
		}
	}

	var enforcerBandwidth *pb.ProcessBandwidth
	enforcerPID := findPIDByName("bip300301-enforcer")
	if enforcerPID > 0 {
		stats, err := s.bandwidthTracker.GetStats(enforcerPID, "bip300301-enforcer")
		if err == nil {
			enforcerBandwidth = &pb.ProcessBandwidth{
				ProcessName:     stats.ProcessName,
				Pid:             int32(stats.PID),
				RxBytesPerSec:   stats.RxBytesPerSec,
				TxBytesPerSec:   stats.TxBytesPerSec,
				TotalRxBytes:    stats.TotalRxBytes,
				TotalTxBytes:    stats.TotalTxBytes,
				ConnectionCount: stats.ConnectionCount,
			}
		}
	}

	return connect.NewResponse(&pb.GetNetworkStatsResponse{
		NetworkHashrate:    0, // Requires getmininginfo (mining-specific)
		Difficulty:         difficulty,
		PeerCount:          int32(len(peerInfo.Peers)),
		TotalBytesReceived: totalBytesReceived,
		TotalBytesSent:     totalBytesSent,
		BlockHeight:        int64(blockchainInfo.Blocks),
		AvgBlockTime:       avgBlockTime,
		NetworkVersion:     networkVersion,
		Subversion:         subversion,
		ConnectionsIn:      connectionsIn,
		ConnectionsOut:     connectionsOut,
		BitcoindBandwidth:  bitcoindBandwidth,
		EnforcerBandwidth:  enforcerBandwidth,
	}), nil
}

// findPIDByName finds a process PID by its name
func findPIDByName(processName string) int {
	cmd := exec.Command("pgrep", "-x", processName)
	output, err := cmd.Output()
	if err != nil {
		return 0
	}

	pidStr := strings.TrimSpace(string(output))
	if pidStr == "" {
		return 0
	}

	// pgrep may return multiple PIDs, take the first one
	lines := strings.Split(pidStr, "\n")
	pid, err := strconv.Atoi(lines[0])
	if err != nil {
		return 0
	}

	return pid
}

func (s *Server) calculateAverageBlockTime(ctx context.Context, currentHeight int64) (float64, error) {
	// Get blocks from last 144 blocks or from genesis if we don't have that many
	lookback := min(int64(144), currentHeight)
	if lookback <= 1 {
		return 600.0, nil // Default to 10 minutes if not enough blocks
	}

	// Get the first block in range
	firstHeight := currentHeight - lookback
	firstBlock, err := s.getBlockAtHeight(ctx, firstHeight)
	if err != nil {
		return 0, fmt.Errorf("get first block: %w", err)
	}

	// Get the last block (current tip)
	lastBlock, err := s.getBlockAtHeight(ctx, currentHeight)
	if err != nil {
		return 0, fmt.Errorf("get last block: %w", err)
	}

	// Calculate average
	timeDiff := lastBlock - firstBlock
	if timeDiff <= 0 {
		return 600.0, nil
	}

	return float64(timeDiff) / float64(lookback), nil
}

func (s *Server) getBlockAtHeight(ctx context.Context, height int64) (int64, error) {
	hash, err := s.data.BlockHash(ctx, &corepb.GetBlockHashRequest{
		Height: uint32(height),
	})
	if err != nil {
		return 0, fmt.Errorf("get block hash: %w", err)
	}

	block, err := s.data.Block(ctx, &corepb.GetBlockRequest{
		Hash:      hash.Hash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	})
	if err != nil {
		return 0, fmt.Errorf("get block: %w", err)
	}

	if block.Time == nil {
		return 0, fmt.Errorf("block time is nil for height %d", height)
	}

	return block.Time.Seconds, nil
}

// checkEnforcerUTXO checks if a UTXO exists in the enforcer wallet
func (s *Server) checkEnforcerUTXO(ctx context.Context, txid string, vout uint32) (bool, error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return false, fmt.Errorf("get enforcer wallet: %w", err)
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return false, fmt.Errorf("list enforcer utxos: %w", err)
	}

	return lo.ContainsBy(utxos.Msg.Outputs, func(utxo *validatorpb.ListUnspentOutputsResponse_Output) bool {
		return utxo.Txid.Hex.Value == txid && utxo.Vout == vout
	}), nil
}

// checkBitcoinCoreUTXO checks if a UTXO exists in a Bitcoin Core wallet
func (s *Server) checkBitcoinCoreUTXO(ctx context.Context, walletID string, txid string, vout uint32) (bool, error) {
	walletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletID)
	if err != nil {
		return false, fmt.Errorf("get wallet name: %w", err)
	}

	utxos, err := s.data.ListUnspent(ctx, &corepb.ListUnspentRequest{
		Wallet: walletName,
	})
	if err != nil {
		return false, fmt.Errorf("list bitcoin core utxos: %w", err)
	}

	return lo.ContainsBy(utxos.Unspent, func(utxo *corepb.UnspentOutput) bool {
		return utxo.Txid == txid && utxo.Vout == vout
	}), nil
}
