package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func writeConf(t *testing.T, dir, name, content string) {
	t.Helper()
	require.NoError(t, os.WriteFile(filepath.Join(dir, name), []byte(content), 0o600))
}

// The orchestrator is the source of truth, but a reader has to be able to align
// with it while it is down.
func TestResolveNetworkReadsTheConf(t *testing.T) {
	dir := t.TempDir()
	writeConf(t, dir, "bitwindow-bitcoin.conf", "signet=1\n[signet]\nrpcuser=user\n")

	network, err := ResolveNetwork(dir)
	require.NoError(t, err)
	assert.Equal(t, NetworkSignet, network)
}

func TestResolveNetworkReadsEachNetwork(t *testing.T) {
	for _, tt := range []struct {
		conf string
		want Network
	}{
		{"regtest=1\n", NetworkRegtest},
		{"signet=1\n", NetworkSignet},
		{"testnet=1\n", NetworkTestnet},
		{"chain=main\n", NetworkMainnet},
		// Same default the orchestrator derives, so the two cannot disagree.
		{"", NetworkSignet},
	} {
		dir := t.TempDir()
		writeConf(t, dir, "bitwindow-bitcoin.conf", tt.conf)

		network, err := ResolveNetwork(dir)
		require.NoErrorf(t, err, "conf %q", tt.conf)
		assert.Equalf(t, tt.want, network, "conf %q", tt.conf)
	}
}

// Without a conf there is nothing to align to, and guessing a network would
// open the wrong datadir.
func TestResolveNetworkFailsWithoutAConf(t *testing.T) {
	_, err := ResolveNetwork(t.TempDir())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "bitwindow-bitcoin.conf")
}

// ResolveNetwork must never create or rewrite the file it reads.
func TestResolveNetworkDoesNotWrite(t *testing.T) {
	dir := t.TempDir()
	writeConf(t, dir, "bitwindow-bitcoin.conf", "signet=1\n")

	before, err := os.ReadFile(filepath.Join(dir, "bitwindow-bitcoin.conf"))
	require.NoError(t, err)
	entriesBefore, err := os.ReadDir(dir)
	require.NoError(t, err)

	_, err = ResolveNetwork(dir)
	require.NoError(t, err)

	after, err := os.ReadFile(filepath.Join(dir, "bitwindow-bitcoin.conf"))
	require.NoError(t, err)
	entriesAfter, err := os.ReadDir(dir)
	require.NoError(t, err)

	assert.Equal(t, string(before), string(after), "conf was rewritten")
	assert.Len(t, entriesAfter, len(entriesBefore), "a file was created")
}

// drynet and forknet are both chain=main to Core; only the uacomment sentinel
// tells them apart. Same NetworkFromConfig the orchestrator uses.
func TestResolveNetworkReadsTheDrynetSentinel(t *testing.T) {
	for _, tt := range []struct {
		name string
		conf string
		want Network
	}{
		{
			name: "drynet",
			conf: "chain=main\n[main]\ndrivechain=1\nuacomment=drynet3\n",
			want: NetworkDrynet,
		},
		{
			name: "later generation still drynet",
			conf: "chain=main\n[main]\ndrivechain=1\nuacomment=drynet4\n",
			want: NetworkDrynet,
		},
		{
			name: "drivechain without the sentinel is forknet",
			conf: "chain=main\n[main]\ndrivechain=1\nuacomment=BitWindow-0.2\n",
			want: NetworkForknet,
		},
		{
			name: "no drivechain is plain mainnet",
			conf: "chain=main\n[main]\nuacomment=BitWindow-0.2\n",
			want: NetworkMainnet,
		},
	} {
		t.Run(tt.name, func(t *testing.T) {
			dir := t.TempDir()
			writeConf(t, dir, "bitwindow-bitcoin.conf", tt.conf)

			network, err := ResolveNetwork(dir)
			require.NoError(t, err)
			assert.Equal(t, tt.want, network)
		})
	}
}
