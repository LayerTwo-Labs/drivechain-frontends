package orchestrator

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

// The picker is the catalog, so a network reaches the user through an endpoint
// change rather than a release. Regtest rides along because nothing publishes
// it and the app still runs it.
func TestListNetworksComesFromTheCatalog(t *testing.T) {
	o := newTestOrchestrator(t)
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin", DisplayName: "Bitcoin"},
		{ID: "signet", Family: "bitcoin", DisplayName: "L2L Signet"},
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet"},
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
	}}, "alphanet")

	var ids, names []string
	for _, opt := range o.ListNetworks() {
		ids = append(ids, opt.ID)
		names = append(names, opt.DisplayName)
	}
	require.Equal(t, []string{"bitcoin", "signet", "alphanet", "drynet4", "regtest"}, ids)
	require.Equal(t, "Alphanet", names[2])
}

// Every eCash entry shares one slot, so only the id that boots may read as
// current. Marking both would let the picker show two selected rows.
func TestListNetworksMarksOnlyTheRunningECashEntry(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet"},
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
	}}, "alphanet")

	current := map[string]bool{}
	for _, opt := range o.ListNetworks() {
		current[opt.ID] = opt.IsCurrent
	}
	require.True(t, current["alphanet"])
	require.False(t, current["drynet4"])
}

// The picker sends a catalog id, so the id must survive to the next start —
// otherwise the boot resolves the catalog's first entry and ignores the pick.
func TestSelectECashNetworkPinsTheID(t *testing.T) {
	o := newTestOrchestrator(t)
	cat := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}
	o.adoptCatalog(cat, "alphanet")
	require.Equal(t, "alphanet", o.SelectedECashID(cat))

	require.NoError(t, o.SelectECashNetwork("drynet4"))
	require.Equal(t, "drynet4", o.SelectedECashID(cat))

	// A bare slot name is not an id, so it must leave the pick alone.
	require.NoError(t, o.SelectECashNetwork("ecash"))
	require.Equal(t, "drynet4", o.SelectedECashID(cat))
}

// A pinned network the catalog drops is gone, so the boot has to fall back
// rather than ask for a fork nothing publishes.
func TestSelectedECashIDFallsBackWhenTheCatalogDropsIt(t *testing.T) {
	o := newTestOrchestrator(t)
	cat := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}
	o.adoptCatalog(cat, "alphanet")
	require.NoError(t, o.SelectECashNetwork("drynet4"))

	trimmed := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
	}}
	require.Equal(t, "alphanet", o.SelectedECashID(trimmed))
}

// The refresh reports what appeared, so the app can name the network in the
// notice instead of saying something changed.
func TestNewIDsReportsWhatTheRefreshAdded(t *testing.T) {
	before := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin"},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}
	after := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin"},
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}
	require.Equal(t, []string{"alphanet"}, after.NewIDs(before))
	require.Empty(t, after.NewIDs(after))
}

// A fresh install must tell the user nothing: it boots on the newest catalog,
// so a notice per network is noise about networks it already runs.
func TestTakeNewNetworksStaysQuietOnAFreshInstall(t *testing.T) {
	o := newTestOrchestrator(t)
	booted := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin", DisplayName: "Bitcoin"},
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet"},
	}}
	o.seedToldNetworks(booted)
	o.adoptCatalog(booted, "alphanet")

	require.Empty(t, o.TakeNewNetworks())
}

// An install that upgrades from an older build booted on a catalog that lists
// no alphanet. Every network published since is news to that user, and staying
// quiet would strand them on a retired fork.
func TestTakeNewNetworksTellsAnUpgradedInstall(t *testing.T) {
	o := newTestOrchestrator(t)
	o.seedToldNetworks(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin", DisplayName: "Bitcoin"},
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
	}})
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "bitcoin", Family: "bitcoin", DisplayName: "Bitcoin"},
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet"},
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
	}}, "drynet4")

	fresh := o.TakeNewNetworks()
	require.Len(t, fresh, 1)
	require.Equal(t, "alphanet", fresh[0].ID)
	require.Equal(t, "Alphanet", fresh[0].DisplayName)

	require.Empty(t, o.TakeNewNetworks(), "the notice must not repeat on the next poll")
}

// The seed runs once. A later boot must not widen the baseline, or a network
// published between two starts slips by with no notice.
func TestSeedToldNetworksRunsOnce(t *testing.T) {
	o := newTestOrchestrator(t)
	o.seedToldNetworks(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
	}})
	o.seedToldNetworks(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet"},
	}})
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, DisplayName: "Alphanet"},
		{ID: "drynet4", Family: netcatalog.FamilyECash, DisplayName: "Drynet 4"},
	}}, "drynet4")

	fresh := o.TakeNewNetworks()
	require.Len(t, fresh, 1)
	require.Equal(t, "alphanet", fresh[0].ID)
}

// The store caches the whole settings object and every setter writes that cache
// back. A pick saved around it would be undone by the next unrelated setting.
func TestECashPickSurvivesAnotherSettingChange(t *testing.T) {
	o := newTestOrchestrator(t)
	o.adoptCatalog(netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash},
		{ID: "drynet4", Family: netcatalog.FamilyECash},
	}}, "alphanet")
	require.NoError(t, o.SelectECashNetwork("drynet4"))

	_, err := o.Settings.SetElectrumServerURL("https://esplora.example")
	require.NoError(t, err)

	reloaded, err := LoadSettings(o.BitwindowDir)
	require.NoError(t, err)
	require.Equal(t, "drynet4", reloaded.ECashNetworkID, "the pick must survive an unrelated save")
	require.Equal(t, "https://esplora.example", reloaded.ElectrumServerURL)
}
