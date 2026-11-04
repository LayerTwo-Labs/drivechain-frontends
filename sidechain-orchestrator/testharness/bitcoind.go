package testharness

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/rs/zerolog"
)

// BinaryCacheDir returns the directory integration tests download managed binaries into.
func BinaryCacheDir(t *testing.T) string {
	t.Helper()
	cache, err := os.UserCacheDir()
	if err != nil {
		t.Fatalf("testharness: user cache dir: %v", err)
	}
	return filepath.Join(cache, "drivechain-test-binaries")
}

// bitcoindBinaryPath returns the on-disk path for a specific Core variant
// from a configs slice. Falls back to the legacy flat layout when the variant
// cannot be resolved (no bitcoincore entry, missing variant id).
func bitcoindBinaryPath(dataDir string, configs []orchestrator.BinaryConfig, variantID string) string {
	for _, c := range configs {
		if !c.IsMainchainCore() {
			continue
		}
		if v, ok := c.Variants[variantID]; ok {
			return orchestrator.CoreBinaryPath(dataDir, v, "bitcoind")
		}
	}
	return orchestrator.BinaryPath(dataDir, "bitcoind")
}

// findBitcoind locates or downloads the bitcoind binary using the orchestrator's
// download logic. This is the same path as `drivechain-cli download bitcoind`.
//
// No fallbacks. Either the orchestrator download works or the test fails.
func findBitcoind(t *testing.T, log zerolog.Logger) string {
	t.Helper()

	// An explicit binary wins over the download logic — used to run against a
	// specific build (e.g. stock vs. replay-patched bitcoind).
	if bin := os.Getenv("BITCOIND_BIN"); bin != "" {
		log.Info().Str("path", bin).Msg("using bitcoind from BITCOIND_BIN")
		return bin
	}

	dataDir := BinaryCacheDir(t)
	// Testharness uses the default ("patched") variant unconditionally — it
	// always wants the drivechain build, regardless of whatever the user has
	// pinned in orchestrator_settings.json.
	configs := orchestrator.AllDefaults()
	orchPath := bitcoindBinaryPath(dataDir, configs, orchestrator.DefaultCoreVariantID)

	// Check if already downloaded and working.
	if _, err := os.Stat(orchPath); err == nil {
		if err := runVersion(orchPath); err == nil {
			log.Info().Str("path", orchPath).Msg("found working bitcoind via orchestrator")
			return orchPath
		}
		log.Warn().Str("path", orchPath).Msg("bitcoind exists but won't execute — re-downloading")
	}

	// Download using orchestrator's download logic.
	log.Info().Msg("downloading bitcoind via orchestrator...")

	configPath := orchestrator.ConfigFilePath(dataDir)
	configs = orchestrator.LoadConfigFile(configPath, log)

	var bitcoindConfig *orchestrator.BinaryConfig
	for i := range configs {
		if configs[i].Name == "bitcoind" {
			bitcoindConfig = &configs[i]
			break
		}
	}
	if bitcoindConfig == nil {
		t.Fatal("testharness: bitcoind not configured in orchestrator — cannot download")
	}

	dm := orchestrator.NewDownloadManager(dataDir, log)
	dm.CoreVariant = func() (orchestrator.CoreVariantSpec, bool) {
		v, ok := bitcoindConfig.Variants[orchestrator.DefaultCoreVariantID]
		return v, ok
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	force := false
	if _, err := os.Stat(orchPath); err == nil {
		force = true // re-download broken binary
	}

	progressCh, err := dm.Download(ctx, *bitcoindConfig, "regtest", force)
	if err != nil {
		t.Fatalf("testharness: start bitcoind download: %v", err)
	}

	for p := range progressCh {
		if p.Error != nil {
			t.Fatalf("testharness: bitcoind download failed: %v", p.Error)
		}
		if p.MBTotal > 0 && p.MBDownloaded > 0 {
			pct := float64(p.MBDownloaded) / float64(p.MBTotal) * 100
			if int(pct)%10 == 0 {
				log.Info().Float64("pct", pct).Msg("downloading bitcoind")
			}
		}
		if p.Done {
			log.Info().Str("path", p.Message).Msg("bitcoind download complete")
		}
	}

	// Verify it exists and runs.
	if _, err := os.Stat(orchPath); err != nil {
		t.Fatalf("testharness: bitcoind not found at %s after download", orchPath)
	}

	if err := runVersion(orchPath); err != nil {
		hint := ""
		if runtime.GOOS == "darwin" {
			hint = " (is Rosetta installed?)"
		}
		t.Fatalf("testharness: bitcoind downloaded to %s but won't execute: %v%s", orchPath, err, hint)
	}

	log.Info().Str("path", orchPath).Msg("bitcoind ready")
	return orchPath
}

// versionTimeout covers the first start of a new binary, which Windows Defender scans.
const versionTimeout = 60 * time.Second

func runVersion(path string) error {
	ctx, cancel := context.WithTimeout(context.Background(), versionTimeout)
	defer cancel()
	if err := exec.CommandContext(ctx, path, "--version").Run(); err != nil {
		if ctx.Err() != nil {
			return fmt.Errorf("--version took more than %s: %w", versionTimeout, err)
		}
		return err
	}
	return nil
}
