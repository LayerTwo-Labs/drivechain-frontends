package testharness

import (
	"os"
	"os/exec"
	"testing"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/rs/zerolog"
)

// findBitcoind locates the bitcoind binary. It checks PATH first (most
// reliable on the current architecture), then the orchestrator's default
// binary location, and skips the test if neither works.
func findBitcoind(t *testing.T, log zerolog.Logger) string {
	t.Helper()

	// 1. PATH lookup — preferred because it respects the host architecture.
	if p, err := exec.LookPath("bitcoind"); err == nil {
		log.Info().Str("path", p).Msg("found bitcoind in PATH")
		return p
	}

	// 2. Orchestrator's default binary location.
	orchPath := orchestrator.BinaryPath(orchestrator.DefaultDataDir(), "bitcoind")
	if _, err := os.Stat(orchPath); err == nil {
		log.Info().Str("path", orchPath).Msg("found bitcoind via orchestrator datadir")
		return orchPath
	}

	// 3. Not found anywhere.
	t.Skip("bitcoind not available (not in PATH or orchestrator datadir)")
	return "" // unreachable
}
