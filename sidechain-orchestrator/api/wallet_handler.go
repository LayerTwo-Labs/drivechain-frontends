package api

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var _ rpc.WalletManagerServiceHandler = new(WalletHandler)

// WalletHandler implements the WalletManagerService gRPC handler.
type WalletHandler struct {
	svc *wallet.Service
}

func NewWalletHandler(svc *wallet.Service) *WalletHandler {
	return &WalletHandler{svc: svc}
}

func (h *WalletHandler) GetWalletStatus(ctx context.Context, req *connect.Request[pb.GetWalletStatusRequest]) (*connect.Response[pb.GetWalletStatusResponse], error) {
	return connect.NewResponse(&pb.GetWalletStatusResponse{
		HasWallet:      h.svc.HasWallet(),
		Encrypted:      h.svc.IsEncrypted(),
		Unlocked:       h.svc.IsUnlocked(),
		ActiveWalletId: h.svc.ActiveWalletID(),
	}), nil
}

func (h *WalletHandler) SetActiveWallet(ctx context.Context, req *connect.Request[pb.SetActiveWalletRequest]) (*connect.Response[pb.SetActiveWalletResponse], error) {
	if req.Msg.WalletId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("wallet_id is required"))
	}
	if err := h.svc.SwitchWallet(req.Msg.WalletId); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	return connect.NewResponse(&pb.SetActiveWalletResponse{}), nil
}

func (h *WalletHandler) GenerateWallet(ctx context.Context, req *connect.Request[pb.GenerateWalletRequest]) (*connect.Response[pb.GenerateWalletResponse], error) {
	name := req.Msg.Name
	if name == "" {
		name = "Enforcer Wallet"
	}

	w, err := h.svc.GenerateWallet(name, req.Msg.CustomMnemonic, req.Msg.Passphrase, nil)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.GenerateWalletResponse{
		WalletId: w.ID,
		Mnemonic: w.Master.Mnemonic,
	}), nil
}

func (h *WalletHandler) UnlockWallet(ctx context.Context, req *connect.Request[pb.UnlockWalletRequest]) (*connect.Response[pb.UnlockWalletResponse], error) {
	if err := h.svc.UnlockWallet(req.Msg.Password); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.UnlockWalletResponse{}), nil
}

func (h *WalletHandler) LockWallet(ctx context.Context, req *connect.Request[pb.LockWalletRequest]) (*connect.Response[pb.LockWalletResponse], error) {
	h.svc.LockWallet()
	return connect.NewResponse(&pb.LockWalletResponse{}), nil
}

func (h *WalletHandler) EncryptWallet(ctx context.Context, req *connect.Request[pb.EncryptWalletRequest]) (*connect.Response[pb.EncryptWalletResponse], error) {
	if err := h.svc.EncryptWallet(req.Msg.Password); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.EncryptWalletResponse{}), nil
}

func (h *WalletHandler) ChangePassword(ctx context.Context, req *connect.Request[pb.ChangePasswordRequest]) (*connect.Response[pb.ChangePasswordResponse], error) {
	if err := h.svc.ChangePassword(req.Msg.OldPassword, req.Msg.NewPassword); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.ChangePasswordResponse{}), nil
}

func (h *WalletHandler) RemoveEncryption(ctx context.Context, req *connect.Request[pb.RemoveEncryptionRequest]) (*connect.Response[pb.RemoveEncryptionResponse], error) {
	if err := h.svc.RemoveEncryption(req.Msg.Password); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.RemoveEncryptionResponse{}), nil
}

func (h *WalletHandler) ListWallets(ctx context.Context, req *connect.Request[pb.ListWalletsRequest]) (*connect.Response[pb.ListWalletsResponse], error) {
	wallets := h.svc.ListWallets()
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		gradientJSON := ""
		if len(w.Gradient) > 0 {
			gradientJSON = string(w.Gradient)
		}
		pbWallets[i] = &pb.WalletMetadata{
			Id:           w.ID,
			Name:         w.Name,
			WalletType:   w.WalletType,
			GradientJson: gradientJSON,
			CreatedAt:    w.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}
	}
	return connect.NewResponse(&pb.ListWalletsResponse{
		Wallets: pbWallets,
	}), nil
}

func (h *WalletHandler) UpdateWalletMetadata(ctx context.Context, req *connect.Request[pb.UpdateWalletMetadataRequest]) (*connect.Response[pb.UpdateWalletMetadataResponse], error) {
	var gradient json.RawMessage
	if req.Msg.GradientJson != "" {
		gradient = json.RawMessage(req.Msg.GradientJson)
	}
	if err := h.svc.UpdateWalletMetadata(req.Msg.WalletId, req.Msg.Name, gradient); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	return connect.NewResponse(&pb.UpdateWalletMetadataResponse{}), nil
}

func (h *WalletHandler) DeleteWallet(ctx context.Context, req *connect.Request[pb.DeleteWalletRequest]) (*connect.Response[pb.DeleteWalletResponse], error) {
	if err := h.svc.DeleteWallet(req.Msg.WalletId); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	return connect.NewResponse(&pb.DeleteWalletResponse{}), nil
}

func (h *WalletHandler) DeleteAllWallets(ctx context.Context, req *connect.Request[pb.DeleteAllWalletsRequest]) (*connect.Response[pb.DeleteAllWalletsResponse], error) {
	if err := h.svc.DeleteAllWallets(nil, nil); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.DeleteAllWalletsResponse{}), nil
}

func (h *WalletHandler) GetMnemonic(ctx context.Context, req *connect.Request[pb.GetMnemonicRequest]) (*connect.Response[pb.GetMnemonicResponse], error) {
	if req.Msg.WalletId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("wallet_id is required"))
	}

	w := h.svc.GetWalletByID(req.Msg.WalletId)
	if w == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("wallet not found"))
	}

	var scMnemonics []*pb.SidechainMnemonic
	for _, sc := range w.Sidechains {
		scMnemonics = append(scMnemonics, &pb.SidechainMnemonic{
			Slot:     int32(sc.Slot),
			Name:     sc.Name,
			Mnemonic: sc.Mnemonic,
		})
	}

	return connect.NewResponse(&pb.GetMnemonicResponse{
		MasterMnemonic:     w.Master.Mnemonic,
		L1Mnemonic:         w.L1.Mnemonic,
		SidechainMnemonics: scMnemonics,
	}), nil
}

func (h *WalletHandler) CreateWatchOnlyWallet(ctx context.Context, req *connect.Request[pb.CreateWatchOnlyWalletRequest]) (*connect.Response[pb.CreateWatchOnlyWalletResponse], error) {
	if err := h.svc.CreateWatchOnlyWallet(req.Msg.Name, req.Msg.XpubOrDescriptor, req.Msg.GradientJson); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Get the ID of the wallet we just created (it's the last one added)
	wallets := h.svc.ListWallets()
	if len(wallets) == 0 {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("wallet not found after creation"))
	}
	lastWallet := wallets[len(wallets)-1]

	return connect.NewResponse(&pb.CreateWatchOnlyWalletResponse{
		WalletId: lastWallet.ID,
	}), nil
}
