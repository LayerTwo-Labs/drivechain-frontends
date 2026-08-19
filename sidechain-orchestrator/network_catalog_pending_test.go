package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func catalogWithDrynet(t *testing.T, id string) netcatalog.Catalog {
	t.Helper()
	c, _ := netcatalog.Load(t.TempDir())
	// One generation only, with a peer that matches its id: the embedded
	// catalog lists several, and renaming them all leaves the last one's
	// address on every entry.
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
		n.P2P.Address = id + ".drivechain.dev:8335"
		networks = append(networks, n)
	}
	c.Networks = networks
	return c
}

// The cache must always describe the data on disk. A promotion that cannot
// wipe has to leave both the cache and the served generation alone, or the
// next start trusts a rollover that never happened.
func TestPendingNotPromotedWhenWipeCannotRun(t *testing.T) {
	dir := t.TempDir()
	current := catalogWithDrynet(t, "drynet2")
	pending := catalogWithDrynet(t, "drynet3")
	if err := netcatalog.SavePending(dir, pending); err != nil {
		t.Fatal(err)
	}

	// No BitcoinConf, so the wipe cannot run.
	o := &Orchestrator{BitwindowDir: dir, log: zerolog.Nop()}
	got := o.promotePendingCatalog(context.Background(), current, pending, true)

	if got.DrynetID() != "drynet2" {
		t.Errorf("served generation = %q, want the unchanged drynet2", got.DrynetID())
	}
	if _, ok := netcatalog.LoadPending(dir); !ok {
		t.Error("pending catalog must survive so the next start retries")
	}
	if cached, fromDisk := netcatalog.Load(dir); fromDisk && cached.DrynetID() == "drynet3" {
		t.Error("cache must not record a generation whose data was never wiped")
	}
}

// drynetOnPendingGeneration puts a drynet install on drynet2 with drynet3
// published but not applied.
func drynetOnPendingGeneration(t *testing.T) *Orchestrator {
	t.Helper()
	o := newTestOrchestrator(t)
	require.NotNil(t, o.BitcoinConf)
	require.NotNil(t, o.EnforcerConf)

	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDrynet, t.TempDir())
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkDrynet))
	// Don't let the unmanaged-Core guard find a real node on this machine.
	o.coreReachable = func() bool { return false }
	require.NoError(t, netcatalog.Save(o.BitwindowDir, catalogWithDrynet(t, "drynet2")))
	require.NoError(t, netcatalog.SavePending(o.BitwindowDir, catalogWithDrynet(t, "drynet3")))
	return o
}

// Switching generations destroys the old chain, so startup must leave it for
// the user to confirm rather than wiping behind their back.
func TestNewGenerationIsNotAppliedWithoutConsent(t *testing.T) {
	o := drynetOnPendingGeneration(t)

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet2", config.DrynetGeneration())
	require.Equal(t, "drynet3", o.PendingDrynetUpgrade().ID, "the upgrade prompt must still see it")
	_, stillPending := netcatalog.LoadPending(o.BitwindowDir)
	require.True(t, stillPending, "pending file must survive so the prompt persists")
}

// Confirming records the choice on disk and nothing else: wiping the chain
// under the running daemons is what the next start is for.
func TestConfirmPromotesTheCacheWithoutSwitchingLive(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	o.ResolveNetworkCatalog(context.Background())

	require.NoError(t, o.ConfirmPendingDrynetGeneration(context.Background()))

	cached, fromDisk := netcatalog.Load(o.BitwindowDir)
	require.True(t, fromDisk)
	require.Equal(t, "drynet3", cached.DrynetID())
	_, stillPending := netcatalog.LoadPending(o.BitwindowDir)
	require.False(t, stillPending, "the prompt must clear once confirmed")
	require.Equal(t, "drynet2", config.DrynetGeneration(), "this process keeps serving the retired generation")
	require.Equal(t, "drynet2", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
}

// The enforcer's esplora host carries the generation, so a switch that updates
// only bitcoin.conf leaves it retrying a retired endpoint forever.
func TestConfirmedGenerationLandsOnTheNextStart(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	o.ResolveNetworkCatalog(context.Background())
	require.NoError(t, o.ConfirmPendingDrynetGeneration(context.Background()))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet3", config.DrynetGeneration())
	require.Equal(t, "drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t, "drynet3.drivechain.dev:8335", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Contains(t, o.EnforcerConf.GetCliArgs(), "--wallet-esplora-url=https://esplora.drynet3.drivechain.dev")
	require.Empty(t, o.PendingDrynetUpgrade().ID)
}

// Confirming off drynet must clear the retired chain itself: the startup wipe
// only runs while drynet is active, and by then the conf names the new one.
func TestConfirmWorksFromAnotherNetwork(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	drynetDir := o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupDrynet)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.ResolveNetworkCatalog(context.Background())
	require.Equal(t, "drynet3", o.PendingDrynetUpgrade().ID)

	blocks := filepath.Join(drynetDir, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o755))

	require.NoError(t, o.ConfirmPendingDrynetGeneration(context.Background()))

	require.NoDirExists(t, blocks, "the retired generation's blocks must be cleared")
	require.Empty(t, o.PendingDrynetUpgrade().ID)
	require.Equal(t, string(config.NetworkMainnet), o.Network, "the active network must be left alone")
}

// The user's own bitcoin.conf names the generation, so only they can change it.
// Reporting success would clear the prompt and strand them on the retired chain.
func TestConfirmRefusedForAUserManagedConf(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	o.ResolveNetworkCatalog(context.Background())
	o.BitcoinConf.HasPrivateConf = true

	require.True(t, o.PendingDrynetUpgrade().UserManagedConf)
	require.Error(t, o.ConfirmPendingDrynetGeneration(context.Background()))

	_, stillPending := netcatalog.LoadPending(o.BitwindowDir)
	require.True(t, stillPending, "the prompt must persist so they know the chain is retired")
}

// Entering drynet must not silently switch generation: the retired chain is
// only deleted with the user's go-ahead, which the prompt collects.
func TestSwappingToDrynetKeepsTheGenerationPrompt(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.ResolveNetworkCatalog(context.Background())

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkDrynet))

	require.Equal(t, "drynet2", config.DrynetGeneration())
	require.Equal(t, "drynet3", o.PendingDrynetUpgrade().ID)
}

// An unchanged generation clears any stale pending file rather than leaving it
// to be re-applied forever.
func TestPromotionIsANoOpForTheSameGeneration(t *testing.T) {
	dir := t.TempDir()
	same := catalogWithDrynet(t, "drynet2")

	o := &Orchestrator{BitwindowDir: dir, log: zerolog.Nop()}
	got := o.promotePendingCatalog(context.Background(), same, same, true)
	if got.DrynetID() != "drynet2" {
		t.Errorf("generation = %q, want drynet2", got.DrynetID())
	}
}

// Core is per-chain and every variant shares one path, so a build left by the
// outgoing network must not survive into the incoming one.
func TestSwappingNetworksResolvesTheIncomingBuild(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	stale := writeResolvedCoreBinary(t, o, "drynet2 build")

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))

	fresh := resolvedCoreBinaryPath(t, o)
	require.NotEqual(t, stale, fresh, "mainnet must not resolve to the drynet build")
	require.NoFileExists(t, fresh, "mainnet must read as not-downloaded so boot fetches its own build")
	require.FileExists(t, stale, "the drynet build stays cached for the swap back")
}

// The drynet build is per generation even though the variant id doesn't change.
// The generation rides in the subfolder, so a rollover resolves to a new path.
func TestGenerationChangeResolvesANewCoreBinary(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	o.ResolveNetworkCatalog(context.Background())
	require.NoError(t, o.ConfirmPendingDrynetGeneration(context.Background()))

	stale := writeResolvedCoreBinary(t, o, "drynet2 build")

	o.ResolveNetworkCatalog(context.Background())

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

	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDrynet, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkDrynet))
	o.coreReachable = func() bool { return false }
	require.NoError(t, o.EnforcerConf.WriteConfig("network-preset=drynet2\nenable-wallet=true"))

	published := catalogWithDrynet(t, "drynet9")
	for i := range published.Networks {
		if published.Networks[i].Family == netcatalog.FamilyECash {
			published.Networks[i].P2P.Address = "drynet9.drivechain.dev:8533"
		}
	}
	require.NoError(t, netcatalog.Save(o.BitwindowDir, published))

	o.ResolveNetworkCatalog(context.Background())

	require.Equal(t, "drynet9", config.DrynetGeneration())
	require.Equal(t, "drynet9.drivechain.dev:8533", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Equal(t, "drynet9", o.EnforcerConf.Config.GetSetting("network-preset"))
	require.Equal(t, "true", o.EnforcerConf.Config.GetSetting("enable-wallet"))
}
