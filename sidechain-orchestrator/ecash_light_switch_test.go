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
			require.NoError(t, o.EnforcerConf.WriteConfig("fork=ecash-betanet"))
			require.NoError(t, o.Settings.SetECashChainID(""))
			require.Equal(t, "betanet", o.installedECashNetwork())

			if path == "pending" {
				require.Equal(t, "ecash", o.PendingECashUpgrade().ID)
				require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))
			} else {
				require.NoError(t, o.ApplyECashSwitch(context.Background(), "ecash"))
			}

			require.Equal(t, "ecash", o.ecashID)
			require.Equal(t, "ecash", o.Settings.ECashNetworkID())
			require.Equal(t, "ecash", o.installedECashNetwork())
			require.Equal(t, "ecash", o.EnforcerConf.Config.GetSetting("fork"))
			require.Equal(t, "new.example:8301", config.ECashEndpoints().P2P.Address)
			require.Equal(t, "betanet", o.Settings.ECashChainID())
			require.Equal(t, "ecash", o.Settings.PendingEnforcerWipe())
			require.NoError(t, o.ApplyECashSwitch(context.Background(), "ecash"))
			require.Equal(t, "betanet", o.Settings.ECashChainID())
			require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
			require.Equal(t, "betanet", o.Settings.ECashChainID())
			o.adoptCatalog(o.Catalog, "ecash")
			require.Equal(t, "betanet", o.Settings.ECashChainID())
			require.Equal(t, "ecash", o.ecashID)
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
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "ecash"))
	core := BinaryConfig{IsBitcoinCore: true, ChainLayer: 1}
	services := []BinaryConfig{{Name: "enforcer"}, {Name: "thunder", ChainLayer: 2}, {Name: "bitnames", IsBitcoinCore: true, ChainLayer: 2}}
	want := "ECX files belong to betanet; open Settings, Network, ECX migration to move them to ecash"
	require.EqualError(t, o.checkECashMigrationStart(context.Background(), core), want)
	for _, cfg := range services {
		require.NoError(t, o.checkECashMigrationStart(context.Background(), cfg))
	}
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.NoError(t, o.AdoptECashID("ecash"))
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	for _, cfg := range append(services, core) {
		require.EqualError(t, o.checkECashMigrationStart(context.Background(), cfg), want)
	}
	checkLightECashFiles(t, files)
}

func TestECashLightSwitchKeepsIncompleteJob(t *testing.T) {
	o := lightECashTestNode(t)
	files := lightECashFiles(t, o)
	state, err := o.newMigration(context.Background(), "betanet", "ecash")
	require.NoError(t, err)
	state.Status.JobID = "saved-job"
	state.Step = 2
	require.NoError(t, o.saveMigration(state))
	want := "resume ECX migration saved-job before a node start"
	require.EqualError(t, o.ApplyECashSwitch(context.Background(), "ecash"), want)
	for _, cfg := range []BinaryConfig{{Name: "enforcer"}, {ChainLayer: 2}, {IsBitcoinCore: true, ChainLayer: 1}} {
		require.EqualError(t, o.checkECashMigrationStart(context.Background(), cfg), want)
	}
	require.Equal(t, "betanet", o.ecashID)
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	require.Equal(t, "betanet", o.installedECashNetwork())
	checkLightECashFiles(t, files)
}

func TestECashLightSwitchRecordsEmptyDirectory(t *testing.T) {
	o := lightECashTestNode(t)
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "ecash"))
	require.Equal(t, "ecash", o.ecashID)
	require.Equal(t, "ecash", o.Settings.ECashChainID())
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "ecash"))
	require.NoFileExists(t, o.migrationPath())
}

func TestAdoptECashIDKeepsLightDiskSource(t *testing.T) {
	o := lightECashTestNode(t)
	files := lightECashFiles(t, o)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkRegtest))
	require.Equal(t, NodeModeFull, o.NodeMode())
	require.NoError(t, o.AdoptECashID("ecash"))
	require.Equal(t, "ecash", o.ecashID)
	require.Equal(t, "betanet", o.Settings.ECashChainID())
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
	o := migrationTestNodeFor(t, "betanet", "ecash")
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
	o.adoptCatalogRows(o.Catalog, "betanet")
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
		files[filepath.Join(o.BitcoinConf.DataDir(), filepath.FromSlash(name))] = []byte("betanet " + name)
	}
	for _, dir := range config.AllDirConfigs() {
		if dir.BinaryName == "bip300301-enforcer" {
			files[filepath.Join(dir.RootDir(), "validator", config.LegacyEnforcerNetworkName(config.NetworkECash), "state")] = []byte("betanet validator")
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

// Full mode runs Core on the blocks, so a move there refuses files that belong to
// another network. The start refuses them as well, from a restart goroutine, where
// the user reads nothing.
func TestSetNodeModeRefusesForeignBlocks(t *testing.T) {
	o := lightECashTestNode(t)
	lightECashFiles(t, o)
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "ecash"))
	require.Equal(t, "betanet", o.Settings.ECashChainID())

	want := "ECX files belong to betanet; open Settings, Network, ECX migration to move them to ecash"
	require.EqualError(t, o.SetNodeMode(context.Background(), NodeModeFull), want)
	require.Equal(t, NodeModeLight, o.NodeMode(), "the mode stays until the files move")

	// The files belong to ecash, so the move passes.
	require.NoError(t, o.Settings.SetECashChainID("ecash"))
	require.NoError(t, o.SetNodeMode(context.Background(), NodeModeFull))
	require.Equal(t, NodeModeFull, o.NodeMode())
}
