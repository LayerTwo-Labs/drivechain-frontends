package config

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSidechainEnforcerArgsUseTheDaemonFlags(t *testing.T) {
	for _, name := range []string{"thunder", "photon", "coinshift", "zside"} {
		args, err := KnownSidechainSpecs[name].EnforcerArgs("http://127.0.0.1:32123")
		require.NoError(t, err)
		require.Equal(t, []string{"--mainchain-grpc-url=http://127.0.0.1:32123"}, args)
	}
	for _, name := range []string{"bitnames", "bitassets", "truthcoin"} {
		args, err := KnownSidechainSpecs[name].EnforcerArgs("http://127.0.0.1:32123")
		require.NoError(t, err)
		require.Equal(t, []string{"--mainchain-grpc-host=127.0.0.1", "--mainchain-grpc-port=32123"}, args)
	}
}

func TestSidechainEnforcerHostAcceptsIPv6(t *testing.T) {
	args, err := KnownSidechainSpecs["bitnames"].EnforcerArgs("http://[::1]:32123")
	require.NoError(t, err)
	require.Equal(t, []string{"--mainchain-grpc-host=[::1]", "--mainchain-grpc-port=32123"}, args)
}

func TestSidechainEnforcerHostRejectsURLsItCannotRepresent(t *testing.T) {
	for _, endpoint := range []string{"https://example.com:443", "http://example.com", "http://example.com:50051/enforcer"} {
		_, err := KnownSidechainSpecs["bitnames"].EnforcerArgs(endpoint)
		require.Error(t, err)
	}
	_, err := KnownSidechainSpecs["liquid-signet"].EnforcerArgs("http://127.0.0.1:50051")
	require.ErrorContains(t, err, "does not support a remote enforcer")
}
