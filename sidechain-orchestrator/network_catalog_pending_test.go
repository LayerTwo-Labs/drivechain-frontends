package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func catalogWithECash(t *testing.T, id string) netcatalog.Catalog {
	t.Helper()
	c, _ := netcatalog.Load(t.TempDir())
	// One eCash entry only, with endpoints that match its id: the published
	// document is what the app reads them from.
	networks := make([]netcatalog.Network, 0, len(c.Networks))
	ecash := false
	for _, n := range c.Networks {
		if n.Family != netcatalog.FamilyECash {
			networks = append(networks, n)
			continue
		}
		if ecash {
			continue
		}
		ecash = true
		n.ID = id
		n.P2P.Address = id + ".example:8335"
		n.Backends = []netcatalog.Backend{{Kind: "esplora", URL: "https://esplora." + id + ".example"}}
		networks = append(networks, n)
	}
	c.Networks = networks
	return c
}

// ecashOnPendingNetwork puts a eCash install on drynet2 with a published
// document that leads with drynet3 and keeps the drynet2 row.
func ecashOnPendingNetwork(t *testing.T) *Orchestrator {
	t.Helper()
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)
	require.NotNil(t, o.EnforcerConf)

	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	// Don't let the unmanaged-Core guard find a real node on this machine.
	o.coreReachable = func() bool { return false }
	o.adoptCatalog(catalogWithECash(t, "drynet2"), "drynet2")
	require.Equal(t, "drynet2", o.installedECashNetwork())
	require.NoError(t, netcatalog.Save(o.BitwindowDir, catalogWithECashRows(t, "drynet3", "drynet2")))
	return o
}

// Switching generations destroys the old chain, so startup must leave it for
// the user to confirm rather than wiping behind their back.
func TestNewGenerationIsNotAppliedWithoutConsent(t *testing.T) {
	o := ecashOnPendingNetwork(t)

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet2", config.ECashNetworkID())
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID, "the upgrade prompt must still see it")
}

// The picker draws the adopted document, so a start that holds the published
// one back leaves the user no row to switch to.
func TestPublishedNetworkReachesThePicker(t *testing.T) {
	o := ecashOnPendingNetwork(t)

	o.ResolveNetworkCatalog(context.Background())

	var ids []string
	for _, n := range o.ListNetworks() {
		ids = append(ids, n.ID)
	}
	require.Contains(t, ids, "drynet3", "the published network must be listed")
	require.Contains(t, ids, "drynet2", "the network this install runs must stay listed")
	require.Equal(t, "drynet2", config.ECashNetworkID(), "the chain stays where it is")
}

// The published document drops a network once it retires, and its backends are
// the only ones that reach the blocks this install holds.
func TestRefreshKeepsTheRowThisInstallRuns(t *testing.T) {
	current := catalogWithECashRows(t, "drynet2", "drynet3")
	fetched := catalogWithECash(t, "drynet4")

	next := retainRunningECash(fetched, current, "drynet3")

	require.Equal(t, "drynet4", next.ECashID(), "the published network still leads")
	kept, ok := next.ByID("drynet3")
	require.True(t, ok, "the row this install runs must survive the refresh")
	require.Equal(t, "https://esplora.drynet3.example", kept.BackendURL("esplora"))
}

// A swap to another network strips the conf sentinel. Without the record, the
// next start reads the published document as the chain on disk.
func TestStartOffECashKeepsTheRecordedChain(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Empty(t, o.installedECashNetwork(), "the swap strips the eCash sentinel")

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet2", config.ECashNetworkID())
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID)
}

// Confirming is the one moment a live Core can rewind to the fork, so the
// switch happens here. A start has no Core and could only delete the chain.
func TestConfirmMovesTheChainOnTheSpot(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.Empty(t, o.PendingECashUpgrade().ID, "the prompt must clear once confirmed")
	require.Equal(t, "drynet3", config.ECashNetworkID(), "this process moves onto the confirmed network")
	require.Equal(t, "ecash-drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
}

// The enforcer's esplora host comes from the catalog, so a switch that updates
// only bitcoin.conf leaves it retrying a retired endpoint forever.
func TestConfirmedGenerationLandsOnTheNextStart(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())
	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet3", config.ECashNetworkID())
	require.Equal(t, "ecash-drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t, "drynet3.example:8335", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Contains(t, o.EnforcerConf.GetCliArgs(), "--wallet-esplora-url=https://esplora.drynet3.example")
	require.Empty(t, o.PendingECashUpgrade().ID)
}

// Confirming off eCash reaches no Core on that chain, so it records the drop
// rather than deleting blocks both networks keep.
func TestConfirmWorksFromAnotherNetwork(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	ecashDir := o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.ResolveNetworkCatalog(context.Background())
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID)

	blocks := filepath.Join(ecashDir, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o755))

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.DirExists(t, blocks, "the blocks below the fork must survive the confirm")
	require.Empty(t, o.PendingECashUpgrade().ID)
	require.Equal(t, string(config.NetworkMainnet), o.Network, "the active network must be left alone")
}

// The user's own bitcoin.conf names the generation, so only they can change it.
// Reporting success would clear the prompt and strand them on the retired chain.
func TestConfirmRefusedForAUserManagedConf(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())
	o.BitcoinConf.HasPrivateConf = true

	require.True(t, o.PendingECashUpgrade().UserManagedConf)
	require.Error(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID,
		"the prompt must persist so they know the chain is retired")
}

// Entering eCash must not silently switch generation: the retired chain is
// only deleted with the user's go-ahead, which the prompt collects.
func TestSwappingToECashKeepsTheGenerationPrompt(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.ResolveNetworkCatalog(context.Background())

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))

	require.Equal(t, "drynet2", config.ECashNetworkID())
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID)
}

// Core is per-chain and every variant shares one path, so a build left by the
// outgoing network must not survive into the incoming one.
func TestSwappingNetworksResolvesTheIncomingBuild(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	stale := writeResolvedCoreBinary(t, o, "drynet2 build")

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))

	fresh := resolvedCoreBinaryPath(t, o)
	require.NotEqual(t, stale, fresh, "mainnet must not resolve to the eCash build")
	require.NoFileExists(t, fresh, "mainnet must read as not-downloaded so boot fetches its own build")
	require.FileExists(t, stale, "the eCash build stays cached for the swap back")
}

// The eCash build is per generation even though the variant id doesn't change.
// The generation rides in the subfolder, so a rollover resolves to a new path.
func TestGenerationChangeResolvesANewCoreBinary(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.ResolveNetworkCatalog(context.Background())

	stale := writeResolvedCoreBinary(t, o, "drynet2 build")

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	fresh := resolvedCoreBinaryPath(t, o)
	require.NotEqual(t, stale, fresh, "the retired generation's build must not resolve")
	require.NoFileExists(t, fresh, "the new generation must read as not-downloaded")
}

// resolvedCoreBinaryPath is the bitcoind path the download and process managers
// agree on for the orchestrator's current network.
func resolvedCoreBinaryPath(t *testing.T, o *Orchestrator) string {
	t.Helper()
	v, ok := o.download.CoreVariant()
	require.True(t, ok, "no core variant resolves for network %s", o.Network)
	return CoreBinaryPath(o.DataDir, v, "bitcoind")
}

func writeResolvedCoreBinary(t *testing.T, o *Orchestrator, body string) string {
	t.Helper()
	path := resolvedCoreBinaryPath(t, o)
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte(body), 0o755))
	return path
}

// Generations publish their own seed port — drynet4 answers on 8533 — so a
// built name sends bitcoind somewhere nothing listens.
func TestRolloverWritesThePublishedPeerAndRetargetsTheEnforcer(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)
	require.NotNil(t, o.EnforcerConf)

	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	require.NoError(t, o.EnforcerConf.WriteConfig("network-preset=drynet2\nenable-block-template-server=true"))

	published := catalogWithECash(t, "drynet9")
	for i := range published.Networks {
		if published.Networks[i].Family == netcatalog.FamilyECash {
			published.Networks[i].P2P.Address = "drynet9.drivechain.dev:8533"
		}
	}
	require.NoError(t, netcatalog.Save(o.BitwindowDir, published))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet9", config.ECashNetworkID())
	require.Equal(t, "drynet9.drivechain.dev:8533", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Equal(t, "drynet9", o.EnforcerConf.Config.GetSetting("network-preset"))
	require.Equal(t, "true", o.EnforcerConf.Config.GetSetting("enable-block-template-server"))
}

// catalogWithECashRows lists several eCash networks in the order given, each
// with endpoints that match its id.
func catalogWithECashRows(t *testing.T, ids ...string) netcatalog.Catalog {
	t.Helper()
	c := catalogWithECash(t, ids[0])
	rows := make([]netcatalog.Network, 0, len(c.Networks)+len(ids))
	for _, n := range c.Networks {
		rows = append(rows, n)
		if n.Family != netcatalog.FamilyECash {
			continue
		}
		for _, id := range ids[1:] {
			extra := n
			extra.ID = id
			extra.P2P.Address = id + ".example:8335"
			extra.Backends = []netcatalog.Backend{{Kind: "esplora", URL: "https://esplora." + id + ".example"}}
			rows = append(rows, extra)
		}
	}
	c.Networks = rows
	return c
}

// A cache written in another order lists the retired rows first, and a retired
// row publishes no endpoints. Document order alone moves the install to that
// row, and the wallet then has no chain source at all.
func TestStartKeepsTheNetworkTheConfNames(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	o.adoptCatalog(catalogWithECash(t, "drynet4"), "drynet4")
	require.Equal(t, "drynet4", o.installedECashNetwork())

	retiredFirst := catalogWithECashRows(t, "drynet2", "drynet4")
	for i := range retiredFirst.Networks {
		if retiredFirst.Networks[i].ID == "drynet2" {
			retiredFirst.Networks[i].Backends = nil
		}
	}
	require.NoError(t, netcatalog.Save(o.BitwindowDir, retiredFirst))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet4", config.ECashNetworkID())
	require.Equal(t, "ecash-drynet4", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t,
		[]string{"https://esplora.drynet4.example"},
		config.WalletChainSourceURLsForNetwork(config.NetworkECash),
		"the wallet must keep reading the network whose blocks are on disk",
	)
}
