package api_bitwindowd

import (
	"context"

	"connectrpc.com/connect"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/bitwindowd/v1/bitwindowdv1connect"
	"google.golang.org/protobuf/types/known/emptypb"
)

var _ rpc.BitwindowdServiceHandler = new(Server)

// New creates a new Server
func New(
	onShutdown func(),
) *Server {
	s := &Server{
		onShutdown: onShutdown,
	}
	return s
}

type Server struct {
	onShutdown func()
}

// EstimateSmartFee implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) Stop(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
	defer s.onShutdown()

	return connect.NewResponse(&emptypb.Empty{}), nil
}
