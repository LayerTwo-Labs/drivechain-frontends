//go:build windows

// Windows-specific reset integration tests. The bug these guard against:
// a reset on Windows only deletes a fraction of the files it collected
// (user-reported "only 12 files deleted") because force-killed daemons still
// hold file locks on bitcoind's blocks/ chainstate/ dirs when os.RemoveAll
// runs. DeleteFiles waits postKillFileLockGrace after shutdown before removing
// so those handles are released first.
//
// Tests seed a realistic, node_software-shaped datadir tree, then assert the
// delete stream removes every path gather promised — in both the clean case
// and the "a handle was held briefly" case.

package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// seedNodeSoftwareTree writes one .exe stub per configured binary into
// <bitwindowDir>/assets/bin so GetBinaryPaths picks them up. Returns the
// absolute paths of every file written.
func seedNodeSoftwareTree(t *testing.T, o *Orchestrator) []string {
	t.Helper()
	binDir := BinDir(o.BitwindowDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))

	seeded := []string{}
	for _, cfg := range o.Configs() {
		if cfg.BinaryName == "" {
			continue
		}
		p := filepath.Join(binDir, cfg.BinaryName+".exe")
		require.NoError(t, os.WriteFile(p, []byte("stub exe"), 0o644))
		seeded = append(seeded, p)
	}
	require.NotEmpty(t, seeded, "expected to seed at least one binary")
	return seeded
}

// gatherNodeSoftware resolves the node_software paths for every configured
// binary — the same selection a "delete node software" reset sends.
func gatherNodeSoftware(t *testing.T, o *Orchestrator) []string {
	t.Helper()
	var specs []GatherSpec
	for _, cfg := range o.Configs() {
		if cfg.BinaryName == "" {
			continue
		}
		specs = append(specs, GatherSpec{BinaryName: cfg.Name, Categories: []string{catSoftware}})
	}
	files, err := o.GatherFilesToDelete(specs)
	require.NoError(t, err)
	paths := make([]string, 0, len(files))
	for _, f := range files {
		paths = append(paths, f.Path)
	}
	return paths
}

// runDelete drives DeleteFiles to completion and tallies the per-path events.
func runDelete(t *testing.T, o *Orchestrator, paths []string) (deleted, failed int) {
	t.Helper()
	ch, err := o.DeleteFiles(context.Background(), paths)
	require.NoError(t, err)
	for evt := range ch {
		if evt.Error == "" {
			deleted++
		} else {
			failed++
		}
	}
	return deleted, failed
}

func TestWindowsReset_DeletesAllSeededBinaries(t *testing.T) {
	o := newResetTestOrchestrator(t)
	seeded := seedNodeSoftwareTree(t, o)

	deleted, failed := runDelete(t, o, gatherNodeSoftware(t, o))

	// "Only 12 files deleted" regression: every seeded file MUST succeed,
	// none may leak through as a failure.
	assert.Zero(t, failed,
		"reset reported %d failures — Windows file locks are leaking through os.RemoveAll", failed)
	assert.GreaterOrEqual(t, deleted, len(seeded),
		"deleted=%d but seeded %d files — reset gave up partway", deleted, len(seeded))

	// Ground-truth check: nothing survives on disk.
	for _, p := range seeded {
		_, err := os.Stat(p)
		assert.True(t, os.IsNotExist(err), "seeded file %s survived DeleteFiles", p)
	}
}

// TestWindowsReset_SurvivesBrieflyHeldFileHandle is a direct repro of the
// Windows shutdown race: bitcoind releases its handle several hundred ms after
// taskkill /F returns. DeleteFiles waits postKillFileLockGrace (5s) after
// shutdown before removing, which must outlast such a transient handle.
func TestWindowsReset_SurvivesBrieflyHeldFileHandle(t *testing.T) {
	o := newResetTestOrchestrator(t)
	seeded := seedNodeSoftwareTree(t, o)

	// Open one seeded file exclusively for ~1s to mimic a lingering daemon
	// handle. Windows refuses deletion while the handle is live.
	locked := seeded[0]
	f, err := os.Open(locked)
	require.NoError(t, err)
	released := make(chan struct{})
	go func() {
		time.Sleep(1 * time.Second)
		_ = f.Close()
		close(released)
	}()

	_, failed := runDelete(t, o, gatherNodeSoftware(t, o))
	<-released

	assert.Zero(t, failed, "a briefly-held handle leaked a failure past the post-kill grace")
	if _, statErr := os.Stat(locked); !os.IsNotExist(statErr) {
		t.Errorf("locked file %s survived DeleteFiles — sharing violation leaked through the grace window", locked)
	}
}

// TestWindowsReset_CountsMatchGather catches the desync the user reported:
// gather says N files but only 12 are actually deleted. Gather and the delete
// stream must walk the same entries; if they drift, the UI progress is lying.
func TestWindowsReset_CountsMatchGather(t *testing.T) {
	o := newResetTestOrchestrator(t)
	seedNodeSoftwareTree(t, o)

	paths := gatherNodeSoftware(t, o)
	require.NotEmpty(t, paths)

	deleted, failed := runDelete(t, o, paths)

	assert.Equal(t, len(paths), deleted+failed,
		"gather promised %d paths but stream accounted for %d (deleted=%d failed=%d)",
		len(paths), deleted+failed, deleted, failed)
	assert.Zero(t, failed, "reset must delete every promised path on Windows; got %d failures", failed)
}
