package bmmstate

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTargetsSurviveANewStore(t *testing.T) {
	dir := t.TempDir()
	store := NewStore(dir, 0)
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, WalletID: "spender", MaxBidSats: 5000}))

	reopened := NewStore(dir, 0)
	targets, err := reopened.Targets()
	require.NoError(t, err)
	require.Len(t, targets, 1)
	assert.Equal(t, int32(9), targets[0].Sidechain)
	assert.Equal(t, "spender", targets[0].WalletID)
	assert.Equal(t, int64(5000), targets[0].MaxBidSats)
}

func TestSaveTargetReplacesTheSameSidechain(t *testing.T) {
	store := NewStore(t.TempDir(), 0)
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 1000}))
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 7000, CapToBlockWorth: true}))
	require.NoError(t, store.SaveTarget(Target{Sidechain: 4, MaxBidSats: 2000}))

	targets, err := store.Targets()
	require.NoError(t, err)
	require.Len(t, targets, 2)
	assert.Equal(t, int64(7000), targets[0].MaxBidSats)
	assert.True(t, targets[0].CapToBlockWorth)
}

func TestDeleteTargetDropsOnlyThatSidechain(t *testing.T) {
	store := NewStore(t.TempDir(), 0)
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 1000}))
	require.NoError(t, store.SaveTarget(Target{Sidechain: 4, MaxBidSats: 2000}))
	require.NoError(t, store.DeleteTarget(9))

	targets, err := store.Targets()
	require.NoError(t, err)
	require.Len(t, targets, 1)
	assert.Equal(t, int32(4), targets[0].Sidechain)

	// Deleting what is not there is not an error, and it writes nothing.
	require.NoError(t, store.DeleteTarget(9))
}

// A network swap points the store at another directory. The targets of the
// old network must not follow it.
func TestRebindDropsTheTargets(t *testing.T) {
	first := t.TempDir()
	store := NewStore(first, 0)
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 1000}))

	store.Rebind(t.TempDir())
	targets, err := store.Targets()
	require.NoError(t, err)
	assert.Empty(t, targets)

	// The first network keeps its own file.
	kept, err := NewStore(first, 0).Targets()
	require.NoError(t, err)
	require.Len(t, kept, 1)
}

func TestTargetsAndRoundsUseSeparateFiles(t *testing.T) {
	dir := t.TempDir()
	store := NewStore(dir, 0)
	require.NoError(t, store.Save(Round{Sidechain: 9, PrevMainHash: "block-1"}))
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 1000}))

	for _, name := range []string{fileName, targetsFileName} {
		_, err := os.Stat(filepath.Join(dir, name))
		require.NoError(t, err, "%s exists", name)
	}

	rounds, err := store.List(9)
	require.NoError(t, err)
	require.Len(t, rounds, 1)
}

// A failed write leaves the file as it was. The cache must agree, or a second
// call finds nothing to delete and answers success while the target stands.
func TestDeleteTargetKeepsItsCacheWhenTheWriteFails(t *testing.T) {
	dir := t.TempDir()
	store := NewStore(dir, 0)
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 1000}))

	require.NoError(t, os.RemoveAll(dir))
	require.Error(t, store.DeleteTarget(9))

	targets, err := store.Targets()
	require.NoError(t, err)
	require.Len(t, targets, 1, "the target stands until a write lands")

	require.NoError(t, os.MkdirAll(dir, 0o755))
	require.NoError(t, store.DeleteTarget(9))

	targets, err = store.Targets()
	require.NoError(t, err)
	assert.Empty(t, targets)
}

// The same holds when saving fails: the cache must not claim a target the
// file never took.
func TestSaveTargetKeepsItsCacheWhenTheWriteFails(t *testing.T) {
	dir := t.TempDir()
	store := NewStore(dir, 0)
	require.NoError(t, store.SaveTarget(Target{Sidechain: 9, MaxBidSats: 1000}))

	require.NoError(t, os.RemoveAll(dir))
	require.Error(t, store.SaveTarget(Target{Sidechain: 4, MaxBidSats: 2000}))

	targets, err := store.Targets()
	require.NoError(t, err)
	require.Len(t, targets, 1)
	assert.Equal(t, int32(9), targets[0].Sidechain)
}
