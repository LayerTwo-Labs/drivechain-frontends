package orchestrator

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func catalogWithECash(t *testing.T, id string) netcatalog.Catalog {
	t.Helper()
	c := netcatalog.Embedded()
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

// publish serves a document to this orchestrator, as drivechain.dev does.
func publish(t *testing.T, o *Orchestrator, c netcatalog.Catalog) {
	t.Helper()
	body, err := json.Marshal(c)
	require.NoError(t, err)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write(body)
	}))
	t.Cleanup(srv.Close)
	o.catalogURL = srv.URL
}

// awaitRefresh waits for the detached fetch to take the published document.
func awaitRefresh(t *testing.T, o *Orchestrator, id string) {
	t.Helper()
	require.Eventually(t, func() bool {
		o.mu.RLock()
		defer o.mu.RUnlock()
		return o.Catalog.ECashID() == id
	}, 5*time.Second, 10*time.Millisecond, "the published document must reach the process")
}

// ecashOnPendingNetwork puts a eCash install on drynet2, with a published
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
	// What a refresh takes: the live network first, the row this install runs
	// kept, and the chain left where it is.
	o.adoptCatalogRows(catalogWithECashRows(t, "drynet3", "drynet2"), "drynet2")
	return o
}

// The bug the picker had: a start held the published document back, so the
// network the user was told about was never a row they could pick.
func TestARefreshReachesThePickerWithoutMovingTheChain(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	o.adoptCatalog(catalogWithECash(t, "drynet2"), "drynet2")
	publish(t, o, catalogWithECashRows(t, "drynet3", "drynet2"))

	o.ResolveNetworkCatalog(context.Background())
	awaitRefresh(t, o, "drynet3")

	var ids []string
	for _, n := range o.ListNetworks() {
		ids = append(ids, n.ID)
	}
	require.Contains(t, ids, "drynet3", "the published network must be listed")
	require.Contains(t, ids, "drynet2", "the network this install runs must stay listed")
	require.Equal(t, "drynet2", config.ECashNetworkID(), "the chain stays where it is")
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID, "and the move is offered")
}

// Switching generations rewinds the chain, so startup must leave it for the
// user to confirm rather than moving them behind their back.
func TestNewGenerationIsNotAppliedWithoutConsent(t *testing.T) {
	o := ecashOnPendingNetwork(t)

	require.Equal(t, "drynet2", config.ECashNetworkID())
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID, "the upgrade prompt must still see it")
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

// A swap to another network strips the conf sentinel. Without the record, a
// start reads the published document as the chain on disk.
func TestStartOffECashKeepsTheRecordedChain(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Empty(t, o.installedECashNetwork(), "the swap strips the eCash sentinel")

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet2", config.ECashNetworkID())
}

// The document is fetched, so the endpoint can be slow or down. A start takes
// the compiled-in document at once and never waits for the answer.
func TestAStartNeverWaitsOnTheEndpoint(t *testing.T) {
	o := newTestOrchestrator(t)
	held := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(_ http.ResponseWriter, _ *http.Request) {
		<-held
	}))
	t.Cleanup(func() {
		close(held)
		srv.Close()
	})
	o.catalogURL = srv.URL

	done := make(chan struct{})
	go func() {
		o.ResolveNetworkCatalog(context.Background())
		close(done)
	}()

	select {
	case <-done:
	case <-time.After(2 * time.Second):
		t.Fatal("a start must not wait on the catalog endpoint")
	}
	require.Equal(t, netcatalog.EmbeddedECashID(), config.ECashNetworkID(),
		"the compiled-in document carries the start")
}

// Confirming is the one moment a live Core can rewind to the fork, so the
// switch happens here. A start has no Core and could only leave the two apart.
func TestConfirmMovesTheChainOnTheSpot(t *testing.T) {
	o := ecashOnPendingNetwork(t)

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.Empty(t, o.PendingECashUpgrade().ID, "the prompt must clear once confirmed")
	require.Equal(t, "drynet3", config.ECashNetworkID(), "this process moves onto the confirmed network")
	require.Equal(t, "ecash-drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
}

// The enforcer's esplora host comes from the catalog, so a switch that updates
// only bitcoin.conf leaves it retrying a retired endpoint forever.
func TestConfirmedGenerationLandsOnTheNextStart(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))
	publish(t, o, catalogWithECashRows(t, "drynet3", "drynet2"))

	o.ResolveNetworkCatalog(context.Background())
	awaitRefresh(t, o, "drynet3")

	require.Equal(t, "drynet3", config.ECashNetworkID())
	require.Equal(t, "ecash-drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t, "drynet3.example:8335", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Contains(t, o.EnforcerConf.GetCliArgs(), "--wallet-esplora-url=https://esplora.drynet3.example")
	require.Empty(t, o.PendingECashUpgrade().ID)
}

// Confirming off eCash reaches no Core on that chain, so it records the move
// rather than touching blocks both networks keep.
func TestConfirmWorksFromAnotherNetwork(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	ecashDir := o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID)

	blocks := filepath.Join(ecashDir, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o755))

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.DirExists(t, blocks, "the blocks below the fork must survive the confirm")
	require.Empty(t, o.PendingECashUpgrade().ID)
	require.Equal(t, string(config.NetworkMainnet), o.Network, "the active network must be left alone")
}

// The blocks the retired fork added survive that confirm, and with no record
// they outrank the confirmed network's: the start that follows serves the chain
// the user just left.
func TestConfirmFromAnotherNetworkJournalsTheOwedRewind(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	height, forID, fromID := o.Settings.PendingRewind()
	require.Equal(t, "drynet3", forID, "the drop is owed on the confirmed network")
	require.Equal(t, "drynet2", fromID, "the blocks above it are drynet2's")
	require.NotZero(t, height, "the last block the two networks share")
}

// A pick that reached the settings file and nothing else is adopted by the next
// start. That start is the last moment anything still knows which network wrote
// the blocks, because it moves the record onto the pick.
func TestStartJournalsTheRewindAPinnedPickOwes(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	_, err := o.Settings.SetECashNetworkID("drynet3")
	require.NoError(t, err)
	require.Equal(t, "drynet2", o.Settings.ECashChainID())

	cat := catalogWithECashRows(t, "drynet3", "drynet2")
	require.Equal(t, "drynet3", o.RunningECashID(cat), "the start adopts the pinned pick")
	o.adoptCatalog(cat, "drynet3")

	height, forID, fromID := o.Settings.PendingRewind()
	require.Equal(t, "drynet3", forID)
	require.Equal(t, "drynet2", fromID)
	require.NotZero(t, height)
	require.Equal(t, "drynet3", o.Settings.ECashChainID(), "the record moves onto the pick")
}

// The user's own bitcoin.conf names the generation, so only they can change it.
// Reporting success would clear the prompt and strand them on the retired chain.
func TestConfirmRefusedForAUserManagedConf(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	o.BitcoinConf.HasPrivateConf = true

	require.True(t, o.PendingECashUpgrade().UserManagedConf)
	require.Error(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.Equal(t, "drynet3", o.PendingECashUpgrade().ID,
		"the prompt must persist so they know the chain is retired")
}

// Entering eCash must not silently switch generation: the chain moves only with
// the user's go-ahead, which the prompt collects.
func TestSwappingToECashKeepsTheGenerationPrompt(t *testing.T) {
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))

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
	o := ecashOnPendingNetwork(t)
	require.NoError(t, o.EnforcerConf.WriteConfig("network-preset=drynet2\nenable-block-template-server=true"))
	published := catalogWithECashRows(t, "drynet9", "drynet2")
	for i := range published.Networks {
		if published.Networks[i].ID == "drynet9" {
			published.Networks[i].P2P.Address = "drynet9.drivechain.dev:8533"
		}
	}
	o.adoptCatalogRows(published, "drynet2")

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.Equal(t, "drynet9", config.ECashNetworkID())
	require.Equal(t, "drynet9.drivechain.dev:8533", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Equal(t, "drynet9", o.EnforcerConf.Config.GetSetting("network-preset"))
	require.Equal(t, "true", o.EnforcerConf.Config.GetSetting("enable-block-template-server"))
}

// A document that lists a retired row first must not move the install onto it.
// A retired row publishes no endpoints, and the wallet then has no chain source.
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
	publish(t, o, retiredFirst)

	o.ResolveNetworkCatalog(context.Background())
	awaitRefresh(t, o, "drynet2")

	require.Equal(t, "drynet4", config.ECashNetworkID())
	require.Equal(t, "ecash-drynet4", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t,
		[]string{"https://esplora.drynet4.example"},
		config.WalletChainSourceURLsForNetwork(config.NetworkECash),
		"the wallet must keep reading the network whose blocks are on disk",
	)
}
