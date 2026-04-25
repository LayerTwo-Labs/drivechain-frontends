package testharness

import (
	"context"
	"os"
	"os/exec"
	"testing"
	"time"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/rs/zerolog"
)

// bitcoindBinaryPath returns the on-disk path for a specific Core variant
// from a configs slice. Falls back to the legacy flat layout when the variant
// cannot be resolved (no bitcoincore entry, missing variant id).
func bitcoindBinaryPath(dataDir string, configs []orchestrator.BinaryConfig, variantID string) string {
	for _, c := range configs {
		if !c.IsBitcoinCore {
			continue
		}
		if v, ok := c.Variants[variantID]; ok {
			return orchestrator.CoreBinaryPath(dataDir, v, "bitcoind")
		}
	}
	return orchestrator.BinaryPath(dataDir, "bitcoind")
}

// findBitcoind locates or downloads the bitcoind binary using the orchestrator's
// download logic. This is the same path as `orchestratorctl download bitcoind`.
//
// No fallbacks. Either the orchestrator download works or the test fails.
func findBitcoind(t *testing.T, log zerolog.Logger) string {
	t.Helper()

	dataDir := orchestrator.DefaultDataDir()
	// Testharness uses the default ("touched") variant unconditionally — it
	// always wants the drivechain build, regardless of whatever the user has
	// pinned in orchestrator_settings.json.
	configs := orchestrator.AllDefaults()
	orchPath := bitcoindBinaryPath(dataDir, configs, orchestrator.DefaultCoreVariantID)

	// Check if already downloaded and working.
	if _, err := os.Stat(orchPath); err == nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := exec.CommandContext(ctx, orchPath, "--version").Run(); err == nil {
			log.Info().Str("path", orchPath).Msg("found working bitcoind via orchestrator")
			return orchPath
		}
		log.Warn().Str("path", orchPath).Msg("bitcoind exists but won't execute — re-downloading")
	}

	// Download using orchestrator's download logic.
	log.Info().Msg("downloading bitcoind via orchestrator...")

	configPath := orchestrator.ConfigFilePath(orchestrator.DefaultBitwindowDir())
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

	dm := orchestrator.NewDownloadManager(dataDir, configPath, log)
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
		if p.TotalBytes > 0 && p.BytesDownloaded > 0 {
			pct := float64(p.BytesDownloaded) / float64(p.TotalBytes) * 100
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

	verifyCtx, verifyCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer verifyCancel()
	if err := exec.CommandContext(verifyCtx, orchPath, "--version").Run(); err != nil {
		t.Fatalf("testharness: bitcoind downloaded to %s but won't execute: %v (is Rosetta installed?)", orchPath, err)
	}

	log.Info().Str("path", orchPath).Msg("bitcoind ready")
	return orchPath
}
