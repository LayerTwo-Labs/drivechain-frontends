package config

import (
	"slices"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A network that supports light mode still serves no sidechains without a
// hosted validator. The list is what the UI names in its place.
func TestRemoteEnforcerNetworksNamesOnlyThePublishedOnes(t *testing.T) {
	names := RemoteEnforcerNetworks()
	require.NotEmpty(t, names, "at least one network publishes a validator")

	for _, n := range AllNetworks() {
		hosted := RemoteEnforcerURLForNetwork(n) != ""
		listed := slices.Contains(names, NetworkDisplayName(n))
		assert.Equal(t, hosted, listed, "%s: the list and the URL must agree", n)
	}
}

func TestNetworkDisplayNameFallsBackToTheNetwork(t *testing.T) {
	assert.Equal(t, string(NetworkRegtest), NetworkDisplayName(NetworkRegtest))
}
