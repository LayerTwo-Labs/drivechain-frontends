package netcatalog

import (
	"os"
	"path/filepath"
	"testing"
)

func TestEmbeddedCatalogParses(t *testing.T) {
	c, fromDisk := Load(t.TempDir())
	if fromDisk {
		t.Fatal("empty dir must not report a cached catalog")
	}
	if got := c.DrynetID(); got != "drynet2" {
		t.Errorf("embedded DrynetID() = %q, want drynet2", got)
	}
	if _, ok := c.ByFamily(FamilyECash); !ok {
		t.Error("embedded catalog must carry an ecash network")
	}
}

// The cache is the baseline for detecting a generation change, so a round trip
// must preserve the id and report that it came from disk.
func TestSaveThenLoadReportsFromDisk(t *testing.T) {
	dir := t.TempDir()
	saved, _ := Load(dir)
	saved.Networks[len(saved.Networks)-1].ID = "drynet3"
	if err := Save(dir, saved); err != nil {
		t.Fatalf("Save: %v", err)
	}

	got, fromDisk := Load(dir)
	if !fromDisk {
		t.Fatal("Load must report a catalog written by Save as coming from disk")
	}
	if got.DrynetID() != "drynet3" {
		t.Errorf("DrynetID() = %q, want drynet3", got.DrynetID())
	}
}

// A corrupt cache must fall back to the embedded copy rather than surfacing a
// half-written file — and must not claim to be from disk, which would let it
// act as a wipe baseline.
func TestCorruptCacheFallsBackToEmbedded(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, cacheFilename), []byte("{not json"), 0o644); err != nil {
		t.Fatal(err)
	}
	c, fromDisk := Load(dir)
	if fromDisk {
		t.Error("corrupt cache must not report as from disk")
	}
	if c.DrynetID() != "drynet2" {
		t.Errorf("DrynetID() = %q, want the embedded drynet2", c.DrynetID())
	}
}

func TestParseRejectsUnusableDocuments(t *testing.T) {
	for name, raw := range map[string]string{
		"not json":          "{",
		"no schema_version": `{"networks":[{"id":"a","family":"b"}]}`,
		"no networks":       `{"schema_version":1,"networks":[]}`,
		"missing family":    `{"schema_version":1,"networks":[{"id":"a"}]}`,
	} {
		if _, err := parse([]byte(raw)); err == nil {
			t.Errorf("%s: expected an error", name)
		}
	}
}

func TestBackendURLPicksLowestPriority(t *testing.T) {
	n := Network{Backends: []Backend{
		{Kind: "esplora", URL: "second", Priority: 2},
		{Kind: "esplora", URL: "first", Priority: 1},
		{Kind: "electrum", URL: "electrum", Priority: 1},
	}}
	if got := n.BackendURL("esplora"); got != "first" {
		t.Errorf("BackendURL(esplora) = %q, want first", got)
	}
	if got := n.BackendURL("electrum"); got != "electrum" {
		t.Errorf("BackendURL(electrum) = %q, want electrum", got)
	}
	if got := n.BackendURL("nope"); got != "" {
		t.Errorf("BackendURL(nope) = %q, want empty", got)
	}
}
