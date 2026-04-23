//go:build windows

// Windows-specific reset integration tests. The bug these guard against:
// StreamResetData on Windows only deletes a fraction of the files it
// collected (user-reported "only 12 files deleted") because
//   (a) force-killed daemons still hold file locks on bitcoind's blocks/
//       chainstate/ dirs when os.RemoveAll runs, and
//   (b) the current StreamResetData uses a bare os.RemoveAll with no retry,
//       so the first ERROR_SHARING_VIOLATION on a locked file aborts that
//       path's subtree and leaves files behind.
//
// Tests seed a realistic, node_software-shaped datadir tree, then assert
// the stream deletes every path it promised to — in both the clean case
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

func TestWindowsReset_DeletesAllSeededBinaries(t *testing.T) {
	o := newResetTestOrchestrator(t)
	seeded := seedNodeSoftwareTree(t, o)

	ch, err := o.StreamResetData(context.Background(),
		ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	var events []ResetEvent
	for evt := range ch {
		events = append(events, evt)
	}
	require.NotEmpty(t, events)
	done := events[len(events)-1]
	require.True(t, done.Done)

	// "Only 12 files deleted" regression: every seeded file MUST be in
	// the success count, not the failure count.
	assert.Zero(t, done.FailedCount,
		"reset reported %d failures — Windows file locks are leaking through os.RemoveAll",
		done.FailedCount)
	assert.GreaterOrEqual(t, done.DeletedCount, len(seeded),
		"DeletedCount=%d but seeded %d files — reset gave up partway",
		done.DeletedCount, len(seeded))

	// Ground-truth check: nothing survives on disk.
	for _, p := range seeded {
		_, err := os.Stat(p)
		assert.True(t, os.IsNotExist(err), "seeded file %s survived StreamResetData", p)
	}
}

// TestWindowsReset_SurvivesBrieflyHeldFileHandle is a direct repro of
// the Windows shutdown race: bitcoind releases its handle on a file
// several hundred ms after taskkill /F returns. If reset runs inside
// that window, os.RemoveAll fails with ERROR_SHARING_VIOLATION.
//
// A correct implementation retries on transient sharing violations
// (same pattern as DeleteFilesWithRetry in config/binaries.go). The
// current reset.go does not retry — this test is the failing
// reproducer that tracks the gap.
func TestWindowsReset_SurvivesBrieflyHeldFileHandle(t *testing.T) {
	o := newResetTestOrchestrator(t)
	seeded := seedNodeSoftwareTree(t, o)

	// Open one seeded file exclusively for ~1s to mimic a lingering
	// daemon handle. Windows refuses deletion while the handle is live.
	locked := seeded[0]
	f, err := os.Open(locked)
	require.NoError(t, err)
	released := make(chan struct{})
	go func() {
		time.Sleep(1 * time.Second)
		_ = f.Close()
		close(released)
	}()

	ch, err := o.StreamResetData(context.Background(),
		ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	var done ResetEvent
	for evt := range ch {
		if evt.Done {
			done = evt
		}
	}
	<-released

	if _, statErr := os.Stat(locked); !os.IsNotExist(statErr) {
		t.Errorf("locked file %s survived StreamResetData — sharing violation leaked without retry (done=%+v)",
			locked, done)
	}
}

// TestWindowsReset_CountsMatchPreview catches the desync the user
// reported: preview says N files but only 12 are actually deleted. The
// preview and the deletion stream must walk the same entries; if they
// drift, the UI progress bar is lying.
func TestWindowsReset_CountsMatchPreview(t *testing.T) {
	o := newResetTestOrchestrator(t)
	seedNodeSoftwareTree(t, o)

	cat := ResetCategory{DeleteNodeSoftware: true}
	preview, err := o.PreviewResetData(cat)
	require.NoError(t, err)
	require.NotEmpty(t, preview)

	ch, err := o.StreamResetData(context.Background(), cat)
	require.NoError(t, err)

	var done ResetEvent
	for evt := range ch {
		if evt.Done {
			done = evt
		}
	}

	assert.Equal(t, len(preview), done.DeletedCount+done.FailedCount,
		"preview promised %d paths but stream accounted for %d (deleted=%d failed=%d)",
		len(preview), done.DeletedCount+done.FailedCount,
		done.DeletedCount, done.FailedCount)
	assert.Zero(t, done.FailedCount,
		"reset must delete every promised path on Windows; got %d failures", done.FailedCount)
}
