package api

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1/multisigloungev1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var _ rpc.MultisigLoungeServiceHandler = new(MultisigLoungeHandler)

var errMissingGroup = errors.New("group is required")

// multisigGroupFundingSats funds the OP_RETURN-carrying broadcast, matching the
// Dart publish path (10000 sats to a fresh own address).
const multisigGroupFundingSats int64 = 10000

// MultisigLoungeHandler implements the MultisigLoungeService gRPC handler.
// BuildDescriptors and ValidatePsbt are pure stateless logic; PublishGroup and
// ImportGroupFromTxid need the wallet engine (broadcast + raw tx) and service
// (seed for wallet-key detection), wired after engine init.
type MultisigLoungeHandler struct {
	svc    *wallet.Service
	engine *wallet.WalletEngine // nil until Core/Electrum RPC is configured
}

func NewMultisigLoungeHandler() *MultisigLoungeHandler {
	return &MultisigLoungeHandler{}
}

// SetService wires the wallet service so wallet-key detection can read seeds.
func (h *MultisigLoungeHandler) SetService(svc *wallet.Service) {
	h.svc = svc
}

// SetEngine wires the wallet engine (called once Core/Electrum RPC is available).
func (h *MultisigLoungeHandler) SetEngine(engine *wallet.WalletEngine) {
	h.engine = engine
}

func (h *MultisigLoungeHandler) requireEngine() error {
	if h.engine == nil {
		return errors.New("wallet engine not configured")
	}
	return nil
}

func (h *MultisigLoungeHandler) walletSeedHex(walletID string) string {
	if h.svc == nil {
		return ""
	}
	for _, w := range h.svc.GetAllWallets() {
		if w.ID == walletID {
			return w.Master.SeedHex
		}
	}
	return ""
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

func optStr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func derefStr(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

// protoToGroupData maps the wire GroupData onto the codec struct whose JSON is
// byte-compatible with the BitWindow OP_RETURN format. Empty fingerprint/origin
// become JSON null, matching the Dart key serialization for non-wallet keys.
func protoToGroupData(g *pb.GroupData) wallet.MultisigGroupData {
	keys := make([]wallet.MultisigGroupKey, 0, len(g.GetKeys()))
	for _, k := range g.GetKeys() {
		keys = append(keys, wallet.MultisigGroupKey{
			Owner:          k.GetOwner(),
			Xpub:           k.GetXpub(),
			DerivationPath: k.GetDerivationPath(),
			Fingerprint:    optStr(k.GetFingerprint()),
			OriginPath:     optStr(k.GetOriginPath()),
			IsWallet:       k.GetIsWallet(),
		})
	}
	return wallet.MultisigGroupData{
		ID:                g.GetId(),
		Name:              g.GetName(),
		N:                 int(g.GetN()),
		M:                 int(g.GetM()),
		Keys:              keys,
		Created:           g.GetCreated(),
		DescriptorReceive: g.GetDescriptorReceive(),
		DescriptorChange:  g.GetDescriptorChange(),
		WatchWalletName:   g.GetWatchWalletName(),
		Txid:              g.GetTxid(),
	}
}

func groupDataToProto(g wallet.MultisigGroupData) *pb.GroupData {
	keys := make([]*pb.GroupKey, 0, len(g.Keys))
	for _, k := range g.Keys {
		keys = append(keys, &pb.GroupKey{
			Owner:          k.Owner,
			Xpub:           k.Xpub,
			DerivationPath: k.DerivationPath,
			Fingerprint:    derefStr(k.Fingerprint),
			OriginPath:     derefStr(k.OriginPath),
			IsWallet:       k.IsWallet,
		})
	}
	return &pb.GroupData{
		Id:                g.ID,
		Name:              g.Name,
		N:                 uint32(g.N),
		M:                 uint32(g.M),
		Keys:              keys,
		Created:           g.Created,
		DescriptorReceive: g.DescriptorReceive,
		DescriptorChange:  g.DescriptorChange,
		WatchWalletName:   g.WatchWalletName,
		Txid:              g.Txid,
	}
}

func (h *MultisigLoungeHandler) PublishGroup(
	ctx context.Context,
	req *connect.Request[pb.PublishGroupRequest],
) (*connect.Response[pb.PublishGroupResponse], error) {
	group := req.Msg.GetGroup()
	if group == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errMissingGroup)
	}
	if req.Msg.GetWalletId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("wallet_id is required"))
	}
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.GetWalletId())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	message, err := wallet.EncodeGroupOpReturn(protoToGroupData(group), uint32(time.Now().Unix()))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("encode group op_return: %w", err))
	}

	address, err := h.engine.Backend().NextReceiveAddress(ctx, walletID, wallet.ScriptNativeSegwit)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get receive address: %w", err))
	}

	txid, err := h.engine.Backend().Send(ctx, walletID, wallet.SendRequest{
		DestinationsSats: map[string]int64{address: multisigGroupFundingSats},
		OpReturnHex:      hex.EncodeToString([]byte(message)),
	})
	if err != nil {
		return nil, rpcError(err)
	}

	return connect.NewResponse(&pb.PublishGroupResponse{Txid: txid}), nil
}

func (h *MultisigLoungeHandler) ImportGroupFromTxid(
	ctx context.Context,
	req *connect.Request[pb.ImportGroupFromTxidRequest],
) (*connect.Response[pb.ImportGroupFromTxidResponse], error) {
	if req.Msg.GetTxid() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("txid is required"))
	}
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.GetWalletId())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	rawTx, err := h.engine.ChainForWallet(walletID).GetRawTransaction(ctx, req.Msg.GetTxid())
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("getrawtransaction: %w", err))
	}

	message, err := wallet.ExtractOpReturnMessage(rawTx.Vout)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}

	groupData, err := wallet.DecodeGroupOpReturn(message)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	indices := h.detectWalletKeys(walletID, groupData)

	return connect.NewResponse(&pb.ImportGroupFromTxidResponse{
		Group:            groupDataToProto(groupData),
		WalletKeyIndices: indices,
	}), nil
}

// detectWalletKeys returns the indices of group keys whose xpub the wallet can
// re-derive from its seed at the key's derivation path. Without a seed (watch-
// only wallet) no key is wallet-owned.
func (h *MultisigLoungeHandler) detectWalletKeys(walletID string, g wallet.MultisigGroupData) []uint32 {
	seedHex := h.walletSeedHex(walletID)
	if seedHex == "" || h.engine == nil {
		return nil
	}
	net := h.engine.Network()
	var indices []uint32
	for i, k := range g.Keys {
		derived, err := wallet.DeriveAccountXpub(seedHex, k.DerivationPath, net)
		if err != nil {
			continue
		}
		if derived == k.Xpub {
			indices = append(indices, uint32(i))
		}
	}
	return indices
}
