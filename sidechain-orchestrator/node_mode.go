package orchestrator

import (
	"context"
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
	// NodeModeLight uses remote Bitcoin services and local sidechain daemons.
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

// SetNodeMode changes the Bitcoin services and restarts active sidechain daemons.
func (o *Orchestrator) SetNodeMode(ctx context.Context, mode NodeMode) error {
	if mode != NodeModeFull && mode != NodeModeLight {
		return fmt.Errorf("select full or light mode")
	}
	o.swapNetworkMu.Lock()
	defer o.swapNetworkMu.Unlock()
	if o.NodeMode() == mode {
		return WriteNodeMode(o.BitwindowDir, mode)
	}
	if mode == NodeModeLight && !config.SupportsLightMode(config.Network(o.CurrentNetwork())) {
		return fmt.Errorf("%s does not support light mode", o.CurrentNetwork())
	}
	for _, cfg := range o.Configs() {
		if cfg.ChainLayer != 2 && (mode != NodeModeLight || (cfg.Name != "enforcer" && cfg.Name != "bitcoind")) {
			continue
		}
		if o.process.IsAdopted(cfg.Name) && !o.mayStopAdopted(cfg.Name) {
			return fmt.Errorf("stop %s in its own launcher before you change node mode", cfg.Name)
		}
	}

	sidechains := make(map[string]StartOpts)
	for _, cfg := range o.Configs() {
		if cfg.ChainLayer != 2 || !o.process.IsRunning(cfg.Name) {
			continue
		}
		if mode == NodeModeLight {
			spec, known := config.SidechainSpecByName(cfg.Name)
			if cfg.IsBitcoinCore || !known || spec.EnforcerArg == "" {
				return fmt.Errorf("stop %s before you select light mode; it uses local Bitcoin services", cfg.Name)
			}
			if config.RemoteEnforcerURLForNetwork(config.Network(o.CurrentNetwork())) == "" {
				return fmt.Errorf("%s has no remote enforcer endpoint", o.CurrentNetwork())
			}
		}
		opts := StartOpts{ForceBackend: true}
		if proc := o.process.Get(cfg.Name); proc != nil && proc.Cmd != nil {
			opts.TargetArgs = append([]string(nil), proc.Cmd.Args[1:]...)
			opts.TargetEnv = make(map[string]string)
			for _, entry := range proc.Cmd.Env {
				if key, value, ok := strings.Cut(entry, "="); ok {
					opts.TargetEnv[key] = value
				}
			}
		}
		for _, flag := range []string{"--mainchain-grpc-url", "--mainchain-grpc-host", "--mainchain-grpc-port", "--mnemonic-seed-phrase-path"} {
			opts.TargetArgs = replaceCLIFlag(opts.TargetArgs, flag, "")
		}
		sidechains[cfg.Name] = opts
	}
	if mode == NodeModeFull && len(sidechains) > 0 {
		network := config.Network(o.CurrentNetwork())
		if o.BitcoinConf == nil || !o.BitcoinConf.HasDatadirForNetwork(network) {
			return fmt.Errorf("select a Bitcoin data directory for %s before full mode", network)
		}
	}
	for name := range sidechains {
		if err := o.stopForNetworkSwap(ctx, name, StopOptions{ForceBackend: true}); err != nil {
			return err
		}
	}
	if mode == NodeModeLight {
		for _, name := range []string{"enforcer", "bitcoind"} {
			if o.process.IsRunning(name) {
				if err := o.stopForNetworkSwap(ctx, name); err != nil {
					return err
				}
			}
		}
	}
	if err := o.closeRemoteEnforcer(); err != nil {
		return err
	}
	if err := WriteNodeMode(o.BitwindowDir, mode); err != nil {
		return err
	}
	o.syncConnMu.Lock()
	o.enforcerSync = nil
	o.syncConnMu.Unlock()
	for name, opts := range sidechains {
		ch, err := o.StartWithL1(context.Background(), name, opts)
		if err != nil {
			return fmt.Errorf("restart %s: %w", name, err)
		}
		go func() {
			for progress := range ch {
				if progress.Error != nil {
					o.log.Error().Err(progress.Error).Str("binary", name).Msg("sidechain restart failed after the mode change")
					return
				}
			}
		}()
	}
	return nil
}
