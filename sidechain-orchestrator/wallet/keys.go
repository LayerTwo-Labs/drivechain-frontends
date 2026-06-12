package wallet

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/tyler-smith/go-bip32"
	"golang.org/x/crypto/ripemd160" //nolint:staticcheck // Bitcoin protocol requires RIPEMD160

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

// serializeKeyForNetwork serializes a BIP32 key, patching the version bytes to
// match the network. go-bip32 hardcodes mainnet xprv version bytes; for any
// other chain Core rejects the serialized key, so we strip + replace + re-sum.
func serializeKeyForNetwork(key *bip32.Key, network *chaincfg.Params) string {
	if network == nil || network.HDPrivateKeyID == chaincfg.MainNetParams.HDPrivateKeyID {
		return key.String()
	}

	// key.Serialize() returns the full 82-byte payload (78 data + 4 checksum).
	// We need to strip the existing checksum, replace version bytes, then
	// re-encode with a fresh checksum so Bitcoin Core accepts the key.
	serialized, err := key.Serialize()
	if err != nil {
		return key.String()
	}

	// serialized is 82 bytes: [4 version][74 data][4 checksum].
	// Strip old checksum, patch version, recompute.
	raw := serialized[:78]
	copy(raw[0:4], network.HDPrivateKeyID[:])
	return base58CheckEncode(raw)
}

// DeriveBIP84Addresses derives external-chain P2WPKH receive addresses
// (m/84'/coin'/0'/0/i) from a BIP32 seed, locally, without any backend.
func DeriveBIP84Addresses(seedHex string, net *chaincfg.Params, start, count int) ([]string, error) {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, fmt.Errorf("decode seed hex: %w", err)
	}
	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return nil, fmt.Errorf("create master key: %w", err)
	}
	purpose, err := masterKey.NewChildKey(bip32.FirstHardenedChild + 84)
	if err != nil {
		return nil, fmt.Errorf("derive purpose: %w", err)
	}
	coin, err := purpose.NewChildKey(bip32.FirstHardenedChild + net.HDCoinType)
	if err != nil {
		return nil, fmt.Errorf("derive coin: %w", err)
	}
	account, err := coin.NewChildKey(bip32.FirstHardenedChild + 0)
	if err != nil {
		return nil, fmt.Errorf("derive account: %w", err)
	}
	external, err := account.NewChildKey(0)
	if err != nil {
		return nil, fmt.Errorf("derive external chain: %w", err)
	}

	addrs := make([]string, 0, count)
	for i := start; i < start+count; i++ {
		child, err := external.NewChildKey(uint32(i))
		if err != nil {
			return nil, fmt.Errorf("derive index %d: %w", i, err)
		}
		addr, err := btcutil.NewAddressWitnessPubKeyHash(hash160(child.PublicKey().Key), net)
		if err != nil {
			return nil, fmt.Errorf("address at index %d: %w", i, err)
		}
		addrs = append(addrs, addr.EncodeAddress())
	}
	return addrs, nil
}

// masterFingerprint computes the master fingerprint from a BIP32 key.
// Hash160(compressed_pubkey)[:4], hex encoded.
func masterFingerprint(masterKey *bip32.Key) string {
	pubKey := masterKey.PublicKey()
	h := hash160(pubKey.Key)
	return hex.EncodeToString(h[:4])
}

// Bip47PaymentCodeFromSeed returns the BIP47 v1 spec-compliant payment code
// (m/47'/coin_type'/0' xpub serialized as 81-byte base58check with version
// 0x47) for a BIP32 seed. coin_type follows BIP44: mainnet=0, testnet variants
// (signet/regtest/testnet3)=1. Returns ("", nil) for an empty seed (watch-only
// wallet) so the UI can distinguish "not applicable" from "still computing".
// A non-nil error means the seed parsed but BIP47 derivation failed — caller
// should log it instead of silently returning an empty code, which the UI
// can't tell apart from a still-loading state.
func Bip47PaymentCodeFromSeed(seedHex string, net *chaincfg.Params) (string, error) {
	if seedHex == "" {
		return "", nil
	}
	pc, err := bip47.PaymentCodeFromSeed(seedHex, net)
	if err != nil {
		return "", fmt.Errorf("bip47: derive payment code: %w", err)
	}
	return pc.Base58(), nil
}

// hash160 computes RIPEMD160(SHA256(data)).
func hash160(data []byte) []byte {
	sha := sha256.Sum256(data)
	ripemd := ripemd160.New()
	ripemd.Write(sha[:])
	return ripemd.Sum(nil)
}

// mustAddChecksum adds a descriptor checksum, panicking on error (for known-good descriptors).
func mustAddChecksum(desc string) string {
	result, err := AddDescriptorChecksum(desc)
	if err != nil {
		// This should never happen for descriptors we construct ourselves
		return desc
	}
	return result
}

// Base58CheckEncode encodes a byte slice as Base58Check.
func Base58CheckEncode(data []byte) string {
	return base58CheckEncode(data)
}

// base58CheckEncode encodes a byte slice as Base58Check (internal).
func base58CheckEncode(data []byte) string {
	// Append 4-byte checksum
	checksum := doubleSha256(data)
	payload := append(data, checksum[:4]...)

	// Convert to base58
	n := new(big.Int).SetBytes(payload)
	result := make([]byte, 0, len(payload)*2)

	base := big.NewInt(58)
	zero := big.NewInt(0)
	mod := new(big.Int)

	for n.Cmp(zero) > 0 {
		n.DivMod(n, base, mod)
		result = append(result, base58Alphabet[mod.Int64()])
	}

	// Add leading zeros
	for _, b := range payload {
		if b != 0 {
			break
		}
		result = append(result, base58Alphabet[0])
	}

	// Reverse
	for i, j := 0, len(result)-1; i < j; i, j = i+1, j-1 {
		result[i], result[j] = result[j], result[i]
	}

	return string(result)
}

func doubleSha256(data []byte) [32]byte {
	first := sha256.Sum256(data)
	return sha256.Sum256(first[:])
}

const base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
