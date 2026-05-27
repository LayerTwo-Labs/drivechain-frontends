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

// DeriveOwnNotificationKey returns the wallet's own notification private key
// (m/47'/0'/0'/0) and the matching P2PKH address. The wallet imports this key
// into Core to watch for incoming BIP47 notification transactions, and uses
// the private key to decrypt the blinded payload to recover the sender's
// payment code.
func DeriveOwnNotificationKey(seedHex string, net *chaincfg.Params) (*btcec.PrivateKey, btcutil.Address, error) {
	account, err := SeedAccountKey(seedHex, net)
	if err != nil {
		return nil, nil, fmt.Errorf("account key: %w", err)
	}
	a0Ext, err := account.Derive(0)
	if err != nil {
		return nil, nil, fmt.Errorf("derive notification key: %w", err)
	}
	a0, err := a0Ext.ECPrivKey()
	if err != nil {
		return nil, nil, fmt.Errorf("notification ECPrivKey: %w", err)
	}
	addr, err := p2pkhAddress(a0.PubKey(), net)
	if err != nil {
		return nil, nil, fmt.Errorf("notification address: %w", err)
	}
	return a0, addr, nil
}

// DeriveReceivedPaymentAddress is the receiver-side mirror of
// DerivePaymentAddressTyped. Given the receiver's seed, the sender's
// notification pubkey A₀ (recovered from the sender's payment code), and the
// per-payment index i, it returns the same address that the sender derives at
// the same index, plus the spending private key for that address.
//
// Math: with bᵢ = receiver m/47'/0'/0'/i privkey, the receiver computes
// sᵢ = SHA256((bᵢ · A₀).x). The sender computed sᵢ = SHA256((a₀ · Bᵢ).x) which
// is the same value by ECDH symmetry. The receiver's spending privkey is then
// bᵢ + sᵢ (mod n), whose pubkey is Bᵢ + sᵢ·G — the same point the sender
// derived as the destination.
func DeriveReceivedPaymentAddress(
	receiverSeedHex string,
	senderNotificationPub *btcec.PublicKey,
	index uint32,
	net *chaincfg.Params,
	addrType AddressType,
) (btcutil.Address, *btcec.PrivateKey, error) {
	if senderNotificationPub == nil {
		return nil, nil, errors.New("nil sender notification pubkey")
	}
	if index >= hdkeychain.HardenedKeyStart {
		return nil, nil, fmt.Errorf("payment index %d must be non-hardened", index)
	}

	account, err := SeedAccountKey(receiverSeedHex, net)
	if err != nil {
		return nil, nil, fmt.Errorf("receiver account key: %w", err)
	}
	bExt, err := account.Derive(index)
	if err != nil {
		return nil, nil, fmt.Errorf("derive bᵢ: %w", err)
	}
	b, err := bExt.ECPrivKey()
	if err != nil {
		return nil, nil, fmt.Errorf("bᵢ ECPrivKey: %w", err)
	}

	x, err := ecdhX(b, senderNotificationPub)
	if err != nil {
		return nil, nil, fmt.Errorf("ecdh: %w", err)
	}
	s := sha256.Sum256(x[:])

	tweakedPriv, err := tweakPrivKey(b, s)
	if err != nil {
		return nil, nil, err
	}

	switch addrType {
	case AddressP2PKH:
		addr, err := p2pkhAddress(tweakedPriv.PubKey(), net)
		if err != nil {
			return nil, nil, err
		}
		return addr, tweakedPriv, nil
	case AddressP2WPKH:
		addr, err := p2wpkhAddress(tweakedPriv.PubKey(), net)
		if err != nil {
			return nil, nil, err
		}
		return addr, tweakedPriv, nil
	default:
		return nil, nil, fmt.Errorf("unknown address type %d", addrType)
	}
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

	senderPC, err := PaymentCodeFromSeed(senderSeedHex, net)
	if err != nil {
		return nil, fmt.Errorf("sender payment code: %w", err)
	}
	if senderPC.Equal(recipient) {
		return nil, errors.New("self-send: sender and recipient payment codes match")
	}

	// a₀ = sender's m/47'/coin'/0'/0 private key
	account, err := SeedAccountKey(senderSeedHex, net)
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
		return nil, fmt.Errorf("recipient indexed pubkey: %w", err)
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
