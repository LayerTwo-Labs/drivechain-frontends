package api

import (
	"context"
	"strings"

	"connectrpc.com/connect/v2"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func (h *Handler) PreviewECashMigration(ctx context.Context, req *pb.PreviewECashMigrationRequest) (*pb.PreviewECashMigrationResponse, error) {
	fromID, toID, err := ecashMigrationNetworks(req.FromId, req.ToId)
	if err != nil {
		return nil, err
	}
	status, err := h.orch.PreviewECashMigration(ctx, fromID, toID)
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	return &pb.PreviewECashMigrationResponse{Status: ecashMigrationStatusToProto(status)}, nil
}

func (h *Handler) StartECashMigration(ctx context.Context, req *pb.StartECashMigrationRequest) (*pb.StartECashMigrationResponse, error) {
	fromID, toID, err := ecashMigrationNetworks(req.FromId, req.ToId)
	if err != nil {
		return nil, err
	}
	status, err := h.orch.StartECashMigration(ctx, fromID, toID)
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	return &pb.StartECashMigrationResponse{Status: ecashMigrationStatusToProto(status)}, nil
}

func (h *Handler) GetECashMigrationStatus(_ context.Context, _ *pb.GetECashMigrationStatusRequest) (*pb.GetECashMigrationStatusResponse, error) {
	status, err := h.orch.ECashMigrationStatus()
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.GetECashMigrationStatusResponse{Status: ecashMigrationStatusToProto(status)}, nil
}

func ecashMigrationNetworks(fromID, toID string) (string, string, error) {
	fromID = strings.TrimSpace(fromID)
	toID = strings.TrimSpace(toID)
	if fromID == "" || toID == "" || fromID == toID {
		return "", "", connect.NewError(connect.CodeInvalidArgument, "select different source and target network IDs")
	}
	return fromID, toID, nil
}

func ecashMigrationStatusToProto(status orchestrator.ECashMigrationStatus) *pb.ECashMigrationStatus {
	return &pb.ECashMigrationStatus{
		JobId:           status.JobID,
		FromId:          status.FromID,
		ToId:            status.ToID,
		Phase:           status.Phase,
		DataDir:         status.DataDir,
		CommonHeight:    status.CommonHeight,
		CommonHash:      status.CommonHash,
		SourceMagic:     status.SourceMagic,
		TargetMagic:     status.TargetMagic,
		BlockFiles:      status.BlockFiles,
		UndoFiles:       status.UndoFiles,
		RecordsDone:     status.RecordsDone,
		RecordsTotal:    status.RecordsTotal,
		Running:         status.Running,
		Complete:        status.Complete,
		Error:           status.Error,
		SyncState:       status.SyncState,
		Pruned:          status.Pruned,
		PruneHeight:     status.PruneHeight,
		WalletOnly:      status.WalletOnly,
		BelowFork:       status.BelowFork,
		StartedAtUnix:   status.StartedAt,
		RecordStage:     status.RecordStage,
		DownloadMbDone:  status.DownloadMBDone,
		DownloadMbTotal: status.DownloadMBTotal,
	}
}
