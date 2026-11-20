package api

import (
	"context"
	"slices"
	"time"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/proto"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/watch"
)

// binariesRecheckInterval is how often WatchBinaries reads the binary state
// that no monitor event covers, such as a file on disk or a port in use.
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
	h.syncSource = src
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

func (h *Handler) WatchSyncStatus(ctx context.Context, req *pb.WatchSyncStatusRequest, stream rpc.OrchestratorServiceWatchSyncStatusServerStream) error {
	changed := h.syncSource.SubscribeSyncStatus(ctx)
	read := func() (*pb.GetSyncStatusResponse, error) {
		s, err := h.syncSource.SyncStatus(ctx)
		if err != nil {
			return nil, err
		}
		return h.syncStatusToProto(s), nil
	}
	return watch.Changes(ctx, changed, binariesRecheckInterval, WatchHeartbeatInterval, read, func(a, b *pb.GetSyncStatusResponse) bool { return proto.Equal(a, b) },
		func(status *pb.GetSyncStatusResponse) error {
			return stream.Send(&pb.WatchSyncStatusResponse{Status: status})
		},
		func() error { return stream.Send(&pb.WatchSyncStatusResponse{Heartbeat: true}) },
	)
}

func (h *Handler) WatchBinaries(ctx context.Context, req *pb.WatchBinariesRequest, stream rpc.OrchestratorServiceWatchBinariesServerStream) error {
	changed := h.orch.SubscribeBinaries(ctx)
	opts := orchestrator.DownloadOptions{ForceBackend: req.ForceBackend}
	read := func() ([]*pb.BinaryStatusMsg, error) {
		statuses := h.orch.ListAllWithOptions(opts)
		out := make([]*pb.BinaryStatusMsg, len(statuses))
		for i, s := range statuses {
			out[i] = statusToProto(s)
		}
		return out, nil
	}
	return watch.Changes(ctx, changed, binariesRecheckInterval, WatchHeartbeatInterval, read, sameBinaries,
		func(binaries []*pb.BinaryStatusMsg) error {
			return stream.Send(&pb.WatchBinariesResponse{Binaries: binaries})
		},
		func() error { return stream.Send(&pb.WatchBinariesResponse{Heartbeat: true}) },
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
