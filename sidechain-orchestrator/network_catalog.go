package orchestrator

import (
	"context"
	"net"
	"strconv"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// drynetPlaceholder is expanded to the live drynet generation id wherever it
// appears in chains_config.json, so a new generation needs no config edit.
const drynetPlaceholder = "{drynet}"

// ResolveNetworkCatalog loads the catalog persisted by the previous run, then
// refreshes it from the published document. A failed refresh is never fatal:
// the persisted copy stays in force, which is also what makes it a safe
// baseline for spotting a drynet generation change — an offline boot compares
// the old values against themselves and so can never wipe anything.
func (o *Orchestrator) ResolveNetworkCatalog(ctx context.Context) {
	// Disk first, and synchronously: this runs before the RPC listener binds,
	// so anything slow here delays every caller, including the wallet list the
	// UI needs to draw. A local read is microseconds.
	current, fromDisk := netcatalog.Load(o.BitwindowDir)

	// A previous run's refresh may have left a newer catalog waiting. Startup
	// is the only place it can be applied: the generation decides which chain
	// data is valid, and swapping that under a running process is what caused
	// the wipe and cache to disagree.
	if pending, ok := netcatalog.LoadPending(o.BitwindowDir); ok {
		current = o.promotePendingCatalog(current, pending, fromDisk)
	}
	o.adoptCatalog(current)

	// The refresh is network I/O and must never gate startup. It runs detached
	// and only writes the pending slot.
	go o.refreshNetworkCatalog(ctx, current)
}

// promotePendingCatalog applies a catalog left by a previous refresh, wiping
// the stale drynet chain data first. Returns the catalog to actually use: the
// pending one when it could be applied, otherwise the current one, so the
// process never serves a generation whose data it has not cleared.
func (o *Orchestrator) promotePendingCatalog(current, pending netcatalog.Catalog, fromDisk bool) netcatalog.Catalog {
	// With no cache — a first run after upgrading from a pre-catalog build —
	// the embedded generation is still what any existing drynet data belongs
	// to, so it remains a valid baseline.
	baseline := current.DrynetID()
	if !fromDisk {
		baseline = netcatalog.EmbeddedDrynetID()
	}

	if !o.wipeOnDrynetGenerationChange(baseline, pending.DrynetID()) {
		// Leave the pending file in place; the next start tries again.
		o.log.Warn().Msg("could not apply the pending network catalog, keeping the current one")
		return current
	}
	// Cache and pending are only reconciled once the stale data is gone, so an
	// interrupted promotion repeats rather than recording a wipe that did not
	// happen.
	if err := netcatalog.Save(o.BitwindowDir, pending); err != nil {
		o.log.Warn().Err(err).Msg("could not persist the promoted network catalog")
		return current
	}
	netcatalog.ClearPending(o.BitwindowDir)
	return pending
}

// refreshNetworkCatalog fetches the published catalog and, when it differs from
// what this process is serving, leaves it for the next start to apply.
//
// It deliberately mutates nothing in memory and does not touch the cache. This
// runs after the RPC server is accepting requests, and the orchestrator's
// shared state — binary configs, monitors, catalog, the bitcoin.conf manager —
// is read by those handlers without a common lock. The cache must also keep
// describing the data actually on disk, which is the generation this process
// is still serving.
func (o *Orchestrator) refreshNetworkCatalog(ctx context.Context, current netcatalog.Catalog) {
	fetched, err := netcatalog.Fetch(ctx, netcatalog.DefaultURL)
	if err != nil {
		o.log.Warn().Err(err).Msg("network catalog refresh failed, using last known values")
		return
	}
	if fetched.DrynetID() == current.DrynetID() {
		netcatalog.ClearPending(o.BitwindowDir)
		return
	}
	if err := netcatalog.SavePending(o.BitwindowDir, fetched); err != nil {
		o.log.Warn().Err(err).Msg("could not record the refreshed network catalog")
		return
	}
	o.log.Info().
		Str("current", current.DrynetID()).
		Str("published", fetched.DrynetID()).
		Msg("drynet generation changed, restart to switch over")
}

// adoptCatalog stores the catalog and expands the drynet placeholder across
// the binary configs so every download path sees a concrete filename.
// Only safe before the RPC server is accepting requests: it writes state that
// the handlers then read without a shared lock.
func (o *Orchestrator) adoptCatalog(c netcatalog.Catalog) {
	id := c.DrynetID()
	if id == "" {
		o.log.Warn().Msg("network catalog carries no drynet generation, drynet downloads will not resolve")
	}

	o.mu.Lock()
	o.Catalog = c
	o.drynetID = id
	// Always expand from the pristine configs: a previous adopt already
	// replaced the placeholder, so re-expanding those would leave the old
	// generation pinned forever.
	for name, raw := range o.rawConfigs {
		o.configs[name] = expandDrynetPlaceholder(raw, id)
	}
	conf := o.BitcoinConf
	o.mu.Unlock()

	if id == "" {
		return
	}
	// The URL helpers and the conf writer both build drynet hostnames from the
	// generation, so both need the resolved id.
	config.SetDrynetGeneration(id)
	if conf == nil {
		return
	}
	conf.DrynetID = id
	// An existing drynet bitcoin.conf still carries whatever generation it was
	// written with; the peer and sentinel are otherwise only regenerated on a
	// network swap. Safe here because this runs before the server is up.
	if config.NetworkFromString(o.Network) == config.NetworkDrynet {
		if err := conf.RefreshMainSectionDefaults(); err != nil {
			o.log.Warn().Err(err).Msg("could not rewrite drynet bitcoin.conf for the new generation")
		}
	}
}

// expandDrynetPlaceholder replaces the drynet placeholder throughout a binary's
// Core variants. It is applied on every path that installs configs — including
// the chains_config.json watcher — because a reload otherwise reinstates the
// unexpanded placeholder. A empty id leaves the config untouched.
func expandDrynetPlaceholder(cfg BinaryConfig, id string) BinaryConfig {
	if id == "" || len(cfg.Variants) == 0 {
		return cfg
	}
	variants := make(map[string]CoreVariantSpec, len(cfg.Variants))
	for vID, v := range cfg.Variants {
		v.Subfolder = strings.ReplaceAll(v.Subfolder, drynetPlaceholder, id)
		v.BaseURL = strings.ReplaceAll(v.BaseURL, drynetPlaceholder, id)
		files := make(map[string]string, len(v.Files))
		for platform, file := range v.Files {
			files[platform] = strings.ReplaceAll(file, drynetPlaceholder, id)
		}
		v.Files = files
		variants[vID] = v
	}
	cfg.Variants = variants
	return cfg
}

// wipeOnDrynetGenerationChange deletes drynet chain state when the published
// generation moves on (drynet2 -> drynet3). The generations are separate forks
// that share one datadir, so the previous blocks and chainstate are invalid for
// the new chain. Wallets survive — see WipeChainData.
// It reports whether the catalog may move on: true when nothing needed wiping
// or the wipe was started, false when the stale data is still there.
func (o *Orchestrator) wipeOnDrynetGenerationChange(oldID, newID string) bool {
	if oldID == "" || newID == "" || oldID == newID {
		return true
	}
	if o.BitcoinConf == nil || o.BitcoinConf.Config == nil {
		o.log.Warn().Msg("drynet generation changed but bitcoin config is unavailable, skipping wipe")
		return false
	}
	if o.BitcoinConf.HasPrivateConf {
		// That user's chain data follows their own bitcoin.conf, not ours.
		o.log.Warn().Msg("drynet generation changed but user bitcoin.conf takes precedence, skipping wipe")
		return true
	}
	// The refresh runs detached, so bitcoind may already have been adopted or
	// started by the time the new generation lands. Renaming blocks and
	// chainstate out from under a live node corrupts it; defer to the next
	// boot, where the check runs before Core comes up.
	if o.process.IsRunning("bitcoind") || o.coreRPCReachable() {
		o.log.Warn().
			Str("previous", oldID).
			Str("current", newID).
			Msg("drynet generation changed while bitcoin core is running, deferring wipe to next start")
		return false
	}

	o.log.Info().
		Str("previous", oldID).
		Str("current", newID).
		Msg("drynet generation changed, wiping stale chain data")

	// Synchronous: the caller persists the new generation next, and recording
	// a wipe that has not happened is worse than not wiping at all. Runs on
	// the refresh goroutine, so a slow volume cannot delay startup.
	config.WipeNetworkScopedChainDataSync(config.NetworkDrynet, o.drynetDatadir(), o.log)
	// The enforcer's validator chain is per-network, not per-generation, so on
	// drynet it must be cleared here too; other networks' swap into drynet does it.
	if config.NetworkFromString(o.Network) == config.NetworkDrynet {
		config.WipeEnforcerChainDataSync(config.NetworkDrynet, o.log)
	}
	return true
}

// coreRPCReachable reports whether something is already listening on Bitcoin
// Core's RPC port. The process manager only knows about daemons it started or
// adopted from a PID file, so a Core the user launched themselves is invisible
// to it — and renaming blocks out from under a live node corrupts it. A refused
// connection is the common case and returns immediately.
func (o *Orchestrator) coreRPCReachable() bool {
	if o.BitcoinConf == nil {
		return false
	}
	addr := net.JoinHostPort(o.BitcoinConf.GetRPCHost(), strconv.Itoa(o.BitcoinConf.GetRPCPort()))
	conn, err := net.DialTimeout("tcp", addr, 300*time.Millisecond)
	if err != nil {
		return false
	}
	_ = conn.Close()
	return true
}

// drynetDatadir returns the datadir drynet's chain data lives in. The group
// slot is authoritative and survives swaps to other networks; the live
// datadir= is only consulted while drynet is the active network, where a fresh
// install may not have written the slot yet. Empty means the platform default.
func (o *Orchestrator) drynetDatadir() string {
	if slot := o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupDrynet); slot != "" {
		return slot
	}
	if config.NetworkFromString(o.Network) == config.NetworkDrynet {
		return o.BitcoinConf.Config.GetSetting("datadir")
	}
	return ""
}
