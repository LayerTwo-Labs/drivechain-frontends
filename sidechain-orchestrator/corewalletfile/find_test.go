package corewalletfile

import (
	"encoding/binary"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/blockfile"
	"github.com/stretchr/testify/require"
)

func TestFindWalletsUsesTheDefaultDirectory(t *testing.T) {
	for _, nested := range []bool{false, true} {
		name := "data directory"
		if nested {
			name = "wallets directory"
		}
		t.Run(name, func(t *testing.T) {
			root := t.TempDir()
			walletDir := root
			if nested {
				walletDir = filepath.Join(root, "wallets")
				createWallet(t, filepath.Join(root, "wallet.dat"), fromMagic)
			}
			paths := []string{
				filepath.Join(walletDir, "a", "wallet.dat"),
				filepath.Join(walletDir, "nested", "b", "wallet.dat"),
			}
			var before [][]byte
			for _, path := range paths {
				createWallet(t, path, blockfile.Magic{1, 2, 3, 4})
				data, err := os.ReadFile(path)
				require.NoError(t, err)
				before = append(before, data)
			}

			found, err := FindWallets(root, "")

			require.NoError(t, err)
			for index, path := range paths {
				paths[index], err = filepath.EvalSymlinks(path)
				require.NoError(t, err)
				data, err := os.ReadFile(path)
				require.NoError(t, err)
				require.Equal(t, before[index], data)
			}
			require.Equal(t, paths, found)
		})
	}
}

func TestFindWalletsUsesTheExplicitDirectory(t *testing.T) {
	root := t.TempDir()
	walletDir := t.TempDir()
	createWallet(t, filepath.Join(root, "wallets", "ignored", "wallet.dat"), fromMagic)
	path := filepath.Join(walletDir, "one", "wallet.dat")
	createWallet(t, path, fromMagic)

	paths, err := FindWallets(root, walletDir)

	require.NoError(t, err)
	path, err = filepath.EvalSymlinks(path)
	require.NoError(t, err)
	require.Equal(t, []string{path}, paths)
}

func TestFindWalletsReturnsNoWalletsForAbsentDefaultData(t *testing.T) {
	root := filepath.Join(t.TempDir(), "absent")

	paths, err := FindWallets(root, "")

	require.NoError(t, err)
	require.Empty(t, paths)
	_, err = os.Stat(root)
	require.ErrorIs(t, err, os.ErrNotExist)
}

func TestFindWalletsReturnsPathErrors(t *testing.T) {
	root := t.TempDir()
	file := filepath.Join(root, "file")
	require.NoError(t, os.WriteFile(file, []byte("file"), 0o600))
	for _, test := range []struct {
		name      string
		dataDir   string
		walletDir string
	}{
		{name: "empty data directory"},
		{name: "data path is a file", dataDir: file},
		{name: "missing wallet directory", dataDir: root, walletDir: filepath.Join(root, "absent")},
		{name: "wallet path is a file", dataDir: root, walletDir: file},
	} {
		t.Run(test.name, func(t *testing.T) {
			paths, err := FindWallets(test.dataDir, test.walletDir)

			require.Error(t, err)
			require.NotErrorIs(t, err, ErrLegacyWallet)
			require.Nil(t, paths)
		})
	}
}

func TestFindWalletsRejectsLegacyWallets(t *testing.T) {
	for _, name := range []string{"wallet.dat", "legacy.dat", "nested/wallet.dat"} {
		t.Run(name, func(t *testing.T) {
			root := t.TempDir()
			path := filepath.Join(root, filepath.FromSlash(name))
			require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
			data := make([]byte, 4096)
			binary.BigEndian.PutUint32(data[12:16], 0x00053162)
			require.NoError(t, os.WriteFile(path, data, 0o600))

			paths, err := FindWallets(root, "")

			require.ErrorContains(t, err, "SQLite")
			require.ErrorIs(t, err, ErrLegacyWallet)
			require.Nil(t, paths)
		})
	}
}

func TestFindWalletsSkipsTheJournalBackup(t *testing.T) {
	root := t.TempDir()
	backup := filepath.Join(root, ".ecash-wallet-journal.d")
	require.NoError(t, os.MkdirAll(backup, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(backup, "wallet.dat"), []byte("invalid"), 0o600))

	paths, err := FindWallets(root, "")

	require.NoError(t, err)
	require.Empty(t, paths)
}

func TestFindWalletsResolvesSymlinks(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("this test uses Unix symlinks")
	}
	root := t.TempDir()
	path := filepath.Join(t.TempDir(), "wallet.dat")
	createWallet(t, path, fromMagic)
	require.NoError(t, os.Symlink(filepath.Dir(path), filepath.Join(root, "directory")))
	require.NoError(t, os.Symlink(path, filepath.Join(root, "wallet.dat")))

	paths, err := FindWallets(root, "")

	require.NoError(t, err)
	path, err = filepath.EvalSymlinks(path)
	require.NoError(t, err)
	require.Equal(t, []string{path}, paths)
}
