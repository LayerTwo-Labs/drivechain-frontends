package api

import (
	"context"
	"errors"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1/multisigloungev1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var _ rpc.MultisigLoungeServiceHandler = new(MultisigLoungeHandler)

var errMissingGroup = errors.New("group is required")

// MultisigLoungeHandler implements the MultisigLoungeService gRPC handler. It is
// pure stateless logic — no wallet, no signing, no broadcast.
type MultisigLoungeHandler struct{}

func NewMultisigLoungeHandler() *MultisigLoungeHandler {
	return &MultisigLoungeHandler{}
}

func protoToLoungeGroup(g *pb.MultisigGroup) wallet.MultisigLoungeGroup {
	keys := make([]wallet.MultisigLoungeKey, 0, len(g.GetKeys()))
	for _, k := range g.GetKeys() {
		keys = append(keys, wallet.MultisigLoungeKey{
			Xpub:        k.GetXpub(),
			Fingerprint: k.GetFingerprint(),
			OriginPath:  k.GetOriginPath(),
			IsWallet:    k.GetIsWallet(),
		})
	}
	return wallet.MultisigLoungeGroup{
		M:    int(g.GetM()),
		N:    int(g.GetN()),
		Keys: keys,
	}
}

func (h *MultisigLoungeHandler) BuildDescriptors(
	ctx context.Context,
	req *connect.Request[pb.BuildDescriptorsRequest],
) (*connect.Response[pb.BuildDescriptorsResponse], error) {
	group := req.Msg.GetGroup()
	if group == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errMissingGroup)
	}
	receive, change, err := wallet.BuildMultisigLoungeDescriptors(protoToLoungeGroup(group))
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.BuildDescriptorsResponse{
		ReceiveDescriptor: receive,
		ChangeDescriptor:  change,
	}), nil
}

func (h *MultisigLoungeHandler) ValidatePsbt(
	ctx context.Context,
	req *connect.Request[pb.ValidatePsbtRequest],
) (*connect.Response[pb.ValidatePsbtResponse], error) {
	var group *wallet.MultisigLoungeGroup
	if g := req.Msg.GetGroup(); g != nil {
		lg := protoToLoungeGroup(g)
		group = &lg
	}

	res, err := wallet.ValidateMultisigPsbt(req.Msg.GetPsbtBase64(), int(req.Msg.GetRequiredSigs()), group)
	if err != nil {
		return connect.NewResponse(&pb.ValidatePsbtResponse{Error: err.Error()}), nil
	}
	return connect.NewResponse(&pb.ValidatePsbtResponse{
		HasSignatures:  res.HasSignatures,
		SignatureCount: uint32(res.SignatureCount),
		IsComplete:     res.IsComplete,
		Finalizable:    res.Finalizable,
	}), nil
}
