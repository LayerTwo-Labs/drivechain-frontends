package wallet

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"

	"golang.org/x/crypto/pbkdf2"
)

const (
	keyLength         = 32
	saltLength        = 32
	ivLength          = 16
	DefaultIterations = 100000
)

// DeriveKey derives an encryption key from a password using PBKDF2-HMAC-SHA256.
func DeriveKey(password string, salt []byte, iterations int) []byte {
	return pbkdf2.Key([]byte(password), salt, iterations, keyLength, sha256.New)
}

// Encrypt encrypts plaintext using AES-256-GCM.
// Output format: base64(iv):base64(ciphertext||tag)
// This is compatible with Dart's encrypt package AES-GCM format.
func Encrypt(plaintext string, key []byte) (string, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", fmt.Errorf("create cipher: %w", err)
	}

	gcm, err := cipher.NewGCMWithNonceSize(block, ivLength)
	if err != nil {
		return "", fmt.Errorf("create gcm: %w", err)
	}

	iv := make([]byte, ivLength)
	if _, err := rand.Read(iv); err != nil {
		return "", fmt.Errorf("generate iv: %w", err)
	}

	// Seal appends ciphertext+tag to dst
	ciphertextWithTag := gcm.Seal(nil, iv, []byte(plaintext), nil)

	ivB64 := base64.StdEncoding.EncodeToString(iv)
	ctB64 := base64.StdEncoding.EncodeToString(ciphertextWithTag)

	return ivB64 + ":" + ctB64, nil
}

// Decrypt decrypts ciphertext using AES-256-GCM.
// Input format: base64(iv):base64(ciphertext||tag)
func Decrypt(ciphertext string, key []byte) (string, error) {
	parts := strings.SplitN(ciphertext, ":", 2)
	if len(parts) != 2 {
		return "", fmt.Errorf("invalid ciphertext format: expected iv:ciphertext")
	}

	iv, err := base64.StdEncoding.DecodeString(parts[0])
	if err != nil {
		return "", fmt.Errorf("decode iv: %w", err)
	}

	ciphertextWithTag, err := base64.StdEncoding.DecodeString(parts[1])
	if err != nil {
		return "", fmt.Errorf("decode ciphertext: %w", err)
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", fmt.Errorf("create cipher: %w", err)
	}

	gcm, err := cipher.NewGCMWithNonceSize(block, ivLength)
	if err != nil {
		return "", fmt.Errorf("create gcm: %w", err)
	}

	plaintext, err := gcm.Open(nil, iv, ciphertextWithTag, nil)
	if err != nil {
		return "", fmt.Errorf("decrypt: %w", err)
	}

	return string(plaintext), nil
}

// GenerateSalt generates a random 32-byte salt.
func GenerateSalt() ([]byte, error) {
	salt := make([]byte, saltLength)
	if _, err := rand.Read(salt); err != nil {
		return nil, fmt.Errorf("generate salt: %w", err)
	}
	return salt, nil
}

// EncryptionMetadata stores encryption parameters alongside the wallet file.
type EncryptionMetadata struct {
	Salt       string `json:"salt"`       // base64-encoded salt
	Iterations int    `json:"iterations"`
	Encrypted  bool   `json:"encrypted"`
	Version    string `json:"version"`
}

func (m EncryptionMetadata) Marshal() ([]byte, error) {
	return json.Marshal(m)
}

func UnmarshalEncryptionMetadata(data []byte) (EncryptionMetadata, error) {
	var m EncryptionMetadata
	if err := json.Unmarshal(data, &m); err != nil {
		return EncryptionMetadata{}, err
	}
	return m, nil
}
