package netcatalog

import (
	"os"
	"path/filepath"
	"testing"
)

// embeddedGeneration is the eCash network networks.json ships with. Change it
// whenever the embedded catalog is refreshed from the published document.
const embeddedGeneration = "alphanet"

func TestEmbeddedCatalogParses(t *testing.T) {
	c := Embedded()
	if got := c.ECashID(); got != embeddedGeneration {
		t.Errorf("embedded ECashID() = %q, want %s", got, embeddedGeneration)
	}
	if _, ok := c.ByFamily(FamilyECash); !ok {
		t.Error("embedded catalog must carry an ecash network")
	}
}

// Every eCash network seeds on its own port, so the embedded document must
// carry the peer — inventing one from the id is what wrote drynet4 with :8335.
func TestEmbeddedCatalogPublishesPeers(t *testing.T) {
	if got := EmbeddedPeer(embeddedGeneration); got == "" {
		t.Errorf("EmbeddedPeer(%s) is empty, want the published seed address", embeddedGeneration)
	}
}

// The live eCash network comes first and the retired ones after it, and the id
// carries no ordering, so document order decides.
func TestECashIDTakesTheFirstECashEntry(t *testing.T) {
	c := Catalog{Networks: []Network{
		{ID: "bitcoin", Family: "bitcoin"},
		{ID: "alphanet", Family: FamilyECash},
		{ID: "drynet4", Family: FamilyECash},
	}}
	if got := c.ECashID(); got != "alphanet" {
		t.Errorf("ECashID() = %q, want alphanet", got)
	}
}

// The endpoints ride along in the document, so a free-form id never has to be
// turned back into a hostname.
func TestEmbeddedECashPublishesEndpoints(t *testing.T) {
	n := EmbeddedECash()
	if n.ID != embeddedGeneration {
		t.Fatalf("EmbeddedECash().ID = %q, want %s", n.ID, embeddedGeneration)
	}
	if got := n.BackendURL("esplora"); got == "" {
		t.Error("embedded eCash entry must publish an esplora backend")
	}
	if got := n.ExplorerHost(); got == "" {
		t.Error("embedded eCash entry must publish an explorer host")
	}
}

func TestECashIDEmptyWithoutECash(t *testing.T) {
	c := Catalog{Networks: []Network{{ID: "bitcoin", Family: "bitcoin"}}}
	if got := c.ECashID(); got != "" {
		t.Errorf("ECashID() = %q, want empty", got)
	}
}

// An older build kept the document on disk. Those files decide nothing now, so
// a start deletes them rather than leaving a stale document to read.
func TestRemoveLegacyFilesClearsBothCopies(t *testing.T) {
	dir := t.TempDir()
	for _, name := range []string{cacheFilename, pendingFilename} {
		if err := os.WriteFile(filepath.Join(dir, name), []byte("{}"), 0o644); err != nil {
			t.Fatal(err)
		}
	}

	RemoveLegacyFiles(dir)

	for _, name := range []string{cacheFilename, pendingFilename} {
		if _, err := os.Stat(filepath.Join(dir, name)); !os.IsNotExist(err) {
			t.Errorf("%s must be gone, stat returned %v", name, err)
		}
	}
}

// The picker lists every entry and the endpoints come from their backends, so a
// refresh that adds a network or moves a host must not read as unchanged.
func TestSameAsSeesEveryEntry(t *testing.T) {
	base := Catalog{SchemaVersion: 1, Networks: []Network{
		{ID: "alphanet", Family: FamilyECash},
	}}
	if !base.SameAs(base) {
		t.Error("a catalog must match itself")
	}

	added := Catalog{SchemaVersion: 1, Networks: []Network{
		{ID: "alphanet", Family: FamilyECash},
		{ID: "drynet4", Family: FamilyECash},
	}}
	if base.SameAs(added) {
		t.Error("an added network must not read as unchanged")
	}

	moved := Catalog{SchemaVersion: 1, Networks: []Network{
		{ID: "alphanet", Family: FamilyECash, Backends: []Backend{{Kind: "esplora", URL: "https://new.example"}}},
	}}
	if base.SameAs(moved) {
		t.Error("a moved endpoint must not read as unchanged")
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
