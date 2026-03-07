package wallet

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"

	"github.com/tyler-smith/go-bip32"
	"github.com/tyler-smith/go-bip39"
)

// GenerateMnemonic generates a new 12-word BIP39 mnemonic.
func GenerateMnemonic() (string, error) {
	entropy, err := bip39.NewEntropy(128) // 128 bits = 12 words
	if err != nil {
		return "", fmt.Errorf("generate entropy: %w", err)
	}
	mnemonic, err := bip39.NewMnemonic(entropy)
	if err != nil {
		return "", fmt.Errorf("create mnemonic: %w", err)
	}
	return mnemonic, nil
}

// MnemonicToSeed converts a mnemonic to a seed using PBKDF2-HMAC-SHA512.
func MnemonicToSeed(mnemonic, passphrase string) []byte {
	return bip39.NewSeed(mnemonic, passphrase)
}

// DeriveStarter derives a child mnemonic from a seed at the given derivation path.
// This matches Dart's _deriveStarter: derive BIP32 key -> SHA256(private key) -> first 16 bytes as entropy -> BIP39 mnemonic.
func DeriveStarter(seedHex, derivationPath string) (string, error) {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return "", fmt.Errorf("decode seed hex: %w", err)
	}

	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return "", fmt.Errorf("create master key: %w", err)
	}

	// Parse derivation path like "m/44'/0'/256'"
	childKey, err := deriveKeyAtPath(masterKey, derivationPath)
	if err != nil {
		return "", fmt.Errorf("derive key at %s: %w", derivationPath, err)
	}

	// SHA256 hash of private key bytes
	// Dart's privateKeyHex() returns the serialized key which is [0x00, ...32-byte-key]
	// (33 bytes total). We must match this format for compatible derivation.
	serializedKey := make([]byte, 33)
	serializedKey[0] = 0x00
	copy(serializedKey[1:], childKey.Key)
	hash := sha256.Sum256(serializedKey)

	// First 16 bytes as entropy (128 bits = 12 words)
	entropy := hash[:16]

	// Create mnemonic from entropy
	mnemonic, err := bip39.NewMnemonic(entropy)
	if err != nil {
		return "", fmt.Errorf("create mnemonic from entropy: %w", err)
	}

	return mnemonic, nil
}

// deriveKeyAtPath derives a BIP32 key at the given path.
// Supports hardened derivation with ' suffix.
func deriveKeyAtPath(masterKey *bip32.Key, path string) (*bip32.Key, error) {
	// Remove "m/" prefix
	path = strings.TrimPrefix(path, "m/")
	if path == "" || path == "m" {
		return masterKey, nil
	}

	components := strings.Split(path, "/")
	key := masterKey

	for _, component := range components {
		hardened := strings.HasSuffix(component, "'")
		component = strings.TrimSuffix(component, "'")

		var index uint32
		_, err := fmt.Sscanf(component, "%d", &index)
		if err != nil {
			return nil, fmt.Errorf("parse path component %q: %w", component, err)
		}

		if hardened {
			index += bip32.FirstHardenedChild
		}

		key, err = key.NewChildKey(index)
		if err != nil {
			return nil, fmt.Errorf("derive child %d: %w", index, err)
		}
	}

	return key, nil
}

// serializedPrivateKeyHex returns hex of [0x00, ...32-byte-key] matching
// Dart's ExtendedPrivateKey._serializedKey() / privateKeyHex() format.
func serializedPrivateKeyHex(key []byte) string {
	buf := make([]byte, 33)
	buf[0] = 0x00
	copy(buf[1:], key)
	return hex.EncodeToString(buf)
}

// bytesToBinary converts bytes to a binary string representation.
func bytesToBinary(data []byte) string {
	var sb strings.Builder
	for _, b := range data {
		sb.WriteString(fmt.Sprintf("%08b", b))
	}
	return sb.String()
}

// calculateChecksumBits calculates BIP39 checksum bits from entropy.
func calculateChecksumBits(entropy []byte) string {
	entropyBits := len(entropy) * 8
	checksumSize := entropyBits / 32

	hash := sha256.Sum256(entropy)
	hashBits := bytesToBinary(hash[:])
	return hashBits[:checksumSize]
}

// GenerateFullWallet generates a complete wallet with master, L1, and sidechain starters.
func GenerateFullWallet(name string, customMnemonic string, passphrase string, slots []SidechainSlot, walletType string) (*WalletData, error) {
	var mnemonic string
	var err error

	if customMnemonic != "" {
		// Validate the provided mnemonic
		if !bip39.IsMnemonicValid(customMnemonic) {
			return nil, fmt.Errorf("invalid mnemonic")
		}
		mnemonic = customMnemonic
	} else {
		mnemonic, err = GenerateMnemonic()
		if err != nil {
			return nil, fmt.Errorf("generate mnemonic: %w", err)
		}
	}

	// Generate seed
	seed := MnemonicToSeed(mnemonic, passphrase)
	seedHex := hex.EncodeToString(seed)

	// Create master key
	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return nil, fmt.Errorf("create master key: %w", err)
	}

	// Get entropy from mnemonic for bip39 metadata
	entropy, err := bip39.EntropyFromMnemonic(mnemonic)
	if err != nil {
		return nil, fmt.Errorf("get entropy from mnemonic: %w", err)
	}

	bip39Binary := bytesToBinary(entropy)
	bip39Checksum := calculateChecksumBits(entropy)
	checksumByte := byte(0)
	for _, c := range bip39Checksum {
		checksumByte = checksumByte<<1 | byte(c-'0')
	}
	bip39ChecksumHex := hex.EncodeToString([]byte{checksumByte})

	master := MasterWallet{
		Mnemonic:         mnemonic,
		SeedHex:          seedHex,
		MasterKey:        serializedPrivateKeyHex(masterKey.Key),
		ChainCode:        hex.EncodeToString(masterKey.ChainCode),
		BIP39Binary:      bip39Binary,
		BIP39Checksum:    bip39Checksum,
		BIP39ChecksumHex: bip39ChecksumHex,
		Name:             "Master",
	}

	// Derive L1 starter: m/44'/0'/256'
	l1Mnemonic, err := DeriveStarter(seedHex, "m/44'/0'/256'")
	if err != nil {
		return nil, fmt.Errorf("derive L1 starter: %w", err)
	}
	l1 := L1Wallet{
		Mnemonic: l1Mnemonic,
		Name:     "Bitcoin Core (Patched)",
	}

	// Derive sidechain starters
	var sidechains []SidechainWallet
	for _, slot := range slots {
		scMnemonic, err := DeriveStarter(seedHex, fmt.Sprintf("m/44'/0'/%d'", slot.Slot))
		if err != nil {
			// Log but continue - match Dart behavior
			continue
		}
		sidechains = append(sidechains, SidechainWallet{
			Slot:     slot.Slot,
			Name:     slot.Name,
			Mnemonic: scMnemonic,
		})
	}

	return &WalletData{
		Version:    1,
		Master:     master,
		L1:         l1,
		Sidechains: sidechains,
		Name:       name,
		WalletType: walletType,
	}, nil
}
