package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// Bitcoin Core reads every connect=/addnode= line, so a rewrite that keeps
// only the last one leaves the node dialling a single peer.
func TestSerializeKeepsEveryPeerLine(t *testing.T) {
	conf := ParseBitcoinConfig(`chain=regtest

[regtest]
connect=10.0.0.1:18444
connect=10.0.0.2:18444
addnode=10.0.0.3:18444
addnode=10.0.0.4:18444
`)

	require.Equal(t, []string{"10.0.0.1:18444", "10.0.0.2:18444"}, conf.GetSettings("connect", "regtest"))
	require.Equal(t, "10.0.0.1:18444", conf.GetSetting("connect", "regtest"))

	serialized := conf.Serialize()
	require.Contains(t, serialized,
		"connect=10.0.0.1:18444\nconnect=10.0.0.2:18444\naddnode=10.0.0.3:18444\naddnode=10.0.0.4:18444\n")

	// A second round-trip must be stable, not accumulate or drop lines.
	require.Equal(t, serialized, ParseBitcoinConfig(serialized).Serialize())
}

// ReplaceSetting is what a caller with a single authoritative value uses; it
// drops the other values instead of appending to them.
func TestReplaceSettingCollapsesAMultiValuedKey(t *testing.T) {
	conf := ParseBitcoinConfig("[signet]\naddnode=1.2.3.4:38333\naddnode=5.6.7.8:38333\n")

	conf.ReplaceSetting("addnode", "9.9.9.9:38333", "signet")

	require.Equal(t, []string{"9.9.9.9:38333"}, conf.GetSettings("addnode", "signet"))
	require.Equal(t, 1, strings.Count(conf.Serialize(), "addnode="))
}

// Every network swap and datadir pick rewrites the whole file. Single-valued
// keys are replaced; the peers the user added must survive.
func TestConfigRewritesKeepUserPeers(t *testing.T) {
	tmpDir := t.TempDir()
	t.Setenv("HOME", tmpDir)
	t.Setenv("USERPROFILE", tmpDir)

	m := newTestManager(tmpDir)
	m.Config = ParseBitcoinConfig(fmt.Sprintf(
		"%s%d\nchain=signet\n\n[signet]\naddnode=1.2.3.4:38333\naddnode=5.6.7.8:38333\n",
		bitcoinConfVersionCommentPrefix, BitcoinConfMigrationsVersion,
	))

	require.NoError(t, m.UpdateNetwork(NetworkRegtest))
	require.NoError(t, m.UpdateDataDir(filepath.Join(tmpDir, "chain"), NetworkRegtest))

	onDisk, err := os.ReadFile(m.getBitWindowConfigPath())
	require.NoError(t, err)
	require.Contains(t, string(onDisk), "addnode=1.2.3.4:38333\naddnode=5.6.7.8:38333\n")
	require.Equal(t, 1, strings.Count(string(onDisk), "\nchain="))
	require.Equal(t, 1, strings.Count(string(onDisk), "\ndatadir="))
}
