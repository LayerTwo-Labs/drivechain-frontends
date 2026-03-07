package api

import (
	"context"
	"fmt"

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

// StartWithDeps intercepts the call to inject wallet starter files as binary args.
func (w *OrchestratorWrapper) StartWithDeps(ctx context.Context, req *connect.Request[orchpb.StartWithDepsRequest], stream *connect.ServerStream[orchpb.StartWithDepsResponse]) error {
	if !w.walletSvc.IsUnlocked() && !w.walletSvc.HasWallet() {
		// No wallet yet - pass through without starter injection
		w.log.Debug().Msg("no wallet available, passing through StartWithDeps")
		return w.inner.StartWithDeps(ctx, req, stream)
	}

	if w.walletSvc.HasWallet() && w.walletSvc.IsUnlocked() {
		// Inject enforcer L1 starter
		l1Path, err := w.walletSvc.WriteL1Starter()
		if err != nil {
			w.log.Warn().Err(err).Msg("failed to write L1 starter, continuing without")
		} else {
			req.Msg.EnforcerArgs = append(req.Msg.EnforcerArgs, fmt.Sprintf("--wallet-seed-file=%s", l1Path))
			w.log.Info().Str("path", l1Path).Msg("injected L1 starter for enforcer")
		}

		// Inject thunder sidechain starter (slot 9)
		scPath, err := w.walletSvc.WriteSidechainStarter(9)
		if err != nil {
			w.log.Warn().Err(err).Msg("failed to write sidechain starter, continuing without")
		} else {
			req.Msg.TargetArgs = append(req.Msg.TargetArgs, fmt.Sprintf("--mnemonic-seed-phrase-path=%s", scPath))
			w.log.Info().Str("path", scPath).Msg("injected sidechain starter for thunder")
		}
	}

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
