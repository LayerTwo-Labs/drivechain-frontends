package api

import (
	"context"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func (h *WalletHandler) hwiRunner() (*wallet.HWIRunner, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	return wallet.NewHWIRunner(h.engine.Network()), nil
}

func hwiSelector(d *pb.HardwareDeviceSelector) wallet.HardwareSelector {
	if d == nil {
		return wallet.HardwareSelector{}
	}
	return wallet.HardwareSelector{Type: d.Type, Path: d.Path, Fingerprint: d.Fingerprint, Passphrase: d.Passphrase}
}

func (h *WalletHandler) EnumerateHardwareDevices(
	ctx context.Context,
	req *connect.Request[pb.EnumerateHardwareDevicesRequest],
) (*connect.Response[pb.EnumerateHardwareDevicesResponse], error) {
	runner, err := h.hwiRunner()
	if err != nil {
		return nil, err
	}
	devices, err := runner.Enumerate(ctx, req.Msg.Passphrase)
	if err != nil {
		return nil, rpcError(err)
	}
	out := make([]*pb.HardwareDevice, 0, len(devices))
	for _, d := range devices {
		out = append(out, &pb.HardwareDevice{
			Type:            d.Type,
			Model:           d.Model,
			Label:           d.Label,
			Path:            d.Path,
			Fingerprint:     d.Fingerprint,
			NeedsPin:        d.NeedsPinSent,
			NeedsPassphrase: d.NeedsPassphraseSent,
			Error:           d.Error,
			ErrorCode:       int32(d.Code),
		})
	}
	return connect.NewResponse(&pb.EnumerateHardwareDevicesResponse{Devices: out}), nil
}

func (h *WalletHandler) GetHardwareXpub(
	ctx context.Context,
	req *connect.Request[pb.GetHardwareXpubRequest],
) (*connect.Response[pb.GetHardwareXpubResponse], error) {
	runner, err := h.hwiRunner()
	if err != nil {
		return nil, err
	}
	xpub, err := runner.GetXpub(ctx, hwiSelector(req.Msg.Device), req.Msg.DerivationPath)
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.GetHardwareXpubResponse{Xpub: xpub}), nil
}

func (h *WalletHandler) SignPsbtWithDevice(
	ctx context.Context,
	req *connect.Request[pb.SignPsbtWithDeviceRequest],
) (*connect.Response[pb.SignPsbtWithDeviceResponse], error) {
	runner, err := h.hwiRunner()
	if err != nil {
		return nil, err
	}
	signed, err := runner.SignPSBT(ctx, hwiSelector(req.Msg.Device), req.Msg.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.SignPsbtWithDeviceResponse{PsbtBase64: signed}), nil
}

func (h *WalletHandler) PromptDevicePin(
	ctx context.Context,
	req *connect.Request[pb.PromptDevicePinRequest],
) (*connect.Response[pb.PromptDevicePinResponse], error) {
	runner, err := h.hwiRunner()
	if err != nil {
		return nil, err
	}
	if err := runner.PromptPin(ctx, hwiSelector(req.Msg.Device)); err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.PromptDevicePinResponse{}), nil
}

func (h *WalletHandler) SendDevicePin(
	ctx context.Context,
	req *connect.Request[pb.SendDevicePinRequest],
) (*connect.Response[pb.SendDevicePinResponse], error) {
	runner, err := h.hwiRunner()
	if err != nil {
		return nil, err
	}
	if err := runner.SendPin(ctx, hwiSelector(req.Msg.Device), req.Msg.Pin); err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.SendDevicePinResponse{}), nil
}

func (h *WalletHandler) CloseDevice(
	ctx context.Context,
	req *connect.Request[pb.CloseDeviceRequest],
) (*connect.Response[pb.CloseDeviceResponse], error) {
	runner, err := h.hwiRunner()
	if err != nil {
		return nil, err
	}
	if err := runner.Close(ctx, hwiSelector(req.Msg.Device)); err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.CloseDeviceResponse{}), nil
}

func (h *WalletHandler) DeriveKeystore(
	ctx context.Context,
	req *connect.Request[pb.DeriveKeystoreRequest],
) (*connect.Response[pb.DeriveKeystoreResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	msg := req.Msg
	src := wallet.KeystoreSource{Mnemonic: msg.Mnemonic, Passphrase: msg.Passphrase, RawKey: msg.RawKey}
	if msg.Device != nil {
		sel := hwiSelector(msg.Device)
		src.Device = &sel
	}
	out, err := wallet.DeriveKeystore(ctx, src, msg.ScriptType, msg.Multisig, msg.Account, h.engine.Network())
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.DeriveKeystoreResponse{
		Xpub:        out.Xpub,
		Fingerprint: out.Fingerprint,
		OriginPath:  out.OriginPath,
		Descriptor_: out.Descriptor,
	}), nil
}
