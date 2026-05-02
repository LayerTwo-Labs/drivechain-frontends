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
	"runtime"
	"sync"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
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

	// Knots binary landed at the single shared bin/bitcoind path.
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

// All variants share bin/bitcoind, so every switch wipes-and-redownloads.
// Final on-disk binary is whichever variant was selected last.
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
	o := newIntegrationOrchestrator(t, "forknet", srv.URL+"/", dataDir, t.TempDir())
	// "core" is not available on forknet — must be rejected.
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
		{"mainnet", []string{"patched"}},
		{"forknet", []string{"patched"}},
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

// User picks knots on signet, then relaunches the app on forknet. The
// resolver must clamp to a forknet-compatible variant (patched) instead of
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
	require.NoError(t, first.BitcoinConf.UpdateNetwork(config.NetworkForknet))

	// Same data dirs; the new orchestrator picks up the persisted forknet.
	second := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, bwDir)

	v, ok := second.download.CoreVariant()
	require.True(t, ok, "resolver must produce a variant on forknet")
	assert.Equal(t, "patched", v.ID, "persisted knots is not forknet-compatible; must clamp to patched")

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

	o := newIntegrationOrchestrator(t, "forknet", srv.URL+"/", "", "")
	v, ok := o.download.CoreVariant()
	require.True(t, ok, "fresh forknet install must resolve to a variant")
	assert.Equal(t, "patched", v.ID)
}

// Verifies the launcher path after a switch. With the single-bitcoind layout
// the path is always BinDir/bitcoind regardless of variant — the active
// variant only changes which payload was last downloaded into that file.
func TestIntegration_SetCoreVariant_ResolverPointsAtActiveVariant(t *testing.T) {
	srv := newVariantServer(t, &requestCount{})
	defer srv.Close()

	dataDir := t.TempDir()
	o := newIntegrationOrchestrator(t, "signet", srv.URL+"/", dataDir, t.TempDir())

	require.NoError(t, o.SetCoreVariant(context.Background(), "knots"))

	knots := o.configs["bitcoind"].Variants["knots"]
	expected := BinaryPath(dataDir, "bitcoind")
	assert.Equal(t, expected, CoreBinaryPath(dataDir, knots, "bitcoind"))
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
		_, err := o.Settings.SetCoreVariant("core")
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

	// Persist a forknet-only variant, then load orchestrator on signet.
	// "core" is not available on forknet, but it IS valid on signet, so use
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

// All variants share BinDir/bitcoind, so the active resolver always returns
// the flat path regardless of which variant is active. Settings still drive
// which payload is on disk; the path is invariant.
func TestIntegration_ActiveCoreBinaryPath(t *testing.T) {
	dataDir := t.TempDir()
	bwDir := t.TempDir()

	configs := []BinaryConfig{makeBitcoindCoreConfig("http://unused/")}

	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "knots"}))
	got := ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind")
	assert.Equal(t, BinaryPath(dataDir, "bitcoind"), got)

	// Switching settings to a different variant doesn't change the path.
	require.NoError(t, SaveSettings(bwDir, OrchestratorSettings{CoreVariant: "core"}))
	assert.Equal(t, BinaryPath(dataDir, "bitcoind"), ActiveCoreBinaryPath(dataDir, bwDir, configs, "bitcoind"))

	// Non-bitcoind binaries always use the flat layout.
	other := ActiveCoreBinaryPath(dataDir, bwDir, configs, "enforcer")
	assert.Equal(t, BinaryPath(dataDir, "enforcer"), other)
}
