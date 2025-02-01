package api_bitwindowd

import (
	"context"
	"database/sql"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/deniability"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.BitwindowdServiceHandler = new(Server)

// New creates a new Server
func New(
	onShutdown func(),
	db *sql.DB,
) *Server {
	s := &Server{
		onShutdown: onShutdown,
		db:         db,
	}
	return s
}

type Server struct {
	onShutdown func()
	db         *sql.DB
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) Stop(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	defer s.onShutdown()

	return connect.NewResponse(&emptypb.Empty{}), nil
}

func (s *Server) CreateDenial(
	ctx context.Context,
	req *connect.Request[pb.CreateDenialRequest],
) (*connect.Response[pb.CreateDenialResponse], error) {
	err := deniability.Create(
		ctx,
		s.db,
		time.Duration(req.Msg.DelaySeconds)*time.Second,
		int(req.Msg.NumHops),
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.CreateDenialResponse{}), nil
}

func (s *Server) ListDenials(
	ctx context.Context,
	req *connect.Request[emptypb.Empty],
) (*connect.Response[pb.ListDenialsResponse], error) {
	deniabilities, err := deniability.List(ctx, s.db)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var pbDenials []*pb.Denial
	for _, d := range deniabilities {
		nextExecution, err := deniability.NextExecution(ctx, s.db, d.ID)
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
				Id:            e.ID,
				DenialId:      e.DenialID,
				TransactionId: e.TransactionID,
				CreatedAt:     timestamppb.New(e.CreatedAt),
			})
		}

		pbDenials = append(pbDenials, &pb.Denial{
			Id:           d.ID,
			DelaySeconds: int32(d.DelayDuration.Seconds()),
			NumHops:      d.NumHops,
			CreatedAt:    timestamppb.New(d.CreatedAt),
			CancelledAt: func() *timestamppb.Timestamp {
				if d.CancelledAt != nil {
					return timestamppb.New(*d.CancelledAt)
				}
				return nil
			}(),
			NextExecution: func() *timestamppb.Timestamp {
				if nextExecution == nil {
					return nil
				}
				return timestamppb.New(*nextExecution)
			}(),
			Executions: pbExecutions,
		})
	}

	return connect.NewResponse(&pb.ListDenialsResponse{
		Denials: pbDenials,
	}), nil
}

func (s *Server) CancelDenial(
	ctx context.Context,
	req *connect.Request[pb.CancelDenialRequest],
) (*connect.Response[emptypb.Empty], error) {
	err := deniability.Cancel(ctx, s.db, req.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&emptypb.Empty{}), nil
}
