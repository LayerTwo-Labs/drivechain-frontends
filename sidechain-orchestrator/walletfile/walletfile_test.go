package walletfile

import (
	"encoding/base64"
	"errors"
	"os"
	"path/filepath"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// walletFileWith builds a plaintext wallet file holding the given wallet ids.
func walletFileWith(ids ...string) []byte {
	body := `{"version":1,"activeWalletId":"` + firstOr(ids, "") + `","wallets":[`
	for i, id := range ids {
		if i > 0 {
			body += ","
		}
		body += `{"version":1,"master":{},"l1":{},"sidechains":[],"id":"` + id + `","name":"` + id + `","gradient":null,"wallet_type":"electrum"}`
	}
	return []byte(body + `]}`)
}

func firstOr(ids []string, fallback string) string {
	if len(ids) == 0 {
		return fallback
	}
	return ids[0]
}

func encryptedWalletFile() []byte {
	iv := base64.StdEncoding.EncodeToString([]byte("0123456789ab"))
	ciphertext := base64.StdEncoding.EncodeToString([]byte("not really a ciphertext"))
	return []byte(iv + ":" + ciphertext)
}

func TestValidate(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		content []byte
		wantErr bool
	}{
		{name: "plaintext wallet file", content: walletFileWith("A", "B")},
		{name: "encrypted wallet file", content: encryptedWalletFile()},
		{name: "empty wallet file", content: nil, wantErr: true},
		// The exact content a lost wallet file held in the field.
		{name: "the word data", content: []byte("data"), wantErr: true},
		{name: "truncated json", content: []byte(`{"version":1,"wallets":[`), wantErr: true},
		{name: "a colon but not base64", content: []byte(`hello: world`), wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			err := Validate(tt.content)
			if tt.wantErr {
				assert.Error(t, err)
				return
			}
			assert.NoError(t, err)
		})
	}
}

func TestDroppedWalletIDs(t *testing.T) {
	t.Parallel()

	assert.Equal(t, []string{"B"}, DroppedWalletIDs(walletFileWith("A", "B"), walletFileWith("A")))
	assert.Empty(t, DroppedWalletIDs(walletFileWith("A"), walletFileWith("A", "B")))
	assert.Empty(t, DroppedWalletIDs(walletFileWith("A"), walletFileWith("A")))
	// An encrypted side compares against nothing, so it never blocks a write.
	assert.Empty(t, DroppedWalletIDs(encryptedWalletFile(), walletFileWith("A")))
}

func TestWriteCreatesAMissingFile(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	content := walletFileWith("A")

	// DigestOf(nil) is what a reader records when the file does not exist.
	require.NoError(t, Write(path, content, Options{
		Expected:      DigestOf(nil),
		ExpectedKnown: true,
	}))

	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, content, got)
}

func TestWriteRefusesContentThatDoesNotParse(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	original := walletFileWith("A", "B")
	require.NoError(t, os.WriteFile(path, original, 0600))

	err := Write(path, []byte("data"), Options{
		Expected:      DigestOf(original),
		ExpectedKnown: true,
	})

	require.Error(t, err)
	got, readErr := os.ReadFile(path)
	require.NoError(t, readErr)
	assert.Equal(t, original, got, "the wallet file must survive a refused write")
}

func TestWriteRefusesAFileAnotherWriterChanged(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	read := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, walletFileWith("A", "B"), 0600))

	err := Write(path, walletFileWith("A", "C"), Options{
		Expected:      DigestOf(read),
		ExpectedKnown: true,
		AllowDrop:     true,
	})

	assert.ErrorIs(t, err, ErrChanged)
	got, readErr := os.ReadFile(path)
	require.NoError(t, readErr)
	assert.Equal(t, walletFileWith("A", "B"), got)
}

func TestWriteRefusesAFileItNeverRead(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	require.NoError(t, os.WriteFile(path, walletFileWith("A"), 0600))

	err := Write(path, walletFileWith("A", "B"), Options{ExpectedKnown: false})

	assert.ErrorIs(t, err, ErrUnread)
}

func TestWriteRefusesAWriteThatDropsAWallet(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	original := walletFileWith("A", "B", "C")
	require.NoError(t, os.WriteFile(path, original, 0600))

	err := Write(path, walletFileWith("A"), Options{
		Expected:      DigestOf(original),
		ExpectedKnown: true,
	})

	require.ErrorIs(t, err, ErrDropsWallets)
	assert.Contains(t, err.Error(), "B")
	assert.Contains(t, err.Error(), "C")

	got, readErr := os.ReadFile(path)
	require.NoError(t, readErr)
	assert.Equal(t, original, got)
}

func TestWriteDropsAWalletWhenTheCallerAsks(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	original := walletFileWith("A", "B")
	require.NoError(t, os.WriteFile(path, original, 0600))
	next := walletFileWith("A")

	require.NoError(t, Write(path, next, Options{
		Expected:      DigestOf(original),
		ExpectedKnown: true,
		AllowDrop:     true,
	}))

	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, next, got)
}

func TestWriteKeepsTheFileItReplaces(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	original := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, original, 0600))

	require.NoError(t, Write(path, walletFileWith("A", "B"), Options{
		Expected:      DigestOf(original),
		ExpectedKnown: true,
	}))

	previous, err := os.ReadFile(path + PreviousSuffix)
	require.NoError(t, err)
	assert.Equal(t, original, previous)
}

func TestWriteOverwritesAFileThatDoesNotParse(t *testing.T) {
	t.Parallel()

	// A wallet file already lost to a bad write must not block the repair.
	path := filepath.Join(t.TempDir(), "wallet.json")
	require.NoError(t, os.WriteFile(path, []byte("data"), 0600))
	content := walletFileWith("A")

	require.NoError(t, Write(path, content, Options{ExpectedKnown: false}))

	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, content, got)
	_, statErr := os.Stat(path + PreviousSuffix)
	assert.True(t, errors.Is(statErr, os.ErrNotExist), "an unreadable file is not worth keeping")
}

func TestWriteKeepsNoPlaintextOnceEncrypted(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	plaintext := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, plaintext, 0600))
	// A copy from an earlier write is plaintext too, and it must go.
	require.NoError(t, os.WriteFile(path+PreviousSuffix, plaintext, 0600))

	require.NoError(t, Write(path, encryptedWalletFile(), Options{
		Expected:      DigestOf(plaintext),
		ExpectedKnown: true,
	}))

	_, err := os.Stat(path + PreviousSuffix)
	assert.True(t, errors.Is(err, os.ErrNotExist), "a plaintext copy beside an encrypted wallet hands out the seed")
}

func TestWriteKeepsTheCopyBetweenTwoEncryptedFiles(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	first := encryptedWalletFile()
	require.NoError(t, os.WriteFile(path, first, 0600))

	second := []byte(base64.StdEncoding.EncodeToString([]byte("another iv!!")) + ":" +
		base64.StdEncoding.EncodeToString([]byte("another ciphertext")))
	require.NoError(t, Write(path, second, Options{
		Expected:      DigestOf(first),
		ExpectedKnown: true,
	}))

	previous, err := os.ReadFile(path + PreviousSuffix)
	require.NoError(t, err)
	assert.Equal(t, first, previous)
}

func TestWriteLetsOnlyOneOfTwoWritersWin(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "wallet.json")
	read := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, read, 0600))

	// Both writers read the same file, so both carry the same digest. The lock
	// serializes them and the second one finds a file it did not read.
	results := make(chan error, 2)
	var start sync.WaitGroup
	start.Add(1)
	for _, id := range []string{"B", "C"} {
		go func(id string) {
			start.Wait()
			results <- Write(path, walletFileWith("A", id), Options{
				Expected:      DigestOf(read),
				ExpectedKnown: true,
			})
		}(id)
	}
	start.Done()

	first, second := <-results, <-results
	if first != nil {
		first, second = second, first
	}
	assert.NoError(t, first, "one writer must win")
	assert.ErrorIs(t, second, ErrChanged, "the other must find the file changed")

	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.NoError(t, Validate(got))
}

func TestWriteLeavesALaterValidWriteAlone(t *testing.T) {
	t.Parallel()

	// A file another writer replaced with valid content stays as it is. Putting
	// the kept copy back would take away that writer's wallet.
	path := filepath.Join(t.TempDir(), "wallet.json")
	original := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, original, 0600))

	require.NoError(t, Write(path, walletFileWith("A", "B"), Options{
		Expected:      DigestOf(original),
		ExpectedKnown: true,
	}))

	got, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Equal(t, walletFileWith("A", "B"), got)
}

func TestWriteRefusesAFileAnotherWriterDeleted(t *testing.T) {
	t.Parallel()

	// The wipe took the file away. Writing here brings back the seeds it removed.
	path := filepath.Join(t.TempDir(), "wallet.json")
	read := walletFileWith("A")

	err := Write(path, walletFileWith("A", "B"), Options{
		Expected:      DigestOf(read),
		ExpectedKnown: true,
	})

	assert.ErrorIs(t, err, ErrChanged)
	_, statErr := os.Stat(path)
	assert.True(t, errors.Is(statErr, os.ErrNotExist))
}

func TestWithLockKeepsAWriteOutUntilItReturns(t *testing.T) {
	t.Parallel()

	// A wipe moves the file away under the lock. A writer that starts at the
	// same time must see the move, not write over it.
	dir := t.TempDir()
	path := filepath.Join(dir, "wallet.json")
	read := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, read, 0600))

	writeDone := make(chan error, 1)
	inLock := make(chan struct{})
	release := make(chan struct{})

	go func() {
		_ = WithLock(path, func() error {
			close(inLock)
			<-release
			return os.Rename(path, filepath.Join(dir, "wallet.json.moved"))
		})
	}()

	<-inLock
	go func() {
		writeDone <- Write(path, walletFileWith("A", "B"), Options{
			Expected:      DigestOf(read),
			ExpectedKnown: true,
		})
	}()

	close(release)
	assert.ErrorIs(t, <-writeDone, ErrChanged)
	_, err := os.Stat(path)
	assert.True(t, errors.Is(err, os.ErrNotExist), "the wipe must hold")
}
