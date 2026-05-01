package orchestrator

import (
	"context"
	"fmt"
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
			Files:             map[string]string{currentOS(): id + ".zip"},
			AvailableNetworks: networks,
		}
	}
	return BinaryConfig{
		Name:           "bitcoind",
		BinaryName:     "bitcoind",
		IsBitcoinCore:  true,
		DownloadSource: DownloadSourceDirect,
		Variants: map[string]CoreVariantSpec{
			"untouched": mkVariant("untouched", "bitcoin", []string{"signet", "testnet", "regtest"}),
			"touched":   mkVariant("touched", "drivechain", []string{"forknet"}),
			"knots":     mkVariant("knots", "knots", []string{"signet", "testnet", "regtest"}),
		},
	}
}

func TestCoreBinaryPath(t *testing.T) {
	dir := t.TempDir()

	v := CoreVariantSpec{ID: "untouched", Subfolder: "bitcoin"}
	got := CoreBinaryPath(dir, v, "bitcoind")
	want := filepath.Join(BinDir(dir), "bitcoin", "bitcoind")
	if runtime.GOOS == "windows" {
		want = filepath.Join(BinDir(dir), "bitcoin", "bitcoind.exe")
	}
	assert.Equal(t, want, got)

	// Empty subfolder collapses to BinDir.
	v2 := CoreVariantSpec{ID: "x"}
	assert.Equal(t, BinaryPath(dir, "bitcoind"), CoreBinaryPath(dir, v2, "bitcoind"))
}

func TestCoreVariantSpec_AvailableOn(t *testing.T) {
	v := CoreVariantSpec{AvailableNetworks: []string{"signet", "testnet"}}
	assert.True(t, v.AvailableOn("signet"))
	assert.True(t, v.AvailableOn("testnet"))
	assert.False(t, v.AvailableOn("forknet"))
	assert.False(t, v.AvailableOn(""))
}

func TestFilterVariantsForNetwork(t *testing.T) {
	cfg := makeBitcoindCoreConfig("http://example/").Variants

	mainnet := FilterVariantsForNetwork(cfg, "mainnet")
	assert.Empty(t, mainnet, "mainnet must hide all variants")

	signet := variantIDs(FilterVariantsForNetwork(cfg, "signet"))
	assert.ElementsMatch(t, []string{"untouched", "knots"}, signet)

	forknet := variantIDs(FilterVariantsForNetwork(cfg, "forknet"))
	assert.ElementsMatch(t, []string{"touched"}, forknet)

	testnet := variantIDs(FilterVariantsForNetwork(cfg, "testnet"))
	assert.ElementsMatch(t, []string{"untouched", "knots"}, testnet)
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
		if c.IsBitcoinCore {
			core = c
			break
		}
	}
	require.NotEmpty(t, core.Variants, "embedded config must declare core variants")

	for _, id := range []string{"untouched", "touched", "knots"} {
		v, ok := core.Variants[id]
		require.True(t, ok, "missing variant %s", id)
		assert.NotEmpty(t, v.Subfolder)
		assert.NotEmpty(t, v.BaseURL)
		assert.NotEmpty(t, v.Files)
		assert.NotEmpty(t, v.AvailableNetworks)
	}

	assert.True(t, core.Variants["touched"].AvailableOn("forknet"))
	assert.True(t, core.Variants["untouched"].AvailableOn("signet"))
	assert.True(t, core.Variants["knots"].AvailableOn("signet"))
	assert.False(t, core.Variants["touched"].AvailableOn("signet"))
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

	// Binary must land in the variant's subfolder, not in BinDir root.
	binName := "bitcoind"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	expected := filepath.Join(BinDir(dir), "knots", binName)
	got, err := os.ReadFile(expected)
	require.NoError(t, err)
	assert.Equal(t, "knots-bin", string(got))

	// Flat path must NOT exist (would imply we extracted to BinDir root).
	_, err = os.Stat(filepath.Join(BinDir(dir), binName))
	assert.True(t, os.IsNotExist(err), "must not write bitcoind to BinDir root when variant is active")
}

func TestDownload_VariantSkipsWhenInstalled(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	cfg := makeBitcoindCoreConfig("http://unused/")
	variant := cfg.Variants["touched"]
	dm.CoreVariant = func() (CoreVariantSpec, bool) { return variant, true }

	target := CoreBinaryPath(dir, variant, "bitcoind")
	require.NoError(t, os.MkdirAll(filepath.Dir(target), 0o755))
	require.NoError(t, os.WriteFile(target, []byte("already-installed"), 0o755))

	ch, err := dm.Download(context.Background(), cfg, "forknet", false)
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
		{"mainnet", nil},
		// "patched" (drivechain.info L1-bitcoin-patched-latest) is available on
		// every non-mainnet chain so a user who lands on signet still gets a
		// drivechain-aware build by default instead of vanilla / knots.
		{"signet", []string{"untouched", "knots", "patched"}},
		{"testnet", []string{"untouched", "knots", "patched"}},
		{"regtest", []string{"untouched", "knots", "patched"}},
		{"forknet", []string{"touched", "patched"}},
	}
	for _, tc := range cases {
		t.Run(tc.network, func(t *testing.T) {
			o := New(t.TempDir(), tc.network, t.TempDir(), AllDefaults(), testLogger(t))
			got := variantIDs(o.ListCoreVariants())
			assert.ElementsMatch(t, tc.want, got)
		})
	}
}
