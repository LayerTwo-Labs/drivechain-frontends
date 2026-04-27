package orchestrator

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// ResetCategory defines which data categories to delete.
type ResetCategory struct {
	DeleteBlockchainData bool
	DeleteNodeSoftware   bool
	DeleteLogs           bool
	DeleteSettings       bool
	DeleteWalletFiles    bool
	AlsoResetSidechains  bool
}

// ResetFileInfo describes a single file/directory that would be affected by a reset.
type ResetFileInfo struct {
	Path        string
	Category    string
	SizeBytes   int64
	IsDirectory bool
}

// ResetEvent is emitted for each file deletion during a streaming reset.
type ResetEvent struct {
	Path         string
	Category     string
	Success      bool
	Error        string
	Done         bool
	DeletedCount int
	FailedCount  int
}

type pathEntry struct {
	path     string
	category string
}

func dirExists(p string) bool {
	if p == "" {
		return false
	}
	info, err := os.Stat(p)
	return err == nil && info.IsDir()
}

// collectPathEntries returns the deduplicated, deterministic list that preview
// and deletion MUST share — otherwise their counts diverge and the UI desyncs.
func (o *Orchestrator) collectPathEntries(cat ResetCategory) []pathEntry {
	pathsByCategory := o.collectPaths(cat)
	order := []string{"blockchain_data", "node_software", "logs", "settings", "wallet"}

	var entries []pathEntry
	seen := make(map[string]bool)
	for _, category := range order {
		for _, p := range pathsByCategory[category] {
			if seen[p] {
				continue
			}
			seen[p] = true
			entries = append(entries, pathEntry{path: p, category: category})
		}
	}
	return entries
}

// categoryLabel maps category flags to human-readable labels.
func categoryLabel(cat string) string {
	switch cat {
	case "blockchain_data":
		return "blockchain_data"
	case "node_software":
		return "node_software"
	case "logs":
		return "logs"
	case "settings":
		return "settings"
	case "wallet":
		return "wallet"
	default:
		return cat
	}
}

// collectPaths gathers all paths per category for the given reset categories.
func (o *Orchestrator) collectPaths(cat ResetCategory) map[string][]string {
	network := config.Network(o.Network)
	result := make(map[string][]string)

	var targets []config.BinaryDirConfig
	for _, cfg := range o.Configs() {
		dirCfg, ok := config.DirConfigByName(cfg.Name)
		if !ok {
			continue
		}
		if cfg.IsSidechain() && !cat.AlsoResetSidechains {
			continue
		}
		targets = append(targets, dirCfg)
	}

	binDir := BinDir(o.BitwindowDir)

	// User may have overridden bitcoind's datadir in bitwindow-bitcoin.conf;
	// honour that so reset targets the right place on disk.
	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}

	// Audit log so users can see exactly which paths the preview
	// considered vs. found. Critical for diagnosing "reset listed 12 items
	// but my data dir has way more" reports.
	o.log.Info().
		Str("network", string(network)).
		Str("bitcoin_override", bitcoinOverride).
		Str("bin_dir", binDir).
		Int("targets", len(targets)).
		Bool("also_sidechains", cat.AlsoResetSidechains).
		Msg("reset-preview: begin walk")

	for _, dc := range targets {
		// Use the network-aware datadir so we hit bitcoind's signet/ subdir
		// (blocks, chainstate, wallets) and bitwindowd's signet/ subdir
		// (bitwindow.db, wallet.json). Other binaries get the flat root.
		networkDir := dc.DatadirNetwork(network, bitcoinOverride)
		rootDir := dc.RootDirNetwork(network)
		flutter := dc.FlutterFrontendPath()

		o.log.Info().
			Str("binary", dc.BinaryName).
			Str("network_dir", networkDir).
			Str("root_dir", rootDir).
			Str("flutter_dir", flutter).
			Bool("network_dir_exists", dirExists(networkDir)).
			Bool("root_dir_exists", dirExists(rootDir)).
			Bool("flutter_dir_exists", dirExists(flutter)).
			Msg("reset-preview: inspect binary")

		logFound := func(category string, paths []string) {
			if len(paths) == 0 {
				o.log.Info().Str("binary", dc.BinaryName).Str("category", category).Msg("reset-preview: no paths found")
				return
			}
			o.log.Info().Str("binary", dc.BinaryName).Str("category", category).Int("count", len(paths)).Strs("paths", paths).Msg("reset-preview: paths found")
		}

		if cat.DeleteBlockchainData {
			p := dc.GetBlockchainDataPaths(networkDir, network, o.log)
			result["blockchain_data"] = append(result["blockchain_data"], p...)
			logFound("blockchain_data", p)
		}
		if cat.DeleteNodeSoftware {
			p := dc.GetBinaryPaths(binDir, o.log)
			result["node_software"] = append(result["node_software"], p...)
			logFound("node_software", p)
		}
		if cat.DeleteLogs {
			p := dc.GetLogPaths(networkDir, o.log)
			result["logs"] = append(result["logs"], p...)
			logFound("logs", p)
		}
		if cat.DeleteSettings {
			p := dc.GetSettingsPaths(networkDir, network, o.log)
			result["settings"] = append(result["settings"], p...)
			logFound("settings", p)
		}
		if cat.DeleteWalletFiles {
			p := dc.GetWalletPaths(networkDir, network, o.log)
			result["wallet"] = append(result["wallet"], p...)
			logFound("wallet", p)
		}
	}

	// Deduplicate within each category.
	for cat, paths := range result {
		seen := make(map[string]bool, len(paths))
		var unique []string
		for _, p := range paths {
			if !seen[p] {
				seen[p] = true
				unique = append(unique, p)
			}
		}
		result[cat] = unique
	}

	return result
}

// PreviewResetData returns the list of files/directories that would be deleted
// for the given categories, without performing any deletions.
func (o *Orchestrator) PreviewResetData(cat ResetCategory) ([]ResetFileInfo, error) {
	entries := o.collectPathEntries(cat)

	var files []ResetFileInfo
	for _, e := range entries {
		info := ResetFileInfo{
			Path:     e.path,
			Category: e.category,
		}
		if fi, err := os.Stat(e.path); err == nil {
			info.IsDirectory = fi.IsDir()
			if !fi.IsDir() {
				info.SizeBytes = fi.Size()
			}
		}
		files = append(files, info)
	}

	return files, nil
}

// StreamResetData stops affected binaries, then deletes data file-by-file,
// sending each deletion event to the returned channel. The final event has
// Done=true with summary counts.
func (o *Orchestrator) StreamResetData(ctx context.Context, cat ResetCategory) (<-chan ResetEvent, error) {
	// Budget grows with dependency-chain length; ShutdownAll is sequential.
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

	// Windows keeps handles briefly after force-kill; wait before RemoveAll.
	time.Sleep(postKillFileLockGrace)

	// Wallet deletion via WalletSvc (must happen while Core is down).
	if cat.DeleteWalletFiles && o.WalletSvc != nil {
		origStop := o.WalletSvc.OnStopAllBinaries
		o.WalletSvc.OnStopAllBinaries = nil
		err := o.WalletSvc.DeleteAllWallets(nil, nil)
		o.WalletSvc.OnStopAllBinaries = origStop
		if err != nil {
			return nil, fmt.Errorf("delete wallet data: %w", err)
		}
	}

	entries := o.collectPathEntries(cat)

	events := make(chan ResetEvent, len(entries)+1)

	go func() {
		defer close(events)

		deleted := 0
		failed := 0

		for _, entry := range entries {
			evt := ResetEvent{
				Path:     entry.path,
				Category: entry.category,
			}

			if err := os.RemoveAll(entry.path); err != nil && !os.IsNotExist(err) {
				evt.Success = false
				evt.Error = err.Error()
				failed++
			} else {
				evt.Success = true
				deleted++
			}

			evt.DeletedCount = deleted
			evt.FailedCount = failed
			events <- evt
		}

		// Final summary event.
		events <- ResetEvent{
			Done:         true,
			DeletedCount: deleted,
			FailedCount:  failed,
		}

		if cat.DeleteNodeSoftware {
			o.log.Info().Msg("node software deleted; frontend should trigger re-download")
		}
	}()

	return events, nil
}

// BinaryWalletPaths returns the per-binary on-disk wallet locations that a
// "Delete Wallet Files" / "Fully Obliterate" reset must remove. Mirrors the
// path enumeration used by collectPaths/StreamResetData so the wallet
// service's pre-deletion sweep agrees with the file-by-file pass that runs
// after — without that agreement, the sweep can miss `<datadir>/<network>/
// wallets/` while the second pass deletes blockchain data, leaving
// the user's wallet alive against an empty chain (issue #1627).
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
