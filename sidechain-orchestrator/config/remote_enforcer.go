package config

import (
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/samber/lo"
)

// RemoteEnforcerURLForNetwork returns the published validator URL, or an empty string.
func RemoteEnforcerURLForNetwork(network Network) string {
	entry := PublishedEndpoints(network)
	if entry.Services.Enforcer.URL != "" {
		return entry.Services.Enforcer.URL
	}
	embedded, ok := netcatalog.Embedded().ForNetwork(string(network))
	if !ok || (entry.ID != "" && entry.ID != embedded.ID) {
		return ""
	}
	return embedded.Services.Enforcer.URL
}

// RemoteEnforcerNetworks names every network that publishes a validator URL, by
// the name the user reads. Light mode serves sidechains on these networks only.
func RemoteEnforcerNetworks() []string {
	withEnforcer := lo.Filter(AllNetworks(), func(n Network, _ int) bool {
		return RemoteEnforcerURLForNetwork(n) != ""
	})
	return lo.Map(withEnforcer, func(n Network, _ int) string { return NetworkDisplayName(n) })
}

// NetworkDisplayName is the name the user reads for a network. The catalog
// names the live eCash network, and the rest carry the name of the network.
func NetworkDisplayName(n Network) string {
	if name := PublishedDisplayName(n); name != "" {
		return name
	}
	return string(n)
}
