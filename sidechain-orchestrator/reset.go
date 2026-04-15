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

// ResetResult holds the outcome of a ResetData operation.
type ResetResult struct {
	DeletedItems []ResetItem
	FailedItems  []ResetItem
}

// ResetItem is a single file/directory that was targeted for deletion.
type ResetItem struct {
	Path  string
	Error string
}

// ResetData stops affected binaries, then deletes data according to the requested
// categories. Fails hard: any deletion error is recorded and returned (no best-effort
// swallowing). Returns the list of successfully deleted and failed items.
func (o *Orchestrator) ResetData(ctx context.Context, cat ResetCategory) (*ResetResult, error) {
	network := config.Network(o.Network)

	// Determine which binaries are in scope.
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
	// We pass nil for onStatusUpdate and beforeBoot since the orchestrator
	// already handled shutdown above.
	if cat.DeleteWalletFiles && o.WalletSvc != nil {
		// Temporarily disable the stop-all callback since we already stopped.
		origStop := o.WalletSvc.OnStopAllBinaries
		o.WalletSvc.OnStopAllBinaries = nil
		err := o.WalletSvc.DeleteAllWallets(nil, nil)
		o.WalletSvc.OnStopAllBinaries = origStop
		if err != nil {
			return nil, fmt.Errorf("delete wallet data: %w", err)
		}
	}

	// Collect all paths per category.
	var paths []string
	binDir := BinDir(o.BitwindowDir)

	for _, dc := range targets {
		networkDir := dc.RootDirNetwork(network)

		if cat.DeleteBlockchainData {
			paths = append(paths, dc.GetBlockchainDataPaths(networkDir, network, o.log)...)
		}
		if cat.DeleteNodeSoftware {
			paths = append(paths, dc.GetBinaryPaths(binDir, o.log)...)
		}
		if cat.DeleteLogs {
			paths = append(paths, dc.GetLogPaths(networkDir, o.log)...)
		}
		if cat.DeleteSettings {
			paths = append(paths, dc.GetSettingsPaths(networkDir, network, o.log)...)
		}
		if cat.DeleteWalletFiles {
			paths = append(paths, dc.GetWalletPaths(networkDir, network, o.log)...)
		}
	}

	// Deduplicate.
	seen := make(map[string]bool, len(paths))
	var unique []string
	for _, p := range paths {
		if !seen[p] {
			seen[p] = true
			unique = append(unique, p)
		}
	}

	result := &ResetResult{}

	for _, p := range unique {
		if err := os.RemoveAll(p); err != nil && !os.IsNotExist(err) {
			result.FailedItems = append(result.FailedItems, ResetItem{
				Path:  p,
				Error: err.Error(),
			})
		} else {
			result.DeletedItems = append(result.DeletedItems, ResetItem{Path: p})
		}
	}

	// If node software was deleted, re-copy bundled binaries from assets.
	if cat.DeleteNodeSoftware {
		// Re-download will be handled by the frontend reboot flow.
		o.log.Info().Msg("node software deleted; frontend should trigger re-download")
	}

	if len(result.FailedItems) > 0 {
		return result, fmt.Errorf("failed to delete %d items", len(result.FailedItems))
	}

	return result, nil
}
