package orchestrator

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// NetworkChangeRequest describes an intended change. Empty fields keep what is
// already in use, so a network swap and a wallet swap share one shape.
type NetworkChangeRequest struct {
	Network       string
	WalletBackend wallet.WalletType
	WalletID      string
}

// NetworkChangePlan is what the change would require of the user. Produced by
// PlanNetworkChange, the only place these conditions are derived.
type NetworkChangePlan struct {
	Network              config.Network
	WalletBackend        wallet.WalletType
	MustSelectDatadir    bool
	Datadir              string
	DatadirGroup         config.DatadirGroup
	NeedsLocalBackends   bool
	ImpliesChainDownload bool
	MissingBinaries      []string
	NeedsBinaryDownload  bool
	NoOp                 bool
	// No chain source exists for an electrum wallet on this network, so every
	// wallet read would fail once the swap applied.
	NoChainSource bool
}

// PlanNetworkChange reports what a change needs before it can be applied.
// Side-effect free, so prepare and apply both run it.
func (o *Orchestrator) PlanNetworkChange(req NetworkChangeRequest) NetworkChangePlan {
	current := config.NetworkFromString(o.CurrentNetwork())
	target := current
	// The eCash entries share one slot, so a move between two of them changes
	// no network. Only the id says the chain moves, and a plan that read that
	// as no work would stop the switch before it started.
	ecashSwitch := false
	if req.Network != "" {
		if resolved, ok := o.NetworkForOption(req.Network); ok {
			target = resolved
		} else {
			target = config.NetworkFromString(req.Network)
		}
		if plan, err := o.PlanECashSwitch(req.Network); err == nil {
			ecashSwitch = plan.FromID != "" && plan.FromID != plan.ToID
		}
	}

	currentBackend := o.activeWalletBackend()
	targetBackend := currentBackend
	switch {
	case req.WalletID != "":
		targetBackend = o.walletBackendByID(req.WalletID)
	case req.WalletBackend != "":
		targetBackend = req.WalletBackend
	}

	// The node mode decides whether a local node runs, so the plan follows it
	// rather than the wallet backend. Full mode with an electrum wallet still
	// runs Core, and light mode runs nothing whatever the wallet is.
	//
	// With no mode picked, nothing is about to start Core, so only an explicit
	// network change is heading for a local node. Treating that as Core is what
	// made a fresh boot demand a Bitcoin datadir before wallet creation.
	mode := NodeModeForNetwork(ReadNodeMode(o.BitwindowDir), target)
	needsLocalBackends := mode == NodeModeFull
	if mode == NodeModeUnset && req.Network != "" {
		// An explicit swap is a move onto that network's local node, so it
		// still has to have somewhere to put the chain.
		needsLocalBackends = true
	}

	plan := NetworkChangePlan{
		Network:            target,
		WalletBackend:      targetBackend,
		DatadirGroup:       config.DatadirGroupForNetwork(target),
		NeedsLocalBackends: needsLocalBackends,
		NoOp:               target == current && targetBackend == currentBackend && !ecashSwitch,
	}

	if o.BitcoinConf != nil && o.BitcoinConf.Config != nil {
		plan.Datadir = o.BitcoinConf.Config.GetGroupDatadir(plan.DatadirGroup)
	}

	// Light mode runs no local Bitcoin backends, so nothing is downloaded and
	// no chain directory is needed — the same predicate StartWithL1 uses.
	if mode == NodeModeLight {
		plan.NoChainSource = len(config.WalletChainSourceURLsForNetwork(target)) == 0
		return plan
	}
	if !plan.NeedsLocalBackends {
		return plan
	}

	plan.MustSelectDatadir = o.BitcoinConf == nil || !o.BitcoinConf.HasDatadirForNetwork(target)
	plan.ImpliesChainDownload = plan.MustSelectDatadir || !hasChainData(plan.Datadir, target)
	plan.MissingBinaries = o.missingL1Binaries()
	plan.NeedsBinaryDownload = len(plan.MissingBinaries) > 0

	return plan
}

// activeWalletBackend returns the backend of the wallet in use, empty when no
// wallet is active. Empty is not Core: assuming Core before the user has any
// wallet is what made a fresh boot demand a Bitcoin datadir.
func (o *Orchestrator) activeWalletBackend() wallet.WalletType {
	if o.WalletSvc == nil {
		return ""
	}
	w := o.WalletSvc.ActiveWallet()
	if w == nil {
		return ""
	}
	return w.WalletType
}

func (o *Orchestrator) walletBackendByID(walletID string) wallet.WalletType {
	if o.WalletSvc == nil {
		return wallet.WalletTypeBitcoinCore
	}
	w := o.WalletSvc.GetWalletByID(walletID)
	if w == nil {
		return o.activeWalletBackend()
	}
	return w.WalletType
}

// missingL1Binaries reports which local Bitcoin backends are not on disk.
func (o *Orchestrator) missingL1Binaries() []string {
	var missing []string
	for _, name := range []string{"bitcoind", "enforcer"} {
		status := o.Status(name)
		if status.Downloadable && !status.Downloaded {
			missing = append(missing, name)
		}
	}
	return missing
}

// hasChainData reports whether a datadir already holds this network's blocks.
// The per-network layout comes from BinaryDirConfig, not a second copy of it.
func hasChainData(datadir string, n config.Network) bool {
	if datadir == "" {
		return false
	}
	for _, dc := range config.AllDirConfigs() {
		if dc.BinaryName != "bitcoind" {
			continue
		}
		entries, err := os.ReadDir(filepath.Join(dc.DatadirNetwork(n, datadir), "blocks"))
		return err == nil && len(entries) > 0
	}
	return false
}

// SetDatadirForCurrentNetwork persists the datadir a user picked in response to
// a plan's must_select_datadir, without changing network.
func (o *Orchestrator) SetDatadirForCurrentNetwork(dataDir string) error {
	if o.BitcoinConf == nil {
		return fmt.Errorf("bitcoin config manager not initialised")
	}
	return o.BitcoinConf.UpdateDataDir(dataDir, config.NetworkFromString(o.CurrentNetwork()))
}
