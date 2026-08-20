package orchestrator

import (
	"context"
	"testing"
)

// An unchanged generation is not a reason to hold back the catalog.
func TestWipeGateAllowsUnchangedGeneration(t *testing.T) {
	o := &Orchestrator{}
	for _, tc := range []struct{ old, new string }{
		{"drynet2", "drynet2"}, {"", "drynet2"}, {"drynet2", ""},
	} {
		if !o.wipeOnECashNetworkChange(context.Background(), tc.old, tc.new) {
			t.Errorf("wipeOnECashNetworkChange(%q, %q) = false, want true", tc.old, tc.new)
		}
	}
}

// A real generation change with no usable config must not let the catalog move
// on, so the next boot retries the wipe before Core starts.
func TestWipeGateHoldsBackWhenConfigMissing(t *testing.T) {
	o := &Orchestrator{}
	if o.wipeOnECashNetworkChange(context.Background(), "drynet2", "drynet3") {
		t.Error("expected the catalog to be held back when the wipe cannot run")
	}
}
