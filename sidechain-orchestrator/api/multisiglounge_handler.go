package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strings"
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
	receive, change, err := wallet.BuildMultisigLoungeDescriptorsTyped(protoToLoungeGroup(group), req.Msg.GetScriptType())
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

	derived, err := h.engine.Backend().NextReceiveAddress(ctx, walletID, wallet.ScriptNativeSegwit)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("get receive address: %w", err))
	}

	txid, err := h.engine.Backend().Send(ctx, walletID, wallet.SendRequest{
		DestinationsSats: map[string]int64{derived.Address: multisigGroupFundingSats},
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
	return h.coreCallWallet(ctx, "", method, params, out)
}

// coreCallWallet invokes a bitcoind JSON-RPC method scoped to a named wallet
// (empty wallet = node-level), with positional params, decoding into out.
func (h *MultisigLoungeHandler) coreCallWallet(ctx context.Context, wallet, method string, params []interface{}, out interface{}) error {
	paramsJSON, err := json.Marshal(params)
	if err != nil {
		return fmt.Errorf("marshal %s params: %w", method, err)
	}
	raw, err := h.coreCaller(ctx, method, string(paramsJSON), wallet)
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

// watchWalletName returns the group's watch-only wallet name, defaulting to the
// Dart convention "multisig_<id>".
func watchWalletName(g *pb.GroupData) string {
	if n := g.GetWatchWalletName(); n != "" {
		return n
	}
	return "multisig_" + g.GetId()
}

// multisigWatchRangeChunk is the granularity the watch wallet's descriptor range
// grows in; the first import covers [0, 999].
const multisigWatchRangeChunk = 1000

// multisigWatchRangeLookahead keeps the imported range at least this far ahead of
// the next index the watch wallet hands out.
const multisigWatchRangeLookahead = 100

// watchRangeEnd is the descriptor range end covering next+lookahead, rounded up
// to a whole chunk so a growing wallet re-imports (and rescans) rarely.
func watchRangeEnd(next int) int {
	return ((next+multisigWatchRangeLookahead)/multisigWatchRangeChunk+1)*multisigWatchRangeChunk - 1
}

// watchDescriptorState is what the watch wallet currently tracks: the imported
// range end covering both active descriptors (-1 when either is missing), the
// highest next index Core will hand out, and the descriptors themselves.
type watchDescriptorState struct {
	end     int
	next    int
	receive string
	change  string
}

// normalizeDescriptor puts a descriptor in a comparable form: checksum dropped,
// lower-cased, hardened steps written "h". Core may echo a descriptor in another
// spelling than it was imported with, and a raw compare would then re-import it.
func normalizeDescriptor(desc string) string {
	if i := strings.LastIndex(desc, "#"); i >= 0 {
		desc = desc[:i]
	}
	return strings.ReplaceAll(strings.ToLower(desc), "'", "h")
}

// watchDescriptorRange reports the wallet's active descriptor state, with the
// descriptors normalized for comparison against freshly built ones.
func (h *MultisigLoungeHandler) watchDescriptorRange(ctx context.Context, name string) (watchDescriptorState, error) {
	var res struct {
		Descriptors []struct {
			Desc     string `json:"desc"`
			Active   bool   `json:"active"`
			Internal bool   `json:"internal"`
			Range    []int  `json:"range"`
			Next     int    `json:"next"`
		} `json:"descriptors"`
	}
	state := watchDescriptorState{end: -1}
	if err := h.coreCallWallet(ctx, name, "listdescriptors", nil, &res); err != nil {
		return state, fmt.Errorf("listdescriptors: %w", err)
	}

	end := -1
	var haveReceive, haveChange bool
	for _, d := range res.Descriptors {
		if !d.Active || len(d.Range) != 2 {
			continue
		}
		if d.Internal {
			haveChange = true
			state.change = normalizeDescriptor(d.Desc)
		} else {
			haveReceive = true
			state.receive = normalizeDescriptor(d.Desc)
		}
		if end < 0 || d.Range[1] < end {
			end = d.Range[1]
		}
		if d.Next > state.next {
			state.next = d.Next
		}
	}
	if haveReceive && haveChange {
		state.end = end
	}
	return state, nil
}

// ensureWatchWallet makes sure the group's watch-only descriptor wallet exists,
// has the Phase-1 receive/change descriptors imported, and that their range
// still covers the addresses the wallet is about to hand out. Idempotent: an
// already-existing wallet is loaded, not recreated, and the descriptors are only
// re-imported when the imported range falls short or the policy changed.
func (h *MultisigLoungeHandler) ensureWatchWallet(ctx context.Context, g *pb.GroupData) (string, error) {
	name := watchWalletName(g)

	// Already loaded? listwallets is the cheapest check.
	var loaded []string
	if err := h.coreCall(ctx, "listwallets", nil, &loaded); err != nil {
		return "", fmt.Errorf("listwallets: %w", err)
	}
	exists := false
	for _, w := range loaded {
		if w == name {
			exists = true
			break
		}
	}

	// Try to load it; on failure create it fresh.
	if !exists {
		if err := h.coreCall(ctx, "loadwallet", []interface{}{name}, nil); err == nil {
			exists = true
		}
	}
	if !exists {
		// createwallet(name, disable_private_keys=true, blank=true, "", false, true, false)
		if err := h.coreCall(ctx, "createwallet",
			[]interface{}{name, true, true, "", false, true, false}, nil); err != nil {
			// A concurrent create may have won the race; tolerate "already exists".
			if !strings.Contains(err.Error(), "already exists") && !strings.Contains(err.Error(), "Database already exists") {
				return "", fmt.Errorf("createwallet: %w", err)
			}
		}
	}

	// The imported range is a hard cap: an address past its end is derivable but
	// invisible to the wallet, so keep it ahead of the next index Core hands out.
	state, err := h.watchDescriptorRange(ctx, name)
	if err != nil {
		return "", err
	}
	wantEnd := watchRangeEnd(state.next)

	receive, change, err := wallet.BuildMultisigLoungeDescriptors(groupDataToLoungeGroup(g))
	if err != nil {
		return "", fmt.Errorf("build descriptors: %w", err)
	}

	// An edited group keeps its id, so the wallet is reused: what it tracks can be
	// a retired policy, which must be replaced rather than served.
	samePolicy := state.receive == normalizeDescriptor(receive) && state.change == normalizeDescriptor(change)
	if state.end >= wantEnd && samePolicy {
		return name, nil
	}

	// The widened indices were never handed out, so they carry no history and
	// need no rescan. Keep "now", as the first import always used.
	var timestamp interface{} = "now"
	if state.end >= 0 && !samePolicy {
		// A new policy's addresses can already hold deposits, and no deposit can
		// predate the group; 0 (unset creation time) rescans from genesis.
		timestamp = g.GetCreated() / 1000
	}

	descs := []map[string]interface{}{
		{"desc": receive, "active": true, "internal": false, "timestamp": timestamp, "range": []int{0, wantEnd}},
		{"desc": change, "active": true, "internal": true, "timestamp": timestamp, "range": []int{0, wantEnd}},
	}
	var importRes []struct {
		Success bool `json:"success"`
		Error   struct {
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := h.coreCallWallet(ctx, name, "importdescriptors", []interface{}{descs}, &importRes); err != nil {
		return "", fmt.Errorf("importdescriptors: %w", err)
	}
	for i, r := range importRes {
		if !r.Success {
			return "", fmt.Errorf("import %s descriptor failed: %s", map[int]string{0: "receive", 1: "change"}[i], r.Error.Message)
		}
	}
	return name, nil
}

func (h *MultisigLoungeHandler) SyncGroup(
	ctx context.Context,
	req *connect.Request[pb.SyncGroupRequest],
) (*connect.Response[pb.SyncGroupResponse], error) {
	group := req.Msg.GetGroup()
	if group == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errMissingGroup)
	}
	if err := h.requireCoreCaller(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	name, err := h.ensureWatchWallet(ctx, group)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// getbalances reports confirmed (trusted) and pending (untrusted_pending)
	// in one call, watch-only included for a descriptor wallet.
	var balances struct {
		Mine struct {
			Trusted          float64 `json:"trusted"`
			UntrustedPending float64 `json:"untrusted_pending"`
		} `json:"mine"`
		Watchonly struct {
			Trusted          float64 `json:"trusted"`
			UntrustedPending float64 `json:"untrusted_pending"`
		} `json:"watchonly"`
	}
	if err := h.coreCallWallet(ctx, name, "getbalances", nil, &balances); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("getbalances: %w", err))
	}
	confirmed := balances.Mine.Trusted + balances.Watchonly.Trusted
	pending := balances.Mine.UntrustedPending + balances.Watchonly.UntrustedPending

	var utxos []struct {
		Txid          string  `json:"txid"`
		Vout          uint32  `json:"vout"`
		Address       string  `json:"address"`
		Amount        float64 `json:"amount"`
		Confirmations uint32  `json:"confirmations"`
		ScriptPubKey  string  `json:"scriptPubKey"`
		Spendable     bool    `json:"spendable"`
		Solvable      bool    `json:"solvable"`
		Safe          bool    `json:"safe"`
	}
	// listunspent(minconf=0, maxconf=9999999, [], include_unsafe=true)
	if err := h.coreCallWallet(ctx, name, "listunspent",
		[]interface{}{0, 9999999, []string{}, true}, &utxos); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("listunspent: %w", err))
	}

	pbUtxos := make([]*pb.MultisigUtxo, 0, len(utxos))
	for _, u := range utxos {
		pbUtxos = append(pbUtxos, &pb.MultisigUtxo{
			Txid:          u.Txid,
			Vout:          u.Vout,
			Address:       u.Address,
			AmountSats:    btcToSatsInt(u.Amount),
			Confirmations: u.Confirmations,
			ScriptPubkey:  u.ScriptPubKey,
			Spendable:     u.Spendable,
			Solvable:      u.Solvable,
			Safe:          u.Safe,
		})
	}

	return connect.NewResponse(&pb.SyncGroupResponse{
		ConfirmedSats: btcToSatsInt(confirmed),
		PendingSats:   btcToSatsInt(pending),
		UtxoCount:     uint32(len(utxos)),
		Utxos:         pbUtxos,
	}), nil
}

func (h *MultisigLoungeHandler) RestoreHistory(
	ctx context.Context,
	req *connect.Request[pb.RestoreHistoryRequest],
) (*connect.Response[pb.RestoreHistoryResponse], error) {
	group := req.Msg.GetGroup()
	if group == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errMissingGroup)
	}
	if err := h.requireCoreCaller(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	name, err := h.ensureWatchWallet(ctx, group)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// listtransactions("*", 1000, 0, include_watchonly=true)
	var txs []struct {
		Txid          string  `json:"txid"`
		Address       string  `json:"address"`
		Category      string  `json:"category"`
		Amount        float64 `json:"amount"`
		Confirmations int32   `json:"confirmations"`
		Time          int64   `json:"time"`
	}
	if err := h.coreCallWallet(ctx, name, "listtransactions",
		[]interface{}{"*", 1000, 0, true}, &txs); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("listtransactions: %w", err))
	}

	seen := map[string]bool{}
	out := make([]*pb.MultisigHistoryTx, 0, len(txs))
	for _, wtx := range txs {
		if wtx.Txid == "" || seen[wtx.Txid] {
			continue
		}
		seen[wtx.Txid] = true

		var raw wallet.RawTransaction
		// getrawtransaction(txid, verbose=true)
		if err := h.coreCall(ctx, "getrawtransaction", []interface{}{wtx.Txid, true}, &raw); err != nil {
			continue // skip txs we can't fetch (matches Dart's per-tx tolerance)
		}

		// Core emits one row per wallet-relevant output, and lists a tx's receive
		// rows before its send rows. Net every row for the txid, or a spend whose
		// change pays a group address reads as an inbound deposit of that change.
		// gettransaction carries the whole row set, so a transaction split by the
		// listtransactions count boundary still nets completely.
		details := h.walletTxDetails(ctx, name, wtx.Txid)

		net := 0.0
		owned := map[string]bool{}
		for _, r := range details {
			net += r.Amount
			if r.Category == "receive" && r.Address != "" {
				owned[r.Address] = true
			}
		}

		// The payee is the first output paid outside the group; change back to the
		// group is either omitted or paired with a receive row. A deposit or a
		// self-send has no external payee, so fall back to the group's own address.
		payee := ""
		for _, r := range details {
			if r.Address == "" {
				continue
			}
			if r.Category == "send" && !owned[r.Address] {
				payee = r.Address
				break
			}
			if payee == "" {
				payee = r.Address
			}
		}

		destination := "Unknown"
		if payee != "" {
			destination = payee
		} else if len(raw.Vout) > 0 && raw.Vout[0].ScriptPubKey.Address != "" {
			destination = raw.Vout[0].ScriptPubKey.Address
		}

		inputs := make([]*pb.MultisigHistoryInput, 0, len(raw.Vin))
		for _, vin := range raw.Vin {
			inputs = append(inputs, &pb.MultisigHistoryInput{Txid: vin.TxID, Vout: uint32(vin.Vout)})
		}

		out = append(out, &pb.MultisigHistoryTx{
			Txid:           wtx.Txid,
			AmountSats:     btcToSatsInt(absFloat(net)),
			IsDeposit:      net > 0,
			Destination:    destination,
			Confirmations:  uint32(maxInt32(wtx.Confirmations, 0)),
			SignatureCount: uint32(wallet.CountMultisigSignatures(raw.Vin)),
			Status:         restoreStatus(wtx.Confirmations),
			Time:           wtx.Time,
			FinalHex:       raw.Hex,
			Inputs:         inputs,
		})
	}

	return connect.NewResponse(&pb.RestoreHistoryResponse{Transactions: out}), nil
}

func (h *MultisigLoungeHandler) CreateSpendPsbt(
	ctx context.Context,
	req *connect.Request[pb.CreateSpendPsbtRequest],
) (*connect.Response[pb.CreateSpendPsbtResponse], error) {
	group := req.Msg.GetGroup()
	if group == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errMissingGroup)
	}
	if len(req.Msg.GetDestinations()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("at least one destination is required"))
	}
	if err := h.requireCoreCaller(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	name, err := h.ensureWatchWallet(ctx, group)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Destinations as {address: btc}, mirroring the Dart walletcreatefundedpsbt
	// call which passes BTC amounts.
	outputs := make(map[string]float64, len(req.Msg.GetDestinations()))
	for _, d := range req.Msg.GetDestinations() {
		if d.GetAddress() == "" || d.GetSats() <= 0 {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("each destination needs an address and a positive sats amount"))
		}
		outputs[d.GetAddress()] = float64(d.GetSats()) / 1e8
	}

	// Options mirror the Dart path: includeWatching (watch-only wallet) and
	// changePosition 1. A non-zero fee rate is forwarded when provided.
	options := map[string]interface{}{
		"includeWatching": true,
		"changePosition":  1,
	}
	if rate := req.Msg.GetFeeRateSatVb(); rate > 0 {
		options["fee_rate"] = rate
	}

	var res struct {
		PSBT string  `json:"psbt"`
		Fee  float64 `json:"fee"`
	}
	// walletcreatefundedpsbt([], outputs, 0, options)
	if err := h.coreCallWallet(ctx, name, "walletcreatefundedpsbt",
		[]interface{}{[]interface{}{}, outputs, 0, options}, &res); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("walletcreatefundedpsbt: %w", err))
	}
	if res.PSBT == "" {
		return nil, connect.NewError(connect.CodeInternal, errors.New("walletcreatefundedpsbt returned an empty psbt"))
	}

	return connect.NewResponse(&pb.CreateSpendPsbtResponse{
		PsbtBase64: res.PSBT,
		FeeSats:    btcToSatsInt(res.Fee),
	}), nil
}

func btcToSatsInt(btc float64) int64 {
	return int64(math.Round(btc * 1e8))
}

func absFloat(f float64) float64 {
	if f < 0 {
		return -f
	}
	return f
}

func maxInt32(a, b int32) int32 {
	if a > b {
		return a
	}
	return b
}

// restoreStatus mirrors the Dart _processHistoricalTransaction status mapping:
// 0-conf or <6 confs is "broadcasted"; >=6 is "confirmed".
func restoreStatus(confirmations int32) string {
	if confirmations >= 6 {
		return "confirmed"
	}
	return "broadcasted"
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

// walletTxRow is one wallet-relevant output of a transaction.
type walletTxRow struct {
	Address  string  `json:"address"`
	Category string  `json:"category"`
	Amount   float64 `json:"amount"`
}

// walletTxDetails returns every wallet-relevant row of one transaction. It reads
// gettransaction, whose detail set is complete, rather than the listtransactions
// page, which a fixed count can cut in half.
func (h *MultisigLoungeHandler) walletTxDetails(ctx context.Context, wallet, txid string) []walletTxRow {
	var res struct {
		Details []walletTxRow `json:"details"`
	}
	if err := h.coreCallWallet(ctx, wallet, "gettransaction",
		[]interface{}{txid, true}, &res); err != nil {
		return nil
	}
	return res.Details
}
