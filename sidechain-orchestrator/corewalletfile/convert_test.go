package corewalletfile

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/binary"
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/blockfile"
	"github.com/stretchr/testify/require"
)

var (
	fromMagic = blockfile.Magic{0xec, 0xa5, 0xa1, 0x04}
	toMagic   = blockfile.Magic{0xfa, 0xbf, 0xb5, 0xda}
)

func testOptions(t *testing.T) Options {
	t.Helper()
	return Options{DataDir: t.TempDir(), From: fromMagic, To: toMagic}
}

func createWallet(t *testing.T, path string, magic blockfile.Magic) {
	t.Helper()
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
	db, err := sql.Open("sqlite3", path)
	require.NoError(t, err)
	_, err = db.Exec("CREATE TABLE main(key BLOB PRIMARY KEY NOT NULL, value BLOB NOT NULL)")
	require.NoError(t, err)
	_, err = db.Exec(fmt.Sprintf("PRAGMA application_id=%d", int32(binary.BigEndian.Uint32(magic[:]))))
	require.NoError(t, err)
	_, err = db.Exec("INSERT INTO main VALUES (?, ?)", []byte{0, 1, 2}, bytes.Repeat([]byte{0, 0xab, 0xff}, 1024))
	require.NoError(t, err)
	require.NoError(t, db.Close())
}

func readRows(t *testing.T, path string) (blockfile.Magic, string) {
	t.Helper()
	db, err := openDatabase(path, true)
	require.NoError(t, err)
	magic, hash, err := inspect(t.Context(), db)
	require.NoError(t, err)
	require.NoError(t, db.Close())
	return magic, hash
}

func TestConvertChangesOnlyWalletMagic(t *testing.T) {
	opts := testOptions(t)
	path := filepath.Join(opts.DataDir, "wallets", "one", "wallet.dat")
	createWallet(t, path, fromMagic)
	before, err := os.ReadFile(path)
	require.NoError(t, err)
	_, hash := readRows(t, path)

	preview, err := Preview(t.Context(), opts)
	require.NoError(t, err)
	require.Equal(t, 1, preview.Wallets)
	require.False(t, preview.Complete)
	afterPreview, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Equal(t, before, afterPreview)
	report, err := Convert(t.Context(), opts)
	require.NoError(t, err)
	require.True(t, report.Complete)
	require.Equal(t, 1, report.ConvertedWallets)

	after, err := os.ReadFile(path)
	require.NoError(t, err)
	expected := bytes.Clone(before)
	copy(expected[68:72], toMagic[:])
	require.Equal(t, expected, after)
	magic, afterHash := readRows(t, path)
	require.Equal(t, toMagic, magic)
	require.Equal(t, hash, afterHash)
	backup, err := os.ReadFile(filepath.Join(report.JournalPath+".d", "000000-db"))
	require.NoError(t, err)
	require.Equal(t, before, backup)

	second, err := Convert(t.Context(), opts)
	require.NoError(t, err)
	require.True(t, second.Complete)
	afterSecond, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Equal(t, after, afterSecond)
}

func TestConvertRecoversWalletWAL(t *testing.T) {
	source := filepath.Join(t.TempDir(), "wallet.dat")
	createWallet(t, source, blockfile.Magic{})
	db, err := openDatabase(source, false)
	require.NoError(t, err)
	for _, query := range []string{
		"PRAGMA journal_mode=WAL",
		"PRAGMA wal_autocheckpoint=0",
		fmt.Sprintf("PRAGMA application_id=%d", int32(binary.BigEndian.Uint32(fromMagic[:]))),
		"INSERT INTO main VALUES (x'112233', x'aabbcc')",
	} {
		_, err := db.Exec(query)
		require.NoError(t, err)
	}
	opts := testOptions(t)
	path := filepath.Join(opts.DataDir, "wallet.dat")
	for _, suffix := range []string{"", "-wal"} {
		_, err := copyFile(source+suffix, path+suffix)
		require.NoError(t, err)
	}
	require.NoError(t, db.Close())
	before, err := os.ReadFile(path)
	require.NoError(t, err)
	wal, err := os.ReadFile(path + "-wal")
	require.NoError(t, err)
	require.NotEmpty(t, wal)
	require.Equal(t, []byte{0, 0, 0, 0}, before[68:72])
	_, hash, err := inspectCopy(t.Context(), path)
	require.NoError(t, err)

	preview, err := Preview(t.Context(), opts)
	require.NoError(t, err)
	require.Equal(t, 1, preview.Wallets)
	afterPreview, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Equal(t, before, afterPreview)
	report, err := Convert(t.Context(), opts)
	require.NoError(t, err)
	require.True(t, report.Complete)

	magic, afterHash := readRows(t, path)
	require.Equal(t, toMagic, magic)
	require.Equal(t, hash, afterHash)
	backup, err := os.ReadFile(filepath.Join(report.JournalPath+".d", "000000-db-wal"))
	require.NoError(t, err)
	require.Equal(t, wal, backup)
	_, err = Convert(t.Context(), opts)
	require.NoError(t, err)
}

func TestConvertFindsNestedAndExternalWallets(t *testing.T) {
	opts := testOptions(t)
	opts.WalletDir = t.TempDir()
	external := t.TempDir()
	opts.WalletPaths = []string{"nested/one", external}
	for _, path := range []string{
		filepath.Join(opts.WalletDir, "wallet.dat"),
		filepath.Join(opts.WalletDir, "nested", "one", "wallet.dat"),
		filepath.Join(external, "wallet.dat"),
	} {
		createWallet(t, path, fromMagic)
	}

	report, err := Convert(t.Context(), opts)

	require.NoError(t, err)
	require.Equal(t, 3, report.Wallets)
	require.Equal(t, 3, report.ConvertedWallets)
	magic, _ := readRows(t, filepath.Join(external, "wallet.dat"))
	require.Equal(t, toMagic, magic)
}

// A datadir keeps wallets from earlier networks. They cannot follow this
// migration, and one of them must not block the wallets that can.
func TestConvertSkipsAWalletFromAnotherNetwork(t *testing.T) {
	opts := testOptions(t)
	mine := filepath.Join(opts.DataDir, "a", "wallet.dat")
	foreign := filepath.Join(opts.DataDir, "b", "wallet.dat")
	createWallet(t, mine, fromMagic)
	createWallet(t, foreign, blockfile.Magic{1, 2, 3, 4})
	before, err := os.ReadFile(foreign)
	require.NoError(t, err)

	report, err := Convert(t.Context(), opts)

	require.NoError(t, err)
	require.Equal(t, 1, report.Wallets)
	require.Equal(t, 1, report.ConvertedWallets)
	require.Equal(t, 1, report.ForeignWallets)

	converted, _ := readRows(t, mine)
	require.Equal(t, toMagic, converted)
	after, err := os.ReadFile(foreign)
	require.NoError(t, err)
	require.Equal(t, before, after)
}

func TestPreviewCountsAWalletFromAnotherNetwork(t *testing.T) {
	opts := testOptions(t)
	createWallet(t, filepath.Join(opts.DataDir, "a", "wallet.dat"), fromMagic)
	createWallet(t, filepath.Join(opts.DataDir, "b", "wallet.dat"), blockfile.Magic{1, 2, 3, 4})

	report, err := Preview(t.Context(), opts)

	require.NoError(t, err)
	require.Equal(t, 1, report.Wallets)
	require.Equal(t, 1, report.ForeignWallets)
	require.Zero(t, report.ConvertedWallets)
}

func TestConvertRejectsLegacyBDBWallet(t *testing.T) {
	for _, name := range []string{"wallet.dat", "legacy.dat"} {
		t.Run(name, func(t *testing.T) {
			opts := testOptions(t)
			path := filepath.Join(opts.DataDir, name)
			data := make([]byte, 4096)
			binary.BigEndian.PutUint32(data[12:16], 0x00053162)
			require.NoError(t, os.WriteFile(path, data, 0o600))

			_, err := Convert(t.Context(), opts)

			require.ErrorContains(t, err, "SQLite")
			after, err := os.ReadFile(path)
			require.NoError(t, err)
			require.Equal(t, data, after)
		})
	}
}

func TestConvertResumesPartialMagicWrite(t *testing.T) {
	opts := testOptions(t)
	path := filepath.Join(opts.DataDir, "wallet.dat")
	createWallet(t, path, fromMagic)
	opts, err := prepare(opts)
	require.NoError(t, err)
	paths, err := discover(opts)
	require.NoError(t, err)
	_, err = makeJournal(t.Context(), opts, paths)
	require.NoError(t, err)
	file, err := os.OpenFile(path, os.O_RDWR, 0)
	require.NoError(t, err)
	_, err = file.WriteAt(toMagic[:2], 68)
	require.NoError(t, err)
	require.NoError(t, file.Close())

	preview, err := Preview(t.Context(), opts)
	require.NoError(t, err)
	require.False(t, preview.Complete)
	report, err := Convert(t.Context(), opts)

	require.NoError(t, err)
	require.True(t, report.Complete)
	magic, _ := readRows(t, path)
	require.Equal(t, toMagic, magic)
}

func TestConvertRefusesRecordsThatDifferFromJournal(t *testing.T) {
	opts := testOptions(t)
	path := filepath.Join(opts.DataDir, "wallet.dat")
	createWallet(t, path, fromMagic)
	opts, err := prepare(opts)
	require.NoError(t, err)
	paths, err := discover(opts)
	require.NoError(t, err)
	_, err = makeJournal(t.Context(), opts, paths)
	require.NoError(t, err)
	db, err := openDatabase(path, false)
	require.NoError(t, err)
	_, err = db.Exec("INSERT INTO main VALUES (x'55', x'66')")
	require.NoError(t, err)
	require.NoError(t, db.Close())

	_, err = Convert(t.Context(), opts)

	require.ErrorContains(t, err, "wallet records differ")
	magic, _ := readRows(t, path)
	require.Equal(t, fromMagic, magic)
}

func TestConvertRefusesAnIncompleteBackup(t *testing.T) {
	opts := testOptions(t)
	path := filepath.Join(opts.DataDir, "wallet.dat")
	createWallet(t, path, fromMagic)
	opts, err := prepare(opts)
	require.NoError(t, err)
	paths, err := discover(opts)
	require.NoError(t, err)
	_, err = makeJournal(t.Context(), opts, paths)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(opts.JournalPath+".d", "000000-db"), []byte("invalid"), 0o600))

	_, err = Convert(t.Context(), opts)

	require.ErrorContains(t, err, "backup differs")
	magic, _ := readRows(t, path)
	require.Equal(t, fromMagic, magic)
}

func TestConvertReturnsAnErrorForAMissingConfiguredWallet(t *testing.T) {
	opts := testOptions(t)
	opts.WalletPaths = []string{"missing-wallet"}

	_, err := Convert(t.Context(), opts)

	require.ErrorContains(t, err, "read configured wallet")
}

func TestConvertAcceptsAnEmptyWalletDirectory(t *testing.T) {
	opts := testOptions(t)

	report, err := Convert(t.Context(), opts)

	require.NoError(t, err)
	require.True(t, report.Complete)
	require.Zero(t, report.Wallets)
	_, err = Convert(t.Context(), opts)
	require.NoError(t, err)
}

func TestConvertReturnsContextCancellation(t *testing.T) {
	opts := testOptions(t)
	createWallet(t, filepath.Join(opts.DataDir, "wallet.dat"), fromMagic)
	ctx, cancel := context.WithCancel(t.Context())
	cancel()

	_, err := Convert(ctx, opts)

	require.ErrorIs(t, err, context.Canceled)
}

// SQLite reads the text between "file://" and the next slash as the URI
// authority, so a Windows drive letter has to sit after a leading slash.
func TestDatabaseURIKeepsTheDriveLetterOutOfTheAuthority(t *testing.T) {
	tests := []struct {
		name     string
		path     string
		readOnly bool
		want     string
	}{
		{
			name: "windows",
			path: `C:/Users/btcap/Documents/Bitcoin/ecash/wallet_43562395/wallet.dat`,
			want: "file:///C:/Users/btcap/Documents/Bitcoin/ecash/wallet_43562395/wallet.dat?_busy_timeout=0&mode=rw",
		},
		{
			name: "unix",
			path: "/home/bo/.ecash/wallet.dat",
			want: "file:///home/bo/.ecash/wallet.dat?_busy_timeout=0&mode=rw",
		},
		{
			name:     "windows read only",
			path:     `C:/Users/btcap/wallet.dat`,
			readOnly: true,
			want:     "file:///C:/Users/btcap/wallet.dat?_busy_timeout=0&immutable=1&mode=ro",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			require.Equal(t, tt.want, databaseURI(tt.path, tt.readOnly))
		})
	}
}
