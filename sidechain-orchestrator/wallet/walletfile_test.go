package wallet

import (
	"encoding/base64"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/walletfile"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// walletFileWith builds a plaintext wallet file holding the given wallet ids.
func walletFileWith(ids ...string) []byte {
	body := `{"version":1,"activeWalletId":"` + ids[0] + `","wallets":[`
	for i, id := range ids {
		if i > 0 {
			body += ","
		}
		body += `{"version":1,"master":{},"l1":{},"sidechains":[],"id":"` + id + `","name":"` + id + `","gradient":null,"wallet_type":"electrum"}`
	}
	return []byte(body + `]}`)
}

func TestLoadWalletFileKeepsTheDigestWhenTheFileDoesNotParse(t *testing.T) {
	t.Parallel()

	dir := t.TempDir()
	service := NewService(dir, zerolog.Nop())
	path := filepath.Join(dir, "wallet.json")
	good := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, good, 0600))
	require.NoError(t, service.loadWalletFile())
	require.Equal(t, walletfile.DigestOf(good), service.lastWalletDigest)

	// A file this process cannot read must not stand as the state it holds.
	require.NoError(t, os.WriteFile(path, []byte("data"), 0600))
	require.Error(t, service.loadWalletFile())

	assert.Equal(t, walletfile.DigestOf(good), service.lastWalletDigest)
}

func plaintextLeftover(t *testing.T, svc *Service, content []byte) string {
	t.Helper()
	path := svc.walletFilePath() + ".backup_before_encryption_1"
	require.NoError(t, os.WriteFile(path, content, 0o644))
	require.NoError(t, os.Chmod(path, 0o644))
	return path
}

func decryptLeftover(t *testing.T, path, password string) []byte {
	t.Helper()
	metaBytes, err := os.ReadFile(path + leftoverMetadataSuffix)
	require.NoError(t, err)
	meta, err := UnmarshalEncryptionMetadata(metaBytes)
	require.NoError(t, err)
	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	require.NoError(t, err)
	content, err := os.ReadFile(path)
	require.NoError(t, err)
	plaintext, err := Decrypt(string(content), DeriveKey(password, salt, meta.Iterations))
	require.NoError(t, err)
	return []byte(plaintext)
}

func requireProtected(t *testing.T, path, password string, want []byte) {
	t.Helper()
	content, err := os.ReadFile(path)
	require.NoError(t, err)
	require.True(t, walletfile.IsEncrypted(content))
	info, err := os.Stat(path)
	require.NoError(t, err)
	if runtime.GOOS != "windows" {
		require.Equal(t, os.FileMode(0o600), info.Mode().Perm())
	}
	require.Equal(t, want, decryptLeftover(t, path, password))
}

func TestProtectPlaintextLeftovers(t *testing.T) {
	t.Run("unlock encrypts a plaintext copy", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Leftover", "", "", testSlots)
		require.NoError(t, err)
		seed, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		require.NoError(t, svc.EncryptWallet("pass"))
		path := plaintextLeftover(t, svc, seed)
		svc.LockWallet()

		require.NoError(t, svc.UnlockWallet("pass"))

		requireProtected(t, path, "pass", seed)
	})

	t.Run("wrong password leaves the copy alone", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Leftover", "", "", testSlots)
		require.NoError(t, err)
		seed, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		require.NoError(t, svc.EncryptWallet("pass"))
		path := plaintextLeftover(t, svc, seed)
		svc.LockWallet()

		require.ErrorContains(t, svc.UnlockWallet("wrong"), "incorrect password")

		got, err := os.ReadFile(path)
		require.NoError(t, err)
		require.Equal(t, seed, got)
		info, err := os.Stat(path)
		require.NoError(t, err)
		if runtime.GOOS != "windows" {
			require.Equal(t, os.FileMode(0o644), info.Mode().Perm())
		}
		require.NoFileExists(t, path+leftoverMetadataSuffix)
	})

	t.Run("encrypt protects an older copy", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Leftover", "", "", testSlots)
		require.NoError(t, err)
		seed, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		path := plaintextLeftover(t, svc, seed)

		require.NoError(t, svc.EncryptWallet("pass"))

		requireProtected(t, path, "pass", seed)
	})

	t.Run("copy opens with the old password after a change", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Leftover", "", "", testSlots)
		require.NoError(t, err)
		seed, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		path := plaintextLeftover(t, svc, seed)
		require.NoError(t, svc.EncryptWallet("old"))

		require.NoError(t, svc.ChangePassword("old", "new"))

		requireProtected(t, path, "old", seed)
	})

	t.Run("encrypt says the wallet is encrypted when a copy fails", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Leftover", "", "", testSlots)
		require.NoError(t, err)
		seed, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		path := plaintextLeftover(t, svc, seed)
		require.NoError(t, os.Mkdir(path+leftoverMetadataSuffix+".tmp", 0o700))

		require.ErrorContains(t, svc.EncryptWallet("pass"), "the wallet is encrypted, but a plaintext copy beside it is not: ")

		content, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		require.True(t, walletfile.IsEncrypted(content))
	})

	t.Run("unlock stops when a copy fails", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Leftover", "", "", testSlots)
		require.NoError(t, err)
		seed, err := os.ReadFile(svc.walletFilePath())
		require.NoError(t, err)
		require.NoError(t, svc.EncryptWallet("pass"))
		path := plaintextLeftover(t, svc, seed)
		require.NoError(t, os.Mkdir(path+leftoverMetadataSuffix+".tmp", 0o700))
		svc.LockWallet()

		require.ErrorContains(t, svc.UnlockWallet("pass"), "unlock stopped: encrypt the plaintext wallet copy: ")
		require.Equal(t, StateLocked, svc.State())
	})
}
