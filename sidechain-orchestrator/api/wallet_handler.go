package api

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"sort"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// allSidechainSlots returns slots for every configured sidechain, so wallet
// generation derives a starter for every slot up front. Without this, sidechain
// starters only appear after a sidechain is launched, and the Starters tab
// shows blanks.
func allSidechainSlots() []wallet.SidechainSlot {
	cfgs := orchestrator.AllSidechains()
	slots := make([]wallet.SidechainSlot, len(cfgs))
	for i, c := range cfgs {
		name := c.DisplayName
		if name == "" {
			name = c.Name
		}
		slots[i] = wallet.SidechainSlot{Slot: c.Slot, Name: name}
	}
	return slots
}

var _ rpc.WalletManagerServiceHandler = new(WalletHandler)

const walletTypeEnforcer = "enforcer"

// WalletHandler implements the WalletManagerService gRPC handler.
type WalletHandler struct {
	svc            *wallet.Service
	engine         *wallet.WalletEngine               // nil until Core RPC is configured
	enforcerWallet enforcerrpc.WalletServiceClient    // nil until enforcer is configured
}

func NewWalletHandler(svc *wallet.Service) *WalletHandler {
	return &WalletHandler{svc: svc}
}

// SetEngine sets the wallet engine (called after Core RPC config is available).
func (h *WalletHandler) SetEngine(engine *wallet.WalletEngine) {
	h.engine = engine
}

// SetEnforcerWallet sets the enforcer wallet client used for enforcer-type wallets.
func (h *WalletHandler) SetEnforcerWallet(client enforcerrpc.WalletServiceClient) {
	h.enforcerWallet = client
}

// walletTypeFor returns the wallet type ("enforcer", "bitcoinCore", "watchOnly")
// for a given wallet ID, resolving empty IDs to the active wallet.
func (h *WalletHandler) walletTypeFor(walletID string) (string, string, error) {
	if walletID == "" {
		walletID = h.svc.ActiveWalletID()
		if walletID == "" {
			return "", "", fmt.Errorf("no active wallet")
		}
	}
	for _, w := range h.svc.GetAllWallets() {
		if w.ID == walletID {
			return walletID, w.WalletType, nil
		}
	}
	return "", "", fmt.Errorf("wallet %s not found", walletID)
}

func (h *WalletHandler) requireEnforcerWallet() error {
	if h.enforcerWallet == nil {
		return fmt.Errorf("enforcer wallet not connected")
	}
	return nil
}

// ============================================================================
// Wallet lifecycle RPCs
// ============================================================================

func (h *WalletHandler) GetWalletStatus(ctx context.Context, req *connect.Request[pb.GetWalletStatusRequest]) (*connect.Response[pb.GetWalletStatusResponse], error) {
	return connect.NewResponse(&pb.GetWalletStatusResponse{
		HasWallet:        h.svc.HasWallet(),
		Encrypted:        h.svc.IsEncrypted(),
		Unlocked:         h.svc.IsUnlocked(),
		ActiveWalletId:   h.svc.ActiveWalletID(),
		ActiveWalletName: h.svc.ActiveWalletName(),
	}), nil
}

func (h *WalletHandler) GenerateWallet(ctx context.Context, req *connect.Request[pb.GenerateWalletRequest]) (*connect.Response[pb.GenerateWalletResponse], error) {
	w, err := h.svc.GenerateWallet(req.Msg.Name, req.Msg.CustomMnemonic, req.Msg.Passphrase, allSidechainSlots())
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
	// Use GetAllWallets so we can access the seed for BIP47 derivation —
	// parity with sendWalletData. ListWallets (metadata-only) can't see it.
	wallets := h.svc.GetAllWallets()
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		var gradientJSON string
		if w.Gradient != nil {
			gradientJSON = string(w.Gradient)
		}
		pbWallets[i] = &pb.WalletMetadata{
			Id:               w.ID,
			Name:             w.Name,
			WalletType:       w.WalletType,
			GradientJson:     gradientJSON,
			CreatedAt:        w.CreatedAt.Format(time.RFC3339),
			Bip47PaymentCode: wallet.Bip47V3PaymentCodeFromSeed(w.Master.SeedHex),
		}
	}
	return connect.NewResponse(&pb.ListWalletsResponse{
		Wallets:        pbWallets,
		ActiveWalletId: h.svc.ActiveWalletID(),
	}), nil
}

func (h *WalletHandler) SwitchWallet(ctx context.Context, req *connect.Request[pb.SwitchWalletRequest]) (*connect.Response[pb.SwitchWalletResponse], error) {
	if err := h.svc.SwitchWallet(req.Msg.WalletId); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	return connect.NewResponse(&pb.SwitchWalletResponse{}), nil
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

func (h *WalletHandler) CreateWatchOnlyWallet(ctx context.Context, req *connect.Request[pb.CreateWatchOnlyWalletRequest]) (*connect.Response[pb.CreateWatchOnlyWalletResponse], error) {
	if err := h.svc.CreateWatchOnlyWallet(req.Msg.Name, req.Msg.XpubOrDescriptor, req.Msg.GradientJson); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.CreateWatchOnlyWalletResponse{
		WalletId: h.svc.ActiveWalletID(),
	}), nil
}

// ============================================================================
// Core wallet management RPCs
// ============================================================================

func (h *WalletHandler) requireEngine() error {
	if h.engine == nil {
		return fmt.Errorf("bitcoin Core RPC not configured")
	}
	return nil
}

func (h *WalletHandler) CreateBitcoinCoreWallet(ctx context.Context, req *connect.Request[pb.CreateBitcoinCoreWalletRequest]) (*connect.Response[pb.CreateBitcoinCoreWalletResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	name, err := h.engine.EnsureCoreWallet(ctx, req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.CreateBitcoinCoreWalletResponse{
		CoreWalletName: name,
	}), nil
}

func (h *WalletHandler) EnsureCoreWallets(ctx context.Context, req *connect.Request[pb.EnsureCoreWalletsRequest]) (*connect.Response[pb.EnsureCoreWalletsResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	count, err := h.engine.EnsureCoreWallets(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.EnsureCoreWalletsResponse{
		SyncedCount: int32(count),
	}), nil
}

// ============================================================================
// Bitcoin operation RPCs (proxied through Core RPC)
// ============================================================================

func (h *WalletHandler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	walletID, wType, err := h.walletTypeFor(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if wType == walletTypeEnforcer {
		if err := h.requireEnforcerWallet(); err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}
		resp, err := h.enforcerWallet.GetBalance(ctx, connect.NewRequest(&enforcerpb.GetBalanceRequest{}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: get balance: %w", err))
		}
		return connect.NewResponse(&pb.GetBalanceResponse{
			ConfirmedSats:   float64(resp.Msg.ConfirmedSats),
			UnconfirmedSats: float64(resp.Msg.PendingSats),
		}), nil
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	confirmed, err := h.engine.CoreRPC().GetBalance(ctx, coreName)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	unconfirmed, err := h.engine.CoreRPC().GetUnconfirmedBalance(ctx, coreName)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.GetBalanceResponse{
		ConfirmedSats:   btcToSats(confirmed),
		UnconfirmedSats: btcToSats(unconfirmed),
	}), nil
}

func (h *WalletHandler) GetNewAddress(ctx context.Context, req *connect.Request[pb.GetNewAddressRequest]) (*connect.Response[pb.GetNewAddressResponse], error) {
	walletID, wType, err := h.walletTypeFor(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if wType == walletTypeEnforcer {
		if err := h.requireEnforcerWallet(); err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}
		resp, err := h.enforcerWallet.CreateNewAddress(ctx, connect.NewRequest(&enforcerpb.CreateNewAddressRequest{}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: create new address: %w", err))
		}
		return connect.NewResponse(&pb.GetNewAddressResponse{
			Address: resp.Msg.Address,
		}), nil
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	addr, err := h.engine.CoreRPC().GetNewAddress(ctx, coreName, "", "bech32")
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: addr,
	}), nil
}

func (h *WalletHandler) SendTransaction(ctx context.Context, req *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
	if len(req.Msg.Destinations) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("must provide at least one destination"))
	}

	if req.Msg.FeeRateSatPerVbyte > 0 && req.Msg.FixedFeeSats > 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("cannot provide both fee rate and fixed fee"))
	}

	const dustLimitSats int64 = 546
	for address, sats := range req.Msg.Destinations {
		if sats < dustLimitSats {
			return nil, connect.NewError(
				connect.CodeInvalidArgument,
				fmt.Errorf("amount to %s is below dust limit (%d sats)", address, dustLimitSats),
			)
		}
	}

	walletID, wType, err := h.walletTypeFor(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if wType == walletTypeEnforcer {
		if err := h.requireEnforcerWallet(); err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}

		var feeRate *enforcerpb.SendTransactionRequest_FeeRate
		if req.Msg.FeeRateSatPerVbyte > 0 {
			feeRate = &enforcerpb.SendTransactionRequest_FeeRate{
				Fee: &enforcerpb.SendTransactionRequest_FeeRate_SatPerVbyte{SatPerVbyte: uint64(req.Msg.FeeRateSatPerVbyte)},
			}
		}
		if req.Msg.FixedFeeSats > 0 {
			feeRate = &enforcerpb.SendTransactionRequest_FeeRate{
				Fee: &enforcerpb.SendTransactionRequest_FeeRate_Sats{Sats: uint64(req.Msg.FixedFeeSats)},
			}
		}

		var opReturn *commonv1.Hex
		if req.Msg.OpReturnHex != "" {
			opReturn = &commonv1.Hex{
				Hex: &wrapperspb.StringValue{Value: req.Msg.OpReturnHex},
			}
		}

		destinations := make(map[string]uint64, len(req.Msg.Destinations))
		for addr, sats := range req.Msg.Destinations {
			destinations[addr] = uint64(sats)
		}

		requiredUtxos := make([]*enforcerpb.SendTransactionRequest_RequiredUtxo, 0, len(req.Msg.RequiredInputs))
		for _, u := range req.Msg.RequiredInputs {
			if u.Txid == "" {
				continue
			}
			requiredUtxos = append(requiredUtxos, &enforcerpb.SendTransactionRequest_RequiredUtxo{
				Txid: &commonv1.ReverseHex{Hex: &wrapperspb.StringValue{Value: u.Txid}},
				Vout: uint32(u.Vout),
			})
		}

		resp, err := h.enforcerWallet.SendTransaction(ctx, connect.NewRequest(&enforcerpb.SendTransactionRequest{
			Destinations:    destinations,
			FeeRate:         feeRate,
			OpReturnMessage: opReturn,
			RequiredUtxos:   requiredUtxos,
		}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: send transaction: %w", err))
		}

		return connect.NewResponse(&pb.SendTransactionResponse{
			Txid: resp.Msg.Txid.GetHex().GetValue(),
		}), nil
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	needsAdvancedSend := req.Msg.OpReturnHex != "" ||
		req.Msg.FeeRateSatPerVbyte > 0 ||
		req.Msg.FixedFeeSats > 0 ||
		len(req.Msg.RequiredInputs) > 0

	if needsAdvancedSend {
		txid, err := h.sendAdvancedTransaction(ctx, coreName, req.Msg)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}

		return connect.NewResponse(&pb.SendTransactionResponse{
			Txid: txid,
		}), nil
	}

	// Convert sats to BTC for sendmany
	destinations := make(map[string]float64, len(req.Msg.Destinations))
	for addr, sats := range req.Msg.Destinations {
		destinations[addr] = satsToBtc(sats)
	}

	var txid string
	if len(destinations) == 1 {
		// Use sendtoaddress for single destination
		for addr, amount := range destinations {
			txid, err = h.engine.CoreRPC().SendToAddress(ctx, coreName, addr, amount, req.Msg.SubtractFeeFromAmount)
			break
		}
	} else {
		txid, err = h.engine.CoreRPC().SendMany(ctx, coreName, destinations)
	}
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.SendTransactionResponse{
		Txid: txid,
	}), nil
}

func (h *WalletHandler) sendAdvancedTransaction(
	ctx context.Context,
	coreName string,
	req *pb.SendTransactionRequest,
) (string, error) {
	outputs, totalDestinationSats := buildRawOutputs(req)
	inputs := make([]wallet.CoreRawInput, 0, len(req.RequiredInputs))
	selectedInputAmountSats := int64(0)

	for _, input := range req.RequiredInputs {
		inputs = append(inputs, wallet.CoreRawInput{
			TxID: input.Txid,
			Vout: int(input.Vout),
		})
		selectedInputAmountSats += input.AmountSats
	}

	if req.FixedFeeSats > 0 {
		var err error
		if len(inputs) == 0 {
			inputs, selectedInputAmountSats, err = h.selectInputsForFixedFee(
				ctx,
				coreName,
				totalDestinationSats+req.FixedFeeSats,
			)
			if err != nil {
				return "", err
			}
		}

		changeSats := selectedInputAmountSats - totalDestinationSats - req.FixedFeeSats
		if changeSats < 0 {
			return "", fmt.Errorf(
				"insufficient selected inputs: need %d sats, have %d sats",
				totalDestinationSats+req.FixedFeeSats,
				selectedInputAmountSats,
			)
		}

		if changeSats >= 546 {
			changeAddress, err := h.engine.CoreRPC().GetRawChangeAddress(ctx, coreName)
			if err != nil {
				return "", fmt.Errorf("get raw change address: %w", err)
			}
			outputs = append(outputs, map[string]interface{}{changeAddress: satsToBtc(changeSats)})
		}

		rawHex, err := h.engine.CoreRPC().CreateRawTransaction(ctx, inputs, outputs)
		if err != nil {
			return "", fmt.Errorf("create raw transaction: %w", err)
		}

		return h.signAndBroadcastRawTransaction(ctx, coreName, rawHex)
	}

	rawHex, err := h.engine.CoreRPC().CreateRawTransaction(ctx, inputs, outputs)
	if err != nil {
		return "", fmt.Errorf("create raw transaction: %w", err)
	}

	fundOptions := map[string]interface{}{}
	if len(inputs) > 0 {
		fundOptions["add_inputs"] = false
	}
	if req.FeeRateSatPerVbyte > 0 {
		fundOptions["fee_rate"] = req.FeeRateSatPerVbyte
	}
	if req.SubtractFeeFromAmount && len(req.Destinations) > 0 {
		subtractFeeFromOutputs := make([]int, 0, len(req.Destinations))
		for i := 0; i < len(req.Destinations); i++ {
			subtractFeeFromOutputs = append(subtractFeeFromOutputs, i)
		}
		fundOptions["subtractFeeFromOutputs"] = subtractFeeFromOutputs
	}

	funded, err := h.engine.CoreRPC().FundRawTransaction(ctx, coreName, rawHex, fundOptions)
	if err != nil {
		return "", fmt.Errorf("fund raw transaction: %w", err)
	}

	return h.signAndBroadcastRawTransaction(ctx, coreName, funded.Hex)
}

func (h *WalletHandler) selectInputsForFixedFee(
	ctx context.Context,
	coreName string,
	requiredSats int64,
) ([]wallet.CoreRawInput, int64, error) {
	utxos, err := h.engine.CoreRPC().ListUnspent(ctx, coreName)
	if err != nil {
		return nil, 0, fmt.Errorf("list unspent: %w", err)
	}

	sort.Slice(utxos, func(i, j int) bool {
		return utxos[i].Amount > utxos[j].Amount
	})

	selected := make([]wallet.CoreRawInput, 0)
	totalSats := int64(0)
	for _, utxo := range utxos {
		if !utxo.Spendable {
			continue
		}

		selected = append(selected, wallet.CoreRawInput{
			TxID: utxo.TxID,
			Vout: utxo.Vout,
		})
		totalSats += int64(math.Round(utxo.Amount * 1e8))
		if totalSats >= requiredSats {
			break
		}
	}

	if totalSats < requiredSats {
		return nil, 0, fmt.Errorf("insufficient funds: need %d sats, have %d sats", requiredSats, totalSats)
	}

	return selected, totalSats, nil
}

func buildRawOutputs(req *pb.SendTransactionRequest) ([]map[string]interface{}, int64) {
	outputs := make([]map[string]interface{}, 0, len(req.Destinations)+1)
	totalDestinationSats := int64(0)
	for address, sats := range req.Destinations {
		outputs = append(outputs, map[string]interface{}{address: satsToBtc(sats)})
		totalDestinationSats += sats
	}
	if req.OpReturnHex != "" {
		outputs = append(outputs, map[string]interface{}{"data": req.OpReturnHex})
	}
	return outputs, totalDestinationSats
}

func (h *WalletHandler) signAndBroadcastRawTransaction(
	ctx context.Context,
	coreName, rawHex string,
) (string, error) {
	signed, err := h.engine.CoreRPC().SignRawTransactionWithWallet(ctx, coreName, rawHex)
	if err != nil {
		return "", fmt.Errorf("sign raw transaction: %w", err)
	}
	if !signed.Complete {
		return "", errors.New("transaction signing incomplete")
	}

	txid, err := h.engine.CoreRPC().SendRawTransaction(ctx, signed.Hex)
	if err != nil {
		return "", fmt.Errorf("broadcast raw transaction: %w", err)
	}

	return txid, nil
}

func (h *WalletHandler) ListTransactions(ctx context.Context, req *connect.Request[pb.ListTransactionsRequest]) (*connect.Response[pb.ListTransactionsResponse], error) {
	walletID, wType, err := h.walletTypeFor(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if wType == walletTypeEnforcer {
		if err := h.requireEnforcerWallet(); err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}
		resp, err := h.enforcerWallet.ListTransactions(ctx, connect.NewRequest(&enforcerpb.ListTransactionsRequest{}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: list transactions: %w", err))
		}
		pbTxs := make([]*pb.TransactionEntry, 0, len(resp.Msg.Transactions))
		for _, tx := range resp.Msg.Transactions {
			amountSats := int64(tx.ReceivedSats) - int64(tx.SentSats)
			var confirmations int32
			var blockTime int64
			if tx.ConfirmationInfo != nil {
				confirmations = int32(tx.ConfirmationInfo.Height)
				if tx.ConfirmationInfo.Timestamp != nil {
					blockTime = tx.ConfirmationInfo.Timestamp.Seconds
				}
			}
			pbTxs = append(pbTxs, &pb.TransactionEntry{
				Txid:          tx.Txid.GetHex().GetValue(),
				Amount:        satsToBtc(amountSats),
				AmountSats:    amountSats,
				Fee:           satsToBtc(int64(tx.FeeSats)),
				Confirmations: confirmations,
				BlockTime:     blockTime,
				Time:          blockTime,
				WalletId:      walletID,
			})
		}
		return connect.NewResponse(&pb.ListTransactionsResponse{
			Transactions: pbTxs,
		}), nil
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	count := int(req.Msg.Count)
	if count <= 0 {
		count = 100
	}

	txs, err := h.engine.CoreRPC().ListTransactions(ctx, coreName, count)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	pbTxs := make([]*pb.TransactionEntry, len(txs))
	for i, tx := range txs {
		pbTxs[i] = &pb.TransactionEntry{
			Txid:          tx.TxID,
			Vout:          int32(tx.Vout),
			Address:       tx.Address,
			Category:      tx.Category,
			Amount:        tx.Amount,
			AmountSats:    int64(math.Round(tx.Amount * 1e8)),
			Confirmations: int32(tx.Confirmations),
			BlockTime:     tx.BlockTime,
			Time:          tx.Time,
			Label:         tx.Label,
			Fee:           tx.Fee,
			WalletId:      walletID,
		}
	}

	return connect.NewResponse(&pb.ListTransactionsResponse{
		Transactions: pbTxs,
	}), nil
}

func (h *WalletHandler) ListUnspent(ctx context.Context, req *connect.Request[pb.ListUnspentRequest]) (*connect.Response[pb.ListUnspentResponse], error) {
	walletID, wType, err := h.walletTypeFor(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if wType == walletTypeEnforcer {
		if err := h.requireEnforcerWallet(); err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}
		resp, err := h.enforcerWallet.ListUnspentOutputs(ctx, connect.NewRequest(&enforcerpb.ListUnspentOutputsRequest{}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: list unspent: %w", err))
		}
		pbUTXOs := make([]*pb.UnspentOutput, 0, len(resp.Msg.Outputs))
		for _, u := range resp.Msg.Outputs {
			confirmations := int32(0)
			if u.IsConfirmed {
				confirmations = 1
			}
			pbUTXOs = append(pbUTXOs, &pb.UnspentOutput{
				Txid:          u.Txid.GetHex().GetValue(),
				Vout:          int32(u.Vout),
				Address:       u.Address.GetValue(),
				Amount:        satsToBtc(int64(u.ValueSats)),
				AmountSats:    int64(u.ValueSats),
				Confirmations: confirmations,
				Spendable:     true,
				Solvable:      true,
				WalletId:      walletID,
			})
		}
		return connect.NewResponse(&pb.ListUnspentResponse{
			Utxos: pbUTXOs,
		}), nil
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	utxos, err := h.engine.CoreRPC().ListUnspent(ctx, coreName)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	pbUTXOs := make([]*pb.UnspentOutput, len(utxos))
	for i, u := range utxos {
		pbUTXOs[i] = &pb.UnspentOutput{
			Txid:          u.TxID,
			Vout:          int32(u.Vout),
			Address:       u.Address,
			Amount:        u.Amount,
			AmountSats:    int64(math.Round(u.Amount * 1e8)),
			Confirmations: int32(u.Confirmations),
			Label:         u.Label,
			Spendable:     u.Spendable,
			Solvable:      u.Solvable,
			WalletId:      walletID,
		}
	}

	return connect.NewResponse(&pb.ListUnspentResponse{
		Utxos: pbUTXOs,
	}), nil
}

func (h *WalletHandler) ListReceiveAddresses(ctx context.Context, req *connect.Request[pb.ListReceiveAddressesRequest]) (*connect.Response[pb.ListReceiveAddressesResponse], error) {
	walletID, wType, err := h.walletTypeFor(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	if wType == walletTypeEnforcer {
		if err := h.requireEnforcerWallet(); err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err)
		}
		utxosResp, err := h.enforcerWallet.ListUnspentOutputs(ctx, connect.NewRequest(&enforcerpb.ListUnspentOutputsRequest{}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: list unspent outputs: %w", err))
		}
		addressMap := make(map[string]*pb.ReceiveAddress)
		for _, utxo := range utxosResp.Msg.Outputs {
			addr := utxo.Address.GetValue()
			entry, ok := addressMap[addr]
			if !ok {
				entry = &pb.ReceiveAddress{Address: addr}
				addressMap[addr] = entry
			}
			entry.AmountSats += int64(utxo.ValueSats)
		}
		addrResp, err := h.enforcerWallet.CreateNewAddress(ctx, connect.NewRequest(&enforcerpb.CreateNewAddressRequest{}))
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("enforcer/wallet: create new address: %w", err))
		}
		if _, ok := addressMap[addrResp.Msg.Address]; !ok {
			addressMap[addrResp.Msg.Address] = &pb.ReceiveAddress{Address: addrResp.Msg.Address}
		}

		addresses := make([]*pb.ReceiveAddress, 0, len(addressMap))
		for _, entry := range addressMap {
			entry.Amount = satsToBtc(entry.AmountSats)
			addresses = append(addresses, entry)
		}
		sort.Slice(addresses, func(i, j int) bool {
			return addresses[i].Address < addresses[j].Address
		})
		_ = walletID
		return connect.NewResponse(&pb.ListReceiveAddressesResponse{
			Addresses: addresses,
		}), nil
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	addrs, err := h.engine.CoreRPC().ListReceivedByAddress(ctx, coreName)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	pbAddrs := make([]*pb.ReceiveAddress, len(addrs))
	for i, a := range addrs {
		pbAddrs[i] = &pb.ReceiveAddress{
			Address:    a.Address,
			Amount:     a.Amount,
			AmountSats: int64(math.Round(a.Amount * 1e8)),
			Label:      a.Label,
			TxCount:    int32(len(a.TxIDs)),
		}
	}

	return connect.NewResponse(&pb.ListReceiveAddressesResponse{
		Addresses: pbAddrs,
	}), nil
}

func (h *WalletHandler) GetTransactionDetails(ctx context.Context, req *connect.Request[pb.GetTransactionDetailsRequest]) (*connect.Response[pb.GetTransactionDetailsResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	rawJSON, err := h.engine.CoreRPC().GetTransaction(ctx, coreName, req.Msg.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var tx struct {
		TxID          string  `json:"txid"`
		Amount        float64 `json:"amount"`
		Fee           float64 `json:"fee"`
		Confirmations int     `json:"confirmations"`
		BlockTime     int64   `json:"blocktime"`
		Time          int64   `json:"time"`
		Hex           string  `json:"hex"`
	}
	if err := json.Unmarshal(rawJSON, &tx); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("decode gettransaction: %w", err))
	}

	rawTx, err := h.engine.CoreRPC().GetRawTransaction(ctx, req.Msg.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("getrawtransaction: %w", err))
	}

	inputs := make([]*pb.TransactionInput, 0, len(rawTx.Vin))
	totalInputSats := int64(0)
	for i, vin := range rawTx.Vin {
		input := &pb.TransactionInput{
			Index:      int32(i),
			PrevTxid:   vin.TxID,
			PrevVout:   int32(vin.Vout),
			Witness:    vin.Witness,
			Sequence:   vin.Sequence,
			IsCoinbase: vin.Coinbase != "",
		}
		if vin.ScriptSig != nil {
			input.ScriptSigAsm = vin.ScriptSig.Asm
			input.ScriptSigHex = vin.ScriptSig.Hex
		}

		if !input.IsCoinbase && vin.TxID != "" {
			prevTx, err := h.engine.CoreRPC().GetRawTransaction(ctx, vin.TxID)
			if err == nil && vin.Vout >= 0 && vin.Vout < len(prevTx.Vout) {
				prevOut := prevTx.Vout[vin.Vout]
				input.ValueSats = int64(math.Round(prevOut.Value * 1e8))
				input.Address = prevOut.ScriptPubKey.Address
				totalInputSats += input.ValueSats
			}
		}

		inputs = append(inputs, input)
	}

	outputs := make([]*pb.TransactionOutput, 0, len(rawTx.Vout))
	totalOutputSats := int64(0)
	for i, vout := range rawTx.Vout {
		valueSats := int64(math.Round(vout.Value * 1e8))
		totalOutputSats += valueSats
		outputs = append(outputs, &pb.TransactionOutput{
			Index:           int32(i),
			ValueSats:       valueSats,
			Address:         vout.ScriptPubKey.Address,
			ScriptType:      vout.ScriptPubKey.Type,
			ScriptPubkeyAsm: vout.ScriptPubKey.Asm,
			ScriptPubkeyHex: vout.ScriptPubKey.Hex,
		})
	}

	feeSats := totalInputSats - totalOutputSats
	if feeSats < 0 {
		feeSats = 0
	}

	feeRateSatVb := 0.0
	if rawTx.Vsize > 0 {
		feeRateSatVb = float64(feeSats) / float64(rawTx.Vsize)
	}

	return connect.NewResponse(&pb.GetTransactionDetailsResponse{
		Transaction: &pb.TransactionEntry{
			Txid:          tx.TxID,
			Amount:        tx.Amount,
			AmountSats:    int64(math.Round(tx.Amount * 1e8)),
			Fee:           tx.Fee,
			Confirmations: int32(tx.Confirmations),
			BlockTime:     tx.BlockTime,
			Time:          tx.Time,
			WalletId:      walletID,
		},
		RawHex:          tx.Hex,
		Blockhash:       rawTx.Blockhash,
		Confirmations:   rawTx.Confirmations,
		BlockTime:       rawTx.BlockTime,
		Version:         rawTx.Version,
		Locktime:        rawTx.Locktime,
		SizeBytes:       rawTx.Size,
		VsizeVbytes:     rawTx.Vsize,
		WeightWu:        rawTx.Weight,
		FeeSats:         feeSats,
		FeeRateSatVb:    feeRateSatVb,
		Inputs:          inputs,
		TotalInputSats:  totalInputSats,
		Outputs:         outputs,
		TotalOutputSats: totalOutputSats,
	}), nil
}

func (h *WalletHandler) BumpFee(ctx context.Context, req *connect.Request[pb.BumpFeeRequest]) (*connect.Response[pb.BumpFeeResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	newTxID, err := h.engine.CoreRPC().BumpFee(ctx, coreName, req.Msg.Txid, req.Msg.NewFeeRate)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.BumpFeeResponse{
		NewTxid: newTxID,
	}), nil
}

func (h *WalletHandler) DeriveAddresses(ctx context.Context, req *connect.Request[pb.DeriveAddressesRequest]) (*connect.Response[pb.DeriveAddressesResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	count := int(req.Msg.Count)
	if count <= 0 {
		count = 20
	}

	start := int(req.Msg.StartIndex)
	end := start + count - 1

	// Build a descriptor for the wallet
	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// Get wallet seed and derive descriptor
	wallets := h.svc.GetAllWallets()
	var seedHex string
	for _, w := range wallets {
		if w.ID == walletID {
			seedHex = w.Master.SeedHex
			break
		}
	}
	if seedHex == "" {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("wallet %s seed not found", walletID))
	}

	addrs, err := h.engine.CoreRPC().DeriveAddresses(ctx, "", start, end)
	if err != nil {
		// Fallback: derive addresses without Core RPC by generating from wallet
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.DeriveAddressesResponse{
		Addresses: addrs,
	}), nil
}

// ============================================================================
// Seed access
// ============================================================================

func (h *WalletHandler) GetWalletSeed(ctx context.Context, req *connect.Request[pb.GetWalletSeedRequest]) (*connect.Response[pb.GetWalletSeedResponse], error) {
	walletID := req.Msg.WalletId

	wallets := h.svc.GetAllWallets()

	if walletID == "" {
		// Return enforcer wallet seed
		for _, w := range wallets {
			if w.WalletType == "enforcer" {
				return connect.NewResponse(&pb.GetWalletSeedResponse{
					SeedHex:  w.Master.SeedHex,
					Mnemonic: w.Master.Mnemonic,
				}), nil
			}
		}
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("no enforcer wallet found"))
	}

	for _, w := range wallets {
		if w.ID == walletID {
			return connect.NewResponse(&pb.GetWalletSeedResponse{
				SeedHex:  w.Master.SeedHex,
				Mnemonic: w.Master.Mnemonic,
			}), nil
		}
	}

	return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("wallet %s not found", walletID))
}

// ============================================================================
// Watch Wallet Data (server-streaming)
// ============================================================================

func (h *WalletHandler) WatchWalletData(ctx context.Context, req *connect.Request[emptypb.Empty], stream *connect.ServerStream[pb.WatchWalletDataResponse]) error {
	// Send initial state immediately.
	if err := h.sendWalletData(ctx, stream); err != nil {
		return err
	}

	// Debounce rapid state changes into one send.
	debounce := time.NewTimer(0)
	if !debounce.Stop() {
		<-debounce.C
	}
	pending := false

	// Fallback ticker: ensure state is sent at least every 5 seconds
	// even if no state changes are detected (e.g. balance changes from
	// new blocks come from Core, not from wallet.Service mutations).
	fallback := time.NewTicker(5 * time.Second)
	defer fallback.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()

		case <-h.svc.StateChanged:
			if !pending {
				debounce.Reset(50 * time.Millisecond)
				pending = true
			}

		case <-debounce.C:
			pending = false
			if err := h.sendWalletData(ctx, stream); err != nil {
				return err
			}

		case <-fallback.C:
			if err := h.sendWalletData(ctx, stream); err != nil {
				return err
			}
		}
	}
}

func (h *WalletHandler) sendWalletData(ctx context.Context, stream *connect.ServerStream[pb.WatchWalletDataResponse]) error {
	wallets := h.svc.GetAllWallets()
	activeID := h.svc.ActiveWalletID()
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		var gradientJSON string
		if w.Gradient != nil {
			gradientJSON = string(w.Gradient)
		}
		md := &pb.WalletMetadata{
			Id:               w.ID,
			Name:             w.Name,
			WalletType:       w.WalletType,
			GradientJson:     gradientJSON,
			CreatedAt:        w.CreatedAt.Format(time.RFC3339),
			Bip47PaymentCode: wallet.Bip47V3PaymentCodeFromSeed(w.Master.SeedHex),
		}
		// Starter material is sensitive; only attach it for the active wallet
		// so non-active entries don't broadcast it on every stream tick.
		if w.ID == activeID {
			md.MasterMnemonic = w.Master.Mnemonic
			md.L1Mnemonic = w.L1.Mnemonic
			md.Sidechains = make([]*pb.SidechainStarter, len(w.Sidechains))
			for j, sc := range w.Sidechains {
				md.Sidechains[j] = &pb.SidechainStarter{
					Slot:     int32(sc.Slot),
					Name:     sc.Name,
					Mnemonic: sc.Mnemonic,
				}
			}
		}
		pbWallets[i] = md
	}

	// Balance is fetched separately via GetBalance RPC when Core wallets are loaded.
	// WatchWalletData only streams wallet metadata — no Core dependency.
	var confirmedSats, unconfirmedSats float64

	return stream.Send(&pb.WatchWalletDataResponse{
		HasWallet:       h.svc.HasWallet(),
		Encrypted:       h.svc.IsEncrypted(),
		Unlocked:        h.svc.IsUnlocked(),
		ActiveWalletId:  activeID,
		Wallets:         pbWallets,
		ConfirmedSats:   confirmedSats,
		UnconfirmedSats: unconfirmedSats,
	})
}

// ============================================================================
// Helpers
// ============================================================================

func btcToSats(btc float64) float64 {
	return math.Round(btc * 1e8)
}

func satsToBtc(sats int64) float64 {
	return float64(sats) / 1e8
}
