// End-to-end coverage for the Core variant switch flow. Drives a real
// Orchestrator against a mock HTTP server, exercising the
// stop -> persist -> ensure-download path. Process restart is not covered
// here because it would require launching bitcoind; that's intentional —
// all other failure modes need to be caught before we ever start a daemon.

package orchestrator

import (
	"context"
	"errors"
	"fmt"
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

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
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

// requestCount tracks per-variant download counts.
type requestCount struct {
	core, patched, knots atomic.Int32
}

func newVariantServer(t *testing.T, counts *requestCount) *httptest.Server {
	t.Helper()
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Don't count HEAD probes — those are the new Content-Length probe
		// and don't represent an actual download.
		isGet := r.Method == http.MethodGet
		switch r.URL.Path {
		case "/core.zip":
			if isGet {
				counts.core.Add(1)
			}
			body := variantArchive(t, "core")
			w.Header().Set("Content-Length", fmt.Sprintf("%d", len(body)))
			if !isGet {
				return
			}
			_, _ = w.Write(body)
		case "/patched.zip":
			if isGet {
				counts.patched.Add(1)
			}
			body := variantArchive(t, "patched")
			w.Header().Set("Content-Length", fmt.Sprintf("%d", len(body)))
			if !isGet {
				return
			}
			_, _ = w.Write(body)
		case "/knots.zip":
			if isGet {
				counts.knots.Add(1)
			}
			body := variantArchive(t, "knots")
			w.Header().Set("Content-Length", fmt.Sprintf("%d", len(body)))
			if !isGet {
				return
			}
			_, _ = w.Write(body)
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

	// The knots binary landed in the knots subfolder.
	knots := o.configs["bitcoind"].Variants["knots"]
	got, err := os.ReadFile(variantBinary(dataDir, knots))
	require.NoError(t, err)
	assert.Equal(t, "knots", string(got))

	assert.Equal(t, int32(1), counts.knots.Load())
	assert.Equal(t, int32(0), counts.patched.Load())
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

// Every switch downloads the selected variant, and the settings report the
// variant selected last.
func TestIntegration_SetCoreVariant_RedownloadsOnEverySwitch(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, t.TempDir())

	ctx := context.Background()
	require.NoError(t, o.SetCoreVariant(ctx, "knots"))
	require.NoError(t, o.SetCoreVariant(ctx, "core"))
	require.NoError(t, o.SetCoreVariant(ctx, "knots"))

	// Final active is knots; bin/bitcoind contains the knots payload.
	knots := o.configs["bitcoind"].Variants["knots"]
	got, err := os.ReadFile(variantBinary(dataDir, knots))
	require.NoError(t, err)
	assert.Equal(t, "knots", string(got))

	// Each switch fires its own download (no caching across switches).
	assert.Equal(t, int32(2), counts.knots.Load(), "knots downloaded once per switch to it")
	assert.Equal(t, int32(1), counts.core.Load())
}

func TestIntegration_SetCoreVariant_RejectsIncompatibleNetwork(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "ecash", srv.URL+"/", dataDir, t.TempDir())
	// "core" is not available on eCash — must be rejected.
	err := o.SetCoreVariant(context.Background(), "core")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "not available")
	assert.Equal(t, int32(0), counts.core.Load())
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
		{"mainnet", []string{"core", "patched", "knots"}},
		{"ecash", []string{"patched"}},
		{"signet", []string{"core", "patched", "knots"}},
		{"testnet", []string{"core", "patched", "knots"}},
		{"regtest", []string{"core", "patched", "knots"}},
	}
	for _, tc := range cases {
		t.Run(tc.network, func(t *testing.T) {
			o := newIntegrationOrchestrator(t, tc.network, srv.URL+"/", "", "")
			got := variantIDs(o.ListCoreVariants())
			assert.ElementsMatch(t, tc.want, got)
		})
	}
}

// User picks knots on signet, then relaunches the app on eCash. The
// resolver must clamp to a eCash-compatible variant (patched) instead of
// honouring the persisted knots ID.
func TestIntegration_VariantResolver_ClampsOnNetworkSwap(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	first := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	require.NoError(t, first.SetCoreVariant(context.Background(), "knots"))

	// Persist the network swap to disk the way the UI does — bitwindow-
	// bitcoin.conf is the source of truth on subsequent boots, the CLI
	// flag only seeds first-boot defaults.
	require.NoError(t, first.BitcoinConf.UpdateNetwork(config.NetworkECash))

	// Same data dirs; the new orchestrator picks up the persisted eCash.
	second := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	v, ok := second.download.CoreVariant()
	require.True(t, ok, "resolver must produce a variant on eCash")
	assert.Equal(t, "patched", v.ID, "persisted knots is not eCash-compatible; must clamp to patched")

	// Swap back to signet via the conf, then knots becomes valid again.
	require.NoError(t, second.BitcoinConf.UpdateNetwork(config.NetworkSignet))
	third := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	v, ok = third.download.CoreVariant()
	require.True(t, ok)
	assert.Equal(t, "knots", v.ID)
}

func TestIntegration_VariantResolver_FallbackWhenSettingsEmpty(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	o := newIntegrationOrchestrator(t, "ecash", srv.URL+"/", "", "")
	v, ok := o.download.CoreVariant()
	require.True(t, ok, "fresh eCash install must resolve to a variant")
	assert.Equal(t, "patched", v.ID)
}

// Verifies the launcher path after a switch. The download has to land in the
// active variant's own subfolder, or the boot check stats a file another
// variant wrote and starts the wrong build.
func TestIntegration_SetCoreVariant_ResolverPointsAtActiveVariant(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, t.TempDir())

	require.NoError(t, o.SetCoreVariant(context.Background(), "knots"))

	knots := o.configs["bitcoind"].Variants["knots"]
	expected := filepath.Join(BinDir(dataDir), knots.Subfolder, "bitcoind")
	assert.Equal(t, expected, CoreBinaryPath(dataDir, knots, "bitcoind"))
	assert.FileExists(t, expected, "the switch must download into the variant's subfolder")

	core := o.configs["bitcoind"].Variants["core"]
	assert.NoFileExists(t, CoreBinaryPath(dataDir, core, "bitcoind"),
		"another variant must not read as downloaded")
}

// Five concurrent SetCoreVariant calls must not race the on-disk state. The
// coreVariantMu serialises stop -> wipe -> persist -> download -> restart so
// we end up with a coherent final active variant whose payload is on disk.
func TestIntegration_SetCoreVariant_Concurrent(t *testing.T) {
	counts := &requestCount{}
	srv := newVariantServer(t, counts)
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	candidates := []string{"core", "knots", "core", "knots", "core"}

	var wg sync.WaitGroup
	for _, id := range candidates {
		wg.Add(1)
		go func(id string) {
			defer wg.Done()
			_ = o.SetCoreVariant(context.Background(), id)
		}(id)
	}
	wg.Wait()

	// Final active variant must be one of the inputs.
	final := o.CoreVariant()
	require.Contains(t, []string{"core", "knots"}, final)
	persisted, err := LoadSettings(bwDir)
	require.NoError(t, err)
	assert.Equal(t, final, persisted.CoreVariant)

	// bin/bitcoind contains exactly one payload — the final active variant's.
	v := o.configs["bitcoind"].Variants[final]
	got, err := os.ReadFile(variantBinary(dataDir, v))
	require.NoError(t, err)
	assert.Equal(t, final, string(got))
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
		o.stopBinary = func(_ context.Context, name string, f bool, _ ...StopOptions) error {
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
		_, err := o.Settings.SetCoreVariant("core")
		require.NoError(t, err)

		o.process.AdoptProcess(o.configs["bitcoind"], 1)

		preDownloads := counts.knots.Load()
		o.stopBinary = func(_ context.Context, _ string, _ bool, _ ...StopOptions) error {
			return errors.New("kill refused")
		}
		o.bootBitcoindForVariantSwap = func(_ context.Context) <-chan StartupProgress {
			t.Fatal("boot must not run when stop failed")
			return nil
		}

		err = o.SetCoreVariant(context.Background(), "knots")
		require.Error(t, err)
		assert.Contains(t, err.Error(), "stop")

		assert.Equal(t, "core", o.CoreVariant(), "settings must stay untouched on stop failure")
		persisted, lerr := LoadSettings(bwDir)
		require.NoError(t, lerr)
		assert.Equal(t, "core", persisted.CoreVariant)
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

	// Switching to a totally unknown variant must be rejected without
	// touching the persisted active.
	err := o.SetCoreVariant(context.Background(), "doge")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "unknown core variant")

	assert.Equal(t, "knots", o.CoreVariant())
	persisted, err := LoadSettings(bwDir)
	require.NoError(t, err)
	assert.Equal(t, "knots", persisted.CoreVariant)
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

	// Persist a eCash-only variant, then load orchestrator on signet.
	// "core" is not available on eCash, but it IS valid on signet, so use
	// it inverse here: persist an unknown id to simulate a mismatch.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "stale-id"}))
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	// Persisted ID is preserved on disk.
	assert.Equal(t, "stale-id", o.CoreVariant())

	// Visible list for signet excludes the stale id.
	visible := variantIDs(o.ListCoreVariants())
	assert.NotContains(t, visible, "stale-id")

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

// The active resolver follows the persisted variant into its own subfolder, so
// the CLI and the testharness point at the build the app runs.
func TestIntegration_ActiveCoreBinaryPath(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()

	configs := []BinaryConfig{makeBitcoindCoreConfig("http://unused/")}
	variants := configs[0].Variants

	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "knots"}))
	assert.Equal(t, CoreBinaryPath(dataDir, variants["knots"], "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind", "signet", "drynet4"))

	// A different variant resolves to a different file.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "core"}))
	assert.Equal(t, CoreBinaryPath(dataDir, variants["core"], "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind", "signet", "drynet4"))

	// A variant the catalog dropped falls back to the preferred one the
	// network offers, never to the flat path where any other build can sit.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "gone"}))
	assert.Equal(t, CoreBinaryPath(dataDir, variants[DefaultCoreVariantID], "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind", "signet", "drynet4"))

	// The network clamps the persisted variant: knots is not on eCash, so the
	// path must be the one eCash actually boots.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "knots"}))
	assert.Equal(t, CoreBinaryPath(dataDir, variants["patched"], "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind", "ecash", "drynet4"))

	// Non-bitcoind binaries always use the flat layout.
	other := ActiveCoreBinaryPath(dataDir, bwDir, configs, "enforcer", "signet", "drynet4")
	assert.Equal(t, BinaryPath(dataDir, "enforcer"), other)
}

// Status must report the build the launcher boots. The persisted variant is
// not available on eCash, so status has to follow the same clamp the process
// manager applies, not the raw settings value.
func TestIntegration_Status_FollowsNetworkClamp(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	dataDir := t.TempDir()
	bwDir := t.TempDir()

	first := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	require.NoError(t, first.SetCoreVariant(context.Background(), "knots"))
	require.NoError(t, first.BitcoinConf.UpdateNetwork(config.NetworkECash))

	second := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)
	require.Equal(t, string(config.NetworkECash), second.CurrentNetwork())

	// The knots build is on disk, but eCash does not boot it.
	assert.False(t, second.Status("bitcoind").Downloaded,
		"a variant the network never boots must not read as downloaded")

	coreCfg, err := second.getConfig("bitcoind")
	require.NoError(t, err)
	ch, err := second.download.Download(context.Background(), coreCfg, second.CurrentNetwork(), true)
	require.NoError(t, err)
	for p := range ch {
		require.NoError(t, p.Error)
	}

	patched := coreCfg.Variants["patched"]
	st := second.Status("bitcoind")
	assert.True(t, st.Downloaded)
	assert.Equal(t, CoreBinaryPath(dataDir, patched, "bitcoind"), st.BinaryPath)
}

// The CLI resolves a eCash path from the generation it is given, so the
// subfolder carries that generation instead of the raw placeholder.
func TestIntegration_ActiveCoreBinaryPath_ExpandsECashPlaceholder(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()

	cfg := makeBitcoindCoreConfig("http://unused/")
	cfg.Variants["ecash"] = CoreVariantSpec{
		ID:                "ecash",
		Subfolder:         "{ecash}",
		BaseURL:           "http://unused/",
		Files:             map[string]string{currentPlatform(): "L1-ecash-bitcoin-{ecash}.zip"},
		AvailableNetworks: []string{"ecash"},
	}
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "ecash"}))

	assert.Equal(t, filepath.Join(BinDir(dataDir), "drynet4", "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, []BinaryConfig{cfg}, "bitcoind", "ecash", "drynet4"))

	// The daemon keeps its generation until it restarts, and the confirm
	// writes the next one to the cache at once. The path must follow the
	// daemon, or `wipe bitcoind` deletes a build no process runs.
	require.NoError(t, netcatalog.Save(bwDir, catalogWithECash(t, "drynet5")))
	assert.Equal(t, filepath.Join(BinDir(dataDir), "drynet4", "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, []BinaryConfig{cfg}, "bitcoind", "ecash", "drynet4"))

	// No generation must never leave the placeholder in the path.
	assert.Equal(t, filepath.Join(BinDir(dataDir), netcatalog.EmbeddedECashID(), "bitcoind"),
		ActiveCoreBinaryPath(dataDir, bwDir, []BinaryConfig{cfg}, "bitcoind", "ecash", ""))
}
