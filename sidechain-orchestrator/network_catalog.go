package orchestrator

import (
	"context"
	"fmt"
	"net"
	"strconv"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// ecashPlaceholder is expanded to the live eCash network id wherever it
// appears in chains_config.json, so a new generation needs no config edit.
const ecashPlaceholder = "{ecash}"

// ResolveNetworkCatalog adopts the compiled-in catalog, then refreshes it from
// the published document. Neither copy is held on disk, and no start waits on
// the endpoint. A refresh moves no chain: only the user changes that.
func (o *Orchestrator) ResolveNetworkCatalog(ctx context.Context) {
	// No I/O: this runs before the RPC listener binds, so anything slow here
	// delays every caller.
	current := netcatalog.Embedded()
	o.seedToldNetworks(current)
	netcatalog.RemoveLegacyFiles(o.BitwindowDir)

	// The network this install serves, not the document's first row: the blocks
	// on disk belong to one network, and only the user moves them to another.
	ecashID := o.RunningECashID(current)
	if _, listed := current.ByID(ecashID); ecashID != "" && !listed {
		o.log.Warn().
			Str("network", ecashID).
			Msg("the catalog does not list the eCash network this install runs, switch from Settings to move")
	}
	o.adoptCatalog(current, ecashID)

	// The fetch is network I/O and must never gate startup, so it runs detached.
	go o.refreshNetworkCatalog(ctx)
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
	o.mu.RLock()
	published := o.Catalog
	o.mu.RUnlock()
	// The document's first row against the network this install runs. A pick
	// says which network runs, not that the user heard about the newer one.
	id := published.ECashID()
	if id == "" || id == o.RunningECashID(published) {
		return PendingECashUpgrade{}
	}
	entry, _ := published.ByID(id)
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

// ConfirmPendingECashNetwork applies the user's go-ahead: it records the
// published network as the pick, then moves the chain onto it.
func (o *Orchestrator) ConfirmPendingECashNetwork(ctx context.Context) error {
	o.mu.RLock()
	published := o.Catalog
	o.mu.RUnlock()
	target := published.ECashID()
	if target == "" || target == o.RunningECashID(published) {
		// A previous confirm moved the chain but stopped before it finished. The
		// same target is that retry, not a request for work already done.
		if target != "" && o.pendingECashSwap() {
			return o.ApplyECashSwitch(ctx, target)
		}
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
	previousPick := ""
	if o.Settings != nil {
		previousPick = o.Settings.ECashNetworkID()
	}

	// The pick goes before the switch. A volume that refuses the write after the
	// chain moved would leave the record naming a network the blocks no longer
	// belong to, and the next start would act on that record.
	//
	// Written straight, not through SelectECashNetwork: that one checks the id
	// against the catalog this process still serves, which is the one the
	// published document supersedes.
	if o.Settings == nil {
		return fmt.Errorf("orchestrator settings are unavailable")
	}
	if _, err := o.Settings.SetECashNetworkID(target); err != nil {
		return fmt.Errorf("record the confirmed network: %w", err)
	}

	if config.NetworkFromString(o.Network) == config.NetworkECash {
		// Here, not on the next start: this is the one moment a live Core can
		// rewind to the fork. A start has none, so it would leave Core above it.
		if err := o.ApplyECashSwitch(ctx, target); err != nil {
			// Only when the switch never committed. Past that point the
			// chain and the conf already name the target, and putting the
			// record back would send the next start after the branch this
			// switch invalidated.
			o.mu.RLock()
			running := o.ecashID
			o.mu.RUnlock()
			if running != target {
				o.restoreECashPick(previousPick)
			}
			return fmt.Errorf("switch to %s: %w", target, err)
		}
	} else {
		// Off eCash no Core answers, so nothing rewinds and the blocks stay.
		// The network this install runs, not the document's first row: a user on
		// a retained entry holds that chain.
		o.mu.RLock()
		served := o.Catalog
		o.mu.RUnlock()
		if !o.ecashChangeHasASharedBlock(o.RunningECashID(served), target) {
			o.restoreECashPick(previousPick)
			return fmt.Errorf("no fork height says where the two eCash chains part")
		}
	}
	o.log.Info().
		Str("current", config.ECashNetworkID()).
		Str("confirmed", target).
		Msg("eCash network switch confirmed")
	return nil
}

// restoreECashPick puts back the pick a failed confirm already wrote, so the
// prompt returns and the record keeps describing the chain on disk.
func (o *Orchestrator) restoreECashPick(pick string) {
	if o.Settings == nil {
		return
	}
	if _, err := o.Settings.SetECashNetworkID(pick); err != nil {
		o.log.Error().Err(err).Msg("could not put the eCash network pick back after a failed confirm")
	}
}

// refreshNetworkCatalog fetches the published document and takes it in memory.
// A failed fetch is never fatal: the compiled-in document stays in force.
func (o *Orchestrator) refreshNetworkCatalog(ctx context.Context) {
	fetched, err := netcatalog.Fetch(ctx, o.publishedCatalogURL())
	if err != nil {
		o.log.Warn().Err(err).Msg("network catalog refresh failed, using the compiled-in document")
		return
	}
	o.mu.RLock()
	current := o.Catalog
	running := o.ecashID
	o.mu.RUnlock()

	next := retainRunningECash(fetched, current, running)
	// Every entry matters, not just the eCash one: the picker lists them all and
	// the endpoints come from their backends. An id-only compare threw away a
	// refresh that added a network, so it never reached the picker.
	if next.SameAs(current) {
		return
	}
	// Rows only: the chain this install runs is the user's to change.
	o.adoptCatalogRows(next, running)
	o.log.Info().
		Str("current", running).
		Str("published", next.ECashID()).
		Msg("took the published network catalog")
}

// publishedCatalogURL is where the document is fetched from.
func (o *Orchestrator) publishedCatalogURL() string {
	if o.catalogURL == "" {
		return netcatalog.DefaultURL
	}
	return o.catalogURL
}

// retainRunningECash keeps the entry for the network this install runs when the
// published document drops it. It goes last, so the live network still leads.
func retainRunningECash(fetched, current netcatalog.Catalog, id string) netcatalog.Catalog {
	if id == "" {
		return fetched
	}
	if _, ok := fetched.ByID(id); ok {
		return fetched
	}
	running, ok := current.ByID(id)
	if !ok {
		return fetched
	}
	rows := make([]netcatalog.Network, 0, len(fetched.Networks)+1)
	fetched.Networks = append(append(rows, fetched.Networks...), running)
	return fetched
}

// adoptCatalog stores the catalog and expands the eCash placeholder across
// the binary configs so every download path sees a concrete filename.
// Only safe before the RPC server is accepting requests: it writes state that
// the handlers then read without a shared lock.
func (o *Orchestrator) adoptCatalog(c netcatalog.Catalog, id string) {
	if id == "" {
		o.log.Warn().Msg("network catalog carries no eCash network, eCash downloads will not resolve")
	}

	// Logged, not returned: a start moves no chain, and the conf sentinel the
	// swap writes still names the network this install runs.
	if err := o.recordECashChain(id); err != nil {
		o.log.Warn().Err(err).Msg("could not record the eCash network this install runs")
	}
	o.adoptCatalogRows(c, id)

	o.mu.RLock()
	conf := o.BitcoinConf
	enforcerConf := o.EnforcerConf
	o.mu.RUnlock()

	if id == "" {
		return
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

// recordECashChain persists the network this install serves, so a start off
// eCash still knows which fork the blocks belong to.
func (o *Orchestrator) recordECashChain(id string) error {
	if id == "" || o.Settings == nil {
		return nil
	}
	if err := o.Settings.SetECashChainID(id); err != nil {
		return fmt.Errorf("record the eCash chain %s: %w", id, err)
	}
	return nil
}

// adoptCatalogRows takes a document in memory: the picker rows, their endpoints
// and their fork heights. It writes no conf, so a refresh can call it live.
func (o *Orchestrator) adoptCatalogRows(c netcatalog.Catalog, id string) {
	o.mu.Lock()
	o.Catalog = c
	o.ecashID = id
	// Always expand from the pristine configs: a previous adopt already
	// replaced the placeholder, so re-expanding those would leave the old
	// network pinned forever.
	for name, raw := range o.rawConfigs {
		o.configs[name] = expandECashPlaceholder(raw, id)
	}
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
			config.SetNetworkEndpoints(net, n)
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

// RunningECashID returns the eCash network this install serves: the pick, then
// the conf, then the record, and only then the document's first row. The conf
// and the record win even when the document drops their network: the blocks
// belong to it.
func (o *Orchestrator) RunningECashID(c netcatalog.Catalog) string {
	if picked := o.pinnedECashID(c); picked != "" {
		return picked
	}
	if installed := o.installedECashNetwork(); installed != "" {
		return installed
	}
	// A swap to another network strips the conf sentinel, so off eCash this
	// record is the only thing that still names the blocks on disk.
	if o.Settings != nil {
		if recorded := o.Settings.ECashChainID(); recorded != "" {
			return recorded
		}
	}
	return c.ECashID()
}

// pinnedECashID returns the user's pick while the catalog still lists it. A
// pick the document dropped is a network the user left long ago, and the conf
// then names the one whose blocks are on disk.
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
// runs on the next start. An id the catalog does not list is ignored: a caller
// that sends the bare slot name keeps whatever the catalog resolves.
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
	// new generation cannot inherit the old one's. That chain rebuilds from the
	// blocks; Core's own block store is never touched. Off eCash the directory
	// belongs to the running network, so the work waits for the swap back.
	if err := o.Settings.SetPendingEnforcerWipe(id); err != nil {
		// Put the pick back: a durable pick with no cleanup record boots the new
		// generation on the retired generation's validator chain, and the
		// previous == id guard above keeps a retry from ever writing it.
		if _, rbErr := o.Settings.SetECashNetworkID(previous); rbErr != nil {
			o.log.Error().Err(rbErr).Str("previous", previous).
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
// catalog it booted with — an upgrade from an older build therefore reads every
// network published since as new, and says so.
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
