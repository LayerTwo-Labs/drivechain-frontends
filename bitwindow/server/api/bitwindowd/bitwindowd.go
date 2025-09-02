package api_bitwindowd

import (
	"cmp"
	"context"
	"database/sql"
	"fmt"
	"slices"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/transactions"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
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
	onShutdown func(),
	db *sql.DB,
	validator *service.Service[validatorrpc.ValidatorServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
	guiBootedMainchain bool,
	guiBootedEnforcer bool,
) *Server {
	s := &Server{
		onShutdown: onShutdown,
		db:         db,
		validator:  validator,
		wallet:     wallet,
		bitcoind:   bitcoind,

		guiBootedMainchain: guiBootedMainchain,
		guiBootedEnforcer:  guiBootedEnforcer,
	}
	return s
}

type Server struct {
	onShutdown func()
	db         *sql.DB
	validator  *service.Service[validatorrpc.ValidatorServiceClient]
	wallet     *service.Service[validatorrpc.WalletServiceClient]
	bitcoind   *service.Service[corerpc.BitcoinServiceClient]

	guiBootedMainchain bool
	guiBootedEnforcer  bool
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) Stop(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	defer func() {
		zerolog.Ctx(ctx).Info().Msg("shutting down..")
		s.onShutdown()
	}()

	if s.guiBootedMainchain {
		zerolog.Ctx(ctx).Info().Msg("mainchain was booted by GUI, shutting down bitcoind..")
		_, err := s.bitcoind.Get(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		// TODO: Add stop rpc bitcoind.Stop(ctx, connect.NewRequest(&emptypb.Empty{}))
		zerolog.Ctx(ctx).Info().Msg("bitcoind shutdown complete")
	} else {
		zerolog.Ctx(ctx).Info().Msg("mainchain was not booted by GUI, not shutting down bitcoind..")
	}

	if s.guiBootedEnforcer {
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
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, err
	}

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

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		err = fmt.Errorf("enforcer/wallet: could not list unspent outputs: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list unspent outputs")
		return nil, err
	}

	// Check if UTXO exists
	var utxoExists bool
	for _, utxo := range utxos.Msg.Outputs {
		if utxo.Txid.Hex.Value == req.Msg.Txid && utxo.Vout == req.Msg.Vout {
			utxoExists = true
			zerolog.Ctx(ctx).Info().
				Str("txid", utxo.Txid.Hex.Value).
				Uint32("vout", utxo.Vout).
				Uint64("value_sats", utxo.ValueSats).
				Bool("is_internal", utxo.IsInternal).
				Msg("CreateDenial: found matching UTXO")
			break
		}
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
		Msg("CreateDenial: creating new denial")

	// UTXO exists, create the denial
	_, err = deniability.Create(
		ctx,
		s.db,
		req.Msg.Txid,
		int32(req.Msg.Vout),
		time.Duration(req.Msg.DelaySeconds)*time.Second,
		req.Msg.NumHops,
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

func (s *Server) CreateAddressBookEntry(ctx context.Context, req *connect.Request[pb.CreateAddressBookEntryRequest]) (*connect.Response[pb.CreateAddressBookEntryResponse], error) {
	direction, err := addressbook.DirectionFromProto(req.Msg.Direction)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid direction")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	address, err := btcutil.DecodeAddress(req.Msg.Address, nil)
	if err != nil {
		err = fmt.Errorf("invalid address: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("invalid address format")
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if err := addressbook.Create(ctx, s.db, req.Msg.Label, address.String(), direction); err != nil {
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
	return &pb.AddressBookEntry{
		Id:         entry.ID,
		Label:      entry.Label,
		Address:    entry.Address,
		Direction:  addressbook.DirectionToProto(entry.Direction),
		CreateTime: timestamppb.New(entry.CreatedAt),
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
		pbEntries = append(pbEntries, &pb.AddressBookEntry{
			Id:         entry.ID,
			Label:      entry.Label,
			Address:    entry.Address,
			Direction:  addressbook.DirectionToProto(entry.Direction),
			CreateTime: timestamppb.New(entry.CreatedAt),
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
		AND NOT(SUBSTR(o.op_return_data, 17, 6) = '6e6577')
		-- and is a valid coin news entry
		AND EXISTS (
			SELECT 1 FROM coin_news_topics t 
			WHERE t.topic = SUBSTR(o.op_return_data, 1, 16)
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
