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

	network, ecashID, err := ResolveNetwork(dir)
	require.NoError(t, err)
	assert.Equal(t, NetworkSignet, network)
	assert.Empty(t, ecashID)
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

		network, _, err := ResolveNetwork(dir)
		require.NoErrorf(t, err, "conf %q", tt.conf)
		assert.Equalf(t, tt.want, network, "conf %q", tt.conf)
	}
}

// Without a conf there is nothing to align to, and guessing a network would
// open the wrong datadir.
func TestResolveNetworkFailsWithoutAConf(t *testing.T) {
	_, _, err := ResolveNetwork(t.TempDir())
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

	_, _, err = ResolveNetwork(dir)
	require.NoError(t, err)

	after, err := os.ReadFile(filepath.Join(dir, "bitwindow-bitcoin.conf"))
	require.NoError(t, err)
	entriesAfter, err := os.ReadDir(dir)
	require.NoError(t, err)

	assert.Equal(t, string(before), string(after), "conf was rewritten")
	assert.Len(t, entriesAfter, len(entriesBefore), "a file was created")
}

// eCash and mainnet are both chain=main to Core; only the uacomment sentinel
// tells them apart. Same NetworkFromConfig the orchestrator uses.
func TestResolveNetworkReadsTheECashSentinel(t *testing.T) {
	for _, tt := range []struct {
		name string
		conf string
		want Network
	}{
		{
			name: "ecash",
			conf: "chain=main\n[main]\ndrivechain=1\nuacomment=ecash-alphanet\n",
			want: NetworkECash,
		},
		{
			name: "later eCash network still eCash",
			conf: "chain=main\n[main]\ndrivechain=1\nuacomment=ecash-betanet\n",
			want: NetworkECash,
		},
		{
			name: "no sentinel is plain mainnet",
			conf: "chain=main\n[main]\ndrivechain=1\nuacomment=BitWindow-0.2\n",
			want: NetworkMainnet,
		},
	} {
		t.Run(tt.name, func(t *testing.T) {
			dir := t.TempDir()
			writeConf(t, dir, "bitwindow-bitcoin.conf", tt.conf)

			network, _, err := ResolveNetwork(dir)
			require.NoError(t, err)
			assert.Equal(t, tt.want, network)
		})
	}
}

// bitwindowd takes the eCash id from the conf too, so it never waits on the
// orchestrator to learn which eCash network it serves.
func TestResolveNetworkReadsTheECashID(t *testing.T) {
	for _, tt := range []struct {
		name string
		conf string
		want string
	}{
		{"alphanet", "chain=main\n[main]\ndrivechain=1\nuacomment=ecash-alphanet\n", "alphanet"},
		{"betanet", "chain=main\n[main]\ndrivechain=1\nuacomment=ecash-betanet\n", "betanet"},
		{"mainnet carries none", "chain=main\n[main]\ndrivechain=1\nuacomment=BitWindow-0.2\n", ""},
		{"signet carries none", "signet=1\n", ""},
	} {
		t.Run(tt.name, func(t *testing.T) {
			dir := t.TempDir()
			writeConf(t, dir, "bitwindow-bitcoin.conf", tt.conf)

			_, ecashID, err := ResolveNetwork(dir)
			require.NoError(t, err)
			assert.Equal(t, tt.want, ecashID)
		})
	}
}
