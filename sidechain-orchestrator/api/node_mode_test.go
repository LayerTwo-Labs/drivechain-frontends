package api

import (
	"context"
	"io"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func TestBitcoinLightModeWithOrWithoutRemoteEnforcer(t *testing.T) {
	for network, remoteEnforcer := range map[config.Network]bool{config.NetworkMainnet: false, config.NetworkSignet: true} {
		t.Run(string(network), func(t *testing.T) {
			orch := orchestrator.New(t.TempDir(), string(network), t.TempDir(), nil, zerolog.New(io.Discard))
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeLight))
			handler := &WalletHandler{orch: orch}

			response, err := handler.GetNodeMode(context.Background(), &pb.GetNodeModeRequest{})

			require.NoError(t, err)
			require.Equal(t, pb.NodeMode_NODE_MODE_LIGHT, response.Mode)
			require.True(t, response.LightModeAvailable)
			require.Equal(t, remoteEnforcer, response.RemoteEnforcerAvailable)
		})
	}
}

func TestNodeModeUsesThePublishedRemoteEnforcer(t *testing.T) {
	network := config.NetworkMainnet
	original := config.PublishedEndpoints(network)
	t.Cleanup(func() { config.SetNetworkEndpoints(network, original) })
	orch := orchestrator.New(t.TempDir(), string(network), t.TempDir(), nil, zerolog.New(io.Discard))
	handler := &WalletHandler{orch: orch}

	for _, endpoint := range []string{"https://validator.example/enforcer", ""} {
		entry := original
		entry.Services.Enforcer = netcatalog.Endpoints{{URL: endpoint}}
		config.SetNetworkEndpoints(network, entry)

		response, err := handler.GetNodeMode(context.Background(), &pb.GetNodeModeRequest{})

		require.NoError(t, err)
		require.Equal(t, endpoint != "", response.RemoteEnforcerAvailable)
	}
}

// The list reads the live catalog, so it names every eCash network that hosts
// an enforcer, and none that the catalog does not run or gives no enforcer.
func TestNodeModeListsTheLiveCatalogEnforcers(t *testing.T) {
	network := func(id, family, name, enforcer string, migrationOnly bool) netcatalog.Network {
		n := netcatalog.Network{ID: id, Family: family, DisplayName: name, MigrationOnly: migrationOnly}
		if enforcer != "" {
			n.Services.Enforcer = netcatalog.Endpoints{{URL: enforcer}}
		}
		return n
	}
	catalog := netcatalog.Catalog{Networks: []netcatalog.Network{
		network("bitcoin", "bitcoin", "Bitcoin", "", false),
		network("signet", "bitcoin", "Test Signet", "https://enforcer.signet.example", false),
		network("devnet", "bitcoin", "Devnet", "https://enforcer.dev.example", false),
		network("alphanet", netcatalog.FamilyECash, "Alphanet", "https://enforcer.alpha.example", true),
		network("betanet", netcatalog.FamilyECash, "Betanet", "", false),
		network("gammanet", netcatalog.FamilyECash, "Gammanet", "https://enforcer.gamma.example", false),
		network("ecash", netcatalog.FamilyECash, "eCash", "https://enforcer.ecash.example", false),
	}}
	orch := &orchestrator.Orchestrator{
		Network: string(config.NetworkECash), BitwindowDir: t.TempDir(), Catalog: catalog,
	}
	handler := &WalletHandler{orch: orch}

	response, err := handler.GetNodeMode(context.Background(), &pb.GetNodeModeRequest{})

	require.NoError(t, err)
	require.Equal(t, []string{"Test Signet", "Gammanet", "eCash"}, response.RemoteEnforcerNetworks)
}
