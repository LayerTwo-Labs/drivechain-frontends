package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"path/filepath"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/blockfile"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// DatadirNetwork is what the blocks on disk say, next to what the app runs.
type DatadirNetwork struct {
	// Magic is the network magic the newest block file carries.
	Magic string
	// DetectedID names the catalog network that writes that magic, empty when
	// no published network does.
	DetectedID   string
	DetectedName string
	// FirstMagic is the magic the oldest block file carries, with the network
	// that writes it. They differ from Magic and DetectedID when a conversion
	// stopped part way.
	FirstMagic string
	FirstID    string
	FirstName  string
	// Mixed is true when the two ends carry different networks, so no node reads
	// every block in the directory.
	Mixed bool
	// SelectedID is the network the app runs.
	SelectedID   string
	SelectedName string
	// Mismatch is true when the blocks do not belong to the network the app
	// runs, either because they name another one or because two networks wrote
	// them.
	Mismatch bool
	// SwitchReadsBlocks is true when a switch to the detected network reads
	// this same directory. Core keeps one directory per chain and one per
	// datadir group, so a switch elsewhere leaves these blocks where they are.
	SwitchReadsBlocks bool
	// ConvertFromID names the network whose records a conversion has to move,
	// empty when no single network can move. It is the end that is not the one
	// the app runs.
	ConvertFromID   string
	ConvertFromName string
}

// ReadDatadirNetwork reads the network out of the block files and compares it
// with the one the app runs. The blocks name the chain, so a datadir that came
// from another network says so before a rollback throws the balance away.
func (o *Orchestrator) ReadDatadirNetwork(ctx context.Context) (DatadirNetwork, error) {
	if o.BitcoinConf == nil || o.BitcoinConf.Config == nil {
		return DatadirNetwork{}, fmt.Errorf("no bitcoin.conf is loaded")
	}
	network := config.Network(o.CurrentNetwork())
	ends, err := blockfile.ReadEnds(ctx, o.coreBlocksDir(network))
	if errors.Is(err, blockfile.ErrNoBlocks) {
		// A datadir with no blocks names no network, which is an answer rather
		// than a failure: the caller clears whatever it said before.
		return DatadirNetwork{}, nil
	}
	if err != nil {
		return DatadirNetwork{}, err
	}

	o.mu.RLock()
	cat := o.Catalog
	o.mu.RUnlock()

	out := DatadirNetwork{Magic: ends.Last.String(), FirstMagic: ends.First.String()}
	out.DetectedID, out.DetectedName = nameMagic(cat, out.Magic)
	out.FirstID, out.FirstName = nameMagic(cat, out.FirstMagic)
	// An unknown magic names no network, and the caller then asks again rather
	// than warn about a directory it cannot describe.
	out.Mixed = !ends.Uniform() && out.DetectedID != "" && out.FirstID != ""
	selected := o.SelectedNetworkID(cat)
	switch entry, ok := cat.ByID(selected); {
	case ok:
		out.SelectedID, out.SelectedName = entry.ID, displayName(entry)
	case selected == regtestOption.ID:
		out.SelectedID, out.SelectedName = regtestOption.ID, regtestOption.DisplayName
	default:
		out.SelectedID = selected
	}
	// A slot and its catalog row carry different names, so a mainnet install
	// selects "mainnet" while the row it runs is "bitcoin".
	if out.DetectedID != "" && out.SelectedID != out.DetectedID {
		if slot, ok := config.NetworkForCatalogEntry(out.DetectedID, ""); ok && string(slot) == out.SelectedID {
			out.SelectedID, out.SelectedName = out.DetectedID, out.DetectedName
		}
	}
	out.Mismatch = out.Mixed || out.DetectedID != "" && out.SelectedID != "" && out.DetectedID != out.SelectedID
	if out.Mismatch {
		out.SwitchReadsBlocks = o.sameBlocksDir(cat, out.DetectedID, network)
		out.ConvertFromID, out.ConvertFromName = out.convertSource(cat)
	}
	return out, nil
}

// convertSource names the network a conversion can move onto the one the app
// runs, empty when none can. The migration rewinds to the block the two networks
// share and replays the target, so the target has to fork the mainchain after
// the source, and both have to be eCash.
func (n DatadirNetwork) convertSource(cat netcatalog.Catalog) (string, string) {
	id, name := n.mixedSource()
	if id == "" {
		return "", ""
	}
	from, okFrom := cat.ByID(id)
	to, okTo := cat.ByID(n.SelectedID)
	if !okFrom || !okTo || from.Family != netcatalog.FamilyECash || to.Family != netcatalog.FamilyECash {
		return "", ""
	}
	if from.ForkHeight <= 1 || to.ForkHeight <= from.ForkHeight {
		return "", ""
	}
	return id, name
}

// mixedSource names the end of the directory that is not the network the app
// runs. A mixed directory holds two, and the one that matches the app stays as
// it is: the conversion moves the other. Empty when both ends differ, because no
// single conversion reaches the running network then.
func (n DatadirNetwork) mixedSource() (string, string) {
	if !n.Mixed {
		return n.DetectedID, n.DetectedName
	}
	if n.FirstID == n.SelectedID {
		return n.DetectedID, n.DetectedName
	}
	if n.DetectedID == n.SelectedID {
		return n.FirstID, n.FirstName
	}
	return "", ""
}

// nameMagic names the catalog network that writes a magic. Regtest carries no
// catalog row — nothing is deployed for it — so it answers from the local one.
func nameMagic(cat netcatalog.Catalog, magic string) (string, string) {
	if entry, ok := cat.ByMagic(magic); ok {
		return entry.ID, displayName(entry)
	}
	if strings.EqualFold(magic, regtestMagic) {
		return regtestOption.ID, regtestOption.DisplayName
	}
	return "", ""
}

// sameBlocksDir reports whether a network reads the directory the app reads
// right now.
func (o *Orchestrator) sameBlocksDir(cat netcatalog.Catalog, id string, running config.Network) bool {
	family := ""
	if entry, ok := cat.ByID(id); ok {
		family = entry.Family
	}
	target, ok := config.NetworkForCatalogEntry(id, family)
	if !ok {
		if id != regtestOption.ID {
			return false
		}
		target = config.NetworkRegtest
	}
	return sameDir(o.coreBlocksDir(target), o.coreBlocksDir(running))
}

// sameDir reports whether two paths name one directory. A user can point two
// datadir groups at one place through a link, and the names then differ.
func sameDir(a, b string) bool {
	if a == b {
		return true
	}
	resolvedA, err := filepath.EvalSymlinks(a)
	if err != nil {
		return false
	}
	resolvedB, err := filepath.EvalSymlinks(b)
	if err != nil {
		return false
	}
	return resolvedA == resolvedB
}

// datadirRootFor names the data directory of a network. Each datadir group
// keeps its own, so a network outside the running group reads another one.
func (o *Orchestrator) datadirRootFor(n config.Network) string {
	group := config.DatadirGroupForNetwork(n)
	if group == config.DatadirGroupForNetwork(config.Network(o.CurrentNetwork())) {
		return o.BitcoinConf.RootDataDir()
	}
	if dir := o.BitcoinConf.Config.GetGroupDatadir(group); dir != "" {
		return dir
	}
	return config.BitcoinCoreDirs.RootDirNetwork(n)
}

// coreBlocksDir names the directory Core keeps the blocks in. Core takes the
// blocksdir setting, else the datadir base, and adds the network subdirectory
// and "blocks" to it (common/args.cpp, GetBlocksDirPath).
func (o *Orchestrator) coreBlocksDir(network config.Network) string {
	base := o.datadirRootFor(network)
	if dir := o.BitcoinConf.Config.GetEffectiveSetting("blocksdir", network.CoreSection()); dir != "" {
		if filepath.IsAbs(dir) {
			base = dir
		} else {
			base = filepath.Join(base, dir)
		}
	}
	// Mainnet and eCash run on the main chain, which keeps no subdirectory.
	sub := ""
	if network != config.NetworkMainnet && network != config.NetworkECash {
		sub = network.CoreChainDir()
	}
	return filepath.Join(base, sub, "blocks")
}

// SelectedNetworkID names the network the app runs: the eCash generation while
// it serves eCash, else the slot itself.
func (o *Orchestrator) SelectedNetworkID(c netcatalog.Catalog) string {
	if config.Network(o.CurrentNetwork()) == config.NetworkECash {
		return o.RunningECashID(c)
	}
	return o.CurrentNetwork()
}

func displayName(n netcatalog.Network) string {
	if n.DisplayName != "" {
		return n.DisplayName
	}
	return n.ID
}
