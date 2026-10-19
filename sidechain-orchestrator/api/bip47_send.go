package api

import (
	"context"
	"errors"
	"fmt"
	"math"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/samber/lo"
	"google.golang.org/protobuf/proto"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47send"
)

// bip47Expansion is the result of running expandBip47Destinations: either no
// BIP47 destination was present (passthrough) or a BIP47 destination was
// substituted with a derived address and a notification tx may need to be
// broadcast first.
type bip47Expansion struct {
	// destinations is the (possibly substituted) destinations map to forward
	// to the underlying send path. Always populated.
	destinations map[string]int64
	// notificationTxHex, if non-empty, is the unsigned notification tx (raw
	// hex) the wallet handler must sign + broadcast BEFORE the payment.
	notificationTxHex string
	// recipientCode is the recipient's payment code, used to MarkNotified
	// after a successful broadcast. Empty when passthrough.
	recipientCode string
	// sendIndex is the per-payment index reserved for this send, released
	// again when the payment does not go out.
	sendIndex uint32
}

func bip47SubstituteError(err error) error {
	switch {
	case errors.Is(err, bip47send.ErrMultiDestination),
		errors.Is(err, bip47send.ErrSelfSend),
		errors.Is(err, bip47send.ErrUnsupportedVersion):
		return connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewError(connect.CodeInternal, err)
}

// sizingIndex stands in for the next BIP47 index. Every index gives a payment
// address of the same script, so a preview sizes the payment without a reservation.
type sizingIndex struct{}

func (sizingIndex) ReserveNextIndex(string, string) (uint32, error) { return 0, nil }

// sizeBip47Destinations replaces a BIP47 payment code with an address of the
// same script, so a send preview can size the payment output. notifies is true
// when the send publishes a notification before the payment.
func (h *WalletHandler) sizeBip47Destinations(
	walletID string, destinations map[string]int64,
) (sized map[string]int64, notifies bool, err error) {
	hasBip47 := lo.SomeBy(lo.Keys(destinations), func(addr string) bool {
		_, err := bip47.ParsePaymentCode(addr)
		return err == nil
	})
	if !hasBip47 {
		return destinations, false, nil
	}
	if h.bip47State == nil {
		return nil, false, connect.NewError(connect.CodeFailedPrecondition, errors.New("bip47 state store not configured"))
	}
	seedHex := h.walletSeedHex(walletID)
	if seedHex == "" {
		return nil, false, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("wallet %s has no master seed", walletID))
	}
	netParams := h.engine.Network()
	if netParams == nil {
		return nil, false, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("BIP47 send not supported on this network"))
	}
	result, err := bip47send.SubstituteBip47Destination(seedHex, walletID, destinations, netParams, sizingIndex{})
	if err != nil {
		return nil, false, bip47SubstituteError(err)
	}
	state, err := h.bip47State.GetState(walletID, result.RecipientCode)
	if err != nil {
		return nil, false, connect.NewError(connect.CodeInternal, fmt.Errorf("read bip47 state: %w", err))
	}
	return result.Destinations, state == nil || state.NotificationTxID == nil, nil
}

// expandBip47Destinations inspects the requested destinations for a BIP47
// payment code. If found, it derives the per-payment address and (when
// needed) builds the notification tx, returning a substituted destinations
// map. If no BIP47 code is present, the original destinations pass through.
func (h *WalletHandler) expandBip47Destinations(
	ctx context.Context,
	walletID string,
	destinations map[string]int64,
	feeRate int64,
	pinnedNotification *wallet.RequiredInput,
	paymentInputs []wallet.RequiredInput,
) (*bip47Expansion, error) {
	hasBip47 := false
	for addr := range destinations {
		if _, err := bip47.ParsePaymentCode(addr); err == nil {
			hasBip47 = true
			break
		}
	}
	if !hasBip47 {
		return &bip47Expansion{destinations: destinations}, nil
	}

	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet backend not configured"))
	}
	// BIP47 send works for any backend that can sign the notification tx and
	// hold the seed for ECDH blinding — Core and electrum both qualify. The
	// enforcer (no spendable wallet) does not implement Bip47Backend.
	if _, ok := h.engine.Bip47BackendFor(walletID); !ok {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("BIP47 send is not supported for wallet %s: its backend cannot build the notification transaction", walletID))
	}
	if h.bip47State == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("bip47 state store not configured"))
	}

	seedHex := h.walletSeedHex(walletID)
	if seedHex == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("wallet %s has no master seed", walletID))
	}

	netParams := h.engine.Network()
	if netParams == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("BIP47 send not supported on this network"))
	}

	result, err := bip47send.SubstituteBip47Destination(seedHex, walletID, destinations, netParams, h.bip47State)
	if err != nil {
		return nil, bip47SubstituteError(err)
	}
	if !result.IsBip47 {
		return &bip47Expansion{destinations: result.Destinations}, nil
	}

	expansion := &bip47Expansion{
		destinations:  result.Destinations,
		recipientCode: result.RecipientCode,
		sendIndex:     result.Index,
	}

	state, err := h.bip47State.GetState(walletID, result.RecipientCode)
	if err != nil {
		h.releaseBip47Index(walletID, expansion)
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("read bip47 state: %w", err))
	}
	if state != nil && state.NotificationTxID != nil {
		return expansion, nil
	}

	rawHex, _, err := h.buildBip47NotificationTx(
		ctx, walletID, seedHex, result.Recipient, netParams, feeRate, pinnedNotification, paymentInputs,
	)
	if err != nil {
		h.releaseBip47Index(walletID, expansion)
		return nil, err
	}
	expansion.notificationTxHex = rawHex
	return expansion, nil
}

// resolveSendFeeRate fills in the rate a send pays when the caller names
// neither a rate nor a fixed fee, so the caller can price the send before it
// broadcasts anything. A backend that prices its own sends needs nothing.
func (h *WalletHandler) resolveSendFeeRate(ctx context.Context, walletID string, req *wallet.SendRequest) error {
	if req.FeeRateSatPerVB > 0 || req.FixedFeeSats > 0 {
		return nil
	}
	rater, ok := h.engine.FeeRaterFor(walletID)
	if !ok {
		return nil
	}
	rate, err := rater.FeeRateForTarget(ctx, wallet.SendFeeTarget)
	if err != nil {
		return connect.NewError(connect.CodeUnavailable, fmt.Errorf("no fee estimate for the payment: %w", err))
	}
	req.FeeRateSatPerVB = int64(math.Ceil(rate))
	return nil
}

// releaseBip47Index gives back the per-payment index reserved for a send that
// failed, so the retry derives the same address instead of burning an index.
// No-op for passthrough (non-BIP47) expansions.
func (h *WalletHandler) releaseBip47Index(walletID string, expansion *bip47Expansion) {
	if expansion == nil || expansion.recipientCode == "" || h.bip47State == nil {
		return
	}
	// Best-effort: the send already failed, and a skipped index is absorbed by
	// the recipient's gap limit.
	_ = h.bip47State.ReleaseIndex(walletID, expansion.recipientCode, expansion.sendIndex)
}

// bip47NotificationCoin picks the coin a BIP47 notification spends, and its
// fee. A rate of 0 takes the chain estimate. pinned names the coin a send
// preview picked. The pick skips frozen coins and the coins in exclude, which
// the payment spends.
func (h *WalletHandler) bip47NotificationCoin(
	ctx context.Context,
	walletID string,
	feeRate int64,
	pinned *wallet.RequiredInput,
	exclude []wallet.RequiredInput,
) (wallet.UTXO, int64, error) {
	utxos, err := h.unfrozenSpendableCoins(ctx, walletID)
	if err != nil {
		return wallet.UTXO{}, 0, err
	}
	skip := map[string]bool{}
	for _, in := range exclude {
		skip[(wallet.Outpoint{TxID: in.TxID, Vout: in.Vout}).Key()] = true
	}

	rate := float64(feeRate)
	if rate <= 0 {
		if rater, ok := h.engine.FeeRaterFor(walletID); ok {
			rate, err = rater.FeeRateForTarget(ctx, wallet.SendFeeTarget)
			if err != nil {
				return wallet.UTXO{}, 0, connect.NewError(connect.CodeUnavailable, fmt.Errorf("no fee estimate for the bip47 notification: %w", err))
			}
		}
	}
	if rate > wallet.MaxFeeRateSatPerVB {
		return wallet.UTXO{}, 0, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("the fee rate of %.0f sat/vB for the bip47 notification is above the limit of %d sat/vB", rate, wallet.MaxFeeRateSatPerVB))
	}
	feeSats := bip47send.EstimateNotificationFee(int64(math.Ceil(rate)))
	minRequired := bip47NotificationDustSats + feeSats + bip47NotificationDustSats

	// The smallest coin keeps the most value for the payment, which cannot
	// spend the change of the notification.
	var picked *wallet.UTXO
	for i, u := range utxos {
		if skip[(wallet.Outpoint{TxID: u.TxID, Vout: u.Vout}).Key()] {
			continue
		}
		if pinned != nil && (u.TxID != pinned.TxID || u.Vout != pinned.Vout) {
			continue
		}
		if int64(math.Round(u.Amount*1e8)) < minRequired {
			continue
		}
		if picked == nil || u.Amount < picked.Amount {
			picked = &utxos[i]
		}
	}
	if picked != nil {
		return *picked, feeSats, nil
	}
	if pinned != nil {
		return wallet.UTXO{}, 0, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("notification coin %s:%d is not a spendable UTXO of at least %d sats", pinned.TxID, pinned.Vout, minRequired))
	}
	return wallet.UTXO{}, 0, connect.NewError(connect.CodeFailedPrecondition,
		fmt.Errorf("no spendable UTXO ≥ %d sats available for BIP47 notification tx", minRequired))
}

// unfrozenSpendableCoins lists the wallet coins a send can spend. The
// notification pick becomes a required input, which Core spends as it is
// told, so a coin the user froze has to leave the list here.
func (h *WalletHandler) unfrozenSpendableCoins(ctx context.Context, walletID string) ([]wallet.UTXO, error) {
	utxos, err := h.engine.Backend().ListUnspent(ctx, walletID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("list unspent: %w", err))
	}
	frozen, err := h.svc.FrozenCoins(ctx, walletID, lo.Map(utxos, func(u wallet.UTXO, _ int) wallet.Outpoint {
		return wallet.Outpoint{TxID: u.TxID, Vout: u.Vout, Confirmed: u.Confirmations > 0}
	}))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return lo.Filter(utxos, func(u wallet.UTXO, _ int) bool {
		return u.Spendable && !frozen[(wallet.Outpoint{TxID: u.TxID, Vout: u.Vout}).Key()]
	}), nil
}

// bip47NotificationDustSats is the payment to the recipient's notification address.
const bip47NotificationDustSats int64 = 546

// buildBip47NotificationTx assembles the unsigned notification transaction by
// picking a designated UTXO from the bitcoinCore wallet, computing the
// blinded payload via ECDH against the recipient, and wrapping outputs:
// [recipient notification P2PKH dust] + [OP_RETURN blinded payload] + [change].
// Returns the unsigned hex and the address whose privkey blinded the OP_RETURN.
func (h *WalletHandler) buildBip47NotificationTx(
	ctx context.Context,
	walletID, seedHex string,
	recipient *bip47.PaymentCode,
	netParams *chaincfg.Params,
	feeRate int64,
	pinned *wallet.RequiredInput,
	exclude []wallet.RequiredInput,
) (string, string, error) {
	coin, feeSats, err := h.bip47NotificationCoin(ctx, walletID, feeRate, pinned, exclude)
	if err != nil {
		return "", "", err
	}
	picked := &coin

	hdPath, err := h.engine.Backend().AddressHDPath(ctx, walletID, picked.Address)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("address hd path: %w", err))
	}
	if hdPath == "" {
		return "", "", connect.NewError(connect.CodeInternal,
			fmt.Errorf("no HD key path for address %s; cannot derive privkey for BIP47 blinding", picked.Address))
	}

	desigPriv, err := bip47send.DerivePrivKeyFromHDPath(seedHex, hdPath)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("derive designated input privkey: %w", err))
	}

	notifAddr, err := bip47.DeriveNotificationAddress(recipient, netParams)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("recipient notification address: %w", err))
	}

	changeAddrStr, err := h.engine.Backend().NextChangeAddress(ctx, walletID)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("get change address: %w", err))
	}
	changeAddr, err := btcutil.DecodeAddress(changeAddrStr, netParams)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("decode change address: %w", err))
	}

	desig := bip47send.DesignatedInput{
		TxID:       picked.TxID,
		Vout:       uint32(picked.Vout),
		AmountSats: int64(math.Round(picked.Amount * 1e8)),
		Address:    picked.Address,
		HDKeyPath:  hdPath,
	}

	rawHex, _, err := bip47send.BuildNotificationTx(
		seedHex,
		recipient,
		desig,
		desigPriv,
		notifAddr,
		changeAddr,
		bip47NotificationDustSats,
		feeSats,
		netParams,
	)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("build notification tx: %w", err))
	}
	return rawHex, picked.Address, nil
}

// broadcastBip47Notification signs and broadcasts the notification tx through
// the wallet's Core RPC, then marks the recipient as notified. Returns the
// notification txid.
func (h *WalletHandler) broadcastBip47Notification(ctx context.Context, walletID, recipientCode, rawHex string, allowReplay bool) (string, error) {
	// The notification tx spends a real coin, so it takes the same locktime as
	// the payment it precedes.
	if wallet.ReplayProtect(h.svc.Network(), allowReplay) {
		lockTime, err := config.ECashReplayLockTime()
		if err != nil {
			return "", connect.NewError(connect.CodeUnavailable, err)
		}
		protectedHex, err := replay.ApplyLockTimeHex(rawHex, lockTime)
		if err != nil {
			return "", connect.NewError(connect.CodeInternal, err)
		}
		rawHex = protectedHex
	}
	signed, err := h.engine.Backend().SignTransaction(ctx, walletID, rawHex)
	if err != nil {
		return "", fmt.Errorf("sign notification tx: %w", err)
	}
	if !signed.Complete {
		return "", errors.New("notification tx signing incomplete")
	}
	txid, err := h.engine.ChainForWallet(walletID).Broadcast(ctx, signed.Hex)
	if err != nil {
		return "", fmt.Errorf("broadcast notification tx: %w", err)
	}
	if err := h.bip47State.MarkNotified(walletID, recipientCode, txid); err != nil {
		// State write failure after a successful broadcast: surface it.
		// Future sends to this recipient will retry the notification, which is
		// wasteful but not unsafe.
		return txid, fmt.Errorf("notification broadcast %s succeeded but state write failed: %w", txid, err)
	}
	// The broadcast went around the electrum backend, so its scan still lists
	// the spent coin. The payment may spend the notification change instead.
	if w := h.svc.GetWalletByID(walletID); w != nil && w.WalletType == wallet.WalletTypeElectrum {
		if err := h.engine.RefreshElectrumScan(ctx, walletID); err != nil {
			return txid, fmt.Errorf("notification broadcast %s succeeded but the wallet scan failed: %w", txid, err)
		}
	}
	return txid, nil
}

// applyDestinationsToRequest returns a clone of the proto request with the
// destinations map replaced, so the existing send path can consume it
// unchanged without mutating the caller's request.
func applyDestinationsToRequest(req *pb.SendTransactionRequest, dests map[string]int64) *pb.SendTransactionRequest {
	cp := proto.Clone(req).(*pb.SendTransactionRequest)
	cp.Destinations = make(map[string]int64, len(dests))
	for k, v := range dests {
		cp.Destinations[k] = v
	}
	return cp
}

func destinationsEqual(a, b map[string]int64) bool {
	if len(a) != len(b) {
		return false
	}
	for k, v := range a {
		if bv, ok := b[k]; !ok || bv != v {
			return false
		}
	}
	return true
}
