package api

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var _ rpc.WalletManagerServiceHandler = new(WalletHandler)

// WalletHandler implements the WalletManagerService gRPC handler.
type WalletHandler struct {
	svc    *wallet.Service
	engine *wallet.WalletEngine // nil until Core RPC is configured
}

func NewWalletHandler(svc *wallet.Service) *WalletHandler {
	return &WalletHandler{svc: svc}
}

// SetEngine sets the wallet engine (called after Core RPC config is available).
func (h *WalletHandler) SetEngine(engine *wallet.WalletEngine) {
	h.engine = engine
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
	w, err := h.svc.GenerateWallet(req.Msg.Name, req.Msg.CustomMnemonic, req.Msg.Passphrase, nil)
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
		var gradientJSON string
		if w.Gradient != nil {
			gradientJSON = string(w.Gradient)
		}
		pbWallets[i] = &pb.WalletMetadata{
			Id:           w.ID,
			Name:         w.Name,
			WalletType:   w.WalletType,
			GradientJson: gradientJSON,
			CreatedAt:    w.CreatedAt.Format(time.RFC3339),
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

	addr, err := h.engine.CoreRPC().GetNewAddress(ctx, coreName, "", "bech32")
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: addr,
	}), nil
}

func (h *WalletHandler) SendTransaction(ctx context.Context, req *connect.Request[pb.SendTransactionRequest]) (*connect.Response[pb.SendTransactionResponse], error) {
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

func (h *WalletHandler) ListTransactions(ctx context.Context, req *connect.Request[pb.ListTransactionsRequest]) (*connect.Response[pb.ListTransactionsResponse], error) {
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
		RawHex: tx.Hex,
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
					SeedHex: w.Master.SeedHex,
				}), nil
			}
		}
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("no enforcer wallet found"))
	}

	for _, w := range wallets {
		if w.ID == walletID {
			return connect.NewResponse(&pb.GetWalletSeedResponse{
				SeedHex: w.Master.SeedHex,
			}), nil
		}
	}

	return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("wallet %s not found", walletID))
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
