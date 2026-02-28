package api

import (
	"context"
	"time"

	"connectrpc.com/connect"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

var _ rpc.OrchestratorServiceHandler = new(Handler)

// Handler implements the OrchestratorService gRPC handler.
type Handler struct {
	orch *orchestrator.Orchestrator
}

func NewHandler(orch *orchestrator.Orchestrator) *Handler {
	return &Handler{orch: orch}
}

func (h *Handler) ListBinaries(ctx context.Context, req *connect.Request[pb.ListBinariesRequest]) (*connect.Response[pb.ListBinariesResponse], error) {
	statuses := h.orch.ListAll()
	pbStatuses := make([]*pb.BinaryStatusMsg, len(statuses))
	for i, s := range statuses {
		pbStatuses[i] = statusToProto(s)
	}
	return connect.NewResponse(&pb.ListBinariesResponse{
		Binaries: pbStatuses,
	}), nil
}

func (h *Handler) GetBinaryStatus(ctx context.Context, req *connect.Request[pb.GetBinaryStatusRequest]) (*connect.Response[pb.GetBinaryStatusResponse], error) {
	s := h.orch.Status(req.Msg.Name)
	return connect.NewResponse(&pb.GetBinaryStatusResponse{
		Status: statusToProto(s),
	}), nil
}

func (h *Handler) DownloadBinary(ctx context.Context, req *connect.Request[pb.DownloadBinaryRequest], stream *connect.ServerStream[pb.DownloadBinaryResponse]) error {
	ch, err := h.orch.Download(ctx, req.Msg.Name, req.Msg.Force)
	if err != nil {
		return err
	}

	for p := range ch {
		msg := &pb.DownloadBinaryResponse{
			BytesDownloaded: p.BytesDownloaded,
			TotalBytes:      p.TotalBytes,
			Message:         p.Message,
			Done:            p.Done,
		}
		if p.Error != nil {
			msg.Error = p.Error.Error()
		}
		if err := stream.Send(msg); err != nil {
			return err
		}
	}

	return nil
}

func (h *Handler) StartBinary(ctx context.Context, req *connect.Request[pb.StartBinaryRequest]) (*connect.Response[pb.StartBinaryResponse], error) {
	pid, err := h.orch.Start(ctx, req.Msg.Name, req.Msg.ExtraArgs, req.Msg.Env)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StartBinaryResponse{
		Pid: int32(pid),
	}), nil
}

func (h *Handler) StopBinary(ctx context.Context, req *connect.Request[pb.StopBinaryRequest]) (*connect.Response[pb.StopBinaryResponse], error) {
	if err := h.orch.Stop(ctx, req.Msg.Name, req.Msg.Force); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StopBinaryResponse{}), nil
}

func (h *Handler) WatchBinaries(ctx context.Context, req *connect.Request[pb.WatchBinariesRequest], stream *connect.ServerStream[pb.WatchBinariesResponse]) error {
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		statuses := h.orch.ListAll()
		pbStatuses := make([]*pb.BinaryStatusMsg, len(statuses))
		for i, s := range statuses {
			pbStatuses[i] = statusToProto(s)
		}

		if err := stream.Send(&pb.WatchBinariesResponse{
			Binaries: pbStatuses,
		}); err != nil {
			return err
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		}
	}
}

func (h *Handler) StreamLogs(ctx context.Context, req *connect.Request[pb.StreamLogsRequest], stream *connect.ServerStream[pb.StreamLogsResponse]) error {
	// Send recent logs first
	if req.Msg.Tail > 0 {
		recent, err := h.orch.RecentLogs(req.Msg.Name, int(req.Msg.Tail))
		if err != nil {
			return err
		}
		for _, entry := range recent {
			if err := stream.Send(&pb.StreamLogsResponse{
				Stream:        entry.Stream,
				Line:          entry.Line,
				TimestampUnix: entry.Timestamp.Unix(),
			}); err != nil {
				return err
			}
		}
	}

	// Stream live logs
	ch, cancel, err := h.orch.Logs(req.Msg.Name)
	if err != nil {
		return err
	}
	defer cancel()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case entry, ok := <-ch:
			if !ok {
				return nil
			}
			if err := stream.Send(&pb.StreamLogsResponse{
				Stream:        entry.Stream,
				Line:          entry.Line,
				TimestampUnix: entry.Timestamp.Unix(),
			}); err != nil {
				return err
			}
		}
	}
}

func (h *Handler) StartWithDeps(ctx context.Context, req *connect.Request[pb.StartWithDepsRequest], stream *connect.ServerStream[pb.StartWithDepsResponse]) error {
	ch, err := h.orch.StartWithDeps(ctx, req.Msg.Target, orchestrator.StartOpts{
		TargetArgs:   req.Msg.TargetArgs,
		TargetEnv:    req.Msg.TargetEnv,
		CoreArgs:     req.Msg.CoreArgs,
		EnforcerArgs: req.Msg.EnforcerArgs,
		Immediate:    req.Msg.Immediate,
	})
	if err != nil {
		return err
	}

	for p := range ch {
		msg := &pb.StartWithDepsResponse{
			Stage:   p.Stage,
			Message: p.Message,
			Done:    p.Done,
		}
		if p.Error != nil {
			msg.Error = p.Error.Error()
		}
		if err := stream.Send(msg); err != nil {
			return err
		}
	}

	return nil
}

func (h *Handler) ShutdownAll(ctx context.Context, req *connect.Request[pb.ShutdownAllRequest], stream *connect.ServerStream[pb.ShutdownAllResponse]) error {
	ch, err := h.orch.ShutdownAll(ctx, req.Msg.Force)
	if err != nil {
		return err
	}

	for p := range ch {
		msg := &pb.ShutdownAllResponse{
			TotalCount:    int32(p.TotalCount),
			CompletedCount: int32(p.CompletedCount),
			CurrentBinary: p.CurrentBinary,
			Done:          p.Done,
		}
		if p.Error != nil {
			msg.Error = p.Error.Error()
		}
		if err := stream.Send(msg); err != nil {
			return err
		}
	}

	return nil
}

func statusToProto(s orchestrator.BinaryStatus) *pb.BinaryStatusMsg {
	return &pb.BinaryStatusMsg{
		Name:           s.Name,
		DisplayName:    s.DisplayName,
		Running:        s.Running,
		Healthy:        s.Healthy,
		Pid:            int32(s.Pid),
		UptimeSeconds:  int64(s.Uptime.Seconds()),
		ChainLayer:     int32(s.ChainLayer),
		Port:           int32(s.Port),
		Error:          s.Error,
	}
}
