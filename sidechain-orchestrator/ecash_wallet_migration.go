package orchestrator

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"slices"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/corewalletfile"
)

func (o *Orchestrator) hasECashData() (bool, error) {
	chain, err := o.hasECashChainFiles()
	if err != nil || chain {
		return chain, err
	}
	paths, err := o.ecashWalletFiles()
	if errors.Is(err, corewalletfile.ErrLegacyWallet) {
		return true, nil
	}
	return len(paths) > 0, err
}

func (o *Orchestrator) ecashWalletFiles() ([]string, error) {
	if o.BitcoinConf == nil {
		return nil, nil
	}
	root := o.ecashDatadir()
	if root == "" {
		if config.NetworkFromString(o.Network) != config.NetworkECash {
			return nil, nil
		}
		root = o.BitcoinConf.RootDataDir()
	}
	return corewalletfile.FindWallets(root, o.BitcoinConf.Config.GetEffectiveSetting("walletdir", "main"))
}

func (o *Orchestrator) setWalletOnlyMigration(state *ecashMigration, paths []string) {
	state.Status.WalletOnly = true
	state.Status.CommonHeight = 0
	state.Status.CommonHash = config.ChainParamsFor(config.NetworkECash).GenesisHash.String()
	state.WalletDir = o.BitcoinConf.Config.GetEffectiveSetting("walletdir", "main")
	for _, path := range paths {
		state.WalletPaths = append(state.WalletPaths, filepath.Dir(path))
	}
}

func (o *Orchestrator) checkWalletOnlySource(ctx context.Context, client *CoreStatusClient, state *ecashMigration) error {
	if state.Status.WalletOnly {
		return checkMigrationChain(ctx, client, state, true)
	}
	var chain struct {
		Blocks int64 `json:"blocks"`
	}
	if err := migrationRPC(ctx, client, "getblockchaininfo", &chain); err != nil {
		return err
	}
	if chain.Blocks != 0 {
		return nil
	}
	paths, err := o.ecashWalletFiles()
	if err != nil || len(paths) == 0 {
		return err
	}
	o.setWalletOnlyMigration(state, paths)
	return checkMigrationChain(ctx, client, state, true)
}

func (o *Orchestrator) normalizeWalletOnlyPaths(state *ecashMigration) error {
	var paths []string
	for _, name := range state.WalletPaths {
		path, err := migrationWalletPath(state, name)
		if err != nil {
			return err
		}
		if !slices.Contains(paths, path) {
			paths = append(paths, path)
		}
	}
	state.WalletPaths = paths
	return nil
}

func migrationWalletPath(state *ecashMigration, name string) (string, error) {
	if filepath.IsAbs(name) {
		return filepath.EvalSymlinks(name)
	}
	base := state.WalletDir
	if base == "" {
		base = filepath.Join(state.Status.DataDir, "wallets")
		if _, err := os.Stat(base); err != nil {
			if !os.IsNotExist(err) {
				return "", err
			}
			base = state.Status.DataDir
		}
	}
	return filepath.EvalSymlinks(filepath.Join(base, name))
}
