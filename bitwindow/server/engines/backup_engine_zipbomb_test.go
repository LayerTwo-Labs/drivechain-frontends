package engines

import (
	"archive/zip"
	"bytes"
	"testing"

	"github.com/stretchr/testify/require"
)

func zipWith(t *testing.T, name string, data []byte) []byte {
	t.Helper()
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	require.NoError(t, addToZip(zw, name, data))
	require.NoError(t, zw.Close())
	return buf.Bytes()
}

// an over-cap zip entry must be rejected, not read into memory
func TestBackupZipEntryCapped(t *testing.T) {
	orig := maxBackupEntrySize
	maxBackupEntrySize = 1 << 10
	defer func() { maxBackupEntrySize = orig }()

	bomb := zipWith(t, "wallet.json", bytes.Repeat([]byte("a"), 8<<10))
	_, _, _, _, _, err := extractZIP(bomb)
	require.ErrorContains(t, err, "exceeds 1024 byte limit")
	e := &BackupEngine{}
	_, err = e.validateZIP(bomb)
	require.ErrorContains(t, err, "exceeds 1024 byte limit")

	// a valid within-cap backup still works
	ok := zipWith(t, "wallet.json", []byte(`{"master":"x","l1":"y"}`))
	wallet, _, _, _, _, err := extractZIP(ok)
	require.NoError(t, err)
	require.NotEmpty(t, wallet)
	_, err = e.validateZIP(ok)
	require.NoError(t, err)
}

func TestValidateZIP_OptionalEntryReadFails(t *testing.T) {
	orig := maxBackupEntrySize
	maxBackupEntrySize = 1 << 10
	defer func() { maxBackupEntrySize = orig }()

	for _, name := range []string{"multisig/multisig.json", "transactions.json"} {
		t.Run(name, func(t *testing.T) {
			var buf bytes.Buffer
			zw := zip.NewWriter(&buf)
			require.NoError(t, addToZip(zw, "wallet.json", []byte(`{"master":"x","l1":"y"}`)))
			require.NoError(t, addToZip(zw, name, bytes.Repeat([]byte("a"), 8<<10)))
			require.NoError(t, zw.Close())

			_, err := (&BackupEngine{}).validateZIP(buf.Bytes())
			require.ErrorContains(t, err, "read "+name+" in zip")
		})
	}
}
