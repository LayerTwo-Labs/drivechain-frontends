package api

import (
	"context"
	"errors"
	"io/fs"
	"path/filepath"
	"time"

	"github.com/fsnotify/fsnotify"
	"google.golang.org/protobuf/proto"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/watch"
)

// confRecheckInterval matches the old frontend poll of the config RPCs. It
// covers state that no file holds, such as the published network catalog.
const confRecheckInterval = 5 * time.Second

// confSettle is the quiet time after a file event before the stream reads.
// The read can write a migration back, so it must not see a half-written file.
const confSettle = 100 * time.Millisecond

// watchFiles wakes the returned channel confSettle after the last event for
// one of paths, and on each watcher error, until ctx is done. A missing
// folder gets no watch.
func watchFiles(ctx context.Context, paths ...string) (<-chan struct{}, error) {
	w, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, err
	}
	names := make(map[string]struct{}, len(paths))
	dirs := make(map[string]struct{}, len(paths))
	for _, p := range paths {
		if p == "" {
			continue
		}
		p = filepath.Clean(p)
		names[p] = struct{}{}
		dirs[filepath.Dir(p)] = struct{}{}
	}
	for dir := range dirs {
		if err := w.Add(dir); err != nil && !errors.Is(err, fs.ErrNotExist) {
			_ = w.Close()
			return nil, err
		}
	}

	ch := make(chan struct{}, 1)
	wake := func() {
		select {
		case ch <- struct{}{}:
		default:
		}
	}
	go func() {
		defer w.Close() //nolint:errcheck // the stream is done
		settle := time.NewTimer(confSettle)
		settle.Stop()
		defer settle.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-settle.C:
				wake()
			case ev, ok := <-w.Events:
				if !ok {
					return
				}
				if _, hit := names[filepath.Clean(ev.Name)]; hit {
					settle.Reset(confSettle)
				}
			case _, ok := <-w.Errors:
				if !ok {
					return
				}
				// A dropped event can hide a write.
				wake()
			}
		}
	}()
	return ch, nil
}

func sameProto[T proto.Message](a, b T) bool { return proto.Equal(a, b) }

func (h *BitcoinConfHandler) WatchBitcoinConfig(ctx context.Context, req *pb.WatchBitcoinConfigRequest, stream rpc.BitcoinConfServiceWatchBitcoinConfigServerStream) error {
	var paths []string
	if h.conf != nil {
		paths = []string{h.conf.BitWindowConfigPath(), h.conf.ConfigPath}
	}
	changed, err := watchFiles(ctx, paths...)
	if err != nil {
		return err
	}
	read := func() (*pb.WatchBitcoinConfigResponse, error) {
		cfg, err := h.GetBitcoinConfig(ctx, &pb.GetBitcoinConfigRequest{})
		if err != nil {
			return nil, err
		}
		return &pb.WatchBitcoinConfigResponse{Config: cfg, Networks: networkOptionsToProto(h.orch.ListNetworks())}, nil
	}
	return watch.Changes(ctx, changed, confRecheckInterval, WatchHeartbeatInterval, read, sameProto,
		stream.Send,
		func() error { return stream.Send(&pb.WatchBitcoinConfigResponse{Heartbeat: true}) },
	)
}

func (h *EnforcerConfHandler) WatchEnforcerConfig(ctx context.Context, req *pb.WatchEnforcerConfigRequest, stream rpc.EnforcerConfServiceWatchEnforcerConfigServerStream) error {
	var paths []string
	if h.conf != nil {
		paths = []string{h.conf.ConfigFilePath()}
	}
	changed, err := watchFiles(ctx, paths...)
	if err != nil {
		return err
	}
	read := func() (*pb.GetEnforcerConfigResponse, error) {
		return h.GetEnforcerConfig(ctx, &pb.GetEnforcerConfigRequest{})
	}
	return watch.Changes(ctx, changed, confRecheckInterval, WatchHeartbeatInterval, read, sameProto,
		func(cfg *pb.GetEnforcerConfigResponse) error {
			return stream.Send(&pb.WatchEnforcerConfigResponse{Config: cfg})
		},
		func() error { return stream.Send(&pb.WatchEnforcerConfigResponse{Heartbeat: true}) },
	)
}

func (h *SidechainConfHandler) WatchSidechainConfig(ctx context.Context, req *pb.GetSidechainConfigRequest, stream rpc.SidechainConfServiceWatchSidechainConfigServerStream) error {
	m, err := h.getManager(req.SidechainName)
	if err != nil {
		return err
	}
	changed, err := watchFiles(ctx, m.ConfigFilePath())
	if err != nil {
		return err
	}
	read := func() (*pb.GetSidechainConfigResponse, error) {
		return h.GetSidechainConfig(ctx, req)
	}
	return watch.Changes(ctx, changed, confRecheckInterval, WatchHeartbeatInterval, read, sameProto,
		func(cfg *pb.GetSidechainConfigResponse) error {
			return stream.Send(&pb.WatchSidechainConfigResponse{Config: cfg})
		},
		func() error { return stream.Send(&pb.WatchSidechainConfigResponse{Heartbeat: true}) },
	)
}
