package orchestrator

import (
	"context"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// ecashPlaceholder is expanded to the live eCash network id wherever it
// appears in chains_config.json, so a new generation needs no config edit.
const ecashPlaceholder = "{ecash}"

// ResolveNetworkCatalog loads the catalog persisted by the previous run, then
// refreshes it from the published document. A failed refresh is never fatal:
// the persisted copy stays in force, which is also what makes it a safe
// baseline for spotting a eCash network change — an offline boot compares
// the old values against themselves and so can never wipe anything.
func (o *Orchestrator) ResolveNetworkCatalog(ctx context.Context) {
	// Disk first, and synchronously: this runs before the RPC listener binds,
	// so anything slow here delays every caller, including the wallet list the
	// UI needs to draw. A local read is microseconds.
	current, fromDisk := netcatalog.Load(o.BitwindowDir)
	// Before the promotion below rewrites the cache: what this document lists is
	// what the previous run knew, and the notice compares against exactly that.
	o.seedToldNetworks(current)

	// A previous run's refresh may have left a newer catalog waiting. Startup
	// is the only place it can be applied: the generation decides which chain
	// data is valid, and swapping that under a running process is what caused
	// the wipe and cache to disagree.
	promoted := false
	if pending, ok := netcatalog.LoadPending(o.BitwindowDir); ok {
		current = o.promotePendingCatalog(ctx, current, pending, fromDisk)
		promoted = true
	}
	// RunningECashID already keeps a network the catalog still lists, so this
	// only fires once the catalog drops the one the blocks belong to. Serving
	// it with no endpoints beats opening its blocks as another fork: the user
	// switches from Settings, which states the resync before it runs.
	ecashID := o.RunningECashID(current)
	if installed := o.installedECashNetwork(); !promoted && o.ecashNetworkMoved(installed, ecashID) {
		o.log.Warn().
			Str("installed", installed).
			Str("published", ecashID).
			Msg("the catalog dropped the installed eCash network, switch from Settings to move")
		ecashID = installed
	}
	o.adoptCatalog(current, ecashID)

	// The refresh is network I/O and must never gate startup. It runs detached
	// and only writes the pending slot.
	go o.refreshNetworkCatalog(ctx, current)
}

// promotePendingCatalog applies a catalog left by a previous refresh. Returns
// the catalog to actually use: the pending one when it names the same eCash
// network, otherwise the current one, so a move between networks stays the
// user's to make.
func (o *Orchestrator) promotePendingCatalog(_ context.Context, current, pending netcatalog.Catalog, fromDisk bool) netcatalog.Catalog {
	// The network this install serves, not the catalog's first entry: a user on
	// a retained row keeps blocks from that row, and a refresh that drops it
	// leaves both documents naming the same first entry. An id-only compare
	// reads that as no change and promotes over a chain it never cleared.
	baseline := o.RunningECashID(current)
	if !fromDisk {
		baseline = netcatalog.EmbeddedECashID()
	}
	// What the pending document resolves to for this install, which is the pick
	// while the pick survives the refresh.
	target := o.SelectedECashID(pending)

	// Switching networks throws away the old chain, so it is the user's call
	// to make. The pending file is what the upgrade prompt reads.
	if baseline != "" && target != "" && baseline != target {
		o.log.Info().
			Str("current", baseline).
			Str("published", target).
			Msg("a new eCash network is available, waiting for the user to confirm the resync")
		return current
	}

	if err := netcatalog.Save(o.BitwindowDir, pending); err != nil {
		o.log.Warn().Err(err).Msg("could not persist the promoted network catalog")
		return current
	}
	netcatalog.ClearPending(o.BitwindowDir)
	return pending
}

// PendingECashUpgrade is a published generation this install has not switched
// to yet. ID is empty when it is already on the newest one.
type PendingECashUpgrade struct {
	ID       string
	Peer     string
	Snapshot *netcatalog.AssumeUTXO

	// UserManagedConf means the switch has to be made by hand: the user's own
	// bitcoin.conf names the generation and is not ours to rewrite.
	UserManagedConf bool
}

// PendingECashUpgrade reports the generation waiting for the user's go-ahead.
func (o *Orchestrator) PendingECashUpgrade() PendingECashUpgrade {
	pending, ok := netcatalog.LoadPending(o.BitwindowDir)
	if !ok {
		return PendingECashUpgrade{}
	}
	// The pick, not the document's first row: a user pinned to a retained entry
	// is on no upgrade path just because another row sits above theirs.
	id := o.SelectedECashID(pending)
	if id == "" || id == config.ECashNetworkID() {
		return PendingECashUpgrade{}
	}
	entry, _ := pending.ByID(id)
	peer := entry.P2P.Address
	if peer == "" {
		peer = config.ECashPeerFor(id)
	}
	return PendingECashUpgrade{
		ID:              id,
		Peer:            peer,
		Snapshot:        entry.AssumeUTXO,
		UserManagedConf: o.ecashSwitchIsManual(),
	}
}

// ecashSwitchIsManual reports whether the user's own bitcoin.conf decides which
// eCash network this install runs.
func (o *Orchestrator) ecashSwitchIsManual() bool {
	if config.NetworkFromString(o.Network) != config.NetworkECash {
		return false
	}
	return o.BitcoinConf != nil && o.BitcoinConf.HasPrivateConf
}

// ConfirmPendingECashNetwork applies the user's go-ahead: it moves the chain
// onto the published network, then promotes that catalog to the cache.
func (o *Orchestrator) ConfirmPendingECashNetwork(ctx context.Context) error {
	pending, ok := netcatalog.LoadPending(o.BitwindowDir)
	if !ok {
		return fmt.Errorf("no new eCash network to switch to")
	}
	if o.ecashSwitchIsManual() {
		return fmt.Errorf("your own bitcoin.conf decides which eCash network this node runs, so the switch has to be made there")
	}
	// The switch below stops the daemons, and it cannot stop a Core we did not
	// launch.
	if config.NetworkFromString(o.Network) == config.NetworkECash &&
		!o.process.IsRunning("bitcoind") && o.coreRPCReachable() {
		return fmt.Errorf("a bitcoin core this app did not start is running — stop it first")
	}
	current, _ := netcatalog.Load(o.BitwindowDir)
	previousPick := ""
	if o.Settings != nil {
		previousPick = o.Settings.ECashNetworkID()
	}

	// Every durable write goes before the switch. A volume that refuses them
	// after the chain moved would leave the record naming a network the blocks
	// no longer belong to, and the next start would act on that record.
	//
	// The pick goes before the catalog it belongs to. A catalog promoted without
	// it reads as current on the next start: the pending file gets cleared, the
	// old pick still resolves, and the prompt never returns to say so.
	//
	// Written straight, not through SelectECashNetwork: that one checks the id
	// against the catalog this process still serves, which is the one the
	// pending document supersedes.
	if id := pending.ECashID(); id != "" {
		if o.Settings == nil {
			return fmt.Errorf("orchestrator settings are unavailable")
		}
		if _, err := o.Settings.SetECashNetworkID(id); err != nil {
			return fmt.Errorf("record the confirmed network: %w", err)
		}
	}
	if err := netcatalog.Save(o.BitwindowDir, pending); err != nil {
		o.restoreConfirmRecord(previousPick, current, pending)
		return fmt.Errorf("persist network catalog: %w", err)
	}

	if config.NetworkFromString(o.Network) == config.NetworkECash {
		// Here, not on the next start: this is the one moment a live Core can
		// rewind to the fork. A start has none and could only delete the chain.
		if id := o.SelectedECashID(pending); id != "" {
			if err := o.ApplyECashSwitch(ctx, id); err != nil {
				// Only when the switch never committed. Past that point the
				// chain and the conf already name the target, and putting the
				// record back would send the next start after the branch this
				// switch invalidated.
				o.mu.RLock()
				running := o.ecashID
				o.mu.RUnlock()
				if running != id {
					o.restoreConfirmRecord(previousPick, current, pending)
				}
				return fmt.Errorf("switch to %s: %w", id, err)
			}
		}
	} else {
		// Off eCash the retired chain is cold files that no start will revisit,
		// and there is no Core on that chain to rewind. Clear them here.
		//
		// The pick on both sides, not each document's first row. A user on a
		// retained entry holds that chain on disk, and comparing first rows
		// reads two identical ids while the blocks belong to a third.
		if !o.ecashChangeHasASharedBlock(o.RunningECashID(current), o.SelectedECashID(pending)) {
			o.restoreConfirmRecord(previousPick, current, pending)
			return fmt.Errorf("could not clear the retired eCash chain data")
		}
	}
	// Last: the switch reads the pending document to resolve a network the
	// served catalog does not list yet. A file left behind by a crash names the
	// same network as the cache, which the next start promotes with no work.
	netcatalog.ClearPending(o.BitwindowDir)
	o.log.Info().
		Str("current", config.ECashNetworkID()).
		Str("confirmed", pending.ECashID()).
		Msg("eCash network switch confirmed")
	return nil
}

// restoreConfirmRecord puts back the pick, the cache and the pending file a
// failed confirm already wrote, so the prompt returns and the record keeps
// describing the chain on disk.
func (o *Orchestrator) restoreConfirmRecord(pick string, current, pending netcatalog.Catalog) {
	if o.Settings != nil {
		if _, err := o.Settings.SetECashNetworkID(pick); err != nil {
			o.log.Error().Err(err).Msg("could not put the eCash network pick back after a failed confirm")
		}
	}
	if err := netcatalog.Save(o.BitwindowDir, current); err != nil {
		o.log.Error().Err(err).Msg("could not put the network catalog back after a failed confirm")
	}
	if err := netcatalog.SavePending(o.BitwindowDir, pending); err != nil {
		o.log.Error().Err(err).Msg("could not put the pending network catalog back after a failed confirm")
	}
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
	// Every entry matters, not just the eCash one: the picker lists them all and
	// the endpoints come from their backends. An id-only compare threw away a
	// refresh that added a network, so it never reached the picker.
	if fetched.SameAs(current) {
		netcatalog.ClearPending(o.BitwindowDir)
		return
	}
	if err := netcatalog.SavePending(o.BitwindowDir, fetched); err != nil {
		o.log.Warn().Err(err).Msg("could not record the refreshed network catalog")
		return
	}
	o.log.Info().
		Str("current", current.ECashID()).
		Str("published", fetched.ECashID()).
		Msg("the network catalog changed, restart to apply it")
}

// adoptCatalog stores the catalog and expands the eCash placeholder across
// the binary configs so every download path sees a concrete filename.
// Only safe before the RPC server is accepting requests: it writes state that
// the handlers then read without a shared lock.
func (o *Orchestrator) adoptCatalog(c netcatalog.Catalog, id string) {
	if id == "" {
		o.log.Warn().Msg("network catalog carries no eCash network, eCash downloads will not resolve")
	}

	o.mu.Lock()
	o.Catalog = c
	o.ecashID = id
	// Always expand from the pristine configs: a previous adopt already
	// replaced the placeholder, so re-expanding those would leave the old
	// network pinned forever.
	for name, raw := range o.rawConfigs {
		o.configs[name] = expandECashPlaceholder(raw, id)
	}
	conf := o.BitcoinConf
	enforcerConf := o.EnforcerConf
	o.mu.Unlock()

	if id == "" {
		return
	}
	// The URL helpers and the conf writer both key off the eCash id, so both
	// need the resolved one.
	config.SetECashNetworkID(id)

	// Fork heights ride along in the catalog, so a new eCash network — and the
	// real fork — activate without a release.
	for _, n := range c.Networks {
		// An eCash id names no network, so writing it as one would stamp its
		// values onto signet, which is what NetworkFromString falls back to.
		if net, ok := config.LookupNetwork(n.ID); ok {
			config.SetForkHeight(net, n.ForkHeight)
			config.SetNetworkDisplayName(net, n.DisplayName)
		}
		if n.Family == netcatalog.FamilyECash {
			config.SetECashPeer(n.ID, n.P2P.Address)
		}
	}
	// The eCash slot takes the resolved entry's values, not the last listed
	// one: the catalog keeps the retired networks after the live one.
	if ecash, ok := c.ByID(id); ok {
		config.SetForkHeight(config.NetworkECash, ecash.ForkHeight)
		config.SetNetworkDisplayName(config.NetworkECash, ecash.DisplayName)
		config.SetECashEndpoints(ecash)
	}

	// The esplora host and network preset name the eCash network, so a rollover
	// that updates only bitcoin.conf leaves the enforcer on the retired fork.
	if enforcerConf != nil {
		switch changed, err := enforcerConf.RetargetECashNetwork(o.installedECashNetwork(), id); {
		case err != nil:
			o.log.Warn().Err(err).Msg("could not rewrite bitwindow-enforcer.conf for the new eCash network")
		case changed:
			o.log.Info().Str("network", id).Msg("rewrote bitwindow-enforcer.conf for the new eCash network")
		}
	}
	if conf == nil {
		return
	}
	conf.ECashID = id
	// An existing eCash bitcoin.conf still carries whatever id it was
	// written with; the peer and sentinel are otherwise only regenerated on a
	// network swap. Safe here because this runs before the server is up.
	if config.NetworkFromString(o.Network) == config.NetworkECash {
		if err := conf.RefreshMainSectionDefaults(); err != nil {
			o.log.Warn().Err(err).Msg("could not rewrite eCash bitcoin.conf for the new generation")
		}
	}
}

// expandECashPlaceholder replaces the eCash placeholder throughout a binary's
// Core variants. It is applied on every path that installs configs — including
// the chains_config.json watcher — because a reload otherwise reinstates the
// unexpanded placeholder. A empty id leaves the config untouched.
func expandECashPlaceholder(cfg BinaryConfig, id string) BinaryConfig {
	if id == "" || len(cfg.Variants) == 0 {
		return cfg
	}
	variants := make(map[string]CoreVariantSpec, len(cfg.Variants))
	for vID, v := range cfg.Variants {
		v.Subfolder = strings.ReplaceAll(v.Subfolder, ecashPlaceholder, id)
		v.BaseURL = strings.ReplaceAll(v.BaseURL, ecashPlaceholder, id)
		files := make(map[string]string, len(v.Files))
		for platform, file := range v.Files {
			files[platform] = strings.ReplaceAll(file, ecashPlaceholder, id)
		}
		v.Files = files
		variants[vID] = v
	}
	cfg.Variants = variants
	return cfg
}

// ecashNetworkMoved reports whether startup must hold back the published eCash
// network: it differs from the one the blocks on disk belong to, the user never
// asked to move, and there are blocks to lose.
func (o *Orchestrator) ecashNetworkMoved(installed, published string) bool {
	if installed == "" || published == "" || installed == published {
		return false
	}
	if config.NetworkFromString(o.Network) != config.NetworkECash {
		return false
	}
	// A move the user already picked is not an offer.
	if o.Settings != nil && o.Settings.ECashNetworkID() == published {
		return false
	}
	return o.ecashChainDataOnDisk()
}

// ecashChainDataOnDisk reports whether Core holds eCash blocks worth keeping.
func (o *Orchestrator) ecashChainDataOnDisk() bool {
	// An empty override means Core's platform default, which is a supported
	// setup — not an install with nothing on disk.
	datadir := config.BitcoinCoreDirs.DatadirNetwork(config.NetworkECash, o.ecashDatadir())
	if datadir == "" {
		return false
	}
	entries, err := os.ReadDir(filepath.Join(datadir, "blocks"))
	if err != nil {
		// Only "not there" says there is nothing to keep. Any other refusal
		// leaves a chain that may exist, and adopting over it needs the user.
		return !os.IsNotExist(err)
	}
	return len(entries) > 0
}

// SelectedECashID returns the network a catalog resolves to: the one the user
// picked while that catalog still lists it, otherwise the entry it lists first.
func (o *Orchestrator) SelectedECashID(c netcatalog.Catalog) string {
	if picked := o.pinnedECashID(c); picked != "" {
		return picked
	}
	return c.ECashID()
}

// RunningECashID returns the eCash network this install serves: the user's pick,
// then the id its bitcoin.conf names, and only then the entry the catalog lists
// first. The conf comes before document order because it names the fork whose
// blocks are on disk.
func (o *Orchestrator) RunningECashID(c netcatalog.Catalog) string {
	if picked := o.pinnedECashID(c); picked != "" {
		return picked
	}
	if installed := o.installedECashNetwork(); installed != "" {
		if _, ok := c.ByID(installed); ok {
			return installed
		}
	}
	return c.ECashID()
}

// pinnedECashID returns the user's pick while the catalog still lists it.
func (o *Orchestrator) pinnedECashID(c netcatalog.Catalog) string {
	if o.Settings == nil {
		return ""
	}
	picked := o.Settings.ECashNetworkID()
	if picked == "" {
		return ""
	}
	if _, ok := c.ByID(picked); !ok {
		return ""
	}
	return picked
}

// SelectECashNetwork pins the eCash network the user picked. The switch itself
// runs on the next start, which is the only place the stale chain can be wiped.
// An id the catalog does not list is ignored: a caller that sends the bare slot
// name keeps whatever the catalog resolves.
func (o *Orchestrator) SelectECashNetwork(id string) error {
	o.mu.RLock()
	cat := o.Catalog
	o.mu.RUnlock()
	if _, ok := cat.ByID(id); !ok {
		return nil
	}
	if o.Settings == nil {
		return nil
	}
	// What this install actually runs, not what the catalog lists first: an
	// unpinned install still boots a network, and that is the chain on disk.
	previous := o.Settings.ECashNetworkID()
	if previous == id {
		return nil
	}
	if previous == "" {
		o.mu.RLock()
		previous = o.ecashID
		o.mu.RUnlock()
	}
	if _, err := o.Settings.SetECashNetworkID(id); err != nil {
		return err
	}
	if previous == id || previous == "" {
		return nil
	}
	if !o.ecashChangeHasASharedBlock(previous, id) {
		// The pick is already durable. Leaving it on a network the chain cannot
		// reach would serve the target over the source fork.
		if _, err := o.Settings.SetECashNetworkID(previous); err != nil {
			o.log.Error().Err(err).Str("previous", previous).
				Msg("could not put the eCash network pick back")
		}
		return fmt.Errorf("no fork height says where %s and %s part", previous, id)
	}
	// The enforcer keeps one validator chain per network, not per fork, so the
	// new generation cannot inherit the old one's. Off eCash that directory
	// belongs to the running network, so the work waits for the swap back.
	if err := o.Settings.SetPendingEnforcerWipe(id); err != nil {
		// The pick is already durable. Leaving it while the enforcer keeps the
		// retired chain runs the new generation on stale validator state.
		if _, putBack := o.Settings.SetECashNetworkID(previous); putBack != nil {
			o.log.Error().Err(putBack).Str("previous", previous).
				Msg("could not put the eCash network pick back")
		}
		return fmt.Errorf("record the enforcer cleanup for %s: %w", id, err)
	}
	return nil
}

// installedECashNetwork returns the eCash network the on-disk bitcoin.conf
// was written for, from its uacomment sentinel, or "" when none.
func (o *Orchestrator) installedECashNetwork() string {
	if o.BitcoinConf == nil || o.BitcoinConf.Config == nil {
		return ""
	}
	return config.ECashIDFromUAComment(o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
}

// sharedECashHeight returns the last block two eCash networks agree on: one
// below the lower published fork height. Both fork mainnet, so everything under
// it is valid on either. false means one of them publishes no fork height, and
// nothing says where the two part.
func (o *Orchestrator) sharedECashHeight(fromID, toID string) (uint32, bool) {
	from, okFrom := o.ecashEntry(fromID)
	to, okTo := o.ecashEntry(toID)
	if !okFrom || !okTo || from.ForkHeight <= 1 || to.ForkHeight <= 1 {
		return 0, false
	}
	shared := from.ForkHeight
	if to.ForkHeight < shared {
		shared = to.ForkHeight
	}
	return uint32(shared - 1), true
}

// ecashChangeHasASharedBlock reports whether a move between two eCash networks
// can reach a block they share. It writes nothing and deletes nothing: the
// rewind itself runs in the switch, against a live Core or not at all.
func (o *Orchestrator) ecashChangeHasASharedBlock(oldID, newID string) bool {
	if oldID == "" || newID == "" || oldID == newID {
		return true
	}
	if _, ok := o.sharedECashHeight(oldID, newID); ok {
		return true
	}
	o.log.Warn().
		Str("previous", oldID).
		Str("current", newID).
		Msg("no fork height says where the two eCash chains part, keeping the chain on disk")
	return false
}

// coreRPCReachable reports whether something is already listening on Bitcoin
// Core's RPC port. The process manager only knows about daemons it started or
// adopted from a PID file, so a Core the user launched themselves is invisible
// to it — and renaming blocks out from under a live node corrupts it. A refused
// connection is the common case and returns immediately.
func (o *Orchestrator) coreRPCReachable() bool {
	if o.coreReachable != nil {
		return o.coreReachable()
	}
	return o.dialCoreRPC()
}

func (o *Orchestrator) dialCoreRPC() bool {
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

// ecashDatadir returns the datadir eCash's chain data lives in. The group
// slot is authoritative and survives swaps to other networks; the live
// datadir= is only consulted while eCash is the active network, where a fresh
// install may not have written the slot yet. Empty means the platform default.
func (o *Orchestrator) ecashDatadir() string {
	if slot := o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash); slot != "" {
		return slot
	}
	if config.NetworkFromString(o.Network) == config.NetworkECash {
		return o.BitcoinConf.Config.GetSetting("datadir")
	}
	return ""
}

// NetworkOption is one row of the network picker.
type NetworkOption struct {
	ID          string
	DisplayName string
	Network     config.Network
	IsCurrent   bool
}

// regtestOption is the local-only row. The published catalog never lists
// regtest — nothing is deployed for it — but the app still runs it.
var regtestOption = NetworkOption{ID: "regtest", DisplayName: "Regtest", Network: config.NetworkRegtest}

// ListNetworks returns the networks the user can pick: every catalog entry the
// app knows how to run, in document order, plus regtest.
func (o *Orchestrator) ListNetworks() []NetworkOption {
	o.mu.RLock()
	cat := o.Catalog
	ecashID := o.ecashID
	o.mu.RUnlock()

	active := config.NetworkFromString(o.Network)
	options := make([]NetworkOption, 0, len(cat.Networks)+1)
	for _, n := range cat.Networks {
		slot, ok := config.NetworkForCatalogEntry(n.ID, n.Family)
		if !ok {
			continue
		}
		options = append(options, NetworkOption{
			ID:          n.ID,
			DisplayName: n.DisplayName,
			Network:     slot,
			// An eCash row is current only when its id is the one that boots;
			// the catalog can list several and they share the slot.
			IsCurrent: slot == active && (slot != config.NetworkECash || n.ID == ecashID),
		})
	}
	regtest := regtestOption
	regtest.IsCurrent = active == config.NetworkRegtest
	return append(options, regtest)
}

// NetworkForOption resolves a picker id to the slot it runs in. It accepts a
// catalog id ("alphanet") and a bare slot name ("signet"), so a caller that
// only knows the slot still works.
func (o *Orchestrator) NetworkForOption(id string) (config.Network, bool) {
	o.mu.RLock()
	cat := o.Catalog
	o.mu.RUnlock()
	if entry, ok := cat.ByID(id); ok {
		return config.NetworkForCatalogEntry(entry.ID, entry.Family)
	}
	return config.LookupNetwork(id)
}

// seedToldNetworks records what this install already knew, once, from the
// catalog it booted with. It runs before a pending catalog is promoted, so the
// baseline is the previous run's document — an upgrade from an older build
// therefore reads every network published since as new, and says so.
func (o *Orchestrator) seedToldNetworks(booted netcatalog.Catalog) {
	if o.Settings == nil || o.Settings.SeenNetworkIDs() != nil {
		return
	}
	// Regtest is never published, so it must go in or every call reports it.
	told := []string{regtestOption.ID}
	for _, n := range booted.Networks {
		told = append(told, n.ID)
	}
	if err := o.Settings.SetSeenNetworkIDs(told); err != nil {
		o.log.Warn().Err(err).Msg("could not record the told networks")
	}
}

// TakeNewNetworks returns the catalog rows this install did not tell the user
// about yet, and records them as told. The baseline comes from the catalog on
// disk at boot, so an install that upgrades from an older build hears about
// every network published since — and a fresh install hears about none.
func (o *Orchestrator) TakeNewNetworks() []NetworkOption {
	if o.Settings == nil {
		return nil
	}
	seen := o.Settings.SeenNetworkIDs()
	told := make(map[string]bool, len(seen))
	for _, id := range seen {
		told[id] = true
	}

	var fresh []NetworkOption
	for _, opt := range o.ListNetworks() {
		if told[opt.ID] {
			continue
		}
		told[opt.ID] = true
		seen = append(seen, opt.ID)
		fresh = append(fresh, opt)
	}
	if len(fresh) == 0 {
		return nil
	}
	if err := o.Settings.SetSeenNetworkIDs(seen); err != nil {
		// Reporting a network we could not record repeats the notice next tick.
		o.log.Warn().Err(err).Msg("could not record the told networks")
		return nil
	}
	return fresh
}
