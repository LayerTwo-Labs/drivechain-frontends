package config

import "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"

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
