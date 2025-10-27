package wallet

import (
	"encoding/base64"
	"fmt"
	"testing"
)

func TestEncryptionCompatibility(t *testing.T) {
	// Test with known values
	password := "test123"
	salt := []byte("12345678901234567890123456789012") // 32 bytes
	iterations := 100000

	// Derive key
	key := DeriveKey(password, salt, iterations)

	fmt.Printf("Password: %s\n", password)
	fmt.Printf("Salt (hex): %x\n", salt)
	fmt.Printf("Salt (base64): %s\n", base64.StdEncoding.EncodeToString(salt))
	fmt.Printf("Iterations: %d\n", iterations)
	fmt.Printf("Derived key (hex): %x\n", key)
	fmt.Printf("Key length: %d bytes\n", len(key))

	// Test encryption
	plaintext := `{"test":"data","master":{"seed_hex":"0123456789abcdef"}}`
	encrypted := Encrypt(plaintext, key)
	fmt.Printf("\nPlaintext: %s\n", plaintext)
	fmt.Printf("Encrypted: %s\n", encrypted)

	// Test decryption
	decrypted, err := Decrypt(encrypted, key)
	if err != nil {
		t.Fatalf("Decryption failed: %v", err)
	}

	fmt.Printf("Decrypted: %s\n", decrypted)

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
	fmt.Printf("Key derived (hex): %x\n", key)

	decrypted, err := Decrypt(encryptedData, key)
	if err != nil {
		t.Fatalf("Decryption failed: %v", err)
	}

	fmt.Printf("Decrypted: %s\n", decrypted)
}

// Helper function for encryption (not in original file)
func Encrypt(plaintext string, key []byte) string {
	// This would need the actual encryption implementation
	// For now, just a placeholder
	return "iv:encrypted"
}
