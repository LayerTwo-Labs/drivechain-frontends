package config

import (
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// Every network the daemon accepts must have params, testnet included: BIP47
// support is a narrower question, and a network without BIP47 sends still runs.
func TestChainParamsForEveryNetwork(t *testing.T) {
	for _, n := range []Network{
		NetworkMainnet, NetworkForknet, NetworkECash,
		NetworkTestnet, NetworkSignet, NetworkRegtest,
	} {
		require.NotNil(t, ChainParamsFor(n), "network %q", n)
	}
	require.Equal(t, &chaincfg.MainNetParams, ChainParamsFor(NetworkECash))
	require.Equal(t, &chaincfg.TestNet3Params, ChainParamsFor(NetworkTestnet))
	require.Panics(t, func() { ChainParamsFor(Network("nosuchnet")) })
}
