package api

import (
	"context"
	"encoding/json"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"

	pb "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/walletmanager/v1"
	svc "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/walletmanager/v1/walletmanagerv1connect"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var _ svc.WalletManagerServiceHandler = new(WalletHandler)

// WalletHandler implements the WalletManagerService gRPC handler.
type WalletHandler struct {
	svc *wallet.Service
	log zerolog.Logger
}

func NewWalletHandler(svc *wallet.Service, log zerolog.Logger) *WalletHandler {
	return &WalletHandler{
		svc: svc,
		log: log.With().Str("handler", "wallet").Logger(),
	}
}

func (h *WalletHandler) GetWalletStatus(_ context.Context, _ *connect.Request[pb.GetWalletStatusRequest]) (*connect.Response[pb.GetWalletStatusResponse], error) {
	h.log.Debug().Msg("RPC GetWalletStatus")
	resp := &pb.GetWalletStatusResponse{
		HasWallet:        h.svc.HasWallet(),
		Encrypted:        h.svc.IsEncrypted(),
		Unlocked:         h.svc.IsUnlocked(),
		ActiveWalletId:   h.svc.ActiveWalletID(),
		ActiveWalletName: h.svc.ActiveWalletName(),
	}
	h.log.Debug().
		Bool("has_wallet", resp.HasWallet).
		Bool("encrypted", resp.Encrypted).
		Bool("unlocked", resp.Unlocked).
		Str("active_id", resp.ActiveWalletId).
		Msg("RPC GetWalletStatus response")
	return connect.NewResponse(resp), nil
}

func (h *WalletHandler) GenerateWallet(_ context.Context, req *connect.Request[pb.GenerateWalletRequest]) (*connect.Response[pb.GenerateWalletResponse], error) {
	h.log.Info().
		Str("name", req.Msg.Name).
		Bool("custom_mnemonic", req.Msg.CustomMnemonic != "").
		Msg("RPC GenerateWallet")

	// Default sidechain slots for Thunder
	slots := []wallet.SidechainSlot{
		{Slot: 9, Name: "Thunder"},
	}

	w, err := h.svc.GenerateWallet(
		req.Msg.Name,
		req.Msg.CustomMnemonic,
		req.Msg.Passphrase,
		slots,
	)
	if err != nil {
		h.log.Error().Err(err).Msg("RPC GenerateWallet failed")
		return nil, err
	}

	h.log.Info().Str("wallet_id", w.ID).Msg("RPC GenerateWallet success")
	return connect.NewResponse(&pb.GenerateWalletResponse{
		WalletId: w.ID,
		Mnemonic: w.Master.Mnemonic,
	}), nil
}

func (h *WalletHandler) UnlockWallet(_ context.Context, req *connect.Request[pb.UnlockWalletRequest]) (*connect.Response[pb.UnlockWalletResponse], error) {
	h.log.Info().Msg("RPC UnlockWallet")
	if err := h.svc.UnlockWallet(req.Msg.Password); err != nil {
		h.log.Warn().Err(err).Msg("RPC UnlockWallet failed")
		return nil, err
	}
	h.log.Info().Msg("RPC UnlockWallet success")
	return connect.NewResponse(&pb.UnlockWalletResponse{}), nil
}

func (h *WalletHandler) LockWallet(_ context.Context, _ *connect.Request[pb.LockWalletRequest]) (*connect.Response[pb.LockWalletResponse], error) {
	h.log.Info().Msg("RPC LockWallet")
	h.svc.LockWallet()
	return connect.NewResponse(&pb.LockWalletResponse{}), nil
}

func (h *WalletHandler) EncryptWallet(_ context.Context, req *connect.Request[pb.EncryptWalletRequest]) (*connect.Response[pb.EncryptWalletResponse], error) {
	h.log.Info().Msg("RPC EncryptWallet")
	if err := h.svc.EncryptWallet(req.Msg.Password); err != nil {
		h.log.Error().Err(err).Msg("RPC EncryptWallet failed")
		return nil, err
	}
	h.log.Info().Msg("RPC EncryptWallet success")
	return connect.NewResponse(&pb.EncryptWalletResponse{}), nil
}

func (h *WalletHandler) ChangePassword(_ context.Context, req *connect.Request[pb.ChangePasswordRequest]) (*connect.Response[pb.ChangePasswordResponse], error) {
	h.log.Info().Msg("RPC ChangePassword")
	if err := h.svc.ChangePassword(req.Msg.OldPassword, req.Msg.NewPassword); err != nil {
		h.log.Warn().Err(err).Msg("RPC ChangePassword failed")
		return nil, err
	}
	h.log.Info().Msg("RPC ChangePassword success")
	return connect.NewResponse(&pb.ChangePasswordResponse{}), nil
}

func (h *WalletHandler) RemoveEncryption(_ context.Context, req *connect.Request[pb.RemoveEncryptionRequest]) (*connect.Response[pb.RemoveEncryptionResponse], error) {
	h.log.Info().Msg("RPC RemoveEncryption")
	if err := h.svc.RemoveEncryption(req.Msg.Password); err != nil {
		h.log.Warn().Err(err).Msg("RPC RemoveEncryption failed")
		return nil, err
	}
	h.log.Info().Msg("RPC RemoveEncryption success")
	return connect.NewResponse(&pb.RemoveEncryptionResponse{}), nil
}

func (h *WalletHandler) ListWallets(_ context.Context, _ *connect.Request[pb.ListWalletsRequest]) (*connect.Response[pb.ListWalletsResponse], error) {
	h.log.Debug().Msg("RPC ListWallets")
	wallets := h.svc.ListWallets()
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		pbWallets[i] = &pb.WalletMetadata{
			Id:           w.ID,
			Name:         w.Name,
			WalletType:   w.WalletType,
			GradientJson: string(w.Gradient),
			CreatedAt:    w.CreatedAt.Format("2006-01-02T15:04:05.000"),
		}
	}
	h.log.Debug().Int("count", len(pbWallets)).Msg("RPC ListWallets response")
	return connect.NewResponse(&pb.ListWalletsResponse{
		Wallets:        pbWallets,
		ActiveWalletId: h.svc.ActiveWalletID(),
	}), nil
}

func (h *WalletHandler) SwitchWallet(_ context.Context, req *connect.Request[pb.SwitchWalletRequest]) (*connect.Response[pb.SwitchWalletResponse], error) {
	h.log.Info().Str("wallet_id", req.Msg.WalletId).Msg("RPC SwitchWallet")
	if err := h.svc.SwitchWallet(req.Msg.WalletId); err != nil {
		h.log.Warn().Err(err).Msg("RPC SwitchWallet failed")
		return nil, err
	}
	return connect.NewResponse(&pb.SwitchWalletResponse{}), nil
}

func (h *WalletHandler) UpdateWalletMetadata(_ context.Context, req *connect.Request[pb.UpdateWalletMetadataRequest]) (*connect.Response[pb.UpdateWalletMetadataResponse], error) {
	h.log.Info().Str("wallet_id", req.Msg.WalletId).Str("name", req.Msg.Name).Msg("RPC UpdateWalletMetadata")
	var gradient json.RawMessage
	if req.Msg.GradientJson != "" {
		gradient = json.RawMessage(req.Msg.GradientJson)
	}
	if err := h.svc.UpdateWalletMetadata(req.Msg.WalletId, req.Msg.Name, gradient); err != nil {
		h.log.Warn().Err(err).Msg("RPC UpdateWalletMetadata failed")
		return nil, err
	}
	return connect.NewResponse(&pb.UpdateWalletMetadataResponse{}), nil
}

func (h *WalletHandler) DeleteWallet(_ context.Context, req *connect.Request[pb.DeleteWalletRequest]) (*connect.Response[pb.DeleteWalletResponse], error) {
	h.log.Info().Str("wallet_id", req.Msg.WalletId).Msg("RPC DeleteWallet")
	if err := h.svc.DeleteWallet(req.Msg.WalletId); err != nil {
		h.log.Warn().Err(err).Msg("RPC DeleteWallet failed")
		return nil, err
	}
	return connect.NewResponse(&pb.DeleteWalletResponse{}), nil
}

func (h *WalletHandler) DeleteAllWallets(_ context.Context, _ *connect.Request[pb.DeleteAllWalletsRequest]) (*connect.Response[pb.DeleteAllWalletsResponse], error) {
	h.log.Info().Msg("RPC DeleteAllWallets")
	if err := h.svc.DeleteAllWallets(nil, nil); err != nil {
		h.log.Error().Err(err).Msg("RPC DeleteAllWallets failed")
		return nil, err
	}
	h.log.Info().Msg("RPC DeleteAllWallets success")
	return connect.NewResponse(&pb.DeleteAllWalletsResponse{}), nil
}
