package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// The runtime folder went out as "drynet". What lives there is the user's own —
// address book, notes, labels, multisig — so a rename must carry it, not leave
// an empty app beside it.
func TestFinalizeAdoptsTheLegacyECashDatadir(t *testing.T) {
	base := t.TempDir()
	legacy := filepath.Join(base, "drynet")
	require.NoError(t, os.MkdirAll(legacy, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(legacy, "bitwindow.db"), []byte("rows"), 0o644))

	conf := &Config{Datadir: base}
	require.NoError(t, conf.Finalize(NetworkECash))

	require.Equal(t, filepath.Join(base, "ecash"), conf.Datadir)
	moved, err := os.ReadFile(filepath.Join(base, "ecash", "bitwindow.db"))
	require.NoError(t, err, "the old database must come along")
	require.Equal(t, "rows", string(moved))
	require.NoDirExists(t, legacy)
}

// A folder this build already wrote to wins. Overwriting it would trade one
// loss for another.
func TestFinalizeKeepsAnExistingECashDatadir(t *testing.T) {
	base := t.TempDir()
	require.NoError(t, os.MkdirAll(filepath.Join(base, "drynet"), 0o755))
	require.NoError(t, os.MkdirAll(filepath.Join(base, "ecash"), 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(base, "ecash", "bitwindow.db"), []byte("current"), 0o644))

	conf := &Config{Datadir: base}
	require.NoError(t, conf.Finalize(NetworkECash))

	kept, err := os.ReadFile(filepath.Join(base, "ecash", "bitwindow.db"))
	require.NoError(t, err)
	require.Equal(t, "current", string(kept))
	require.DirExists(t, filepath.Join(base, "drynet"), "the old folder stays for the user to look at")
}

// Only the eCash slot went by another name, so no other network may be touched.
func TestFinalizeLeavesOtherNetworksAlone(t *testing.T) {
	base := t.TempDir()
	legacy := filepath.Join(base, "drynet")
	require.NoError(t, os.MkdirAll(legacy, 0o755))

	conf := &Config{Datadir: base}
	require.NoError(t, conf.Finalize(NetworkSignet))

	require.DirExists(t, legacy)
}
