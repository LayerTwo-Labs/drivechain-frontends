package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect/v2"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

var _ rpc.EnforcerConfServiceHandler = new(EnforcerConfHandler)

// EnforcerConfHandler implements the EnforcerConfService gRPC handler.
type EnforcerConfHandler struct {
	conf *config.EnforcerConfManager
}

func NewEnforcerConfHandler(conf *config.EnforcerConfManager) *EnforcerConfHandler {
	return &EnforcerConfHandler{conf: conf}
}

func (h *EnforcerConfHandler) GetEnforcerConfig(ctx context.Context, req *pb.GetEnforcerConfigRequest) (*pb.GetEnforcerConfigResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "enforcer config manager not initialized")
	}

	// Reload from disk to get latest state
	if err := h.conf.LoadConfig(); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", err).Error())
	}

	var configContent string
	if h.conf.Config != nil {
		configContent = h.conf.Config.Serialize()
	}

	return &pb.GetEnforcerConfigResponse{
		ConfigContent: configContent,
		ConfigPath:    h.conf.ConfigPath,
		// node-rpc-* are no longer persisted in enforcer.conf — they're
		// overlaid from bitcoin.conf at boot — so the file can never
		// "differ" from the live derivation. Hardcode false to keep the
		// proto field's wire shape without a proto change.
		NodeRpcDiffers:          false,
		DefaultConfig:           h.conf.GetDefaultConfig(),
		CliArgs:                 h.conf.GetCliArgs(),
		ExpectedNodeRpcSettings: h.conf.GetExpectedNodeRpcSettings(),
	}, nil
}

func (h *EnforcerConfHandler) WriteEnforcerConfig(ctx context.Context, req *pb.WriteEnforcerConfigRequest) (*pb.WriteEnforcerConfigResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "enforcer config manager not initialized")
	}

	h.conf.Config = config.ParseEnforcerConfig(req.ConfigContent)

	if err := h.conf.SaveConfig(); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save config: %w", err).Error())
	}

	return &pb.WriteEnforcerConfigResponse{}, nil
}

func (h *EnforcerConfHandler) SyncNodeRpcFromBitcoinConf(ctx context.Context, req *pb.SyncNodeRpcFromBitcoinConfRequest) (*pb.SyncNodeRpcFromBitcoinConfResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "enforcer config manager not initialized")
	}
	// No-op: node-rpc-* are now overlaid from bitcoin.conf at boot, so
	// there's nothing to sync into the persisted file. Kept callable so
	// older clients that still invoke this RPC don't error out.
	return &pb.SyncNodeRpcFromBitcoinConfResponse{}, nil
}
