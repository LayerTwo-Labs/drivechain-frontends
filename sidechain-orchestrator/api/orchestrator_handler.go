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
	// Send initial state immediately
	if err := h.sendBinaryStatuses(stream); err != nil {
		return err
	}

	// Debounce timer: batch rapid state changes into one send
	debounce := time.NewTimer(0)
	if !debounce.Stop() {
		<-debounce.C
	}
	pending := false

	// Fallback ticker: ensure state is sent at least every 5 seconds
	// even if no state changes are detected
	fallback := time.NewTicker(5 * time.Second)
	defer fallback.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()

		case <-h.orch.StateChanged:
			// State changed — start debounce if not already pending
			if !pending {
				debounce.Reset(50 * time.Millisecond)
				pending = true
			}

		case <-debounce.C:
			pending = false
			if err := h.sendBinaryStatuses(stream); err != nil {
				return err
			}

		case <-fallback.C:
			if err := h.sendBinaryStatuses(stream); err != nil {
				return err
			}
		}
	}
}

func (h *Handler) sendBinaryStatuses(stream *connect.ServerStream[pb.WatchBinariesResponse]) error {
	statuses := h.orch.ListAll()
	pbStatuses := make([]*pb.BinaryStatusMsg, len(statuses))
	for i, s := range statuses {
		pbStatuses[i] = statusToProto(s)
	}
	return stream.Send(&pb.WatchBinariesResponse{
		Binaries: pbStatuses,
	})
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

func (h *Handler) StartWithL1(ctx context.Context, req *connect.Request[pb.StartWithL1Request], stream *connect.ServerStream[pb.StartWithL1Response]) error {
	ch, err := h.orch.StartWithL1(ctx, req.Msg.Target, orchestrator.StartOpts{
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
		msg := &pb.StartWithL1Response{
			Stage:           p.Stage,
			Message:         p.Message,
			Done:            p.Done,
			BytesDownloaded: p.BytesDownloaded,
			TotalBytes:      p.TotalBytes,
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

func (h *Handler) GetBTCPrice(ctx context.Context, req *connect.Request[pb.GetBTCPriceRequest]) (*connect.Response[pb.GetBTCPriceResponse], error) {
	price, updatedAt, err := h.orch.GetBTCPrice()
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBTCPriceResponse{
		Btcusd:          price,
		LastUpdatedUnix: updatedAt.Unix(),
	}), nil
}

func (h *Handler) GetMainchainBlockchainInfo(ctx context.Context, req *connect.Request[pb.GetMainchainBlockchainInfoRequest]) (*connect.Response[pb.GetMainchainBlockchainInfoResponse], error) {
	info, err := h.orch.GetMainchainBlockchainInfo(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetMainchainBlockchainInfoResponse{
		Chain:                info.Chain,
		Blocks:               int32(info.Blocks),
		Headers:              int32(info.Headers),
		BestBlockHash:        info.BestBlockHash,
		Difficulty:           info.Difficulty,
		Time:                 info.Time,
		MedianTime:           info.MedianTime,
		VerificationProgress: info.VerificationProgress,
		InitialBlockDownload: info.InitialBlockDownload,
		ChainWork:            info.ChainWork,
		SizeOnDisk:           info.SizeOnDisk,
		Pruned:               info.Pruned,
	}), nil
}

func (h *Handler) GetEnforcerBlockchainInfo(ctx context.Context, req *connect.Request[pb.GetEnforcerBlockchainInfoRequest]) (*connect.Response[pb.GetEnforcerBlockchainInfoResponse], error) {
	info, err := h.orch.GetEnforcerBlockchainInfo(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetEnforcerBlockchainInfoResponse{
		Blocks:  int32(info.Blocks),
		Headers: int32(info.Headers),
		Time:    info.Time,
	}), nil
}

func (h *Handler) GetMainchainBalance(ctx context.Context, req *connect.Request[pb.GetMainchainBalanceRequest]) (*connect.Response[pb.GetMainchainBalanceResponse], error) {
	bal, err := h.orch.GetMainchainBalance(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetMainchainBalanceResponse{
		Confirmed:   bal.Confirmed,
		Unconfirmed: bal.Unconfirmed,
	}), nil
}

func (h *Handler) ResetData(ctx context.Context, req *connect.Request[pb.ResetDataRequest]) (*connect.Response[pb.ResetDataResponse], error) {
	result, err := h.orch.ResetData(ctx, orchestrator.ResetCategory{
		DeleteBlockchainData: req.Msg.DeleteBlockchainData,
		DeleteNodeSoftware:   req.Msg.DeleteNodeSoftware,
		DeleteLogs:           req.Msg.DeleteLogs,
		DeleteSettings:       req.Msg.DeleteSettings,
		DeleteWalletFiles:    req.Msg.DeleteWalletFiles,
		AlsoResetSidechains:  req.Msg.AlsoResetSidechains,
	})
	if result == nil && err != nil {
		return nil, err
	}

	resp := &pb.ResetDataResponse{}
	for _, item := range result.DeletedItems {
		resp.DeletedItems = append(resp.DeletedItems, &pb.ResetDeletedItem{
			Path: item.Path,
		})
	}
	for _, item := range result.FailedItems {
		resp.FailedItems = append(resp.FailedItems, &pb.ResetDeletedItem{
			Path:  item.Path,
			Error: item.Error,
		})
	}

	if err != nil {
		// Return partial results with the error attached.
		return connect.NewResponse(resp), err
	}
	return connect.NewResponse(resp), nil
}

func statusToProto(s orchestrator.BinaryStatus) *pb.BinaryStatusMsg {
	startupLogs := make([]*pb.StartupLogEntryMsg, len(s.StartupLogs))
	for i, l := range s.StartupLogs {
		startupLogs[i] = &pb.StartupLogEntryMsg{
			TimestampUnix: l.Timestamp.Unix(),
			Message:       l.Message,
		}
	}

	return &pb.BinaryStatusMsg{
		Name:            s.Name,
		DisplayName:     s.DisplayName,
		Running:         s.Running,
		Healthy:         s.Healthy,
		Pid:             int32(s.Pid),
		UptimeSeconds:   int64(s.Uptime.Seconds()),
		ChainLayer:      int32(s.ChainLayer),
		Port:            int32(s.Port),
		Error:           s.Error,
		Connected:       s.Connected,
		StartupError:    s.StartupError,
		ConnectionError: s.ConnectionError,
		Stopping:        s.Stopping,
		Initializing:    s.Initializing,
		ConnectModeOnly: s.ConnectModeOnly,
		Downloadable:    s.Downloadable,
		Description:     s.Description,
		Downloaded:      s.Downloaded,
		PortInUse:       s.PortInUse,
		Version:         s.Version,
		RepoUrl:         s.RepoURL,
		StartupLogs:     startupLogs,
	}
}
