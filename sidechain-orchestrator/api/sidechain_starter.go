package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// EnsureSidechainStarter returns the seed phrase of one slot, and derives it
// when the slot has none.
//
// injectSidechainStarter derives a starter only when a sidechain binary
// starts. A slot whose chain runs no local binary would never get one, so the
// user could never read the phrase that holds their coins.
func (h *WalletHandler) EnsureSidechainStarter(
	ctx context.Context, req *connect.Request[pb.EnsureSidechainStarterRequest],
) (*connect.Response[pb.EnsureSidechainStarterResponse], error) {
	if req.Msg.Slot > 255 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("slot is %d, and a slot holds 0 to 255", req.Msg.Slot))
	}
	if req.Msg.Name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("name is empty"))
	}

	mnemonic, err := h.svc.GetOrDeriveSidechainStarter(int(req.Msg.Slot), req.Msg.Name)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("sidechain starter for slot %d: %w", req.Msg.Slot, err))
	}

	return connect.NewResponse(&pb.EnsureSidechainStarterResponse{Mnemonic: mnemonic}), nil
}
