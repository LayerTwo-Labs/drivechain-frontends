package config

import (
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

func TestEnforcerLoadConfigStripsDerivedFields(t *testing.T) {
	// Old conf files (or anything that snuck derived fields in) must
	// have those fields stripped on load — that's how a stale regtest
	// node-rpc-addr never makes it into the running enforcer's args.
	m, _ := newTestEnforcerManager(t)

	confPath := m.getConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(confPath), 0755))
	stale := "# bitwindow-enforcer-conf-version=2\n" +
		"enable-wallet=true\n" +
		"node-rpc-user=stale\n" +
		"node-rpc-pass=stale\n" +
		"node-rpc-addr=127.0.0.1:18443\n" +
		"node-zmq-addr-sequence=tcp://127.0.0.1:99999\n" +
		"wallet-esplora-url=http://localhost:3003\n"
	require.NoError(t, os.WriteFile(confPath, []byte(stale), 0644))

	require.NoError(t, m.LoadConfig())

	for _, key := range derivedEnforcerSettings {
		if m.Config.HasSetting(key) {
			t.Errorf("derived field %q must be stripped on load, still present", key)
		}
	}
	if m.Config.GetSetting("enable-wallet") != "true" {
		t.Error("user toggle enable-wallet must survive the strip")
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
// NodeRpcDiffers / SyncFromBitcoinConf — both vestigial after derived
// fields stopped being persisted; just guard the wire-shape behaviour.
// ---------------------------------------------------------------------------

func TestNodeRpcDiffersAlwaysFalse(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	if m.NodeRpcDiffers() {
		t.Error("NodeRpcDiffers must always be false now that node-rpc-* are not persisted")
	}

	// Even if some legacy code stuffs a stale value back in, the answer
	// is still false — there's nothing meaningful to compare against.
	m.Config.SetSetting("node-rpc-user", "wrong")
	if m.NodeRpcDiffers() {
		t.Error("NodeRpcDiffers must remain false even with manually-injected stale state")
	}
}

func TestSyncFromBitcoinConfIsNoOp(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	require.NoError(t, m.SyncFromBitcoinConf())

	for _, key := range derivedEnforcerSettings {
		if m.Config.HasSetting(key) {
			t.Errorf("SyncFromBitcoinConf must not persist derived field %q", key)
		}
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

	// Signet RPC port (38332) and signet esplora must be present even
	// though the persisted file contains nothing about them.
	requireArg(t, args, "--node-rpc-addr=127.0.0.1:38332")
	requireArg(t, args, "--node-rpc-user=user")
	requireArg(t, args, "--node-rpc-pass=password")
	requireArg(t, args, "--node-zmq-addr-sequence=tcp://127.0.0.1:29000")
	requireArg(t, args, "--wallet-esplora-url=https://explorer.signet.drivechain.info/api")
}

func TestGetCliArgsIgnoresStalePersistedDerivedFields(t *testing.T) {
	// Even if a stale persisted file somehow survived the load-time
	// strip (older-build dropped a file, race, you name it),
	// GetCliArgs must derive from the live bitcoin.conf, not from the
	// file. This is the regression test for "regtest port baked into
	// signet enforcer.conf".
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	m.Config.SetSetting("node-rpc-addr", "127.0.0.1:18443")
	m.Config.SetSetting("wallet-esplora-url", "http://localhost:3003")

	args := m.GetCliArgs()

	for _, bad := range []string{"--node-rpc-addr=127.0.0.1:18443", "--wallet-esplora-url=http://localhost:3003"} {
		for _, got := range args {
			if got == bad {
				t.Errorf("GetCliArgs must ignore stale persisted derived field, got %q", got)
			}
		}
	}
	requireArg(t, args, "--node-rpc-addr=127.0.0.1:38332")
	requireArg(t, args, "--wallet-esplora-url=https://explorer.signet.drivechain.info/api")
}

func TestGetCliArgsOverlaysWhenConfigIsNil(t *testing.T) {
	// If we're called before LoadConfig (e.g. from a command-line tool
	// that just wants the args), derived fields still need to land.
	m, _ := newTestEnforcerManager(t)

	args := m.GetCliArgs()

	requireArg(t, args, "--node-rpc-addr=127.0.0.1:38332")
}

func requireArg(t *testing.T, args []string, want string) {
	t.Helper()
	for _, got := range args {
		if got == want {
			return
		}
	}
	t.Errorf("expected arg %q in %v", want, args)
}
