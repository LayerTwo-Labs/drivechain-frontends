package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPidFile_WriteReadDelete(t *testing.T) {
	m := newTestPidManager(t)

	require.NoError(t, m.WritePidFile("test-binary", 12345))

	pid, err := m.ReadPidFile("test-binary")
	require.NoError(t, err)
	assert.Equal(t, 12345, pid)

	require.NoError(t, m.DeletePidFile("test-binary"))

	_, err = m.ReadPidFile("test-binary")
	assert.ErrorIs(t, err, os.ErrNotExist)
}

func TestPidFile_ReadNonExistent(t *testing.T) {
	m := newTestPidManager(t)
	_, err := m.ReadPidFile("nonexistent")
	assert.ErrorIs(t, err, os.ErrNotExist)
}

func TestPidFile_InvalidContentDeletesFile(t *testing.T) {
	m := newTestPidManager(t)

	path := filepath.Join(m.pidDir, "bad.pid")
	require.NoError(t, os.WriteFile(path, []byte("not-a-number"), 0o644))

	_, err := m.ReadPidFile("bad")
	assert.Error(t, err)

	_, err = os.Stat(path)
	assert.True(t, os.IsNotExist(err))
}

func TestPidFile_DeleteNonExistentIsNoop(t *testing.T) {
	m := newTestPidManager(t)
	assert.NoError(t, m.DeletePidFile("nonexistent"))
}

func TestPidFile_List(t *testing.T) {
	m := newTestPidManager(t)

	require.NoError(t, m.WritePidFile("aaa", 100))
	require.NoError(t, m.WritePidFile("bbb", 200))

	pids := m.ListPidFiles()
	assert.Equal(t, map[string]int{"aaa": 100, "bbb": 200}, pids)
}

func TestPidFile_OverwriteKeepsLatest(t *testing.T) {
	m := newTestPidManager(t)

	require.NoError(t, m.WritePidFile("bin", 100))
	require.NoError(t, m.WritePidFile("bin", 200))

	pid, err := m.ReadPidFile("bin")
	require.NoError(t, err)
	assert.Equal(t, 200, pid)
}

func TestProcessNameMatches(t *testing.T) {
	tests := []struct {
		proc, bin string
		want      bool
	}{
		{"bitcoind", "bitcoind", true},
		{"Bitcoind", "bitcoind", true},   // case insensitive
		{"bitcoin", "bitcoind", true},    // ps truncation
		{"bitcoind", "bitcoin", true},    // reverse contains
		{"unrelated", "bitcoind", false}, // no overlap
		{"bip300301-enforcer", "bip300301-enforcer", true},
		{"bip300301", "bip300301-enforcer", true}, // truncated
	}
	for _, tt := range tests {
		t.Run(tt.proc+"_vs_"+tt.bin, func(t *testing.T) {
			assert.Equal(t, tt.want, processNameMatches(tt.proc, tt.bin))
		})
	}
}
