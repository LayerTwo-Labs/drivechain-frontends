package orchestrator

import (
	"context"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// ResetCategory maps 1:1 to the proto DeletionType enum and selects which
// getter on config.BinaryDirConfig is used.
type ResetCategory int

const (
	ResetCategoryData ResetCategory = iota
	ResetCategorySoftware
	ResetCategoryLogs
	ResetCategorySettings
	ResetCategoryWallet
)

const (
	catData     = ResetCategoryData
	catSoftware = ResetCategorySoftware
	catLogs     = ResetCategoryLogs
	catSettings = ResetCategorySettings
	catWallet   = ResetCategoryWallet
)

// ResetBinary is the typed reset graph. Keep these values hardcoded and small:
// they are safer to reason about than free-form process names in reset logic.
type ResetBinary int

const (
	ResetBinaryUnknown ResetBinary = iota
	ResetBinaryBitcoind
	ResetBinaryEnforcer
	ResetBinaryBitwindowd
	ResetBinaryThunder
	ResetBinaryZSide
	ResetBinaryBitNames
	ResetBinaryBitAssets
	ResetBinaryTruthcoin
	ResetBinaryPhoton
	ResetBinaryCoinShift
	ResetBinaryGRPCurl
	ResetBinaryOrchestratord
	ResetBinaryZSided
)

// GatherSpec is one binary plus the categories of its data to gather.
type GatherSpec struct {
	Binary     ResetBinary
	Categories []ResetCategory
}

// ResetFileInfo describes a single file/directory that a reset would affect.
type ResetFileInfo struct {
	Path        string
	Category    ResetCategory
	Binary      ResetBinary
	SizeBytes   int64
	IsDirectory bool
}

// DeleteEvent is emitted for each path during DeleteFiles. Error is empty when
// the path was removed (or moved to backup) successfully.
type DeleteEvent struct {
	Path  string
	Error string
}

func (b ResetBinary) processName() string {
	switch b {
	case ResetBinaryBitcoind:
		return "bitcoind"
	case ResetBinaryEnforcer:
		return "enforcer"
	case ResetBinaryBitwindowd:
		return "bitwindowd"
	case ResetBinaryThunder:
		return "thunder"
	case ResetBinaryZSide:
		return "zside"
	case ResetBinaryBitNames:
		return "bitnames"
	case ResetBinaryBitAssets:
		return "bitassets"
	case ResetBinaryTruthcoin:
		return "truthcoin"
	case ResetBinaryPhoton:
		return "photon"
	case ResetBinaryCoinShift:
		return "coinshift"
	case ResetBinaryGRPCurl:
		return "grpcurl"
	case ResetBinaryOrchestratord:
		return "orchestratord"
	case ResetBinaryZSided:
		return "zsided"
	default:
		return ""
	}
}

func (b ResetBinary) dirConfig() (config.BinaryDirConfig, bool) {
	switch b {
	case ResetBinaryBitcoind:
		return config.BitcoinCoreDirs, true
	case ResetBinaryEnforcer:
		return config.EnforcerDirs, true
	case ResetBinaryBitwindowd:
		return config.BitWindowDirs, true
	case ResetBinaryThunder:
		return config.ThunderDirs, true
	case ResetBinaryZSide:
		return config.ZSideDirs, true
	case ResetBinaryBitNames:
		return config.BitNamesDirs, true
	case ResetBinaryBitAssets:
		return config.BitAssetsDirs, true
	case ResetBinaryTruthcoin:
		return config.TruthcoinDirs, true
	case ResetBinaryPhoton:
		return config.PhotonDirs, true
	case ResetBinaryCoinShift:
		return config.CoinShiftDirs, true
	default:
		return config.BinaryDirConfig{}, false
	}
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

	add := func(cat ResetCategory, binary ResetBinary, paths []string) {
		for _, p := range paths {
			if p == "" || seen[p] {
				continue
			}
			seen[p] = true
			info := ResetFileInfo{Path: p, Category: cat, Binary: binary}
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
		dc, ok := spec.Binary.dirConfig()
		if !ok {
			o.log.Warn().Int("binary", int(spec.Binary)).Msg("gather: unknown binary, skipping")
			continue
		}
		networkDir := dc.DatadirNetwork(network, bitcoinOverride)

		for _, cat := range spec.Categories {
			switch cat {
			case catData:
				add(cat, spec.Binary, dc.GetBlockchainDataPaths(networkDir, network, o.log))
			case catSoftware:
				add(cat, spec.Binary, dc.GetBinaryPaths(binDir, o.log))
			case catLogs:
				add(cat, spec.Binary, dc.GetLogPaths(networkDir, o.log))
			case catSettings:
				add(cat, spec.Binary, dc.GetSettingsPaths(networkDir, network, o.log))
			case catWallet:
				add(cat, spec.Binary, dc.GetWalletPaths(networkDir, network, o.log))
				// bitwindowd's master wallet lives at the flat <bitwindowDir>/
				// wallet.json, which the network-scoped getter above doesn't
				// cover. Include it so a full wallet wipe backs it up too.
				if dc.BinaryName == "bitwindowd" && o.WalletSvc != nil {
					add(cat, spec.Binary, o.WalletSvc.MasterWalletPaths())
				}
			}
		}
	}

	return files, nil
}

// DeleteFiles stops the binaries implicated by specs, then removes each path.
// Wallet paths are moved to wallet_backups/ instead of being removed — keys are
// irreplaceable. Each path is reported on the returned channel; an empty Error
// means success. A returned error means deletion couldn't start at all (e.g.
// shutdown failed).
//
// Callers must pass only paths from GatherFilesToDelete; the RPC handler
// enforces that by resolving them server-side. Passing specs scopes shutdown to
// the selected binaries; omitting specs preserves the legacy "stop all" behavior
// for direct internal callers.
func (o *Orchestrator) DeleteFiles(ctx context.Context, paths []string, specs ...[]GatherSpec) (<-chan DeleteEvent, error) {
	var plan resetPlan
	useResetPlan := len(specs) > 0
	if len(specs) > 0 {
		plan = o.buildResetPlan(specs[0])
	}

	running := o.process.ListRunning()
	if useResetPlan {
		running = plan.runningProcessNames()
	}
	shutdownBudget := gracefulKillTimeout * time.Duration(len(running)+2)
	shutdownCtx, cancel := context.WithTimeout(ctx, shutdownBudget)
	defer cancel()

	if useResetPlan {
		if err := o.stopResetPlan(shutdownCtx, plan); err != nil {
			return nil, fmt.Errorf("shutdown binaries: %w", err)
		}
	} else {
		ch, err := o.ShutdownAll(shutdownCtx, false)
		if err != nil {
			return nil, fmt.Errorf("shutdown binaries: %w", err)
		}
		for p := range ch {
			if p.Error != nil {
				return nil, fmt.Errorf("shutdown binaries: %w", p.Error)
			}
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

		if useResetPlan {
			go o.restartResetPlan(context.Background(), plan)
		}
	}()

	return events, nil
}

type resetRestart struct {
	binary       ResetBinary
	forceBackend bool
}

type resetPlan struct {
	stop    map[ResetBinary]bool
	restart []resetRestart
}

var resetSidechainBinaries = []ResetBinary{
	ResetBinaryThunder,
	ResetBinaryZSide,
	ResetBinaryBitNames,
	ResetBinaryBitAssets,
	ResetBinaryTruthcoin,
	ResetBinaryPhoton,
	ResetBinaryCoinShift,
}

var resetStopOrder = []ResetBinary{
	ResetBinaryThunder,
	ResetBinaryZSide,
	ResetBinaryBitNames,
	ResetBinaryBitAssets,
	ResetBinaryTruthcoin,
	ResetBinaryPhoton,
	ResetBinaryCoinShift,
	ResetBinaryBitwindowd,
	ResetBinaryEnforcer,
	ResetBinaryBitcoind,
}

var resetStartOrder = []ResetBinary{
	ResetBinaryBitcoind,
	ResetBinaryEnforcer,
	ResetBinaryBitwindowd,
	ResetBinaryThunder,
	ResetBinaryZSide,
	ResetBinaryBitNames,
	ResetBinaryBitAssets,
	ResetBinaryTruthcoin,
	ResetBinaryPhoton,
	ResetBinaryCoinShift,
}

const resetRestartTimeout = 5 * time.Minute

func resetDescendants(binary ResetBinary) []ResetBinary {
	switch binary {
	case ResetBinaryBitcoind:
		return append([]ResetBinary{ResetBinaryEnforcer}, resetSidechainBinaries...)
	case ResetBinaryEnforcer:
		return resetSidechainBinaries
	default:
		return nil
	}
}

func (o *Orchestrator) buildResetPlan(specs []GatherSpec) resetPlan {
	stop := make(map[ResetBinary]bool)
	for _, spec := range specs {
		if spec.Binary == ResetBinaryUnknown || len(spec.Categories) == 0 {
			continue
		}
		stop[spec.Binary] = true
		for _, child := range resetDescendants(spec.Binary) {
			if o.isResetBinaryRunning(child) {
				stop[child] = true
			}
		}
	}

	restart := make([]resetRestart, 0, len(stop))
	for _, binary := range resetStartOrder {
		if !stop[binary] || !o.isResetBinaryRunning(binary) || o.isResetBinaryAdopted(binary) {
			continue
		}
		restart = append(restart, resetRestart{
			binary:       binary,
			forceBackend: o.process.ForceBackendFor(binary.processName()),
		})
	}

	return resetPlan{stop: stop, restart: restart}
}

func (p resetPlan) runningProcessNames() []string {
	names := make([]string, 0, len(p.stop))
	for _, binary := range resetStopOrder {
		if p.stop[binary] {
			names = append(names, binary.processName())
		}
	}
	return names
}

func (o *Orchestrator) isResetBinaryRunning(binary ResetBinary) bool {
	name := binary.processName()
	return name != "" && o.process.IsRunning(name)
}

func (o *Orchestrator) isResetBinaryAdopted(binary ResetBinary) bool {
	name := binary.processName()
	return name != "" && o.process.IsAdopted(name)
}

func (o *Orchestrator) configForResetBinary(binary ResetBinary) (BinaryConfig, bool) {
	name := binary.processName()
	if name == "" {
		return BinaryConfig{}, false
	}
	cfg, err := o.getConfig(name)
	return cfg, err == nil
}

func (o *Orchestrator) stopResetPlan(ctx context.Context, plan resetPlan) error {
	for _, binary := range resetStopOrder {
		if !plan.stop[binary] {
			continue
		}
		if err := o.stopResetBinary(ctx, binary); err != nil {
			return err
		}
	}
	return nil
}

func (o *Orchestrator) stopResetBinary(ctx context.Context, binary ResetBinary) error {
	name := binary.processName()
	if name == "" || !o.process.IsRunning(name) {
		return nil
	}

	if o.process.IsAdopted(name) {
		o.log.Info().Str("binary", name).Msg("adopted process, skipping reset shutdown")
		o.process.Remove(name)
		o.markResetBinaryStopped(name)
		return nil
	}

	o.setResetBinaryStopping(name, true)
	if !o.stopBinaryViaRPC(ctx, name) {
		if err := o.process.Stop(ctx, name, false); err != nil {
			o.log.Warn().Err(err).Str("binary", name).Msg("graceful stop failed during reset, escalating to SIGKILL")
			if killErr := o.process.Stop(ctx, name, true); killErr != nil {
				o.markResetBinaryStopped(name)
				return fmt.Errorf("stop %s: graceful failed (%v) and force kill failed: %w", name, err, killErr)
			}
		}
	}

	o.markResetBinaryStopped(name)
	return nil
}

func (o *Orchestrator) setResetBinaryStopping(name string, stopping bool) {
	o.monitorsMu.Lock()
	defer o.monitorsMu.Unlock()
	if mon, ok := o.monitors[name]; ok {
		mon.SetStopping(stopping)
	}
}

func (o *Orchestrator) markResetBinaryStopped(name string) {
	o.monitorsMu.Lock()
	defer o.monitorsMu.Unlock()
	if mon, ok := o.monitors[name]; ok {
		mon.MarkStopped()
	}
}

func (o *Orchestrator) restartResetPlan(ctx context.Context, plan resetPlan) {
	ctx, cancel := context.WithTimeout(ctx, time.Duration(len(plan.restart)+1)*resetRestartTimeout)
	defer cancel()

	for _, item := range plan.restart {
		if err := o.restartResetBinary(ctx, item.binary, item.forceBackend); err != nil {
			o.log.Error().Err(err).Str("binary", item.binary.processName()).Msg("reset restart failed")
			return
		}
	}
}

func (o *Orchestrator) restartResetBinary(ctx context.Context, binary ResetBinary, forceBackend bool) error {
	cfg, ok := o.configForResetBinary(binary)
	if !ok {
		return fmt.Errorf("unknown reset binary %d", binary)
	}

	ch := make(chan StartupProgress, 100)
	drained := make(chan error, 1)
	go func() {
		drained <- drainStartupError(ch)
	}()
	closed := false
	defer func() {
		if !closed {
			close(ch)
			<-drained
		}
	}()

	opts := StartOpts{ForceBackend: forceBackend}
	var startErr error
	switch binary {
	case ResetBinaryBitcoind:
		o.prepareCoreArgs(&opts)
		if !o.startBitcoindOnly(ctx, opts, ch) {
			startErr = fmt.Errorf("start %s failed", cfg.Name)
		}
	case ResetBinaryEnforcer:
		o.prepareEnforcerArgs(&opts)
		o.startEnforcerWhenReady(ctx, opts, nil)
		mon := o.getOrCreateMonitor("enforcer", NewHealthChecker(cfg), enforcerStartupPatterns)
		startErr = waitForConnectedOrExit(ctx, mon, o.process.Get("enforcer"))
	case ResetBinaryBitwindowd:
		o.startTargetOnly(ctx, cfg, opts, ch, nil)
	default:
		o.injectSidechainStarter(cfg, &opts)
		o.injectHeadlessForForcedBackend(cfg, &opts)
		o.startTargetOnly(ctx, cfg, opts, ch, nil)
	}

	close(ch)
	closed = true
	drainErr := <-drained
	if startErr != nil {
		return startErr
	}
	return drainErr
}

func drainStartupError(ch <-chan StartupProgress) error {
	for p := range ch {
		if p.Error != nil {
			return p.Error
		}
	}
	return nil
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
