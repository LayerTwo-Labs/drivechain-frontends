package engines

import (
	"context"
	"io"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

func TestBackupKeepsOneWalletState(t *testing.T) {
	db := database.Test(t)
	encryptedDir := t.TempDir()
	for _, name := range []string{"wallet.json", "wallet_encryption.json"} {
		data, err := os.ReadFile(filepath.Join("..", "tests", "apitests", "testdata", "encrypted", name))
		require.NoError(t, err)
		require.NoError(t, os.WriteFile(filepath.Join(encryptedDir, name), data, 0600))
	}
	encrypted := NewBackupEngine(db, encryptedDir, "")
	restoreData, _, err := encrypted.CreateBackup(t.Context())
	require.NoError(t, err)
	_, err = encrypted.ValidateBackup(t.Context(), restoreData, "restore.zip")
	require.NoError(t, err)

	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), []byte(`{"master":"seed","l1":"key"}`), 0600))
	engine := NewBackupEngine(db, dir, "")
	plainData, _, err := engine.CreateBackup(t.Context())
	require.NoError(t, err)
	_, err = engine.ValidateBackup(t.Context(), plainData, "plain.zip")
	require.NoError(t, err)
	read := make(chan struct{})
	release := make(chan struct{})
	var releaseOnce sync.Once
	ctx, cancel := context.WithTimeout(t.Context(), 5*time.Second)
	defer cancel()
	logger := zerolog.New(io.Discard).Hook(zerolog.HookFunc(func(_ *zerolog.Event, _ zerolog.Level, message string) {
		if message == "backup: added wallet.json" {
			close(read)
			select {
			case <-release:
			case <-ctx.Done():
			}
		}
	}))
	type result struct {
		data []byte
		err  error
	}
	done := make(chan result, 1)
	joined := false
	defer func() {
		releaseOnce.Do(func() { close(release) })
		if !joined {
			<-done
		}
	}()
	go func() {
		data, _, err := engine.CreateBackup(logger.WithContext(ctx))
		done <- result{data: data, err: err}
	}()
	select {
	case <-read:
	case <-ctx.Done():
		t.Fatal(ctx.Err())
	}
	restored := make(chan error, 1)
	go func() { restored <- engine.RestoreBackup(t.Context(), restoreData, "restore.zip") }()
	select {
	case err := <-restored:
		require.NoError(t, err)
		t.Fatal("restore changed the wallet before the backup finished")
	case <-time.After(50 * time.Millisecond):
	}
	releaseOnce.Do(func() { close(release) })
	backup := <-done
	joined = true
	require.NoError(t, <-restored)
	require.NoError(t, backup.err)
	_, err = engine.ValidateBackup(t.Context(), backup.data, "backup.zip")
	require.NoError(t, err, "a successful backup must hold one wallet state")
}
