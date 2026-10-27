package netcatalog

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// embeddedGeneration is the eCash network networks.json ships with. Change it
// whenever the embedded catalog is refreshed from the published document.
const embeddedGeneration = "ecash"

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

// The document lists the eCash networks from oldest to newest, and the id
// carries no ordering, so the last eCash entry is the live one.
func TestECashIDTakesTheLastECashEntry(t *testing.T) {
	c := Catalog{Networks: []Network{
		{ID: "bitcoin", Family: "bitcoin"},
		{ID: "drynet4", Family: FamilyECash},
		{ID: "betanet", Family: FamilyECash},
		{ID: "ecash", Family: FamilyECash},
		{ID: "signet", Family: "bitcoin"},
	}}
	if got := c.ECashID(); got != "ecash" {
		t.Errorf("ECashID() = %q, want ecash", got)
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
		{ID: "betanet", Family: FamilyECash},
	}}
	if !base.SameAs(base) {
		t.Error("a catalog must match itself")
	}

	added := Catalog{SchemaVersion: 1, Networks: []Network{
		{ID: "betanet", Family: FamilyECash},
		{ID: "drynet4", Family: FamilyECash},
	}}
	if base.SameAs(added) {
		t.Error("an added network must not read as unchanged")
	}

	moved := Catalog{SchemaVersion: 1, Networks: []Network{
		{ID: "betanet", Family: FamilyECash, Backends: []Backend{{Kind: "esplora", URL: "https://new.example"}}},
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

// A published document can drop fork_parent_hash from an entry. The migration
// reads that hash, so the compiled-in value fills the gap.
func TestFillForkParentHashTakesTheEmbeddedValue(t *testing.T) {
	embedded := Catalog{Networks: []Network{
		{ID: "betanet", Family: FamilyECash, ForkParentHash: "aa"},
		{ID: "ecash", Family: FamilyECash},
	}}
	fetched := Catalog{Networks: []Network{
		{ID: "betanet", Family: FamilyECash},
		{ID: "ecash", Family: FamilyECash},
		{ID: "gammanet", Family: FamilyECash},
	}}

	filled := fillFromEmbedded(fetched, embedded)
	for id, want := range map[string]string{"betanet": "aa", "ecash": "", "gammanet": ""} {
		entry, ok := filled.ByID(id)
		if !ok {
			t.Fatalf("%s left the catalog", id)
		}
		if entry.ForkParentHash != want {
			t.Errorf("%s fork parent hash = %q, want %q", id, entry.ForkParentHash, want)
		}
	}
}

func TestFillFromEmbeddedKeepsThePublishedForkParentHash(t *testing.T) {
	embedded := Catalog{Networks: []Network{{ID: "betanet", Family: FamilyECash, ForkParentHash: "aa"}}}
	fetched := Catalog{Networks: []Network{{ID: "betanet", Family: FamilyECash, ForkParentHash: "bb"}}}

	filled := fillFromEmbedded(fetched, embedded)
	entry, _ := filled.ByID("betanet")
	if entry.ForkParentHash != "bb" {
		t.Errorf("fork parent hash = %q, want the published bb", entry.ForkParentHash)
	}
	if embedded.Networks[0].ForkParentHash != "aa" {
		t.Error("fillFromEmbedded wrote through to the source catalog")
	}
}

// A migration off a retired eCash network rewinds to its fork parent, so the
// embedded document has to carry that hash even when the published one does
// not. The live network can lack it until its fork block exists.
func TestEmbeddedCatalogPublishesTheForkParentHash(t *testing.T) {
	live := EmbeddedECashID()
	for _, entry := range Embedded().Networks {
		if entry.Family != FamilyECash || entry.ID == live {
			continue
		}
		if len(entry.ForkParentHash) != 64 {
			t.Errorf("%s fork parent hash = %q, want 64 hex characters", entry.ID, entry.ForkParentHash)
		}
	}
}

// An install on alphanet can still migrate, so the embedded row keeps what the
// migration reads. The picker does not list it.
func TestEmbeddedAlphanetIsAMigrationSource(t *testing.T) {
	n, ok := Embedded().ByID("alphanet")
	require.True(t, ok)
	require.True(t, n.MigrationOnly)
	require.Equal(t, FamilyECash, n.Family)
	require.Equal(t, "eca5a104", n.NetworkMagic)
	require.Equal(t, 963648, n.ForkHeight)
	require.Len(t, n.ForkParentHash, 64)
	require.Equal(t, "alphanet", n.ReleaseChannelOrID())
	require.NotEmpty(t, n.P2P.Address)
	require.Empty(t, n.Backends)
	require.Nil(t, n.AssumeUTXO)
	require.NotEqual(t, "alphanet", EmbeddedECashID())
}

// The blocks on disk name the chain, so a magic reads back its network.
func TestByMagicNamesTheNetwork(t *testing.T) {
	c := Embedded()
	for _, want := range []string{"betanet", "alphanet", "bitcoin"} {
		entry, ok := c.ByID(want)
		if !ok {
			t.Fatalf("embedded catalog lists no %s", want)
		}
		got, ok := c.ByMagic(entry.NetworkMagic)
		if !ok || got.ID != want {
			t.Errorf("ByMagic(%s) = %q, %v; want %s", entry.NetworkMagic, got.ID, ok, want)
		}
		upper, ok := c.ByMagic(strings.ToUpper(entry.NetworkMagic))
		if !ok || upper.ID != want {
			t.Errorf("ByMagic reads hexadecimal in either case")
		}
	}
	if _, ok := c.ByMagic("00000000"); ok {
		t.Error("a magic no network carries must read as unknown")
	}
	if _, ok := c.ByMagic(""); ok {
		t.Error("an empty magic must read as unknown")
	}
}

func catalogWith(t *testing.T, id, address string) []byte {
	raw, err := json.Marshal(map[string]any{
		"schema_version": 1,
		"networks": []map[string]any{{
			"id":     id,
			"family": FamilyECash,
			"p2p":    map[string]any{"address": address},
		}},
	})
	require.NoError(t, err)
	return raw
}

func TestParseValidatesEntries(t *testing.T) {
	for name, id := range map[string]string{
		"parent path id":  "../x",
		"slash id":        "a/b",
		"upper case id":   "A",
		"newline id":      "alpha\nrpcbind=0.0.0.0",
		"empty id":        "",
		"33 character id": strings.Repeat("a", 33),
	} {
		t.Run(name, func(t *testing.T) {
			_, err := parse(catalogWith(t, id, ""))
			require.ErrorContains(t, err, "parse catalog: network")
		})
	}
	for name, address := range map[string]string{
		"newline address": "1.2.3.4:8301\nrpcallowip=0.0.0.0/0",
		"hash address":    "host #x",
		"equals address":  "a=b",
	} {
		t.Run(name, func(t *testing.T) {
			_, err := parse(catalogWith(t, "betanet", address))
			require.ErrorContains(t, err, "p2p address")
		})
	}
	t.Run("published shape", func(t *testing.T) {
		c, err := parse(catalogWith(t, "betanet", "seed.example.com:8301"))
		require.NoError(t, err)
		require.Equal(t, "seed.example.com:8301", c.Networks[0].P2P.Address)
	})
}

func TestParseReadsTheReplayLockTime(t *testing.T) {
	c, err := parse([]byte(`{"schema_version":1,"networks":[
		{"id":"mainnet","family":"ecash","replay_lock_time":499999998},
		{"id":"betanet","family":"ecash"}
	]}`))
	require.NoError(t, err)
	require.EqualValues(t, 499999998, c.Networks[0].ReplayLockTimeOrDefault())
	require.EqualValues(t, 499999999, c.Networks[1].ReplayLockTimeOrDefault())
}

func TestEmbeddedECashNetworksPublishTheReplayLockTime(t *testing.T) {
	for _, id := range []string{"betanet", "alphanet"} {
		n, ok := Embedded().ByID(id)
		require.True(t, ok, id)
		require.EqualValues(t, 499999999, n.ReplayLockTime, id)
		require.Equal(t, id, n.ReleaseChannel, id)
	}
	n, ok := Embedded().ByID("ecash")
	require.True(t, ok)
	require.EqualValues(t, 499999998, n.ReplayLockTime, "the eCash v1 node takes 499999998")
	require.Equal(t, "mainnet", n.ReleaseChannel)
}

// The document drivechain.dev/config served on 2026-10-26 lists the eCash
// networks oldest first and omits the replay locktime of ecash. Without the
// compiled-in value a send would take 499999999, which the eCash v1 node holds
// non-final.
func TestPublishedCatalogOf20261026TakesEcashWithItsCompiledInValues(t *testing.T) {
	raw, err := os.ReadFile(filepath.Join("testdata", "published-2026-10-26.json"))
	require.NoError(t, err)
	c, err := parse(raw)
	require.NoError(t, err)
	require.Equal(t, "ecash", c.ECashID())
	published, _ := c.ByID("ecash")
	require.Zero(t, published.ReplayLockTime)

	live, ok := fillFromEmbedded(c, Embedded()).CurrentECash()
	require.True(t, ok)
	require.Equal(t, "ecash", live.ID)
	require.EqualValues(t, 499999998, live.ReplayLockTimeOrDefault())
}

func TestFillFromEmbeddedKeepsAlphanetMigrationOnly(t *testing.T) {
	raw, err := os.ReadFile(filepath.Join("testdata", "published-2026-10-19.json"))
	require.NoError(t, err)
	c, err := parse(raw)
	require.NoError(t, err)
	published, ok := c.ByID("alphanet")
	require.True(t, ok)
	require.False(t, published.MigrationOnly)

	filled, _ := fillFromEmbedded(c, Embedded()).ByID("alphanet")
	require.True(t, filled.MigrationOnly)
	betanet, _ := fillFromEmbedded(c, Embedded()).ByID("betanet")
	require.False(t, betanet.MigrationOnly)
}

func TestFillFromEmbeddedKeepsThePublishedLockTime(t *testing.T) {
	embedded := Catalog{Networks: []Network{{ID: "ecash", Family: FamilyECash, ReplayLockTime: 499999998}}}
	fetched := Catalog{Networks: []Network{{ID: "ecash", Family: FamilyECash, ReplayLockTime: 499999997}}}

	entry, _ := fillFromEmbedded(fetched, embedded).ByID("ecash")
	require.EqualValues(t, 499999997, entry.ReplayLockTime)
}

// The document drivechain.dev/config served on 2026-10-19 carries no
// replay_lock_time, so its networks keep the value their nodes accept.
func TestPublishedCatalogWithoutTheFieldKeepsTheDefault(t *testing.T) {
	raw, err := os.ReadFile(filepath.Join("testdata", "published-2026-10-19.json"))
	require.NoError(t, err)
	require.NotContains(t, string(raw), "replay_lock_time")
	c, err := parse(raw)
	require.NoError(t, err)
	for _, id := range []string{"alphanet", "betanet"} {
		n, ok := c.ByID(id)
		require.True(t, ok, id)
		require.EqualValues(t, 499999999, n.ReplayLockTimeOrDefault(), id)
	}
	live, ok := c.CurrentECash()
	require.True(t, ok)
	require.EqualValues(t, 499999999, live.ReplayLockTimeOrDefault())
}

func ecashMainnetCatalog(t *testing.T) Catalog {
	t.Helper()
	raw, err := os.ReadFile(filepath.Join("testdata", "ecash-mainnet.json"))
	require.NoError(t, err)
	c, err := parse(raw)
	require.NoError(t, err)
	return c
}

func TestParseReadsTheECashMainnetRow(t *testing.T) {
	n, ok := ecashMainnetCatalog(t).ByID("ecash-mainnet")
	require.True(t, ok)
	require.Equal(t, FamilyECash, n.Family)
	require.Equal(t, "eCash Mainnet", n.DisplayName)
	require.Equal(t, "main", n.Chain)
	require.Equal(t, "ECX", n.Currency.Ticker)
	require.Equal(t, "eca5dcb7", n.NetworkMagic)
	require.Equal(t, 973728, n.ForkHeight)
	require.EqualValues(t, 499999998, n.ReplayLockTime)
	require.EqualValues(t, 499999998, n.ReplayLockTimeOrDefault())
	require.Equal(t, "mainnet", n.ReleaseChannel)
	require.Equal(t, "mainnet", n.ReleaseChannelOrID())
	require.Empty(t, n.ForkParentHash, "block 973727 does not exist yet")
	require.Equal(t, "seed.mainnet.ecash.example:8533", n.P2P.Address)
	require.NotEmpty(t, n.BackendURL(KindEsplora))
	require.NotEmpty(t, n.ElectrumURL())
	require.Nil(t, n.AssumeUTXO)
}

func TestParseReadsACatalogWithEveryNetwork(t *testing.T) {
	c := ecashMainnetCatalog(t)
	var ids []string
	for _, n := range c.Networks {
		ids = append(ids, n.ID)
	}
	require.Equal(t, []string{"bitcoin", "signet", "alphanet", "betanet", "ecash-mainnet"}, ids)
	require.Equal(t, "ecash-mainnet", c.ECashID())

	got, ok := c.ByMagic("eca5dcb7")
	require.True(t, ok)
	require.Equal(t, "ecash-mainnet", got.ID)
	got, ok = c.ByMagic("f9beb4d9")
	require.True(t, ok)
	require.Equal(t, "bitcoin", got.ID)
}

func TestTheECashMainnetRowLeavesBitcoinAlone(t *testing.T) {
	c := ecashMainnetCatalog(t)
	btc, ok := c.ForNetwork("mainnet")
	require.True(t, ok)
	require.Equal(t, "bitcoin", btc.ID)
	require.Zero(t, btc.ForkHeight)
	require.Equal(t, Embedded().Networks[0], btc, "the bitcoin row must not change")

	live, ok := c.ForNetwork("ecash")
	require.True(t, ok)
	require.Equal(t, "ecash-mainnet", live.ID)
}

func TestReleaseChannelOrIDFallsBackToTheID(t *testing.T) {
	c := ecashMainnetCatalog(t)
	for id, want := range map[string]string{"ecash-mainnet": "mainnet", "betanet": "betanet"} {
		n, ok := c.ByID(id)
		require.True(t, ok, id)
		require.Equal(t, want, n.ReleaseChannelOrID(), id)
	}
}
