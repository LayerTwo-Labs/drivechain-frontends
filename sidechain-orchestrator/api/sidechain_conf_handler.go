package api

import (
	"context"
	"fmt"
	"strings"

	"connectrpc.com/connect/v2"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

var _ rpc.SidechainConfServiceHandler = new(SidechainConfHandler)

// SidechainConfHandler implements the generic SidechainConfService gRPC handler.
// Routes requests to the correct SidechainConfManager based on sidechain_name.
type SidechainConfHandler struct {
	managers map[string]*config.SidechainConfManager
}

func NewSidechainConfHandler(managers map[string]*config.SidechainConfManager) *SidechainConfHandler {
	return &SidechainConfHandler{managers: managers}
}

func (h *SidechainConfHandler) getManager(name string) (*config.SidechainConfManager, error) {
	key := strings.ToLower(name)
	m, ok := h.managers[key]
	if !ok {
		return nil, connect.Errorf(connect.CodeNotFound, "unknown sidechain: %s", name)
	}
	return m, nil
}

func (h *SidechainConfHandler) GetSidechainConfig(ctx context.Context, req *pb.GetSidechainConfigRequest) (*pb.GetSidechainConfigResponse, error) {
	m, err := h.getManager(req.SidechainName)
	if err != nil {
		return nil, err
	}

	if loadErr := m.LoadConfig(); loadErr != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", loadErr).Error())
	}

	var configContent string
	if m.Config != nil {
		configContent = m.Config.Serialize()
	}

	return &pb.GetSidechainConfigResponse{
		ConfigContent: configContent,
		ConfigPath:    m.ConfigPath,
		DefaultConfig: m.GetDefaultConfig(),
		CliArgs:       m.GetCliArgs(),
		Network:       m.GetNetwork(),
	}, nil
}

func (h *SidechainConfHandler) WriteSidechainConfig(ctx context.Context, req *pb.WriteSidechainConfigRequest) (*pb.WriteSidechainConfigResponse, error) {
	m, err := h.getManager(req.SidechainName)
	if err != nil {
		return nil, err
	}

	if writeErr := m.WriteConfig(req.ConfigContent); writeErr != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("write config: %w", writeErr).Error())
	}

	return &pb.WriteSidechainConfigResponse{}, nil
}

func (h *SidechainConfHandler) SyncSidechainNetworkFromBitcoinConf(ctx context.Context, req *pb.SyncSidechainNetworkFromBitcoinConfRequest) (*pb.SyncSidechainNetworkFromBitcoinConfResponse, error) {
	m, err := h.getManager(req.SidechainName)
	if err != nil {
		return nil, err
	}

	if syncErr := m.SyncNetworkFromBitcoinConf(); syncErr != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sync network: %w", syncErr).Error())
	}

	return &pb.SyncSidechainNetworkFromBitcoinConfResponse{}, nil
}
