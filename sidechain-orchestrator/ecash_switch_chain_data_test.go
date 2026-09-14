package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func TestPlanECashSwitchReportsChainData(t *testing.T) {
	for _, test := range []struct {
		name      string
		file      string
		blocksDir string
	}{
		{name: "empty directory"},
		{name: "block file", file: "blocks/blk00000.dat"},
		{name: "chainstate", file: "chainstate/CURRENT"},
		{name: "block index", file: "blocks/index/CURRENT"},
		{name: "separate blocks directory", file: "blocks/blk00005.dat", blocksDir: "absolute"},
		{name: "relative blocks directory", file: "blocks/blk00005.dat", blocksDir: "relative"},
	} {
		t.Run(test.name, func(t *testing.T) {
			o := newTestOrchestrator(t)
			o.Catalog = ecashCatalog()
			o.ecashID = "drynet4"
			require.NoError(t, o.Settings.SetECashChainID("drynet4"))
			root := t.TempDir()
			o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, root)
			fileRoot := root
			switch test.blocksDir {
			case "absolute":
				fileRoot = t.TempDir()
				o.BitcoinConf.Config.SetSetting("blocksdir", fileRoot, "main")
			case "relative":
				fileRoot = filepath.Join(root, "block-data")
				o.BitcoinConf.Config.SetSetting("blocksdir", "block-data", "main")
			}
			if test.file != "" {
				path := filepath.Join(fileRoot, filepath.FromSlash(test.file))
				require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
				require.NoError(t, os.WriteFile(path, []byte("chain data"), 0o600))
			}

			plan, err := o.PlanECashSwitch("alphanet")

			require.NoError(t, err)
			require.Equal(t, test.file != "", plan.HasChainData)
			if test.file == "" {
				require.Empty(t, plan.ChainID)
			} else {
				require.Equal(t, "drynet4", plan.ChainID)
			}
			require.Equal(t, "drynet4", plan.FromID)
			require.Equal(t, "alphanet", plan.ToID)
			require.True(t, plan.NeedsRollback)
			require.EqualValues(t, 961631, plan.RewindHeight)
		})
	}
}

func TestPlanECashSwitchReportsChainDataForTheCurrentNetwork(t *testing.T) {
	o := newTestOrchestrator(t)
	o.Catalog = ecashCatalog()
	o.ecashID = "alphanet"
	require.NoError(t, o.Settings.SetECashChainID("alphanet"))
	root := t.TempDir()
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, root)
	require.NoError(t, os.Mkdir(filepath.Join(root, "chainstate"), 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(root, "chainstate", "CURRENT"), []byte("MANIFEST-000001\n"), 0o600))

	plan, err := o.PlanECashSwitch("alphanet")

	require.NoError(t, err)
	require.True(t, plan.HasChainData)
	require.Equal(t, "alphanet", plan.ChainID)
	require.False(t, plan.NeedsRollback)
}

func TestPlanECashSwitchUsesOnlyTheECashDataPath(t *testing.T) {
	for _, network := range []config.Network{config.NetworkMainnet, config.NetworkECash} {
		t.Run(string(network), func(t *testing.T) {
			o := newTestOrchestrator(t)
			o.Network = string(network)
			o.Catalog = ecashCatalog()
			o.ecashID = "alphanet"
			require.NoError(t, o.Settings.SetECashChainID("alphanet"))
			root := t.TempDir()
			o.BitcoinConf.Network = network
			o.BitcoinConf.DetectedDataDir = root
			o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, "")
			o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, root)
			o.BitcoinConf.Config.SetSetting("datadir", "")
			o.BitcoinConf.Config.SetSetting("datadir", root, "main")
			require.NoError(t, os.Mkdir(filepath.Join(root, "blocks"), 0o700))
			blockPath := filepath.Join(root, "blocks", "blk00000.dat")
			require.NoError(t, os.WriteFile(blockPath, []byte("chain data"), 0o600))
			require.Empty(t, o.ecashDatadir())

			plan, err := o.PlanECashSwitch("alphanet")

			require.NoError(t, err)
			require.Equal(t, network == config.NetworkECash, plan.HasChainData)
			if network == config.NetworkECash {
				require.Equal(t, "alphanet", plan.ChainID)
			} else {
				require.Empty(t, plan.ChainID)
			}
			data, err := os.ReadFile(blockPath)
			require.NoError(t, err)
			require.Equal(t, "chain data", string(data))
		})
	}
}

func TestPlanECashSwitchKeepsTheRetainedChainID(t *testing.T) {
	for _, network := range []config.Network{config.NetworkECash, config.NetworkMainnet} {
		t.Run(string(network), func(t *testing.T) {
			o := newTestOrchestrator(t)
			o.Network = string(network)
			o.Catalog = ecashCatalog()
			o.Catalog.Networks[2].ID = "betanet"
			o.ecashID = "betanet"
			require.NoError(t, o.Settings.SetECashChainID("alphanet"))
			root := t.TempDir()
			o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, root)
			require.NoError(t, os.Mkdir(filepath.Join(root, "blocks"), 0o700))
			require.NoError(t, os.WriteFile(filepath.Join(root, "blocks", "blk00000.dat"), []byte("alpha data"), 0o600))

			plan, err := o.PlanECashSwitch("betanet")

			require.NoError(t, err)
			require.True(t, plan.HasChainData)
			require.Equal(t, "alphanet", plan.ChainID)
			require.Equal(t, "betanet", plan.FromID)
			require.Equal(t, "betanet", plan.ToID)
			require.Zero(t, plan.RewindHeight)
			require.False(t, plan.NeedsRollback)
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
		})
	}
}

func TestPlanECashSwitchReturnsChainIdentityErrors(t *testing.T) {
	o := newTestOrchestrator(t)
	o.Catalog = ecashCatalog()
	o.ecashID = "alphanet"
	require.NoError(t, o.Settings.SetECashChainID(""))
	o.BitcoinConf.Config.SetSetting("uacomment", "", "main")
	root := t.TempDir()
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, root)
	require.NoError(t, os.Mkdir(filepath.Join(root, "blocks"), 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(root, "blocks", "blk00000.dat"), []byte("chain data"), 0o600))

	plan, err := o.PlanECashSwitch("alphanet")

	require.ErrorContains(t, err, "read ECX chain identity")
	require.ErrorContains(t, err, "no saved network identity")
	require.Equal(t, ECashSwitchPlan{}, plan)
}

func TestPlanECashSwitchReturnsChainDataReadErrors(t *testing.T) {
	o := newTestOrchestrator(t)
	o.Catalog = ecashCatalog()
	o.ecashID = "drynet4"
	root := t.TempDir()
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, root)
	o.BitcoinConf.Config.SetSetting("blocksdir", "[", "main")

	plan, err := o.PlanECashSwitch("alphanet")

	require.ErrorContains(t, err, "read ECX chain files")
	require.ErrorIs(t, err, filepath.ErrBadPattern)
	require.Equal(t, ECashSwitchPlan{}, plan)
}
