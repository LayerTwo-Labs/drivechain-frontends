package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
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

// CoreRawCaller invokes a bitcoind JSON-RPC method (params as a JSON array
// string), optionally scoped to a wallet. It is the same seam the orchestrator's
// CoreRawCall handler uses, so multisig signing/combine/broadcast hit the exact
// bitcoind the rest of the wallet already talks to.
type CoreRawCaller func(ctx context.Context, method, paramsJSON, wallet string) (json.RawMessage, error)

// MultisigLoungeHandler implements the MultisigLoungeService gRPC handler.
// BuildDescriptors and ValidatePsbt are pure stateless logic; PublishGroup and
// ImportGroupFromTxid need the wallet engine (broadcast + raw tx) and service
// (seed); SignTransaction and CombineAndBroadcast additionally need the Core RPC
// seam to drive bitcoind's descriptorprocesspsbt/combinepsbt/finalizepsbt.
type MultisigLoungeHandler struct {
	svc        *wallet.Service
	engine     *wallet.WalletEngine // nil until Core/Electrum RPC is configured
	coreCaller CoreRawCaller        // nil until Core RPC is configured
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

// SetCoreCaller wires the bitcoind JSON-RPC seam used for multisig signing.
func (h *MultisigLoungeHandler) SetCoreCaller(c CoreRawCaller) {
	h.coreCaller = c
}

func (h *MultisigLoungeHandler) requireCoreCaller() error {
	if h.coreCaller == nil {
		return errors.New("bitcoin core RPC not configured")
	}
	return nil
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

// groupDataToLoungeGroup maps the full wire GroupData onto the descriptor-builder
// group (xpub + [fp/origin] + is_wallet), so SignTransaction can reuse the
// Phase-1 descriptor construction and ValidatePsbt's group membership check.
func groupDataToLoungeGroup(g *pb.GroupData) wallet.MultisigLoungeGroup {
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

// coreCall invokes a bitcoind JSON-RPC method with positional params, wallet-less
// (matching the Dart multisig path), and unmarshals the result into out.
func (h *MultisigLoungeHandler) coreCall(ctx context.Context, method string, params []interface{}, out interface{}) error {
	paramsJSON, err := json.Marshal(params)
	if err != nil {
		return fmt.Errorf("marshal %s params: %w", method, err)
	}
	raw, err := h.coreCaller(ctx, method, string(paramsJSON), "")
	if err != nil {
		return err
	}
	if out == nil {
		return nil
	}
	if err := json.Unmarshal(raw, out); err != nil {
		return fmt.Errorf("decode %s result: %w", method, err)
	}
	return nil
}

func (h *MultisigLoungeHandler) SignTransaction(
	ctx context.Context,
	req *connect.Request[pb.SignTransactionRequest],
) (*connect.Response[pb.SignTransactionResponse], error) {
	group := req.Msg.GetGroup()
	if group == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errMissingGroup)
	}
	if req.Msg.GetPsbtBase64() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("psbt_base64 is required"))
	}
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	if err := h.requireCoreCaller(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.GetWalletId())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	seedHex := h.walletSeedHex(walletID)
	if seedHex == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet has no seed; cannot sign"))
	}

	loungeGroup := groupDataToLoungeGroup(group)

	// Reject a PSBT that does not belong to this group before signing it.
	if _, err := wallet.ValidateMultisigPsbt(req.Msg.GetPsbtBase64(), int(group.GetM()), &loungeGroup); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("psbt does not match group: %w", err))
	}

	// Derive the wallet's xprv for every group key the wallet owns, keyed by xpub
	// for substitution into the signing descriptor.
	net := h.engine.Network()
	signWithXprv := map[string]string{}
	for _, k := range group.GetKeys() {
		if !k.GetIsWallet() {
			continue
		}
		xprv, xpub, derr := wallet.DeriveAccountXprv(seedHex, k.GetDerivationPath(), net)
		if derr != nil {
			continue
		}
		if xpub == k.GetXpub() {
			signWithXprv[xpub] = xprv
		}
	}
	if len(signWithXprv) == 0 {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet owns none of the group's keys; cannot sign"))
	}

	receiveDesc, changeDesc, err := wallet.BuildMultisigSigningDescriptors(loungeGroup, signWithXprv)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("build signing descriptors: %w", err))
	}

	before := countPsbtSignatures(req.Msg.GetPsbtBase64())

	// descriptorprocesspsbt(psbt, descriptors, sighashtype, bip32derivs, finalize=false)
	var res struct {
		PSBT     string `json:"psbt"`
		Complete bool   `json:"complete"`
	}
	if err := h.coreCall(ctx, "descriptorprocesspsbt", []interface{}{
		req.Msg.GetPsbtBase64(),
		[]string{receiveDesc, changeDesc},
		"ALL",
		true,
		false,
	}, &res); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("descriptorprocesspsbt: %w", err))
	}
	if res.PSBT == "" {
		return nil, connect.NewError(connect.CodeInternal, errors.New("descriptorprocesspsbt returned an empty psbt"))
	}

	added := countPsbtSignatures(res.PSBT) - before
	if added < 0 {
		added = 0
	}

	return connect.NewResponse(&pb.SignTransactionResponse{
		PsbtBase64:      res.PSBT,
		AddedSignatures: uint32(added),
		IsComplete:      res.Complete,
	}), nil
}

func (h *MultisigLoungeHandler) CombineAndBroadcast(
	ctx context.Context,
	req *connect.Request[pb.CombineAndBroadcastRequest],
) (*connect.Response[pb.CombineAndBroadcastResponse], error) {
	psbts := req.Msg.GetPsbts()
	if len(psbts) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("no psbts provided"))
	}
	if err := h.requireCoreCaller(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	// Reject any PSBT that does not belong to the group before combining, so a
	// foreign/stale PSBT can't poison the combined transaction.
	if group := req.Msg.GetGroup(); group != nil {
		loungeGroup := groupDataToLoungeGroup(group)
		for i, p := range psbts {
			if _, err := wallet.ValidateMultisigPsbt(p, int(group.GetM()), &loungeGroup); err != nil {
				return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("psbt %d does not match group: %w", i, err))
			}
		}
	}

	// Combine merges partial signatures (it never overwrites; bitcoind unions the
	// partial sigs across packets), so a stale PSBT can't clobber a newer sig.
	combined := psbts[0]
	if len(psbts) > 1 {
		unique := dedupeStrings(psbts)
		if len(unique) > 1 {
			if err := h.coreCall(ctx, "combinepsbt", []interface{}{unique}, &combined); err != nil {
				return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("combinepsbt: %w", err))
			}
		} else {
			combined = unique[0]
		}
	}

	var fin struct {
		Hex      string `json:"hex"`
		Complete bool   `json:"complete"`
	}
	if err := h.coreCall(ctx, "finalizepsbt", []interface{}{combined}, &fin); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("finalizepsbt: %w", err))
	}
	if !fin.Complete || fin.Hex == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("psbt is not finalizable (threshold of signatures not reached); not broadcasting"))
	}

	var txid string
	if err := h.coreCall(ctx, "sendrawtransaction", []interface{}{fin.Hex}, &txid); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("sendrawtransaction: %w", err))
	}

	return connect.NewResponse(&pb.CombineAndBroadcastResponse{Txid: txid}), nil
}

func dedupeStrings(in []string) []string {
	seen := map[string]bool{}
	out := make([]string, 0, len(in))
	for _, s := range in {
		if seen[s] {
			continue
		}
		seen[s] = true
		out = append(out, s)
	}
	return out
}

// countPsbtSignatures returns the max partial-signature count across inputs, or
// 0 if the PSBT cannot be parsed.
func countPsbtSignatures(psbtBase64 string) int {
	res, err := wallet.ValidateMultisigPsbt(psbtBase64, 0, nil)
	if err != nil {
		return 0
	}
	return res.SignatureCount
}
