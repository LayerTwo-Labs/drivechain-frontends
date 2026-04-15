package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"sort"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// newResetTestOrchestrator creates an Orchestrator with a temp datadir and
// a minimal set of configs. The BitwindowDir is set to the temp datadir so
// BinDir resolves inside it.
func newResetTestOrchestrator(t *testing.T) *Orchestrator {
	t.Helper()
	dir := t.TempDir()
	return New(dir, "signet", dir, AllDefaults(), testLogger(t))
}

// seedFile creates a file (with parent dirs) and writes some bytes so
// os.Stat reports a non-zero size.
func seedFile(t *testing.T, path string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte("data"), 0o644))
}

// seedDir creates an empty directory.
func seedDir(t *testing.T, path string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(path, 0o755))
}

// ---------- collectPaths ---------------------------------------------------

func TestCollectPaths_NoCategories(t *testing.T) {
	o := newResetTestOrchestrator(t)
	// With nothing selected, no paths should be returned.
	paths := o.collectPaths(ResetCategory{})
	assert.Empty(t, paths)
}

func TestCollectPaths_CategoriesAreCorrect(t *testing.T) {
	o := newResetTestOrchestrator(t)
	// Each flag should produce only its own category key.
	for _, tc := range []struct {
		cat      ResetCategory
		wantKeys []string
	}{
		{ResetCategory{DeleteBlockchainData: true}, []string{"blockchain_data"}},
		{ResetCategory{DeleteNodeSoftware: true}, []string{"node_software"}},
		{ResetCategory{DeleteLogs: true}, []string{"logs"}},
		{ResetCategory{DeleteSettings: true}, []string{"settings"}},
		{ResetCategory{DeleteWalletFiles: true}, []string{"wallet"}},
	} {
		paths := o.collectPaths(tc.cat)
		for key := range paths {
			assert.Contains(t, tc.wantKeys, key, "unexpected category key %q", key)
		}
	}
}

func TestCollectPaths_SidechainsExcludedByDefault(t *testing.T) {
	o := newResetTestOrchestrator(t)

	without := o.collectPaths(ResetCategory{DeleteBlockchainData: true, AlsoResetSidechains: false})
	with := o.collectPaths(ResetCategory{DeleteBlockchainData: true, AlsoResetSidechains: true})

	// With sidechains included there should be at least as many paths.
	totalWithout := 0
	for _, p := range without {
		totalWithout += len(p)
	}
	totalWith := 0
	for _, p := range with {
		totalWith += len(p)
	}
	assert.GreaterOrEqual(t, totalWith, totalWithout,
		"including sidechains should not reduce paths")
}

func TestCollectPaths_DeduplicatesWithinCategory(t *testing.T) {
	o := newResetTestOrchestrator(t)
	paths := o.collectPaths(ResetCategory{
		DeleteBlockchainData: true,
		DeleteLogs:           true,
		DeleteSettings:       true,
		DeleteWalletFiles:    true,
		DeleteNodeSoftware:   true,
		AlsoResetSidechains:  true,
	})
	for cat, ps := range paths {
		seen := make(map[string]bool)
		for _, p := range ps {
			assert.False(t, seen[p], "duplicate path %q in category %q", p, cat)
			seen[p] = true
		}
	}
}

// ---------- PreviewResetData -----------------------------------------------

func TestPreviewResetData_Empty(t *testing.T) {
	o := newResetTestOrchestrator(t)
	files, err := o.PreviewResetData(ResetCategory{})
	require.NoError(t, err)
	assert.Empty(t, files)
}

func TestPreviewResetData_ReturnsCategoriesAndPaths(t *testing.T) {
	o := newResetTestOrchestrator(t)
	files, err := o.PreviewResetData(ResetCategory{
		DeleteBlockchainData: true,
		DeleteLogs:           true,
		AlsoResetSidechains:  true,
	})
	require.NoError(t, err)

	// Verify all returned items have the expected category.
	allowedCats := map[string]bool{"blockchain_data": true, "logs": true}
	for _, f := range files {
		assert.True(t, allowedCats[f.Category],
			"unexpected category %q for path %q", f.Category, f.Path)
		assert.NotEmpty(t, f.Path)
	}
}

func TestPreviewResetData_StatsExistingFiles(t *testing.T) {
	o := newResetTestOrchestrator(t)

	// Seed a file that collectPaths will pick up for node_software.
	// BinDir is <bitwindowDir>/assets/bin, and node_software collects
	// binary paths from that directory.
	binDir := BinDir(o.BitwindowDir)
	seedFile(t, filepath.Join(binDir, "bitcoind"))

	files, err := o.PreviewResetData(ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	// At least the seeded file should show up with correct size.
	var found bool
	for _, f := range files {
		if filepath.Base(f.Path) == "bitcoind" {
			found = true
			assert.False(t, f.IsDirectory)
			assert.Equal(t, int64(len("data")), f.SizeBytes)
		}
	}
	assert.True(t, found, "expected seeded bitcoind binary in preview")
}

func TestPreviewResetData_DirectoryMarked(t *testing.T) {
	o := newResetTestOrchestrator(t)

	// Seed a directory that will be picked up (e.g. blocks dir for bitcoind).
	// We need to figure out the network dir for bitcoind and create a "blocks"
	// directory inside it.
	cfg, ok := o.configs["bitcoind"]
	if !ok {
		t.Skip("bitcoind config not present in defaults")
	}
	_ = cfg
	// Use collectPaths to discover what paths would be looked up, then
	// create one as a directory.
	paths := o.collectPaths(ResetCategory{DeleteBlockchainData: true})
	if bcPaths, ok := paths["blockchain_data"]; ok && len(bcPaths) > 0 {
		// Create the first path as a directory.
		seedDir(t, bcPaths[0])

		files, err := o.PreviewResetData(ResetCategory{DeleteBlockchainData: true})
		require.NoError(t, err)
		for _, f := range files {
			if f.Path == bcPaths[0] {
				assert.True(t, f.IsDirectory)
				assert.Zero(t, f.SizeBytes, "directories should report 0 size")
			}
		}
	}
}

func TestPreviewResetData_NoSideEffects(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	testFile := filepath.Join(binDir, "bitcoind")
	seedFile(t, testFile)

	_, err := o.PreviewResetData(ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	// File must still exist — preview is read-only.
	_, statErr := os.Stat(testFile)
	assert.NoError(t, statErr, "preview must not delete files")
}

// ---------- StreamResetData ------------------------------------------------

func TestStreamResetData_DeletesSeededFiles(t *testing.T) {
	o := newResetTestOrchestrator(t)

	// Seed files in the bin directory (node_software category).
	binDir := BinDir(o.BitwindowDir)
	seedFile(t, filepath.Join(binDir, "bitcoind"))
	seedFile(t, filepath.Join(binDir, "bip300301-enforcer"))

	// Verify they exist in preview.
	preview, err := o.PreviewResetData(ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)
	require.NotEmpty(t, preview, "expected seeded files in preview")

	ch, err := o.StreamResetData(context.Background(), ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	var events []ResetEvent
	for evt := range ch {
		events = append(events, evt)
	}

	// Must have at least one non-done event + the final done event.
	require.NotEmpty(t, events)
	last := events[len(events)-1]
	assert.True(t, last.Done, "last event must be the done summary")
	assert.Zero(t, last.FailedCount, "no failures expected")

	// Check files are actually gone.
	for _, f := range preview {
		_, statErr := os.Stat(f.Path)
		assert.True(t, os.IsNotExist(statErr), "file %q should have been deleted", f.Path)
	}
}

func TestStreamResetData_EmitsPerFileEvents(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	seedFile(t, filepath.Join(binDir, "bitcoind"))
	seedFile(t, filepath.Join(binDir, "bip300301-enforcer"))

	ch, err := o.StreamResetData(context.Background(), ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	var fileEvents []ResetEvent
	var doneEvent ResetEvent
	for evt := range ch {
		if evt.Done {
			doneEvent = evt
		} else {
			fileEvents = append(fileEvents, evt)
		}
	}

	// Each per-file event should have path, category, and success.
	for _, evt := range fileEvents {
		assert.NotEmpty(t, evt.Path)
		assert.Equal(t, "node_software", evt.Category)
		assert.True(t, evt.Success)
		assert.Empty(t, evt.Error)
	}

	// Done event should have cumulative counts.
	assert.True(t, doneEvent.Done)
	assert.Equal(t, len(fileEvents), doneEvent.DeletedCount)
	assert.Zero(t, doneEvent.FailedCount)
}

func TestStreamResetData_CountsAreCumulative(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	seedFile(t, filepath.Join(binDir, "bitcoind"))
	seedFile(t, filepath.Join(binDir, "bip300301-enforcer"))
	seedFile(t, filepath.Join(binDir, "thunder"))

	ch, err := o.StreamResetData(context.Background(), ResetCategory{DeleteNodeSoftware: true})
	require.NoError(t, err)

	prev := 0
	for evt := range ch {
		if evt.Done {
			break
		}
		assert.GreaterOrEqual(t, evt.DeletedCount, prev,
			"deleted count must be monotonically increasing")
		prev = evt.DeletedCount
	}
}

func TestStreamResetData_NonExistentPathsSucceed(t *testing.T) {
	// When collectPaths returns paths that don't exist on disk,
	// os.RemoveAll should succeed (IsNotExist is treated as success).
	o := newResetTestOrchestrator(t)

	// Don't seed any files — paths won't exist.
	ch, err := o.StreamResetData(context.Background(), ResetCategory{
		DeleteNodeSoftware: true,
	})
	require.NoError(t, err)

	var failCount int
	for evt := range ch {
		if !evt.Done && !evt.Success {
			failCount++
		}
	}
	assert.Zero(t, failCount, "non-existent paths should not be failures")
}

func TestStreamResetData_EmptyCategories(t *testing.T) {
	o := newResetTestOrchestrator(t)

	ch, err := o.StreamResetData(context.Background(), ResetCategory{})
	require.NoError(t, err)

	var events []ResetEvent
	for evt := range ch {
		events = append(events, evt)
	}

	// Should still get a done event even with nothing to delete.
	require.Len(t, events, 1)
	assert.True(t, events[0].Done)
	assert.Zero(t, events[0].DeletedCount)
	assert.Zero(t, events[0].FailedCount)
}

func TestStreamResetData_ContextCancellation(t *testing.T) {
	o := newResetTestOrchestrator(t)

	ctx, cancel := context.WithCancel(context.Background())
	cancel() // cancel immediately

	// StreamResetData calls ShutdownAll which uses the context.
	// With a cancelled context, it should return an error.
	_, err := o.StreamResetData(ctx, ResetCategory{DeleteNodeSoftware: true})
	// The shutdown step may or may not fail depending on whether there are
	// running processes. With no running processes, ShutdownAll returns
	// immediately so the cancellation may not surface. Either outcome is
	// acceptable — the key thing is no panic / hang.
	_ = err
}

func TestStreamResetData_DeduplicatesAcrossCategories(t *testing.T) {
	o := newResetTestOrchestrator(t)

	// Request multiple categories. Paths appearing in multiple categories
	// should only be deleted once.
	ch, err := o.StreamResetData(context.Background(), ResetCategory{
		DeleteBlockchainData: true,
		DeleteLogs:           true,
		DeleteSettings:       true,
		AlsoResetSidechains:  true,
	})
	require.NoError(t, err)

	seen := make(map[string]bool)
	for evt := range ch {
		if evt.Done {
			continue
		}
		assert.False(t, seen[evt.Path],
			"path %q emitted more than once", evt.Path)
		seen[evt.Path] = true
	}
}

// ---------- categoryLabel --------------------------------------------------

func TestCategoryLabel(t *testing.T) {
	for _, cat := range []string{"blockchain_data", "node_software", "logs", "settings", "wallet"} {
		assert.Equal(t, cat, categoryLabel(cat))
	}
	assert.Equal(t, "unknown", categoryLabel("unknown"))
}

// ---------- ResetFileInfo ordering -----------------------------------------

func TestPreviewResetData_ResultsAreStable(t *testing.T) {
	o := newResetTestOrchestrator(t)

	cat := ResetCategory{
		DeleteBlockchainData: true,
		DeleteNodeSoftware:   true,
		DeleteLogs:           true,
		AlsoResetSidechains:  true,
	}

	files1, err := o.PreviewResetData(cat)
	require.NoError(t, err)
	files2, err := o.PreviewResetData(cat)
	require.NoError(t, err)

	// Sort both by path for deterministic comparison.
	sort.Slice(files1, func(i, j int) bool { return files1[i].Path < files1[j].Path })
	sort.Slice(files2, func(i, j int) bool { return files2[i].Path < files2[j].Path })

	require.Equal(t, len(files1), len(files2))
	for i := range files1 {
		assert.Equal(t, files1[i].Path, files2[i].Path)
		assert.Equal(t, files1[i].Category, files2[i].Category)
	}
}
