package orchestrator

import "testing"

// A light install runs no thunder binary. The frontend asks nothing of a chain
// it reads as unreachable, so the balance would stay empty for good.
func TestStatusReadsALightChainAsReachable(t *testing.T) {
	o := newTestOrchestrator(t)

	before := o.Status("thunder")
	if before.Connected {
		t.Fatal("a stopped binary with no index reads as connected")
	}

	o.SetReachableWithoutNode(func(name string) bool { return name == "thunder" })

	after := o.Status("thunder")
	if !after.Connected {
		t.Error("a chain a light install reads through an index must read as connected")
	}
	if !after.Healthy {
		t.Error("a reachable chain must read as healthy")
	}
	// No process runs, and nothing may claim one does.
	if after.Running {
		t.Error("a light chain must not read as running")
	}
}

// A chain a light install does not serve keeps the state its monitor reports.
func TestStatusLeavesAnotherChainAlone(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SetReachableWithoutNode(func(name string) bool { return name == "thunder" })

	if o.Status("bitnames").Connected {
		t.Error("bitnames reads as connected, and no light mode serves it")
	}
}
