package orchestrator

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func catalogWithDrynet(t *testing.T, id string) netcatalog.Catalog {
	t.Helper()
	c, _ := netcatalog.Load(t.TempDir())
	for i := range c.Networks {
		if c.Networks[i].Family == netcatalog.FamilyECash {
			c.Networks[i].ID = id
		}
	}
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
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkDrynet))
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

// The enforcer's esplora host carries the generation, so a switch that updates
// only bitcoin.conf leaves it retrying a retired endpoint forever.
func TestAppliedGenerationReachesEnforcerArgs(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	o.ResolveNetworkCatalog(context.Background())

	require.NoError(t, o.switchDrynetGeneration(context.Background()))

	require.Equal(t, "drynet3", config.DrynetGeneration())
	require.Equal(t, "drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Contains(t, o.EnforcerConf.GetCliArgs(), "--wallet-esplora-url=https://esplora.drynet3.drivechain.dev")
	require.Empty(t, o.PendingDrynetUpgrade().ID, "the prompt must clear once applied")
}

// A mainnet user's retired drynet data is untouched files on disk, so the
// switch must not need their L1 stack stopped — and must not boot drynet's.
func TestGenerationSwitchWorksFromAnotherNetwork(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.ResolveNetworkCatalog(context.Background())
	require.Equal(t, "drynet3", o.PendingDrynetUpgrade().ID)

	require.NoError(t, o.ApplyPendingDrynetGeneration(context.Background()))

	require.Equal(t, "drynet3", config.DrynetGeneration())
	require.Empty(t, o.PendingDrynetUpgrade().ID)
	require.Equal(t, string(config.NetworkMainnet), o.Network, "the active network must be left alone")
}

// Entering drynet with an upgrade pending must land on the current generation.
// Syncing the retired one only to throw it away is never what the user wants.
func TestSwappingToDrynetTakesThePendingUpgrade(t *testing.T) {
	o := drynetOnPendingGeneration(t)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	o.ResolveNetworkCatalog(context.Background())
	require.Equal(t, "drynet2", config.DrynetGeneration())

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkDrynet))

	require.Equal(t, "drynet3", config.DrynetGeneration())
	require.Equal(t, "drynet3", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t, "drynet3.drivechain.dev:8335", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Empty(t, o.PendingDrynetUpgrade().ID)
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
