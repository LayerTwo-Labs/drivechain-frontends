package api

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"connectrpc.com/connect/v2"

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

func (h *BitcoinConfHandler) GetBitcoinConfig(ctx context.Context, req *pb.GetBitcoinConfigRequest) (*pb.GetBitcoinConfigResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "bitcoin config manager not initialized")
	}

	// Reload from disk to get latest state
	if err := h.conf.LoadConfig(false); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("reload config: %w", err).Error())
	}

	network := h.conf.Network
	networkSupportsSidechains := network == config.NetworkECash ||
		network == config.NetworkSignet ||
		network == config.NetworkRegtest

	// Resolved, not raw: consumers use these to authenticate to Core, so on a
	// cookie-authenticated install the raw settings are empty and they must
	// get the cookie pair instead. Empty when Core is not up yet.
	rpcUser, rpcPassword, err := h.conf.GetRPCCredentials()
	if err != nil {
		rpcUser, rpcPassword = "", ""
	}

	var configContent, defaultDatadir, ecashDatadir string
	if h.conf.Config != nil {
		configContent = h.conf.Config.Serialize()
		defaultDatadir = h.conf.Config.GetGroupDatadir(config.DatadirGroupDefault)
		ecashDatadir = h.conf.Config.GetGroupDatadir(config.DatadirGroupECash)
		// If the active group has a live datadir but no slot recorded yet
		// (fresh install or hand-edited conf), surface the live value as
		// the active slot so the UI doesn't claim "no datadir set".
		activeGroup := config.DatadirGroupForNetwork(h.conf.Network)
		if liveDatadir := h.conf.Config.GetSetting("datadir"); liveDatadir != "" {
			if activeGroup == config.DatadirGroupDefault && defaultDatadir == "" {
				defaultDatadir = liveDatadir
			}
			if activeGroup == config.DatadirGroupECash && ecashDatadir == "" {
				ecashDatadir = liveDatadir
			}
		}
	}

	return &pb.GetBitcoinConfigResponse{
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
		EcashDatadir:              ecashDatadir,
		EcashNetworkId:            config.ECashNetworkID(),
		EcashEsploraUrl:           config.EsploraURLForNetwork(config.NetworkECash),
		EcashExplorerHost:         config.ECashExplorerHost(),
		MustSelectDatadir:         h.orch.PlanNetworkChange(orchestrator.NetworkChangeRequest{}).MustSelectDatadir,
	}, nil
}

func (h *BitcoinConfHandler) PrepareNetworkChange(ctx context.Context, req *pb.PrepareNetworkChangeRequest) (*pb.NetworkChangePlan, error) {
	network := strings.TrimSpace(req.Network)
	if _, known := h.orch.NetworkForOption(network); !known {
		if _, named := config.LookupNetwork(network); network != "" && !named {
			return nil, connect.Errorf(connect.CodeInvalidArgument, "unknown network %q", network)
		}
	}
	plan := h.orch.PlanNetworkChange(orchestrator.NetworkChangeRequest{
		Network:       network,
		WalletBackend: walletBackendFromProto(req.WalletBackend),
		WalletID:      strings.TrimSpace(req.WalletId),
	})
	return networkChangePlanToProto(plan), nil
}

func (h *BitcoinConfHandler) ListNetworks(ctx context.Context, req *pb.ListNetworksRequest) (*pb.ListNetworksResponse, error) {
	return &pb.ListNetworksResponse{Networks: networkOptionsToProto(h.orch.ListNetworks())}, nil
}

func networkOptionsToProto(options []orchestrator.NetworkOption) []*pb.NetworkOption {
	rows := make([]*pb.NetworkOption, 0, len(options))
	for _, o := range options {
		rows = append(rows, &pb.NetworkOption{
			Id:          o.ID,
			DisplayName: o.DisplayName,
			Network:     string(o.Network),
			IsCurrent:   o.IsCurrent,
		})
	}
	return rows
}

func (h *BitcoinConfHandler) TakeNewNetworks(ctx context.Context, req *pb.TakeNewNetworksRequest) (*pb.TakeNewNetworksResponse, error) {
	return &pb.TakeNewNetworksResponse{Networks: networkOptionsToProto(h.orch.TakeNewNetworks())}, nil
}

func (h *BitcoinConfHandler) PlanECashSwitch(ctx context.Context, req *pb.PlanECashSwitchRequest) (*pb.PlanECashSwitchResponse, error) {
	plan, err := h.orch.PlanECashSwitch(strings.TrimSpace(req.NetworkId))
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	return &pb.PlanECashSwitchResponse{
		FromId:        plan.FromID,
		ToId:          plan.ToID,
		RewindHeight:  plan.RewindHeight,
		NeedsRollback: plan.NeedsRollback,
		Blocked:       plan.Blocked,
		HasChainData:  plan.HasChainData,
		ChainId:       plan.ChainID,
	}, nil
}

func (h *BitcoinConfHandler) SetBitcoinConfigNetwork(ctx context.Context, req *pb.SetBitcoinConfigNetworkRequest) (*pb.SetBitcoinConfigNetworkResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "bitcoin config manager not initialized")
	}

	selection := strings.TrimSpace(req.Network)
	if selection == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "network is required")
	}

	network, ok := h.orch.NetworkForOption(selection)
	if !ok {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "unknown network %q", selection)
	}
	networkStr := string(network)

	if dataDir := strings.TrimSpace(req.DataDir); dataDir != "" {
		if err := validateDirWritable(dataDir); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("directory not writable: %w", err).Error())
		}
		if err := h.orch.EditBitcoinConfig(func() error {
			return h.conf.UpdateDataDir(dataDir, network)
		}); err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("update datadir: %w", err).Error())
		}
	}

	if _, known := config.LookupNetwork(networkStr); networkStr != "" && !known {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "unknown network %q", networkStr)
	}
	// Apply is authoritative: re-plan so a stale prepare can't smuggle through a
	// requirement the user never resolved.
	plan := h.orch.PlanNetworkChange(orchestrator.NetworkChangeRequest{Network: networkStr})
	if plan.MustSelectDatadir {
		return nil, requirementsUnmet(plan)
	}

	// The picker sends a catalog id, and the eCash rows all share one slot, so
	// the id is the only thing that says which fork to boot. This runs only
	// once every requirement passes: the pick clears the retired chain, and a
	// request the RPC goes on to refuse must leave that chain alone.
	previousECashID := ""
	if network == config.NetworkECash {
		onECash := config.NetworkFromString(h.orch.CurrentNetwork()) == config.NetworkECash
		ecashPlan, planErr := h.orch.PlanECashSwitch(selection)
		// A move between two eCash networks changes no slot, so the swap below
		// would see no work. Only that case runs the rewind, and only from a
		// live chain; from another network the pick alone is the change.
		if onECash && planErr == nil && ecashPlan.FromID != "" && ecashPlan.FromID != ecashPlan.ToID {
			if err := h.orch.ApplyECashSwitch(ctx, selection); err != nil {
				return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("switch ecash network: %w", err).Error())
			}
			return &pb.SetBitcoinConfigNetworkResponse{
				Applied: networkChangePlanToProto(h.orch.PlanNetworkChange(orchestrator.NetworkChangeRequest{})),
			}, nil
		}
		if err := h.orch.SelectECashNetwork(selection); err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("select ecash network: %w", err).Error())
		}
		// The swap below writes the conf and starts the binaries, and both read
		// the id from memory. A pick that only reached the settings file would
		// boot the network the user just left.
		if planErr == nil {
			if err := h.orch.AdoptECashID(ecashPlan.ToID); err != nil {
				return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("select ecash network: %w", err).Error())
			}
			previousECashID = ecashPlan.FromID
		}
		// Before the swap, not after: the swap starts the L1 boot on a
		// goroutine that reads the enforcer conf at once.
		h.orch.RetargetECashEnforcerConf(previousECashID)
	}

	if err := h.orch.SwapNetwork(ctx, network); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("swap network: %w", err).Error())
	}

	return &pb.SetBitcoinConfigNetworkResponse{Applied: networkChangePlanToProto(plan)}, nil
}

func (h *BitcoinConfHandler) WriteBitcoinConfig(ctx context.Context, req *pb.WriteBitcoinConfigRequest) (*pb.WriteBitcoinConfigResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "bitcoin config manager not initialized")
	}

	if err := h.orch.EditBitcoinConfig(func() error {
		if err := h.conf.WriteConfig(req.ConfigContent); err != nil {
			return fmt.Errorf("write config: %w", err)
		}
		if err := h.conf.LoadConfig(false); err != nil {
			return fmt.Errorf("reload config: %w", err)
		}
		return nil
	}); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.WriteBitcoinConfigResponse{}, nil
}

func (h *BitcoinConfHandler) SetBitcoinConfigDataDir(ctx context.Context, req *pb.SetBitcoinConfigDataDirRequest) (*pb.SetBitcoinConfigDataDirResponse, error) {
	if h.conf == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "bitcoin config manager not initialized")
	}

	networkStr := strings.TrimSpace(req.Network)
	if networkStr == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "network is required")
	}
	forNetwork, known := config.LookupNetwork(networkStr)
	if !known {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "unknown network %q", networkStr)
	}

	dataDir := strings.TrimSpace(req.DataDir)

	// Validate writability when setting (not clearing) a datadir.
	if dataDir != "" {
		if err := validateDirWritable(dataDir); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("directory not writable: %w", err).Error())
		}
	}

	if err := h.orch.EditBitcoinConfig(func() error {
		return h.conf.UpdateDataDir(dataDir, forNetwork)
	}); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("update datadir: %w", err).Error())
	}

	return &pb.SetBitcoinConfigDataDirResponse{}, nil
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
