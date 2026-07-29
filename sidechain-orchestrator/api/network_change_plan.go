package api

import (
	"fmt"

	"connectrpc.com/connect"

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
	case pb.WalletBackend_WALLET_BACKEND_ENFORCER:
		return wallet.WalletTypeEnforcer
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
	case wallet.WalletTypeEnforcer:
		return pb.WalletBackend_WALLET_BACKEND_ENFORCER
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
	err := connect.NewError(
		connect.CodeFailedPrecondition,
		fmt.Errorf("datadir not configured for %s", p.Network),
	)
	if detail, derr := connect.NewErrorDetail(networkChangePlanToProto(p)); derr == nil {
		err.AddDetail(detail)
	}
	return err
}
