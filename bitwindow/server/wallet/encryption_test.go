package wallet_test

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
)

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

func TestDecryptWallet(t *testing.T) {
	const password = "correct horse"
	salt := []byte("0123456789abcdef0123456789abcdef")

	writeWallet := func(t *testing.T, saltBase64, walletText string) string {
		dir := t.TempDir()
		metadata, err := json.Marshal(wallet.EncryptionMetadata{Salt: saltBase64, Iterations: 1000, Encrypted: true})
		require.NoError(t, err)
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet_encryption.json"), metadata, 0o600))
		require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), []byte(walletText), 0o600))
		return dir
	}
	encrypted, err := encrypt(`{"activeWalletId":"a"}`, wallet.DeriveKey(password, salt, 1000))
	require.NoError(t, err)
	saltBase64 := base64.StdEncoding.EncodeToString(salt)

	t.Run("the right password opens the wallet", func(t *testing.T) {
		data, err := wallet.DecryptWallet(writeWallet(t, saltBase64, encrypted), password)
		require.NoError(t, err)
		require.Equal(t, "a", data["activeWalletId"])
	})

	t.Run("a wallet with a 16-byte IV opens", func(t *testing.T) {
		data, err := wallet.DecryptWallet(filepath.Join("testdata", "iv16"), password)
		require.NoError(t, err)
		require.Equal(t, "iv16", data["activeWalletId"])
	})

	t.Run("a wrong password is an incorrect password", func(t *testing.T) {
		_, err := wallet.DecryptWallet(writeWallet(t, saltBase64, encrypted), "wrong")
		require.ErrorIs(t, err, wallet.ErrIncorrectPassword)
	})

	t.Run("a bad salt is no password error", func(t *testing.T) {
		_, err := wallet.DecryptWallet(writeWallet(t, "not base64!", encrypted), password)
		require.ErrorContains(t, err, "invalid salt")
		require.NotErrorIs(t, err, wallet.ErrIncorrectPassword)
	})

	t.Run("a bad wallet file is no password error", func(t *testing.T) {
		_, err := wallet.DecryptWallet(writeWallet(t, saltBase64, "plain text"), password)
		require.ErrorContains(t, err, "invalid ciphertext format")
		require.NotErrorIs(t, err, wallet.ErrIncorrectPassword)
	})
}
