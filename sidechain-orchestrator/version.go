package orchestrator

import (
	"context"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"time"
)

var versionTripleRe = regexp.MustCompile(`v?(\d+\.\d+\.\d+)`)
var enforcerCommitRe = regexp.MustCompile(`commit:\s*([a-f0-9]+)`)

// BinaryVersion resolves the binary the same way the launcher does (variant-
// and test-build aware, honoring forceBackend) and returns its --version
// output. isTest is true when the resolved path is a Flutter test build, which
// has no --version — callers should show "Test Sidechain" rather than running
// it. Mirrors the former Dart Binary.binaryVersion so the frontend can drop
// its own path-guessing.
func (o *Orchestrator) BinaryVersion(name string, forceBackend bool) (version, binPath string, isTest bool, err error) {
	config, err := o.getConfig(name)
	if err != nil {
		return "", "", false, err
	}

	binPath, pidName := o.process.resolvePaths(config, forceBackend)
	isTest = strings.HasSuffix(pidName, "-test")
	if isTest {
		// Test builds are Flutter app bundles; --version isn't meaningful.
		return "", binPath, true, nil
	}

	if _, statErr := os.Stat(binPath); statErr != nil {
		return "", binPath, false, statErr
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	out, runErr := exec.CommandContext(ctx, binPath, "--version").Output()
	if runErr != nil {
		return "", binPath, false, runErr
	}

	return parseBinaryVersion(config, string(out)), binPath, false, nil
}

// parseBinaryVersion extracts a display version from --version stdout. The
// enforcer prints a multi-line build banner; everything else gets the first
// semver triple, falling back to the first line.
func parseBinaryVersion(config BinaryConfig, output string) string {
	output = strings.TrimSpace(output)
	if output == "" {
		return "Unknown"
	}
	lines := strings.Split(output, "\n")

	if config.BinaryName == "bip300301-enforcer" {
		var versionLine, commitLine string
		for _, l := range lines {
			if strings.Contains(l, "bip300301_enforcer_lib") {
				versionLine = l
			}
			if strings.HasPrefix(strings.TrimSpace(l), "commit:") {
				commitLine = l
			}
		}
		if versionLine == "" {
			return lines[0]
		}
		v := versionTripleRe.FindStringSubmatch(versionLine)
		c := enforcerCommitRe.FindStringSubmatch(commitLine)
		if v != nil && c != nil {
			return v[1] + " (" + c[1] + ")"
		}
		if v != nil {
			return v[1]
		}
		return versionLine
	}

	if v := versionTripleRe.FindStringSubmatch(output); v != nil {
		return v[1]
	}
	return lines[0]
}
