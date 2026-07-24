package orchestrator

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// The active network maps to its catalog entry, whose assumeutxo drives the
// automatic load. Drynet matches by family; the rest by id.
func TestCatalogEntryForNetwork(t *testing.T) {
	// The newest ecash generation wins, whatever it is called and whatever order
	// the catalog lists it in. The higher-numbered entry carries Height 99.
	const newestHeight = 99
	cat := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin"},
		{ID: "signet", Family: "bitcoin"},
		{ID: "drynet9", Family: netcatalog.FamilyECash, AssumeUTXO: &netcatalog.AssumeUTXO{Height: newestHeight}},
		{ID: "drynet7", Family: netcatalog.FamilyECash, AssumeUTXO: &netcatalog.AssumeUTXO{Height: 7}},
	}}

	if got, ok := catalogEntryForNetwork(cat, config.NetworkMainnet); !ok || got.ID != "bitcoin" {
		t.Errorf("mainnet -> %q (ok=%v), want bitcoin", got.ID, ok)
	}
	if got, ok := catalogEntryForNetwork(cat, config.NetworkSignet); !ok || got.ID != "signet" {
		t.Errorf("signet -> %q (ok=%v), want signet", got.ID, ok)
	}
	got, ok := catalogEntryForNetwork(cat, config.NetworkDrynet)
	if !ok || got.AssumeUTXO.Height != newestHeight {
		t.Errorf("drynet -> %+v (ok=%v), want the newest generation", got, ok)
	}
	if _, ok := catalogEntryForNetwork(cat, config.NetworkForknet); ok {
		t.Error("forknet has no catalog entry, want not found")
	}
}

func TestSnapshotFileNameFallsBackWhenURLHasNoSegment(t *testing.T) {
	if got := snapshotFileName("https://example.com/utxo-42.dat"); got != "utxo-42.dat" {
		t.Errorf("snapshotFileName = %q, want utxo-42.dat", got)
	}
	if got := snapshotFileName("/"); got != "utxo-snapshot.dat" {
		t.Errorf("snapshotFileName(/) = %q, want the fallback", got)
	}
	// A presigned or cache-busted URL carries a query string that would be an
	// invalid filename on Windows; only the path segment may reach disk.
	if got := snapshotFileName("https://example.com/utxo-42.dat?X-Amz-Signature=abc"); got != "utxo-42.dat" {
		t.Errorf("snapshotFileName with query = %q, want utxo-42.dat", got)
	}
}

// The pending snapshot is consumed exactly once: the apply runs on the way back
// up from a restart, and a later restart must not silently re-wipe and reload.
func TestPendingSnapshotIsTakenOnce(t *testing.T) {
	o := &Orchestrator{}
	o.SetPendingSnapshot(&SnapshotSource{Path: "/tmp/utxo.dat"})

	if got := o.takePendingSnapshot(); got == nil || got.Path != "/tmp/utxo.dat" {
		t.Fatalf("first take = %+v, want the pending source", got)
	}
	if got := o.takePendingSnapshot(); got != nil {
		t.Errorf("second take = %+v, want nil", got)
	}
}

func TestApplyUserSnapshotRejectsEmptySource(t *testing.T) {
	o := &Orchestrator{}
	if _, err := o.ApplyUserSnapshot(t.Context(), SnapshotSource{}); err == nil {
		t.Error("expected an error when neither URL nor Path is set")
	}
}

func TestApplyUserSnapshotRejectsMissingFile(t *testing.T) {
	o := &Orchestrator{}
	_, err := o.ApplyUserSnapshot(t.Context(), SnapshotSource{Path: "/definitely/not/here.dat"})
	if err == nil {
		t.Error("expected an error for a file that does not exist")
	}
	if o.pendingSnapshot != nil {
		t.Error("a rejected source must not be left pending")
	}
}
