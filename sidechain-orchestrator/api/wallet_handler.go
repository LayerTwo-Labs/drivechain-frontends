package api

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"sort"
	"strings"
	"sync"
	"time"

	"buf.build/go/protovalidate"
	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/fork"
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
	return orchestrator.WalletSidechainSlots()
}

var _ rpc.WalletManagerServiceHandler = new(WalletHandler)

// walletTypeToProto maps the wallet's provider type onto the typed wire enum.
func walletStateToProto(s wallet.State) pb.WalletState {
	switch s {
	case wallet.StateNoWallet:
		return pb.WalletState_WALLET_STATE_NO_WALLET
	case wallet.StateLocked:
		return pb.WalletState_WALLET_STATE_LOCKED
	case wallet.StateUnlocked:
		return pb.WalletState_WALLET_STATE_UNLOCKED
	default:
		return pb.WalletState_WALLET_STATE_UNSPECIFIED
	}
}

func walletTypeToProto(t wallet.WalletType) pb.WalletType {
	switch t {
	case wallet.WalletTypeEnforcer:
		return pb.WalletType_WALLET_TYPE_ENFORCER
	case wallet.WalletTypeElectrum:
		return pb.WalletType_WALLET_TYPE_ELECTRUM
	case wallet.WalletTypeBitcoinCore:
		return pb.WalletType_WALLET_TYPE_BITCOIN_CORE
	default:
		return pb.WalletType_WALLET_TYPE_UNSPECIFIED
	}
}

// WalletHandler implements the WalletManagerService gRPC handler.
type WalletHandler struct {
	svc             *wallet.Service
	engine          *wallet.WalletEngine       // nil until Core RPC is configured
	orch            *orchestrator.Orchestrator // nil until set; used for Core variant RPCs
	bip47State      *bip47state.Store          // nil until SetBip47StateStore is called
	ecxBurnWarnings sync.Map
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

func (h *WalletHandler) GetWalletStatus(ctx context.Context, req *pb.GetWalletStatusRequest) (*pb.GetWalletStatusResponse, error) {
	state := h.svc.State()
	return &pb.GetWalletStatusResponse{
		HasWallet:        state != wallet.StateNoWallet, //nolint:staticcheck // old apps read it
		Encrypted:        h.svc.IsEncrypted(),
		Unlocked:         state == wallet.StateUnlocked, //nolint:staticcheck // old apps read it
		ActiveWalletId:   h.svc.ActiveWalletID(),
		ActiveWalletName: h.svc.ActiveWalletName(),
		State:            walletStateToProto(state),
	}, nil
}

func (h *WalletHandler) GenerateWallet(ctx context.Context, req *pb.GenerateWalletRequest) (*pb.GenerateWalletResponse, error) {
	account, path, err := wallet.ResolveCreateDerivationPath(req.Account, req.DerivationPath)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	if _, err := wallet.ResolveScriptType(req.ScriptType, path); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	w, err := h.svc.GenerateWalletWithPath(req.Name, req.CustomMnemonic, req.Passphrase, account, path, req.ScriptType, allSidechainSlots())
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.GenerateWalletResponse{
		WalletId: w.ID,
		Mnemonic: w.Master.Mnemonic,
	}, nil
}

func (h *WalletHandler) UnlockWallet(ctx context.Context, req *pb.UnlockWalletRequest) (*pb.UnlockWalletResponse, error) {
	if err := h.svc.UnlockWallet(req.Password); err != nil {
		return nil, rpcError(err)
	}
	return &pb.UnlockWalletResponse{}, nil
}

func (h *WalletHandler) LockWallet(ctx context.Context, req *pb.LockWalletRequest) (*pb.LockWalletResponse, error) {
	h.svc.LockWallet()
	return &pb.LockWalletResponse{}, nil
}

func (h *WalletHandler) EncryptWallet(ctx context.Context, req *pb.EncryptWalletRequest) (*pb.EncryptWalletResponse, error) {
	if err := h.svc.EncryptWallet(req.Password); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.EncryptWalletResponse{}, nil
}

func (h *WalletHandler) ChangePassword(ctx context.Context, req *pb.ChangePasswordRequest) (*pb.ChangePasswordResponse, error) {
	if err := h.svc.ChangePassword(req.OldPassword, req.NewPassword); err != nil {
		return nil, rpcError(err)
	}
	return &pb.ChangePasswordResponse{}, nil
}

func (h *WalletHandler) RemoveEncryption(ctx context.Context, req *pb.RemoveEncryptionRequest) (*pb.RemoveEncryptionResponse, error) {
	if err := h.svc.RemoveEncryption(req.Password); err != nil {
		return nil, rpcError(err)
	}
	return &pb.RemoveEncryptionResponse{}, nil
}

func (h *WalletHandler) ListWallets(ctx context.Context, req *pb.ListWalletsRequest) (*pb.ListWalletsResponse, error) {
	// Use GetAllWallets so we can access the seed for BIP47 derivation —
	// parity with sendWalletData. ListWallets (metadata-only) can't see it.
	wallets := h.svc.GetAllWallets()
	starterID := h.svc.StarterWalletID()
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		var gradientJSON string
		if w.Gradient != nil {
			gradientJSON = string(w.Gradient)
		}
		// Watch-only wallets hold no seed, so BIP47 derivation is both pointless
		// and noisy (it errors on the empty seed); skip it. Advertise only for
		// BIP47-capable backends (Core + electrum), the wallets the engine watches.
		var bip47Code string
		// BIP47 derives from a single master seed, which multisig and watch-only
		// wallets don't have — skip them rather than derive from an empty seed.
		if w.Master.SeedHex != "" && !w.IsWatchOnly() && h.bip47Capable(w.ID) {
			code, err := wallet.Bip47PaymentCodeFromSeed(w.Master.SeedHex, h.bip47NetParams())
			if err != nil {
				h.svc.Log().Error().Err(err).Str("wallet_id", w.ID).Msg("ListWallets: bip47 derivation failed")
			}
			bip47Code = code
		}
		pbWallets[i] = &pb.WalletMetadata{
			Id:                  w.ID,
			Name:                w.Name,
			WalletType:          walletTypeToProto(w.WalletType),
			WatchOnly:           w.IsWatchOnly(),
			HardwareDeviceType:  w.HardwareDeviceType(),
			HardwareFingerprint: w.HardwareFingerprint(),
			GradientJson:        gradientJSON,
			CreatedAt:           w.CreatedAt.Format(time.RFC3339),
			Bip47PaymentCode:    bip47Code,
			Multisig:            multisigInfoProto(&w),
			ReceiveAddressTypes: receiveAddressTypesProto(&w),
			IsStarter:           w.ID == starterID,
			ScriptType:          w.ScriptType,
			AccountIndex:        w.AccountIndex,
			DerivationPath:      w.DerivationPath,
		}
	}
	return &pb.ListWalletsResponse{
		Wallets:        pbWallets,
		ActiveWalletId: h.svc.ActiveWalletID(),
	}, nil
}

// receiveAddressTypesProto lists the address types a wallet derives, its own
// kind first, so the frontend asks for one the wallet can actually serve.
func receiveAddressTypesProto(w *wallet.WalletData) []pb.AddressType {
	return lo.FilterMap(wallet.ReceiveKinds(w), func(k wallet.ScriptKind, _ int) (pb.AddressType, bool) {
		switch k {
		case wallet.ScriptNativeSegwit:
			return pb.AddressType_ADDRESS_TYPE_SEGWIT, true
		case wallet.ScriptTaproot:
			return pb.AddressType_ADDRESS_TYPE_TAPROOT, true
		default:
			return pb.AddressType_ADDRESS_TYPE_UNSPECIFIED, false
		}
	})
}

func (h *WalletHandler) SwitchWallet(ctx context.Context, req *pb.SwitchWalletRequest) (*pb.SwitchWalletResponse, error) {
	// Switching onto a Core/enforcer wallet is what makes the local chain
	// necessary, so it goes through the same planner a network swap does.
	if h.orch != nil {
		if dataDir := strings.TrimSpace(req.DataDir); dataDir != "" {
			// Persisting an unusable directory would satisfy the planner and
			// then stop prompting, with no chain to run from.
			if err := validateDirWritable(dataDir); err != nil {
				return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
			}
			if err := h.orch.SetDatadirForCurrentNetwork(dataDir); err != nil {
				return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
			}
		}
		plan := h.orch.PlanNetworkChange(orchestrator.NetworkChangeRequest{WalletID: req.WalletId})
		if plan.MustSelectDatadir {
			return nil, requirementsUnmet(plan)
		}
		if plan.NoChainSource {
			return nil, connect.Errorf(connect.CodeFailedPrecondition,
				"%s has no chain source for an electrum wallet", plan.Network)
		}
	}

	if err := h.svc.SwitchWallet(req.WalletId); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	}
	h.ensureL1ForWallet(req.WalletId)
	return &pb.SwitchWalletResponse{}, nil
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
		progress, err := h.orch.StartWithL1(context.Background(), "enforcer", orchestrator.StartOpts{})
		if err != nil {
			h.svc.Log().Warn().Err(err).Str("wallet_id", walletID).Msg("ensure L1 after wallet switch failed")
			return
		}
		// Unread progress fills the channel and blocks the boot mid-download.
		for p := range progress {
			if p.Error != nil {
				h.svc.Log().Warn().Err(p.Error).Str("wallet_id", walletID).Msg("L1 boot after wallet switch failed")
			}
		}
	}()
}

// walletNeedsL1 reports whether a wallet requires the local L1 stack: every
// type except electrum (which serves chain data remotely).
func (h *WalletHandler) walletNeedsL1(walletID string) bool {
	w := h.svc.GetWalletByID(walletID)
	return w != nil && w.WalletType != wallet.WalletTypeElectrum
}

func (h *WalletHandler) UpdateWalletMetadata(ctx context.Context, req *pb.UpdateWalletMetadataRequest) (*pb.UpdateWalletMetadataResponse, error) {
	var gradient json.RawMessage
	if req.GradientJson != "" {
		gradient = json.RawMessage(req.GradientJson)
	}
	if err := h.svc.UpdateWalletMetadata(req.WalletId, req.Name, gradient); err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	}
	return &pb.UpdateWalletMetadataResponse{}, nil
}

func (h *WalletHandler) DeleteWallet(ctx context.Context, req *pb.DeleteWalletRequest) (*pb.DeleteWalletResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	if err := h.svc.CheckDeletable(req.WalletId); err != nil {
		return nil, rpcError(err)
	}
	if err := h.engine.DeleteWallet(ctx, req.WalletId); err != nil {
		return nil, rpcError(err)
	}
	return &pb.DeleteWalletResponse{}, nil
}

func (h *WalletHandler) DeleteAllWallets(ctx context.Context, req *pb.DeleteAllWalletsRequest) (*pb.DeleteAllWalletsResponse, error) {
	if err := h.svc.DeleteAllWallets(nil, nil); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.DeleteAllWalletsResponse{}, nil
}

func (h *WalletHandler) ListWalletBackups(ctx context.Context, req *pb.ListWalletBackupsRequest) (*pb.ListWalletBackupsResponse, error) {
	backups, err := h.svc.ListWalletBackups()
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	resp := &pb.ListWalletBackupsResponse{
		Backups: lo.Map(backups, func(backup wallet.WalletBackupInfo, _ int) *pb.WalletBackup {
			return walletBackupToProto(backup)
		}),
	}
	return resp, nil
}

func (h *WalletHandler) RestoreWalletBackup(ctx context.Context, req *pb.RestoreWalletBackupRequest) (*pb.RestoreWalletBackupResponse, error) {
	if err := h.svc.RestoreWalletBackup(req.BackupId, req.Password); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	return &pb.RestoreWalletBackupResponse{}, nil
}

func (h *WalletHandler) RestoreWalletBackupStream(ctx context.Context, req *pb.RestoreWalletBackupRequest, stream rpc.WalletManagerServiceRestoreWalletBackupStreamServerStream) error {
	steps, err := h.svc.RestoreWalletBackupPlan(req.BackupId)
	if err != nil {
		return connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	planned := lo.Map(steps, func(step wallet.RestoreWalletBackupStep, _ int) *pb.RestoreWalletBackupStep {
		return &pb.RestoreWalletBackupStep{
			StepId: step.ID,
			Name:   step.Name,
		}
	})
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

	if err := h.svc.RestoreWalletBackupWithProgress(req.BackupId, req.Password, sendProgress); err != nil {
		if sendErr != nil {
			return sendErr
		}
		return connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
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

func (h *WalletHandler) CreateWatchOnlyWallet(ctx context.Context, req *pb.CreateWatchOnlyWalletRequest) (*pb.CreateWatchOnlyWalletResponse, error) {
	if err := h.svc.CreateWatchOnlyWallet(req.Name, req.XpubOrDescriptor, req.GradientJson); err != nil {
		return nil, rpcError(err)
	}
	return &pb.CreateWatchOnlyWalletResponse{
		WalletId: h.svc.ActiveWalletID(),
	}, nil
}

func (h *WalletHandler) CreateElectrumWallet(ctx context.Context, req *pb.CreateElectrumWalletRequest) (*pb.CreateElectrumWalletResponse, error) {
	if h.engine == nil || !h.engine.ElectrumConfigured() {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"electrum wallets are not supported on this network")
	}
	account, path, err := wallet.ResolveCreateDerivationPath(req.Account, req.DerivationPath)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	if req.XpubOrDescriptor == "" {
		if _, err := wallet.ResolveScriptType(req.ScriptType, path); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
		}
	}
	// A bare extended key states no kind, so its own history places it. With
	// no history the chosen type stands.
	scriptType := req.ScriptType
	if req.XpubOrDescriptor != "" && wallet.BareKeyWithoutKind(req.XpubOrDescriptor) {
		if detected, ok := h.engine.DetectScriptKind(ctx, req.XpubOrDescriptor); ok {
			scriptType = detected.String()
		}
	}
	w, err := h.svc.CreateElectrumWallet(req.Name, json.RawMessage(req.GradientJson), req.Slots, req.CustomMnemonic, req.Passphrase, req.XpubOrDescriptor, scriptType, account, path)
	if err != nil {
		return nil, rpcError(err)
	}
	if req.HardwareDeviceType != "" {
		if err := h.svc.SetWalletHardwareDevice(w.ID, req.HardwareDeviceType, req.HardwareFingerprint); err != nil {
			return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
		}
	}
	return &pb.CreateElectrumWalletResponse{
		WalletId: w.ID,
	}, nil
}

func (h *WalletHandler) CreateMultisigWallet(ctx context.Context, req *pb.CreateMultisigWalletRequest) (*pb.CreateMultisigWalletResponse, error) {
	if h.engine == nil || !h.engine.ElectrumConfigured() {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			"multisig wallets are not supported on this network")
	}
	net := h.engine.Network()
	cosigners := make([]wallet.MultisigCosigner, 0, len(req.Cosigners))
	for _, c := range req.Cosigners {
		xpub := c.Xpub
		mnemonic := c.Mnemonic
		// For a held cosigner, derive the authoritative xpub from its seed +
		// passphrase so the stored (watch-only) key can never disagree with the
		// signing key — the wallet always watches exactly what it can sign.
		if mnemonic != "" {
			var err error
			mnemonic, err = wallet.ParseMnemonic(mnemonic)
			if err != nil {
				return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("cosigner mnemonic: %w", err).Error())
			}
			seedHex := hex.EncodeToString(wallet.MnemonicToSeed(mnemonic, c.Passphrase))
			_, derived, err := wallet.DeriveAccountXprv(seedHex, "m/"+c.OriginPath, net)
			if err != nil {
				return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("derive cosigner xpub: %w", err).Error())
			}
			xpub = derived
		}
		if err := wallet.CheckCosignerKeyMatchesOrigin(xpub, c.OriginPath); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
		}
		cosigners = append(cosigners, wallet.MultisigCosigner{
			Xpub:               xpub,
			OriginPath:         c.OriginPath,
			Fingerprint:        c.Fingerprint,
			Mnemonic:           mnemonic,
			Passphrase:         c.Passphrase,
			Xprv:               c.Xprv,
			HardwareDeviceType: c.HardwareDeviceType,
		})
	}
	w, err := h.svc.CreateElectrumMultisig(
		req.Name,
		json.RawMessage(req.GradientJson),
		int(req.M),
		int(req.N),
		req.ScriptType,
		cosigners,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.CreateMultisigWalletResponse{WalletId: w.ID}, nil
}

// multisigInfoProto exposes a wallet's multisig policy to the frontend. Private
// cosigner material (mnemonic/xprv) is never included — only public data and a
// held flag.
func multisigInfoProto(w *wallet.WalletData) *pb.MultisigInfo {
	if w.Multisig == nil {
		return nil
	}
	cosigners := make([]*pb.MultisigCosignerInfo, 0, len(w.Multisig.Cosigners))
	for _, c := range w.Multisig.Cosigners {
		cosigners = append(cosigners, &pb.MultisigCosignerInfo{
			Xpub:               c.Xpub,
			Fingerprint:        c.Fingerprint,
			OriginPath:         c.OriginPath,
			Held:               c.Held(),
			HardwareDeviceType: c.HardwareDeviceType,
		})
	}
	return &pb.MultisigInfo{
		M:          uint32(w.Multisig.M),
		N:          uint32(w.Multisig.N),
		ScriptType: w.MultisigScriptType(),
		Cosigners:  cosigners,
	}
}

func (h *WalletHandler) ParseMultisigConfig(ctx context.Context, req *pb.ParseMultisigConfigRequest) (*pb.ParseMultisigConfigResponse, error) {
	m, n, scriptType, cosigners, err := wallet.ParseMultisigConfig(req.Content)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	pbCosigners := make([]*pb.ParsedCosigner, 0, len(cosigners))
	for _, c := range cosigners {
		pbCosigners = append(pbCosigners, &pb.ParsedCosigner{
			Xpub:        c.Xpub,
			Fingerprint: c.Fingerprint,
			OriginPath:  c.OriginPath,
		})
	}
	return &pb.ParseMultisigConfigResponse{
		M:          uint32(m),
		N:          uint32(n),
		ScriptType: scriptType,
		Cosigners:  pbCosigners,
	}, nil
}

func (h *WalletHandler) ValidateDescriptor(ctx context.Context, req *pb.ValidateDescriptorRequest) (*pb.ValidateDescriptorResponse, error) {
	policy, err := wallet.ValidateDescriptor(req.Descriptor_)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	keys := make([]*pb.ParsedCosigner, 0, len(policy.Cosigners))
	for _, c := range policy.Cosigners {
		keys = append(keys, &pb.ParsedCosigner{
			Xpub:        c.Xpub,
			Fingerprint: c.Fingerprint,
			OriginPath:  c.OriginPath,
			Xprv:        c.Xprv,
		})
	}
	return &pb.ValidateDescriptorResponse{
		Multisig:   policy.Multisig,
		ScriptType: policy.ScriptType,
		M:          uint32(policy.M),
		N:          uint32(policy.N),
		Keys:       keys,
	}, nil
}

func (h *WalletHandler) ValidateDerivationPath(ctx context.Context, req *pb.ValidateDerivationPathRequest) (*pb.ValidateDerivationPathResponse, error) {
	normalized, err := wallet.ParseKeystorePath(req.Path)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	return &pb.ValidateDerivationPathResponse{
		Normalized: normalized,
		ScriptType: wallet.KeystorePathScriptType(normalized, req.Multisig),
	}, nil
}

func (h *WalletHandler) ListDerivationPaths(ctx context.Context, req *pb.ListDerivationPathsRequest) (*pb.ListDerivationPathsResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	options, defaultPath, err := wallet.StandardDerivationPaths(req.ScriptType, req.Multisig, req.Account, h.engine.Network())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	pbOptions := make([]*pb.DerivationPathOption, 0, len(options))
	for _, o := range options {
		pbOptions = append(pbOptions, &pb.DerivationPathOption{Label: o.Label, Path: o.Path})
	}
	return &pb.ListDerivationPathsResponse{Options: pbOptions, DefaultPath: defaultPath}, nil
}

func (h *WalletHandler) SignPsbtWithCosigner(ctx context.Context, req *pb.SignPsbtWithCosignerRequest) (*pb.SignPsbtWithCosignerResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	out, err := h.engine.SignPSBTWithCosigner(ctx, walletID, req.PsbtBase64, req.CosignerXpub)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.SignPsbtWithCosignerResponse{PsbtBase64: out}, nil
}

func (h *WalletHandler) MultisigPsbtStatus(ctx context.Context, req *pb.MultisigPsbtStatusRequest) (*pb.MultisigPsbtStatusResponse, error) {
	w := h.svc.GetWalletByID(req.WalletId)
	if w == nil {
		return nil, connect.Errorf(connect.CodeNotFound, "wallet %s not found", req.WalletId)
	}
	if w.Multisig == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "wallet is not a multisig wallet")
	}
	status, err := wallet.MultisigPsbtSigningStatus(req.PsbtBase64, w.Multisig.Cosigners)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	return &pb.MultisigPsbtStatusResponse{
		Threshold:      uint32(w.Multisig.M),
		Signatures:     uint32(status.Signatures),
		Finalizable:    status.Finalizable,
		CosignerSigned: status.CosignerSigned,
	}, nil
}

func (h *WalletHandler) BroadcastTransaction(ctx context.Context, req *pb.BroadcastTransactionRequest) (*pb.BroadcastTransactionResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	// A saved draft spends the coins it named when the user built it. The user
	// can freeze one of them before this call, so read the inputs again.
	if err := h.refuseFrozenRawInputs(req.TxHex); err != nil {
		return nil, err
	}

	txid, err := h.engine.ChainForWallet(walletID).Broadcast(ctx, req.TxHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("broadcast: %w", err).Error())
	}
	if rerr := h.engine.RefreshElectrumScan(ctx, walletID); rerr != nil {
		h.svc.Log().Warn().Err(rerr).Str("wallet_id", walletID).Msg("refresh scan after broadcast failed")
	}
	return &pb.BroadcastTransactionResponse{Txid: txid}, nil
}

func (h *WalletHandler) RescanWallet(ctx context.Context, req *pb.RescanWalletRequest) (*pb.RescanWalletResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	if err := h.engine.RefreshElectrumScan(ctx, walletID); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("rescan: %w", err).Error())
	}
	return &pb.RescanWalletResponse{}, nil
}

func (h *WalletHandler) EstimateFee(ctx context.Context, req *pb.EstimateFeeRequest) (*pb.EstimateFeeResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	rate, err := h.engine.EstimateFeeRate(ctx, int(req.ConfTarget))
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	return &pb.EstimateFeeResponse{SatPerVbyte: rate}, nil
}

// ============================================================================
// Core wallet management RPCs
// ============================================================================

// ResolveWalletID names the wallet an id means. An empty id means the active
// wallet.
func (h *WalletHandler) ResolveWalletID(walletID string) (string, error) {
	if err := h.requireEngine(); err != nil {
		return "", err
	}
	return h.engine.ResolveWalletID(walletID)
}

// TxStatus reads the chain status of one transaction from the chain source.
func (h *WalletHandler) TxStatus(ctx context.Context, txid string) (wallet.EsploraStatus, error) {
	if err := h.requireEngine(); err != nil {
		return wallet.EsploraStatus{}, err
	}
	return h.engine.TxStatus(ctx, txid)
}

func (h *WalletHandler) requireEngine() error {
	if h.engine == nil {
		return fmt.Errorf("bitcoin Core RPC not configured")
	}
	return nil
}

func rpcError(err error) error {
	var ce *connect.Error
	if errors.As(err, &ce) {
		return ce
	}
	switch {
	case errors.Is(err, wallet.ErrIncorrectPassword):
		return connect.NewError(connect.CodeUnauthenticated, err.Error()).WithCause(err)
	case errors.Is(err, wallet.ErrNotEncrypted):
		return connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	default:
		return connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
}

func (h *WalletHandler) CreateBitcoinCoreWallet(ctx context.Context, req *pb.CreateBitcoinCoreWalletRequest) (*pb.CreateBitcoinCoreWalletResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	if h.orch != nil {
		plan := h.orch.PlanNetworkChange(orchestrator.NetworkChangeRequest{WalletBackend: wallet.WalletTypeBitcoinCore})
		if plan.MustSelectDatadir {
			return nil, requirementsUnmet(plan)
		}
	}

	name, err := h.engine.Backend().Ensure(ctx, req.WalletId)
	if err != nil {
		// Bitcoin Core mid-startup (-28) or already loading the wallet (-4) is
		// not an internal failure — it's "try again in a few seconds". Return
		// Unavailable so the Dart logging filter quiets it and the UI doesn't
		// flash an error toast every poll cycle.
		if wallet.IsTransientWalletErr(err) {
			return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
		}
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.CreateBitcoinCoreWalletResponse{
		CoreWalletName: name,
	}, nil
}

func (h *WalletHandler) EnsureCoreWallets(ctx context.Context, req *pb.EnsureCoreWalletsRequest) (*pb.EnsureCoreWalletsResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	count, err := h.engine.Backend().EnsureAll(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.EnsureCoreWalletsResponse{
		SyncedCount: int32(count),
	}, nil
}

// ============================================================================
// Bitcoin operation RPCs (proxied through Core RPC)
// ============================================================================

func (h *WalletHandler) GetBalance(ctx context.Context, req *pb.GetBalanceRequest) (*pb.GetBalanceResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	confirmed, unconfirmed, immature, err := h.engine.Backend().Balance(ctx, walletID)
	if err != nil {
		return nil, rpcError(err)
	}

	confirmedSats := btcToSats(confirmed)
	unconfirmedSats := btcToSats(unconfirmed)
	if err := h.svc.SyncBalance(orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND, walletID, uint64(math.Round(confirmedSats)), uint64(math.Round(unconfirmedSats)), "Bitcoin"); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save the balance snapshot: %w", err).Error())
	}

	return &pb.GetBalanceResponse{
		ConfirmedSats:   confirmedSats,
		UnconfirmedSats: unconfirmedSats,
		ImmatureSats:    btcToSats(immature),
	}, nil
}

func (h *WalletHandler) GetNewAddress(ctx context.Context, req *pb.GetNewAddressRequest) (*pb.GetNewAddressResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	var kind wallet.ScriptKind
	switch req.AddressType {
	case pb.AddressType_ADDRESS_TYPE_SEGWIT:
		kind = wallet.ScriptNativeSegwit
	case pb.AddressType_ADDRESS_TYPE_TAPROOT:
		kind = wallet.ScriptTaproot
	default:
		kind = wallet.ScriptUnknown
	}

	addr, err := h.engine.Backend().NextReceiveAddress(ctx, walletID, kind)
	if err != nil {
		return nil, rpcError(err)
	}

	return &pb.GetNewAddressResponse{
		Address:        addr.Address,
		Index:          addr.Index,
		DerivationPath: addr.HDPath,
	}, nil
}

// mapRawOutputs converts proto raw outputs to the wallet's TxOutSpec shape.
func mapRawOutputs(raws []*pb.RawOutput) []wallet.TxOutSpec {
	return lo.Map(raws, func(r *pb.RawOutput, _ int) wallet.TxOutSpec {
		return wallet.TxOutSpec{RawScriptHex: r.ScriptHex, AmountSats: r.ValueSats}
	})
}

// mapExternalInputs converts proto external inputs to the wallet's shape.
func mapExternalInputs(exts []*pb.ExternalInput) []wallet.ExternalInput {
	return lo.Map(exts, func(e *pb.ExternalInput, _ int) wallet.ExternalInput {
		return wallet.ExternalInput{
			TxID:            e.Txid,
			Vout:            int(e.Vout),
			AmountSats:      e.ValueSats,
			ScriptPubKeyHex: e.ScriptPubkeyHex,
		}
	})
}

// refuseFrozenRawInputs stops a broadcast of a transaction that spends a coin
// the user froze. A raw transaction names its inputs, so no lock reaches them.
func (h *WalletHandler) refuseFrozenRawInputs(txHex string) error {
	held := h.svc.HeldCoins()
	if len(held) == 0 {
		return nil
	}
	decoded, err := wallet.DecodeTransaction(txHex, h.engine.Network())
	if err != nil {
		// An unreadable transaction fails at the node, with its own words.
		return nil
	}
	for _, in := range decoded.Inputs {
		outpoint := wallet.Outpoint{TxID: in.PrevTxID, Vout: in.PrevVout}
		if held[outpoint.Key()] {
			return connect.Errorf(connect.CodeFailedPrecondition,
				"the output %s is frozen; unfreeze it to spend it", outpoint.Key())
		}
	}
	return nil
}

// refuseFrozenInputs stops a send that names a coin the user froze.
func (h *WalletHandler) refuseFrozenInputs(inputs []*pb.UnspentOutput) error {
	if len(inputs) == 0 {
		return nil
	}
	held := h.svc.HeldCoins()
	if len(held) == 0 {
		return nil
	}
	for _, in := range inputs {
		outpoint := wallet.Outpoint{TxID: in.Txid, Vout: int(in.Vout)}
		if held[outpoint.Key()] {
			return connect.Errorf(connect.CodeFailedPrecondition,
				"the output %s is frozen; unfreeze it to spend it", outpoint.Key())
		}
	}
	return nil
}

// HeldCoins names the coins the frontend froze.
func (h *WalletHandler) HeldCoins() map[string]bool {
	return h.svc.HeldCoins()
}

// SetFrozenCoins records the coins the frontend froze, so every later send
// leaves them alone.
func (h *WalletHandler) SetFrozenCoins(ctx context.Context, req *pb.SetFrozenCoinsRequest) (*emptypb.Empty, error) {
	coins := make([]wallet.Outpoint, 0, len(req.Outpoints))
	for _, out := range req.Outpoints {
		if out.Txid == "" {
			return nil, connect.NewError(connect.CodeInvalidArgument, "a frozen coin needs a txid")
		}
		coins = append(coins, wallet.Outpoint{TxID: out.Txid, Vout: int(out.Vout)})
	}
	h.svc.SetHeldCoins(coins)

	return &emptypb.Empty{}, nil
}

func (h *WalletHandler) SendTransaction(ctx context.Context, req *pb.SendTransactionRequest) (*pb.SendTransactionResponse, error) {
	if err := protovalidate.Validate(req); err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	// A BIP47 send reserves an index and can broadcast a notification below.
	if req.FixedFeeSats > 0 && req.SubtractFeeFromAmount && h.walletNeedsL1(walletID) {
		return nil, connect.NewError(connect.CodeInvalidArgument, wallet.ErrCoreMixedFee.Error()).WithCause(wallet.ErrCoreMixedFee)
	}

	// A required input is spent as it is given, so no lock reaches it. The
	// set here is the user's alone: a bid raise pins the coin its own bid
	// holds, and that coin has to stay spendable.
	if err := h.refuseFrozenInputs(req.RequiredInputs); err != nil {
		return nil, err
	}

	// Resolve any BIP47 payment-code destinations into per-payment addresses
	// before the dust check so we validate against the substituted address.
	var pinnedNotification *wallet.RequiredInput
	if req.NotificationInput != nil {
		pinnedNotification = &mapRequiredInputs([]*pb.UnspentOutput{req.NotificationInput})[0]
	}
	expansion, err := h.expandBip47Destinations(
		ctx, walletID, req.Destinations,
		req.FeeRateSatPerVbyte, pinnedNotification, mapRequiredInputs(req.RequiredInputs),
	)
	if err != nil {
		return nil, err
	}
	if expansion.notificationTxHex != "" || !destinationsEqual(expansion.destinations, req.Destinations) {
		req = applyDestinationsToRequest(req, expansion.destinations)
	}
	// The reserved per-payment index is only released for a failure that
	// happens before the payment goes out. A broadcast that times out may
	// still have published the payment, and reusing that address would defeat
	// the address isolation BIP47 exists for.
	const dustLimitSats int64 = 546
	for address, sats := range req.Destinations {
		if sats < dustLimitSats {
			h.releaseBip47Index(walletID, expansion)
			return nil, connect.Errorf(
				connect.CodeInvalidArgument,
				"amount to %s is below dust limit (%d sats)", address, dustLimitSats,
			)
		}
	}

	sendReq := wallet.SendRequest{
		DestinationsSats:      req.Destinations,
		FeeRateSatPerVB:       req.FeeRateSatPerVbyte,
		FixedFeeSats:          req.FixedFeeSats,
		OpReturnHex:           req.OpReturnHex,
		SubtractFeeFromAmount: req.SubtractFeeFromAmount,
		AllowReplay:           req.AllowReplay,
		Replaceable:           req.Replaceable,
	}

	// A BIP47 payment holds a reserved index, and its first send also publishes
	// a notification that spends a real coin. Price the payment before either,
	// so a wallet that cannot price it gives the index back and leaves the
	// chain untouched.
	if expansion.recipientCode != "" {
		if err := h.resolveSendFeeRate(ctx, walletID, &sendReq); err != nil {
			h.releaseBip47Index(walletID, expansion)
			return nil, err
		}
	}

	if expansion.notificationTxHex != "" {
		notifTxID, err := h.broadcastBip47Notification(ctx, walletID, expansion.recipientCode, expansion.notificationTxHex, req.AllowReplay)
		if err != nil {
			// The payment never went out, so its index is still free.
			h.releaseBip47Index(walletID, expansion)
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("broadcast bip47 notification: %w", err).Error())
		}
		_ = notifTxID
	}
	sendReq.RequiredInputs = mapRequiredInputs(req.RequiredInputs)
	sendReq.RawOutputs = mapRawOutputs(req.RawOutputs)
	sendReq.ExternalInputs = mapExternalInputs(req.ExternalInputs)

	txid, err := h.engine.Backend().Send(ctx, walletID, sendReq)
	if err != nil {
		return nil, rpcError(err)
	}

	return &pb.SendTransactionResponse{
		Txid: txid,
	}, nil
}

func mapRequiredInputs(inputs []*pb.UnspentOutput) []wallet.RequiredInput {
	return lo.Map(inputs, func(u *pb.UnspentOutput, _ int) wallet.RequiredInput {
		return wallet.RequiredInput{TxID: u.Txid, Vout: int(u.Vout), AmountSats: u.AmountSats}
	})
}

func (h *WalletHandler) PreviewSend(ctx context.Context, req *pb.PreviewSendRequest) (*pb.PreviewSendResponse, error) {
	if len(req.Destinations) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "must provide at least one destination")
	}
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	if err := h.refuseFrozenInputs(req.RequiredInputs); err != nil {
		return nil, err
	}
	destinations, notifies, err := h.sizeBip47Destinations(walletID, req.Destinations)
	if err != nil {
		return nil, err
	}
	requiredInputs := mapRequiredInputs(req.RequiredInputs)

	resp := &pb.PreviewSendResponse{}
	var excluded []wallet.RequiredInput
	var notificationCoinSats int64
	// A first BIP47 payment publishes a notification first. Its coin stays out
	// of the payment, so the send can pin the coins of both. A wallet with one
	// coin pays from the notification change, which no preview can pin.
	if notifies {
		coins, err := h.unfrozenSpendableCoins(ctx, walletID)
		if err != nil {
			return nil, err
		}
		coin, feeSats, err := h.bip47NotificationCoin(ctx, walletID, req.FeeRateSatPerVbyte, nil, requiredInputs)
		if err != nil {
			return nil, err
		}
		notificationCoinSats = int64(math.Round(coin.Amount * 1e8))
		resp.NotificationFeeSats = feeSats
		resp.FeeIsEstimate = len(coins) < 2
		if !resp.FeeIsEstimate {
			resp.NotificationInput = &pb.UnspentOutput{Txid: coin.TxID, Vout: int32(coin.Vout), AmountSats: notificationCoinSats}
			excluded = []wallet.RequiredInput{{TxID: coin.TxID, Vout: coin.Vout, AmountSats: notificationCoinSats}}
		}
	}

	preview, err := h.engine.Backend().PreviewSend(ctx, walletID, wallet.SendRequest{
		DestinationsSats:      destinations,
		FeeRateSatPerVB:       req.FeeRateSatPerVbyte,
		SubtractFeeFromAmount: req.SubtractFeeFromAmount,
		AllowReplay:           req.AllowReplay,
		RequiredInputs:        requiredInputs,
		ExcludedInputs:        excluded,
	})
	if err != nil {
		return nil, rpcError(err)
	}
	resp.FeeSats = preview.FeeSats
	resp.VsizeVbytes = preview.VsizeVBytes
	// The payment of a one-coin wallet spends the notification change, so the
	// notification fee and dust leave the coin first.
	if resp.FeeIsEstimate {
		changeSats := notificationCoinSats - resp.NotificationFeeSats - bip47NotificationDustSats
		needSats := lo.Sum(lo.Values(destinations))
		if !req.SubtractFeeFromAmount {
			needSats += preview.FeeSats
		}
		if needSats > changeSats {
			return nil, connect.Errorf(connect.CodeFailedPrecondition,
				"the payment needs %d sats, but the only coin keeps %d sats after the BIP47 notification", needSats, changeSats)
		}
	}
	if !resp.FeeIsEstimate {
		resp.Inputs = lo.Map(preview.Inputs, func(in wallet.RequiredInput, _ int) *pb.UnspentOutput {
			return &pb.UnspentOutput{Txid: in.TxID, Vout: int32(in.Vout), AmountSats: in.AmountSats}
		})
	}
	return resp, nil
}

func (h *WalletHandler) ListTransactions(ctx context.Context, req *pb.ListTransactionsRequest) (*pb.ListTransactionsResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	count := int(req.Count)
	if count <= 0 {
		count = 100
	}

	txs, err := h.engine.Backend().ListTransactions(ctx, walletID, count)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	pbTxs := lo.Map(txs, func(tx wallet.WalletTransaction, _ int) *pb.TransactionEntry {
		return &pb.TransactionEntry{
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
	})

	bids := h.bidLabels(ctx, walletID, pbTxs)
	deposits, err := h.svc.WalletSidechainDeposits(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	depositOf := lo.KeyBy(deposits, func(d wallet.SidechainDeposit) string { return d.Txid })
	for _, entry := range pbTxs {
		entry.BmmBid = bids[entry.Txid]
		if d, ok := depositOf[entry.Txid]; ok {
			entry.SidechainDeposit = &pb.SidechainDeposit{
				Txid:        d.Txid,
				WalletId:    d.WalletID,
				Slot:        d.Slot,
				Destination: d.Destination,
				AmountSats:  d.AmountSats,
				FeeSats:     d.FeeSats,
			}
		}
	}
	if err := h.setTransactionWarnings(ctx, walletID, pbTxs); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.ListTransactionsResponse{
		Transactions: pbTxs,
	}, nil
}

// bidLabels names the BMM request each unconfirmed transaction carries. A
// confirmed transaction cannot be a live bid, so a settled wallet costs no
// Core call.
func (h *WalletHandler) bidLabels(
	ctx context.Context, walletID string, entries []*pb.TransactionEntry,
) map[string]*pb.BmmBid {
	if h.orch == nil {
		return nil
	}
	pending := lo.FilterMap(entries, func(e *pb.TransactionEntry, _ int) (string, bool) {
		return e.Txid, e.Confirmations == 0
	})
	if len(pending) == 0 {
		return nil
	}
	if h.orch.NodeMode() == orchestrator.NodeModeLight {
		return h.walletBidLabels(ctx, walletID, lo.Uniq(pending))
	}
	core := NewHandler(h.orch)
	return BidLabels(ctx, func(ctx context.Context, method, paramsJSON string) (json.RawMessage, error) {
		return core.RawCoreCall(ctx, method, paramsJSON, "")
	}, lo.Uniq(pending))
}

// walletBidLabels reads the bids of a light install from the wallet's chain
// source. The wallet lists a transaction unconfirmed only while a mempool holds it.
func (h *WalletHandler) walletBidLabels(ctx context.Context, walletID string, txids []string) map[string]*pb.BmmBid {
	tip, _, err := h.orch.ChainTip(ctx)
	if err != nil {
		return nil
	}
	chain := h.engine.ChainForWallet(walletID)
	return labelBids(tip, txids, func(txid string) (string, error) {
		tx, err := chain.GetRawTransaction(ctx, txid)
		if err != nil {
			return "", err
		}
		if len(tx.Vout) == 0 {
			return "", fmt.Errorf("transaction %s has no outputs", txid)
		}
		return tx.Vout[0].ScriptPubKey.Hex, nil
	}, func(string) bool { return true })
}

func (h *WalletHandler) ListUnspent(ctx context.Context, req *pb.ListUnspentRequest) (*pb.ListUnspentResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	utxos, err := h.engine.Backend().ListUnspent(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	txTimes := h.fetchCoreTxTimes(ctx, walletID, utxos)
	splitStatuses := map[string]bool{}
	if config.IsEcashFork(config.NetworkFromString(h.svc.Network())) {
		splitStatuses, err = h.svc.SplitStatuses(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
		}
	}

	pbUTXOs := lo.Map(utxos, func(u wallet.UTXO, _ int) *pb.UnspentOutput {
		out := &pb.UnspentOutput{
			Txid:           u.TxID,
			Vout:           int32(u.Vout),
			Address:        u.Address,
			Amount:         u.Amount,
			AmountSats:     int64(math.Round(u.Amount * 1e8)),
			Confirmations:  int32(u.Confirmations),
			Label:          u.Label,
			Spendable:      u.Spendable,
			Solvable:       u.Solvable,
			WalletId:       walletID,
			ReceivedAt:     receivedAt(u, txTimes),
			DerivationPath: u.HDPath,
		}
		// A descriptor gives the exact script, so the input's weight is a
		// calculation. A backend without one leaves the field at zero, and the
		// caller falls back to its own estimate.
		if u.InputWeightUnits > 0 {
			out.InputWeightUnits = int32(u.InputWeightUnits)
		} else if weight, err := wallet.InputWeightUnits(u.Descriptor); err == nil {
			out.InputWeightUnits = int32(weight)
		} else if u.Descriptor != "" {
			h.svc.Log().Warn().Err(err).Str("descriptor", u.Descriptor).Msg("cannot size utxo input")
		}
		if splittable, ok := splitStatuses[fork.Outpoint(u.TxID, u.Vout)]; ok {
			out.Splittable = lo.ToPtr(splittable)
		}
		return out
	})

	return &pb.ListUnspentResponse{
		Utxos: pbUTXOs,
	}, nil
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

func (h *WalletHandler) ListReceiveAddresses(ctx context.Context, req *pb.ListReceiveAddressesRequest) (*pb.ListReceiveAddressesResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	addrs, err := h.engine.Backend().ListReceivedByAddress(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	pbAddrs := lo.Map(addrs, func(a wallet.ReceivedByAddress, _ int) *pb.ReceiveAddress {
		var lastUsedAt *timestamppb.Timestamp
		if a.LastUsedAt > 0 {
			lastUsedAt = timestamppb.New(time.Unix(a.LastUsedAt, 0))
		}
		return &pb.ReceiveAddress{
			Address: a.Address,
			// The column reads "Balance", so it carries what the address still
			// holds, not every coin it ever received.
			Amount:         float64(a.BalanceSats) / 1e8,
			AmountSats:     a.BalanceSats,
			Label:          a.Label,
			TxCount:        int32(len(a.TxIDs)),
			IsChange:       a.Change,
			DerivationPath: a.HDPath,
			LastUsedAt:     lastUsedAt,
		}
	})

	return &pb.ListReceiveAddressesResponse{
		Addresses: pbAddrs,
	}, nil
}

func (h *WalletHandler) GetTransactionDetails(ctx context.Context, req *pb.GetTransactionDetailsRequest) (*pb.GetTransactionDetailsResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	tx, err := h.engine.Backend().GetWalletTransaction(ctx, walletID, req.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	rawTx, err := h.engine.ChainForWallet(walletID).GetRawTransaction(ctx, req.Txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("getrawtransaction: %w", err).Error())
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
	addresses := make([]string, 0, len(rawTx.Vout))
	for i, vout := range rawTx.Vout {
		valueSats := int64(math.Round(vout.Value * 1e8))
		totalOutputSats += valueSats
		addresses = append(addresses, vout.ScriptPubKey.Address)
		outputs = append(outputs, &pb.TransactionOutput{
			Index:           int32(i),
			ValueSats:       valueSats,
			Address:         vout.ScriptPubKey.Address,
			ScriptType:      vout.ScriptPubKey.Type,
			ScriptPubkeyAsm: vout.ScriptPubKey.Asm,
			ScriptPubkeyHex: vout.ScriptPubKey.Hex,
		})
	}

	owned, err := h.engine.Backend().OwnedAddresses(ctx, walletID, addresses)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("read address ownership: %w", err).Error())
	}
	for _, out := range outputs {
		change, mine := owned[out.Address]
		out.IsMine = mine
		out.IsChange = change
	}

	feeSats := totalInputSats - totalOutputSats
	if feeSats < 0 {
		feeSats = 0
	}

	feeRateSatVb := 0.0
	if rawTx.Vsize > 0 {
		feeRateSatVb = float64(feeSats) / float64(rawTx.Vsize)
	}

	return &pb.GetTransactionDetailsResponse{
		Transaction: &pb.TransactionEntry{
			Txid:           tx.TxID,
			WarningMessage: h.transactionWarning(outputs),
			Amount:         tx.Amount,
			AmountSats:     int64(math.Round(tx.Amount * 1e8)),
			Fee:            tx.Fee,
			Confirmations:  int32(tx.Confirmations),
			BlockTime:      tx.BlockTime,
			Time:           tx.Time,
			WalletId:       walletID,
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
	}, nil
}

func (h *WalletHandler) DecodeTransaction(ctx context.Context, req *pb.DecodeTransactionRequest) (*pb.DecodeTransactionResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	decoded, err := wallet.DecodeTransaction(req.Input, h.engine.Network())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	response := decodedToResponse(decoded)
	if decoded.Form == wallet.DecodedFormTxid {
		result, err := h.decodeTxidResponse(ctx, decoded.TxID, req.WalletId)
		if err != nil {
			return nil, err
		}
		response = result
	}

	if req.CheckOwnership {
		walletID, err := h.engine.ResolveWalletID(req.WalletId)
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
		}
		addresses := make([]string, len(response.Outputs))
		for i, output := range response.Outputs {
			addresses[i] = output.Address
		}
		owned, err := h.engine.Backend().OwnedAddresses(ctx, walletID, addresses)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("read address ownership: %w", err).Error())
		}
		for _, output := range response.Outputs {
			output.IsChange, output.IsMine = owned[output.Address]
		}
	}
	response.WarningMessage = h.transactionWarning(response.Outputs)
	return response, nil
}

func (h *WalletHandler) decodeTxidResponse(ctx context.Context, txid, walletID string) (*pb.DecodeTransactionResponse, error) {
	resolved, err := h.engine.ResolveWalletID(walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	rawTx, err := h.engine.ChainForWallet(resolved).GetRawTransaction(ctx, txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("transaction %s not found: %w", txid, err).Error())
	}

	inputs, totalInput, allKnown := h.rawTxInputs(ctx, resolved, rawTx)
	outputs, totalOutput := rawTxOutputs(rawTx)

	resp := &pb.DecodeTransactionResponse{
		Form:            pb.DecodedForm_DECODED_FORM_TXID,
		Txid:            rawTx.TxID,
		Version:         rawTx.Version,
		Locktime:        rawTx.Locktime,
		SizeBytes:       rawTx.Size,
		VsizeVbytes:     rawTx.Vsize,
		WeightWu:        rawTx.Weight,
		Inputs:          inputs,
		Outputs:         outputs,
		TotalInputSats:  totalInput,
		HasTotalInput:   allKnown,
		TotalOutputSats: totalOutput,
		Raw:             rawTx.Hex,
	}
	if allKnown {
		fee := totalInput - totalOutput
		if fee >= 0 {
			resp.FeeSats = fee
			resp.HasFee = true
			if rawTx.Vsize > 0 {
				resp.FeeRateSatVb = float64(fee) / float64(rawTx.Vsize)
			}
		}
	}
	return resp, nil
}

func (h *WalletHandler) rawTxInputs(ctx context.Context, walletID string, rawTx *wallet.RawTransaction) ([]*pb.TransactionInput, int64, bool) {
	inputs := make([]*pb.TransactionInput, 0, len(rawTx.Vin))
	total := int64(0)
	allKnown := len(rawTx.Vin) > 0
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
		resolved := false
		if !input.IsCoinbase && vin.TxID != "" {
			prevTx, err := h.engine.ChainForWallet(walletID).GetRawTransaction(ctx, vin.TxID)
			if err == nil && vin.Vout >= 0 && vin.Vout < len(prevTx.Vout) {
				prevOut := prevTx.Vout[vin.Vout]
				input.ValueSats = int64(math.Round(prevOut.Value * 1e8))
				input.Address = prevOut.ScriptPubKey.Address
				total += input.ValueSats
				resolved = true
			}
		}
		if input.IsCoinbase {
			resolved = true
		}
		if !resolved {
			allKnown = false
		}
		inputs = append(inputs, input)
	}
	return inputs, total, allKnown
}

func rawTxOutputs(rawTx *wallet.RawTransaction) ([]*pb.TransactionOutput, int64) {
	outputs := make([]*pb.TransactionOutput, 0, len(rawTx.Vout))
	total := int64(0)
	for i, vout := range rawTx.Vout {
		valueSats := int64(math.Round(vout.Value * 1e8))
		total += valueSats
		outputs = append(outputs, &pb.TransactionOutput{
			Index:           int32(i),
			ValueSats:       valueSats,
			Address:         vout.ScriptPubKey.Address,
			ScriptType:      vout.ScriptPubKey.Type,
			ScriptPubkeyAsm: vout.ScriptPubKey.Asm,
			ScriptPubkeyHex: vout.ScriptPubKey.Hex,
		})
	}
	return outputs, total
}

func decodedToResponse(d *wallet.DecodedTransaction) *pb.DecodeTransactionResponse {
	resp := &pb.DecodeTransactionResponse{
		Form:            decodedFormToProto(d.Form),
		Txid:            d.TxID,
		Version:         d.Version,
		Locktime:        d.Locktime,
		SizeBytes:       d.SizeBytes,
		VsizeVbytes:     d.VsizeVBytes,
		WeightWu:        d.WeightWU,
		TotalInputSats:  d.TotalInputSats,
		HasTotalInput:   d.HasTotalInput,
		TotalOutputSats: d.TotalOutput,
		FeeSats:         d.FeeSats,
		HasFee:          d.HasFee,
		FeeRateSatVb:    d.FeeRateSatVB,
		IsPsbt:          d.IsPSBT,
		SignedInputs:    int32(d.SignedInputs),
		Raw:             d.RawHex,
	}
	for _, in := range d.Inputs {
		resp.Inputs = append(resp.Inputs, &pb.TransactionInput{
			Index:        int32(in.Index),
			PrevTxid:     in.PrevTxID,
			PrevVout:     int32(in.PrevVout),
			Address:      in.Address,
			ValueSats:    in.ValueSats,
			ScriptSigHex: in.ScriptSig,
			Witness:      in.Witness,
			Sequence:     in.Sequence,
			IsCoinbase:   in.IsCoinbase,
		})
	}
	for _, out := range d.Outputs {
		resp.Outputs = append(resp.Outputs, &pb.TransactionOutput{
			Index:           int32(out.Index),
			ValueSats:       out.ValueSats,
			Address:         out.Address,
			ScriptType:      out.ScriptType,
			ScriptPubkeyHex: out.ScriptPubKeyHex,
			IsChange:        out.IsChange,
		})
	}
	return resp
}

func decodedFormToProto(f wallet.DecodedForm) pb.DecodedForm {
	switch f {
	case wallet.DecodedFormTxid:
		return pb.DecodedForm_DECODED_FORM_TXID
	case wallet.DecodedFormRawTx:
		return pb.DecodedForm_DECODED_FORM_RAW_TX
	case wallet.DecodedFormPSBT:
		return pb.DecodedForm_DECODED_FORM_PSBT
	default:
		return pb.DecodedForm_DECODED_FORM_UNSPECIFIED
	}
}

func (h *WalletHandler) BumpFee(ctx context.Context, req *pb.BumpFeeRequest) (*pb.BumpFeeResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	result, err := h.engine.Backend().BumpFee(ctx, walletID, wallet.BumpFeeRequest{
		TxID:        req.Txid,
		NewFeeRate:  req.NewFeeRate,
		FeeFromVout: voutPointer(req.FeeFromVout),
	})
	if err != nil {
		return nil, rpcError(err)
	}

	// A bumped deposit keeps its money on the way under a new txid. Without
	// this the old record reads as a deposit the network lost.
	if err := h.svc.RepointSidechainDeposit(ctx, req.Txid, result.NewTxID, result.Plan.NewFeeSats); err != nil {
		h.svc.Log().Error().Err(err).Str("old_txid", req.Txid).Str("new_txid", result.NewTxID).
			Msg("could not move the deposit record onto the replacement")
	}

	return &pb.BumpFeeResponse{
		NewTxid: result.NewTxID,
		Plan:    bumpFeePlanToProto(result.Plan),
	}, nil
}

func (h *WalletHandler) PreviewBumpFee(ctx context.Context, req *pb.PreviewBumpFeeRequest) (*pb.PreviewBumpFeeResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	preview, err := h.engine.Backend().PreviewBumpFee(ctx, walletID, wallet.BumpFeeRequest{
		TxID:        req.Txid,
		NewFeeRate:  req.NewFeeRate,
		FeeFromVout: voutPointer(req.FeeFromVout),
	})
	if err != nil {
		return nil, rpcError(err)
	}

	resp := &pb.PreviewBumpFeeResponse{
		InputCount:       int32(preview.InputCount),
		VsizeVbytes:      preview.VsizeVBytes,
		OldFeeSats:       preview.OldFeeSats,
		OldFeeRateSatVb:  preview.OldFeeRate,
		SuggestedFeeRate: preview.SuggestedRate,
		Reason:           preview.Reason,
		CanReplace:       preview.CanReplace,
		HasChild:         preview.HasChild,
		AddsInputs:       preview.AddsInputs,
		Outputs: lo.Map(preview.Outputs, func(o wallet.BumpFeeOutput, _ int) *pb.BumpFeeOutput {
			return &pb.BumpFeeOutput{
				Vout:       int32(o.Vout),
				AmountSats: o.AmountSats,
				Address:    o.Address,
				IsChange:   o.IsChange,
				DustSats:   o.DustSats,
				IsMine:     o.IsMine,
			}
		}),
	}
	if preview.Plan != nil {
		resp.Plan = bumpFeePlanToProto(*preview.Plan)
	}

	cancel, err := h.engine.Backend().PreviewCancel(ctx, walletID, req.Txid)
	if err != nil {
		// The user asked for a bump, so a cancel this node cannot price says so
		// on its own button, and the bump preview stands.
		resp.CancelReason = fmt.Sprintf("this node cannot price a cancel: %v", err)
		return resp, nil
	}
	resp.CancelReason = cancel.Reason
	if cancel.Plan != nil {
		resp.Cancel = &pb.CancelPlan{
			RecoveredSats: cancel.Plan.RecoveredSats,
			FeeSats:       cancel.Plan.FeeSats,
		}
	}
	return resp, nil
}

func (h *WalletHandler) CancelTransaction(ctx context.Context, req *pb.CancelTransactionRequest) (*pb.CancelTransactionResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	if req.Txid == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "name the transaction to cancel")
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	result, err := h.engine.Backend().CancelTransaction(ctx, walletID, req.Txid, req.MaxFeeSats)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.CancelTransactionResponse{
		ReplacementTxid: result.NewTxID,
		RecoveredSats:   result.Plan.RecoveredSats,
		FeeSats:         result.Plan.FeeSats,
	}, nil
}

// voutPointer maps the request's optional output index onto the backend's.
func voutPointer(vout *int32) *int {
	if vout == nil {
		return nil
	}
	v := int(*vout)
	return &v
}

func bumpFeePlanToProto(plan wallet.BumpFeePlan) *pb.BumpFeePlan {
	return &pb.BumpFeePlan{
		OldFeeSats:       plan.OldFeeSats,
		NewFeeSats:       plan.NewFeeSats,
		ExtraFeeSats:     plan.ExtraFeeSats,
		NewFeeRateSatVb:  plan.NewFeeRate,
		FeeFromVout:      int32(plan.FeeFromVout),
		AmountBeforeSats: plan.AmountBefore,
		AmountAfterSats:  plan.AmountAfter,
		OutputRemoved:    plan.OutputRemoved,
		ReducesPayment:   plan.ReducesPayment,
	}
}

func (h *WalletHandler) CreateCpfp(ctx context.Context, req *pb.CreateCpfpRequest) (*pb.CreateCpfpResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	// The child spends the parent output the caller names, so a freeze has to
	// stop the call. No lock reaches an outpoint a caller pins by hand.
	parent := wallet.Outpoint{TxID: req.ParentTxid, Vout: int(req.ParentVout)}
	if h.svc.HeldCoins()[parent.Key()] {
		return nil, connect.Errorf(connect.CodeFailedPrecondition,
			"the output %s is frozen; unfreeze it to spend it", parent.Key())
	}

	childTxID, err := h.engine.Backend().CreateCpfp(ctx, walletID, wallet.CpfpRequest{
		ParentTxID: req.ParentTxid,
		ParentVout: int(req.ParentVout),
		TargetRate: req.TargetFeeRate,
	})
	if err != nil {
		if connect.CodeOf(err) != connect.CodeUnknown {
			return nil, err
		}
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.CreateCpfpResponse{
		ChildTxid: childTxID,
	}, nil
}

func (h *WalletHandler) DeriveAddresses(ctx context.Context, req *pb.DeriveAddressesRequest) (*pb.DeriveAddressesResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	count := int(req.Count)
	if count <= 0 {
		count = 20
	}

	start := int(req.StartIndex)

	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	w := h.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, connect.Errorf(connect.CodeNotFound, "wallet %s not found", walletID)
	}

	addrs, err := wallet.DeriveWalletReceiveAddresses(w, h.engine.Network(), start, count)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}

	return &pb.DeriveAddressesResponse{
		Addresses: addrs,
	}, nil
}

// ============================================================================
// Seed access
// ============================================================================

func (h *WalletHandler) GetWalletSeed(ctx context.Context, req *pb.GetWalletSeedRequest) (*pb.GetWalletSeedResponse, error) {
	walletID := req.WalletId
	if walletID == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "wallet_id is required")
	}

	for _, w := range h.svc.GetAllWallets() {
		if w.ID != walletID {
			continue
		}
		// Electrum wallets keep no master seed, so say so rather than hand back
		// a blank one that reads like a successful answer.
		if w.Master.SeedHex == "" {
			return nil, connect.Errorf(
				connect.CodeFailedPrecondition,
				"wallet %s holds no master seed", walletID,
			)
		}
		return &pb.GetWalletSeedResponse{
			SeedHex:  w.Master.SeedHex,
			Mnemonic: w.Master.Mnemonic,
		}, nil
	}

	return nil, connect.Errorf(connect.CodeNotFound, "wallet %s not found", walletID)
}

func (h *WalletHandler) PreviewWalletFromEntropy(
	ctx context.Context,
	req *pb.PreviewWalletFromEntropyRequest,
) (*pb.PreviewWalletFromEntropyResponse, error) {
	strength := wallet.Strength128
	if req.WordCount == 24 {
		strength = wallet.Strength256
	}

	entropy := req.Entropy
	switch {
	case len(entropy) > 0:
	case req.SourceText != "":
		// Exact-length hex is what this handler itself hands back, so take it
		// as-is; anything else is hashed, and one character is enough.
		if raw, err := hex.DecodeString(req.SourceText); err == nil && len(raw) == strength.Bytes() {
			entropy = raw
			break
		}
		digest := sha256.Sum256([]byte(req.SourceText))
		entropy = digest[:strength.Bytes()]
	default:
		var err error
		entropy, err = wallet.FreshEntropy(strength)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("generate entropy: %w", err).Error())
		}
		// Client-supplied extra randomness folds into the fresh entropy, so
		// the result is never weaker than crypto/rand alone.
		if len(req.ExtraEntropy) > 0 {
			digest := sha256.Sum256(append(entropy, req.ExtraEntropy...))
			entropy = digest[:strength.Bytes()]
		}
	}

	w, err := h.svc.GenerateWalletFromEntropy(entropy, req.Passphrase, true, allSidechainSlots())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("derive wallet from entropy: %w", err).Error())
	}

	return &pb.PreviewWalletFromEntropyResponse{
		EntropyHex:       hex.EncodeToString(entropy),
		Mnemonic:         w.Master.Mnemonic,
		SeedHex:          w.Master.SeedHex,
		MasterKey:        w.Master.MasterKey,
		ChainCode:        w.Master.ChainCode,
		Bip39Binary:      w.Master.BIP39Binary,
		Bip39Checksum:    w.Master.BIP39Checksum,
		Bip39ChecksumHex: w.Master.BIP39ChecksumHex,
	}, nil
}

// ============================================================================
// Watch Wallet Data (server-streaming)
// ============================================================================

func (h *WalletHandler) WatchWalletData(ctx context.Context, req *emptypb.Empty, stream rpc.WalletManagerServiceWatchWalletDataServerStream) error {
	var seq int64

	// Per-stream subscription. The wallet service fans out notifyChanged to
	// every subscriber, so concurrent Watch streams don't steal each other's
	// events. ctx scopes the subscription to this stream's lifetime.
	//
	// Subscribe BEFORE the initial send: the channel is buffered (cap 1), so a
	// wallet-load notification that fires during or right after the first frame
	// is retained and replayed by the loop below. Subscribing after the initial
	// send loses that wakeup, leaving the stream stuck on an empty first frame
	// (empty wallet dropdown, null activeWalletId, endless status recovery).
	stateChanged := h.svc.Subscribe(ctx)

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

func (h *WalletHandler) sendWalletData(stream rpc.WalletManagerServiceWatchWalletDataServerStream, seq *int64) error {
	resp := buildWatchWalletDataResponse(
		h.svc.GetAllWallets(),
		h.svc.ActiveWalletID(),
		h.svc.StarterWalletID(),
		h.svc.State(),
		h.svc.IsEncrypted(),
		h.bip47NetParams(),
		h.bip47Capable,
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

// bip47Capable reports whether a wallet's backend can participate in BIP47, so a
// payment code is advertised only for wallets the inbound engine actually
// watches. Same capability source the engine and send path use (Core + electrum,
// not the enforcer or an unconfigured backend).
func (h *WalletHandler) bip47Capable(walletID string) bool {
	if h.engine == nil {
		return false
	}
	_, ok := h.engine.Bip47BackendFor(walletID)
	return ok
}

func buildWatchWalletDataResponse(wallets []wallet.WalletData, activeID, starterID string, state wallet.State, encrypted bool, netParams *chaincfg.Params, bip47Capable func(walletID string) bool, onBip47Err func(walletID string, err error)) *pb.WatchWalletDataResponse {
	pbWallets := make([]*pb.WalletMetadata, len(wallets))
	for i, w := range wallets {
		var gradientJSON string
		if w.Gradient != nil {
			gradientJSON = string(w.Gradient)
		}
		// Watch-only wallets hold no seed; skip BIP47 derivation on them. The
		// code is advertised only for BIP47-capable backends (Core + electrum),
		// the same wallets the inbound engine watches.
		var bip47Code string
		// BIP47 derives from a single master seed, which multisig and watch-only
		// wallets don't have — skip them rather than derive from an empty seed.
		if w.Master.SeedHex != "" && !w.IsWatchOnly() && bip47Capable(w.ID) {
			code, err := wallet.Bip47PaymentCodeFromSeed(w.Master.SeedHex, netParams)
			if err != nil && onBip47Err != nil {
				onBip47Err(w.ID, err)
			}
			bip47Code = code
		}
		md := &pb.WalletMetadata{
			Id:                  w.ID,
			Name:                w.Name,
			WalletType:          walletTypeToProto(w.WalletType),
			WatchOnly:           w.IsWatchOnly(),
			HardwareDeviceType:  w.HardwareDeviceType(),
			HardwareFingerprint: w.HardwareFingerprint(),
			GradientJson:        gradientJSON,
			CreatedAt:           w.CreatedAt.Format(time.RFC3339),
			Bip47PaymentCode:    bip47Code,
			Multisig:            multisigInfoProto(&w),
			ReceiveAddressTypes: receiveAddressTypesProto(&w),
			IsStarter:           w.ID == starterID,
			ScriptType:          w.ScriptType,
			AccountIndex:        w.AccountIndex,
			DerivationPath:      w.DerivationPath,
		}
		// The starter wallet's seed derives the L1 and sidechain starters, so
		// only it carries them — whichever wallet happens to be active.
		if w.ID == starterID {
			md.MasterMnemonic = w.Master.Mnemonic
			md.L1Mnemonic = w.L1.Mnemonic
			md.Sidechains = lo.Map(w.Sidechains, func(sc wallet.SidechainWallet, _ int) *pb.SidechainStarter {
				return &pb.SidechainStarter{
					Slot:     int32(sc.Slot),
					Name:     sc.Name,
					Mnemonic: sc.Mnemonic,
				}
			})
		}
		pbWallets[i] = md
	}
	return &pb.WatchWalletDataResponse{
		HasWallet:      state != wallet.StateNoWallet, //nolint:staticcheck // old apps read it
		Encrypted:      encrypted,
		Unlocked:       state == wallet.StateUnlocked, //nolint:staticcheck // old apps read it
		ActiveWalletId: activeID,
		Wallets:        pbWallets,
		State:          walletStateToProto(state),
	}
}

// ============================================================================
// Core variant RPCs
// ============================================================================

func (h *WalletHandler) ListCoreVariants(ctx context.Context, req *pb.ListCoreVariantsRequest) (*pb.ListCoreVariantsResponse, error) {
	if h.orch == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "orchestrator not configured")
	}
	out := lo.Map(h.orch.ListCoreVariants(), func(v orchestrator.CoreVariantSpec, _ int) *pb.CoreVariant {
		return &pb.CoreVariant{
			Id:          v.ID,
			DisplayName: coreVariantDisplayName(v.ID),
			Installed:   orchestrator.CoreVariantInstalled(h.orch.DataDir, v, "bitcoind"),
		}
	})
	// Display order: Patched first (default), Core second, Knots third.
	// Anything else sorts alphabetically after.
	sort.Slice(out, func(i, j int) bool {
		return coreVariantOrder(out[i].Id) < coreVariantOrder(out[j].Id)
	})

	// Clamp active_id to the visible list. The persisted ID is fine to keep
	// on disk — but the UI dropdown will throw when given a value that isn't
	// one of its items, so an out-of-list active surfaces as "".
	activeID := h.orch.CoreVariant()
	if !lo.ContainsBy(out, func(v *pb.CoreVariant) bool { return v.Id == activeID }) {
		activeID = ""
	}
	return &pb.ListCoreVariantsResponse{
		Variants: out,
		ActiveId: activeID,
	}, nil
}

func (h *WalletHandler) GetCoreVariant(ctx context.Context, req *pb.GetCoreVariantRequest) (*pb.GetCoreVariantResponse, error) {
	if h.orch == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "orchestrator not configured")
	}
	return &pb.GetCoreVariantResponse{Id: h.orch.CoreVariant()}, nil
}

func (h *WalletHandler) SetCoreVariant(ctx context.Context, req *pb.SetCoreVariantRequest) (*pb.SetCoreVariantResponse, error) {
	if h.orch == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "orchestrator not configured")
	}
	if req.Id == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "variant id required")
	}
	if err := h.orch.SetCoreVariant(ctx, req.Id); err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return &pb.SetCoreVariantResponse{}, nil
}

// ============================================================================
// Electrum server selection
// ============================================================================

func (h *WalletHandler) GetElectrumServer(ctx context.Context, req *pb.GetElectrumServerRequest) (*pb.GetElectrumServerResponse, error) {
	if h.engine == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "wallet engine not configured")
	}
	url, err := h.engine.ElectrumServerURL()
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	defaultURL := ""
	override := ""
	if h.orch != nil {
		defaultURL = h.orch.DefaultElectrumServerURL()
		override = h.orch.ElectrumServerOverride()
	}
	return &pb.GetElectrumServerResponse{
		Url:        url,
		IsOverride: override != "",
		DefaultUrl: defaultURL,
	}, nil
}

func (h *WalletHandler) SetElectrumServer(ctx context.Context, req *pb.SetElectrumServerRequest) (*pb.SetElectrumServerResponse, error) {
	if h.engine == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "wallet engine not configured")
	}

	// Empty URL resets to the network default; resolve it here so the switch is
	// validated and persisted as a cleared override, not as a literal default.
	target := req.Url
	reset := target == ""
	if reset {
		if h.orch == nil {
			return nil, connect.Errorf(connect.CodeFailedPrecondition, "orchestrator not configured")
		}
		target = h.orch.DefaultElectrumServerURL()
		if target == "" {
			return nil, connect.Errorf(connect.CodeFailedPrecondition, "no default electrum server for this network")
		}
	}

	tip, err := h.engine.SetElectrumServerURL(ctx, target)
	if err != nil {
		return nil, err
	}

	if h.orch != nil {
		persist := target
		if reset {
			persist = ""
		}
		if perr := h.orch.PersistElectrumServerURL(persist); perr != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("server switched but persisting it failed: %w", perr).Error())
		}
	}

	return &pb.SetElectrumServerResponse{
		Url:       target,
		TipHeight: int64(tip),
	}, nil
}

// ============================================================================
// Tor routing
// ============================================================================

func (h *WalletHandler) GetTorConfig(ctx context.Context, req *pb.GetTorConfigRequest) (*pb.GetTorConfigResponse, error) {
	if h.engine == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "wallet engine not configured")
	}
	enabled, proxyAddr, err := h.engine.TorConfig()
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	return &pb.GetTorConfigResponse{
		Enabled:      enabled,
		Proxy:        proxyAddr,
		DefaultProxy: orchestrator.DefaultTorProxy,
	}, nil
}

func (h *WalletHandler) SetTorConfig(ctx context.Context, req *pb.SetTorConfigRequest) (*pb.SetTorConfigResponse, error) {
	if h.engine == nil {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "wallet engine not configured")
	}

	proxyAddr := req.Proxy
	if req.Enabled && proxyAddr == "" {
		proxyAddr = orchestrator.DefaultTorProxy
	}

	tip, err := h.engine.SetTorConfig(ctx, req.Enabled, proxyAddr)
	if err != nil {
		return nil, err
	}

	if h.orch != nil {
		persistProxy := proxyAddr
		if !req.Enabled {
			persistProxy = ""
		}
		if perr := h.orch.PersistTorConfig(req.Enabled, persistProxy); perr != nil {
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("tor routing switched but persisting it failed: %w", perr).Error())
		}
	}

	return &pb.SetTorConfigResponse{
		Enabled:   req.Enabled,
		Proxy:     proxyAddr,
		TipHeight: int64(tip),
	}, nil
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
	out.Wallets = lo.Map(backup.Wallets, func(w wallet.WalletSummary, _ int) *pb.BackupWalletSummary {
		return &pb.BackupWalletSummary{
			Id:         w.ID,
			Name:       w.Name,
			WalletType: string(w.WalletType),
		}
	})
	out.LatestKnownBalance = lo.Map(backup.LatestKnownBalance, func(b wallet.BalanceSnapshot, _ int) *pb.BalanceSnapshot {
		snap := &pb.BalanceSnapshot{
			Binary:        b.Binary,
			DisplayName:   b.DisplayName,
			ConfirmedSats: b.ConfirmedSats,
			PendingSats:   b.PendingSats,
		}
		if !b.UpdatedAt.IsZero() {
			snap.UpdatedAt = timestamppb.New(b.UpdatedAt)
		}
		return snap
	})
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

func (h *WalletHandler) CreatePsbt(ctx context.Context, req *pb.CreatePsbtRequest) (*pb.CreatePsbtResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	sendReq := wallet.SendRequest{
		DestinationsSats:      req.Destinations,
		FeeRateSatPerVB:       req.FeeRateSatPerVbyte,
		FixedFeeSats:          req.FixedFeeSats,
		OpReturnHex:           req.OpReturnHex,
		SubtractFeeFromAmount: req.SubtractFeeFromAmount,
		AllowReplay:           req.AllowReplay,
	}
	if err := h.refuseFrozenInputs(req.RequiredInputs); err != nil {
		return nil, err
	}
	sendReq.RequiredInputs = lo.Map(req.RequiredInputs, func(u *pb.UnspentOutput, _ int) wallet.RequiredInput {
		return wallet.RequiredInput{
			TxID: u.Txid, Vout: int(u.Vout), AmountSats: u.AmountSats,
		}
	})
	sendReq.RawOutputs = mapRawOutputs(req.RawOutputs)
	sendReq.ExternalInputs = mapExternalInputs(req.ExternalInputs)
	b64, err := h.engine.CreatePSBT(ctx, walletID, sendReq)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.CreatePsbtResponse{PsbtBase64: b64}, nil
}

func (h *WalletHandler) SignPsbt(ctx context.Context, req *pb.SignPsbtRequest) (*pb.SignPsbtResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	walletID, err := h.engine.ResolveWalletID(req.WalletId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}
	out, err := h.engine.SignPSBT(ctx, walletID, req.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.SignPsbtResponse{PsbtBase64: out}, nil
}

func (h *WalletHandler) CombinePsbt(ctx context.Context, req *pb.CombinePsbtRequest) (*pb.CombinePsbtResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	out, err := h.engine.CombinePSBT(req.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.CombinePsbtResponse{PsbtBase64: out}, nil
}

func (h *WalletHandler) FinalizePsbt(ctx context.Context, req *pb.FinalizePsbtRequest) (*pb.FinalizePsbtResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	rawHex, err := h.engine.FinalizePSBT(req.PsbtBase64)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.FinalizePsbtResponse{RawTxHex: rawHex}, nil
}

func (h *WalletHandler) GetAddressUnspent(ctx context.Context, req *pb.GetAddressUnspentRequest) (*pb.GetAddressUnspentResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	address := strings.TrimSpace(req.Address)
	if address == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "address is required")
	}

	utxos, tip, err := h.engine.AddressUnspent(ctx, address)
	if err != nil {
		return nil, rpcError(err)
	}

	return &pb.GetAddressUnspentResponse{
		Utxos: lo.Map(utxos, func(u wallet.UTXO, _ int) *pb.AddressUnspentOutput {
			return &pb.AddressUnspentOutput{
				Txid:          u.TxID,
				Vout:          int32(u.Vout),
				ValueSats:     int64(math.Round(u.Amount * 1e8)),
				Confirmations: int32(u.Confirmations),
				BlockTime:     u.ReceivedAt,
			}
		}),
		TipHeight: int32(tip),
	}, nil
}

func (h *WalletHandler) BroadcastElectrumTransaction(ctx context.Context, req *pb.BroadcastElectrumTransactionRequest) (*pb.BroadcastElectrumTransactionResponse, error) {
	if err := h.requireEngine(); err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	txHex := strings.TrimSpace(req.TxHex)
	if txHex == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "tx_hex is required")
	}

	txid, err := h.engine.BroadcastRaw(ctx, txHex)
	if err != nil {
		return nil, rpcError(err)
	}
	return &pb.BroadcastElectrumTransactionResponse{Txid: txid}, nil
}
