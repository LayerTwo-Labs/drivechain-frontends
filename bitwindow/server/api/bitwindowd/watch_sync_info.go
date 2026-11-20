package bitwindowd

import (
	"context"
	"time"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/watch"
)

const (
	// syncInfoRecheckInterval matches the old frontend poll of GetSyncInfo.
	syncInfoRecheckInterval = time.Second
	// syncInfoHeartbeatInterval keeps the client watchdog fed on a quiet stream.
	syncInfoHeartbeatInterval = 5 * time.Second
)

// SetTipSource names the wake that WatchSyncInfo reads on each new processed
// block.
func (s *Server) SetTipSource(subscribe func(ctx context.Context) <-chan struct{}) {
	s.tipChanged = subscribe
}

func (s *Server) WatchSyncInfo(ctx context.Context, _ *emptypb.Empty, stream rpc.BitwindowdServiceWatchSyncInfoServerStream) error {
	var tip <-chan struct{}
	if s.tipChanged != nil {
		tip = s.tipChanged(ctx)
	}
	return watch.Changes(ctx, tip, syncInfoRecheckInterval, syncInfoHeartbeatInterval,
		func() (*pb.GetSyncInfoResponse, error) { return s.GetSyncInfo(ctx, &emptypb.Empty{}) },
		func(a, b *pb.GetSyncInfoResponse) bool { return proto.Equal(a, b) },
		func(info *pb.GetSyncInfoResponse) error { return stream.Send(&pb.WatchSyncInfoResponse{Info: info}) },
		func() error { return stream.Send(&pb.WatchSyncInfoResponse{Heartbeat: true}) },
	)
}
