package wallet

import (
	"encoding/base64"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEncryptDecryptRoundTrip(t *testing.T) {
	key := DeriveKey("testpassword", []byte("0123456789abcdef0123456789abcdef"), 1000)

	plaintext := `{"version":1,"wallets":[]}`
	encrypted, err := Encrypt(plaintext, key)
	require.NoError(t, err)

	// Verify format: base64(iv):base64(ciphertext+tag)
	parts := strings.SplitN(encrypted, ":", 2)
	assert.Len(t, parts, 2, "encrypted format should be iv:ciphertext")

	// IV should be 16 bytes = base64 length of 24
	iv, err := base64.StdEncoding.DecodeString(parts[0])
	require.NoError(t, err)
	assert.Len(t, iv, 16, "IV should be 16 bytes")

	// Decrypt
	decrypted, err := Decrypt(encrypted, key)
	require.NoError(t, err)
	assert.Equal(t, plaintext, decrypted)
}

func TestEncryptDecryptLargePayload(t *testing.T) {
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)

	// Simulate a realistic wallet.json (~2KB)
	plaintext := strings.Repeat(`{"mnemonic":"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about","seed":"abc123"}`, 20)

	encrypted, err := Encrypt(plaintext, key)
	require.NoError(t, err)

	decrypted, err := Decrypt(encrypted, key)
	require.NoError(t, err)
	assert.Equal(t, plaintext, decrypted)
}

func TestEncryptDecryptEmptyString(t *testing.T) {
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)

	encrypted, err := Encrypt("", key)
	require.NoError(t, err)

	decrypted, err := Decrypt(encrypted, key)
	require.NoError(t, err)
	assert.Equal(t, "", decrypted)
}

func TestEncryptDecryptUnicodeContent(t *testing.T) {
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)

	plaintext := `{"name":"钱包","emoji":"🔐💰","notes":"日本語テスト"}`
	encrypted, err := Encrypt(plaintext, key)
	require.NoError(t, err)

	decrypted, err := Decrypt(encrypted, key)
	require.NoError(t, err)
	assert.Equal(t, plaintext, decrypted)
}

func TestEncryptProducesDifferentCiphertextEachTime(t *testing.T) {
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)
	plaintext := "same plaintext"

	enc1, err := Encrypt(plaintext, key)
	require.NoError(t, err)
	enc2, err := Encrypt(plaintext, key)
	require.NoError(t, err)

	assert.NotEqual(t, enc1, enc2, "same plaintext should encrypt to different ciphertext (random IV)")

	// But both should decrypt to the same thing
	dec1, err := Decrypt(enc1, key)
	require.NoError(t, err)
	dec2, err := Decrypt(enc2, key)
	require.NoError(t, err)
	assert.Equal(t, dec1, dec2)
	assert.Equal(t, plaintext, dec1)
}

func TestDecryptWithWrongKeyFails(t *testing.T) {
	key1 := DeriveKey("password1", []byte("0123456789abcdef0123456789abcdef"), 1000)
	key2 := DeriveKey("password2", []byte("0123456789abcdef0123456789abcdef"), 1000)

	encrypted, err := Encrypt("secret data", key1)
	require.NoError(t, err)

	_, err = Decrypt(encrypted, key2)
	assert.Error(t, err, "decrypting with wrong key should fail")
}

func TestDecryptInvalidFormat(t *testing.T) {
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)

	// No colon separator
	_, err := Decrypt("notvalid", key)
	assert.Error(t, err)

	// Invalid base64 for IV
	_, err = Decrypt("!!!invalid!!!:validbase64==", key)
	assert.Error(t, err)

	// Valid IV but invalid ciphertext base64
	validIV := base64.StdEncoding.EncodeToString(make([]byte, 16))
	_, err = Decrypt(validIV+":!!!notbase64!!!", key)
	assert.Error(t, err)

	// Valid format but garbage content
	garbageCT := base64.StdEncoding.EncodeToString([]byte("not real ciphertext"))
	_, err = Decrypt(validIV+":"+garbageCT, key)
	assert.Error(t, err, "should fail to decrypt garbage")
}

func TestDecryptTamperedCiphertext(t *testing.T) {
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)

	encrypted, err := Encrypt("important data", key)
	require.NoError(t, err)

	// Tamper with the ciphertext portion
	parts := strings.SplitN(encrypted, ":", 2)
	ctBytes, err := base64.StdEncoding.DecodeString(parts[1])
	require.NoError(t, err)

	// Flip a bit
	if len(ctBytes) > 0 {
		ctBytes[0] ^= 0xff
	}
	tampered := parts[0] + ":" + base64.StdEncoding.EncodeToString(ctBytes)

	_, err = Decrypt(tampered, key)
	assert.Error(t, err, "GCM should detect tampering")
}

func TestDeriveKeyDeterministic(t *testing.T) {
	salt := []byte("fixed_salt_for_test_1234_5678_90")
	key1 := DeriveKey("mypassword", salt, 1000)
	key2 := DeriveKey("mypassword", salt, 1000)
	assert.Equal(t, key1, key2, "same password+salt should produce same key")
}

func TestDeriveKeyDifferentPasswordsDifferentKeys(t *testing.T) {
	salt := []byte("fixed_salt_for_test_1234_5678_90")
	key1 := DeriveKey("password1", salt, 1000)
	key2 := DeriveKey("password2", salt, 1000)
	assert.NotEqual(t, key1, key2, "different passwords should produce different keys")
}

func TestDeriveKeyDifferentSaltsDifferentKeys(t *testing.T) {
	key1 := DeriveKey("same_password", []byte("salt_aaaaaaaaaaaaaaaaaaaaaaaaaaaa"), 1000)
	key2 := DeriveKey("same_password", []byte("salt_bbbbbbbbbbbbbbbbbbbbbbbbbbbb"), 1000)
	assert.NotEqual(t, key1, key2, "different salts should produce different keys")
}

func TestDeriveKeyDifferentIterationsDifferentKeys(t *testing.T) {
	salt := []byte("fixed_salt_for_test_1234_5678_90")
	key1 := DeriveKey("password", salt, 1000)
	key2 := DeriveKey("password", salt, 2000)
	assert.NotEqual(t, key1, key2, "different iterations should produce different keys")
}

func TestDeriveKeyLength(t *testing.T) {
	salt := []byte("fixed_salt_for_test_1234_5678_90")
	key := DeriveKey("test", salt, 1000)
	assert.Len(t, key, 32, "derived key should be 32 bytes (AES-256)")
}

func TestGenerateSalt(t *testing.T) {
	salt1, err := GenerateSalt()
	require.NoError(t, err)
	assert.Len(t, salt1, 32)

	salt2, err := GenerateSalt()
	require.NoError(t, err)
	assert.NotEqual(t, salt1, salt2, "salts should be unique")
}

func TestEncryptionMetadataMarshal(t *testing.T) {
	meta := EncryptionMetadata{
		Salt:       base64.StdEncoding.EncodeToString([]byte("test_salt_32_bytes______________")),
		Iterations: 100000,
		Encrypted:  true,
		Version:    "1.0",
	}

	data, err := meta.Marshal()
	require.NoError(t, err)

	parsed, err := UnmarshalEncryptionMetadata(data)
	require.NoError(t, err)

	assert.Equal(t, meta.Salt, parsed.Salt)
	assert.Equal(t, meta.Iterations, parsed.Iterations)
	assert.Equal(t, meta.Encrypted, parsed.Encrypted)
	assert.Equal(t, meta.Version, parsed.Version)
}

func TestUnmarshalEncryptionMetadataInvalidJSON(t *testing.T) {
	_, err := UnmarshalEncryptionMetadata([]byte("not json"))
	assert.Error(t, err)

	_, err = UnmarshalEncryptionMetadata([]byte(""))
	assert.Error(t, err)
}

func TestEncryptDecryptWithActualPBKDF2Parameters(t *testing.T) {
	// Test with production-like parameters (but fewer iterations for speed)
	salt, err := GenerateSalt()
	require.NoError(t, err)

	key := DeriveKey("real-world-password-123!", salt, 10000)

	walletJSON := `{"version":1,"activeWalletId":"ABC123","wallets":[{"version":1,"master":{"mnemonic":"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"}}]}`

	encrypted, err := Encrypt(walletJSON, key)
	require.NoError(t, err)

	// Verify it's not plaintext
	assert.NotContains(t, encrypted, "abandon")
	assert.NotContains(t, encrypted, "mnemonic")

	// But can be decrypted
	decrypted, err := Decrypt(encrypted, key)
	require.NoError(t, err)
	assert.Equal(t, walletJSON, decrypted)
}

func TestGCMNonceSizeIs16Bytes(t *testing.T) {
	// This is critical for Dart compatibility - Dart's encrypt package uses 16-byte IV
	key := DeriveKey("test", []byte("0123456789abcdef0123456789abcdef"), 1000)

	encrypted, err := Encrypt("test", key)
	require.NoError(t, err)

	parts := strings.SplitN(encrypted, ":", 2)
	require.Len(t, parts, 2)

	iv, err := base64.StdEncoding.DecodeString(parts[0])
	require.NoError(t, err)
	assert.Len(t, iv, 16, "IV must be 16 bytes for Dart compatibility (not standard 12)")
}
