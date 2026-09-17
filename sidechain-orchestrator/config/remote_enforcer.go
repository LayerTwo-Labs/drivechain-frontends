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
	embedded, ok := embeddedEntryFor(entry.ID, network)
	if !ok {
		return ""
	}
	return embedded.Services.Enforcer.URL
}

// embeddedEntryFor finds the compiled-in entry that stands for a network. An id
// from the published document matches by id, so each eCash network reads its
// own row; the family lookup serves only a caller that has no id yet, because
// it takes whichever eCash row comes first.
func embeddedEntryFor(id string, network Network) (netcatalog.Network, bool) {
	if id != "" {
		return netcatalog.Embedded().ByID(id)
	}
	return netcatalog.Embedded().ForNetwork(string(network))
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
