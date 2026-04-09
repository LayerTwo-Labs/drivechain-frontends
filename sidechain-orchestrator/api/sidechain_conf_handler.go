package api

import (
	"context"
	"fmt"
	"strings"

	"connectrpc.com/connect"

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
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("unknown sidechain: %s", name))
	}
	return m, nil
}

func (h *SidechainConfHandler) GetSidechainConfig(ctx context.Context, req *connect.Request[pb.GetSidechainConfigRequest]) (*connect.Response[pb.GetSidechainConfigResponse], error) {
	m, err := h.getManager(req.Msg.SidechainName)
	if err != nil {
		return nil, err
	}

	if loadErr := m.LoadConfig(); loadErr != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", loadErr))
	}

	var configContent string
	if m.Config != nil {
		configContent = m.Config.Serialize()
	}

	return connect.NewResponse(&pb.GetSidechainConfigResponse{
		ConfigContent: configContent,
		ConfigPath:    m.ConfigPath,
		DefaultConfig: m.GetDefaultConfig(),
		CliArgs:       m.GetCliArgs(),
		Network:       m.GetNetwork(),
	}), nil
}

func (h *SidechainConfHandler) WriteSidechainConfig(ctx context.Context, req *connect.Request[pb.WriteSidechainConfigRequest]) (*connect.Response[pb.WriteSidechainConfigResponse], error) {
	m, err := h.getManager(req.Msg.SidechainName)
	if err != nil {
		return nil, err
	}

	if writeErr := m.WriteConfig(req.Msg.ConfigContent); writeErr != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("write config: %w", writeErr))
	}

	return connect.NewResponse(&pb.WriteSidechainConfigResponse{}), nil
}

func (h *SidechainConfHandler) SyncSidechainNetworkFromBitcoinConf(ctx context.Context, req *connect.Request[pb.SyncSidechainNetworkFromBitcoinConfRequest]) (*connect.Response[pb.SyncSidechainNetworkFromBitcoinConfResponse], error) {
	m, err := h.getManager(req.Msg.SidechainName)
	if err != nil {
		return nil, err
	}

	if syncErr := m.SyncNetworkFromBitcoinConf(); syncErr != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sync network: %w", syncErr))
	}

	return connect.NewResponse(&pb.SyncSidechainNetworkFromBitcoinConfResponse{}), nil
}
