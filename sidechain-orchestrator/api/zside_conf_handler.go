package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

var _ rpc.ZSideConfServiceHandler = new(ZSideConfHandler)

// ZSideConfHandler implements the ZSideConfService gRPC handler.
type ZSideConfHandler struct {
	conf *config.ZSideConfManager
}

func NewZSideConfHandler(conf *config.ZSideConfManager) *ZSideConfHandler {
	return &ZSideConfHandler{conf: conf}
}

func (h *ZSideConfHandler) GetZSideConfig(ctx context.Context, req *connect.Request[pb.GetZSideConfigRequest]) (*connect.Response[pb.GetZSideConfigResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("zside config manager not initialized"))
	}

	// Reload from disk to get latest state
	if err := h.conf.LoadConfig(); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", err))
	}

	var configContent string
	if h.conf.Config != nil {
		configContent = h.conf.Config.Serialize()
	}

	return connect.NewResponse(&pb.GetZSideConfigResponse{
		ConfigContent: configContent,
		ConfigPath:    h.conf.ConfigPath,
		DefaultConfig: h.conf.GetDefaultConfig(),
		CliArgs:       h.conf.GetCliArgs(),
		Network:       h.conf.GetNetwork(),
	}), nil
}

func (h *ZSideConfHandler) WriteZSideConfig(ctx context.Context, req *connect.Request[pb.WriteZSideConfigRequest]) (*connect.Response[pb.WriteZSideConfigResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("zside config manager not initialized"))
	}

	if err := h.conf.WriteConfig(req.Msg.ConfigContent); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("write config: %w", err))
	}

	return connect.NewResponse(&pb.WriteZSideConfigResponse{}), nil
}

func (h *ZSideConfHandler) SyncNetworkFromBitcoinConf(ctx context.Context, req *connect.Request[pb.ZSideSyncNetworkFromBitcoinConfRequest]) (*connect.Response[pb.ZSideSyncNetworkFromBitcoinConfResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("zside config manager not initialized"))
	}

	if err := h.conf.SyncNetworkFromBitcoinConf(); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sync network: %w", err))
	}

	return connect.NewResponse(&pb.ZSideSyncNetworkFromBitcoinConfResponse{}), nil
}
