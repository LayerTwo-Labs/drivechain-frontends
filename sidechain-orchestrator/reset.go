package orchestrator

import (
	"context"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// Deletion categories. These string keys map 1:1 to the proto DeletionType
// enum (converted in the API handler) and select which getter on
// config.BinaryDirConfig is used.
const (
	catData     = "blockchain_data"
	catSoftware = "node_software"
	catLogs     = "logs"
	catSettings = "settings"
	catWallet   = "wallet"
)

// GatherSpec is one binary plus the categories of its data to gather.
type GatherSpec struct {
	BinaryName string // resolvable by config.DirConfigByName (JSON key / name / binary name)
	Categories []string
}

// ResetFileInfo describes a single file/directory that a reset would affect.
type ResetFileInfo struct {
	Path        string
	Category    string
	BinaryName  string
	SizeBytes   int64
	IsDirectory bool
}

// DeleteEvent is emitted for each path during DeleteFiles. Error is empty when
// the path was removed (or moved to backup) successfully.
type DeleteEvent struct {
	Path  string
	Error string
}

// GatherFilesToDelete resolves, per binary, the on-disk paths for each
// requested category. No side effects. The returned list is deduplicated by
// path so a file shared between two categories (e.g. a frontend wallet.json
// that shows up under both settings and wallet) is only listed once.
func (o *Orchestrator) GatherFilesToDelete(specs []GatherSpec) ([]ResetFileInfo, error) {
	network := config.Network(o.Network)
	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}
	binDir := BinDir(o.BitwindowDir)

	var files []ResetFileInfo
	seen := make(map[string]bool)

	add := func(cat, binaryName string, paths []string) {
		for _, p := range paths {
			if p == "" || seen[p] {
				continue
			}
			seen[p] = true
			info := ResetFileInfo{Path: p, Category: cat, BinaryName: binaryName}
			if fi, err := os.Stat(p); err == nil {
				info.IsDirectory = fi.IsDir()
				if !fi.IsDir() {
					info.SizeBytes = fi.Size()
				}
			}
			files = append(files, info)
		}
	}

	for _, spec := range specs {
		dc, ok := config.DirConfigByName(spec.BinaryName)
		if !ok {
			o.log.Warn().Str("binary", spec.BinaryName).Msg("gather: unknown binary, skipping")
			continue
		}
		networkDir := dc.DatadirNetwork(network, bitcoinOverride)

		for _, cat := range spec.Categories {
			switch cat {
			case catData:
				add(cat, spec.BinaryName, dc.GetBlockchainDataPaths(networkDir, network, o.log))
			case catSoftware:
				add(cat, spec.BinaryName, dc.GetBinaryPaths(binDir, o.log))
			case catLogs:
				add(cat, spec.BinaryName, dc.GetLogPaths(networkDir, o.log))
			case catSettings:
				add(cat, spec.BinaryName, dc.GetSettingsPaths(networkDir, network, o.log))
			case catWallet:
				add(cat, spec.BinaryName, dc.GetWalletPaths(networkDir, network, o.log))
				// bitwindowd's master wallet lives at the flat <bitwindowDir>/
				// wallet.json, which the network-scoped getter above doesn't
				// cover. Include it so a full wallet wipe backs it up too.
				if dc.BinaryName == "bitwindowd" && o.WalletSvc != nil {
					add(cat, spec.BinaryName, o.WalletSvc.MasterWalletPaths())
				}
			}
		}
	}

	return files, nil
}

// DeleteFiles stops all binaries, then removes each path. Wallet paths are
// moved to wallet_backups/ instead of being removed — keys are irreplaceable.
// Each path is reported on the returned channel; an empty Error means success.
// A returned error means deletion couldn't start at all (e.g. shutdown failed).
//
// Callers must pass only paths produced by GatherFilesToDelete. The RPC handler
// enforces this by re-resolving the request's specs server-side rather than
// trusting client-supplied paths.
func (o *Orchestrator) DeleteFiles(ctx context.Context, paths []string) (<-chan DeleteEvent, error) {
	// Any path could belong to a running daemon; stop them all first.
	running := o.process.ListRunning()
	shutdownBudget := gracefulKillTimeout * time.Duration(len(running)+2)
	shutdownCtx, cancel := context.WithTimeout(ctx, shutdownBudget)
	defer cancel()

	ch, err := o.ShutdownAll(shutdownCtx, false)
	if err != nil {
		return nil, fmt.Errorf("shutdown binaries: %w", err)
	}
	for p := range ch {
		if p.Error != nil {
			return nil, fmt.Errorf("shutdown binaries: %w", p.Error)
		}
	}

	// Windows keeps handles briefly after force-kill; wait before removing.
	time.Sleep(postKillFileLockGrace)

	// Any path that is a known wallet location gets moved to backup rather than
	// hard-deleted. Computed across every binary so a wallet path can never slip
	// through to os.RemoveAll.
	walletSet := o.allWalletPaths()
	masterSet := map[string]bool{}
	if o.WalletSvc != nil {
		for _, p := range o.WalletSvc.MasterWalletPaths() {
			masterSet[p] = true
		}
	}

	events := make(chan DeleteEvent, len(paths)+1)
	go func() {
		defer close(events)

		masterTouched := false
		for _, p := range paths {
			evt := DeleteEvent{Path: p}
			if isWalletPath(p, walletSet) {
				// Wallets are moved aside, never removed — keys are irreplaceable.
				if o.WalletSvc != nil {
					if _, err := o.WalletSvc.BackupPath(p); err != nil {
						evt.Error = err.Error()
					}
				}
				if masterSet[p] {
					masterTouched = true
				}
			} else {
				if err := os.RemoveAll(p); err != nil && !os.IsNotExist(err) {
					evt.Error = err.Error()
				}
			}
			events <- evt
		}

		// The orchestrator caches the master wallet in memory; once it's been
		// moved aside, drop that state so the service reflects the wipe.
		if masterTouched && o.WalletSvc != nil {
			o.WalletSvc.ClearInMemoryState()
		}
	}()

	return events, nil
}

// isWalletPath decides whether a path must be moved to backup rather than
// removed. It first trusts the authoritative set computed from config, then
// falls back to conservative name/segment heuristics. Over-classifying a path
// as a wallet is harmless (it just leaves a recoverable backup); the one thing
// that must never happen is a wallet slipping through to os.RemoveAll, so the
// fallbacks deliberately err toward "this is a wallet".
func isWalletPath(p string, walletSet map[string]bool) bool {
	if walletSet[p] {
		return true
	}
	// Normalise Windows backslashes + case, host-independently (filepath.ToSlash
	// is a no-op on POSIX hosts, so do the replace manually) so the checks below
	// hold for every platform's path shape.
	lower := strings.ToLower(strings.ReplaceAll(p, `\`, "/"))

	// Known wallet files, anywhere in the tree.
	for _, name := range []string{"wallet.mdb", "wallet.dat", "wallet.json", "wallet_encryption.json"} {
		if lower == name || strings.HasSuffix(lower, "/"+name) {
			return true
		}
	}

	// Wallet directories: bitcoind's `wallets/`, the enforcer's `wallet/<net>`.
	return strings.Contains(lower, "/wallet/") || strings.HasSuffix(lower, "/wallet") ||
		strings.Contains(lower, "/wallets/") || strings.HasSuffix(lower, "/wallets")
}

// allWalletPaths is the set of every binary's wallet locations for the current
// network, used by DeleteFiles to decide move-to-backup vs. hard-delete.
func (o *Orchestrator) allWalletPaths() map[string]bool {
	network := config.Network(o.Network)
	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}

	set := make(map[string]bool)
	for _, dc := range config.AllDirConfigs() {
		for _, p := range dc.GetWalletPaths(dc.DatadirNetwork(network, bitcoinOverride), network, o.log) {
			set[p] = true
		}
	}
	if o.WalletSvc != nil {
		for _, p := range o.WalletSvc.MasterWalletPaths() {
			set[p] = true
		}
	}
	return set
}

// BinaryWalletPaths returns the per-binary on-disk wallet locations that the
// wallet service's pre-deletion sweep removes. Mirrors the path enumeration
// GatherFilesToDelete uses so the sweep agrees with the file-by-file pass.
func (o *Orchestrator) BinaryWalletPaths() []string {
	network := config.Network(o.Network)
	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}

	var paths []string
	for _, cfg := range o.Configs() {
		dirConfig, ok := config.DirConfigByName(cfg.Name)
		if !ok {
			continue
		}
		paths = append(paths, dirConfig.GetWalletPaths(dirConfig.DatadirNetwork(network, bitcoinOverride), network, o.log)...)
	}
	return paths
}
