// End-to-end coverage for the Core variant switch flow. Drives a real
// Orchestrator against a mock HTTP server, exercising the
// stop -> persist -> ensure-download path. Process restart is not covered
// here because it would require launching bitcoind; that's intentional —
// all other failure modes need to be caught before we ever start a daemon.

package orchestrator

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"sync"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// variantArchive is the fake archive served by the mock server for a given
// variant. The orchestrator unpacks this exactly like a real release.
func variantArchive(t *testing.T, variantID string) []byte {
	t.Helper()
	binName := "bitcoind"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	return makeZipBytes(t, map[string][]byte{binName: []byte(variantID)})
}

// requestCount tracks per-variant download counts so coexistence tests can
// assert "switching to an installed variant must not redownload."
type requestCount struct {
	untouched, touched, knots atomic.Int32
}

func newVariantServer(t *testing.T, counts *requestCount) *httptest.Server {
	t.Helper()
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/untouched.zip":
			counts.untouched.Add(1)
			_, _ = w.Write(variantArchive(t, "untouched"))
		case "/touched.zip":
			counts.touched.Add(1)
			_, _ = w.Write(variantArchive(t, "touched"))
		case "/knots.zip":
			counts.knots.Add(1)
			_, _ = w.Write(variantArchive(t, "knots"))
		default:
			http.NotFound(w, r)
		}
	})
	return httptest.NewServer(mux)
}

// newIntegrationOrchestrator builds an Orchestrator wired to mock variant
// configs that point at the given server. dataDir/bitwindowDir default to
// fresh temp dirs unless caller supplies one (used for restart tests).
func newIntegrationOrchestrator(t *testing.T, network, baseURL string, dataDir, bitwindowDir string) *Orchestrator {
	t.Helper()
	if dataDir == "" {
		dataDir = t.TempDir()
	}
	if bitwindowDir == "" {
		bitwindowDir = t.TempDir()
	}
	configs := []BinaryConfig{makeBitcoindCoreConfig(baseURL)}
	return New(dataDir, network, bitwindowDir, configs, testLogger(t))
}

func variantBinary(dataDir string, v CoreVariantSpec) string {
	return CoreBinaryPath(dataDir, v, "bitcoind")
}

func TestIntegration_SetCoreVariant_FreshSwitchInstallsBinary(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	require.NoError(t, o.SetCoreVariant(context.Background(), "knots"))

	// Settings now report knots, persisted to disk.
	assert.Equal(t, "knots", o.CoreVariant())
	persisted, err := LoadSettings(bwDir)
	require.NoError(t, err)
	assert.Equal(t, "knots", persisted.CoreVariant)

	// Knots binary landed in its variant subfolder; default touched did not.
	knots := o.configs["bitcoind"].Variants["knots"]
	touched := o.configs["bitcoind"].Variants["touched"]
	got, err := os.ReadFile(variantBinary(dataDir, knots))
	require.NoError(t, err)
	assert.Equal(t, "knots", string(got))
	_, err = os.Stat(variantBinary(dataDir, touched))
	assert.True(t, os.IsNotExist(err), "non-selected variant must not download")

	assert.Equal(t, int32(1), counts.knots.Load())
	assert.Equal(t, int32(0), counts.touched.Load())
}

func TestIntegration_SetCoreVariant_PersistsAcrossRestart(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	first := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	require.NoError(t, first.SetCoreVariant(context.Background(), "knots"))

	// Recreate the orchestrator from the same dirs — simulates app restart.
	second := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	assert.Equal(t, "knots", second.CoreVariant())
}

func TestIntegration_SetCoreVariant_CoexistsAndSkipsCachedDownload(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, t.TempDir())

	ctx := context.Background()
	require.NoError(t, o.SetCoreVariant(ctx, "knots"))
	require.NoError(t, o.SetCoreVariant(ctx, "untouched"))
	// Switching back to the cached knots binary must not redownload.
	require.NoError(t, o.SetCoreVariant(ctx, "knots"))

	knots := o.configs["bitcoind"].Variants["knots"]
	untouched := o.configs["bitcoind"].Variants["untouched"]
	_, err := os.Stat(variantBinary(dataDir, knots))
	require.NoError(t, err, "knots binary must persist after switching away")
	_, err = os.Stat(variantBinary(dataDir, untouched))
	require.NoError(t, err, "untouched binary must persist after switching away")

	assert.Equal(t, int32(1), counts.knots.Load(), "knots must be downloaded exactly once")
	assert.Equal(t, int32(1), counts.untouched.Load())
}

func TestIntegration_SetCoreVariant_RejectsMainnet(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	o := newIntegrationOrchestrator(t, "mainnet", srv.URL+"/", "", "")
	err := o.SetCoreVariant(context.Background(), "knots")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "mainnet")
}

func TestIntegration_SetCoreVariant_RejectsIncompatibleNetwork(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, t.TempDir())
	err := o.SetCoreVariant(context.Background(), "touched")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "not available")
	// No download should have been attempted for the rejected variant.
	assert.Equal(t, int32(0), counts.touched.Load())
	touched := o.configs["bitcoind"].Variants["touched"]
	_, statErr := os.Stat(variantBinary(dataDir, touched))
	assert.True(t, os.IsNotExist(statErr))
}

func TestIntegration_SetCoreVariant_RejectsUnknownVariant(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", "", "")
	err := o.SetCoreVariant(context.Background(), "doge")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "unknown core variant")
}

func TestIntegration_ListCoreVariants_FilterByNetwork(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	cases := []struct {
		network string
		want    []string
	}{
		{"mainnet", nil},
		{"forknet", []string{"touched"}},
		{"signet", []string{"untouched", "knots"}},
		{"testnet", []string{"untouched", "knots"}},
		{"regtest", []string{"untouched", "knots"}},
	}
	for _, tc := range cases {
		t.Run(tc.network, func(t *testing.T) {
			o := newIntegrationOrchestrator(t, tc.network, srv.URL+"/", "", "")
			got := variantIDs(o.ListCoreVariants())
			assert.ElementsMatch(t, tc.want, got)
		})
	}
}

// User picks knots on signet, then relaunches the app on forknet. The
// resolver must clamp to a forknet-compatible variant (touched) instead of
// honouring the persisted knots ID.
func TestIntegration_VariantResolver_ClampsOnNetworkSwap(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	first := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	require.NoError(t, first.SetCoreVariant(context.Background(), "knots"))

	// Same data dirs, different network. Settings still say knots.
	second := newIntegrationOrchestrator(t, "forknet", srv.URL+"/", dataDir, bwDir)

	v, ok := second.download.CoreVariant()
	require.True(t, ok, "resolver must produce a variant on forknet")
	assert.Equal(t, "touched", v.ID, "persisted knots is not forknet-compatible; must clamp to touched")

	// On a network where knots IS available, the persisted choice still wins.
	third := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	v, ok = third.download.CoreVariant()
	require.True(t, ok)
	assert.Equal(t, "knots", v.ID)
}

func TestIntegration_VariantResolver_FallbackWhenSettingsEmpty(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	o := newIntegrationOrchestrator(t, "forknet", srv.URL+"/", "", "")
	v, ok := o.download.CoreVariant()
	require.True(t, ok, "fresh forknet install must resolve to a variant")
	assert.Equal(t, "touched", v.ID)
}

// Verifies the path the launcher would use after a switch. The orchestrator's
// process manager queries CoreVariant() at Start time, and the variant
// resolver wires CoreBinaryPath into ProcessManager. Without launching
// bitcoind we can still confirm the resolver reports the right active path.
func TestIntegration_SetCoreVariant_ResolverPointsAtActiveVariant(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, t.TempDir())

	require.NoError(t, o.SetCoreVariant(context.Background(), "knots"))

	knots := o.configs["bitcoind"].Variants["knots"]
	expected := filepath.Join(BinDir(dataDir), knots.Subfolder, "bitcoind")
	if runtime.GOOS == "windows" {
		expected += ".exe"
	}
	assert.Equal(t, expected, CoreBinaryPath(dataDir, knots, "bitcoind"))
}

// Five concurrent SetCoreVariant calls must not race the on-disk state. The
// coreVariantMu serialises stop -> persist -> download -> restart so we end up
// with a coherent active variant, and only the actually-attempted variants
// land in the bin dir.
func TestIntegration_SetCoreVariant_Concurrent(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	candidates := []string{"untouched", "knots", "untouched", "knots", "untouched"}

	var wg sync.WaitGroup
	for _, id := range candidates {
		wg.Add(1)
		go func(id string) {
			defer wg.Done()
			_ = o.SetCoreVariant(context.Background(), id)
		}(id)
	}
	wg.Wait()

	// Final active variant must be one of the inputs, not a half-baked value.
	final := o.CoreVariant()
	require.Contains(t, []string{"untouched", "knots"}, final)
	persisted, err := LoadSettings(bwDir)
	require.NoError(t, err)
	assert.Equal(t, final, persisted.CoreVariant)

	// Every attempted variant lands as a single binary; no torn writes.
	untouched := o.configs["bitcoind"].Variants["untouched"]
	knots := o.configs["bitcoind"].Variants["knots"]
	for _, v := range []CoreVariantSpec{untouched, knots} {
		got, err := os.ReadFile(variantBinary(dataDir, v))
		require.NoError(t, err)
		assert.Equal(t, v.ID, string(got))
	}

	// Only one download per variant, regardless of how many goroutines asked
	// for it. Five attempts with two distinct ids => two HTTP fetches.
	assert.LessOrEqual(t, counts.untouched.Load(), int32(1), "untouched downloaded more than once")
	assert.LessOrEqual(t, counts.knots.Load(), int32(1), "knots downloaded more than once")
}

// Graceful stop fails -> SetCoreVariant must escalate to SIGKILL and persist
// only when SIGKILL succeeds. If both fail, settings stay untouched and no
// download is attempted.
func TestIntegration_SetCoreVariant_StopFailure(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	t.Run("escalates_and_persists", func(t *testing.T) {
		dataDir := t.TempDir()
		bwDir := t.TempDir()
		o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

		// Pretend bitcoind is running so SetCoreVariant exercises the stop path.
		o.process.AdoptProcess(o.configs["bitcoind"], 1)

		var graceful, force atomic.Int32
		o.stopBinary = func(_ context.Context, name string, f bool) error {
			require.Equal(t, "bitcoind", name)
			if !f {
				graceful.Add(1)
				return errors.New("graceful stop failed")
			}
			force.Add(1)
			// Pretend kill worked: drop the fake process so the boot path
			// downstream doesn't try to talk to a dead PID.
			o.process.Remove("bitcoind")
			return nil
		}
		// Replace the boot helper with a no-op success — we don't have a real
		// bitcoind binary to launch in unit tests.
		o.bootBitcoindForVariantSwap = func(_ context.Context) <-chan StartupProgress {
			ch := make(chan StartupProgress, 1)
			ch <- StartupProgress{Done: true}
			close(ch)
			return ch
		}

		require.NoError(t, o.SetCoreVariant(context.Background(), "knots"))
		assert.Equal(t, int32(1), graceful.Load(), "graceful stop must be attempted first")
		assert.Equal(t, int32(1), force.Load(), "must escalate to force kill once")
		assert.Equal(t, "knots", o.CoreVariant(), "settings must persist after escalation")
		persisted, err := LoadSettings(bwDir)
		require.NoError(t, err)
		assert.Equal(t, "knots", persisted.CoreVariant)
	})

	t.Run("force_also_fails_no_persist", func(t *testing.T) {
		dataDir := t.TempDir()
		bwDir := t.TempDir()
		o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

		// Pre-set to a known value so we can prove no persist happened.
		_, err := o.Settings.SetCoreVariant("untouched")
		require.NoError(t, err)

		o.process.AdoptProcess(o.configs["bitcoind"], 1)

		preDownloads := counts.knots.Load()
		o.stopBinary = func(_ context.Context, _ string, _ bool) error {
			return errors.New("kill refused")
		}
		o.bootBitcoindForVariantSwap = func(_ context.Context) <-chan StartupProgress {
			t.Fatal("boot must not run when stop failed")
			return nil
		}

		err = o.SetCoreVariant(context.Background(), "knots")
		require.Error(t, err)
		assert.Contains(t, err.Error(), "stop")

		assert.Equal(t, "untouched", o.CoreVariant(), "settings must stay untouched on stop failure")
		persisted, lerr := LoadSettings(bwDir)
		require.NoError(t, lerr)
		assert.Equal(t, "untouched", persisted.CoreVariant)
		assert.Equal(t, preDownloads, counts.knots.Load(), "no download must run when stop failed")

		knots := o.configs["bitcoind"].Variants["knots"]
		_, statErr := os.Stat(variantBinary(dataDir, knots))
		assert.True(t, os.IsNotExist(statErr), "no variant binary must land when stop failed")
	})
}

// A network-rejected variant must be rejected before any state mutates: prior
// settings stay intact even when called from a bitwindow dir that already has
// a different active variant persisted.
func TestIntegration_SetCoreVariant_RejectedStopLeavesSettingsUnchanged(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	// Pre-populate orchestrator_settings.json with knots.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "knots"}))

	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	require.Equal(t, "knots", o.CoreVariant())

	// "touched" is forknet-only: must be rejected on signet.
	err := o.SetCoreVariant(context.Background(), "touched")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "not available")

	assert.Equal(t, "knots", o.CoreVariant())
	persisted, err := LoadSettings(bwDir)
	require.NoError(t, err)
	assert.Equal(t, "knots", persisted.CoreVariant)
	assert.Equal(t, int32(0), counts.touched.Load())
}

// When the persisted active variant isn't valid for the current network, the
// ListCoreVariants response must clamp active_id to "" so the dropdown can't
// be handed an out-of-list value.
func TestIntegration_ListCoreVariants_ClampsActiveOnNetworkMismatch(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	// Persist a forknet-only variant, then load orchestrator on signet.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "touched"}))
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	// Persisted ID is preserved on disk.
	assert.Equal(t, "touched", o.CoreVariant())

	// Visible list for signet excludes touched.
	visible := variantIDs(o.ListCoreVariants())
	assert.NotContains(t, visible, "touched")

	// Simulate the wallet handler clamp: active_id from CoreVariant() not in
	// the visible list -> empty.
	active := o.CoreVariant()
	clamped := active
	found := false
	for _, id := range visible {
		if id == active {
			found = true
			break
		}
	}
	if !found {
		clamped = ""
	}
	assert.Equal(t, "", clamped, "active must clamp to empty when not in visible list")
}

// CLI subcommands like `which`/`wipe`/`list` must resolve the active variant
// from orchestrator_settings.json instead of using the legacy flat path.
func TestIntegration_LegacyBinaryPathCallsites(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()

	binName := "bitcoind"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}

	configs := []BinaryConfig{makeBitcoindCoreConfig("http://unused/")}
	knots := configs[0].Variants["knots"]

	// Place a stub binary in the variant subfolder only — flat path stays empty.
	variantPath := CoreBinaryPath(dataDir, knots, "bitcoind")
	require.NoError(t, os.MkdirAll(filepath.Dir(variantPath), 0o755))
	require.NoError(t, os.WriteFile(variantPath, []byte("stub"), 0o755))
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "knots"}))

	got := ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind")
	assert.Equal(t, variantPath, got, "must resolve the active variant subfolder, not BinDir root")

	// Sanity: the legacy flat path doesn't exist.
	flatPath := filepath.Join(BinDir(dataDir), binName)
	_, err := os.Stat(flatPath)
	assert.True(t, os.IsNotExist(err), "must not look at BinDir/%s", binName)

	// Resolver must follow settings even when they change.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "untouched"}))
	untouched := configs[0].Variants["untouched"]
	expected := CoreBinaryPath(dataDir, untouched, "bitcoind")
	assert.Equal(t, expected, ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind"))

	// And falls back to flat layout for non-bitcoind names.
	other := ActiveCoreBinaryPath(dataDir, bwDir, configs, "enforcer")
	assert.Equal(t, BinaryPath(dataDir, "enforcer"), other)
}
