package orchestrator

import "testing"

// An unchanged generation is not a reason to hold back the catalog.
func TestRewindGateAllowsUnchangedGeneration(t *testing.T) {
	o := &Orchestrator{}
	for _, tc := range []struct{ old, new string }{
		{"drynet2", "drynet2"}, {"", "drynet2"}, {"drynet2", ""},
	} {
		if !o.ecashChangeHasASharedBlock(tc.old, tc.new) {
			t.Errorf("ecashChangeHasASharedBlock(%q, %q) = false, want true", tc.old, tc.new)
		}
	}
}

// A real generation change with no usable config must not let the catalog move
// on: the chain on disk still belongs to the network the conf names.
func TestRewindGateHoldsBackWhenConfigMissing(t *testing.T) {
	o := &Orchestrator{}
	if o.ecashChangeHasASharedBlock("drynet2", "drynet3") {
		t.Error("expected the catalog to be held back when the rewind cannot run")
	}
}
