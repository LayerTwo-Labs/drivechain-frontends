package api

import (
	"testing"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/stretchr/testify/assert"
)

// deletablePaths must be subtractive only: it drops deselected paths and can
// never introduce a path that gather didn't produce. This is the guard that
// stops DeleteFiles from ever os.RemoveAll'ing a client-supplied path outside
// the gather set.
func TestDeletablePaths_ExceptIsSubtractiveOnly(t *testing.T) {
	files := []orchestrator.ResetFileInfo{{Path: "/a"}, {Path: "/b"}, {Path: "/c"}}

	// "/b" is a real deselection; "/evil" is a path the client invented that
	// gather never returned — it must be ignored, not deleted.
	got := deletablePaths(files, []string{"/b", "/evil"})

	assert.ElementsMatch(t, []string{"/a", "/c"}, got)
	assert.NotContains(t, got, "/evil", "a path outside the gather set must never be deletable")
}

func TestDeletablePaths_EmptyExceptKeepsAll(t *testing.T) {
	files := []orchestrator.ResetFileInfo{{Path: "/a"}, {Path: "/b"}}
	got := deletablePaths(files, nil)
	assert.ElementsMatch(t, []string{"/a", "/b"}, got)
}
