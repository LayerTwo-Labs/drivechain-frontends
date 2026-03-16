package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/rs/zerolog"
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
	config := NewEnforcerConfig()
	migrated := RunEnforcerConfMigrations(config)

	if !migrated {
		t.Fatal("expected migrations to run on fresh config")
	}
	if config.ConfigVersion != enforcerConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, enforcerConfMigrationsVersion)
	}
	if !config.HasSetting("node-zmq-addr-sequence") {
		t.Error("migration should have added node-zmq-addr-sequence")
	}
	if config.GetSetting("node-zmq-addr-sequence") != "tcp://127.0.0.1:29000" {
		t.Errorf("zmq addr = %q", config.GetSetting("node-zmq-addr-sequence"))
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

func TestRunEnforcerConfMigrationsPreservesExisting(t *testing.T) {
	config := NewEnforcerConfig()
	config.ConfigVersion = 1
	config.SetSetting("node-zmq-addr-sequence", "tcp://127.0.0.1:99999")

	RunEnforcerConfMigrations(config)

	// Migration 2 should NOT overwrite existing value (uses HasSetting check)
	if config.GetSetting("node-zmq-addr-sequence") != "tcp://127.0.0.1:99999" {
		t.Errorf("should not overwrite existing zmq addr, got %q", config.GetSetting("node-zmq-addr-sequence"))
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

func TestEnforcerLoadConfigWithMigration(t *testing.T) {
	m, _ := newTestEnforcerManager(t)

	// Write a v1 config without zmq setting
	confPath := m.getConfigPath()
	os.MkdirAll(filepath.Dir(confPath), 0755)
	os.WriteFile(confPath, []byte("# bitwindow-enforcer-conf-version=1\nenable-wallet=true\n"), 0644)

	if err := m.LoadConfig(); err != nil {
		t.Fatal(err)
	}

	// Should have been migrated to v2 with zmq
	if m.Config.ConfigVersion != enforcerConfMigrationsVersion {
		t.Errorf("version = %d, want %d", m.Config.ConfigVersion, enforcerConfMigrationsVersion)
	}
	if !m.Config.HasSetting("node-zmq-addr-sequence") {
		t.Error("migration should have added node-zmq-addr-sequence")
	}

	// File should have been written with migrated content
	data, err := os.ReadFile(confPath)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(data), "node-zmq-addr-sequence") {
		t.Error("migrated file should contain node-zmq-addr-sequence")
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
// NodeRpcDiffers tests
// ---------------------------------------------------------------------------

func TestNodeRpcDiffers(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.LoadConfig()

	// After sync, should not differ
	m.SyncFromBitcoinConf()
	if m.NodeRpcDiffers() {
		t.Error("should not differ after sync")
	}

	// Change a setting manually
	m.Config.SetSetting("node-rpc-user", "wrong")
	if !m.NodeRpcDiffers() {
		t.Error("should differ after manual change")
	}
}

// ---------------------------------------------------------------------------
// SyncFromBitcoinConf tests
// ---------------------------------------------------------------------------

func TestSyncFromBitcoinConf(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.LoadConfig()

	// Set bitcoin conf to have specific values
	m.bitcoinConf.Config.GlobalSettings["rpcuser"] = "myuser"
	m.bitcoinConf.Config.GlobalSettings["rpcpassword"] = "mypass"

	if err := m.SyncFromBitcoinConf(); err != nil {
		t.Fatal(err)
	}

	if m.Config.GetSetting("node-rpc-user") != "myuser" {
		t.Errorf("user = %q, want myuser", m.Config.GetSetting("node-rpc-user"))
	}
	if m.Config.GetSetting("node-rpc-pass") != "mypass" {
		t.Errorf("pass = %q, want mypass", m.Config.GetSetting("node-rpc-pass"))
	}
}

func TestSyncFromBitcoinConfSetsEsplora(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.LoadConfig()

	// Signet should have esplora URL
	m.bitcoinConf.Network = NetworkSignet
	m.SyncFromBitcoinConf()
	if m.Config.GetSetting("wallet-esplora-url") != "https://explorer.signet.drivechain.info/api" {
		t.Errorf("esplora = %q", m.Config.GetSetting("wallet-esplora-url"))
	}

	// Testnet should have no esplora URL (removed)
	m.bitcoinConf.Network = NetworkTestnet
	m.SyncFromBitcoinConf()
	if m.Config.HasSetting("wallet-esplora-url") {
		t.Error("testnet should not have esplora URL")
	}
}

// ---------------------------------------------------------------------------
// GetCurrentConfigContent / WriteConfig tests
// ---------------------------------------------------------------------------

func TestGetCurrentConfigContent(t *testing.T) {
	m, _ := newTestEnforcerManager(t)
	m.LoadConfig()

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
	m.LoadConfig()

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
	m.LoadConfig()

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
	m.LoadConfig()

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
	os.WriteFile(confPath, []byte(newConfig.Serialize()), 0644)

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

func TestEnforcerGetDefaultConfigHasNodeRpc(t *testing.T) {
	m, _ := newTestEnforcerManager(t)

	conf := m.GetDefaultConfig()
	if !strings.Contains(conf, "node-rpc-user=user") {
		t.Error("should contain node-rpc-user")
	}
	if !strings.Contains(conf, "node-rpc-pass=password") {
		t.Error("should contain node-rpc-pass")
	}
}
