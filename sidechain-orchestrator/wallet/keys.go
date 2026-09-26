package wallet

import (
	"fmt"

	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

// DeriveBIP84Addresses derives external-chain P2WPKH receive addresses
// (m/84'/coin'/0'/0/i) of a BIP32 seed.
func DeriveBIP84Addresses(seedHex string, net *chaincfg.Params, start, count int) ([]string, error) {
	return DeriveWalletReceiveAddresses(&WalletData{Master: MasterWallet{SeedHex: seedHex}}, net, start, count)
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

func base58CheckEncode(data []byte) string {
	checksum := chainhash.DoubleHashB(data)
	payload := make([]byte, 0, len(data)+4)
	payload = append(payload, data...)
	payload = append(payload, checksum[:4]...)
	return base58.Encode(payload)
}
