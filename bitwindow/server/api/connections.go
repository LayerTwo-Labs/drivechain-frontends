package api

import (
	"context"
	"time"

	"github.com/rs/zerolog"

	orchctlpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchctlrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

const connectionsRetryWait = time.Second

// follower takes its connection state from a channel.
type follower interface {
	Follow(ctx context.Context, up <-chan bool)
}

// connectionTargets routes the state of a drivechaind binary to the services
// that it serves.
type connectionTargets map[string][]chan bool

func (c connectionTargets) add(ctx context.Context, binary string, f follower) {
	ch := make(chan bool, 1)
	f.Follow(ctx, ch)
	c[binary] = append(c[binary], ch)
}

// offer replaces an unread state with v. One goroutine writes each channel.
func offer(ch chan bool, v bool) {
	select {
	case <-ch:
	default:
	}
	ch <- v
}

// followConnections sends each change of a binary to its services until ctx
// ends. A broken stream keeps the last state and dials the stream again.
func followConnections(ctx context.Context, client orchctlrpc.OrchestratorServiceClient, targets connectionTargets) {
	for {
		err := watchConnections(ctx, client, targets)
		if ctx.Err() != nil {
			return
		}
		zerolog.Ctx(ctx).Debug().Err(err).Msg("connection stream stopped")
		select {
		case <-ctx.Done():
			return
		case <-time.After(connectionsRetryWait):
		}
	}
}

func watchConnections(ctx context.Context, client orchctlrpc.OrchestratorServiceClient, targets connectionTargets) error {
	stream, err := client.WatchConnections(ctx, &orchctlpb.WatchConnectionsRequest{})
	if err != nil {
		return err
	}
	defer stream.Close() //nolint:errcheck // the stream is done either way
	last := make(map[string]bool, len(targets))
	for {
		msg, err := stream.Receive()
		if err != nil {
			return err
		}
		if msg.GetHeartbeat() {
			continue
		}
		up := make(map[string]bool, len(msg.GetConnections()))
		for _, c := range msg.GetConnections() {
			up[c.GetName()] = c.GetConnected()
		}
		for binary, chans := range targets {
			v := up[binary]
			if prev, seen := last[binary]; seen && prev == v {
				continue
			}
			last[binary] = v
			for _, ch := range chans {
				offer(ch, v)
			}
		}
	}
}
