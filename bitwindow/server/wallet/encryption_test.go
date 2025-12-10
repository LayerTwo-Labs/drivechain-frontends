package wallet

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"testing"
)

func TestEncryptionCompatibility(t *testing.T) {
	// Test with known values
	password := "test123"
	salt := []byte("12345678901234567890123456789012") // 32 bytes
	iterations := 100000

	// Derive key
	key := DeriveKey(password, salt, iterations)

	// Test encryption
	plaintext := `{"test":"data","master":{"seed_hex":"0123456789abcdef"}}`
	encrypted, err := encrypt(plaintext, key)
	if err != nil {
		t.Fatalf("Encryption failed: %v", err)
	}

	// Test decryption
	decrypted, err := Decrypt(encrypted, key)
	if err != nil {
		t.Fatalf("Decryption failed: %v", err)
	}

	if plaintext != decrypted {
		t.Fatalf("Decrypted text doesn't match: got %s, want %s", decrypted, plaintext)
	}
}

func TestDecryptDartEncrypted(t *testing.T) {
	// You can paste actual encrypted data from Dart here to test
	t.Skip("Manual test - add encrypted data from Dart")

	password := "YOUR_PASSWORD"
	saltBase64 := "YOUR_SALT_BASE64"
	encryptedData := "YOUR_IV:YOUR_ENCRYPTED_DATA"
	iterations := 100000

	salt, err := base64.StdEncoding.DecodeString(saltBase64)
	if err != nil {
		t.Fatalf("Invalid salt: %v", err)
	}

	key := DeriveKey(password, salt, iterations)

	decrypted, err := Decrypt(encryptedData, key)
	if err != nil {
		t.Fatalf("Decryption failed: %v", err)
	}

	t.Logf("Decrypted: %s", decrypted)
}

// encrypt encrypts data using AES-256-GCM with a 12-byte nonce
// Format matches Decrypt: "iv:encrypted" (both base64 encoded)
func encrypt(plaintext string, key []byte) (string, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	// Generate random nonce (12 bytes for standard GCM)
	nonce := make([]byte, gcm.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return "", err
	}

	// Encrypt the plaintext
	ciphertext := gcm.Seal(nil, nonce, []byte(plaintext), nil)

	// Return as "iv:encrypted" format with base64 encoding
	ivBase64 := base64.StdEncoding.EncodeToString(nonce)
	encryptedBase64 := base64.StdEncoding.EncodeToString(ciphertext)

	return ivBase64 + ":" + encryptedBase64, nil
}
