package orchestrator

import (
	"context"
	"fmt"
	"github.com/rs/zerolog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// makeBitcoindCoreConfig returns a synthetic bitcoind BinaryConfig with all
// three variants populated, pointing at the given baseURL.
func makeBitcoindCoreConfig(baseURL string) BinaryConfig {
	mkVariant := func(id, sub string, networks []string) CoreVariantSpec {
		return CoreVariantSpec{
			ID:                id,
			Subfolder:         sub,
			BaseURL:           baseURL,
			Files:             map[string]string{currentPlatform(): id + ".zip"},
			AvailableNetworks: networks,
		}
	}
	return BinaryConfig{
		Name:           "bitcoind",
		BinaryName:     "bitcoind",
		IsBitcoinCore:  true,
		ChainLayer:     1,
		DownloadSource: DownloadSourceDirect,
		Variants: map[string]CoreVariantSpec{
			"core":    mkVariant("core", "bitcoin", []string{"mainnet", "signet", "testnet", "regtest"}),
			"patched": mkVariant("patched", "drivechain-patched", []string{"mainnet", "signet", "testnet", "regtest", "ecash"}),
			"knots":   mkVariant("knots", "knots", []string{"mainnet", "signet", "testnet", "regtest"}),
		},
	}
}

func TestCoreBinaryPath(t *testing.T) {
	dir := t.TempDir()

	// Each variant owns a subfolder, so two variants never share a file.
	core := CoreVariantSpec{ID: "core", Subfolder: "bitcoin"}
	knots := CoreVariantSpec{ID: "knots", Subfolder: "knots"}
	assert.Equal(t, filepath.Join(BinDir(dir), "bitcoin", "bitcoind"), CoreBinaryPath(dir, core, "bitcoind"))
	assert.Equal(t, filepath.Join(BinDir(dir), "knots", "bitcoind"), CoreBinaryPath(dir, knots, "bitcoind"))
	assert.NotEqual(t, CoreBinaryPath(dir, core, "bitcoind"), CoreBinaryPath(dir, knots, "bitcoind"))

	// No subfolder keeps the flat layout for callers with no spec.
	assert.Equal(t, BinaryPath(dir, "bitcoind"), CoreBinaryPath(dir, CoreVariantSpec{ID: "x"}, "bitcoind"))
}

func TestCoreVariantSpec_AvailableOn(t *testing.T) {
	v := CoreVariantSpec{AvailableNetworks: []string{"signet", "testnet"}}
	assert.True(t, v.AvailableOn("signet"))
	assert.True(t, v.AvailableOn("testnet"))
	assert.False(t, v.AvailableOn("ecash"))
	assert.False(t, v.AvailableOn(""))
}

func TestFilterVariantsForNetwork(t *testing.T) {
	cfg := makeBitcoindCoreConfig("http://example/").Variants

	mainnet := variantIDs(FilterVariantsForNetwork(cfg, "mainnet"))
	assert.ElementsMatch(t, []string{"core", "patched", "knots"}, mainnet)

	signet := variantIDs(FilterVariantsForNetwork(cfg, "signet"))
	assert.ElementsMatch(t, []string{"core", "patched", "knots"}, signet)

	ecash := variantIDs(FilterVariantsForNetwork(cfg, "ecash"))
	assert.ElementsMatch(t, []string{"patched"}, ecash)

	testnet := variantIDs(FilterVariantsForNetwork(cfg, "testnet"))
	assert.ElementsMatch(t, []string{"core", "patched", "knots"}, testnet)
}

func variantIDs(vs []CoreVariantSpec) []string {
	out := make([]string, len(vs))
	for i, v := range vs {
		out[i] = v.ID
	}
	return out
}

func TestParseConfigJSON_BitcoincoreVariants(t *testing.T) {
	configs, err := parseConfigJSON(embeddedConfig)
	require.NoError(t, err)

	var core BinaryConfig
	for _, c := range configs {
		if c.IsMainchainCore() {
			core = c
			break
		}
	}
	require.NotEmpty(t, core.Variants, "embedded config must declare core variants")

	for _, id := range []string{"core", "patched", "knots", "forknet", "ecash"} {
		v, ok := core.Variants[id]
		require.True(t, ok, "missing variant %s", id)
		assert.NotEmpty(t, v.Subfolder)
		assert.NotEmpty(t, v.BaseURL)
		assert.NotEmpty(t, v.Files)
		assert.NotEmpty(t, v.AvailableNetworks)
	}

	assert.True(t, core.Variants["forknet"].AvailableOn("forknet"))
	assert.True(t, core.Variants["ecash"].AvailableOn("ecash"))
	assert.False(t, core.Variants["ecash"].AvailableOn("forknet"))
	assert.False(t, core.Variants["patched"].AvailableOn("ecash"))
	assert.True(t, core.Variants["patched"].AvailableOn("mainnet"))
	assert.True(t, core.Variants["core"].AvailableOn("mainnet"))
	assert.True(t, core.Variants["knots"].AvailableOn("mainnet"))
	assert.True(t, core.Variants["core"].AvailableOn("signet"))
	assert.True(t, core.Variants["knots"].AvailableOn("signet"))
	assert.False(t, core.Variants["core"].AvailableOn("ecash"))
}

func TestSettingsStore_RoundTrip(t *testing.T) {
	dir := t.TempDir()

	s, err := NewSettingsStore(dir)
	require.NoError(t, err)
	assert.Equal(t, DefaultCoreVariantID, s.CoreVariant())

	prev, err := s.SetCoreVariant("knots")
	require.NoError(t, err)
	assert.Equal(t, DefaultCoreVariantID, prev)
	assert.Equal(t, "knots", s.CoreVariant())

	// Persisted across reload.
	s2, err := NewSettingsStore(dir)
	require.NoError(t, err)
	assert.Equal(t, "knots", s2.CoreVariant())

	// Same-value set is a no-op.
	prev, err = s2.SetCoreVariant("knots")
	require.NoError(t, err)
	assert.Equal(t, "knots", prev)
}

func TestDownload_VariantSelectsURLAndDestination(t *testing.T) {
	zipContent := makeZipBytes(t, map[string][]byte{"bitcoind": []byte("knots-bin")})

	var requested string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requested = r.URL.Path
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(zipContent)))
		_, _ = w.Write(zipContent)
	}))
	defer srv.Close()

	dm, dir := newTestDownloadManager(t)
	dm.httpClient = srv.Client()

	cfg := makeBitcoindCoreConfig(srv.URL + "/")
	dm.CoreVariant = func() (CoreVariantSpec, bool) {
		return cfg.Variants["knots"], true
	}

	ch, err := dm.Download(context.Background(), cfg, "signet", true)
	require.NoError(t, err)
	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, "/knots.zip", requested, "must hit the variant's filename")

	// The extract has to land in the variant's own subfolder, so a stat of
	// that path proves the build is the selected one.
	binName := "bitcoind"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	knots := cfg.Variants["knots"]
	expected := filepath.Join(BinDir(dir), knots.Subfolder, binName)
	got, err := os.ReadFile(expected)
	require.NoError(t, err)
	assert.Equal(t, "knots-bin", string(got))
	assert.NoFileExists(t, filepath.Join(BinDir(dir), binName),
		"the flat path must stay empty, it is what let a stale build boot")
}

func TestDownload_VariantSkipsWhenInstalled(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	cfg := makeBitcoindCoreConfig("http://unused/")
	variant := cfg.Variants["patched"]
	dm.CoreVariant = func() (CoreVariantSpec, bool) { return variant, true }

	target := CoreBinaryPath(dir, variant, "bitcoind")
	require.NoError(t, os.MkdirAll(filepath.Dir(target), 0o755))
	require.NoError(t, os.WriteFile(target, []byte("already-installed"), 0o755))

	ch, err := dm.Download(context.Background(), cfg, "ecash", false)
	require.NoError(t, err)
	last := drainProgress(t, ch)
	assert.True(t, last.Done)
	assert.Equal(t, target, last.Message, "skip-when-exists must report variant path")

	// Bytes still untouched.
	got, err := os.ReadFile(target)
	require.NoError(t, err)
	assert.Equal(t, "already-installed", string(got))
}

func TestOrchestrator_ListCoreVariants(t *testing.T) {
	cases := []struct {
		network string
		want    []string
	}{
		// core/patched/knots are available on every chain except forknet and
		// eCash, which each have a dedicated build as their sole option.
		{"mainnet", []string{"core", "knots", "patched"}},
		{"signet", []string{"core", "knots", "patched"}},
		{"testnet", []string{"core", "knots", "patched"}},
		{"regtest", []string{"core", "knots", "patched"}},
		{"forknet", []string{"forknet"}},
		{"ecash", []string{"ecash"}},
	}
	for _, tc := range cases {
		t.Run(tc.network, func(t *testing.T) {
			o := New(t.TempDir(), tc.network, t.TempDir(), AllDefaults(), testLogger(t))
			got := variantIDs(o.ListCoreVariants())
			assert.ElementsMatch(t, tc.want, got)
		})
	}
}

// The incident this layout fixes: a stale stock Core sat in the shared
// bin/bitcoind, the boot check stated that path, and Core ran chain=main
// against the eCash datadir. Each variant must own its own file, and the
// eCash network must ride in the subfolder so a rollover moves too.
func TestCoreBinaryPathSeparatesEveryVariant(t *testing.T) {
	dir := t.TempDir()
	cfg := expandECashPlaceholder(makeBitcoindCoreConfig("http://example/"), "drynet4")

	seen := map[string]string{}
	for id, v := range cfg.Variants {
		path := CoreBinaryPath(dir, v, "bitcoind")
		require.NotEqual(t, BinaryPath(dir, "bitcoind"), path, "variant %s must not use the flat path", id)
		if other, clash := seen[path]; clash {
			t.Fatalf("variants %s and %s share %s", id, other, path)
		}
		seen[path] = id
	}

}

// The shipped chains_config.json is the real composition: it is the file that
// gives eCash a {ecash} subfolder, so the generation has to reach the path.
func TestCoreBinaryPathCarriesTheECashGeneration(t *testing.T) {
	dir := t.TempDir()
	configs := LoadConfigFile("chains_config.json", zerolog.Nop())
	require.NotEmpty(t, configs, "the shipped chains_config.json must parse")

	var core BinaryConfig
	for _, c := range configs {
		if c.IsMainchainCore() {
			core = c
			break
		}
	}
	require.NotEmpty(t, core.Variants, "no mainchain core config in chains_config.json")

	four := expandECashPlaceholder(core, "drynet4").Variants["ecash"]
	five := expandECashPlaceholder(core, "drynet5").Variants["ecash"]
	assert.Equal(t, filepath.Join(BinDir(dir), "drynet4", "bitcoind"), CoreBinaryPath(dir, four, "bitcoind"))
	assert.NotEqual(t, CoreBinaryPath(dir, four, "bitcoind"), CoreBinaryPath(dir, five, "bitcoind"),
		"a generation rollover must resolve to a new file")

	// Every shipped variant keeps its own file, stock Core included.
	seen := map[string]string{}
	for id, v := range expandECashPlaceholder(core, "drynet4").Variants {
		path := CoreBinaryPath(dir, v, "bitcoind")
		require.NotEqual(t, BinaryPath(dir, "bitcoind"), path, "variant %s must not use the flat path", id)
		if other, clash := seen[path]; clash {
			t.Fatalf("variants %s and %s share %s", id, other, path)
		}
		seen[path] = id
	}
}
