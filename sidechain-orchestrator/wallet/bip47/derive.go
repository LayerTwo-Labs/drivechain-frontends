package bip47

import (
	"crypto/sha256"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
)

// AddressType selects between P2PKH (BIP47 v1 default) and P2WPKH (segwit
// feature, recipient code byte 79 == 0x01).
type AddressType int

const (
	AddressP2PKH AddressType = iota
	AddressP2WPKH
)

func DeriveNotificationAddress(pc *PaymentCode, net *chaincfg.Params) (btcutil.Address, error) {
	if pc == nil {
		return nil, errors.New("nil payment code")
	}
	xpub := pc.AsExtendedPubKey(net)
	child, err := xpub.Derive(0)
	if err != nil {
		return nil, fmt.Errorf("derive child 0: %w", err)
	}
	pub, err := child.ECPubKey()
	if err != nil {
		return nil, fmt.Errorf("ECPubKey: %w", err)
	}
	return p2pkhAddress(pub, net)
}

// DerivePaymentAddress is the sender-side per-payment derivation: index i in
// [0, 2^31). It returns the P2PKH address (v1 default).
func DerivePaymentAddress(senderSeedHex string, recipient *PaymentCode, index uint32, net *chaincfg.Params) (btcutil.Address, error) {
	return DerivePaymentAddressTyped(senderSeedHex, recipient, index, net, AddressP2PKH)
}

func DerivePaymentAddressTyped(senderSeedHex string, recipient *PaymentCode, index uint32, net *chaincfg.Params, addrType AddressType) (btcutil.Address, error) {
	if recipient == nil {
		return nil, errors.New("nil recipient payment code")
	}
	if index >= hdkeychain.HardenedKeyStart {
		return nil, fmt.Errorf("payment index %d must be non-hardened", index)
	}

	senderPC, err := PaymentCodeFromSeed(senderSeedHex)
	if err != nil {
		return nil, fmt.Errorf("sender payment code: %w", err)
	}
	if senderPC.Equal(recipient) {
		return nil, errors.New("self-send: sender and recipient payment codes match")
	}

	// a₀ = sender's m/47'/0'/0'/0 private key
	account, err := SeedAccountKey(senderSeedHex)
	if err != nil {
		return nil, fmt.Errorf("sender account key: %w", err)
	}
	a0Ext, err := account.Derive(0)
	if err != nil {
		return nil, fmt.Errorf("derive a₀: %w", err)
	}
	a0, err := a0Ext.ECPrivKey()
	if err != nil {
		return nil, fmt.Errorf("a₀ ECPrivKey: %w", err)
	}

	// Bᵢ = recipient_xpub.derive(index)
	rxpub := recipient.AsExtendedPubKey(net)
	bExt, err := rxpub.Derive(index)
	if err != nil {
		return nil, fmt.Errorf("derive Bᵢ: %w", err)
	}
	bPub, err := bExt.ECPubKey()
	if err != nil {
		return nil, fmt.Errorf("Bᵢ ECPubKey: %w", err)
	}

	tweaked, err := computePaymentPubKey(a0, bPub)
	if err != nil {
		return nil, err
	}

	switch addrType {
	case AddressP2PKH:
		return p2pkhAddress(tweaked, net)
	case AddressP2WPKH:
		return p2wpkhAddress(tweaked, net)
	default:
		return nil, fmt.Errorf("unknown address type %d", addrType)
	}
}

// computePaymentPubKey returns Bᵢ + SHA256((a·Bᵢ).x)·G. Errors if the SHA256
// of the shared secret is not in [1, n-1], in which case the caller should
// retry with the next index.
func computePaymentPubKey(a *btcec.PrivateKey, bPub *btcec.PublicKey) (*btcec.PublicKey, error) {
	x, err := ecdhX(a, bPub)
	if err != nil {
		return nil, fmt.Errorf("ecdh: %w", err)
	}
	s := sha256.Sum256(x[:])
	return tweakPubKey(bPub, s)
}
