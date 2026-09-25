package api

import (
	"context"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func (h *Handler) GetDatadirNetwork(ctx context.Context, _ *connect.Request[pb.GetDatadirNetworkRequest]) (*connect.Response[pb.GetDatadirNetworkResponse], error) {
	out, err := h.orch.ReadDatadirNetwork(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	return connect.NewResponse(&pb.GetDatadirNetworkResponse{
		Magic:             out.Magic,
		DetectedId:        out.DetectedID,
		DetectedName:      out.DetectedName,
		SelectedId:        out.SelectedID,
		SelectedName:      out.SelectedName,
		Mismatch:          out.Mismatch,
		SwitchReadsBlocks: out.SwitchReadsBlocks,
	}), nil
}
