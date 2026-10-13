package wallet

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Each wallet carries its own seed, so a moved pin restarts every sidechain
// against coins the user does not hold. The delete has to refuse.
func TestDeleteWalletRefusesTheStarter(t *testing.T) {
	svc := newTestService(t)

	first, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	second, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)

	require.Equal(t, first.ID, svc.StarterWalletID(), "the first seeded wallet holds the pin")

	err = svc.DeleteWallet(first.ID)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "derives the sidechain starters")

	require.NoError(t, svc.DeleteWallet(second.ID), "any other wallet still deletes")
	assert.Equal(t, first.ID, svc.StarterWalletID(), "the pin never moves")
}

func TestStarterDir(t *testing.T) {
	predictable := filepath.Join(os.TempDir(), fmt.Sprintf("bitwindow_starters_%d", os.Getpid()))
	require.NoError(t, os.MkdirAll(predictable, 0o777))
	t.Cleanup(func() { require.NoError(t, os.RemoveAll(predictable)) })

	svc := newTestService(t)
	_, err := svc.GenerateWallet("Starter", "", "", testSlots)
	require.NoError(t, err)

	first, err := svc.WriteSidechainStarter(9)
	require.NoError(t, err)
	second, err := svc.WriteSidechainStarter(5)
	require.NoError(t, err)

	entries, err := os.ReadDir(predictable)
	require.NoError(t, err)
	require.Empty(t, entries)

	dir := filepath.Dir(first)
	require.NotEqual(t, predictable, dir)
	require.Equal(t, dir, filepath.Dir(second))
	info, err := os.Stat(dir)
	require.NoError(t, err)
	require.Equal(t, os.FileMode(0o700), info.Mode().Perm())

	svc.CleanupStarterFiles()
	require.NoDirExists(t, dir)
}
