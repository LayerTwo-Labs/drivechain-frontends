package sidechain

import (
	"context"
	"fmt"

	"connectrpc.com/connect/v2"
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
	req *pb.GetDetectedWithdrawalsRequest,
) (*pb.GetDetectedWithdrawalsResponse, error) {
	withdrawals, err := s.monitor.GetDetectedWithdrawals(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	// Convert to protobuf
	pbWithdrawals := make([]*pb.DetectedWithdrawal, 0, len(withdrawals))
	for _, w := range withdrawals {
		// Filter by sidechain if requested
		if req.Sidechain != nil && *req.Sidechain != w.Sidechain {
			continue
		}

		pbWithdrawals = append(pbWithdrawals, withdrawalToProto(w))

		// Apply limit if specified
		if req.Limit != nil && len(pbWithdrawals) >= int(*req.Limit) {
			break
		}
	}

	return &pb.GetDetectedWithdrawalsResponse{
		Withdrawals: pbWithdrawals,
	}, nil
}

func (s *Server) GetWithdrawalByTxid(
	ctx context.Context,
	req *pb.GetWithdrawalByTxidRequest,
) (*pb.GetWithdrawalByTxidResponse, error) {
	withdrawal, err := s.monitor.GetWithdrawalByTxid(ctx, req.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Sprintf("get withdrawal %s: %s", req.Txid, err)).WithCause(err)
	}

	resp := &pb.GetWithdrawalByTxidResponse{}

	if withdrawal != nil {
		resp.Withdrawal = withdrawalToProto(*withdrawal)
	}

	return resp, nil
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
