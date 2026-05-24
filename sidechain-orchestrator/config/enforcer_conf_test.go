package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/rs/zerolog"
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

func TestRunEnforcerConfMigrationsFresh(t *testing.T) {
	// No active migrations after derived fields stopped being persisted —
	// fresh configs need no work.
	config := NewEnforcerConfig()
	migrated := RunEnforcerConfMigrations(config)

	if migrated {
		t.Error("no migrations should run on a fresh config")
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
	custom := "# bitwindow-enforcer-conf-version=2\n" +
		"enable-wallet=true\n" +
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

	newContent := "# bitwindow-enforcer-conf-version=2\nenable-wallet=true\ncustom-setting=hello\n"
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
		if arg == "--enable-wallet" {
			hasEnableWallet = true
		}
	}
	if !hasEnableWallet {
		t.Error("should have --enable-wallet flag")
	}
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
	newConfig.SetSetting("enable-wallet", "true")
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
	prefix := "# bitwindow-enforcer-conf-version=2"
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
	if !strings.Contains(conf, "enable-wallet=true") {
		t.Error("default config should still include enable-wallet=true")
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
