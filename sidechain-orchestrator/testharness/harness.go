// Package testharness provides a reusable integration test harness for the
// wallet stack. It spins up real regtest Bitcoin Core nodes, orchestrator
// wallet engines, and ConnectRPC servers so tests can exercise the full
// pipeline from gRPC client through Core RPC.
//
// The package itself carries no build tags so both the orchestrator and
// bitwindow test suites can import it; heavy deps only get compiled when
// a test file with //go:build integration pulls the package in.
package testharness

import (
	"fmt"
	"net"
	"os"
	"path/filepath"
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
// Each node gets its own bitcoind, wallet service, wallet engine, and gRPC
// server. The harness auto-registers t.Cleanup to tear everything down.
func New(t *testing.T, nodeCount int) *Harness {
	t.Helper()

	rootDir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()

	bitcoindBin := findBitcoind(t, log)

	h := &Harness{
		Datadir: rootDir,
		log:     log,
	}

	for i := 0; i < nodeCount; i++ {
		name := fmt.Sprintf("node%d", i)
		nodeDir := filepath.Join(rootDir, name)
		if err := os.MkdirAll(nodeDir, 0700); err != nil {
			t.Fatalf("testharness: mkdir %s: %v", nodeDir, err)
		}

		rpcPort := freePort(t)
		p2pPort := freePort(t)

		n := newNode(t, name, nodeDir, bitcoindBin, rpcPort, p2pPort, log)
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

// freePort asks the OS for an available TCP port.
func freePort(t *testing.T) int {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("testharness: listen for free port: %v", err)
	}
	port := l.Addr().(*net.TCPAddr).Port
	l.Close()
	return port
}
