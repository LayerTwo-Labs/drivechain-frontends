package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newTestEnforcerManager(t *testing.T) (*EnforcerConfManager, string) {
	tmpDir := t.TempDir()
	bitcoinConf := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		Config:       NewBitcoinConfig(),
		log:          zerolog.Nop(),
	}
	// Set up basic bitcoin config so GetExpectedNodeRpcSettings works
	bitcoinConf.Config.GlobalSettings["rpcuser"] = "user"
	bitcoinConf.Config.GlobalSettings["rpcpassword"] = "password"

	m := &EnforcerConfManager{
		bitcoinConf: bitcoinConf,
		ConfigDir:   tmpDir, // Use temp dir so tests don't pollute the real enforcer config
		log:         zerolog.Nop(),
	}
	return m, tmpDir
}

// ---------------------------------------------------------------------------
// Migration system tests
// ---------------------------------------------------------------------------

// A config with no version header reads as version 0, which is what an old
// file looks like. The migration must reach it and leave it at the current
// version, so the enforcer stops seeding a wallet it no longer runs.
func TestRunEnforcerConfMigrationsFresh(t *testing.T) {
	config := NewEnforcerConfig()

	if !RunEnforcerConfMigrations(config) {
		t.Error("an unversioned config must migrate")
	}
	if config.ConfigVersion != enforcerConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, enforcerConfMigrationsVersion)
	}
	if got := config.GetSetting("enable-wallet"); got != "" {
		t.Errorf("enable-wallet = %q, want it gone", got)
	}
	if got := config.GetSetting("enable-block-template-server"); got != "true" {
		t.Errorf("enable-block-template-server = %q, want true", got)
	}

	if RunEnforcerConfMigrations(config) {
		t.Error("a migrated config must be left alone")
	}
}

func TestRunEnforcerConfMigrationsSkipsApplied(t *testing.T) {
	config := NewEnforcerConfig()
	config.ConfigVersion = enforcerConfMigrationsVersion

	migrated := RunEnforcerConfMigrations(config)
	if migrated {
		t.Error("should not migrate when already at current version")
	}
}

// ---------------------------------------------------------------------------
// LoadConfig tests
// ---------------------------------------------------------------------------

func TestEnforcerLoadConfigFromScratch(t *testing.T) {
	m, _ := newTestEnforcerManager(t)

	if err := m.LoadConfig(); err != nil {
		t.Fatal(err)
	}

	if m.Config == nil {
		t.Fatal("config should not be nil")
	}
	if m.ConfigPath == "" {
		t.Error("configPath should be set")
	}
	if m.Config.ConfigVersion != enforcerConfMigrationsVersion {
		t.Errorf("version = %d, want %d", m.Config.ConfigVersion, enforcerConfMigrationsVersion)
	}
}

func TestEnforcerLoadConfigPreservesPersistedDerivedFields(t *testing.T) {
	// Persisted bitwindow-enforcer.conf has precedence — anything written
	// there (by the user, by a future migration, by a tool) survives load
	// untouched. GetCliArgs only fills in gaps from the network derivation.
	m, _ := newTestEnforcerManager(t)

	confPath := m.getConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(confPath), 0755))
	custom := "# bitwindow-enforcer-conf-version=3\n" +
		"enable-block-template-server=true\n" +
		"node-rpc-addr=10.0.0.5:8332\n" +
		"node-rpc-user=alice\n"
	require.NoError(t, os.WriteFile(confPath, []byte(custom), 0644))

	require.NoError(t, m.LoadConfig())

	if got := m.Config.GetSetting("node-rpc-addr"); got != "10.0.0.5:8332" {
		t.Errorf("persisted node-rpc-addr = %q, want unchanged 10.0.0.5:8332", got)
	}
	if got := m.Config.GetSetting("node-rpc-user"); got != "alice" {
		t.Errorf("persisted node-rpc-user = %q, want unchanged alice", got)
	}
}

func TestEnforcerLoadConfigIdempotent(t *testing.T) {
	m, _ := newTestEnforcerManager(t)

	if err := m.LoadConfig(); err != nil {
		t.Fatal(err)
	}
	v1 := m.Config.ConfigVersion

	if err := m.LoadConfig(); err != nil {
		t.Fatal(err)
	}

	if m.Config.ConfigVersion != v1 {
		t.Errorf("version changed from %d to %d on reload", v1, m.Config.ConfigVersion)
	}
}

// ---------------------------------------------------------------------------
// GetCurrentConfigContent / WriteConfig tests
// ---------------------------------------------------------------------------

func TestGetCurrentConfigContent(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	content := m.GetCurrentConfigContent()
	if content == "" {
		t.Error("should return non-empty content")
	}
}

func TestGetCurrentConfigContentNilConfig(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	// Don't call LoadConfig — config is nil
	content := m.GetCurrentConfigContent()
	if content == "" {
		t.Error("should return default config when config is nil")
	}
}

func TestWriteConfig(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	newContent := "# bitwindow-enforcer-conf-version=3\nenable-block-template-server=true\ncustom-setting=hello\n"
	if err := m.WriteConfig(newContent); err != nil {
		t.Fatal(err)
	}

	// Config should be updated in memory
	if m.Config.GetSetting("custom-setting") != "hello" {
		t.Errorf("custom-setting = %q, want hello", m.Config.GetSetting("custom-setting"))
	}

	// File should be written
	data, err := os.ReadFile(m.getConfigPath())
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(data), "custom-setting=hello") {
		t.Error("file should contain custom-setting")
	}
}

// ---------------------------------------------------------------------------
// GetCliArgs tests
// ---------------------------------------------------------------------------

// ECash forks mainnet, so the enforcer needs the generation's preset. Nothing
// persists it — the conf carries no network-preset on a fresh install.
func TestGetCliArgsDerivesECashNetworkPreset(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())
	m.bitcoinConf.Network = NetworkECash
	m.bitcoinConf.ECashID = "drynet4"

	require.Contains(t, m.GetCliArgs(), "--network-preset=drynet4")

	// A persisted value wins, same as every other derived setting.
	m.Config.Settings["network-preset"] = "drynet3"
	require.Contains(t, m.GetCliArgs(), "--network-preset=drynet3")
	require.NotContains(t, m.GetCliArgs(), "--network-preset=drynet4")
}

// Only eCash builds of the enforcer accept the flag.
func TestGetCliArgsOmitsNetworkPresetOffECash(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	for _, arg := range m.GetCliArgs() {
		require.NotContains(t, arg, "--network-preset")
	}
}

func TestGetCliArgs(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	args := m.GetCliArgs()
	if len(args) == 0 {
		t.Fatal("should have CLI args")
	}

	// Check that boolean true values become flags
	hasEnableWallet := false
	for _, arg := range args {
		if arg == "--enable-block-template-server" {
			hasEnableWallet = true
		}
	}
	if !hasEnableWallet {
		t.Error("should have --enable-block-template-server flag")
	}
}

// The enforcer exits on an unknown option, so a settings file that still
// carries a flag it dropped must not reach the argv — one stale key would
// otherwise keep the daemon from ever starting.
func TestGetCliArgsDropsKeysTheEnforcerDoesNotAccept(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	m.Config.SetSetting("serve-json-rpc-addr", "127.0.0.1:8123")
	m.Config.SetSetting("wallet-full-scan", "true")
	m.Config.SetSetting("signet-miner-coinbase-recipient", "tb1qexample")
	m.Config.SetSetting("serve-rpc-addr", "127.0.0.1:8122")

	args := m.GetCliArgs()

	rejectArgPrefix(t, args, "--serve-json-rpc-addr")
	rejectArgPrefix(t, args, "--wallet-full-scan")
	rejectArgPrefix(t, args, "--signet-miner-coinbase-recipient")
	requireArg(t, args, "--serve-rpc-addr=127.0.0.1:8122")
}

// Regression for #1712 ("Enforcer startup errors due to password and cookie
// mixups"). The enforcer dies at startup with "precisely one of rpc user and
// cookie must be set" when --node-rpc-user / --node-rpc-pass don't reach it.
// These tests pin two invariants of GetCliArgs:
//  1. A fresh config (no persisted overrides) always emits both flags via
//     the bitcoin-conf-derived overlay.
//  2. An EMPTY persisted value (e.g. user cleared the field in the
//     configurator) must NOT mark the key as seen — the overlay default
//     must still fire. Previously the seen[key]=true short-circuit ran
//     first, leaving the enforcer with neither flag.
func TestGetCliArgs_FreshConfigAlwaysEmitsNodeRpcUserAndPass(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	args := m.GetCliArgs()
	hasUser, hasPass := false, false
	for _, a := range args {
		if strings.HasPrefix(a, "--node-rpc-user=") {
			hasUser = true
		}
		if strings.HasPrefix(a, "--node-rpc-pass=") {
			hasPass = true
		}
	}
	if !hasUser {
		t.Errorf("expected --node-rpc-user=... in args, got %v", args)
	}
	if !hasPass {
		t.Errorf("expected --node-rpc-pass=... in args, got %v", args)
	}
}

func TestGetCliArgs_EmptyPersistedValueFallsBackToOverlay(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	// Simulate the user clearing the value in the configurator. The
	// persisted settings map carries an entry with an empty value.
	m.Config.Settings["node-rpc-user"] = ""
	m.Config.Settings["node-rpc-pass"] = ""

	args := m.GetCliArgs()
	hasUser, hasPass := false, false
	for _, a := range args {
		if strings.HasPrefix(a, "--node-rpc-user=") && a != "--node-rpc-user=" {
			hasUser = true
		}
		if strings.HasPrefix(a, "--node-rpc-pass=") && a != "--node-rpc-pass=" {
			hasPass = true
		}
	}
	if !hasUser {
		t.Errorf("empty persisted node-rpc-user must fall back to overlay default; got args=%v", args)
	}
	if !hasPass {
		t.Errorf("empty persisted node-rpc-pass must fall back to overlay default; got args=%v", args)
	}
}

func TestGetCliArgs_NonEmptyPersistedValueWinsOverOverlay(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	m.Config.Settings["node-rpc-user"] = "custom-user"
	m.Config.Settings["node-rpc-pass"] = "custom-pass"

	args := m.GetCliArgs()
	hasCustomUser, hasCustomPass := false, false
	for _, a := range args {
		if a == "--node-rpc-user=custom-user" {
			hasCustomUser = true
		}
		if a == "--node-rpc-pass=custom-pass" {
			hasCustomPass = true
		}
	}
	if !hasCustomUser || !hasCustomPass {
		t.Errorf("expected custom persisted creds to win over overlay; got %v", args)
	}
}

// ---------------------------------------------------------------------------
// File watching tests
// ---------------------------------------------------------------------------

func TestEnforcerFileWatchingTriggersReload(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	if err := m.StartWatching(); err != nil {
		t.Fatal(err)
	}
	defer m.StopWatching()

	// Write a different config externally
	confPath := m.getConfigPath()
	newConfig := NewEnforcerConfig()
	newConfig.ConfigVersion = enforcerConfMigrationsVersion
	newConfig.SetSetting("enable-block-template-server", "true")
	newConfig.SetSetting("custom-watched-setting", "detected")
	require.NoError(t, os.WriteFile(confPath, []byte(newConfig.Serialize()), 0644))

	// Wait for debounce (500ms) + processing
	time.Sleep(700 * time.Millisecond)

	if m.Config.GetSetting("custom-watched-setting") != "detected" {
		t.Error("file watcher should have reloaded config with new setting")
	}
}

// ---------------------------------------------------------------------------
// GetDefaultConfig tests
// ---------------------------------------------------------------------------

func TestEnforcerGetDefaultConfigHasVersionPrefix(t *testing.T) {
	m, _ := newTestEnforcerManager(t)

	conf := m.GetDefaultConfig()
	prefix := "# bitwindow-enforcer-conf-version=4"
	if !strings.HasPrefix(conf, prefix) {
		first := conf
		if len(first) > 80 {
			first = first[:80]
		}
		t.Errorf("default config should start with %q, got %q...", prefix, first)
	}
}

func TestEnforcerGetDefaultConfigOmitsDerivedFields(t *testing.T) {
	m, _ := newTestEnforcerManager(t)

	conf := m.GetDefaultConfig()
	for _, key := range derivedEnforcerSettings {
		// match "key=" to avoid false-positives on a comment that
		// references the field name.
		needle := key + "="
		if strings.Contains(conf, needle) {
			t.Errorf("default config must not persist derived field %q (substring %q found)", key, needle)
		}
	}
	// The genuine user toggles still belong in the template.
	if !strings.Contains(conf, "enable-block-template-server=true") {
		t.Error("default config should still include enable-block-template-server=true")
	}
	if !strings.Contains(conf, "enable-mempool=true") {
		t.Error("default config should still include enable-mempool=true")
	}
}

// ---------------------------------------------------------------------------
// GetCliArgs derived-field overlay
// ---------------------------------------------------------------------------

func TestGetCliArgsAlwaysOverlaysDerivedFromBitcoinConf(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	args := m.GetCliArgs()

	// Each derived field must show up — exact values are network/config
	// dependent and tested elsewhere (network_test.go for port mapping,
	// EsploraURLForNetwork for esplora). What this test guarantees is
	// the overlay: every derived flag is present in CLI args even when
	// the persisted file contains nothing about them.
	requireArg(t, args, "--node-rpc-addr=")
	requireArg(t, args, "--node-rpc-user=")
	requireArg(t, args, "--node-rpc-pass=")
	requireArg(t, args, "--node-zmq-addr-sequence=")
	requireArg(t, args, "--wallet-esplora-url=")
}

func TestGetCliArgsPersistedValuesWinOverNetworkDerivation(t *testing.T) {
	// bitwindow-enforcer.conf has precedence: when a derived field is
	// explicitly set in the persisted config, GetCliArgs uses that and
	// does NOT also emit the bitcoin.conf-derived value. This is the
	// "advanced override" path — point the enforcer at a different
	// bitcoind than BitWindow's own.
	m, _ := newTestEnforcerManager(t) // signet
	require.NoError(t, m.LoadConfig())

	const customAddr = "10.0.0.5:8332"
	const customEsplora = "http://my-esplora.example/api"
	m.Config.SetSetting("node-rpc-addr", customAddr)
	m.Config.SetSetting("wallet-esplora-url", customEsplora)

	args := m.GetCliArgs()

	// Persisted values must show up.
	requireArg(t, args, "--node-rpc-addr="+customAddr)
	requireArg(t, args, "--wallet-esplora-url="+customEsplora)

	// And the network-derived defaults must NOT also be appended —
	// otherwise the enforcer would see two --node-rpc-addr flags and
	// the override wouldn't actually override anything.
	rejectArg(t, args, fmt.Sprintf("--node-rpc-addr=127.0.0.1:%d", RPCPortForNetwork(m.bitcoinConf.Network)))
	rejectArg(t, args, fmt.Sprintf("--wallet-esplora-url=%s", EsploraURLForNetwork(m.bitcoinConf.Network)))
}

func TestGetCliArgsReflectsCurrentNetwork(t *testing.T) {
	// Swap the manager's network mid-flight and confirm the next
	// GetCliArgs call surfaces the new network's port + esplora URL.
	// This is what the original bug claimed should happen but didn't —
	// the persisted file pinned the args to whatever network was active
	// when the file was first written.
	m, _ := newTestEnforcerManager(t) // starts on signet
	require.NoError(t, m.LoadConfig())

	signetArgs := m.GetCliArgs()
	requireArg(t, signetArgs, fmt.Sprintf("--node-rpc-addr=127.0.0.1:%d", RPCPortForNetwork(NetworkSignet)))
	requireArg(t, signetArgs, fmt.Sprintf("--wallet-esplora-url=%s", EsploraURLForNetwork(NetworkSignet)))

	m.bitcoinConf.Network = NetworkRegtest
	regtestArgs := m.GetCliArgs()
	requireArg(t, regtestArgs, fmt.Sprintf("--node-rpc-addr=127.0.0.1:%d", RPCPortForNetwork(NetworkRegtest)))
	// Regtest has no esplora / electrs in the stack; the enforcer is
	// switched to wallet-sync-source=disabled and gets no esplora URL.
	rejectArgPrefix(t, regtestArgs, "--wallet-esplora-url=")
	requireArg(t, regtestArgs, "--wallet-sync-source=disabled")

	m.bitcoinConf.Network = NetworkMainnet
	mainnetArgs := m.GetCliArgs()
	requireArg(t, mainnetArgs, fmt.Sprintf("--node-rpc-addr=127.0.0.1:%d", RPCPortForNetwork(NetworkMainnet)))
	// Mainnet has an esplora URL too; assert presence by prefix rather
	// than exact value to keep the test robust to provider swaps.
	requireArg(t, mainnetArgs, "--wallet-esplora-url=")
}

func TestGetCliArgsOverlaysWhenConfigIsNil(t *testing.T) {
	// If we're called before LoadConfig (e.g. from a command-line tool
	// that just wants the args), derived fields still need to land.
	m, _ := newTestEnforcerManager(t)

	args := m.GetCliArgs()

	requireArg(t, args, "--node-rpc-addr=")
}

// requireArg asserts at least one element of args has the given prefix.
// Pass a full "--flag=value" to assert presence-by-exact-content; pass
// just "--flag=" to assert presence-by-key.
func requireArg(t *testing.T, args []string, prefix string) {
	t.Helper()
	for _, got := range args {
		if strings.HasPrefix(got, prefix) {
			return
		}
	}
	t.Errorf("expected an arg with prefix %q in %v", prefix, args)
}

func rejectArg(t *testing.T, args []string, bad string) {
	t.Helper()
	for _, got := range args {
		if got == bad {
			t.Errorf("arg %q must not appear in %v", bad, args)
		}
	}
}

// rejectArgPrefix fails if any arg starts with prefix — use when you want
// to assert a flag is absent regardless of its value.
func rejectArgPrefix(t *testing.T, args []string, prefix string) {
	t.Helper()
	for _, got := range args {
		if strings.HasPrefix(got, prefix) {
			t.Errorf("arg with prefix %q must not appear in %v", prefix, args)
		}
	}
}

// An eCash rollover must reach the enforcer conf: a persisted preset or esplora
// host still names the retired fork, and the enforcer would keep it.
func TestRetargetECashGenerationRewritesPersistedValues(t *testing.T) {
	m, dir := newTestEnforcerManager(t)
	m.bitcoinConf.Network = NetworkECash
	require.NoError(t, m.WriteConfig(strings.Join([]string{
		"network-preset=drynet4",
		"wallet-esplora-url=https://esplora.drynet4.drivechain.dev",
		"enable-block-template-server=true",
	}, "\n")))

	changed, err := m.RetargetECashNetwork("drynet4", "alphanet")
	require.NoError(t, err)
	require.True(t, changed)

	require.Equal(t, "alphanet", m.Config.GetSetting("network-preset"))
	require.Equal(t, EsploraURLForNetwork(NetworkECash), m.Config.GetSetting("wallet-esplora-url"))
	require.Equal(t, "true", m.Config.GetSetting("enable-block-template-server"))

	onDisk, err := os.ReadFile(filepath.Join(dir, bitwindowEnforcerConfFilename))
	require.NoError(t, err)
	require.Contains(t, string(onDisk), "network-preset=alphanet")
	require.NotContains(t, string(onDisk), "drynet4")
}

// The derived keys belong to the active network, so a value written for another
// one must survive the eCash retarget.
func TestRetargetECashGenerationLeavesOtherNetworksAlone(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.WriteConfig("wallet-esplora-url=https://explorer.signet.drivechain.info/api"))

	changed, err := m.RetargetECashNetwork("drynet4", "alphanet")
	require.NoError(t, err)
	require.False(t, changed)
	require.Equal(t, "https://explorer.signet.drivechain.info/api", m.Config.GetSetting("wallet-esplora-url"))
}

// GetCliArgs treats a persisted value as an explicit override, and every start
// runs the retarget. An endpoint the user chose must not read as the retired
// fork's just because eCash is active.
func TestRetargetECashGenerationKeepsACustomEndpoint(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.bitcoinConf.Network = NetworkECash
	require.NoError(t, m.WriteConfig(strings.Join([]string{
		"network-preset=drynet4",
		"wallet-esplora-url=https://esplora.mine.example",
	}, "\n")))

	changed, err := m.RetargetECashNetwork("drynet4", "alphanet")
	require.NoError(t, err)
	require.True(t, changed, "the preset still names the retired fork")

	require.Equal(t, "alphanet", m.Config.GetSetting("network-preset"))
	require.Equal(t, "https://esplora.mine.example", m.Config.GetSetting("wallet-esplora-url"),
		"an endpoint the user chose is theirs to keep")
}

// Nothing changed, so nothing may be rewritten: a start that rewrites the file
// every time would undo an override the moment it is written.
func TestRetargetECashGenerationDoesNothingWithoutAMove(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.bitcoinConf.Network = NetworkECash
	require.NoError(t, m.WriteConfig("network-preset=alphanet"))

	changed, err := m.RetargetECashNetwork("alphanet", "alphanet")
	require.NoError(t, err)
	require.False(t, changed)
}

// A conf that persists neither derived key must be left alone, so every start
// does not rewrite the file.
func TestRetargetECashGenerationLeavesOtherConfigsAlone(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.bitcoinConf.Network = NetworkECash
	require.NoError(t, m.WriteConfig("enable-block-template-server=true\nenable-mempool=true"))

	changed, err := m.RetargetECashNetwork("drynet4", "alphanet")
	require.NoError(t, err)
	require.False(t, changed)
}

// newCookieEnforcerManager mirrors newTestEnforcerManager but leaves the
// bitcoin conf without rpcuser/rpcpassword, so Core's cookie is the only
// credential — the default for a fresh install.
func newCookieEnforcerManager(t *testing.T) (*EnforcerConfManager, string) {
	t.Helper()
	tmpDir := t.TempDir()
	datadir := t.TempDir()
	writeCookie(t, datadir, NetworkSignet, "__cookie__:s3cret")

	bitcoinConf := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		Config:       NewBitcoinConfig(),
		log:          zerolog.Nop(),
	}
	bitcoinConf.Config.SetSetting("datadir", datadir)
	bitcoinConf.DetectedDataDir = datadir

	return &EnforcerConfManager{
		bitcoinConf: bitcoinConf,
		ConfigDir:   tmpDir,
		log:         zerolog.Nop(),
	}, datadir
}

func hasArgPrefix(args []string, prefix string) bool {
	for _, a := range args {
		if strings.HasPrefix(a, prefix) {
			return true
		}
	}
	return false
}

func TestGetCliArgs_NoConfCredsUsesCookiePath(t *testing.T) {
	m, datadir := newCookieEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	args := m.GetCliArgs()
	assert.Contains(t, args, "--node-rpc-cookie-path="+filepath.Join(datadir, "signet", ".cookie"))
	assert.False(t, hasArgPrefix(args, "--node-rpc-user="), "cookie and user are mutually exclusive: %v", args)
	assert.False(t, hasArgPrefix(args, "--node-rpc-pass="), "cookie and pass are mutually exclusive: %v", args)
}

// The enforcer refuses a user and a cookie together, so a persisted auth mode
// must suppress the derived one.
func TestGetCliArgs_PersistedUserSuppressesDerivedCookie(t *testing.T) {
	m, _ := newCookieEnforcerManager(t)
	require.NoError(t, m.LoadConfig())
	m.Config.Settings["node-rpc-user"] = "legacy-user"
	m.Config.Settings["node-rpc-pass"] = "legacy-pass"

	args := m.GetCliArgs()
	assert.Contains(t, args, "--node-rpc-user=legacy-user")
	assert.False(t, hasArgPrefix(args, "--node-rpc-cookie-path="), "got %v", args)
}

func TestGetCliArgs_PersistedCookieSuppressesDerivedUser(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())
	m.Config.Settings["node-rpc-cookie-path"] = "/custom/.cookie"

	args := m.GetCliArgs()
	assert.Contains(t, args, "--node-rpc-cookie-path=/custom/.cookie")
	assert.False(t, hasArgPrefix(args, "--node-rpc-user="), "got %v", args)
	assert.False(t, hasArgPrefix(args, "--node-rpc-pass="), "got %v", args)
}

func TestWithElectrumFallbackReplacesEsplora(t *testing.T) {
	args := []string{"--enable-block-template-server", "--wallet-esplora-url=https://esplora.drynet4.drivechain.dev"}

	got := WithElectrumFallback(args, "ssl://drynet4.drivechain.dev", 50002)

	assert.Contains(t, got, "--enable-block-template-server")
	assert.Contains(t, got, "--wallet-sync-source=electrum")
	assert.Contains(t, got, "--wallet-electrum-host=ssl://drynet4.drivechain.dev")
	assert.Contains(t, got, "--wallet-electrum-port=50002")
	assert.False(t, hasArgPrefix(got, "--wallet-esplora-url="), "got %v", got)
}

// A pinned sync source is the user's choice, so the probe must not undo it.
func TestWithElectrumFallbackKeepsPinnedSyncSource(t *testing.T) {
	args := []string{"--wallet-esplora-url=https://esplora.example", "--wallet-sync-source=disabled"}

	assert.Equal(t, args, WithElectrumFallback(args, "ssl://node.example", 50002))
}

func TestWithElectrumFallbackKeepsArgsWithoutElectrumServer(t *testing.T) {
	args := []string{"--wallet-esplora-url=https://esplora.example"}

	assert.Equal(t, args, WithElectrumFallback(args, "", 0))
}

func TestEsploraArgURL(t *testing.T) {
	url, ok := EsploraArgURL([]string{"--enable-block-template-server", "--wallet-esplora-url=https://esplora.example"})
	assert.True(t, ok)
	assert.Equal(t, "https://esplora.example", url)

	_, ok = EsploraArgURL([]string{"--enable-block-template-server"})
	assert.False(t, ok)
}

// The L1 boot reads this file on a goroutine the swap starts, so it has to be
// right before eCash is the active network. A guard on the live network would
// refuse the one rewrite that matters and lose the race.
func TestRetargetECashNetworkForRunsBeforeTheSwapLands(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.Equal(t, NetworkSignet, m.bitcoinConf.Network, "the swap has not landed yet")
	require.NoError(t, m.WriteConfig("network-preset=drynet4\n"))

	changed, err := m.RetargetECashNetworkFor(NetworkECash, "drynet4", "alphanet")
	require.NoError(t, err)
	require.True(t, changed, "the target network decides, not the live one")
	require.Equal(t, "alphanet", m.Config.GetSetting("network-preset"))
}

// A swap into any other network leaves this file alone: its values belong to
// whoever wrote them.
func TestRetargetECashNetworkForIgnoresOtherNetworks(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.WriteConfig("network-preset=drynet4\n"))

	changed, err := m.RetargetECashNetworkFor(NetworkSignet, "drynet4", "alphanet")
	require.NoError(t, err)
	require.False(t, changed)
	require.Equal(t, "drynet4", m.Config.GetSetting("network-preset"))
}
