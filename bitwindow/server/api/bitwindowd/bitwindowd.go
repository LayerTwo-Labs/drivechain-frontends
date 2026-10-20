package bitwindowd

import (
	"cmp"
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os/exec"
	"runtime"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/sourcegraph/conc/pool"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/miningpools"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bip329"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	cnstore "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinnews"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/mempooltx"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/utxometadata"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/utils/bandwidth"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

var _ rpc.BitwindowdServiceHandler = new(Server)

// New creates a new Server. recycle hot-swaps bitwindowd's per-network
// runtime (DB, engines, sub-handlers) in-process when UpdateNetwork is
// called — bitwindowd never exits across a network swap.
func New(
	onShutdown func(ctx context.Context),
	db *sql.DB,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	walletEngine *engines.WalletEngine,
	mempoolWatcher *engines.MempoolWatcher,
	pools *miningpools.Registry,
	config config.Config,
	recycle func(ctx context.Context, network config.Network, networkID string, resetFrom uint32) error,
) *Server {
	s := &Server{
		onShutdown:       onShutdown,
		db:               db,
		bitcoind:         bitcoind,
		walletEngine:     walletEngine,
		mempoolWatcher:   mempoolWatcher,
		pools:            pools,
		bandwidthTracker: bandwidth.NewTracker(),
		recycle:          recycle,

		config: config,
	}
	return s
}

type Server struct {
	onShutdown       func(ctx context.Context)
	db               *sql.DB
	bitcoind         *service.Service[corerpc.BitcoinServiceClient]
	walletEngine     *engines.WalletEngine
	mempoolWatcher   *engines.MempoolWatcher
	pools            *miningpools.Registry
	bandwidthTracker *bandwidth.Tracker
	recycle          func(ctx context.Context, network config.Network, networkID string, resetFrom uint32) error

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
//  1. Forward to drivechaind's SetBitcoinConfigNetwork. drivechaind
//     rewrites bitcoin.conf, restarts bitcoind on the new chain, and
//     atomically rebuilds its hosted bitcoin proxy. All `service.Service`
//     reconnect loops (bitcoind, enforcer, wallet) reconverge automatically.
//  2. Hand off to recycle: closes the old DB, opens a new network-scoped
//     one, rebuilds engines + sub-handlers, atomic-swaps the listener mux.
//     The HTTP server stays bound to the same port across the swap.
//  3. Return success.
func (s *Server) UpdateNetwork(ctx context.Context, req *pb.UpdateNetworkRequest) (*pb.UpdateNetworkResponse, error) {
	if req.Network == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "network required")
	}

	network := config.Network(req.Network)
	if !isKnownNetwork(network) {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "unknown network: %q", req.Network)
	}

	confClient := dial.BitcoinConf(s.config.OrchestratorAddr, s.config.BitwindowDir())
	// The orchestrator takes the catalog id; this server takes the network it
	// belongs to, because its own runtime is per-network.
	target := req.NetworkId
	if target == "" {
		target = req.Network
	}
	// Planned before the switch runs: once it has, the plan reads as a no-op.
	var resetFrom uint32
	if network == config.NetworkECash && req.NetworkId != "" {
		plan, err := confClient.PlanECashSwitch(ctx, &orchpb.PlanECashSwitchRequest{
			NetworkId: req.NetworkId,
		})
		if err != nil {
			return nil, connect.NewError(connect.CodeOf(err), fmt.Sprintf("orchestrator.PlanECashSwitch: %s", err)).WithCause(err)
		}
		if plan.NeedsRollback {
			resetFrom = plan.RewindHeight + 1
		} else {
			// A completed migration already moved Core, so the switch plan has no rollback.
			client := dial.Orchestrator(s.config.OrchestratorAddr, s.config.BitwindowDir())
			status, err := client.GetECashMigrationStatus(ctx, &orchpb.GetECashMigrationStatusRequest{})
			if err != nil {
				return nil, connect.NewError(connect.CodeOf(err), fmt.Sprintf("orchestrator.GetECashMigrationStatus: %s", err)).WithCause(err)
			}
			migration := status.GetStatus()
			if migration.GetComplete() && migration.GetToId() == target && !migration.GetWalletOnly() {
				resetFrom = uint32(migration.GetCommonHeight()) + 1
			}
		}
	}
	if _, err := confClient.SetBitcoinConfigNetwork(ctx, &orchpb.SetBitcoinConfigNetworkRequest{
		Network: target,
		DataDir: req.DataDir,
	}); err != nil {
		return nil, connect.NewError(connect.CodeOf(err), fmt.Sprintf("orchestrator.SetBitcoinConfigNetwork: %s", err)).WithCause(err)
	}

	if err := s.recycle(ctx, network, target, resetFrom); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("recycle runtime to %s: %s", network, err)).WithCause(err)
	}

	zerolog.Ctx(ctx).Info().Str("network", req.Network).Msg("network swap complete (in-process)")
	return &pb.UpdateNetworkResponse{}, nil
}

func isKnownNetwork(n config.Network) bool {
	switch n {
	case config.NetworkMainnet, config.NetworkECash, config.NetworkSignet, config.NetworkTestnet, config.NetworkRegtest:
		return true
	}
	return false
}

// Stop implements bitwindowdv1connect.BitwindowdServiceHandler.
// Stop is the window-close hook + clean-exit entry point. Relays to
// drivechaind.Shutdown — drivechaind is detached and drains
// bitcoind/enforcer in the background over ~90s — then triggers bitwindowd's
// own teardown. Acks the frontend in milliseconds so the window can
// windowManager.destroy() immediately. With skip_downstream=true the
// drivechaind stack stays running (only bitwindowd dies).
func (s *Server) Stop(ctx context.Context, req *pb.BitwindowdServiceStopRequest) (*emptypb.Empty, error) {
	log := zerolog.Ctx(ctx)

	if req.SkipDownstream {
		log.Info().Msg("skip_downstream=true, bitwindowd-only exit (drivechaind stays running)")
	} else {
		client := dial.Orchestrator(s.config.OrchestratorAddr, s.config.BitwindowDir())
		// Fresh context — the inbound ctx may be cancelled by the frontend
		// the moment we return. Short timeout because drivechaind acks
		// immediately (the drain runs in its own goroutine).
		rpcCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
		defer cancel()
		// only_if_last: a sidechain frontend may hold drivechaind directly.
		if _, err := client.Shutdown(rpcCtx, &orchpb.ShutdownRequest{OnlyIfLast: true}); err != nil {
			log.Warn().Err(err).Msg("relay Shutdown to drivechaind (continuing with bitwindowd teardown)")
		} else {
			log.Info().Msg("drivechaind Shutdown relayed; it will drain children in the background")
		}
	}

	// Kick off bitwindowd's own teardown after we return the ack to the
	// frontend.
	defer func() {
		log.Info().Msg("bitwindowd shutting down")
		s.onShutdown(context.WithoutCancel(ctx))
	}()

	return &emptypb.Empty{}, nil
}

func (s *Server) CreateDenial(
	ctx context.Context,
	req *pb.CreateDenialRequest,
) (*emptypb.Empty, error) {
	if req.DelaySeconds <= 0 {
		err := errors.New("delay_seconds must be positive")
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	if req.NumHops <= 0 {
		err := errors.New("num_hops must be positive")
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	// Get active wallet to determine routing
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get active wallet: %s", err)).WithCause(err)
	}

	// Deniability requires spending, which a watch-only wallet cannot do.
	if activeWallet.IsWatchOnly() {
		err := errors.New("deniability is not supported for watch-only wallets")
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	// List UTXOs based on wallet type
	var utxoExists bool
	switch activeWallet.WalletType {
	case engines.WalletTypeBitcoinCore:
		utxoExists, err = s.checkBitcoinCoreUTXO(ctx, activeWallet.ID, req.Txid, req.Vout)
	case engines.WalletTypeElectrum:
		utxoExists, err = s.checkElectrumUTXO(ctx, activeWallet.ID, req.Txid, req.Vout)
	default:
		return nil, connect.Errorf(connect.CodeInternal, "unknown wallet type: %s", activeWallet.WalletType)
	}
	if err != nil {
		return nil, err
	}

	if !utxoExists {
		err := fmt.Errorf("utxo %s:%d not found in wallet", req.Txid, req.Vout)
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	denial, err := deniability.GetByTip(ctx, s.db, req.Txid, lo.ToPtr(int32(req.Vout)))
	if err != nil {
		err = fmt.Errorf("get by tip: %w", err)
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	if denial != nil {
		if denial.CancelledAt == nil && (denial.NextExecution != nil || denial.PausedAt != nil) {
			return nil, connect.Errorf(connect.CodeAlreadyExists,
				"denial %d already runs for %s:%d", denial.ID, req.Txid, req.Vout)
		}

		zerolog.Ctx(ctx).Info().
			Int64("denial_id", denial.ID).
			Str("txid", req.Txid).
			Uint32("vout", req.Vout).
			Int32("delay_seconds", req.DelaySeconds).
			Int32("num_hops", req.NumHops).
			Msg("CreateDenial: continue a stopped denial")

		targetSizes := make(deniability.TargetSizes, denial.NumHops, int(denial.NumHops)+len(req.TargetUtxoSizes))
		copy(targetSizes, denial.TargetUTXOSizes)
		targetSizes = append(targetSizes, req.TargetUtxoSizes...)
		if err := deniability.Update(
			ctx, s.db, denial.ID, time.Duration(req.DelaySeconds)*time.Second, req.NumHops,
			targetSizes, req.Txid, int32(req.Vout),
		); err != nil {
			return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
		}

		return &emptypb.Empty{}, nil
	}

	zerolog.Ctx(ctx).Info().
		Str("txid", req.Txid).
		Uint32("vout", req.Vout).
		Int32("delay_seconds", req.DelaySeconds).
		Int32("num_hops", req.NumHops).
		Str("wallet_id", activeWallet.ID).
		Ints64("target_utxo_sizes", req.TargetUtxoSizes).
		Msg("CreateDenial: creating new denial")

	// UTXO exists, create the denial with the wallet ID
	_, err = deniability.Create(
		ctx,
		s.db,
		activeWallet.ID,
		req.Txid,
		int32(req.Vout),
		time.Duration(req.DelaySeconds)*time.Second,
		req.NumHops,
		req.TargetUtxoSizes,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

func (s *Server) CancelDenial(
	ctx context.Context,
	req *pb.CancelDenialRequest,
) (*emptypb.Empty, error) {
	err := deniability.Cancel(ctx, s.db, req.Id, "cancelled by user")
	switch {
	case errors.Is(err, deniability.ErrNotFound):
		return nil, connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

func (s *Server) PauseDenial(
	ctx context.Context,
	req *pb.PauseDenialRequest,
) (*emptypb.Empty, error) {
	err := deniability.Pause(ctx, s.db, req.Id)
	switch {
	case errors.Is(err, deniability.ErrNotFound):
		return nil, connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("pause denial %d: %s", req.Id, err)).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

func (s *Server) ResumeDenial(
	ctx context.Context,
	req *pb.ResumeDenialRequest,
) (*emptypb.Empty, error) {
	err := deniability.Resume(ctx, s.db, req.Id)
	switch {
	case errors.Is(err, deniability.ErrNotFound):
		return nil, connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("resume denial %d: %s", req.Id, err)).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

func (s *Server) CreateAddressBookEntry(ctx context.Context, req *pb.CreateAddressBookEntryRequest) (*pb.CreateAddressBookEntryResponse, error) {
	direction, err := addressbook.DirectionFromProto(req.Direction)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	addr := strings.TrimSpace(req.Address)
	if err := validateAddressBookAddress(addr); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	// A label must map to a single address. Saving the same address again
	// sets its label.
	if err := s.checkLabelFree(ctx, strings.TrimSpace(req.Label), func(entry addressbook.Entry) bool {
		return entry.Address == addr
	}); err != nil {
		return nil, err
	}

	// User-added addresses don't belong to a specific wallet (nil walletID)
	if err := addressbook.Upsert(ctx, s.db, nil, req.Label, addr, direction); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	entry, ok := lo.Find(entries, func(entry addressbook.Entry) bool {
		return entry.Address == addr && entry.Direction == direction
	})
	if !ok {
		err := fmt.Errorf("entry %s/%s missing after save", addr, direction)
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.CreateAddressBookEntryResponse{
		Entry: EntryToProto(&entry),
	}, nil
}

func validateAddressBookAddress(addr string) error {
	kind := addressbook.ClassifyAddress(addr)
	if kind == pb.AddressType_ADDRESS_TYPE_UNKNOWN || kind == pb.AddressType_ADDRESS_TYPE_UNSPECIFIED {
		return fmt.Errorf(
			"invalid address %q: must be (1) a Bitcoin address on any network, "+
				"(2) a Drivechain deposit address s<slot>_<addr>_<checksum>, or "+
				"(3) a BIP47 v3 payment code", addr,
		)
	}
	return nil
}

// checkLabelFree refuses a label that an entry other than self holds.
func (s *Server) checkLabelFree(ctx context.Context, label string, self func(addressbook.Entry) bool) error {
	if label == "" {
		return nil
	}
	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		return connect.NewError(connect.CodeInternal, fmt.Sprintf("list address book entries: %s", err)).WithCause(err)
	}
	if lo.ContainsBy(entries, func(entry addressbook.Entry) bool {
		return !self(entry) && strings.EqualFold(strings.TrimSpace(entry.Label), label)
	}) {
		return connect.Errorf(connect.CodeAlreadyExists, "an address book entry with label %q already exists", label)
	}
	return nil
}

func EntryToProto(entry *addressbook.Entry) *pb.AddressBookEntry {
	walletID := ""
	if entry.WalletID != nil {
		walletID = *entry.WalletID
	}
	return &pb.AddressBookEntry{
		Id:         entry.ID,
		Label:      entry.Label,
		Address:    entry.Address,
		Direction:  addressbook.DirectionToProto(entry.Direction),
		CreateTime: timestamppb.New(entry.CreatedAt),
		WalletId:   walletID,
		Type:       addressbook.ClassifyAddress(entry.Address),
	}
}

func (s *Server) ListAddressBook(ctx context.Context, req *emptypb.Empty) (*pb.ListAddressBookResponse, error) {
	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	var pbEntries []*pb.AddressBookEntry
	for i := range entries {
		pbEntries = append(pbEntries, EntryToProto(&entries[i]))
	}

	return &pb.ListAddressBookResponse{
		Entries: pbEntries,
	}, nil
}

func (s *Server) UpdateAddressBookEntry(ctx context.Context, req *pb.UpdateAddressBookEntryRequest) (*emptypb.Empty, error) {
	if err := s.checkLabelFree(ctx, strings.TrimSpace(req.Label), func(entry addressbook.Entry) bool {
		return entry.ID == req.Id
	}); err != nil {
		return nil, err
	}

	err := addressbook.UpdateLabel(ctx, s.db, req.Id, req.Label)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, connect.NewError(connect.CodeNotFound, "address book entry not found")
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

func (s *Server) DeleteAddressBookEntry(ctx context.Context, req *pb.DeleteAddressBookEntryRequest) (*emptypb.Empty, error) {
	err := addressbook.Delete(ctx, s.db, req.Id)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, connect.NewError(connect.CodeNotFound, "address book entry not found")
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

// GetSyncInfo implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) GetSyncInfo(ctx context.Context, req *emptypb.Empty) (*pb.GetSyncInfoResponse, error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	tip, err := bitcoind.GetBlockchainInfo(ctx, connectv1.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		// Bitcoin Core returns -28 from every RPC while it's still loading the
		// block index, verifying blocks, or rescanning the wallet. Treat that
		// as "still booting" and surface the message so the UI can render
		// "Verifying blocks…" instead of a misleading "0 / 0 blocks" state.
		if msg := engines.ExtractBitcoindStartupMessage(err.Error()); msg != "" {
			return &pb.GetSyncInfoResponse{
				StartupMessage: msg,
			}, nil
		}
		return nil, err
	}

	processedTip, err := blocks.GetProcessedTip(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("get processed tip")
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	waitsForCore := engines.WaitsForCore(tip.Msg.InitialBlockDownload, s.config.BitcoinCoreNetwork)

	if processedTip == nil {
		return &pb.GetSyncInfoResponse{
			TipBlockHeight:      0,
			TipBlockTime:        0,
			TipBlockHash:        "",
			TipBlockProcessedAt: &timestamppb.Timestamp{},
			HeaderHeight:        int64(tip.Msg.Headers),
			SyncProgress:        0,
			WaitsForCore:        waitsForCore,
		}, nil
	}

	var syncProgress float64
	if tip.Msg.Blocks > 0 {
		syncProgress = float64(processedTip.Height) / float64(tip.Msg.Blocks)
	}

	return &pb.GetSyncInfoResponse{
		TipBlockHeight:      int64(processedTip.Height),
		TipBlockTime:        processedTip.ProcessedAt.Unix(),
		TipBlockHash:        processedTip.Hash.String(),
		TipBlockProcessedAt: timestamppb.New(processedTip.ProcessedAt),
		SyncProgress:        syncProgress,
		HeaderHeight:        int64(tip.Msg.Headers),
		WaitsForCore:        waitsForCore,
	}, nil
}

// SetTransactionNote implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) SetTransactionNote(ctx context.Context, req *pb.SetTransactionNoteRequest) (*emptypb.Empty, error) {
	walletID := req.WalletId
	if walletID == "" {
		activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Sprintf("get active wallet: %s", err)).WithCause(err)
		}
		walletID = activeWallet.ID
	}

	err := transactions.SetNote(ctx, s.db, walletID, req.Txid, req.Note)
	switch {
	case errors.Is(err, transactions.ErrEmptyTxID):
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	case err != nil:
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &emptypb.Empty{}, nil
}

// ExportLabels implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) ExportLabels(ctx context.Context, req *emptypb.Empty) (*pb.ExportLabelsResponse, error) {
	addrs, err := addressbook.List(ctx, s.db)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	// BIP329 has no wallet field: a label file describes one wallet. Export the
	// active wallet's notes, which is what importing one back in expects.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Sprintf("get active wallet: %s", err)).WithCause(err)
	}

	notes, err := transactions.ListByWallet(ctx, s.db, activeWallet.ID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	utxos, err := utxometadata.Get(ctx, s.db, nil)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
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
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.ExportLabelsResponse{Jsonl: jsonl}, nil
}

// ImportLabels implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) ImportLabels(ctx context.Context, req *pb.ImportLabelsRequest) (*pb.ImportLabelsResponse, error) {
	labels, skipped, err := bip329.Decode(req.Jsonl)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	// A BIP329 file describes one wallet, so its notes belong to the active one.
	activeWallet, err := s.walletEngine.GetActiveWallet(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Sprintf("get active wallet: %s", err)).WithCause(err)
	}

	resp := &pb.ImportLabelsResponse{Skipped: int64(skipped)}

	book, err := addressbook.List(ctx, s.db)
	if err != nil {
		return nil, fmt.Errorf("list address book entries: %w", err)
	}
	byAddress := lo.GroupBy(book, func(e addressbook.Entry) string { return e.Address })

	for _, l := range labels {
		ref := strings.TrimSpace(l.Ref)
		label := strings.TrimSpace(l.Label)
		if ref == "" || label == "" {
			resp.Skipped++
			continue
		}

		switch l.Type {
		case bip329.TypeAddr:
			if err := validateAddressBookAddress(ref); err != nil {
				zerolog.Ctx(ctx).Warn().Err(err).Str("ref", ref).Msg("import labels: skip address")
				resp.Skipped++
				continue
			}
			err := s.checkLabelFree(ctx, label, func(e addressbook.Entry) bool { return e.Address == ref })
			if connect.CodeOf(err) == connect.CodeAlreadyExists {
				zerolog.Ctx(ctx).Warn().Err(err).Str("ref", ref).Msg("import labels: skip address")
				resp.Skipped++
				continue
			}
			if err != nil {
				return nil, err
			}
			// An address already in the book keeps its direction.
			if existing := byAddress[ref]; len(existing) > 0 {
				for _, e := range existing {
					if err := addressbook.UpdateLabel(ctx, s.db, e.ID, label); err != nil {
						return nil, fmt.Errorf("import address label %s: %w", ref, err)
					}
				}
			} else if err := addressbook.Upsert(ctx, s.db, nil, label, ref, addressbook.DirectionReceive); err != nil {
				return nil, fmt.Errorf("import address label %s: %w", ref, err)
			}
			resp.ImportedAddresses++

		case bip329.TypeTx:
			if err := transactions.SetNote(ctx, s.db, activeWallet.ID, ref, label); err != nil {
				return nil, fmt.Errorf("import transaction note %s: %w", ref, err)
			}
			resp.ImportedTransactions++

		case bip329.TypeOutput:
			if err := utxometadata.Set(ctx, s.db, ref, nil, &label); err != nil {
				return nil, fmt.Errorf("import utxo label %s: %w", ref, err)
			}
			resp.ImportedOutputs++

		default:
			resp.Skipped++
		}
	}

	return resp, nil
}

// GetFireplaceStats implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) GetFireplaceStats(ctx context.Context, req *emptypb.Empty) (*pb.GetFireplaceStatsResponse, error) {
	// Calculate block count in last 24 hours
	blockCount24h, err := blocks.CountSince(ctx, s.db, time.Now().Add(-24*time.Hour))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get block count: %s", err)).WithCause(err)
	}

	// Calculate transaction count in last 24 hours
	txCount24h, err := blocks.TxCountSince(ctx, s.db, time.Now().Add(-24*time.Hour))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get transaction count: %s", err)).WithCause(err)
	}

	// Calculate coinnews count in last 7 days
	coinnewsCount7d, err := cnstore.CountStoriesSince(ctx, s.db, time.Now().Add(-7*24*time.Hour))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get coinnews count: %s", err)).WithCause(err)
	}

	return &pb.GetFireplaceStatsResponse{
		TransactionCount_24H: txCount24h,
		CoinnewsCount_7D:     coinnewsCount7d,
		BlockCount_24H:       blockCount24h,
	}, nil
}

func (s *Server) ListBlocks(ctx context.Context, c *pb.ListBlocksRequest) (*pb.ListBlocksResponse, error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitcoind: %w", err)
	}

	info, err := bitcoind.GetBlockchainInfo(ctx, connectv1.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: get blockchain info: %w", err)
	}
	if info.Msg.InitialBlockDownload && config.IsFullChainNetwork(s.config.BitcoinCoreNetwork) {
		return &pb.ListBlocksResponse{}, nil
	}
	currentTip := info.Msg.Blocks
	currentHash := info.Msg.BestBlockHash

	// Default to most recent blocks if no pagination
	startHeight := currentTip
	if c.StartHeight > 0 {
		startHeight = c.StartHeight
	}

	// Default page size
	pageSize := uint32(50)
	if c.PageSize > 0 {
		pageSize = c.PageSize
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
			return &pb.ListBlocksResponse{
				RecentBlocks: out,
				HasMore:      entry.hasMore,
			}, nil
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
			hash, err := bitcoind.GetBlockHash(ctx, connectv1.NewRequest(&corepb.GetBlockHashRequest{
				Height: uint32(height),
			}))
			switch {
			// A reorg between the tip read and this call drops the height off
			// the chain. Skip it, the next poll reads the shorter tip.
			case err != nil && strings.Contains(err.Error(), "Block height out of range"):
				return nil, nil

			case err != nil:
				return nil, fmt.Errorf("bitcoind: get block hash %d: %w", height, err)
			}

			block, err := bitcoind.GetBlock(ctx, connectv1.NewRequest(&corepb.GetBlockRequest{
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				Hash:      hash.Msg.Hash,
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: get block %s: %w", hash.Msg.Hash, err)
			}

			return &pb.Block{
				BlockTime:         block.Msg.Time,
				Height:            block.Msg.Height,
				Hash:              block.Msg.Hash,
				Confirmations:     block.Msg.Confirmations,
				Version:           block.Msg.Version,
				VersionHex:        block.Msg.VersionHex,
				MerkleRoot:        block.Msg.MerkleRoot,
				Nonce:             block.Msg.Nonce,
				Bits:              block.Msg.Bits,
				Difficulty:        block.Msg.Difficulty,
				PreviousBlockHash: block.Msg.PreviousBlockHash,
				NextBlockHash:     block.Msg.NextBlockHash,
				StrippedSize:      block.Msg.StrippedSize,
				Size:              block.Msg.Size,
				Weight:            block.Msg.Weight,
				Txids:             block.Msg.Txids,
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
	if err := s.attributeBlocks(ctx, blocks); err != nil {
		return nil, err
	}

	hasMore := len(blocks) > 0 && blocks[len(blocks)-1].Height > 0
	s.listBlocksCache.Store(cacheKey, &listBlocksCacheEntry{
		blocks:  blocks,
		hasMore: hasMore,
		tip:     currentValidity,
	})

	out := make([]*pb.Block, len(blocks))
	copy(out, blocks)
	return &pb.ListBlocksResponse{
		RecentBlocks: out,
		HasMore:      hasMore,
	}, nil
}

func (s *Server) ListRecentTransactions(ctx context.Context, c *pb.ListRecentTransactionsRequest) (*pb.ListRecentTransactionsResponse, error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitcoind: %w", err)
	}

	// First get mempool transactions
	mempoolRes, err := bitcoind.GetRawMempool(ctx, connectv1.NewRequest(&corepb.GetRawMempoolRequest{
		Verbose: true,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: get mempool: %w", err)
	}

	var transactions []*pb.RecentTransaction

	// Add mempool transactions
	for txid, tx := range mempoolRes.Msg.Transactions {
		fee, err := btcutil.NewAmount(tx.Fees.Base)
		if err != nil {
			return nil, fmt.Errorf("parse fee: %w", err)
		}

		transactions = append(transactions, &pb.RecentTransaction{
			VirtualSize:      tx.VirtualSize,
			Time:             tx.Time,
			Txid:             txid,
			FeeSats:          uint64(fee),
			ConfirmedInBlock: nil,
		})
	}
	info, err := bitcoind.GetBlockchainInfo(ctx, connectv1.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: get blockchain info: %w", err)
	}

	// While Core is in IBD on a populated chain (mainnet / eCash), the
	// historical block walk below is the single biggest source of cs_main
	// pressure on this whole codebase: it issues a per-tx
	// GetRawTransaction for every tx in up to 100 recent blocks. During
	// IBD that storms Core badly enough to push getblockchaininfo past
	// its client timeout. The user has nothing useful to look at in that
	// window anyway — return mempool only and bail.
	if info.Msg.InitialBlockDownload && config.IsFullChainNetwork(s.config.BitcoinCoreNetwork) {
		return &pb.ListRecentTransactionsResponse{
			Transactions: transactions,
		}, nil
	}

	// Resolve the requested count up front so the block walk can stop as
	// soon as we have enough.
	count := int64(100)
	if c.Count > 0 {
		count = c.Count
	}

	// Get block at latest height
	blockHashRes, err := bitcoind.GetBlock(ctx, connectv1.NewRequest(&corepb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: get block at height %d: %w", info.Msg.Blocks, err)
	}

	// Walk recent blocks, fetching per-tx fee info, until we have `count`
	// non-coinbase transactions. Cap the walk at maxBlocks so an empty
	// signet/regtest chain doesn't run away.
	const maxBlocks = 100
	currentHash := blockHashRes.Msg.Hash
walkBlocks:
	for i := 0; i < maxBlocks && currentHash != ""; i++ {
		blockRes, err := bitcoind.GetBlock(ctx, connectv1.NewRequest(&corepb.GetBlockRequest{
			Hash:      currentHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO,
		}))
		if err != nil {
			return nil, fmt.Errorf("bitcoind: get block: %w", err)
		}
		for idx, txid := range blockRes.Msg.Txids {
			// Skip coinbase before we pay for GetRawTransaction.
			if idx == 0 {
				continue
			}

			txRes, err := bitcoind.GetRawTransaction(ctx, connectv1.NewRequest(&corepb.GetRawTransactionRequest{
				Txid:      txid,
				Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: get transaction %s: %w", txid, err)
			}

			fee, err := btcutil.NewAmount(txRes.Msg.Fee)
			if err != nil {
				return nil, err
			}

			transactions = append(transactions, &pb.RecentTransaction{
				VirtualSize:      uint32(txRes.Msg.Vsize),
				Time:             blockRes.Msg.Time,
				Txid:             txid,
				FeeSats:          uint64(fee),
				ConfirmedInBlock: &blockRes.Msg.Height,
			})

			if int64(len(transactions)) >= count {
				break walkBlocks
			}
		}

		currentHash = blockRes.Msg.PreviousBlockHash
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

	return &pb.ListRecentTransactionsResponse{
		Transactions: transactions,
	}, nil
}

func (s *Server) GetNetworkStats(ctx context.Context, req *emptypb.Empty) (*pb.GetNetworkStatsResponse, error) {
	// Light mode runs no local Bitcoin Core. Answer before the dial, so the
	// caller gets one clear reason instead of a connection error each tick.
	if !s.walletEngine.NodeMode().RunsLocalNode(ctx) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"network stats need full mode, which runs a local Bitcoin node")
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitcoind: %w", err)
	}

	// Fetch blockchain info
	blockchainInfo, err := bitcoind.GetBlockchainInfo(ctx, connectv1.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get blockchain info: %w", err)
	}

	// Calculate average block time from last 144 blocks
	avgBlockTime, err := s.calculateAverageBlockTime(ctx, int64(blockchainInfo.Msg.Blocks))
	if err != nil {
		return nil, fmt.Errorf("calculate average block time: %w", err)
	}

	// Get difficulty from latest block
	difficulty := 0.0
	if blockchainInfo.Msg.Blocks > 0 {
		hash, err := bitcoind.GetBlockHash(ctx, connectv1.NewRequest(&corepb.GetBlockHashRequest{
			Height: blockchainInfo.Msg.Blocks,
		}))
		if err != nil {
			return nil, fmt.Errorf("get latest block hash: %w", err)
		}
		block, err := bitcoind.GetBlock(ctx, connectv1.NewRequest(&corepb.GetBlockRequest{
			Hash:      hash.Msg.Hash,
			Verbosity: 1,
		}))
		if err != nil {
			return nil, fmt.Errorf("get latest block: %w", err)
		}
		difficulty = block.Msg.Difficulty
	}

	networkInfo, err := bitcoind.GetNetworkInfo(ctx, connectv1.NewRequest(&corepb.GetNetworkInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get network info: %w", err)
	}

	netTotals, err := bitcoind.GetNetTotals(ctx, connectv1.NewRequest(&corepb.GetNetTotalsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get net totals: %w", err)
	}

	// Get peer info
	peerInfo, err := bitcoind.GetPeerInfo(ctx, connectv1.NewRequest(&corepb.GetPeerInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get peer info: %w", err)
	}

	// Count connections by direction
	connectionsIn := int32(0)
	connectionsOut := int32(0)
	for _, peer := range peerInfo.Msg.Peers {
		if peer.Inbound {
			connectionsIn++
		} else {
			connectionsOut++
		}
	}

	bitcoindBandwidth, err := s.processBandwidth(ctx, "bitcoind")
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	enforcerBandwidth, err := s.processBandwidth(ctx, "bip300301-enforcer")
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.GetNetworkStatsResponse{
		NetworkHashrate:    0, // Requires getmininginfo (mining-specific)
		Difficulty:         difficulty,
		PeerCount:          int32(len(peerInfo.Msg.Peers)),
		TotalBytesReceived: netTotals.Msg.TotalBytesRecv,
		TotalBytesSent:     netTotals.Msg.TotalBytesSent,
		BlockHeight:        int64(blockchainInfo.Msg.Blocks),
		AvgBlockTime:       avgBlockTime,
		NetworkVersion:     networkInfo.Msg.Version,
		Subversion:         networkInfo.Msg.Subversion,
		ConnectionsIn:      connectionsIn,
		ConnectionsOut:     connectionsOut,
		BitcoindBandwidth:  bitcoindBandwidth,
		EnforcerBandwidth:  enforcerBandwidth,
	}, nil
}

// processBandwidth gives nil when no process has the name.
func (s *Server) processBandwidth(ctx context.Context, name string) (*pb.ProcessBandwidth, error) {
	// Windows has no pgrep.
	if runtime.GOOS == "windows" {
		return nil, nil
	}
	output, err := exec.CommandContext(ctx, "pgrep", "-x", name).Output()
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) && exitErr.ExitCode() == 1 {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("pgrep %s: %w", name, err)
	}

	// pgrep may return multiple PIDs, take the first one
	first, _, _ := strings.Cut(strings.TrimSpace(string(output)), "\n")
	pid, err := strconv.Atoi(first)
	if err != nil {
		return nil, fmt.Errorf("parse pid of %s: %w", name, err)
	}

	stats, err := s.bandwidthTracker.GetStats(pid, name)
	if err != nil {
		return nil, fmt.Errorf("bandwidth of %s: %w", name, err)
	}
	return &pb.ProcessBandwidth{
		ProcessName:     stats.ProcessName,
		Pid:             int32(stats.PID),
		RxBytesPerSec:   stats.RxBytesPerSec,
		TxBytesPerSec:   stats.TxBytesPerSec,
		TotalRxBytes:    stats.TotalRxBytes,
		TotalTxBytes:    stats.TotalTxBytes,
		ConnectionCount: stats.ConnectionCount,
	}, nil
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
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return 0, fmt.Errorf("bitcoind: %w", err)
	}

	hash, err := bitcoind.GetBlockHash(ctx, connectv1.NewRequest(&corepb.GetBlockHashRequest{
		Height: uint32(height),
	}))
	if err != nil {
		return 0, fmt.Errorf("get block hash: %w", err)
	}

	block, err := bitcoind.GetBlock(ctx, connectv1.NewRequest(&corepb.GetBlockRequest{
		Hash:      hash.Msg.Hash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return 0, fmt.Errorf("get block: %w", err)
	}

	if block.Msg.Time == nil {
		return 0, fmt.Errorf("block time is nil for height %d", height)
	}

	return block.Msg.Time.Seconds, nil
}

func (s *Server) checkElectrumUTXO(ctx context.Context, walletID string, txid string, vout uint32) (bool, error) {
	utxos, err := s.walletEngine.GetElectrumUnspent(ctx, walletID)
	if err != nil {
		return false, fmt.Errorf("list electrum utxos: %w", err)
	}

	return lo.ContainsBy(utxos, func(utxo *wmpb.UnspentOutput) bool {
		return utxo.Txid == txid && uint32(utxo.Vout) == vout
	}), nil
}

// checkBitcoinCoreUTXO checks if a UTXO exists in a Bitcoin Core wallet
func (s *Server) checkBitcoinCoreUTXO(ctx context.Context, walletID string, txid string, vout uint32) (bool, error) {
	walletName, err := s.walletEngine.EnsureBitcoinCoreWallet(ctx, walletID)
	if err != nil {
		return false, fmt.Errorf("get wallet name: %w", err)
	}

	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return false, fmt.Errorf("bitcoind: %w", err)
	}

	utxos, err := bitcoind.ListUnspent(ctx, connectv1.NewRequest(&corepb.ListUnspentRequest{
		Wallet: walletName,
	}))
	if err != nil {
		return false, fmt.Errorf("list bitcoin core utxos: %w", err)
	}

	return lo.ContainsBy(utxos.Msg.Unspent, func(utxo *corepb.UnspentOutput) bool {
		return utxo.Txid == txid && utxo.Vout == vout
	}), nil
}
func (s *Server) SetMempoolWatch(ctx context.Context, req *pb.SetMempoolWatchRequest) (*emptypb.Empty, error) {
	if req.Enabled {
		if err := s.walletEngine.NodeMode().RequireFullNode(ctx, "mempool watch"); err != nil {
			return nil, err
		}
	}
	if err := s.mempoolWatcher.SetEnabled(ctx, req.Enabled); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *Server) ResetMempoolWatch(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	if err := s.mempoolWatcher.Reset(ctx); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *Server) GetMempoolWatchStatus(ctx context.Context, _ *emptypb.Empty) (*pb.GetMempoolWatchStatusResponse, error) {
	status := s.mempoolWatcher.Status()
	count, err := mempooltx.Count(ctx, s.db)
	if err != nil {
		return nil, err
	}
	return &pb.GetMempoolWatchStatusResponse{
		Enabled:      status.Enabled,
		Running:      status.Running,
		Error:        status.Error,
		TipHeight:    status.Tip,
		PendingCount: count,
	}, nil
}

func (s *Server) ListMempoolTransactions(ctx context.Context, req *pb.ListMempoolTransactionsRequest) (*pb.ListMempoolTransactionsResponse, error) {
	filter := mempooltx.Filter{
		TxidPrefix: strings.ToLower(strings.TrimSpace(req.Txid)),
		Limit:      int(req.Limit),
		Offset:     int(req.Offset),
	}
	if filter.Limit == 0 {
		filter.Limit = 200
	}
	txs, total, err := mempooltx.List(ctx, s.db, filter)
	if err != nil {
		return nil, err
	}

	out := make([]*pb.MempoolTransaction, len(txs))
	for i, tx := range txs {
		out[i] = &pb.MempoolTransaction{
			Txid:            tx.Txid,
			FeeSats:         tx.FeeSats,
			Vsize:           tx.Vsize,
			FeeRate:         tx.FeeRate,
			FirstSeen:       timestamppb.New(tx.FirstSeenAt),
			FirstSeenHeight: tx.FirstSeenHeight,
		}
	}
	return &pb.ListMempoolTransactionsResponse{Transactions: out, Total: total}, nil
}

func (s *Server) ListBlockStats(ctx context.Context, req *pb.ListBlockStatsRequest) (*pb.ListBlockStatsResponse, error) {
	blocks, err := mempooltx.ListBlockStats(ctx, s.db, req.FromHeight, req.ToHeight)
	if err != nil {
		return nil, err
	}
	out := make([]*pb.BlockStats, len(blocks))
	for i, b := range blocks {
		out[i] = &pb.BlockStats{Height: b.Height, MinFeeRate: b.MinFeeRate, TotalFeeSats: b.TotalFeeSats}
	}
	return &pb.ListBlockStatsResponse{Blocks: out}, nil
}

var miningPoolWindows = map[pb.MiningPoolWindow]time.Duration{
	pb.MiningPoolWindow_MINING_POOL_WINDOW_24H: 24 * time.Hour,
	pb.MiningPoolWindow_MINING_POOL_WINDOW_3D:  3 * 24 * time.Hour,
	pb.MiningPoolWindow_MINING_POOL_WINDOW_1W:  7 * 24 * time.Hour,
}

func (s *Server) ListMiningPools(ctx context.Context, req *pb.ListMiningPoolsRequest) (*pb.ListMiningPoolsResponse, error) {
	window, ok := miningPoolWindows[req.Window]
	if !ok {
		window = miningPoolWindows[pb.MiningPoolWindow_MINING_POOL_WINDOW_24H]
	}
	rows, err := coinbases.ListSince(ctx, s.db, time.Now().Add(-window))
	if err != nil {
		return nil, fmt.Errorf("list coinbases: %w", err)
	}
	registry := s.pools.Pools()
	summary := miningpools.Summarize(rows, registry.Pools)
	shares := make([]*pb.MiningPoolShare, len(summary.Shares))
	for i, share := range summary.Shares {
		shares[i] = &pb.MiningPoolShare{
			Pool:              miningPoolProto(share.Pool),
			BlockCount:        share.Blocks,
			EmptyBlocks:       share.Empty,
			Share:             share.Share,
			EstimatedHashrate: share.Hashrate,
		}
	}
	return &pb.ListMiningPoolsResponse{
		Pools:             shares,
		BlockCount:        summary.Blocks,
		FromHeight:        summary.FromHeight,
		ToHeight:          summary.ToHeight,
		NetworkHashrate:   summary.NetworkHashrate,
		RegistryAvailable: registry.Available,
		RegistrySource:    registry.Source,
	}, nil
}

// attributeBlocks fills the pool of every block whose coinbase was recorded.
// Blocks arrive sorted by height, descending.
func (s *Server) attributeBlocks(ctx context.Context, blocks []*pb.Block) error {
	if len(blocks) == 0 {
		return nil
	}
	rows, err := coinbases.ListRange(ctx, s.db, blocks[len(blocks)-1].Height, blocks[0].Height)
	if err != nil {
		return fmt.Errorf("list coinbases: %w", err)
	}
	byHeight := make(map[uint32]coinbases.Coinbase, len(rows))
	for _, row := range rows {
		byHeight[row.Height] = row
	}
	registry := s.pools.Pools()
	for _, block := range blocks {
		if row, ok := byHeight[block.Height]; ok && row.Hash == block.Hash {
			block.Pool = miningPoolProto(miningpools.Match(row.Script, row.Addresses, registry.Pools))
		}
	}
	return nil
}

func miningPoolProto(p miningpools.Pool) *pb.MiningPool {
	return &pb.MiningPool{
		Name:       p.Name,
		Slug:       p.Slug,
		Link:       p.Link,
		Operator:   p.Operator,
		Mode:       p.Mode,
		FeeBps:     uint32(p.FeeBps),
		StratumUrl: p.StratumURL,
		Payout:     p.Payout,
	}
}
