// Package testharness provides a reusable integration test harness for the
// wallet stack. It spins up real regtest Bitcoin Core nodes and real
// orchestratord subprocesses so tests exercise the full pipeline: gRPC
// client → orchestratord → Bitcoin Core.
package testharness

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/rs/zerolog"
)

// Harness manages a cluster of test nodes.
type Harness struct {
	Nodes   []*Node
	Datadir string // root temp dir
	log     zerolog.Logger
}

// New creates a Harness with nodeCount fully-wired nodes.
// Each node gets its own bitcoind subprocess, orchestratord subprocess, and
// gRPC client. Tests interact exclusively via the gRPC client.
//
// The harness:
// 1. Builds orchestratord from source (ensures we test current code)
// 2. Finds/downloads bitcoind via orchestrator download logic
// 3. Starts N independent (bitcoind + orchestratord) pairs
func New(t *testing.T, nodeCount int) *Harness {
	t.Helper()

	rootDir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	// Find bitcoind via orchestrator download logic.
	bitcoindBin := findBitcoind(t, log)

	// Build orchestratord from source.
	orchBin := buildOrchestratord(t, rootDir, log)

	h := &Harness{
		Datadir: rootDir,
		log:     log,
	}

	portBase := randomPortBase()
	for i := 0; i < nodeCount; i++ {
		name := fmt.Sprintf("node%d", i)
		rpcPort, p2pPort, grpcPort := testPorts(portBase, i)
		n := newNode(t, name, rootDir, bitcoindBin, orchBin, rpcPort, p2pPort, grpcPort, log)
		h.Nodes = append(h.Nodes, n)
	}

	t.Cleanup(func() { h.Close() })
	return h
}

// Close shuts down all nodes. Idempotent.
func (h *Harness) Close() {
	for _, n := range h.Nodes {
		n.close()
	}
}

// buildOrchestratord compiles the orchestratord binary from source.
func buildOrchestratord(t *testing.T, rootDir string, log zerolog.Logger) string {
	t.Helper()

	binPath := filepath.Join(rootDir, orchBinaryName())

	// Find the orchestratord source directory relative to the testharness package.
	// We're at sidechain-orchestrator/testharness/, cmd is at sidechain-orchestrator/cmd/orchestratord/
	orchSrcDir := filepath.Join(srcDir(), "cmd", "orchestratord")
	if _, err := os.Stat(orchSrcDir); err != nil {
		t.Fatalf("testharness: orchestratord source not found at %s: %v", orchSrcDir, err)
	}

	log.Info().Str("src", orchSrcDir).Str("out", binPath).Msg("building orchestratord")

	cmd := exec.Command("go", "build", "-o", binPath, ".")
	cmd.Dir = orchSrcDir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		t.Fatalf("testharness: build orchestratord: %v", err)
	}

	log.Info().Str("path", binPath).Msg("orchestratord built")
	return binPath
}

// srcDir returns the absolute path to the sidechain-orchestrator root.
func srcDir() string {
	// Use runtime.Caller to find this file's location, then go up one level.
	// testharness/harness.go → sidechain-orchestrator/
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		panic("testharness: cannot determine source directory")
	}
	return filepath.Dir(filepath.Dir(thisFile))
}
