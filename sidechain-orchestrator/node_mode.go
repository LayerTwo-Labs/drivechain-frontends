package orchestrator

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// NodeMode is how much of Bitcoin this install runs.
type NodeMode string

const (
	// NodeModeUnset means the user never picked. The frontend must ask before
	// it boots anything.
	NodeModeUnset NodeMode = ""
	// NodeModeFull runs Bitcoin Core and the enforcer on this machine.
	NodeModeFull NodeMode = "full"
	// NodeModeLight reads the chain from a remote Esplora server and starts no
	// local daemon.
	NodeModeLight NodeMode = "light"
)

const nodeModeFileName = "node_mode"

// ParseNodeMode reads a stored value. Anything unknown reads as unset, so a
// damaged file makes the app ask again rather than boot the wrong stack.
func ParseNodeMode(s string) NodeMode {
	switch NodeMode(strings.ToLower(strings.TrimSpace(s))) {
	case NodeModeFull:
		return NodeModeFull
	case NodeModeLight:
		return NodeModeLight
	default:
		return NodeModeUnset
	}
}

func nodeModePath(bitwindowDir string) string {
	return filepath.Join(bitwindowDir, nodeModeFileName)
}

// ReadNodeMode returns the mode the user picked, or NodeModeUnset.
func ReadNodeMode(bitwindowDir string) NodeMode {
	body, err := os.ReadFile(nodeModePath(bitwindowDir))
	if err != nil {
		return NodeModeUnset
	}
	return ParseNodeMode(string(body))
}

// WriteNodeMode records the user's choice.
func WriteNodeMode(bitwindowDir string, mode NodeMode) error {
	if mode != NodeModeFull && mode != NodeModeLight {
		return fmt.Errorf("node mode %q is neither full nor light", mode)
	}
	if err := os.MkdirAll(bitwindowDir, 0o755); err != nil {
		return fmt.Errorf("create %s: %w", bitwindowDir, err)
	}
	if err := os.WriteFile(nodeModePath(bitwindowDir), []byte(mode), 0o644); err != nil {
		return fmt.Errorf("write node mode: %w", err)
	}
	return nil
}

// NodeModeForNetwork resolves the mode a network can actually run. A network
// with no remote chain server — regtest and testnet — runs full mode whatever
// the file says, so the stored mode never applies there and the user is never
// asked.
func NodeModeForNetwork(mode NodeMode, network config.Network) NodeMode {
	if !config.SupportsLightMode(network) {
		return NodeModeFull
	}
	return mode
}

// NodeMode is the mode this install runs, already narrowed to what the current
// network can serve.
func (o *Orchestrator) NodeMode() NodeMode {
	return NodeModeForNetwork(ReadNodeMode(o.BitwindowDir), config.Network(o.CurrentNetwork()))
}
