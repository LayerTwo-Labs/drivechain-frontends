package orchestrator

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sync/atomic"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func TestECashLightSwitchKeepsLocalFiles(t *testing.T) {
	for _, path := range []string{"direct", "pending"} {
		t.Run(path, func(t *testing.T) {
			o := lightECashTestNode(t)
			files := lightECashFiles(t, o)
			require.NoError(t, o.EnforcerConf.WriteConfig("network-preset=alphanet"))
			require.NoError(t, o.Settings.SetECashChainID(""))
			require.Equal(t, "alphanet", o.installedECashNetwork())

			if path == "pending" {
				o.Catalog.Networks[0], o.Catalog.Networks[1] = o.Catalog.Networks[1], o.Catalog.Networks[0]
				require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))
			} else {
				require.NoError(t, o.ApplyECashSwitch(context.Background(), "betanet"))
			}

			require.Equal(t, "betanet", o.ecashID)
			require.Equal(t, "betanet", o.Settings.ECashNetworkID())
			require.Equal(t, "betanet", o.installedECashNetwork())
			require.Equal(t, "betanet", o.EnforcerConf.Config.GetSetting("network-preset"))
			require.Equal(t, "new.example:8301", config.ECashEndpoints().P2P.Address)
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			require.Equal(t, "betanet", o.Settings.PendingEnforcerWipe())
			require.NoError(t, o.ApplyECashSwitch(context.Background(), "betanet"))
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			o.adoptCatalog(o.Catalog, "betanet")
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			require.Equal(t, "betanet", o.ecashID)
			require.NoFileExists(t, o.migrationPath())
			require.Empty(t, o.Settings.RewoundBlockHash())
			require.False(t, o.process.IsRunning("bitcoind"))
			checkLightECashFiles(t, files)
		})
	}
}

func TestECashLightSwitchKeepsSourceForFullMode(t *testing.T) {
	o := lightECashTestNode(t)
	files := lightECashFiles(t, o)
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "betanet"))
	core := BinaryConfig{IsBitcoinCore: true, ChainLayer: 1}
	services := []BinaryConfig{{Name: "enforcer"}, {Name: "thunder", ChainLayer: 2}, {Name: "bitnames", IsBitcoinCore: true, ChainLayer: 2}}
	want := "ECX files belong to alphanet; use drivechain-cli ecash migrate --from alphanet --to betanet --yes"
	require.EqualError(t, o.checkECashMigrationStart(context.Background(), core), want)
	for _, cfg := range services {
		require.NoError(t, o.checkECashMigrationStart(context.Background(), cfg))
	}
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.NoError(t, o.AdoptECashID("betanet"))
	require.Equal(t, "alphanet", o.Settings.ECashChainID())
	for _, cfg := range append(services, core) {
		require.EqualError(t, o.checkECashMigrationStart(context.Background(), cfg), want)
	}
	checkLightECashFiles(t, files)
}

func TestECashLightSwitchKeepsIncompleteJob(t *testing.T) {
	o := lightECashTestNode(t)
	files := lightECashFiles(t, o)
	state, err := o.newMigration("alphanet", "betanet")
	require.NoError(t, err)
	state.Status.JobID = "saved-job"
	state.Step = 2
	require.NoError(t, o.saveMigration(state))
	want := "resume ECX migration saved-job before a node start"
	require.EqualError(t, o.ApplyECashSwitch(context.Background(), "betanet"), want)
	for _, cfg := range []BinaryConfig{{Name: "enforcer"}, {ChainLayer: 2}, {IsBitcoinCore: true, ChainLayer: 1}} {
		require.EqualError(t, o.checkECashMigrationStart(context.Background(), cfg), want)
	}
	require.Equal(t, "alphanet", o.ecashID)
	require.Equal(t, "alphanet", o.Settings.ECashChainID())
	require.Equal(t, "alphanet", o.installedECashNetwork())
	checkLightECashFiles(t, files)
}

func TestECashLightSwitchRecordsEmptyDirectory(t *testing.T) {
	o := lightECashTestNode(t)
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "betanet"))
	require.Equal(t, "betanet", o.ecashID)
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "betanet"))
	require.NoFileExists(t, o.migrationPath())
}

func TestAdoptECashIDKeepsLightDiskSource(t *testing.T) {
	o := lightECashTestNode(t)
	files := lightECashFiles(t, o)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkRegtest))
	require.Equal(t, NodeModeFull, o.NodeMode())
	require.NoError(t, o.AdoptECashID("betanet"))
	require.Equal(t, "betanet", o.ecashID)
	require.Equal(t, "alphanet", o.Settings.ECashChainID())
	require.NoFileExists(t, o.migrationPath())
	for path := range files {
		if filepath.Base(path) == "state" {
			delete(files, path)
		}
	}
	checkLightECashFiles(t, files)
}

func lightECashTestNode(t *testing.T) *Orchestrator {
	t.Helper()
	o := migrationTestNode(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	var requests atomic.Int64
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requests.Add(1)
		http.Error(w, "unexpected local request", http.StatusServiceUnavailable)
	}))
	t.Cleanup(server.Close)
	t.Cleanup(func() { require.Zero(t, requests.Load(), "light mode must not call Core or download a binary") })
	for index := range o.Catalog.Networks {
		o.Catalog.Networks[index].Backends = []netcatalog.Backend{{Kind: netcatalog.KindEsplora, URL: server.URL + "/esplora"}}
	}
	o.adoptCatalogRows(o.Catalog, "alphanet")
	require.Equal(t, NodeModeLight, o.NodeMode())
	host, port, err := net.SplitHostPort(server.Listener.Addr().String())
	require.NoError(t, err)
	o.BitcoinConf.Config.SetSetting("rpcconnect", host, "main")
	o.BitcoinConf.Config.SetSetting("rpcport", port, "main")
	o.coreReachable = func() bool { return false }
	for name, raw := range o.rawConfigs {
		raw.DownloadURLs = map[string]string{"default": server.URL + "/"}
		raw.AltDownloadURLs = map[string]string{"default": server.URL + "/"}
		for id, variant := range raw.Variants {
			variant.BaseURL = server.URL + "/"
			raw.Variants[id] = variant
		}
		o.rawConfigs[name] = raw
		o.configs[name] = expandECashPlaceholder(raw, o.ecashID)
	}
	return o
}

func lightECashFiles(t *testing.T, o *Orchestrator) map[string][]byte {
	t.Helper()
	files := make(map[string][]byte)
	for _, name := range []string{"blocks/blk00000.dat", "blocks/rev00000.dat", "chainstate/CURRENT", "peers.dat"} {
		files[filepath.Join(o.BitcoinConf.DataDir(), filepath.FromSlash(name))] = []byte("alphanet " + name)
	}
	for _, dir := range config.AllDirConfigs() {
		if dir.BinaryName == "bip300301-enforcer" {
			files[filepath.Join(dir.RootDir(), "validator", config.EnforcerNetworkName(config.NetworkECash), "state")] = []byte("alphanet validator")
		}
	}
	for path, data := range files {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
		require.NoError(t, os.WriteFile(path, data, 0o600))
	}
	wallet := filepath.Join(o.BitcoinConf.DataDir(), "wallets", "cold", "wallet.dat")
	createMigrationFixtureWallet(t, wallet, []byte{0xec, 0xa5, 0xa1, 0x04})
	data, err := os.ReadFile(wallet)
	require.NoError(t, err)
	files[wallet] = data
	return files
}

func checkLightECashFiles(t *testing.T, files map[string][]byte) {
	t.Helper()
	for path, want := range files {
		data, err := os.ReadFile(path)
		require.NoError(t, err)
		require.Equal(t, want, data, path)
	}
}
