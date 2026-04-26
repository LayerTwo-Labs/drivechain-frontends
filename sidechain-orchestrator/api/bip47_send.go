package api

import (
	"context"
	"errors"
	"fmt"
	"math"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"google.golang.org/protobuf/proto"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
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
	// after a successful broadcast.
	recipientCode string
}

// expandBip47Destinations inspects the requested destinations for a BIP47
// payment code. If found, it derives the per-payment address and (when
// needed) builds the notification tx, returning a substituted destinations
// map. If no BIP47 code is present, the original destinations pass through.
func (h *WalletHandler) expandBip47Destinations(
	ctx context.Context,
	walletID, walletType string,
	destinations map[string]int64,
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

	if walletType != "bitcoinCore" {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("BIP47 send for %s wallets is not yet supported: orchestrator can only blind ECDH for bitcoinCore wallets, where the master seed is locally derivable", walletType))
	}

	if h.engine == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("bitcoin Core RPC not configured"))
	}
	if h.bip47State == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("bip47 state store not configured"))
	}

	seedHex := h.walletSeedHex(walletID)
	if seedHex == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("wallet %s has no master seed", walletID))
	}

	netParams, err := bip47send.NetworkParams(h.engine.Network())
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err)
	}

	result, err := bip47send.SubstituteBip47Destination(seedHex, walletID, destinations, netParams, h.bip47State)
	if err != nil {
		switch {
		case errors.Is(err, bip47send.ErrMultiDestination),
			errors.Is(err, bip47send.ErrSelfSend),
			errors.Is(err, bip47send.ErrUnsupportedVersion):
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if !result.IsBip47 {
		return &bip47Expansion{destinations: result.Destinations}, nil
	}

	expansion := &bip47Expansion{
		destinations:  result.Destinations,
		recipientCode: result.RecipientCode,
	}

	state, err := h.bip47State.GetState(walletID, result.RecipientCode)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("read bip47 state: %w", err))
	}
	if state != nil && state.NotificationTxID != nil {
		return expansion, nil
	}

	rawHex, _, err := h.buildBip47NotificationTx(ctx, walletID, seedHex, result.Recipient, netParams)
	if err != nil {
		return nil, err
	}
	expansion.notificationTxHex = rawHex
	return expansion, nil
}

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
) (string, string, error) {
	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, err)
	}

	utxos, err := h.engine.CoreRPC().ListUnspent(ctx, coreName)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("list unspent: %w", err))
	}

	const dustSats int64 = 546
	feeSats := bip47send.EstimateNotificationFee(2)
	minRequired := dustSats + feeSats + dustSats

	var picked *wallet.CoreUTXO
	for i, u := range utxos {
		if !u.Spendable {
			continue
		}
		amountSats := int64(math.Round(u.Amount * 1e8))
		if amountSats < minRequired {
			continue
		}
		picked = &utxos[i]
		break
	}
	if picked == nil {
		return "", "", connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("no spendable UTXO ≥ %d sats available for BIP47 notification tx", minRequired))
	}

	info, err := h.engine.CoreRPC().GetAddressInfo(ctx, coreName, picked.Address)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("getaddressinfo: %w", err))
	}
	if info.HDKeyPath == "" {
		return "", "", connect.NewError(connect.CodeInternal,
			fmt.Errorf("no HD key path for address %s; cannot derive privkey for BIP47 blinding", picked.Address))
	}

	desigPriv, err := bip47send.DerivePrivKeyFromHDPath(seedHex, info.HDKeyPath)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("derive designated input privkey: %w", err))
	}

	notifAddr, err := bip47.DeriveNotificationAddress(recipient, netParams)
	if err != nil {
		return "", "", connect.NewError(connect.CodeInternal, fmt.Errorf("recipient notification address: %w", err))
	}

	changeAddrStr, err := h.engine.CoreRPC().GetRawChangeAddress(ctx, coreName)
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
		HDKeyPath:  info.HDKeyPath,
	}

	rawHex, _, err := bip47send.BuildNotificationTx(
		seedHex,
		recipient,
		desig,
		desigPriv,
		notifAddr,
		changeAddr,
		dustSats,
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
func (h *WalletHandler) broadcastBip47Notification(ctx context.Context, walletID, recipientCode, rawHex string) (string, error) {
	coreName, err := h.engine.GetCoreWalletName(ctx, walletID)
	if err != nil {
		return "", fmt.Errorf("get core wallet: %w", err)
	}
	signed, err := h.engine.CoreRPC().SignRawTransactionWithWallet(ctx, coreName, rawHex)
	if err != nil {
		return "", fmt.Errorf("sign notification tx: %w", err)
	}
	if !signed.Complete {
		return "", errors.New("notification tx signing incomplete")
	}
	txid, err := h.engine.CoreRPC().SendRawTransaction(ctx, signed.Hex)
	if err != nil {
		return "", fmt.Errorf("broadcast notification tx: %w", err)
	}
	if err := h.bip47State.MarkNotified(walletID, recipientCode, txid); err != nil {
		// State write failure after a successful broadcast: surface it.
		// Future sends to this recipient will retry the notification, which is
		// wasteful but not unsafe.
		return txid, fmt.Errorf("notification broadcast %s succeeded but state write failed: %w", txid, err)
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
