package config

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func confWithDatadir(t *testing.T, network Network, datadir string) *BitcoinConfManager {
	t.Helper()
	cfg := NewBitcoinConfig()
	if datadir != "" {
		cfg.SetSetting("datadir", datadir)
	}
	return &BitcoinConfManager{Network: network, Config: cfg, DetectedDataDir: datadir}
}

// writeCookie plants the cookie where Core would, for a conf whose datadir=
// points at the given directory.
func writeCookie(t *testing.T, datadir string, network Network, contents string) string {
	t.Helper()
	path := (&BitcoinConfManager{Network: network, DetectedDataDir: datadir}).GetRPCCookiePath()
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte(contents), 0o600))
	return path
}

func TestGetRPCCredentialsPrefersExplicitConf(t *testing.T) {
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "__cookie__:fromcookie")

	m := confWithDatadir(t, NetworkSignet, datadir)
	m.Config.SetSetting("rpcuser", "alice")
	m.Config.SetSetting("rpcpassword", "hunter2")

	user, password, err := m.GetRPCCredentials()
	require.NoError(t, err)
	assert.Equal(t, "alice", user)
	assert.Equal(t, "hunter2", password)
}

func TestGetRPCCredentialsFallsBackToCookie(t *testing.T) {
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "__cookie__:s3cret\n")

	user, password, err := confWithDatadir(t, NetworkSignet, datadir).GetRPCCredentials()
	require.NoError(t, err)
	assert.Equal(t, "__cookie__", user)
	assert.Equal(t, "s3cret", password)
}

// Core rewrites the cookie on every restart, so nothing may cache it.
func TestGetRPCCredentialsRereadsRotatedCookie(t *testing.T) {
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "__cookie__:first")
	m := confWithDatadir(t, NetworkSignet, datadir)

	_, first, err := m.GetRPCCredentials()
	require.NoError(t, err)
	assert.Equal(t, "first", first)

	writeCookie(t, datadir, NetworkSignet, "__cookie__:second")
	_, second, err := m.GetRPCCredentials()
	require.NoError(t, err)
	assert.Equal(t, "second", second)
}

// A half-configured conf must not silently fall through to the cookie.
func TestGetRPCCredentialsIgnoresPartialConfCreds(t *testing.T) {
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "__cookie__:s3cret")

	m := confWithDatadir(t, NetworkSignet, datadir)
	m.Config.SetSetting("rpcuser", "alice")

	user, password, err := m.GetRPCCredentials()
	require.NoError(t, err)
	assert.Equal(t, "__cookie__", user)
	assert.Equal(t, "s3cret", password)
}

// A cookie only authenticates the node that wrote it, so a remote rpcconnect
// must not be handed the local one.
func TestGetRPCCredentialsRemoteCoreIgnoresLocalCookie(t *testing.T) {
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "__cookie__:s3cret")

	m := confWithDatadir(t, NetworkSignet, datadir)
	m.Config.SetSetting("rpcconnect", "10.0.0.5")

	_, _, err := m.GetRPCCredentials()
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no core credentials")
}

func TestGetRPCCredentialsMissingCookieErrors(t *testing.T) {
	_, _, err := confWithDatadir(t, NetworkRegtest, t.TempDir()).GetRPCCredentials()
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no core credentials")
}

func TestGetRPCCredentialsMalformedCookieErrors(t *testing.T) {
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "no-colon-here")

	_, _, err := confWithDatadir(t, NetworkSignet, datadir).GetRPCCredentials()
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no core credentials")
}

// chain=main networks write to the datadir root; the rest get a chain subdir.
func TestGetRPCCookiePathPerNetwork(t *testing.T) {
	datadir := t.TempDir()
	for network, want := range map[Network]string{
		NetworkMainnet: ".cookie",
		NetworkForknet: ".cookie",
		NetworkDrynet:  ".cookie",
		NetworkSignet:  filepath.Join("signet", ".cookie"),
		NetworkRegtest: filepath.Join("regtest", ".cookie"),
	} {
		got := confWithDatadir(t, network, datadir).GetRPCCookiePath()
		assert.Equal(t, filepath.Join(datadir, want), got, "network %s", network)
	}
}

// signet, testnet and regtest normally carry no datadir= at all — Core runs in
// its platform default, and the cookie still has to be found.
func TestGetRPCCookiePathFallsBackToPlatformDefault(t *testing.T) {
	path := confWithDatadir(t, NetworkSignet, "").GetRPCCookiePath()
	assert.NotEmpty(t, path)
	assert.Equal(t, ".cookie", filepath.Base(path))
	assert.Equal(t, "signet", filepath.Base(filepath.Dir(path)))
}

// The default conf must ship no credentials, so Core generates a cookie.
func TestDefaultConfigHasNoStaticCredentials(t *testing.T) {
	conf := (&BitcoinConfManager{Network: NetworkSignet}).GetDefaultConfig()
	assert.NotContains(t, conf, "rpcuser=")
	assert.NotContains(t, conf, "rpcpassword=")
}

// Core stores testnet under testnet3, not the network's readable name.
func TestGetRPCCookiePathTestnetUsesTestnet3(t *testing.T) {
	datadir := t.TempDir()
	got := confWithDatadir(t, NetworkTestnet, datadir).GetRPCCookiePath()
	assert.Equal(t, filepath.Join(datadir, "testnet3", ".cookie"), got)
}

func TestGetRPCCookiePathHonoursAbsoluteRpccookiefile(t *testing.T) {
	m := confWithDatadir(t, NetworkSignet, t.TempDir())
	m.Config.SetSetting("rpccookiefile", filepath.Join(t.TempDir(), "custom.cookie"))

	assert.Equal(t, m.Config.GetSetting("rpccookiefile"), m.GetRPCCookiePath())
}

// A relative rpccookiefile resolves against the network datadir.
func TestGetRPCCookiePathHonoursRelativeRpccookiefile(t *testing.T) {
	datadir := t.TempDir()
	m := confWithDatadir(t, NetworkSignet, datadir)
	m.Config.SetSetting("rpccookiefile", "alt.cookie")

	assert.Equal(t, filepath.Join(datadir, "signet", "alt.cookie"), m.GetRPCCookiePath())
}

func TestGetRPCCredentialsReadsRpccookiefile(t *testing.T) {
	datadir := t.TempDir()
	m := confWithDatadir(t, NetworkSignet, datadir)
	m.Config.SetSetting("rpccookiefile", "alt.cookie")

	require.NoError(t, os.MkdirAll(filepath.Dir(m.GetRPCCookiePath()), 0o755))
	require.NoError(t, os.WriteFile(m.GetRPCCookiePath(), []byte("__cookie__:alt"), 0o600))

	_, password, err := m.GetRPCCredentials()
	require.NoError(t, err)
	assert.Equal(t, "alt", password)
}
