package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func nodeModeToProto(m orchestrator.NodeMode) pb.NodeMode {
	switch m {
	case orchestrator.NodeModeFull:
		return pb.NodeMode_NODE_MODE_FULL
	case orchestrator.NodeModeLight:
		return pb.NodeMode_NODE_MODE_LIGHT
	default:
		return pb.NodeMode_NODE_MODE_UNSPECIFIED
	}
}

func nodeModeFromProto(m pb.NodeMode) orchestrator.NodeMode {
	switch m {
	case pb.NodeMode_NODE_MODE_FULL:
		return orchestrator.NodeModeFull
	case pb.NodeMode_NODE_MODE_LIGHT:
		return orchestrator.NodeModeLight
	default:
		return orchestrator.NodeModeUnset
	}
}

// currentNetwork reports the network the orchestrator serves.
func (h *WalletHandler) currentNetwork() config.Network {
	if h.orch == nil {
		return ""
	}
	return config.Network(h.orch.CurrentNetwork())
}

// GetNodeMode reports the mode the user picked. UNSPECIFIED means they never
// picked, so the frontend must ask before it boots anything.
func (h *WalletHandler) GetNodeMode(
	ctx context.Context, req *connect.Request[pb.GetNodeModeRequest],
) (*connect.Response[pb.GetNodeModeResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not wired"))
	}
	network := h.currentNetwork()
	mode := orchestrator.NodeModeForNetwork(orchestrator.ReadNodeMode(h.orch.BitwindowDir), network)
	return connect.NewResponse(&pb.GetNodeModeResponse{
		Mode:               nodeModeToProto(mode),
		LightModeAvailable: config.SupportsLightMode(network),
	}), nil
}

// SetNodeMode records the user's choice. It refuses light mode on a network
// that serves no Esplora, because that wallet could never read a chain.
func (h *WalletHandler) SetNodeMode(
	ctx context.Context, req *connect.Request[pb.SetNodeModeRequest],
) (*connect.Response[pb.SetNodeModeResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not wired"))
	}
	mode := nodeModeFromProto(req.Msg.Mode)
	if mode == orchestrator.NodeModeUnset {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("pick full or light"))
	}
	network := h.currentNetwork()
	if mode == orchestrator.NodeModeLight && !config.SupportsLightMode(network) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("light mode needs a remote chain server, and %s has none", network))
	}
	if err := orchestrator.WriteNodeMode(h.orch.BitwindowDir, mode); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.SetNodeModeResponse{}), nil
}
