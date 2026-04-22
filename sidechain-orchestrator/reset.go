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

	for _, dc := range targets {
		// Use the network-aware datadir so we hit bitcoind's signet/ subdir
		// (blocks, chainstate, wallets) and bitwindowd's signet/ subdir
		// (bitwindow.db, wallet.json). Other binaries get the flat root.
		networkDir := dc.DatadirNetwork(network, bitcoinOverride)

		if cat.DeleteBlockchainData {
			result["blockchain_data"] = append(result["blockchain_data"],
				dc.GetBlockchainDataPaths(networkDir, network, o.log)...)
		}
		if cat.DeleteNodeSoftware {
			result["node_software"] = append(result["node_software"],
				dc.GetBinaryPaths(binDir, o.log)...)
		}
		if cat.DeleteLogs {
			result["logs"] = append(result["logs"],
				dc.GetLogPaths(networkDir, o.log)...)
		}
		if cat.DeleteSettings {
			result["settings"] = append(result["settings"],
				dc.GetSettingsPaths(networkDir, network, o.log)...)
		}
		if cat.DeleteWalletFiles {
			result["wallet"] = append(result["wallet"],
				dc.GetWalletPaths(networkDir, network, o.log)...)
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
	// Stop all managed binaries before touching anything on disk.
	shutdownCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
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

	// Small grace period for file handles to be released.
	time.Sleep(2 * time.Second)

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
