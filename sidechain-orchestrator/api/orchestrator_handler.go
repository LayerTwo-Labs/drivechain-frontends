package api

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"

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
			TotalCount:     int32(p.TotalCount),
			CompletedCount: int32(p.CompletedCount),
			CurrentBinary:  p.CurrentBinary,
			Done:           p.Done,
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

// GetEnforcerBlockchainInfo is a thin compatibility shim over the new
// GetSyncStatus path. Frontends should migrate to GetSyncStatus directly.
func (h *Handler) GetEnforcerBlockchainInfo(ctx context.Context, req *connect.Request[pb.GetEnforcerBlockchainInfoRequest]) (*connect.Response[pb.GetEnforcerBlockchainInfoResponse], error) {
	s, err := h.orch.GetSyncStatus(ctx, "")
	if err != nil {
		return nil, err
	}
	enf := s.Enforcer
	if enf == nil || enf.Error != "" {
		return connect.NewResponse(&pb.GetEnforcerBlockchainInfoResponse{}), nil
	}
	return connect.NewResponse(&pb.GetEnforcerBlockchainInfoResponse{
		Blocks:  int32(enf.Blocks),
		Headers: int32(enf.Headers),
		Time:    enf.Time,
	}), nil
}

func (h *Handler) GetSyncStatus(ctx context.Context, req *connect.Request[pb.GetSyncStatusRequest]) (*connect.Response[pb.GetSyncStatusResponse], error) {
	s, err := h.orch.GetSyncStatus(ctx, req.Msg.Sidechain)
	if err != nil {
		return nil, err
	}
	out := &pb.GetSyncStatusResponse{
		Mainchain: chainSyncToProto(s.Mainchain),
		Enforcer:  chainSyncToProto(s.Enforcer),
	}
	if s.Sidechain != nil {
		out.Sidechain = chainSyncToProto(s.Sidechain)
	}
	return connect.NewResponse(out), nil
}

func chainSyncToProto(s *orchestrator.ChainSyncResult) *pb.ChainSync {
	if s == nil {
		return nil
	}
	return &pb.ChainSync{
		Blocks:  int32(s.Blocks),
		Headers: int32(s.Headers),
		Time:    s.Time,
		Error:   s.Error,
	}
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

func (h *Handler) PreviewResetData(ctx context.Context, req *connect.Request[pb.PreviewResetDataRequest]) (*connect.Response[pb.PreviewResetDataResponse], error) {
	files, err := h.orch.PreviewResetData(orchestrator.ResetCategory{
		DeleteBlockchainData: req.Msg.DeleteBlockchainData,
		DeleteNodeSoftware:   req.Msg.DeleteNodeSoftware,
		DeleteLogs:           req.Msg.DeleteLogs,
		DeleteSettings:       req.Msg.DeleteSettings,
		DeleteWalletFiles:    req.Msg.DeleteWalletFiles,
		AlsoResetSidechains:  req.Msg.AlsoResetSidechains,
	})
	if err != nil {
		return nil, err
	}

	resp := &pb.PreviewResetDataResponse{}
	for _, f := range files {
		resp.Files = append(resp.Files, &pb.ResetFileInfo{
			Path:        f.Path,
			Category:    f.Category,
			SizeBytes:   f.SizeBytes,
			IsDirectory: f.IsDirectory,
		})
	}
	return connect.NewResponse(resp), nil
}

func (h *Handler) StreamResetData(ctx context.Context, req *connect.Request[pb.StreamResetDataRequest], stream *connect.ServerStream[pb.StreamResetDataResponse]) error {
	ch, err := h.orch.StreamResetData(ctx, orchestrator.ResetCategory{
		DeleteBlockchainData: req.Msg.DeleteBlockchainData,
		DeleteNodeSoftware:   req.Msg.DeleteNodeSoftware,
		DeleteLogs:           req.Msg.DeleteLogs,
		DeleteSettings:       req.Msg.DeleteSettings,
		DeleteWalletFiles:    req.Msg.DeleteWalletFiles,
		AlsoResetSidechains:  req.Msg.AlsoResetSidechains,
	})
	if err != nil {
		return err
	}

	for evt := range ch {
		msg := &pb.StreamResetDataResponse{
			Path:         evt.Path,
			Category:     evt.Category,
			Success:      evt.Success,
			Error:        evt.Error,
			Done:         evt.Done,
			DeletedCount: int32(evt.DeletedCount),
			FailedCount:  int32(evt.FailedCount),
		}
		if err := stream.Send(msg); err != nil {
			return err
		}
	}

	return nil
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
		BinaryPath:      s.BinaryPath,
		PortInUse:       s.PortInUse,
		Version:         s.Version,
		RepoUrl:         s.RepoURL,
		StartupLogs:     startupLogs,
	}
}

// ─── Bitcoin Core typed extensions ─────────────────────────────────────────
//
// Direct JSON-RPC to bitcoind for methods btc-buf doesn't type
// (getmempoolinfo, finalizepsbt, descriptorprocesspsbt, …). Credentials come
// from the orchestrator's BitcoinConf, which it already loads at startup.

type coreRPCResult struct {
	Result json.RawMessage `json:"result"`
	Error  *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func (h *Handler) callCoreRPC(ctx context.Context, method, paramsJSON, wallet string) (json.RawMessage, error) {
	if h.orch.BitcoinConf == nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("bitcoin conf not loaded"))
	}

	port := h.orch.BitcoinConf.GetRPCPort()
	var user, password string
	if h.orch.BitcoinConf.Config != nil {
		section := h.orch.BitcoinConf.Network.CoreSection()
		user = h.orch.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
		password = h.orch.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
	}

	if paramsJSON == "" {
		paramsJSON = "[]"
	}
	body := []byte(fmt.Sprintf(`{"jsonrpc":"1.0","id":"orchestratord","method":%q,"params":%s}`, method, paramsJSON))

	url := fmt.Sprintf("http://localhost:%d", port)
	if wallet != "" {
		url = strings.TrimRight(url, "/") + "/wallet/" + wallet
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("build %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")
	if user != "" {
		req.SetBasicAuth(user, password)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", method, err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read %s response: %w", method, err)
	}

	var out coreRPCResult
	if jerr := json.Unmarshal(respBody, &out); jerr != nil {
		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("%s: HTTP %d", method, resp.StatusCode)
		}
		return nil, fmt.Errorf("decode %s: %w", method, jerr)
	}
	if out.Error != nil {
		return nil, fmt.Errorf("%s: %s", method, out.Error.Message)
	}
	return out.Result, nil
}

func (h *Handler) GetCoreMempoolInfo(ctx context.Context, _ *connect.Request[pb.GetCoreMempoolInfoRequest]) (*connect.Response[pb.GetCoreMempoolInfoResponse], error) {
	raw, err := h.callCoreRPC(ctx, "getmempoolinfo", "[]", "")
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	var info struct {
		Loaded              bool    `json:"loaded"`
		Size                int64   `json:"size"`
		Bytes               int64   `json:"bytes"`
		Usage               int64   `json:"usage"`
		TotalFee            float64 `json:"total_fee"`
		MaxMempool          int64   `json:"maxmempool"`
		MempoolMinFee       float64 `json:"mempoolminfee"`
		MinRelayTxFee       float64 `json:"minrelaytxfee"`
		IncrementalRelayFee float64 `json:"incrementalrelayfee"`
		UnbroadcastCount    int64   `json:"unbroadcastcount"`
		FullRBF             bool    `json:"fullrbf"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode getmempoolinfo: %w", err))
	}
	return connect.NewResponse(&pb.GetCoreMempoolInfoResponse{
		Loaded:              info.Loaded,
		Size:                info.Size,
		Bytes:               info.Bytes,
		Usage:               info.Usage,
		TotalFee:            info.TotalFee,
		MaxMempool:          info.MaxMempool,
		MempoolMinFee:       info.MempoolMinFee,
		MinRelayTxFee:       info.MinRelayTxFee,
		IncrementalRelayFee: info.IncrementalRelayFee,
		UnbroadcastCount:    info.UnbroadcastCount,
		FullRbf:             info.FullRBF,
	}), nil
}

func (h *Handler) CoreRawCall(ctx context.Context, req *connect.Request[pb.CoreRawCallRequest]) (*connect.Response[pb.CoreRawCallResponse], error) {
	raw, err := h.callCoreRPC(ctx, req.Msg.Method, req.Msg.ParamsJson, req.Msg.Wallet)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.CoreRawCallResponse{ResultJson: string(raw)}), nil
}
