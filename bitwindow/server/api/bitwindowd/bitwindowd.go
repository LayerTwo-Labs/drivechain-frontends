package api_bitwindowd

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
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
	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
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
	bitcoind *service.Service[bitcoindv1alphaconnect.BitcoinServiceClient],
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
	bitcoind   *service.Service[bitcoindv1alphaconnect.BitcoinServiceClient]

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
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not get bitcoind client")
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
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not get validator client")
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
) (*connect.Response[pb.CreateDenialResponse], error) {
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get wallet client")
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
		if err := deniability.Update(ctx, s.db, denial.ID, time.Duration(req.Msg.DelaySeconds)*time.Second, req.Msg.NumHops); err != nil {
			zerolog.Ctx(ctx).Error().Err(err).Msg("could not update denial")
			return nil, connect.NewError(connect.CodeInternal, err)
		}

		return connect.NewResponse(&pb.CreateDenialResponse{
			Deniability: func() *pb.DeniabilityInfo {
				deniability, err := s.withDeniability(ctx, *denial)
				if err != nil {
					zerolog.Ctx(ctx).Error().Err(err).Msg("could not get deniability info")
					return nil
				}
				return deniability
			}(),
		}), nil
	}

	zerolog.Ctx(ctx).Info().
		Str("txid", req.Msg.Txid).
		Uint32("vout", req.Msg.Vout).
		Int32("delay_seconds", req.Msg.DelaySeconds).
		Int32("num_hops", req.Msg.NumHops).
		Msg("CreateDenial: creating new denial")

	// UTXO exists, create the denial
	createdDenial, err := deniability.Create(
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

	return connect.NewResponse(&pb.CreateDenialResponse{
		Deniability: func() *pb.DeniabilityInfo {
			deniability, err := s.withDeniability(ctx, createdDenial)
			if err != nil {
				zerolog.Ctx(ctx).Error().Err(err).Msg("could not get deniability info")
				return nil
			}
			return deniability
		}(),
	}), nil
}

func (s *Server) ListDenials(
	ctx context.Context,
	req *connect.Request[emptypb.Empty],
) (*connect.Response[pb.ListDenialsResponse], error) {

	// First get all UTXOs from the wallet
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get wallet client")
		return nil, err
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		err = fmt.Errorf("enforcer/wallet: could not list unspent outputs: %w", err)
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list unspent outputs")
		return nil, err
	}

	deniabilities, err := deniability.List(ctx, s.db)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list deniabilities")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Create map of deniability info by current tip txid/vout
	deniabilityMap := make(map[string]*deniability.Denial)
	for _, d := range deniabilities {
		// key is txid:vout, but if vout is nil, just use txid
		var key string
		if d.TipVout == nil {
			key = d.TipTXID
		} else {
			key = fmt.Sprintf("%s:%d", d.TipTXID, *d.TipVout)
		}
		deniabilityMap[key] = &d
	}

	// Build response with UTXOs and matched deniability info
	var pbUtxos []*pb.DeniabilityUTXO
	var matchedCount int
	var unmatchedCount int

	for _, utxo := range utxos.Msg.Outputs {
		pbUtxo := &pb.DeniabilityUTXO{
			Txid:       utxo.Txid.Hex.Value,
			Vout:       utxo.Vout,
			ValueSats:  utxo.ValueSats,
			IsInternal: utxo.IsInternal,
		}

		key := fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout)

		// Try exact match first
		if d, exists := deniabilityMap[key]; exists {
			// the utxo has deniability info! Add it to the response
			deniability, err := s.withDeniability(ctx, *d)
			if err != nil {
				zerolog.Ctx(ctx).Error().Err(err).Msg("could not get deniability info")
				return nil, connect.NewError(connect.CodeInternal, err)
			}
			pbUtxo.Deniability = deniability
			matchedCount++
		} else {
			// Try matching just on txid
			if d, exists := deniabilityMap[utxo.Txid.Hex.Value]; exists {
				deniability, err := s.withDeniability(ctx, *d)
				if err != nil {
					zerolog.Ctx(ctx).Error().Err(err).Msg("could not get deniability info")
					return nil, connect.NewError(connect.CodeInternal, err)
				}
				pbUtxo.Deniability = deniability
				matchedCount++
			} else {
				unmatchedCount++
			}
		}

		pbUtxos = append(pbUtxos, pbUtxo)
	}

	return connect.NewResponse(&pb.ListDenialsResponse{
		Utxos: pbUtxos,
	}), nil
}

func (s *Server) withDeniability(ctx context.Context, d deniability.Denial) (*pb.DeniabilityInfo, error) {
	nextExecution, err := deniability.NextExecution(ctx, s.db, d)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get next execution")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	executions, err := deniability.ListExecutions(ctx, s.db, d.ID)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not list executions")
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var pbExecutions []*pb.ExecutedDenial
	for _, e := range executions {
		pbExecutions = append(pbExecutions, &pb.ExecutedDenial{
			Id:         e.ID,
			DenialId:   e.DenialID,
			FromTxid:   e.FromTxID,
			FromVout:   uint32(e.FromVout),
			ToTxid:     e.ToTxID,
			CreateTime: timestamppb.New(e.CreatedAt),
		})
	}

	return &pb.DeniabilityInfo{
		Id:           d.ID,
		DelaySeconds: int32(d.DelayDuration.Seconds()),
		NumHops:      d.NumHops,
		CreateTime:   timestamppb.New(d.CreatedAt),
		CancelTime: func() *timestamppb.Timestamp {
			if d.CancelledAt != nil {
				return timestamppb.New(*d.CancelledAt)
			}
			return nil
		}(),
		CancelReason: d.CancelReason,
		NextExecution: func() *timestamppb.Timestamp {
			if nextExecution == nil {
				return nil
			}
			return timestamppb.New(*nextExecution)
		}(),
		Executions:    pbExecutions,
		HopsCompleted: uint32(len(executions)),
		IsActive:      d.CancelledAt == nil && len(executions) < int(d.NumHops),
	}, nil
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
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get bitcoind client")
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
		TipBlockHash:        processedTip.Hash,
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
