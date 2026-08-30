package config

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// The CUSF sidechains default to signet when launched without --network, so
// GetCliArgs has to emit the conf's value.
func TestSidechainCliArgsCarryNetwork(t *testing.T) {
	for _, name := range []string{"thunder", "bitassets", "bitnames", "zside", "photon", "truthcoin", "coinshift"} {
		m := &SidechainConfManager{
			Spec:   KnownSidechainSpecs[name],
			Config: ParseGenericAppConfig("network=regtest\n"),
		}
		require.Contains(t, m.GetCliArgs(), "--network=regtest", name)
		require.False(t, KnownSidechainSpecs[name].ConfOnly, name)
	}

	// Elements is the exception: Core-style -flags, and it exits on an
	// unknown --option, so none of its conf may reach the command line.
	require.True(t, KnownSidechainSpecs["liquid-signet"].ConfOnly)
}
