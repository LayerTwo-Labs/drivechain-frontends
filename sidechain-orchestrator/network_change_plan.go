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
}

// PlanNetworkChange reports what a change needs before it can be applied.
// Side-effect free, so prepare and apply both run it.
func (o *Orchestrator) PlanNetworkChange(req NetworkChangeRequest) NetworkChangePlan {
	current := config.NetworkFromString(o.CurrentNetwork())
	target := current
	if req.Network != "" {
		target = config.NetworkFromString(req.Network)
	}

	currentBackend := o.activeWalletBackend()
	targetBackend := currentBackend
	switch {
	case req.WalletID != "":
		targetBackend = o.walletBackendByID(req.WalletID)
	case req.WalletBackend != "":
		targetBackend = req.WalletBackend
	}

	plan := NetworkChangePlan{
		Network:            target,
		WalletBackend:      targetBackend,
		DatadirGroup:       config.DatadirGroupForNetwork(target),
		NeedsLocalBackends: targetBackend != wallet.WalletTypeElectrum,
		NoOp:               target == current && targetBackend == currentBackend,
	}

	if o.BitcoinConf != nil && o.BitcoinConf.Config != nil {
		plan.Datadir = o.BitcoinConf.Config.GetGroupDatadir(plan.DatadirGroup)
	}

	// Electrum runs no local Bitcoin backends, so nothing is downloaded and no
	// chain directory is needed — the same predicate StartWithL1 uses.
	if !plan.NeedsLocalBackends {
		return plan
	}

	plan.MustSelectDatadir = o.BitcoinConf == nil || !o.BitcoinConf.HasDatadirForNetwork(target)
	plan.ImpliesChainDownload = plan.MustSelectDatadir || !hasChainData(plan.Datadir, target)
	plan.MissingBinaries = o.missingL1Binaries()
	plan.NeedsBinaryDownload = len(plan.MissingBinaries) > 0

	return plan
}

func (o *Orchestrator) activeWalletBackend() wallet.WalletType {
	if o.WalletSvc == nil {
		return wallet.WalletTypeBitcoinCore
	}
	w := o.WalletSvc.ActiveWallet()
	if w == nil {
		return wallet.WalletTypeBitcoinCore
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
