package api

import (
	"context"
	"slices"
	"time"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/proto"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/watch"
)

// binariesRecheckInterval is how often the binaries feed reads the state that
// no monitor event covers, such as a file on disk.
const binariesRecheckInterval = time.Second

// SyncStatusSource supplies the snapshot that WatchSyncStatus streams.
type SyncStatusSource interface {
	// SubscribeSyncStatus wakes the channel when the snapshot can differ.
	// The channel lives until ctx is done.
	SubscribeSyncStatus(ctx context.Context) <-chan struct{}
	SyncStatus(ctx context.Context) (*orchestrator.SyncStatus, error)
}

// SetSyncStatusSource replaces the source of WatchSyncStatus.
func (h *Handler) SetSyncStatusSource(src SyncStatusSource) {
	// The source polls by itself, so the feed needs no recheck.
	h.syncFeed = &feed[*pb.GetSyncStatusResponse]{
		read: func(ctx context.Context) (*pb.GetSyncStatusResponse, error) {
			s, err := src.SyncStatus(ctx)
			if err != nil {
				return nil, err
			}
			return h.syncStatusToProto(s), nil
		},
		same:    func(a, b *pb.GetSyncStatusResponse) bool { return proto.Equal(a, b) },
		changed: src.SubscribeSyncStatus,
	}
}

// pollSyncStatus reads GetSyncStatus on a fixed tick.
type pollSyncStatus struct {
	orch     *orchestrator.Orchestrator
	interval time.Duration
}

func (p pollSyncStatus) SubscribeSyncStatus(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)
	go func() {
		ticker := time.NewTicker(p.interval)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				select {
				case ch <- struct{}{}:
				default:
				}
			}
		}
	}()
	return ch
}

func (p pollSyncStatus) SyncStatus(ctx context.Context) (*orchestrator.SyncStatus, error) {
	return p.orch.GetSyncStatus(ctx)
}

// engineSyncStatus wakes on each Core tip or health change, and again a short
// time later for the enforcer and sidechains that follow the tip. The slow
// poll covers the state that no event reaches.
type engineSyncStatus struct {
	pollSyncStatus
	engine *chaindata.Engine
	// sidechainRunning reports whether a sidechain runs. Its height has no
	// event, so it keeps the fast poll.
	sidechainRunning func() bool
}

// poll ticks each syncStatusPollInterval while a sidechain runs, else each
// interval.
func (e engineSyncStatus) poll(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)
	go func() {
		ticker := time.NewTicker(syncStatusPollInterval)
		defer ticker.Stop()
		last := time.Now()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
			}
			if !e.sidechainRunning() && time.Since(last) < e.interval {
				continue
			}
			last = time.Now()
			select {
			case ch <- struct{}{}:
			default:
			}
		}
	}()
	return ch
}

// followUps are the extra wakes after a Core event.
var followUps = []time.Duration{100 * time.Millisecond, 500 * time.Millisecond, 2 * time.Second}

func (e engineSyncStatus) SubscribeSyncStatus(ctx context.Context) <-chan struct{} {
	out := make(chan struct{}, 1)
	wake := func() {
		select {
		case out <- struct{}{}:
		default:
		}
	}
	forward := func(in <-chan struct{}, after []time.Duration) {
		for {
			select {
			case <-ctx.Done():
				return
			case _, ok := <-in:
				if !ok {
					return
				}
				wake()
				for _, d := range after {
					time.AfterFunc(d, wake)
				}
			}
		}
	}
	go forward(e.poll(ctx), nil)
	go forward(e.engine.Subscribe(ctx, chaindata.KindBlockchainInfo), followUps)
	go forward(e.engine.Subscribe(ctx, chaindata.KindHealth), followUps)
	return out
}

func (h *Handler) WatchSyncStatus(ctx context.Context, req *pb.WatchSyncStatusRequest, stream rpc.OrchestratorServiceWatchSyncStatusServerStream) error {
	f := h.syncFeed
	return watch.Changes(ctx, f.subscribe(ctx), WatchHeartbeatInterval, WatchHeartbeatInterval, f.latest, f.same,
		func(status *pb.GetSyncStatusResponse) error {
			return stream.Send(&pb.WatchSyncStatusResponse{Status: status})
		},
		func() error { return stream.Send(&pb.WatchSyncStatusResponse{Heartbeat: true}) },
	)
}

func (h *Handler) WatchBinaries(ctx context.Context, req *pb.WatchBinariesRequest, stream rpc.OrchestratorServiceWatchBinariesServerStream) error {
	feed := h.binariesFeed(req.ForceBackend)
	return watch.Changes(ctx, feed.subscribe(ctx), WatchHeartbeatInterval, WatchHeartbeatInterval, feed.latest, sameBinaries,
		func(binaries []*pb.BinaryStatusMsg) error {
			return stream.Send(&pb.WatchBinariesResponse{Binaries: binaries})
		},
		func() error { return stream.Send(&pb.WatchBinariesResponse{Heartbeat: true}) },
	)
}

// WatchConnections wakes on each monitor change. The recheck only satisfies
// watch.Changes: each change of a connected bit notifies.
func (h *Handler) WatchConnections(ctx context.Context, _ *pb.WatchConnectionsRequest, stream rpc.OrchestratorServiceWatchConnectionsServerStream) error {
	read := func() ([]*pb.BinaryConnection, error) {
		conns := h.orch.Connections()
		out := make([]*pb.BinaryConnection, len(conns))
		for i, c := range conns {
			out[i] = &pb.BinaryConnection{Name: c.Name, Connected: c.Connected}
		}
		return out, nil
	}
	same := func(a, b []*pb.BinaryConnection) bool {
		return slices.EqualFunc(a, b, func(x, y *pb.BinaryConnection) bool { return proto.Equal(x, y) })
	}
	return watch.Changes(ctx, h.orch.SubscribeBinaries(ctx), WatchHeartbeatInterval, WatchHeartbeatInterval, read, same,
		func(conns []*pb.BinaryConnection) error {
			return stream.Send(&pb.WatchConnectionsResponse{Connections: conns})
		},
		func() error { return stream.Send(&pb.WatchConnectionsResponse{Heartbeat: true}) },
	)
}

// sameBinaries ignores the uptime, which moves on each read.
func sameBinaries(a, b []*pb.BinaryStatusMsg) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i].UptimeSeconds != b[i].UptimeSeconds {
			x, y := proto.CloneOf(a[i]), proto.CloneOf(b[i])
			x.UptimeSeconds, y.UptimeSeconds = 0, 0
			if !proto.Equal(x, y) {
				return false
			}
			continue
		}
		if !proto.Equal(a[i], b[i]) {
			return false
		}
	}
	return true
}

// syncStatusPollInterval is the tick of the default SyncStatusSource.
const syncStatusPollInterval = 250 * time.Millisecond

// engineSyncStatusPollInterval is the tick for the state outside the engine.
const engineSyncStatusPollInterval = time.Second

func (h *Handler) WatchDownloadStatus(ctx context.Context, req *pb.WatchDownloadStatusRequest, stream rpc.OrchestratorServiceWatchDownloadStatusServerStream) error {
	changed := h.orch.SubscribeDownloads(ctx)
	read := func() ([]*pb.DownloadStatus, error) {
		return downloadStatesToProto(h.orch.DownloadStates()), nil
	}
	same := func(a, b []*pb.DownloadStatus) bool {
		return slices.EqualFunc(a, b, func(x, y *pb.DownloadStatus) bool { return proto.Equal(x, y) })
	}
	return watch.Changes(ctx, changed, WatchHeartbeatInterval, WatchHeartbeatInterval, read, same,
		func(downloads []*pb.DownloadStatus) error {
			return stream.Send(&pb.WatchDownloadStatusResponse{Downloads: downloads})
		},
		func() error { return stream.Send(&pb.WatchDownloadStatusResponse{Heartbeat: true}) },
	)
}

// migrationRecheckInterval matches the old frontend poll of the migration.
const migrationRecheckInterval = 3 * time.Second

func (h *Handler) WatchECashMigrationStatus(ctx context.Context, req *pb.WatchECashMigrationStatusRequest, stream rpc.OrchestratorServiceWatchECashMigrationStatusServerStream) error {
	changed := h.orch.SubscribeECashMigration(ctx)
	read := func() (*pb.ECashMigrationStatus, error) {
		status, err := h.orch.ECashMigrationStatus()
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
		}
		return ecashMigrationStatusToProto(status), nil
	}
	return watch.Changes(ctx, changed, migrationRecheckInterval, WatchHeartbeatInterval, read,
		func(a, b *pb.ECashMigrationStatus) bool { return proto.Equal(a, b) },
		func(status *pb.ECashMigrationStatus) error {
			return stream.Send(&pb.WatchECashMigrationStatusResponse{Status: status})
		},
		func() error { return stream.Send(&pb.WatchECashMigrationStatusResponse{Heartbeat: true}) },
	)
}
