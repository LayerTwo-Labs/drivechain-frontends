package sidechain

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/sidechain/v1"
)

type Server struct {
	monitor *engines.SidechainMonitorEngine
}

func New(monitor *engines.SidechainMonitorEngine) *Server {
	return &Server{
		monitor: monitor,
	}
}

func (s *Server) GetDetectedWithdrawals(
	ctx context.Context,
	req *connect.Request[pb.GetDetectedWithdrawalsRequest],
) (*connect.Response[pb.GetDetectedWithdrawalsResponse], error) {
	withdrawals, err := s.monitor.GetDetectedWithdrawals(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Convert to protobuf
	pbWithdrawals := make([]*pb.DetectedWithdrawal, 0, len(withdrawals))
	for _, w := range withdrawals {
		// Filter by sidechain if requested
		if req.Msg.Sidechain != nil && *req.Msg.Sidechain != w.Sidechain {
			continue
		}

		pbWithdrawals = append(pbWithdrawals, withdrawalToProto(w))

		// Apply limit if specified
		if req.Msg.Limit != nil && len(pbWithdrawals) >= int(*req.Msg.Limit) {
			break
		}
	}

	return connect.NewResponse(&pb.GetDetectedWithdrawalsResponse{
		Withdrawals: pbWithdrawals,
	}), nil
}

func (s *Server) GetWithdrawalByTxid(
	ctx context.Context,
	req *connect.Request[pb.GetWithdrawalByTxidRequest],
) (*connect.Response[pb.GetWithdrawalByTxidResponse], error) {
	withdrawal, err := s.monitor.GetWithdrawalByTxid(ctx, req.Msg.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get withdrawal %s: %w", req.Msg.Txid, err))
	}

	resp := &pb.GetWithdrawalByTxidResponse{}

	if withdrawal != nil {
		resp.Withdrawal = withdrawalToProto(*withdrawal)
	}

	return connect.NewResponse(resp), nil
}

func withdrawalToProto(w engines.DetectedWithdrawal) *pb.DetectedWithdrawal {
	return &pb.DetectedWithdrawal{
		Txid:        w.Txid,
		Sidechain:   w.Sidechain,
		Amount:      w.Amount,
		Destination: w.Destination,
		DetectedAt:  timestamppb.New(w.DetectedAt),
		BlockHash:   w.BlockHash,
	}
}
