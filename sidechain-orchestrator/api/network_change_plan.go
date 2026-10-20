package api

import (
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connectproto"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func walletBackendFromProto(b pb.WalletBackend) wallet.WalletType {
	switch b {
	case pb.WalletBackend_WALLET_BACKEND_ELECTRUM:
		return wallet.WalletTypeElectrum
	case pb.WalletBackend_WALLET_BACKEND_CORE:
		return wallet.WalletTypeBitcoinCore
	default:
		return ""
	}
}

func walletBackendToProto(t wallet.WalletType) pb.WalletBackend {
	switch t {
	case wallet.WalletTypeElectrum:
		return pb.WalletBackend_WALLET_BACKEND_ELECTRUM
	case wallet.WalletTypeBitcoinCore:
		return pb.WalletBackend_WALLET_BACKEND_CORE
	default:
		return pb.WalletBackend_WALLET_BACKEND_UNSPECIFIED
	}
}

func networkChangePlanToProto(p orchestrator.NetworkChangePlan) *pb.NetworkChangePlan {
	return &pb.NetworkChangePlan{
		Network:              string(p.Network),
		WalletBackend:        walletBackendToProto(p.WalletBackend),
		MustSelectDatadir:    p.MustSelectDatadir,
		Datadir:              p.Datadir,
		DatadirGroup:         string(p.DatadirGroup),
		NeedsLocalBackends:   p.NeedsLocalBackends,
		ImpliesChainDownload: p.ImpliesChainDownload,
		MissingBinaries:      p.MissingBinaries,
		NeedsBinaryDownload:  p.NeedsBinaryDownload,
		NoOp:                 p.NoOp,
	}
}

// requirementsUnmet refuses a change the user has not resolved, carrying the
// plan as a detail so the frontend reads fields instead of parsing a string.
func requirementsUnmet(p orchestrator.NetworkChangePlan) *connect.Error {
	err := connect.Errorf(
		connect.CodeFailedPrecondition,
		"datadir not configured for %s", p.Network,
	)
	if detail, derr := connectproto.NewErrorDetail(networkChangePlanToProto(p)); derr == nil {
		err = err.WithDetail(detail)
	}
	return err
}
