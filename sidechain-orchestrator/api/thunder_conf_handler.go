package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

var _ rpc.ThunderConfServiceHandler = new(ThunderConfHandler)

// ThunderConfHandler implements the ThunderConfService gRPC handler.
// 1:1 port of GenericSidechainConfProvider pattern for Thunder.
type ThunderConfHandler struct {
	conf *config.ThunderConfManager
}

func NewThunderConfHandler(conf *config.ThunderConfManager) *ThunderConfHandler {
	return &ThunderConfHandler{conf: conf}
}

func (h *ThunderConfHandler) GetThunderConfig(ctx context.Context, req *connect.Request[pb.GetThunderConfigRequest]) (*connect.Response[pb.GetThunderConfigResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("thunder config manager not initialized"))
	}

	// Reload from disk to get latest state
	if err := h.conf.LoadConfig(); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", err))
	}

	var configContent string
	if h.conf.Config != nil {
		configContent = h.conf.Config.Serialize()
	}

	return connect.NewResponse(&pb.GetThunderConfigResponse{
		ConfigContent: configContent,
		ConfigPath:    h.conf.ConfigPath,
		DefaultConfig: h.conf.GetDefaultConfig(),
		CliArgs:       h.conf.GetCliArgs(),
		Network:       h.conf.GetNetwork(),
	}), nil
}

func (h *ThunderConfHandler) WriteThunderConfig(ctx context.Context, req *connect.Request[pb.WriteThunderConfigRequest]) (*connect.Response[pb.WriteThunderConfigResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("thunder config manager not initialized"))
	}

	if err := h.conf.WriteConfig(req.Msg.ConfigContent); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("write config: %w", err))
	}

	return connect.NewResponse(&pb.WriteThunderConfigResponse{}), nil
}

func (h *ThunderConfHandler) SyncNetworkFromBitcoinConf(ctx context.Context, req *connect.Request[pb.SyncNetworkFromBitcoinConfRequest]) (*connect.Response[pb.SyncNetworkFromBitcoinConfResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("thunder config manager not initialized"))
	}

	if err := h.conf.SyncNetworkFromBitcoinConf(); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sync network: %w", err))
	}

	return connect.NewResponse(&pb.SyncNetworkFromBitcoinConfResponse{}), nil
}
