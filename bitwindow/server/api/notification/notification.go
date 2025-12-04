package api_notification

import (
	"context"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1/notificationv1connect"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/emptypb"
)

var _ rpc.NotificationServiceHandler = new(Server)

func New(notificationEngine *engines.NotificationEngine) *Server {
	return &Server{
		notificationEngine: notificationEngine,
	}
}

type Server struct {
	notificationEngine *engines.NotificationEngine
}

func (s *Server) Watch(
	ctx context.Context,
	req *connect.Request[emptypb.Empty],
	stream *connect.ServerStream[notificationv1.WatchResponse],
) error {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("notification watch stream started")

	// Subscribe to notification engine
	eventCh := s.notificationEngine.Subscribe(ctx)

	// Stream events to client
	for {
		select {
		case <-ctx.Done():
			log.Info().Msg("notification watch stream closed")
			return ctx.Err()
		case event, ok := <-eventCh:
			if !ok {
				log.Info().Msg("notification event channel closed")
				return nil
			}

			if err := stream.Send(event); err != nil {
				log.Warn().Err(err).Msg("send notification event")
				return err
			}

			log.Debug().
				Str("event_type", getEventType(event)).
				Msg("notification event sent")
		}
	}
}

func getEventType(event *notificationv1.WatchResponse) string {
	switch event.Event.(type) {
	case *notificationv1.WatchResponse_Transaction:
		return "transaction"
	case *notificationv1.WatchResponse_TimestampEvent:
		return "timestamp"
	case *notificationv1.WatchResponse_System:
		return "system"
	default:
		return "unknown"
	}
}
