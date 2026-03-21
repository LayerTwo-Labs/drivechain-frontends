package api

import (
	"context"

	"connectrpc.com/connect"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
)

var _ orchsvc.OrchestratorServiceHandler = new(OrchestratorWrapper)

// OrchestratorWrapper wraps the orchestrator handler to inject wallet starter args.
type OrchestratorWrapper struct {
	inner     orchsvc.OrchestratorServiceHandler
	walletSvc *wallet.Service
	log       zerolog.Logger
}

func NewOrchestratorWrapper(inner orchsvc.OrchestratorServiceHandler, walletSvc *wallet.Service, log zerolog.Logger) *OrchestratorWrapper {
	return &OrchestratorWrapper{
		inner:     inner,
		walletSvc: walletSvc,
		log:       log.With().Str("component", "orch-wrapper").Logger(),
	}
}

// StartWithDeps passes through to the inner handler.
func (w *OrchestratorWrapper) StartWithDeps(ctx context.Context, req *connect.Request[orchpb.StartWithDepsRequest], stream *connect.ServerStream[orchpb.StartWithDepsResponse]) error {
	return w.inner.StartWithDeps(ctx, req, stream)
}

// Pass-through methods

func (w *OrchestratorWrapper) ListBinaries(ctx context.Context, req *connect.Request[orchpb.ListBinariesRequest]) (*connect.Response[orchpb.ListBinariesResponse], error) {
	return w.inner.ListBinaries(ctx, req)
}

func (w *OrchestratorWrapper) GetBinaryStatus(ctx context.Context, req *connect.Request[orchpb.GetBinaryStatusRequest]) (*connect.Response[orchpb.GetBinaryStatusResponse], error) {
	return w.inner.GetBinaryStatus(ctx, req)
}

func (w *OrchestratorWrapper) DownloadBinary(ctx context.Context, req *connect.Request[orchpb.DownloadBinaryRequest], stream *connect.ServerStream[orchpb.DownloadBinaryResponse]) error {
	return w.inner.DownloadBinary(ctx, req, stream)
}

func (w *OrchestratorWrapper) StartBinary(ctx context.Context, req *connect.Request[orchpb.StartBinaryRequest]) (*connect.Response[orchpb.StartBinaryResponse], error) {
	return w.inner.StartBinary(ctx, req)
}

func (w *OrchestratorWrapper) StopBinary(ctx context.Context, req *connect.Request[orchpb.StopBinaryRequest]) (*connect.Response[orchpb.StopBinaryResponse], error) {
	return w.inner.StopBinary(ctx, req)
}

func (w *OrchestratorWrapper) WatchBinaries(ctx context.Context, req *connect.Request[orchpb.WatchBinariesRequest], stream *connect.ServerStream[orchpb.WatchBinariesResponse]) error {
	return w.inner.WatchBinaries(ctx, req, stream)
}

func (w *OrchestratorWrapper) StreamLogs(ctx context.Context, req *connect.Request[orchpb.StreamLogsRequest], stream *connect.ServerStream[orchpb.StreamLogsResponse]) error {
	return w.inner.StreamLogs(ctx, req, stream)
}

func (w *OrchestratorWrapper) ShutdownAll(ctx context.Context, req *connect.Request[orchpb.ShutdownAllRequest], stream *connect.ServerStream[orchpb.ShutdownAllResponse]) error {
	return w.inner.ShutdownAll(ctx, req, stream)
}

func (w *OrchestratorWrapper) GetBTCPrice(ctx context.Context, req *connect.Request[orchpb.GetBTCPriceRequest]) (*connect.Response[orchpb.GetBTCPriceResponse], error) {
	return w.inner.GetBTCPrice(ctx, req)
}

func (w *OrchestratorWrapper) GetMainchainBlockchainInfo(ctx context.Context, req *connect.Request[orchpb.GetMainchainBlockchainInfoRequest]) (*connect.Response[orchpb.GetMainchainBlockchainInfoResponse], error) {
	return w.inner.GetMainchainBlockchainInfo(ctx, req)
}

func (w *OrchestratorWrapper) GetEnforcerBlockchainInfo(ctx context.Context, req *connect.Request[orchpb.GetEnforcerBlockchainInfoRequest]) (*connect.Response[orchpb.GetEnforcerBlockchainInfoResponse], error) {
	return w.inner.GetEnforcerBlockchainInfo(ctx, req)
}

func (w *OrchestratorWrapper) GetMainchainBalance(ctx context.Context, req *connect.Request[orchpb.GetMainchainBalanceRequest]) (*connect.Response[orchpb.GetMainchainBalanceResponse], error) {
	return w.inner.GetMainchainBalance(ctx, req)
}
