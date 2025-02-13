package api_bitwindowd

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitwindowd/v1/bitwindowdv1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/service"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.BitwindowdServiceHandler = new(Server)

// New creates a new Server
func New(
	onShutdown func(),
	db *sql.DB,
	wallet *service.Service[validatorrpc.WalletServiceClient],
) *Server {
	s := &Server{
		onShutdown: onShutdown,
		db:         db,
		wallet:     wallet,
	}
	return s
}

type Server struct {
	onShutdown func()
	db         *sql.DB
	wallet     *service.Service[validatorrpc.WalletServiceClient]
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) Stop(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	defer s.onShutdown()

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) CreateDenial(
	ctx context.Context,
	req *connect.Request[pb.CreateDenialRequest],
) (*connect.Response[emptypb.Empty], error) {
	// First check if the UTXO exists
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	if req.Msg.DelaySeconds <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("delay_seconds must be positive"))
	}

	if req.Msg.NumHops <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("num_hops must be positive"))
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Check if UTXO exists
	var utxoExists bool
	for _, utxo := range utxos.Msg.Outputs {
		if utxo.Txid.Hex.Value == req.Msg.Txid && utxo.Vout == req.Msg.Vout {
			utxoExists = true
			break
		}
	}

	if !utxoExists {
		return nil, connect.NewError(
			connect.CodeInvalidArgument,
			fmt.Errorf("utxo %s:%d not found in wallet", req.Msg.Txid, req.Msg.Vout),
		)
	}

	denial, err := deniability.GetByTip(ctx, s.db, req.Msg.Txid, req.Msg.Vout)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("could not get by tip: %w", err))
	}

	if denial != nil {
		// denial for this utxo already exists. Let's piggy back on that by updating its values
		if err := deniability.Update(ctx, s.db, denial.ID, req.Msg.DelaySeconds, req.Msg.NumHops); err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		return connect.NewResponse(&emptypb.Empty{}), nil
	}

	// UTXO exists, create the denial
	err = deniability.Create(
		ctx,
		s.db,
		req.Msg.Txid,
		int32(req.Msg.Vout),
		time.Duration(req.Msg.DelaySeconds)*time.Second,
		req.Msg.NumHops,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) ListDenials(
	ctx context.Context,
	req *connect.Request[emptypb.Empty],
) (*connect.Response[pb.ListDenialsResponse], error) {
	// First get all UTXOs from the wallet
	wallet, err := s.wallet.Get(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	utxos, err := wallet.ListUnspentOutputs(ctx, connect.NewRequest(&validatorpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	deniabilities, err := deniability.List(ctx, s.db)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Create map of deniability info by current tip txid/vout
	deniabilityMap := make(map[string]*deniability.Denial)
	for _, d := range deniabilities {
		// key is txid:vout
		key := fmt.Sprintf("%s:%d", d.TipTXID, d.TipVout)
		deniabilityMap[key] = &d
	}

	// Build response with UTXOs and matched deniability info
	var pbUtxos []*pb.UnspentOutput
	for _, utxo := range utxos.Msg.Outputs {
		pbUtxo := &pb.UnspentOutput{
			Txid:       utxo.Txid.Hex.Value,
			Vout:       utxo.Vout,
			ValueSats:  utxo.ValueSats,
			IsInternal: utxo.IsInternal,
		}

		key := fmt.Sprintf("%s:%d", utxo.Txid.Hex.Value, utxo.Vout)
		if d, exists := deniabilityMap[key]; exists {
			// the utxo has deniability info! Add it to the response
			deniability, err := s.withDeniability(ctx, d)
			if err != nil {
				return nil, connect.NewError(connect.CodeInternal, err)
			}
			pbUtxo.Deniability = deniability
		}

		pbUtxos = append(pbUtxos, pbUtxo)
	}

	return connect.NewResponse(&pb.ListDenialsResponse{
		Utxos: pbUtxos,
	}), nil
}

func (s *Server) withDeniability(ctx context.Context, d *deniability.Denial) (*pb.DeniabilityInfo, error) {
	nextExecution, err := deniability.NextExecution(ctx, s.db, *d)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	executions, err := deniability.ListExecutions(ctx, s.db, d.ID)
	if err != nil {
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
			ToVout:     uint32(e.ToVout),
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
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) CreateAddressBookEntry(ctx context.Context, req *connect.Request[pb.CreateAddressBookEntryRequest]) (*connect.Response[emptypb.Empty], error) {
	direction, err := addressbook.DirectionFromProto(req.Msg.Direction)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if err := addressbook.Create(ctx, s.db, req.Msg.Label, req.Msg.Address, direction); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) ListAddressBook(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListAddressBookResponse], error) {
	entries, err := addressbook.List(ctx, s.db)
	if err != nil {
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
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) DeleteAddressBookEntry(ctx context.Context, req *connect.Request[pb.DeleteAddressBookEntryRequest]) (*connect.Response[emptypb.Empty], error) {
	if err := addressbook.Delete(ctx, s.db, req.Msg.Id); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}
