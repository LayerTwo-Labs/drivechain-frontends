package api

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"connectrpc.com/connect"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

var _ rpc.BitcoinConfServiceHandler = new(BitcoinConfHandler)

// BitcoinConfHandler implements the BitcoinConfService gRPC handler.
type BitcoinConfHandler struct {
	orch *orchestrator.Orchestrator
	conf *config.BitcoinConfManager
}

func NewBitcoinConfHandler(orch *orchestrator.Orchestrator) *BitcoinConfHandler {
	return &BitcoinConfHandler{orch: orch, conf: orch.BitcoinConf}
}

func (h *BitcoinConfHandler) GetBitcoinConfig(ctx context.Context, req *connect.Request[pb.GetBitcoinConfigRequest]) (*connect.Response[pb.GetBitcoinConfigResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bitcoin config manager not initialized"))
	}

	// Reload from disk to get latest state
	if err := h.conf.LoadConfig(false); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", err))
	}

	network := h.conf.Network
	networkSupportsSidechains := network == config.NetworkForknet ||
		network == config.NetworkSignet ||
		network == config.NetworkRegtest

	var configContent, rpcUser, rpcPassword, defaultDatadir, forknetDatadir string
	if h.conf.Config != nil {
		configContent = h.conf.Config.Serialize()
		section := h.conf.Network.CoreSection()
		rpcUser = h.conf.Config.GetEffectiveSetting("rpcuser", section)
		rpcPassword = h.conf.Config.GetEffectiveSetting("rpcpassword", section)
		defaultDatadir = h.conf.Config.GetGroupDatadir(config.DatadirGroupDefault)
		forknetDatadir = h.conf.Config.GetGroupDatadir(config.DatadirGroupForknet)
		// If the active group has a live datadir but no slot recorded yet
		// (fresh install or hand-edited conf), surface the live value as
		// the active slot so the UI doesn't claim "no datadir set".
		activeGroup := config.DatadirGroupForNetwork(h.conf.Network)
		if liveDatadir := h.conf.Config.GetSetting("datadir"); liveDatadir != "" {
			if activeGroup == config.DatadirGroupDefault && defaultDatadir == "" {
				defaultDatadir = liveDatadir
			}
			if activeGroup == config.DatadirGroupForknet && forknetDatadir == "" {
				forknetDatadir = liveDatadir
			}
		}
	}

	return connect.NewResponse(&pb.GetBitcoinConfigResponse{
		Network:                   string(network),
		RpcPort:                   int32(h.conf.GetRPCPort()),
		HasPrivateConf:            h.conf.HasPrivateConf,
		ConfigPath:                h.conf.ConfigPath,
		DetectedDataDir:           h.conf.DetectedDataDir,
		ConfigContent:             configContent,
		NetworkSupportsSidechains: networkSupportsSidechains,
		IsDemoMode:                network == config.NetworkMainnet,
		RpcUser:                   rpcUser,
		RpcPassword:               rpcPassword,
		DefaultDatadir:            defaultDatadir,
		ForknetDatadir:            forknetDatadir,
	}), nil
}

func (h *BitcoinConfHandler) SetBitcoinConfigNetwork(ctx context.Context, req *connect.Request[pb.SetBitcoinConfigNetworkRequest]) (*connect.Response[pb.SetBitcoinConfigNetworkResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bitcoin config manager not initialized"))
	}

	networkStr := strings.TrimSpace(req.Msg.Network)
	if networkStr == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("network is required"))
	}

	network := config.NetworkFromString(networkStr)

	// Guard: mainnet/forknet need a datadir set up before we switch. Surface
	// a FailedPrecondition so the frontend can prompt the user to pick one.
	if !h.conf.HasDatadirForNetwork(network) {
		return nil, connect.NewError(
			connect.CodeFailedPrecondition,
			fmt.Errorf("datadir not configured for %s", network),
		)
	}

	if err := h.orch.SwapNetwork(ctx, network); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("swap network: %w", err))
	}

	return connect.NewResponse(&pb.SetBitcoinConfigNetworkResponse{}), nil
}

func (h *BitcoinConfHandler) WriteBitcoinConfig(ctx context.Context, req *connect.Request[pb.WriteBitcoinConfigRequest]) (*connect.Response[pb.WriteBitcoinConfigResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bitcoin config manager not initialized"))
	}

	if err := h.conf.WriteConfig(req.Msg.ConfigContent); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("write config: %w", err))
	}

	// Reload to pick up changes
	if err := h.conf.LoadConfig(false); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", err))
	}

	return connect.NewResponse(&pb.WriteBitcoinConfigResponse{}), nil
}

func (h *BitcoinConfHandler) SetBitcoinConfigDataDir(ctx context.Context, req *connect.Request[pb.SetBitcoinConfigDataDirRequest]) (*connect.Response[pb.SetBitcoinConfigDataDirResponse], error) {
	if h.conf == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("bitcoin config manager not initialized"))
	}

	networkStr := strings.TrimSpace(req.Msg.Network)
	if networkStr == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("network is required"))
	}
	forNetwork := config.NetworkFromString(networkStr)

	dataDir := strings.TrimSpace(req.Msg.DataDir)

	// Validate writability when setting (not clearing) a datadir.
	if dataDir != "" {
		if err := validateDirWritable(dataDir); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("directory not writable: %w", err))
		}
	}

	if err := h.conf.UpdateDataDir(dataDir, forNetwork); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("update datadir: %w", err))
	}

	return connect.NewResponse(&pb.SetBitcoinConfigDataDirResponse{}), nil
}

// validateDirWritable creates and removes a probe file to confirm the
// directory exists and is writable by the current process.
func validateDirWritable(dir string) error {
	probe := filepath.Join(dir, ".bitwindow_test")
	if err := os.WriteFile(probe, []byte("test"), 0o644); err != nil {
		return err
	}
	return os.Remove(probe)
}
