package orchestrator

import "testing"

// A light install runs no sidechain daemon. Every slot then carries "not
// running", and the window used to print the mainchain height instead.
func TestLightModeFillsSidechainHeightFromTheIndex(t *testing.T) {
	sidechains := map[string]*ChainSyncResult{
		"thunder":  {Error: "not running"},
		"bitnames": {Error: "not running"},
	}
	applyIndexHeights(sidechains, map[string]int64{"thunder": 20}, true)

	thunder := sidechains["thunder"]
	if thunder.Error != "" {
		t.Errorf("error = %q, want empty", thunder.Error)
	}
	if thunder.Blocks != 20 || thunder.Headers != 20 {
		t.Errorf("blocks/headers = %d/%d, want 20/20", thunder.Blocks, thunder.Headers)
	}
	// A chain with no index keeps what it reported.
	if sidechains["bitnames"].Error != "not running" {
		t.Errorf("bitnames error = %q, want not running", sidechains["bitnames"].Error)
	}
}

// A full install runs the daemon, and the daemon owns the block count. The
// index names the goal only, so a stopped daemon stays stopped.
func TestFullModeKeepsTheDaemonBlockCount(t *testing.T) {
	sidechains := map[string]*ChainSyncResult{
		"thunder": {Blocks: 18},
		"zside":   {Error: "not running"},
	}
	applyIndexHeights(sidechains, map[string]int64{"thunder": 20, "zside": 5}, false)

	if got := sidechains["thunder"]; got.Blocks != 18 || got.Headers != 20 {
		t.Errorf("blocks/headers = %d/%d, want 18/20", got.Blocks, got.Headers)
	}
	if sidechains["zside"].Error != "not running" {
		t.Errorf("zside error = %q, want not running", sidechains["zside"].Error)
	}
}
