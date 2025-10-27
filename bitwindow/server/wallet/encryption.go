package wallet

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"golang.org/x/crypto/pbkdf2"
)

const (
	keyLength         = 32
	defaultIterations = 100000
)

// EncryptionMetadata stores encryption parameters
type EncryptionMetadata struct {
	Salt       string `json:"salt"`
	Iterations int    `json:"iterations"`
	Encrypted  bool   `json:"encrypted"`
	Version    string `json:"version"`
}

// DeriveKey derives an encryption key from a password using PBKDF2-HMAC-SHA256
// This matches the Dart implementation exactly
func DeriveKey(password string, salt []byte, iterations int) []byte {
	return pbkdf2.Key([]byte(password), salt, iterations, keyLength, sha256.New)
}

// Decrypt decrypts data using AES-256-GCM
// Format matches Dart: "iv:encrypted" (both base64 encoded)
// Supports both 12-byte (standard GCM) and 16-byte IVs (Dart default)
func Decrypt(ciphertext string, key []byte) (string, error) {
	parts := strings.Split(ciphertext, ":")
	if len(parts) != 2 {
		return "", errors.New("invalid ciphertext format")
	}

	ivBytes, err := base64.StdEncoding.DecodeString(parts[0])
	if err != nil {
		return "", fmt.Errorf("invalid IV base64: %w", err)
	}

	encryptedBytes, err := base64.StdEncoding.DecodeString(parts[1])
	if err != nil {
		return "", fmt.Errorf("invalid encrypted data base64: %w", err)
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", fmt.Errorf("failed to create cipher: %w", err)
	}

	// Support both 12-byte (standard) and 16-byte (Dart default) IVs
	var gcm cipher.AEAD
	if len(ivBytes) == 16 {
		// Use custom nonce size for 16-byte IV (Dart compatibility)
		gcm, err = cipher.NewGCMWithNonceSize(block, 16)
	} else {
		// Use standard 12-byte nonce
		gcm, err = cipher.NewGCM(block)
	}
	if err != nil {
		return "", fmt.Errorf("failed to create GCM: %w", err)
	}

	if len(ivBytes) != gcm.NonceSize() {
		return "", fmt.Errorf("invalid IV size: got %d, want %d", len(ivBytes), gcm.NonceSize())
	}

	plaintext, err := gcm.Open(nil, ivBytes, encryptedBytes, nil)
	if err != nil {
		return "", fmt.Errorf("decryption failed: %w", err)
	}

	return string(plaintext), nil
}

// LoadMetadata reads wallet_encryption.json
func LoadMetadata(appDir string) (*EncryptionMetadata, error) {
	metadataPath := filepath.Join(appDir, "wallet_encryption.json")
	data, err := os.ReadFile(metadataPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read metadata file: %w", err)
	}

	var metadata EncryptionMetadata
	if err := json.Unmarshal(data, &metadata); err != nil {
		return nil, fmt.Errorf("failed to parse metadata: %w", err)
	}

	return &metadata, nil
}

// IsWalletEncrypted checks if the wallet is encrypted
func IsWalletEncrypted(appDir string) bool {
	metadata, err := LoadMetadata(appDir)
	return err == nil && metadata.Encrypted
}

// DecryptWallet decrypts wallet.json using the provided password
// Returns the decrypted wallet data as a map
func DecryptWallet(appDir, password string) (map[string]interface{}, error) {
	metadata, err := LoadMetadata(appDir)
	if err != nil {
		return nil, fmt.Errorf("failed to load metadata: %w", err)
	}

	if !metadata.Encrypted {
		return nil, errors.New("wallet is not encrypted")
	}

	walletPath := filepath.Join(appDir, "wallet.json")
	encryptedData, err := os.ReadFile(walletPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read wallet file: %w", err)
	}

	salt, err := base64.StdEncoding.DecodeString(metadata.Salt)
	if err != nil {
		return nil, fmt.Errorf("invalid salt in metadata: %w", err)
	}

	key := DeriveKey(password, salt, metadata.Iterations)

	decrypted, err := Decrypt(string(encryptedData), key)
	if err != nil {
		return nil, errors.New("incorrect password or corrupted wallet")
	}

	var walletData map[string]interface{}
	if err := json.Unmarshal([]byte(decrypted), &walletData); err != nil {
		return nil, fmt.Errorf("failed to parse decrypted wallet: %w", err)
	}

	return walletData, nil
}

// LoadUnencryptedWallet loads wallet.json when it's not encrypted
func LoadUnencryptedWallet(appDir string) (map[string]interface{}, error) {
	walletPath := filepath.Join(appDir, "wallet.json")
	data, err := os.ReadFile(walletPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read wallet file: %w", err)
	}

	var walletData map[string]interface{}
	if err := json.Unmarshal(data, &walletData); err != nil {
		return nil, fmt.Errorf("failed to parse wallet: %w", err)
	}

	return walletData, nil
}
