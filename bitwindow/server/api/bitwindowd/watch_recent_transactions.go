package bitwindowd

import (
	"context"
	"errors"
	"time"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/proto"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	mempoolpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/watch"
)

// recentRecheckInterval matches the old frontend poll of ListRecentTransactions.
const recentRecheckInterval = 5 * time.Second

func (s *Server) WatchRecentTransactions(ctx context.Context, req *pb.ListRecentTransactionsRequest, stream rpc.BitwindowdServiceWatchRecentTransactionsServerStream) error {
	if s.mempool == nil {
		return errors.New("no mempool source")
	}
	ctx, cancel := context.WithCancelCause(ctx)
	defer cancel(nil)
	feed, err := s.mempool.WatchTransactions(ctx, &mempoolpb.WatchTransactionsRequest{})
	if err != nil {
		return connect.NewError(connect.CodeUnavailable, "drivechaind: watch mempool: "+err.Error()).WithCause(err)
	}
	defer feed.Close() //nolint:errcheck // the stream is done either way

	changed := make(chan struct{}, 1)
	go func() {
		for {
			msg, err := feed.Receive()
			if err != nil {
				// Unavailable, so a client does not take the code of drivechaind for its own.
				cancel(connect.NewError(connect.CodeUnavailable, "drivechaind: watch mempool: "+err.Error()).WithCause(err))
				return
			}
			if msg.GetHeartbeat() || msg.GetSnapshot().GetMore() {
				continue
			}
			select {
			case changed <- struct{}{}:
			default:
			}
		}
	}()

	err = watch.Changes(ctx, changed, recentRecheckInterval, syncInfoHeartbeatInterval,
		func() (*pb.ListRecentTransactionsResponse, error) { return s.ListRecentTransactions(ctx, req) },
		func(a, b *pb.ListRecentTransactionsResponse) bool { return proto.Equal(a, b) },
		func(list *pb.ListRecentTransactionsResponse) error {
			return stream.Send(&pb.WatchRecentTransactionsResponse{Transactions: list.Transactions})
		},
		func() error { return stream.Send(&pb.WatchRecentTransactionsResponse{Heartbeat: true}) },
	)
	if cause := context.Cause(ctx); cause != nil && !errors.Is(cause, context.Canceled) {
		return cause
	}
	return err
}
