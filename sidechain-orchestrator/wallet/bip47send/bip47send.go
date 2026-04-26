// Package bip47send drives the orchestrator-side BIP47 send flow for
// bitcoinCore wallets: per-payment address derivation and notification
// transaction assembly. ECDH blinding requires the private key of the
// designated input, which the orchestrator derives locally from the wallet
// seed (stored in WalletData.Master.SeedHex) — Bitcoin Core never reveals it.
package bip47send

import (
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

// NetworkParams maps the orchestrator's network string to chaincfg.Params.
// Returns an error for networks where BIP47 sends are not supported.
func NetworkParams(network string) (*chaincfg.Params, error) {
	switch network {
	case "mainnet":
		return &chaincfg.MainNetParams, nil
	case "signet":
		return &chaincfg.SigNetParams, nil
	case "regtest":
		return &chaincfg.RegressionNetParams, nil
	default:
		return nil, fmt.Errorf("BIP47 send not supported on network %q", network)
	}
}

// DesignatedInput identifies the UTXO that funds the notification tx and
// whose private key blinds the OP_RETURN payload.
type DesignatedInput struct {
	TxID       string
	Vout       uint32
	AmountSats int64
	Address    string
	HDKeyPath  string // m/84'/coin'/0'/{0,1}/i
}

// BuildNotificationTx returns the unsigned notification tx hex and the
// outpoint used as the designated input. The OP_RETURN holds the blinded
// payment code; the recipient sees a P2PKH dust output to their notification
// address.
//
// Outputs (in order):
//  0. Recipient's notification P2PKH address (dustSats)
//  1. OP_RETURN with the 80-byte blinded payment code
//  2. Change back to changeAddress (omitted if below dust)
func BuildNotificationTx(
	senderSeedHex string,
	recipient *bip47.PaymentCode,
	desig DesignatedInput,
	desigPriv *btcec.PrivateKey,
	notificationAddr btcutil.Address,
	changeAddr btcutil.Address,
	dustSats int64,
	feeSats int64,
	net *chaincfg.Params,
) (rawHex string, outpoint wire.OutPoint, err error) {
	senderPC, err := bip47.PaymentCodeFromSeed(senderSeedHex)
	if err != nil {
		return "", wire.OutPoint{}, fmt.Errorf("sender payment code: %w", err)
	}

	prevHash, err := chainhash.NewHashFromStr(desig.TxID)
	if err != nil {
		return "", wire.OutPoint{}, fmt.Errorf("decode designated txid: %w", err)
	}
	outpoint = wire.OutPoint{Hash: *prevHash, Index: desig.Vout}

	senderSerialized := senderPC.Serialize()
	blinded, err := bip47.BuildBlindedPayload(senderSerialized, desigPriv, recipient, outpoint)
	if err != nil {
		return "", wire.OutPoint{}, fmt.Errorf("blind payload: %w", err)
	}

	tx := wire.NewMsgTx(2)
	tx.AddTxIn(&wire.TxIn{
		PreviousOutPoint: outpoint,
		Sequence:         wire.MaxTxInSequenceNum,
	})

	notifScript, err := txscript.PayToAddrScript(notificationAddr)
	if err != nil {
		return "", wire.OutPoint{}, fmt.Errorf("notification script: %w", err)
	}
	tx.AddTxOut(wire.NewTxOut(dustSats, notifScript))

	opReturn, err := txscript.NullDataScript(blinded[:])
	if err != nil {
		return "", wire.OutPoint{}, fmt.Errorf("op_return script: %w", err)
	}
	tx.AddTxOut(wire.NewTxOut(0, opReturn))

	changeSats := desig.AmountSats - dustSats - feeSats
	if changeSats < 0 {
		return "", wire.OutPoint{}, fmt.Errorf("designated input %d sats too small for dust+fee (%d)", desig.AmountSats, dustSats+feeSats)
	}
	if changeSats >= dustSats {
		changeScript, err := txscript.PayToAddrScript(changeAddr)
		if err != nil {
			return "", wire.OutPoint{}, fmt.Errorf("change script: %w", err)
		}
		tx.AddTxOut(wire.NewTxOut(changeSats, changeScript))
	}

	var buf strings.Builder
	if err := tx.Serialize(hexWriter{&buf}); err != nil {
		return "", wire.OutPoint{}, fmt.Errorf("serialize tx: %w", err)
	}
	return buf.String(), outpoint, nil
}

type hexWriter struct{ b *strings.Builder }

func (h hexWriter) Write(p []byte) (int, error) {
	h.b.WriteString(hex.EncodeToString(p))
	return len(p), nil
}

// DerivePrivKeyFromHDPath returns the private key for an HD path of form
// m/84'/<coin>'/0'/<branch>/<index> (or any non-hardened tail) given the
// wallet seed. Hardened components must use the apostrophe form. Path
// components beyond the first hardened ones are derived non-hardened.
func DerivePrivKeyFromHDPath(seedHex, hdkeypath string) (*btcec.PrivateKey, error) {
	if hdkeypath == "" {
		return nil, errors.New("empty hdkeypath")
	}
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed: %w", err)
	}

	master, err := hdkeychain.NewMaster(seed, &chaincfg.MainNetParams)
	if err != nil {
		return nil, fmt.Errorf("master key: %w", err)
	}

	parts := strings.Split(hdkeypath, "/")
	if len(parts) == 0 || parts[0] != "m" {
		return nil, fmt.Errorf("hdkeypath must start with m/, got %q", hdkeypath)
	}
	cur := master
	for _, p := range parts[1:] {
		hardened := strings.HasSuffix(p, "'") || strings.HasSuffix(p, "h")
		nStr := strings.TrimRight(p, "'h")
		n, err := strconv.ParseUint(nStr, 10, 32)
		if err != nil {
			return nil, fmt.Errorf("parse hd component %q: %w", p, err)
		}
		idx := uint32(n)
		if hardened {
			idx += hdkeychain.HardenedKeyStart
		}
		cur, err = cur.Derive(idx)
		if err != nil {
			return nil, fmt.Errorf("derive %s: %w", p, err)
		}
	}
	priv, err := cur.ECPrivKey()
	if err != nil {
		return nil, fmt.Errorf("ecprivkey: %w", err)
	}
	return priv, nil
}

// EstimateNotificationFee picks a flat fee for the notification tx. The exact
// vsize is small (~150 vB) so feerate × 200 is a safe over-estimate that
// avoids needing an extra Core RPC for fee estimation. The receiver pays
// nothing — only the sender's UTXO is consumed.
func EstimateNotificationFee(feeRateSatPerVbyte int64) int64 {
	if feeRateSatPerVbyte <= 0 {
		feeRateSatPerVbyte = 2
	}
	return int64(math.Max(float64(feeRateSatPerVbyte*200), 500))
}

// Sentinel errors for the wallet handler to map onto gRPC codes.
var (
	ErrMultiDestination   = errors.New("BIP47 sends must be single-destination")
	ErrSelfSend           = errors.New("BIP47 self-send: sender and recipient payment codes match")
	ErrUnsupportedVersion = errors.New("unsupported BIP47 payment code version")
)

// IndexReserver is the minimum interface a state store must satisfy for
// SubstituteBip47Destination to advance the per-recipient send counter
// atomically.
type IndexReserver interface {
	ReserveNextIndex(walletID, recipientCode string) (uint32, error)
}

// SubstituteResult is the outcome of resolving a BIP47-bearing destinations
// map into a substituted (per-payment address) destinations map.
type SubstituteResult struct {
	// Destinations is the new destinations map with the BIP47 code replaced
	// by a derived per-payment address. Identity to the input when no BIP47
	// code is present.
	Destinations map[string]int64
	// RecipientCode is the BIP47 code of the recipient, or "" when no BIP47
	// destination was found.
	RecipientCode string
	// Recipient is the parsed payment code, nil when no BIP47 destination.
	Recipient *bip47.PaymentCode
	// Index is the per-payment index reserved for this send. Zero when
	// passthrough.
	Index uint32
	// IsBip47 reports whether substitution actually happened.
	IsBip47 bool
}

// SubstituteBip47Destination takes a destinations map possibly containing a
// BIP47 payment code, and returns a substituted destinations map with the
// code replaced by the per-payment derived address. Caller is responsible
// for separately building/broadcasting any required notification tx based
// on the (state, IsBip47) outcome.
//
// Returns ErrMultiDestination, ErrSelfSend, ErrUnsupportedVersion as
// applicable. Network must be a *chaincfg.Params for the active network.
//
// The reserver MUST be backed by an atomic counter so that concurrent calls
// for the same (walletID, recipientCode) pair never reuse the same index.
func SubstituteBip47Destination(
	senderSeedHex, walletID string,
	destinations map[string]int64,
	net *chaincfg.Params,
	reserver IndexReserver,
) (*SubstituteResult, error) {
	var bip47Addr string
	var bip47Sats int64
	for addr, sats := range destinations {
		if _, err := bip47.ParsePaymentCode(addr); err == nil {
			bip47Addr = addr
			bip47Sats = sats
			break
		}
	}
	if bip47Addr == "" {
		return &SubstituteResult{Destinations: destinations}, nil
	}
	if len(destinations) > 1 {
		return nil, ErrMultiDestination
	}

	recipient, err := bip47.ParsePaymentCode(bip47Addr)
	if err != nil {
		return nil, fmt.Errorf("parse recipient payment code: %w", err)
	}
	if recipient.Version != 0x01 {
		return nil, fmt.Errorf("%w: 0x%02x", ErrUnsupportedVersion, recipient.Version)
	}

	senderPC, err := bip47.PaymentCodeFromSeed(senderSeedHex)
	if err != nil {
		return nil, fmt.Errorf("derive sender payment code: %w", err)
	}
	if senderPC.Equal(recipient) {
		return nil, ErrSelfSend
	}

	idx, err := reserver.ReserveNextIndex(walletID, bip47Addr)
	if err != nil {
		return nil, fmt.Errorf("reserve next index: %w", err)
	}

	derived, err := bip47.DerivePaymentAddress(senderSeedHex, recipient, idx, net)
	if err != nil {
		return nil, fmt.Errorf("derive payment address: %w", err)
	}

	return &SubstituteResult{
		Destinations:  map[string]int64{derived.EncodeAddress(): bip47Sats},
		RecipientCode: bip47Addr,
		Recipient:     recipient,
		Index:         idx,
		IsBip47:       true,
	}, nil
}
