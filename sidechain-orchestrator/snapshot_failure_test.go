package orchestrator

import (
	"errors"
	"testing"
)

// A snapshot the user asked for must fail loudly: the streaming handler only
// turns StartupProgress.Error into an RPC error, so without it the UI reaches
// end-of-stream and reports success for a snapshot that never loaded.
func TestRequestedSnapshotFailureCarriesTheError(t *testing.T) {
	o := &Orchestrator{}
	cause := errors.New("download failed")

	got := o.snapshotFailure(SnapshotSource{Requested: true}, "unavailable", cause)
	if got.Error == nil {
		t.Error("a requested snapshot failure must carry the error")
	}

	// The automatic drynet snapshot falls back to a normal sync, which is a
	// fine outcome and not something to report as a failure.
	got = o.snapshotFailure(SnapshotSource{}, "unavailable", cause)
	if got.Error != nil {
		t.Errorf("automatic snapshot failure must stay non-fatal, got %v", got.Error)
	}
	if got.Message == "" {
		t.Error("the message should still be reported")
	}
}
