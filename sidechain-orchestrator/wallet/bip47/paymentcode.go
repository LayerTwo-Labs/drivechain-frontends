package bip47

import (
	"bytes"
	"crypto/sha256"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/tyler-smith/go-bip39"
)

const (
	PaymentCodeLength = 80
	Base58Version     = 0x47
)

type PaymentCode struct {
	Version   byte
	Features  byte
	SignByte  byte
	X         [32]byte
	ChainCode [32]byte
	Reserved  [13]byte
}

func ParsePaymentCode(s string) (*PaymentCode, error) {
	decoded, version, err := base58.CheckDecode(s)
	if err != nil {
		return nil, fmt.Errorf("base58check decode: %w", err)
	}
	if version != Base58Version {
		return nil, fmt.Errorf("payment code version byte 0x%02x, want 0x%02x", version, Base58Version)
	}
	return parseFromCheckDecoded(decoded)
}

func parseFromCheckDecoded(b []byte) (*PaymentCode, error) {
	if len(b) != PaymentCodeLength {
		return nil, fmt.Errorf("payment code payload length %d, want %d", len(b), PaymentCodeLength)
	}
	pc := &PaymentCode{
		Version:  b[0],
		Features: b[1],
		SignByte: b[2],
	}
	copy(pc.X[:], b[3:35])
	copy(pc.ChainCode[:], b[35:67])
	copy(pc.Reserved[:], b[67:80])
	if pc.Version != 0x01 {
		return nil, fmt.Errorf("unsupported payment code version 0x%02x", pc.Version)
	}
	if pc.SignByte != 0x02 && pc.SignByte != 0x03 {
		return nil, fmt.Errorf("invalid sign byte 0x%02x", pc.SignByte)
	}
	if _, err := pc.PubKey(); err != nil {
		return nil, fmt.Errorf("invalid pubkey: %w", err)
	}
	return pc, nil
}

func (pc *PaymentCode) Serialize() [PaymentCodeLength]byte {
	var out [PaymentCodeLength]byte
	out[0] = pc.Version
	out[1] = pc.Features
	out[2] = pc.SignByte
	copy(out[3:35], pc.X[:])
	copy(out[35:67], pc.ChainCode[:])
	copy(out[67:80], pc.Reserved[:])
	return out
}

func (pc *PaymentCode) Base58() string {
	payload := pc.Serialize()
	buf := make([]byte, 1+PaymentCodeLength+4)
	buf[0] = Base58Version
	copy(buf[1:1+PaymentCodeLength], payload[:])
	sum := doubleSHA256(buf[:1+PaymentCodeLength])
	copy(buf[1+PaymentCodeLength:], sum[:4])
	return base58.Encode(buf)
}

func (pc *PaymentCode) CompressedPubKey() [33]byte {
	var out [33]byte
	out[0] = pc.SignByte
	copy(out[1:], pc.X[:])
	return out
}

func (pc *PaymentCode) PubKey() (*btcec.PublicKey, error) {
	cp := pc.CompressedPubKey()
	return btcec.ParsePubKey(cp[:])
}

// AsExtendedPubKey wraps the payment-code pubkey + chaincode for non-hardened
// child derivation. Version bytes are placeholder — they only affect xpub
// serialization, not derivation output.
func (pc *PaymentCode) AsExtendedPubKey(net *chaincfg.Params) *hdkeychain.ExtendedKey {
	cp := pc.CompressedPubKey()
	parentFP := []byte{0, 0, 0, 0}
	return hdkeychain.NewExtendedKey(
		net.HDPublicKeyID[:],
		cp[:],
		pc.ChainCode[:],
		parentFP,
		3,
		0,
		false,
	)
}

// NotificationPubKey returns B₀ = child 0 of the payment-code xpub. This is
// both the source of the notification address (P2PKH) and the ECDH partner
// when blinding the sender's payment code.
func (pc *PaymentCode) NotificationPubKey() (*btcec.PublicKey, error) {
	xpub := pc.AsExtendedPubKey(&chaincfg.MainNetParams)
	child, err := xpub.Derive(0)
	if err != nil {
		return nil, err
	}
	return child.ECPubKey()
}

func (pc *PaymentCode) Equal(other *PaymentCode) bool {
	a := pc.Serialize()
	b := other.Serialize()
	return bytes.Equal(a[:], b[:])
}

func PaymentCodeFromSeed(seedHex string) (*PaymentCode, error) {
	seed, err := hexDecode(seedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed: %w", err)
	}
	master, err := hdkeychain.NewMaster(seed, &chaincfg.MainNetParams)
	if err != nil {
		return nil, fmt.Errorf("master key: %w", err)
	}
	const hardened = hdkeychain.HardenedKeyStart
	purpose, err := master.Derive(hardened + 47)
	if err != nil {
		return nil, fmt.Errorf("derive 47': %w", err)
	}
	coin, err := purpose.Derive(hardened + 0)
	if err != nil {
		return nil, fmt.Errorf("derive 0': %w", err)
	}
	account, err := coin.Derive(hardened + 0)
	if err != nil {
		return nil, fmt.Errorf("derive 0' (account): %w", err)
	}
	priv, err := account.ECPrivKey()
	if err != nil {
		return nil, fmt.Errorf("account ECPrivKey: %w", err)
	}
	pub := priv.PubKey()
	compressed := pub.SerializeCompressed()
	cc := account.ChainCode()
	if len(cc) != 32 {
		return nil, errors.New("unexpected chaincode length")
	}
	pc := &PaymentCode{
		Version:  0x01,
		Features: 0x00,
		SignByte: compressed[0],
	}
	copy(pc.X[:], compressed[1:])
	copy(pc.ChainCode[:], cc)
	return pc, nil
}

func PaymentCodeFromMnemonic(mnemonic string) (*PaymentCode, error) {
	seed := bip39.NewSeed(mnemonic, "")
	return PaymentCodeFromSeed(hexEncode(seed))
}

// SeedAccountKey returns the m/47'/0'/0' extended private key. a₀ used for
// sender-side per-payment derivation is child 0 of this.
func SeedAccountKey(seedHex string) (*hdkeychain.ExtendedKey, error) {
	seed, err := hexDecode(seedHex)
	if err != nil {
		return nil, err
	}
	master, err := hdkeychain.NewMaster(seed, &chaincfg.MainNetParams)
	if err != nil {
		return nil, err
	}
	const h = hdkeychain.HardenedKeyStart
	a, err := master.Derive(h + 47)
	if err != nil {
		return nil, err
	}
	a, err = a.Derive(h + 0)
	if err != nil {
		return nil, err
	}
	a, err = a.Derive(h + 0)
	if err != nil {
		return nil, err
	}
	return a, nil
}

func doubleSHA256(b []byte) [32]byte {
	first := sha256.Sum256(b)
	return sha256.Sum256(first[:])
}
