package orchestrator

import (
	"context"
	"maps"
	"os"
	"path/filepath"
	"strconv"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func ecashVariantConfig() BinaryConfig {
	return BinaryConfig{
		Name:          "bitcoind",
		IsBitcoinCore: true,
		ChainLayer:    1,
		Variants: map[string]CoreVariantSpec{
			"ecash": {
				ID:        "ecash",
				Subfolder: "{ecash}",
				BaseURL:   "https://releases.drivechain.info/",
				Files: map[string]string{
					"linux-x86_64": "L1-ecash-bitcoin-{ecash}-x86_64-unknown-linux-gnu.zip",
					"macos-arm64":  "L1-ecash-bitcoin-{ecash}-aarch64-apple-darwin.zip",
				},
			},
			"patched": {ID: "patched", Subfolder: "drivechain-patched", Files: map[string]string{"linux-x86_64": "patched.zip"}},
		},
	}
}

func TestExpandECashPlaceholder(t *testing.T) {
	got := expandECashPlaceholder(ecashVariantConfig(), "drynet3")

	v := got.Variants["ecash"]
	if v.Subfolder != "drynet3" {
		t.Errorf("subfolder = %q, want drynet3", v.Subfolder)
	}
	if want := "L1-ecash-bitcoin-drynet3-x86_64-unknown-linux-gnu.zip"; v.Files["linux-x86_64"] != want {
		t.Errorf("linux file = %q, want %q", v.Files["linux-x86_64"], want)
	}
	if want := "L1-ecash-bitcoin-drynet3-aarch64-apple-darwin.zip"; v.Files["macos-arm64"] != want {
		t.Errorf("macos file = %q, want %q", v.Files["macos-arm64"], want)
	}
	if p := got.Variants["patched"]; p.Subfolder != "drivechain-patched" || p.Files["linux-x86_64"] != "patched.zip" {
		t.Errorf("non-ecash variant must be untouched, got %+v", p)
	}
}

// An empty id means the catalog carried no generation. Leaving the placeholder
// in place makes the download fail loudly rather than fetching a wrong file.
func TestExpandECashPlaceholderEmptyIDLeavesConfig(t *testing.T) {
	got := expandECashPlaceholder(ecashVariantConfig(), "")
	if got.Variants["ecash"].Subfolder != "{ecash}" {
		t.Errorf("subfolder = %q, want the placeholder left alone", got.Variants["ecash"].Subfolder)
	}
}

// The chains_config.json watcher reinstates raw configs on every file change,
// so expansion has to survive a reload rather than happening once at boot.
func TestUpdateConfigsExpandsPlaceholder(t *testing.T) {
	o := &Orchestrator{configs: map[string]BinaryConfig{}, ecashID: "drynet3"}
	o.UpdateConfigs([]BinaryConfig{ecashVariantConfig()})

	if got := o.configs["bitcoind"].Variants["ecash"].Subfolder; got != "drynet3" {
		t.Errorf("subfolder after UpdateConfigs = %q, want drynet3", got)
	}
}

func catalogTestNode(t *testing.T) *Orchestrator {
	t.Helper()
	id := config.ECashNetworkID()
	endpoints := config.ECashEndpoints()
	height := config.PublishedForkHeight(config.NetworkECash)
	name := config.PublishedDisplayName(config.NetworkECash)
	t.Cleanup(func() {
		config.SetECashNetworkID(id)
		config.SetECashEndpoints(endpoints)
		config.SetForkHeight(config.NetworkECash, height)
		config.SetNetworkDisplayName(config.NetworkECash, name)
	})
	return ecashInstall(t)
}

func TestCatalogKeepsDiskIdentity(t *testing.T) {
	for _, saved := range []bool{false, true} {
		name := "conf_identity"
		if saved {
			name = "saved_identity"
		}
		t.Run(name, func(t *testing.T) {
			o := catalogTestNode(t)
			catalog := netcatalog.Catalog{Networks: []netcatalog.Network{
				{ID: "betanet", Family: netcatalog.FamilyECash},
				{ID: "alphanet", Family: netcatalog.FamilyECash},
			}}
			o.adoptCatalog(catalog, "alphanet")
			blocks := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
			require.NoError(t, os.MkdirAll(blocks, 0700))
			path := filepath.Join(blocks, "blk00000.dat")
			data := []byte{0xec, 0xa5, 0xa1, 0x04}
			require.NoError(t, os.WriteFile(path, data, 0600))
			if !saved {
				require.NoError(t, o.Settings.SetECashChainID(""))
			}
			_, err := o.Settings.SetECashNetworkID("betanet")
			require.NoError(t, err)
			require.Equal(t, "alphanet", o.installedECashNetwork())
			o.adoptCatalog(catalog, o.RunningECashID(catalog))
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			require.Equal(t, "betanet", o.ecashID)
			require.ErrorContains(t, o.checkECashMigrationStart(context.Background(), ecashVariantConfig()), "ECX files belong to alphanet")
			o.adoptCatalog(catalog, "betanet")
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			actual, err := os.ReadFile(path)
			require.NoError(t, err)
			require.Equal(t, data, actual)
		})
	}
}

func TestCatalogKeepsEmptyDirectoryBehavior(t *testing.T) {
	o := catalogTestNode(t)
	require.NoError(t, os.MkdirAll(filepath.Join(o.BitcoinConf.DataDir(), "blocks"), 0700))
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "betanet", Family: netcatalog.FamilyECash},
	}}, "betanet")
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	require.Equal(t, "betanet", o.ecashID)
	require.NoError(t, o.checkECashMigrationStart(context.Background(), ecashVariantConfig()))
}

func TestCatalogKeepsConfigBeforeMigrationCompletion(t *testing.T) {
	for _, test := range []struct {
		name     string
		selected string
		pending  bool
	}{
		{"pending_same_id", "alphanet", true},
		{"pending_target_id", "betanet", true},
		{"selected_target_id", "betanet", false},
	} {
		t.Run(test.name, func(t *testing.T) {
			o := catalogTestNode(t)
			catalog := netcatalog.Catalog{Networks: []netcatalog.Network{
				{ID: "betanet", Family: netcatalog.FamilyECash},
				{ID: "alphanet", Family: netcatalog.FamilyECash},
			}}
			o.adoptCatalog(catalog, "alphanet")
			blocks := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
			require.NoError(t, os.MkdirAll(blocks, 0700))
			require.NoError(t, os.WriteFile(filepath.Join(blocks, "blk00000.dat"), []byte{1}, 0600))
			o.BitcoinConf.Config.SetSetting("rpcport", "18444", "main")
			require.NoError(t, o.BitcoinConf.SaveConfig())
			o.EnforcerConf.Config.Settings["network-preset"] = "alphanet"
			require.NoError(t, o.EnforcerConf.SaveConfig())
			coreConfig := o.BitcoinConf.Config.Serialize()
			enforcerSettings := maps.Clone(o.EnforcerConf.Config.Settings)
			enforcerConfig, err := os.ReadFile(o.EnforcerConf.ConfigPath)
			require.NoError(t, err)
			if test.pending {
				require.NoError(t, saveMigrationFile(o.migrationPath(), ecashMigration{
					Status: ECashMigrationStatus{JobID: "test", FromID: "alphanet", ToID: "betanet"}, Step: 2,
				}))
			}
			o.adoptCatalog(catalog, test.selected)
			require.Equal(t, test.selected, o.ecashID)
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			require.Equal(t, "alphanet", o.installedECashNetwork())
			require.Equal(t, "alphanet", o.BitcoinConf.ECashID)
			require.Equal(t, 18444, o.BitcoinConf.GetRPCPort())
			require.Equal(t, coreConfig, o.BitcoinConf.Config.Serialize())
			require.Equal(t, enforcerSettings, o.EnforcerConf.Config.Settings)
			data, err := os.ReadFile(o.BitcoinConf.GetConfFilePath())
			require.NoError(t, err)
			require.Equal(t, coreConfig, string(data))
			data, err = os.ReadFile(o.EnforcerConf.ConfigPath)
			require.NoError(t, err)
			require.Equal(t, enforcerConfig, data)
		})
	}
}

func TestCatalogGetsIdentityFromMigration(t *testing.T) {
	for _, step := range []int{2, 4} {
		t.Run("step_"+strconv.Itoa(step), func(t *testing.T) {
			o := catalogTestNode(t)
			blocks := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
			require.NoError(t, os.MkdirAll(blocks, 0700))
			require.NoError(t, os.WriteFile(filepath.Join(blocks, "blk00000.dat"), []byte{1}, 0600))
			require.NoError(t, o.Settings.SetECashChainID(""))
			o.BitcoinConf.Config.SetSetting("uacomment", config.ECashUAComment("betanet"), "main")
			require.NoError(t, saveMigrationFile(o.migrationPath(), ecashMigration{
				Status: ECashMigrationStatus{JobID: "test", FromID: "alphanet", ToID: "betanet"}, Step: step,
			}))
			id, err := o.catalogChainID("betanet")
			require.NoError(t, err)
			if step < 4 {
				require.Equal(t, "alphanet", id)
			} else {
				require.Equal(t, "betanet", id)
			}
		})
	}
}

func TestCatalogRejectsUnknownDiskIdentity(t *testing.T) {
	o := catalogTestNode(t)
	blocks := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0700))
	require.NoError(t, os.WriteFile(filepath.Join(blocks, "blk00000.dat"), []byte{1}, 0600))
	require.NoError(t, o.Settings.SetECashChainID(""))
	o.BitcoinConf.Config.SetSetting("uacomment", "", "main")
	_, err := o.catalogChainID("betanet")
	require.ErrorContains(t, err, "no saved network identity")
	o.adoptCatalog(netcatalog.Catalog{}, "betanet")
	require.Empty(t, o.Settings.ECashChainID())
}
