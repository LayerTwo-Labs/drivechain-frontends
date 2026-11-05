package config

import (
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// RemoteEnforcerURLForNetwork returns the published validator URL, or an empty string.
func RemoteEnforcerURLForNetwork(network Network) string {
	entry := PublishedEndpoints(network)
	if url := entry.Services.Enforcer.URL(); url != "" {
		return url
	}
	embedded, ok := embeddedEntryFor(entry.ID, network)
	if !ok {
		return ""
	}
	return embedded.Services.Enforcer.URL()
}

// embeddedEntryFor finds the compiled-in entry that stands for a network. An id
// from the published document matches by id, so each eCash network reads its
// own row; the family lookup serves only a caller that has no id yet, because
// it takes the live eCash row, which comes last.
func embeddedEntryFor(id string, network Network) (netcatalog.Network, bool) {
	if id != "" {
		return netcatalog.Embedded().ByID(id)
	}
	return netcatalog.Embedded().ForNetwork(string(network))
}

// NetworkDisplayName is the name the user reads for a network. The catalog
// names the live eCash network, and the rest carry the name of the network.
func NetworkDisplayName(n Network) string {
	if name := PublishedDisplayName(n); name != "" {
		return name
	}
	return string(n)
}
