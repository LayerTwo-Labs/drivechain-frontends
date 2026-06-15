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
	"github.com/btcsuite/btcd/chaincfg"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	orchestratorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
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

// Backend type for a wallet: which backend serves it. Watch-only is an
// orthogonal capability (the wallet's watch-only payload), not a provider.
const (
	walletTypeEnforcer    = "enforcer"
	walletTypeBitcoinCore = "bitcoinCore"
	walletTypeElectrum    = "electrum"
)

// walletTypeToProto maps the wallet's provider type onto the typed wire enum.
func walletTypeToProto(t string) pb.WalletType {
	switch t {
	case walletTypeEnforcer:
		return pb.WalletType_WALLET_TYPE_ENFORCER
	case walletTypeElectrum:
		return pb.WalletType_WALLET_TYPE_ELECTRUM
	case walletTypeBitcoinCore:
		return pb.WalletType_WALLET_TYPE_BITCOIN_CORE
	default:
		return pb.WalletType_WALLET_TYPE_UNSPECIFIED
	}
}

// WalletHandler implements the WalletManagerService gRPC handler.
type WalletHandler struct {
	svc        *wallet.Service
	engine     *wallet.WalletEngine       // nil until Core RPC is configured
	orch       *orchestrator.Orchestrator // nil until set; used for Core variant RPCs
	bip47State *bip47state.Store          // nil until SetBip47StateStore is called
}

func NewWalletHandler(svc *wallet.Service) *WalletHandler {
	return &WalletHandler{svc: svc}
}

// SetBip47StateStore wires the persistent BIP47 send state used by the
// orchestrator to derive per-payment indices and remember whether a
// notification tx has already been broadcast for a given recipient.
func (h *WalletHandler) SetBip47StateStore(store *bip47state.Store) {
	h.bip47State = store
}

// SetEngine sets the wallet engine (called after Core RPC config is available).
func (h *WalletHandler) SetEngine(engine *wallet.WalletEngine) {
	h.engine = engine
}

// SetOrchestrator wires the orchestrator so Core variant RPCs can drive
// download/restart flows without each handler call rebuilding context.
func (h *WalletHandler) SetOrchestrator(orch *orchestrator.Orchestrator) {
	h.orch = orch
}

// walletSeedHex returns the master seed hex for a wallet, or "" if not found.
func (h *WalletHandler) walletSeedHex(walletID string) string {
	for _, w := range h.svc.GetAllWallets() {
		if w.ID == walletID {
			return w.Master.SeedHex
		}
	}
	return ""
}

// bip47NetParams returns the chaincfg.Params for the BIP47 coin_type level.
// Returns nil when the engine isn't wired yet — wallet.Bip47PaymentCodeFromSeed
// treats nil as mainnet, matching pre-fix behavior.
func (h *WalletHandler) bip47NetParams() *chaincfg.Params {
	if h.engine == nil {
		return nil
	}
	return h.engine.Network()
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
		// Watch-only wallets hold no seed, so BIP47 derivation is both pointless
		// and noisy (it errors on the empty seed); skip it.
		var bip47Code string
		// Electrum wallets advertise no BIP47 code: inbound BIP47 (BIP47Engine)
		// only watches bitcoinCore wallets, so a published code would receive
		// payments the wallet never discovers.
		if !w.IsWatchOnly() && w.WalletType != "electrum" {
			code, err := wallet.Bip47PaymentCodeFromSeed(w.Master.SeedHex, h.bip47NetParams())
			if err != nil {
				h.svc.Log().Error().Err(err).Str("wallet_id", w.ID).Msg("ListWallets: bip47 derivation failed")
			}
			bip47Code = code
		}
		pbWallets[i] = &pb.WalletMetadata{
			Id:               w.ID,
			Name:             w.Name,
			WalletType:       walletTypeToProto(w.WalletType),
			WatchOnly:        w.IsWatchOnly(),
			GradientJson:     gradientJSON,
			CreatedAt:        w.CreatedAt.Format(time.RFC3339),
			Bip47PaymentCode: bip47Code,
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
	h.ensureL1ForWallet(req.Msg.WalletId)
	return connect.NewResponse(&pb.SwitchWalletResponse{}), nil
}

// ensureL1ForWallet starts the local L1 stack when switching to a wallet that
// needs it (anything but electrum). Booting on an electrum wallet skips L1, so
// a later switch to a Core/enforcer wallet would otherwise find bitcoind down.
// StartWithL1 is idempotent — it adopts a running stack and boots one
// otherwise — so this is safe to call on every switch.
func (h *WalletHandler) ensureL1ForWallet(walletID string) {
	if h.orch == nil || !h.walletNeedsL1(walletID) {
		return
	}
	go func() {
		if _, err := h.orch.StartWithL1(context.Background(), "enforcer", orchestrator.StartOpts{}); err != nil {
			h.svc.Log().Warn().Err(err).Str("wallet_id", walletID).Msg("ensure L1 after wallet switch failed")
		}
	}()
}

// walletNeedsL1 reports whether a wallet requires the local L1 stack: every
// type except electrum (which serves chain data remotely).
func (h *WalletHandler) walletNeedsL1(walletID string) bool {
	w := h.svc.GetWalletByID(walletID)
	return w != nil && w.WalletType != "electrum"
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

func (h *WalletHandler) ListWalletBackups(ctx context.Context, req *connect.Request[pb.ListWalletBackupsRequest]) (*connect.Response[pb.ListWalletBackupsResponse], error) {
	backups, err := h.svc.ListWalletBackups()
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	resp := &pb.ListWalletBackupsResponse{Backups: make([]*pb.WalletBackup, 0, len(backups))}
	for _, backup := range backups {
		resp.Backups = append(resp.Backups, walletBackupToProto(backup))
	}
	return connect.NewResponse(resp), nil
}

func (h *WalletHandler) RestoreWalletBackup(ctx context.Context, req *connect.Request[pb.RestoreWalletBackupRequest]) (*connect.Response[pb.RestoreWalletBackupResponse], error) {
	if err := h.svc.RestoreWalletBackup(req.Msg.BackupId, req.Msg.Password); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.RestoreWalletBackupResponse{}), nil
}

func (h *WalletHandler) RestoreWalletBackupStream(ctx context.Context, req *connect.Request[pb.RestoreWalletBackupRequest], stream *connect.ServerStream[pb.RestoreWalletBackupProgressResponse]) error {
	steps, err := h.svc.RestoreWalletBackupPlan(req.Msg.BackupId)
	if err != nil {
		return connect.NewError(connect.CodeInvalidArgument, err)
	}

	planned := make([]*pb.RestoreWalletBackupStep, 0, len(steps))
	for _, step := range steps {
		planned = append(planned, &pb.RestoreWalletBackupStep{
			StepId: step.ID,
			Name:   step.Name,
		})
	}
	if err := stream.Send(&pb.RestoreWalletBackupProgressResponse{Steps: planned}); err != nil {
		return err
	}

	var sendErr error
	sendProgress := func(stepID string, status wallet.RestoreWalletBackupStepStatus, stepErr error) {
		if sendErr != nil {
			return
		}
		msg := &pb.RestoreWalletBackupProgressResponse{
			Status: &pb.RestoreWalletBackupProgressStatus{
				StepId: stepID,
				State:  restoreStepStatusToProto(status),
			},
		}
		if stepErr != nil {
			msg.Status.Error = stepErr.Error()
		}
		if err := stream.Send(msg); err != nil {
			sendErr = err
		}
	}

	if err := h.svc.RestoreWalletBackupWithProgress(req.Msg.BackupId, req.Msg.Password, sendProgress); err != nil {
		if sendErr != nil {
			return sendErr
		}
		return connect.NewError(connect.CodeInvalidArgument, err)
	}
	if sendErr != nil {
		return sendErr
	}

	return stream.Send(&pb.RestoreWalletBackupProgressResponse{
		Status: &pb.RestoreWalletBackupProgressStatus{
			Complete: true,
			State:    pb.RestoreWalletBackupStepState_RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED,
		},
	})
}

func (h *WalletHandler) CreateWatchOnlyWallet(ctx context.Context, req *connect.Request[pb.CreateWatchOnlyWalletRequest]) (*connect.Response[pb.CreateWatchOnlyWalletResponse], error) {
	if err := h.svc.CreateWatchOnlyWallet(req.Msg.Name, req.Msg.XpubOrDescriptor, req.Msg.GradientJson); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.CreateWatchOnlyWalletResponse{
		WalletId: h.svc.ActiveWalletID(),
	}), nil
}

func (h *WalletHandler) CreateElectrumWallet(ctx context.Context, req *connect.Request[pb.CreateElectrumWalletRequest]) (*connect.Response[pb.CreateElectrumWalletResponse], error) {
	if h.engine == nil || !h.engine.ElectrumConfigured() {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("electrum wallets are not supported on this network: no Esplora backend configured"))
	}
	w, err := h.svc.CreateElectrumWallet(req.Msg.Name, json.RawMessage(req.Msg.GradientJson), req.Msg.Slots, req.Msg.CustomMnemonic, req.Msg.XpubOrDescriptor, req.Msg.ScriptType)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.CreateElectrumWalletResponse{
		WalletId: w.ID,
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

// rpcError passes through errors that already carry a connect code and
// wraps everything else as internal.
func rpcError(err error) error {
	var ce *connect.Error
	if errors.As(err, &ce) {
		return ce
	}
	return connect.NewError(connect.CodeInternal, err)
}

func (h *WalletHandler) CreateBitcoinCoreWallet(ctx context.Context, req *connect.Request[pb.CreateBitcoinCoreWalletRequest]) (*connect.Response[pb.CreateBitcoinCoreWalletResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	name, err := h.engine.Backend().Ensure(ctx, req.Msg.WalletId)
	if err != nil {
		// Bitcoin Core mid-startup (-28) or already loading the wallet (-4) is
		// not an internal failure — it's "try again in a few seconds". Return
		// Unavailable so the Dart logging filter quiets it and the UI doesn't
		// flash an error toast every poll cycle.
		if wallet.IsTransientWalletErr(err) {
			return nil, connect.NewError(connect.CodeUnavailable, err)
		}
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

	count, err := h.engine.Backend().EnsureAll(ctx)
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

	confirmed, unconfirmed, err := h.engine.Backend().Balance(ctx, walletID)
	if err != nil {
		return nil, rpcError(err)
	}

	confirmedSats := btcToSats(confirmed)
	unconfirmedSats := btcToSats(unconfirmed)
	_ = h.svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, walletID, uint64(math.Round(confirmedSats)), uint64(math.Round(unconfirmedSats)), "Bitcoin")

	return connect.NewResponse(&pb.GetBalanceResponse{
		ConfirmedSats:   confirmedSats,
		UnconfirmedSats: unconfirmedSats,
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

	addr, err := h.engine.Backend().NextReceiveAddress(ctx, walletID)
	if err != nil {
		return nil, rpcError(err)
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

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	// Resolve any BIP47 payment-code destinations into per-payment addresses
	// before the dust check so we validate against the substituted address.
	expansion, err := h.expandBip47Destinations(ctx, walletID, req.Msg.Destinations)
	if err != nil {
		return nil, err
	}
	if expansion.notificationTxHex != "" || !destinationsEqual(expansion.destinations, req.Msg.Destinations) {
		req = connect.NewRequest(applyDestinationsToRequest(req.Msg, expansion.destinations))
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

	if expansion.notificationTxHex != "" {
		notifTxID, err := h.broadcastBip47Notification(ctx, walletID, expansion.recipientCode, expansion.notificationTxHex)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("broadcast bip47 notification: %w", err))
		}
		_ = notifTxID
	}

	sendReq := wallet.SendRequest{
		DestinationsSats:      req.Msg.Destinations,
		FeeRateSatPerVB:       req.Msg.FeeRateSatPerVbyte,
		FixedFeeSats:          req.Msg.FixedFeeSats,
		OpReturnHex:           req.Msg.OpReturnHex,
		SubtractFeeFromAmount: req.Msg.SubtractFeeFromAmount,
		ReplayProtect:         req.Msg.ReplayProtect,
	}
	for _, u := range req.Msg.RequiredInputs {
		sendReq.RequiredInputs = append(sendReq.RequiredInputs, wallet.RequiredInput{
			TxID:       u.Txid,
			Vout:       int(u.Vout),
			AmountSats: u.AmountSats,
		})
	}

	txid, err := h.engine.Backend().Send(ctx, walletID, sendReq)
	if err != nil {
		return nil, rpcError(err)
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

	count := int(req.Msg.Count)
	if count <= 0 {
		count = 100
	}

	txs, err := h.engine.Backend().ListTransactions(ctx, walletID, count)
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

	utxos, err := h.engine.Backend().ListUnspent(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	txTimes := h.fetchCoreTxTimes(ctx, walletID, utxos)

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
			ReceivedAt:    receivedAt(u, txTimes),
		}
	}

	return connect.NewResponse(&pb.ListUnspentResponse{
		Utxos: pbUTXOs,
	}), nil
}

// receivedAt prefers the provider-supplied per-UTXO time, falling back to
// the wallet-tx lookup.
func receivedAt(u wallet.UTXO, txTimes map[string]*timestamppb.Timestamp) *timestamppb.Timestamp {
	if u.ReceivedAt > 0 {
		return timestamppb.New(time.Unix(u.ReceivedAt, 0))
	}
	return txTimes[u.TxID]
}

// fetchCoreTxTimes returns, for each unique txid in utxos lacking a
// provider-supplied ReceivedAt, the wallet's time_received falling back to
// blocktime then time. Best-effort: failures omit the txid.
func (h *WalletHandler) fetchCoreTxTimes(ctx context.Context, walletID string, utxos []wallet.UTXO) map[string]*timestamppb.Timestamp {
	seen := make(map[string]struct{}, len(utxos))
	out := make(map[string]*timestamppb.Timestamp, len(utxos))
	for _, u := range utxos {
		if u.ReceivedAt > 0 {
			continue
		}
		if _, ok := seen[u.TxID]; ok {
			continue
		}
		seen[u.TxID] = struct{}{}

		tx, err := h.engine.Backend().GetWalletTransaction(ctx, walletID, u.TxID)
		if err != nil {
			continue
		}
		switch {
		case tx.TimeReceived > 0:
			out[u.TxID] = timestamppb.New(time.Unix(tx.TimeReceived, 0))
		case tx.BlockTime > 0:
			out[u.TxID] = timestamppb.New(time.Unix(tx.BlockTime, 0))
		case tx.Time > 0:
			out[u.TxID] = timestamppb.New(time.Unix(tx.Time, 0))
		}
	}
	return out
}

func (h *WalletHandler) ListReceiveAddresses(ctx context.Context, req *connect.Request[pb.ListReceiveAddressesRequest]) (*connect.Response[pb.ListReceiveAddressesResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	addrs, err := h.engine.Backend().ListReceivedByAddress(ctx, walletID)
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

	tx, err := h.engine.Backend().GetWalletTransaction(ctx, walletID, req.Msg.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	rawTx, err := h.engine.ChainForWallet(walletID).GetRawTransaction(ctx, req.Msg.Txid)
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
			prevTx, err := h.engine.ChainForWallet(walletID).GetRawTransaction(ctx, vin.TxID)
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

	newTxID, err := h.engine.Backend().BumpFee(ctx, walletID, req.Msg.Txid, req.Msg.NewFeeRate)
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

	addrs, err := wallet.DeriveBIP84Addresses(seedHex, h.engine.Network(), start, count)
	if err != nil {
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
	var seq int64

	if err := h.sendWalletData(stream, &seq); err != nil {
		return err
	}

	debounce := time.NewTimer(0)
	if !debounce.Stop() {
		<-debounce.C
	}
	pending := false

	// Heartbeat: idle keepalive so the client's watchdog can distinguish
	// a quiet stream from a half-open connection. Reset whenever a real
	// frame goes out so we don't double up.
	heartbeat := time.NewTicker(WatchHeartbeatInterval)
	defer heartbeat.Stop()

	// Per-stream subscription. The wallet service fans out notifyChanged to
	// every subscriber, so concurrent Watch streams don't steal each other's
	// events. ctx scopes the subscription to this stream's lifetime.
	stateChanged := h.svc.Subscribe(ctx)

	send := func() error {
		if err := h.sendWalletData(stream, &seq); err != nil {
			return err
		}
		heartbeat.Reset(WatchHeartbeatInterval)
		return nil
	}

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()

		case <-stateChanged:
			if !pending {
				debounce.Reset(50 * time.Millisecond)
				pending = true
			}

		case <-debounce.C:
			pending = false
			if err := send(); err != nil {
				return err
			}

		case <-heartbeat.C:
			seq++
			if err := stream.Send(&pb.WatchWalletDataResponse{
				Seq:       seq,
				Heartbeat: true,
			}); err != nil {
				return err
			}
		}
	}
}

func (h *WalletHandler) sendWalletData(stream *connect.ServerStream[pb.WatchWalletDataResponse], seq *int64) error {
	resp := buildWatchWalletDataResponse(
		h.svc.GetAllWallets(),
		h.svc.ActiveWalletID(),
		h.svc.HasWallet(),
		h.svc.IsEncrypted(),
		h.svc.IsUnlocked(),
		h.bip47NetParams(),
		bip47Logger(h.svc),
	)
	*seq++
	resp.Seq = *seq
	return stream.Send(resp)
}

// bip47Logger returns a callback that surfaces BIP47 derivation errors via
// the wallet service's logger. Returning the error path silently as ""
// reads in the UI as an indefinite spinner — the loader sticks until a
// non-empty payment code arrives — so the error MUST be observable.
func bip47Logger(svc *wallet.Service) func(walletID string, err error) {
	return func(walletID string, err error) {
		svc.Log().Error().Err(err).Str("wallet_id", walletID).Msg("bip47 derivation failed")
	}
}

func buildWatchWalletDataResponse(wallets []wallet.WalletData, activeID string, hasWallet, encrypted, unlocked bool, netParams *chaincfg.Params, onBip47Err func(walletID string, err error)) *pb.WatchWalletDataResponse {
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		var gradientJSON string
		if w.Gradient != nil {
			gradientJSON = string(w.Gradient)
		}
		// Watch-only wallets hold no seed; skip BIP47 derivation on them.
		var bip47Code string
		// Electrum wallets advertise no BIP47 code: inbound BIP47 (BIP47Engine)
		// only watches bitcoinCore wallets, so a published code would receive
		// payments the wallet never discovers.
		if !w.IsWatchOnly() && w.WalletType != "electrum" {
			code, err := wallet.Bip47PaymentCodeFromSeed(w.Master.SeedHex, netParams)
			if err != nil && onBip47Err != nil {
				onBip47Err(w.ID, err)
			}
			bip47Code = code
		}
		md := &pb.WalletMetadata{
			Id:               w.ID,
			Name:             w.Name,
			WalletType:       walletTypeToProto(w.WalletType),
			WatchOnly:        w.IsWatchOnly(),
			GradientJson:     gradientJSON,
			CreatedAt:        w.CreatedAt.Format(time.RFC3339),
			Bip47PaymentCode: bip47Code,
		}
		// Starter material lives only on the enforcer wallet (L1 mnemonic and
		// sidechain starters are derived from its seed). Attach it to that
		// wallet's metadata so the Dart side can find it whether or not the
		// active wallet happens to be the enforcer.
		if w.WalletType == walletTypeEnforcer {
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
	return &pb.WatchWalletDataResponse{
		HasWallet:      hasWallet,
		Encrypted:      encrypted,
		Unlocked:       unlocked,
		ActiveWalletId: activeID,
		Wallets:        pbWallets,
	}
}

// ============================================================================
// Core variant RPCs
// ============================================================================

func (h *WalletHandler) ListCoreVariants(ctx context.Context, req *connect.Request[pb.ListCoreVariantsRequest]) (*connect.Response[pb.ListCoreVariantsResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not configured"))
	}
	specs := h.orch.ListCoreVariants()
	out := make([]*pb.CoreVariant, 0, len(specs))
	for _, v := range specs {
		out = append(out, &pb.CoreVariant{
			Id:          v.ID,
			DisplayName: coreVariantDisplayName(v.ID),
			Installed:   orchestrator.CoreVariantInstalled(h.orch.DataDir, v, "bitcoind"),
		})
	}
	// Display order: Patched first (default), Core second, Knots third.
	// Anything else sorts alphabetically after.
	sort.Slice(out, func(i, j int) bool {
		return coreVariantOrder(out[i].Id) < coreVariantOrder(out[j].Id)
	})

	// Clamp active_id to the visible list. The persisted ID is fine to keep
	// on disk — but the UI dropdown will throw when given a value that isn't
	// one of its items, so an out-of-list active surfaces as "".
	activeID := h.orch.CoreVariant()
	visible := false
	for _, v := range out {
		if v.Id == activeID {
			visible = true
			break
		}
	}
	if !visible {
		activeID = ""
	}
	return connect.NewResponse(&pb.ListCoreVariantsResponse{
		Variants: out,
		ActiveId: activeID,
	}), nil
}

func (h *WalletHandler) GetCoreVariant(ctx context.Context, req *connect.Request[pb.GetCoreVariantRequest]) (*connect.Response[pb.GetCoreVariantResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not configured"))
	}
	return connect.NewResponse(&pb.GetCoreVariantResponse{Id: h.orch.CoreVariant()}), nil
}

func (h *WalletHandler) SetCoreVariant(ctx context.Context, req *connect.Request[pb.SetCoreVariantRequest]) (*connect.Response[pb.SetCoreVariantResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not configured"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("variant id required"))
	}
	if err := h.orch.SetCoreVariant(ctx, req.Msg.Id); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.SetCoreVariantResponse{}), nil
}

// ============================================================================
// Test-sidechains toggle
// ============================================================================

func (h *WalletHandler) GetTestSidechains(ctx context.Context, req *connect.Request[pb.GetTestSidechainsRequest]) (*connect.Response[pb.GetTestSidechainsResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not configured"))
	}
	return connect.NewResponse(&pb.GetTestSidechainsResponse{Enabled: h.orch.UseTestSidechains()}), nil
}

func (h *WalletHandler) SetTestSidechains(ctx context.Context, req *connect.Request[pb.SetTestSidechainsRequest]) (*connect.Response[pb.SetTestSidechainsResponse], error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("orchestrator not configured"))
	}
	if err := h.orch.SetTestSidechains(ctx, req.Msg.Enabled); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&pb.SetTestSidechainsResponse{}), nil
}

func coreVariantDisplayName(id string) string {
	switch id {
	case "core":
		return "Bitcoin Core"
	case "patched":
		return "Bitcoin Patched"
	case "knots":
		return "Knots"
	default:
		return id
	}
}

// coreVariantOrder is the dropdown sort key. Lower wins. Anything outside
// the named list sorts last (and tied entries fall back to ID order
// implicitly via the sort.Slice contract).
func coreVariantOrder(id string) int {
	switch id {
	case "patched":
		return 0
	case "core":
		return 1
	case "knots":
		return 2
	default:
		return 99
	}
}

func walletBackupToProto(backup wallet.WalletBackupInfo) *pb.WalletBackup {
	out := &pb.WalletBackup{
		BackupId:       backup.ID,
		SourceName:     backup.SourceName,
		Encrypted:      backup.Encrypted,
		HasMetadata:    backup.HasMetadata,
		ActiveWalletId: backup.ActiveWalletID,
		Valid:          backup.Valid,
		ErrorMessage:   backup.ErrorMessage,
	}
	if !backup.CreatedAt.IsZero() {
		out.CreatedAt = timestamppb.New(backup.CreatedAt)
	}
	for _, w := range backup.Wallets {
		out.Wallets = append(out.Wallets, &pb.BackupWalletSummary{
			Id:         w.ID,
			Name:       w.Name,
			WalletType: w.WalletType,
		})
	}
	for _, b := range backup.LatestKnownBalance {
		out.LatestKnownBalance = append(out.LatestKnownBalance, &pb.BalanceSnapshot{
			Binary:        b.Binary,
			DisplayName:   b.DisplayName,
			ConfirmedSats: b.ConfirmedSats,
			PendingSats:   b.PendingSats,
		})
		if !b.UpdatedAt.IsZero() {
			out.LatestKnownBalance[len(out.LatestKnownBalance)-1].UpdatedAt = timestamppb.New(b.UpdatedAt)
		}
	}
	return out
}

func restoreStepStatusToProto(status wallet.RestoreWalletBackupStepStatus) pb.RestoreWalletBackupStepState {
	switch status {
	case wallet.RestoreWalletBackupStepStarted:
		return pb.RestoreWalletBackupStepState_RESTORE_WALLET_BACKUP_STEP_STATE_STARTED
	case wallet.RestoreWalletBackupStepCompleted:
		return pb.RestoreWalletBackupStepState_RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED
	case wallet.RestoreWalletBackupStepFailed:
		return pb.RestoreWalletBackupStepState_RESTORE_WALLET_BACKUP_STEP_STATE_FAILED
	default:
		return pb.RestoreWalletBackupStepState_RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED
	}
}

// ============================================================================
// Helpers
// ============================================================================

func btcToSats(btc float64) float64 {
	return math.Round(btc * 1e8)
}

func (h *WalletHandler) CreatePsbt(ctx context.Context, req *connect.Request[pb.CreatePsbtRequest]) (*connect.Response[pb.CreatePsbtResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	sendReq := wallet.SendRequest{
		DestinationsSats:      req.Msg.Destinations,
		FeeRateSatPerVB:       req.Msg.FeeRateSatPerVbyte,
		FixedFeeSats:          req.Msg.FixedFeeSats,
		OpReturnHex:           req.Msg.OpReturnHex,
		SubtractFeeFromAmount: req.Msg.SubtractFeeFromAmount,
	}
	for _, u := range req.Msg.RequiredInputs {
		sendReq.RequiredInputs = append(sendReq.RequiredInputs, wallet.RequiredInput{
			TxID: u.Txid, Vout: int(u.Vout), AmountSats: u.AmountSats,
		})
	}
	b64, err := h.engine.CreatePSBT(ctx, walletID, sendReq)
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.CreatePsbtResponse{PsbtBase64: b64}), nil
}

func (h *WalletHandler) SignPsbt(ctx context.Context, req *connect.Request[pb.SignPsbtRequest]) (*connect.Response[pb.SignPsbtResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	walletID, err := h.engine.ResolveWalletID(req.Msg.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	out, err := h.engine.SignPSBT(ctx, walletID, req.Msg.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.SignPsbtResponse{PsbtBase64: out}), nil
}

func (h *WalletHandler) CombinePsbt(ctx context.Context, req *connect.Request[pb.CombinePsbtRequest]) (*connect.Response[pb.CombinePsbtResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	out, err := h.engine.CombinePSBT(req.Msg.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.CombinePsbtResponse{PsbtBase64: out}), nil
}

func (h *WalletHandler) FinalizePsbt(ctx context.Context, req *connect.Request[pb.FinalizePsbtRequest]) (*connect.Response[pb.FinalizePsbtResponse], error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}
	rawHex, err := h.engine.FinalizePSBT(req.Msg.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return connect.NewResponse(&pb.FinalizePsbtResponse{RawTxHex: rawHex}), nil
}
