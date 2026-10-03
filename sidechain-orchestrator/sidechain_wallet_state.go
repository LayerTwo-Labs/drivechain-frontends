package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/nodes"
	"github.com/samber/lo"
)

// walletStampFile names the wallet whose wallet.mdb a sidechain datadir holds.
const walletStampFile = ".wallet"

const sidechainWalletFile = "wallet.mdb"

// externalWalletID parks a wallet.mdb whose seed no wallet here made.
const externalWalletID = "external"

// walletSwapExitTimeout bounds the wait for a stopped sidechain to exit.
const walletSwapExitTimeout = 30 * time.Second

// seedRefusal is what a node prints when wallet.mdb holds another seed than
// the one it starts with.
const seedRefusal = "seed has already been set"

// walletParkKey scopes a parked wallet.mdb to its wallet and, on eCash, to its
// network, because every eCash network shares one datadir.
func walletParkKey(walletID, ecashID string) string {
	if ecashID == "" {
		return "wallet-" + walletID
	}
	return "wallet-" + walletID + "-ecash-" + ecashID
}

// alignSidechainState gives a sidechain the chain and the wallet it starts
// with, and names that wallet. The start must write the starter of that same
// wallet, or the node refuses the wallet.mdb. Empty for a sidechain that keeps
// no wallet file.
func (o *Orchestrator) alignSidechainState(cfg BinaryConfig) (string, error) {
	// The refused wallet.mdb is the live one only until a swap moves it.
	if err := o.parkRefusedWallet(cfg); err != nil {
		return "", err
	}
	if err := o.alignECashSidechainState(cfg); err != nil {
		return "", err
	}
	dir, ecashID, ok := o.sidechainWalletDir(cfg)
	// A running daemon holds its database open.
	if !ok || o.process.IsRunning(cfg.Name) {
		return "", nil
	}
	walletID := o.WalletSvc.SidechainWalletID()
	if walletID == "" {
		return "", nil
	}
	ecashAlignMu.Lock()
	defer ecashAlignMu.Unlock()
	if err := alignWalletState(dir, ecashID, walletID, o.WalletSvc.StarterWalletID()); err != nil {
		return "", err
	}
	return walletID, nil
}

// sidechainWalletDir is the directory a sidechain keeps wallet.mdb in. ok is
// false for a binary with no such file.
func (o *Orchestrator) sidechainWalletDir(cfg BinaryConfig) (dir, ecashID string, ok bool) {
	if cfg.ChainLayer != 2 || cfg.IsBitcoinCore || o.WalletSvc == nil {
		return "", "", false
	}
	dc, found := config.DirConfigByName(cfg.Name)
	if !found {
		return "", "", false
	}
	network := config.Network(o.CurrentNetwork())
	if network == config.NetworkECash {
		o.mu.RLock()
		ecashID = o.ecashID
		o.mu.RUnlock()
	}
	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}
	return dc.DatadirNetwork(network, bitcoinOverride), ecashID, true
}

// alignWalletState puts the wallet.mdb of walletID in dir and stamps dir with
// it. The wallet.mdb of another wallet is parked under that wallet, never
// deleted. One with no stamp is from before the stamp existed, when every
// sidechain loaded legacyOwner.
func alignWalletState(dir, ecashID, walletID, legacyOwner string) error {
	stampPath := filepath.Join(dir, walletStampFile)
	raw, err := os.ReadFile(stampPath)
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return fmt.Errorf("read %s: %w", stampPath, err)
	}
	stamped := strings.TrimSpace(string(raw))

	live := filepath.Join(dir, sidechainWalletFile)
	exists, err := pathExists(live)
	if err != nil {
		return fmt.Errorf("read %s before parking it: %w", live, err)
	}
	if stamped == "" && exists {
		stamped = legacyOwner
		if stamped == "" {
			stamped = externalWalletID
		}
	}

	if stamped != walletID && exists {
		if err := parkWallet(live, walletParkKey(stamped, ecashID)); err != nil {
			return err
		}
		exists = false
	}
	// The stamp goes before the restore, so a start after a restore that
	// stopped halfway finishes it.
	if strings.TrimSpace(string(raw)) != walletID {
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return fmt.Errorf("create %s: %w", dir, err)
		}
		if err := os.WriteFile(stampPath, []byte(walletID+"\n"), 0o644); err != nil {
			return fmt.Errorf("stamp %s with wallet %s: %w", dir, walletID, err)
		}
	}
	if exists {
		return nil
	}
	incoming, ok := latestParkedPath(live, walletParkKey(walletID, ecashID))
	if !ok {
		return nil
	}
	if err := os.Rename(incoming, live); err != nil {
		return fmt.Errorf("restore %s from %s: %w", live, incoming, err)
	}
	return nil
}

func parkWallet(live, key string) error {
	inUse, err := lmdbInUse(live)
	if err != nil {
		return fmt.Errorf("read the lock of %s: %w", live, err)
	}
	if inUse {
		return fmt.Errorf("a running node holds %s open; stop it before the wallet changes", live)
	}
	parked, err := freeParkedPath(live, key)
	if err != nil {
		return err
	}
	if err := os.Rename(live, parked); err != nil {
		return fmt.Errorf("park %s under %s: %w", live, key, err)
	}
	return nil
}

// lmdbInUse reports whether a process holds the LMDB environment in envDir open.
func lmdbInUse(envDir string) (bool, error) {
	info, err := os.Stat(envDir)
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	if !info.IsDir() {
		return false, nil
	}
	return lmdbLockHeld(filepath.Join(envDir, "lock.mdb"))
}

func pathExists(path string) (bool, error) {
	switch _, err := os.Stat(path); {
	case err == nil:
		return true, nil
	case errors.Is(err, os.ErrNotExist):
		return false, nil
	default:
		return false, err
	}
}

func (o *Orchestrator) beforeStart(ctx context.Context, cfg BinaryConfig) error {
	if err := o.checkECashMigrationStart(ctx, cfg); err != nil {
		return err
	}
	return o.parkRefusedWallet(cfg)
}

// parkRefusedWallet moves aside the wallet.mdb the last run refused, so the
// next start makes one for the wallet the sidechain loads. It keeps the file,
// and acts one time for each refused run.
func (o *Orchestrator) parkRefusedWallet(cfg BinaryConfig) error {
	dir, ecashID, ok := o.sidechainWalletDir(cfg)
	if !ok || o.process.IsRunning(cfg.Name) {
		return nil
	}
	last := o.process.LatestRun(cfg.Name)
	if last == nil || !refusedSeed(last) {
		return nil
	}
	if handled, _ := o.refusedRuns.Load(cfg.Name); handled == last {
		return nil
	}
	// Before a network swap the file is still the one of the network it names.
	if ecashID != "" {
		raw, err := os.ReadFile(filepath.Join(dir, ecashStampFile))
		if err != nil && !errors.Is(err, os.ErrNotExist) {
			return fmt.Errorf("read the network stamp of %s: %w", dir, err)
		}
		if stamped := strings.TrimSpace(string(raw)); stamped != "" {
			ecashID = stamped
		}
	}
	live := filepath.Join(dir, sidechainWalletFile)
	exists, err := pathExists(live)
	if err != nil {
		return fmt.Errorf("read %s before parking it: %w", live, err)
	}
	if exists {
		ecashAlignMu.Lock()
		err := parkWallet(live, walletParkKey(externalWalletID, ecashID))
		ecashAlignMu.Unlock()
		if err != nil {
			return err
		}
		o.log.Warn().Str("binary", cfg.Name).Str("dir", dir).
			Msg("parked a wallet.mdb that holds a seed no wallet here made")
	}
	o.refusedRuns.Store(cfg.Name, last)
	return nil
}

func refusedSeed(run *ManagedProcess) bool {
	return lo.ContainsBy(run.RecentLogs(maxLogEntries), func(entry LogEntry) bool {
		return strings.Contains(entry.Line, seedRefusal)
	})
}

// LoadedSidechainWallet names the wallet whose wallet.mdb a sidechain holds.
// Empty for a sidechain that never started with a wallet.
func (o *Orchestrator) LoadedSidechainWallet(cfg BinaryConfig) (string, error) {
	// A Core derived sidechain keeps its wallet in Core, made from the starter
	// wallet, unless the node keeps a wallet of its own.
	if cfg.ChainLayer == 2 && cfg.IsBitcoinCore && o.WalletSvc != nil {
		node, err := nodes.New(cfg.Name, cfg.RPCHost(), cfg.Port, cfg.IsBitcoinCore, config.Network(o.CurrentNetwork()))
		if err != nil {
			return "", err
		}
		if _, own := node.(sidechain.OwnWalletNode); own {
			return "", nil
		}
		return o.WalletSvc.StarterWalletID(), nil
	}
	dir, _, ok := o.sidechainWalletDir(cfg)
	if !ok {
		return "", nil
	}
	raw, err := os.ReadFile(filepath.Join(dir, walletStampFile))
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return "", fmt.Errorf("read the wallet stamp of %s: %w", cfg.Name, err)
	}
	if stamped := strings.TrimSpace(string(raw)); stamped != "" {
		return stamped, nil
	}
	// A wallet.mdb from before the stamp is the starter wallet's.
	exists, err := pathExists(filepath.Join(dir, sidechainWalletFile))
	if err != nil || !exists {
		return "", err
	}
	return o.WalletSvc.StarterWalletID(), nil
}

// HasExternalWallet reports whether a sidechain keeps a refused wallet.mdb aside
// on the current network.
func (o *Orchestrator) HasExternalWallet(cfg BinaryConfig) bool {
	dir, ecashID, ok := o.sidechainWalletDir(cfg)
	if !ok {
		return false
	}
	_, found := latestParkedPath(filepath.Join(dir, sidechainWalletFile), walletParkKey(externalWalletID, ecashID))
	return found
}

// ReloadSidechainWallets restarts each running sidechain that holds another
// wallet than the one the sidechains load.
func (o *Orchestrator) ReloadSidechainWallets(ctx context.Context) error {
	if o.WalletSvc == nil {
		return nil
	}
	o.swapNetworkMu.Lock()
	defer o.swapNetworkMu.Unlock()

	walletID := o.WalletSvc.SidechainWalletID()
	if walletID == "" {
		return nil
	}
	stale, err := o.sidechainsWithAnotherWallet(walletID)
	if err != nil {
		return err
	}
	restarts := make(map[string]StartOpts, len(stale))
	for _, cfg := range stale {
		if o.process.IsAdopted(cfg.Name) && !o.mayStopAdopted(cfg.Name) {
			return fmt.Errorf("stop %s in its own launcher before you change the wallet", cfg.Name)
		}
		opts := StartOpts{ForceBackend: true}
		if proc := o.process.Get(cfg.Name); proc != nil && proc.Cmd != nil {
			opts.TargetArgs = replaceCLIFlag(append([]string(nil), proc.Cmd.Args[1:]...), "--mnemonic-seed-phrase-path", "")
			opts.TargetEnv = make(map[string]string)
			for _, entry := range proc.Cmd.Env {
				if key, value, ok := strings.Cut(entry, "="); ok {
					opts.TargetEnv[key] = value
				}
			}
		}
		restarts[cfg.Name] = opts
	}
	// A failed stop still starts the sidechains already stopped: a later
	// reload sees a stopped sidechain as nothing to restart.
	var stopped []string
	var errs []error
	for name := range restarts {
		if err := o.stopForNetworkSwap(ctx, name, StopOptions{ForceBackend: true}); err != nil {
			errs = append(errs, err)
			break
		}
		// A forced stop returns before the process is gone, and the swap skips
		// a process that still runs.
		if !o.process.WaitForExit(name, walletSwapExitTimeout) {
			errs = append(errs, fmt.Errorf("%s did not stop for the wallet change", name))
			break
		}
		stopped = append(stopped, name)
	}
	for _, name := range stopped {
		ch, err := o.StartWithL1(context.Background(), name, restarts[name])
		if err != nil {
			errs = append(errs, fmt.Errorf("restart %s: %w", name, err))
			continue
		}
		go func() {
			for progress := range ch {
				if progress.Error != nil {
					o.log.Error().Err(progress.Error).Str("binary", name).Msg("sidechain restart failed after the wallet change")
					return
				}
			}
		}()
	}
	return errors.Join(errs...)
}

// realignSidechainWallet swaps in the wallet.mdb of the active wallet and
// writes its starter into opts, for a daemon the swap skipped while it ran.
func (o *Orchestrator) realignSidechainWallet(cfg BinaryConfig, opts *StartOpts) error {
	walletID, err := o.alignSidechainState(cfg)
	if err != nil || walletID == "" {
		return err
	}
	opts.TargetArgs = replaceCLIFlag(opts.TargetArgs, "--mnemonic-seed-phrase-path", "")
	o.injectSidechainStarter(cfg, opts, walletID)
	return nil
}

// reloadIfWalletChanged restarts a sidechain that booted with walletID after
// the sidechains moved to another wallet. A wallet change during the boot found
// the sidechain stopped, so it did not restart it.
func (o *Orchestrator) reloadIfWalletChanged(walletID string) {
	if walletID == "" || o.WalletSvc == nil || o.WalletSvc.SidechainWalletID() == walletID {
		return
	}
	go func() {
		if err := o.ReloadSidechainWallets(context.Background()); err != nil {
			o.log.Error().Err(err).Msg("could not reload the sidechain wallets after a boot")
		}
	}()
}

// sidechainsWithAnotherWallet lists each running sidechain whose wallet.mdb is
// not the one of walletID.
func (o *Orchestrator) sidechainsWithAnotherWallet(walletID string) ([]BinaryConfig, error) {
	var stale []BinaryConfig
	for _, cfg := range o.Configs() {
		if _, _, ok := o.sidechainWalletDir(cfg); !ok || !o.process.IsRunning(cfg.Name) {
			continue
		}
		loaded, err := o.LoadedSidechainWallet(cfg)
		if err != nil {
			return nil, err
		}
		if loaded != walletID {
			stale = append(stale, cfg)
		}
	}
	return stale, nil
}

// WatchSidechainWallets reloads the sidechain wallets one time, then on each
// wallet change, until ctx ends. Call it after the adoption of running daemons:
// a wallet change before a crash found them with the old wallet.
func (o *Orchestrator) WatchSidechainWallets(ctx context.Context) {
	if o.WalletSvc == nil {
		return
	}
	changed := o.WalletSvc.Subscribe(ctx)
	go func() {
		if err := o.ReloadSidechainWallets(ctx); err != nil {
			o.log.Error().Err(err).Msg("could not reload the sidechain wallets at startup")
		}
		for range changed {
			if err := o.ReloadSidechainWallets(ctx); err != nil {
				o.log.Error().Err(err).Msg("could not reload the sidechain wallets after a wallet change")
			}
		}
	}()
}
