package api_bitwindowd

import (
	"cmp"
	"context"
	"database/sql"
	"fmt"
	"os/exec"
	"slices"
	"strconv"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/cpuminer"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/utils/bandwidth"
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

// New creates a new Server
func New(
	onShutdown func(ctx context.Context),
	db *sql.DB,
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	walletEngine *engines.WalletEngine,
	config config.Config,
) *Server {
	s := &Server{
		onShutdown:       onShutdown,
		db:               db,
		validator:        validator,
		wallet:           wallet,
		bitcoind:         bitcoind,
		walletEngine:     walletEngine,
		bandwidthTracker: bandwidth.NewTracker(),

		config: config,
	}
	return s
}

type Server struct {
	onShutdown       func(ctx context.Context)
	db               *sql.DB
	validator        *service.Service[validatorrpc.ValidatorServiceClient]
	wallet           *service.Service[validatorrpc.WalletServiceClient]
	bitcoind         *service.Service[corerpc.BitcoinServiceClient]
	walletEngine     *engines.WalletEngine
	bandwidthTracker *bandwidth.Tracker

	config config.Config
}

// Stop implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) Stop(ctx context.Context, req *connect.Request[pb.BitwindowdServiceStopRequest]) (*connect.Response[emptypb.Empty], error) {
	defer func() {
		zerolog.Ctx(ctx).Info().Msg("shutting down..")
		s.onShutdown(ctx)
	}()

	if req.Msg.SkipDownstream {
		zerolog.Ctx(ctx).Info().Msg("skip_downstream=true, not stopping enforcer or bitcoind")
		return connect.NewResponse(&emptypb.Empty{}), nil
	}

	if s.config.GuiBootedMainchain {
		zerolog.Ctx(ctx).Info().Msg("mainchain was booted by GUI, shutting down bitcoind..")
		_, err := s.bitcoind.Get(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		// Note: Stop RPC not available in btc-buf yet
		// bitcoind will be stopped via SIGTERM by the process manager
		zerolog.Ctx(ctx).Info().Msg("bitcoind will be stopped by process manager")
	} else {
		zerolog.Ctx(ctx).Info().Msg("mainchain was not booted by GUI, not shutting down bitcoind..")
	}

	if s.config.GuiBootedEnforcer {
		zerolog.Ctx(ctx).Info().Msg("enforcer was booted by GUI, shutting down bip300301-enforcer..")
		validator, err := s.validator.Get(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		_, err = validator.Stop(ctx, connect.NewRequest(&validatorpb.StopRequest{}))
		if err != nil {
			err = fmt.Errorf("could not stop enforcer: %w", err)
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not stop enforcer")
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		zerolog.Ctx(ctx).Info().Msg("bip300301-enforcer shutdown complete")
	} else {
		zerolog.Ctx(ctx).Info().Msg("enforcer was not booted by GUI, not shutting down bip300301-enforcer..")
	}

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

	// Check if wallet type supports deniability
	if activeWallet.WalletType == engines.WalletTypeWatchOnly {
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
	case engines.WalletTypeWatchOnly:
		err = fmt.Errorf("deniability is not supported for watch-only wallets")
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
	err := deniability.Cancel(ctx, s.db, req.Msg.Id, "cancelled by user")
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
	err := deniability.Pause(ctx, s.db, req.Msg.Id)
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
	err := deniability.Resume(ctx, s.db, req.Msg.Id)
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

	address, err := btcutil.DecodeAddress(req.Msg.Address, s.walletEngine.GetChainParams())
	if err != nil {
		err = fmt.Errorf("invalid address: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid address format")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// User-added addresses don't belong to a specific wallet (nil walletId)
	if err := addressbook.Create(ctx, s.db, nil, req.Msg.Label, address.String(), direction); err != nil {
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
				if entry.Address == req.Msg.Address && entry.Direction == direction {
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
		return entry.Address == req.Msg.Address && entry.Direction == direction
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
	}
}

func (s *Server) ListAddressBook(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListAddressBookResponse], error) {
	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list address book entries")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var pbEntries []*pb.AddressBookEntry
	for _, entry := range entries {
		walletId := ""
		if entry.WalletID != nil {
			walletId = *entry.WalletID
		}
		pbEntries = append(pbEntries, &pb.AddressBookEntry{
			Id:         entry.ID,
			Label:      entry.Label,
			Address:    entry.Address,
			Direction:  addressbook.DirectionToProto(entry.Direction),
			CreateTime: timestamppb.New(entry.CreatedAt),
			WalletId:   walletId,
		})
	}

	return connect.NewResponse(&pb.ListAddressBookResponse{
		Entries: pbEntries,
	}), nil
}

func (s *Server) UpdateAddressBookEntry(ctx context.Context, req *connect.Request[pb.UpdateAddressBookEntryRequest]) (*connect.Response[emptypb.Empty], error) {
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
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	tip, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get blockchain info")
		return nil, connect.NewError(connect.CodeInternal, err)
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
			HeaderHeight:        int64(tip.Msg.Headers),
			SyncProgress:        0,
		}), nil
	}

	return connect.NewResponse(&pb.GetSyncInfoResponse{
		TipBlockHeight:      int64(processedTip.Height),
		TipBlockTime:        processedTip.ProcessedAt.Unix(),
		TipBlockHash:        processedTip.Hash.String(),
		TipBlockProcessedAt: timestamppb.New(processedTip.ProcessedAt),
		SyncProgress:        float64(processedTip.Height) / float64(tip.Msg.Blocks),
		HeaderHeight:        int64(tip.Msg.Headers),
	}), nil
}

// SetTransactionNote implements bitwindowdv1connect.BitwindowdServiceHandler.
func (s *Server) SetTransactionNote(ctx context.Context, req *connect.Request[pb.SetTransactionNoteRequest]) (*connect.Response[emptypb.Empty], error) {
	if err := transactions.SetNote(ctx, s.db, req.Msg.Txid, req.Msg.Note); err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not set transaction note")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
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
		FROM op_returns o
		-- created in the last 7 days
		WHERE o.created_at >= ?
		AND LENGTH(o.op_return_data) >= 16
		-- filter out all all topic creation operations
		-- 6e6577 is hex for "new"
		AND NOT(SUBSTR(o.op_return_data, 9, 6) = '6e6577')
		-- and is a valid coin news entry (topic is 4 bytes = 8 hex chars)
		AND EXISTS (
			SELECT 1 FROM coin_news_topics t
			WHERE t.topic = SUBSTR(o.op_return_data, 1, 8)
		)
	`, cutoffTime).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("query coinnews count: %w", err)
	}

	return count, nil
}

func (s *Server) ListBlocks(ctx context.Context, c *connect.Request[pb.ListBlocksRequest]) (*connect.Response[pb.ListBlocksResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	info, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}

	// Default to most recent blocks if no pagination
	startHeight := info.Msg.Blocks
	if c.Msg.StartHeight > 0 {
		startHeight = c.Msg.StartHeight
	}

	// Default page size
	pageSize := uint32(50)
	if c.Msg.PageSize > 0 {
		pageSize = c.Msg.PageSize
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
			hash, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
				Height: uint32(height),
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get block hash %d: %w", height, err)
			}

			block, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
				Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
				Hash:      hash.Msg.Hash,
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get block %s: %w", hash.Msg.Hash, err)
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

	return connect.NewResponse(&pb.ListBlocksResponse{
		RecentBlocks: blocks,
		HasMore:      startHeight > uint32(len(blocks)),
	}), nil
}

func (s *Server) ListRecentTransactions(ctx context.Context, c *connect.Request[pb.ListRecentTransactionsRequest]) (*connect.Response[pb.ListRecentTransactionsResponse], error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, err
	}

	// First get mempool transactions
	mempoolRes, err := bitcoind.GetRawMempool(ctx, connect.NewRequest(&corepb.GetRawMempoolRequest{
		Verbose: true,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get mempool: %w", err)
	}

	var transactions []*pb.RecentTransaction

	// Add mempool transactions
	for txid, tx := range mempoolRes.Msg.Transactions {
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
	info, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get blockchain info: %w", err)
	}

	// Get block at latest height
	blockHashRes, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
		Hash:      info.Msg.BestBlockHash,
		Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_INFO,
	}))
	if err != nil {
		return nil, fmt.Errorf("bitcoind: could not get block at height %d: %w", info.Msg.Blocks, err)
	}

	// Extract transactions from the 100 most recent blocks
	currentHash := blockHashRes.Msg.Hash
	for i := 0; i < 100 && currentHash != ""; i++ {
		blockRes, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
			Hash:      currentHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO, // Get full transaction details
		}))
		if err != nil {
			return nil, fmt.Errorf("bitcoind: could not get block: %w", err)
		}
		for idx, txid := range blockRes.Msg.Txids {
			// Get full transaction details
			txRes, err := bitcoind.GetRawTransaction(ctx, connect.NewRequest(&corepb.GetRawTransactionRequest{
				Txid:      txid,
				Verbosity: corepb.GetRawTransactionRequest_VERBOSITY_TX_PREVOUT_INFO,
			}))
			if err != nil {
				return nil, fmt.Errorf("bitcoind: could not get transaction %s: %w", txid, err)
			}

			// Coinbase transaction
			if idx == 0 {
				continue
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
		}

		currentHash = blockRes.Msg.PreviousBlockHash
	}

	// Sort by time, newest first
	slices.SortFunc(transactions, func(a, b *pb.RecentTransaction) int {
		return cmp.Compare(b.Time.AsTime().Unix(), a.Time.AsTime().Unix())
	})

	// Limit to requested count
	count := int64(100)
	if c.Msg.Count > 0 {
		count = c.Msg.Count
	}
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

		// Get address from Bitcoin Core wallet
		walletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, activeWallet.ID)
		if err != nil {
			return "", fmt.Errorf("get bitcoin core wallet name: %w", err)
		}
		addr, err := bitcoind.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
			Wallet: walletName,
		}))
		if err != nil {
			return "", err
		}
		return addr.Msg.Address, nil

	case engines.WalletTypeWatchOnly:
		// Get address from watch-only wallet
		walletName, err := s.walletEngine.EnsureWatchOnlyWallet(ctx, activeWallet.ID)
		if err != nil {
			return "", fmt.Errorf("ensure watch-only wallet: %w", err)
		}
		addr, err := bitcoind.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
			Wallet: walletName,
		}))
		if err != nil {
			return "", err
		}
		return addr.Msg.Address, nil

	default:
		return "", fmt.Errorf("unsupported wallet type: %s", walletType)
	}
}

func (s *Server) MineBlocks(ctx context.Context, req *connect.Request[emptypb.Empty], stream *connect.ServerStream[pb.MineBlocksResponse]) error {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return err
	}

	// Verify we're actually able to connect to Bitcoin Core
	info, err := bitcoind.GetBlockchainInfo(
		ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}),
	)
	if err != nil {
		return err
	}

	switch info.Msg.Chain {
	case "regtest", "testnet3", "testnet4", "forknet":
	default:
		return connect.NewError(
			connect.CodeFailedPrecondition,
			fmt.Errorf(
				"generating blocks on %s is not supported",
				cmp.Or(info.Msg.Chain, "unknown network"),
			),
		)
	}

	// Get a payout address from the active wallet for mining rewards
	address, err := s.getCoinbaseAddress(ctx)
	if err != nil {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("get mining address: %w", err))
	}

	miner, err := cpuminer.New(cpuminer.Config{
		RpcURL:          s.config.BitcoinCoreURL,
		RpcUser:         s.config.BitcoinCoreRpcUser,
		RpcPass:         s.config.BitcoinCoreRpcPassword,
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
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("get bitcoind client: %w", err))
	}

	// Fetch blockchain info
	blockchainInfo, err := bitcoind.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get blockchain info: %w", err))
	}

	// Calculate average block time from last 144 blocks
	avgBlockTime, err := s.calculateAverageBlockTime(ctx, bitcoind, int64(blockchainInfo.Msg.Blocks))
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("calculate average block time")
		avgBlockTime = 600.0 // Default to 10 minutes
	}

	// Get difficulty from latest block
	difficulty := 0.0
	if blockchainInfo.Msg.Blocks > 0 {
		hash, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
			Height: blockchainInfo.Msg.Blocks,
		}))
		if err != nil {
			zerolog.Ctx(ctx).Warn().Err(err).Msg("get latest block hash for difficulty")
		} else {
			block, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
				Hash:      hash.Msg.Hash,
				Verbosity: 1,
			}))
			if err != nil {
				zerolog.Ctx(ctx).Warn().Err(err).Msg("get latest block for difficulty")
			} else {
				difficulty = block.Msg.Difficulty
			}
		}
	}

	// Get network info for version and subversion
	networkInfo, err := bitcoind.GetNetworkInfo(ctx, connect.NewRequest(&corepb.GetNetworkInfoRequest{}))
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("get network info")
	}

	// Get net totals for bandwidth statistics
	netTotals, err := bitcoind.GetNetTotals(ctx, connect.NewRequest(&corepb.GetNetTotalsRequest{}))
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("get net totals")
	}

	// Get peer info
	peerInfo, err := bitcoind.GetPeerInfo(ctx, connect.NewRequest(&corepb.GetPeerInfoRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get peer info: %w", err))
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

	// Extract network info fields
	networkVersion := int32(0)
	subversion := ""
	if networkInfo != nil {
		networkVersion = networkInfo.Msg.Version
		subversion = networkInfo.Msg.Subversion
	}

	// Extract bandwidth statistics
	totalBytesReceived := uint64(0)
	totalBytesSent := uint64(0)
	if netTotals != nil {
		totalBytesReceived = netTotals.Msg.TotalBytesRecv
		totalBytesSent = netTotals.Msg.TotalBytesSent
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
		PeerCount:          int32(len(peerInfo.Msg.Peers)),
		TotalBytesReceived: totalBytesReceived,
		TotalBytesSent:     totalBytesSent,
		BlockHeight:        int64(blockchainInfo.Msg.Blocks),
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

func (s *Server) calculateAverageBlockTime(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, currentHeight int64) (float64, error) {
	// Get blocks from last 144 blocks or from genesis if we don't have that many
	lookback := min(int64(144), currentHeight)
	if lookback <= 1 {
		return 600.0, nil // Default to 10 minutes if not enough blocks
	}

	// Get the first block in range
	firstHeight := currentHeight - lookback
	firstBlock, err := s.getBlockAtHeight(ctx, bitcoind, firstHeight)
	if err != nil {
		return 0, fmt.Errorf("get first block: %w", err)
	}

	// Get the last block (current tip)
	lastBlock, err := s.getBlockAtHeight(ctx, bitcoind, currentHeight)
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

func (s *Server) getBlockAtHeight(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, height int64) (int64, error) {
	hash, err := bitcoind.GetBlockHash(ctx, connect.NewRequest(&corepb.GetBlockHashRequest{
		Height: uint32(height),
	}))
	if err != nil {
		return 0, fmt.Errorf("get block hash: %w", err)
	}

	block, err := bitcoind.GetBlock(ctx, connect.NewRequest(&corepb.GetBlockRequest{
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

	for _, utxo := range utxos.Msg.Outputs {
		if utxo.Txid.Hex.Value == txid && utxo.Vout == vout {
			return true, nil
		}
	}

	return false, nil
}

// checkBitcoinCoreUTXO checks if a UTXO exists in a Bitcoin Core wallet
func (s *Server) checkBitcoinCoreUTXO(ctx context.Context, walletID string, txid string, vout uint32) (bool, error) {
	bitcoind, err := s.bitcoind.Get(ctx)
	if err != nil {
		return false, fmt.Errorf("get bitcoind: %w", err)
	}

	walletName, err := s.walletEngine.GetBitcoinCoreWalletName(ctx, walletID)
	if err != nil {
		return false, fmt.Errorf("get wallet name: %w", err)
	}

	utxos, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		Wallet: walletName,
	}))
	if err != nil {
		return false, fmt.Errorf("list bitcoin core utxos: %w", err)
	}

	for _, utxo := range utxos.Msg.Unspent {
		if utxo.Txid == txid && utxo.Vout == vout {
			return true, nil
		}
	}

	return false, nil
}
