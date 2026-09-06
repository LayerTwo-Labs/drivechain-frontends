package api_wallet

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// restoreServer builds a Server whose wallet lives in dir.
func restoreServer(dir string) *Server {
	return &Server{
		walletEngine: engines.NewWalletEngine(nil, dir, &chaincfg.SigNetParams),
		backupEngine: engines.NewBackupEngine(nil, dir),
		walletDir:    dir,
	}
}

// A restore swaps out wallet.json, so it must not run behind the lock screen -
// otherwise anyone at the machine can replace the wallet without the password.
func TestRestoreBackupRejectedWhileLocked(t *testing.T) {
	t.Parallel()

	dir := t.TempDir()
	walletPath := filepath.Join(dir, "wallet.json")
	existing := []byte("aXY=:Y2lwaGVy")
	require.NoError(t, os.WriteFile(walletPath, existing, 0600))
	require.NoError(t, os.WriteFile(
		filepath.Join(dir, "wallet_encryption.json"),
		[]byte(`{"salt":"c2FsdA==","iterations":100000,"encrypted":true,"version":"1"}`), 0600,
	))

	server := restoreServer(dir)
	require.False(t, server.walletEngine.IsUnlocked(), "an encrypted wallet starts locked")

	_, err := server.RestoreBackup(context.Background(), connect.NewRequest(&pb.RestoreBackupRequest{
		BackupData: []byte(`{"master":"backup seed","l1":"backup key"}`),
		Filename:   "wallet.json",
	}))
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

	after, err := os.ReadFile(walletPath)
	require.NoError(t, err)
	require.Equal(t, existing, after, "the locked wallet must be untouched")
}

// First launch has no wallet to protect, so the restore that seeds one still runs.
func TestRestoreBackupWithoutExistingWallet(t *testing.T) {
	t.Parallel()

	dir := t.TempDir()
	server := restoreServer(dir)

	backup := []byte(`{"master":"backup seed","l1":"backup key"}`)
	_, err := server.RestoreBackup(context.Background(), connect.NewRequest(&pb.RestoreBackupRequest{
		BackupData: backup,
		Filename:   "wallet.json",
	}))
	require.NoError(t, err)

	written, err := os.ReadFile(filepath.Join(dir, "wallet.json"))
	require.NoError(t, err)
	require.Equal(t, backup, written)
}

// An unencrypted wallet that fails to auto-unlock reads as locked, and it has no
// unlock path - gating on it would brick the restore that repairs it.
func TestRestoreBackupOverCorruptUnencryptedWallet(t *testing.T) {
	t.Parallel()

	dir := t.TempDir()
	walletPath := filepath.Join(dir, "wallet.json")
	require.NoError(t, os.WriteFile(walletPath, []byte(`{"master": "truncated`), 0600))

	server := restoreServer(dir)
	require.False(t, server.walletEngine.IsUnlocked(), "a corrupt wallet never auto-unlocks")

	backup := []byte(`{"master":"backup seed","l1":"backup key"}`)
	_, err := server.RestoreBackup(context.Background(), connect.NewRequest(&pb.RestoreBackupRequest{
		BackupData: backup,
		Filename:   "wallet.json",
	}))
	require.NoError(t, err)

	written, err := os.ReadFile(walletPath)
	require.NoError(t, err)
	require.Equal(t, backup, written)
}
