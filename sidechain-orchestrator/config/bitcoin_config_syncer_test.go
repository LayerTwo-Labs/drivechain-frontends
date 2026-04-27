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

// ---------------------------------------------------------------------------
// Piece 1 tests: ForknetConfig + MainnetConfig
// ---------------------------------------------------------------------------

func TestParseForknetConfig(t *testing.T) {
	input := `# bitwindow-forknet-conf-version=3
port=8300
rpcport=18301
drivechain=1
`
	c := ParseForknetConfig(input)
	if c.Version != 3 {
		t.Errorf("version = %d, want 3", c.Version)
	}
	if c.Settings["port"] != "8300" {
		t.Errorf("port = %q, want 8300", c.Settings["port"])
	}
	if c.Settings["rpcport"] != "18301" {
		t.Errorf("rpcport = %q, want 18301", c.Settings["rpcport"])
	}
	if c.Settings["drivechain"] != "1" {
		t.Errorf("drivechain = %q, want 1", c.Settings["drivechain"])
	}
}

func TestForknetConfigRoundTrip(t *testing.T) {
	c := NewForknetConfig()
	c.Version = 4
	c.Settings["port"] = "8300"
	c.Settings["rpcport"] = "18301"

	serialized := c.Serialize()
	parsed := ParseForknetConfig(serialized)

	if parsed.Version != 4 {
		t.Errorf("version = %d, want 4", parsed.Version)
	}
	if parsed.Settings["port"] != "8300" {
		t.Errorf("port = %q, want 8300", parsed.Settings["port"])
	}
	if parsed.Settings["rpcport"] != "18301" {
		t.Errorf("rpcport = %q, want 18301", parsed.Settings["rpcport"])
	}
}

func TestParseForknetConfigEmpty(t *testing.T) {
	c := ParseForknetConfig("")
	if c.Version != 0 {
		t.Errorf("version = %d, want 0", c.Version)
	}
	if len(c.Settings) != 0 {
		t.Errorf("settings = %v, want empty", c.Settings)
	}
}

func TestParseMainnetConfig(t *testing.T) {
	input := `# bitwindow-mainnet-conf-version=2
datadir=/path/to/data
`
	c := ParseMainnetConfig(input)
	if c.Version != 2 {
		t.Errorf("version = %d, want 2", c.Version)
	}
	if c.Settings["datadir"] != "/path/to/data" {
		t.Errorf("datadir = %q, want /path/to/data", c.Settings["datadir"])
	}
}

func TestMainnetConfigRoundTrip(t *testing.T) {
	c := NewMainnetConfig()
	c.Version = 4
	c.Settings["datadir"] = "/some/path"

	serialized := c.Serialize()
	parsed := ParseMainnetConfig(serialized)

	if parsed.Version != 4 {
		t.Errorf("version = %d, want 4", parsed.Version)
	}
	if parsed.Settings["datadir"] != "/some/path" {
		t.Errorf("datadir = %q, want /some/path", parsed.Settings["datadir"])
	}
}

// ---------------------------------------------------------------------------
// Piece 2 tests: Migration system
// ---------------------------------------------------------------------------

func TestRunBitcoinConfMigrationsFresh(t *testing.T) {
	config := NewBitcoinConfig()
	migrated := RunBitcoinConfMigrations(config, false)

	if !migrated {
		t.Fatal("expected migrations to run on fresh config")
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}

	// Migration 3 should have set signet values
	signet := config.NetworkSettings["signet"]
	if signet["addnode"] != "172.105.148.135:38333" {
		t.Errorf("signet addnode = %q, want 172.105.148.135:38333", signet["addnode"])
	}
	if signet["signetblocktime"] != "600" {
		t.Errorf("signet signetblocktime = %q, want 600", signet["signetblocktime"])
	}
	if signet["signetchallenge"] != "a91484fa7c2460891fe5212cb08432e21a4207909aa987" {
		t.Errorf("signet signetchallenge = %q", signet["signetchallenge"])
	}

	// Migration 4 should have set global uacomment
	if config.GlobalSettings["uacomment"] != "BitWindow-0.2" {
		t.Errorf("uacomment = %q, want BitWindow-0.2", config.GlobalSettings["uacomment"])
	}
}

func TestRunBitcoinConfMigrationsSkipsApplied(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = BitcoinConfMigrationsVersion

	migrated := RunBitcoinConfMigrations(config, false)
	if migrated {
		t.Error("should not migrate when already at current version")
	}
}

func TestRunBitcoinConfMigrationsPartial(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 2 // skip migrations 1 and 2

	migrated := RunBitcoinConfMigrations(config, false)
	if !migrated {
		t.Fatal("expected migrations 3+ to run")
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}

	// Migration 3 should have updated signet
	if config.NetworkSettings["signet"]["signetblocktime"] != "600" {
		t.Errorf("signetblocktime = %q, want 600", config.NetworkSettings["signet"]["signetblocktime"])
	}
}

// Existing mainnet/signet/regtest configs that predate migration 5 must get
// rest=1 added to their global settings — the enforcer requires it on every
// network. Regression guard for the bug where mainnet conf shipped without
// rest=1, the enforcer crashed at boot, and the UI lost its enforcer chain
// tip.
func TestRunBitcoinConfMigrationsBackfillsRest(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 4
	// User's existing mainnet conf at the time migration 5 lands.
	config.GlobalSettings["rpcuser"] = "user"
	config.GlobalSettings["rpcpassword"] = "password"
	config.GlobalSettings["server"] = "1"
	config.GlobalSettings["txindex"] = "1"
	config.GlobalSettings["chain"] = "main"

	migrated := RunBitcoinConfMigrations(config, false)
	if !migrated {
		t.Fatal("expected migration 5 to run on a v4 config")
	}
	if got := config.GlobalSettings["rest"]; got != "1" {
		t.Errorf("rest = %q, want 1", got)
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}
}


func TestRunBitcoinConfMigrationsForknetConditional(t *testing.T) {
	// Currently no forknet-specific migration data, but test the mechanism
	config := NewBitcoinConfig()

	// Run as forknet
	RunBitcoinConfMigrations(config, true)
	// Should still apply signet + global migrations
	if config.GlobalSettings["uacomment"] != "BitWindow-0.2" {
		t.Errorf("uacomment = %q, want BitWindow-0.2", config.GlobalSettings["uacomment"])
	}
}

func TestRunForknetConfMigrations(t *testing.T) {
	config := NewForknetConfig()
	migrated := RunForknetConfMigrations(config)

	// Currently no forknet-specific migration data exists, so settings
	// shouldn't change, but version should advance
	if !migrated {
		t.Fatal("expected version to advance")
	}
	if config.Version != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.Version, BitcoinConfMigrationsVersion)
	}
}

func TestRunMainnetConfMigrations(t *testing.T) {
	config := NewMainnetConfig()
	migrated := RunMainnetConfMigrations(config)

	if !migrated {
		t.Fatal("expected version to advance")
	}
	if config.Version != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.Version, BitcoinConfMigrationsVersion)
	}
}

// ---------------------------------------------------------------------------
// Piece 3 tests: Default config version prefix
// ---------------------------------------------------------------------------

func TestGetDefaultConfigHasVersionPrefix(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkSignet}
	conf := m.GetDefaultConfig()

	prefix := fmt.Sprintf("# bitwindow-bitcoin-conf-version=%d", BitcoinConfMigrationsVersion)
	if !strings.HasPrefix(conf, prefix) {
		first := conf
		if len(first) > 80 {
			first = first[:80]
		}
		t.Errorf("default config should start with %q, got %q...", prefix, first)
	}
}

// The mainnet template ships rest=1 — without it the enforcer crashes at
// boot. Regression guard for the bug where mainnet was carved out into a
// "minimal" template that dropped the setting.
func TestGetDefaultConfigMainnetIncludesRest(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkMainnet}
	conf := m.GetDefaultConfig()

	if !strings.Contains(conf, "\nrest=1\n") {
		t.Errorf("mainnet default config must include rest=1, got:\n%s", conf)
	}
}

// ---------------------------------------------------------------------------
// Piece 4 tests: getMainSectionPath + defaults
// ---------------------------------------------------------------------------

func TestGetMainSectionPath(t *testing.T) {
	m := &BitcoinConfManager{BitwindowDir: "/tmp/bw"}

	forknetPath := m.getMainSectionPath(NetworkForknet)
	if !strings.HasSuffix(forknetPath, "bitwindow-forknet.conf") {
		t.Errorf("forknet path = %q", forknetPath)
	}

	mainnetPath := m.getMainSectionPath(NetworkMainnet)
	if !strings.HasSuffix(mainnetPath, "bitwindow-mainnet.conf") {
		t.Errorf("mainnet path = %q", mainnetPath)
	}
}

func TestGetDefaultMainSection(t *testing.T) {
	forknet, forknetOrder := getDefaultMainSection(NetworkForknet)
	if forknet["drivechain"] != "1" {
		t.Error("forknet should have drivechain=1")
	}
	if forknet["rpcport"] != "18301" {
		t.Errorf("forknet rpcport = %q, want 18301", forknet["rpcport"])
	}
	if len(forknetOrder) != len(forknet) {
		t.Errorf("forknet order len %d != settings len %d", len(forknetOrder), len(forknet))
	}

	mainnet, _ := getDefaultMainSection(NetworkMainnet)
	if len(mainnet) != 0 {
		t.Errorf("mainnet defaults should be empty, got %v", mainnet)
	}

	signet, _ := getDefaultMainSection(NetworkSignet)
	if len(signet) != 0 {
		t.Errorf("signet defaults should be empty, got %v", signet)
	}
}

func TestIsMainnetOrForknet(t *testing.T) {
	if !isMainnetOrForknet(NetworkMainnet) {
		t.Error("mainnet should be true")
	}
	if !isMainnetOrForknet(NetworkForknet) {
		t.Error("forknet should be true")
	}
	if isMainnetOrForknet(NetworkSignet) {
		t.Error("signet should be false")
	}
}

// ---------------------------------------------------------------------------
// Piece 5 tests: [main] section save/load
// ---------------------------------------------------------------------------

func TestSaveAndLoadMainSection(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	// Set some [main] settings
	m.Config.NetworkSettings["main"]["port"] = "8300"
	m.Config.NetworkSettings["main"]["drivechain"] = "1"

	// Save for forknet
	if err := m.SaveMainSectionForNetwork(NetworkForknet); err != nil {
		t.Fatal(err)
	}

	// Clear [main] and load back
	m.Config.NetworkSettings["main"] = map[string]string{}
	if err := m.LoadMainSectionForNetwork(NetworkForknet); err != nil {
		t.Fatal(err)
	}

	if m.Config.NetworkSettings["main"]["port"] != "8300" {
		t.Errorf("port = %q, want 8300", m.Config.NetworkSettings["main"]["port"])
	}
	if m.Config.NetworkSettings["main"]["drivechain"] != "1" {
		t.Errorf("drivechain = %q, want 1", m.Config.NetworkSettings["main"]["drivechain"])
	}
}

func TestLoadMainSectionMissingFileUsesDefaults(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	// Load forknet when file doesn't exist
	if err := m.LoadMainSectionForNetwork(NetworkForknet); err != nil {
		t.Fatal(err)
	}

	if m.Config.NetworkSettings["main"]["drivechain"] != "1" {
		t.Error("should use forknet defaults when file missing")
	}
}

func TestSaveMainSectionPreservesVersion(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	// Create a forknet file with version 2
	fc := NewForknetConfig()
	fc.Version = 2
	fc.Settings["port"] = "8300"
	confPath := m.getMainSectionPath(NetworkForknet)
	require.NoError(t, os.MkdirAll(filepath.Dir(confPath), 0755))
	require.NoError(t, os.WriteFile(confPath, []byte(fc.Serialize()), 0644))

	// Save new settings — should preserve version 2
	m.Config.NetworkSettings["main"]["port"] = "9999"
	if err := m.SaveMainSectionForNetwork(NetworkForknet); err != nil {
		t.Fatal(err)
	}

	// Read back and check version
	data, _ := os.ReadFile(confPath)
	parsed := ParseForknetConfig(string(data))
	if parsed.Version != 2 {
		t.Errorf("version = %d, want 2 (should be preserved)", parsed.Version)
	}
	if parsed.Settings["port"] != "9999" {
		t.Errorf("port = %q, want 9999", parsed.Settings["port"])
	}
}

// ---------------------------------------------------------------------------
// Piece 7 tests: Copy config downstream
// ---------------------------------------------------------------------------

func TestCopyConfigDownstream(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	// Override downstream path to temp dir for testing
	m.Network = NetworkSignet

	// Write a master config
	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte("chain=signet\n"), 0644))

	if err := m.CopyConfigDownstream(); err != nil {
		t.Fatal(err)
	}

	destPath := m.getDownstreamConfigPath()
	data, err := os.ReadFile(destPath)
	if err != nil {
		t.Fatalf("downstream file not created: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "READ-ONLY COPY") {
		t.Error("downstream should contain read-only header")
	}
	if !strings.Contains(content, "chain=signet") {
		t.Error("downstream should contain original config content")
	}
}

// ---------------------------------------------------------------------------
// Piece 10 tests: HasDatadirForNetwork
// ---------------------------------------------------------------------------

func TestHasDatadirForNetwork(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	// No file — should be false
	if m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("should be false when file doesn't exist")
	}

	// Non-mainnet/forknet — always true
	if !m.HasDatadirForNetwork(NetworkSignet) {
		t.Error("signet should always return true")
	}

	// Create file with datadir
	fc := NewForknetConfig()
	fc.Settings["datadir"] = "/some/path"
	confPath := m.getMainSectionPath(NetworkForknet)
	require.NoError(t, os.WriteFile(confPath, []byte(fc.Serialize()), 0644))

	if !m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("should be true when datadir is set")
	}

	// Create file without datadir
	fc2 := NewForknetConfig()
	require.NoError(t, os.WriteFile(confPath, []byte(fc2.Serialize()), 0644))

	if m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("should be false when datadir is empty")
	}
}

// ---------------------------------------------------------------------------
// Piece 8 tests: UpdateNetwork with [main] section swap
// ---------------------------------------------------------------------------

func TestUpdateNetworkSwapsMainSections(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	// Start on forknet with forknet-specific [main] settings
	m.Network = NetworkForknet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("drivechain", "1", "main")
	m.Config.NetworkSettings["main"]["port"] = "8300"
	m.Config.NetworkSettings["main"]["rpcport"] = "18301"

	// Write master config so SaveConfig works
	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	// Switch to signet
	if err := m.UpdateNetwork(NetworkSignet); err != nil {
		t.Fatal(err)
	}

	if m.Network != NetworkSignet {
		t.Errorf("network = %s, want signet", m.Network)
	}

	// Forknet [main] settings should have been saved
	forknetPath := m.getMainSectionPath(NetworkForknet)
	data, err := os.ReadFile(forknetPath)
	if err != nil {
		t.Fatal("forknet config should exist after switch away from forknet")
	}
	fc := ParseForknetConfig(string(data))
	if fc.Settings["port"] != "8300" {
		t.Errorf("saved forknet port = %q, want 8300", fc.Settings["port"])
	}

	// Switch back to forknet — should restore [main] settings
	if err := m.UpdateNetwork(NetworkForknet); err != nil {
		t.Fatal(err)
	}

	if m.Config.NetworkSettings["main"]["port"] != "8300" {
		t.Errorf("restored port = %q, want 8300", m.Config.NetworkSettings["main"]["port"])
	}
}

func TestUpdateNetworkCallsCallback(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	// Write master config
	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte("chain=signet\n"), 0644))

	called := false
	m.OnNetworkChanged = func() { called = true }

	if err := m.UpdateNetwork(NetworkRegtest); err != nil {
		t.Fatal(err)
	}

	if !called {
		t.Error("OnNetworkChanged callback should have been called")
	}
}

func TestUpdateNetworkNoCallbackWhenSameNetwork(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkSignet

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte("chain=signet\n"), 0644))

	called := false
	m.OnNetworkChanged = func() { called = true }

	if err := m.UpdateNetwork(NetworkSignet); err != nil {
		t.Fatal(err)
	}

	if called {
		t.Error("OnNetworkChanged should not be called when network unchanged")
	}
}

// ---------------------------------------------------------------------------
// Piece 12 tests: Full LoadConfig
// ---------------------------------------------------------------------------

func TestLoadConfigFromScratch(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	if err := m.LoadConfig(true); err != nil {
		t.Fatal(err)
	}

	// Should have created default config and parsed it
	if m.Config == nil {
		t.Fatal("config should not be nil after load")
	}
	if m.Network != NetworkSignet {
		t.Errorf("network = %s, want signet", m.Network)
	}

	// Config should be at current migration version
	if m.Config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("config version = %d, want %d", m.Config.ConfigVersion, BitcoinConfMigrationsVersion)
	}

	// Forknet config should have been created with migrations
	forknetPath := m.getMainSectionPath(NetworkForknet)
	if _, err := os.Stat(forknetPath); os.IsNotExist(err) {
		t.Error("forknet config should have been created during migration")
	}
}

func TestLoadConfigIdempotent(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	// First load
	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}
	v1 := m.Config.ConfigVersion

	// Second load should be idempotent
	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}

	if m.Config.ConfigVersion != v1 {
		t.Errorf("version changed from %d to %d on reload", v1, m.Config.ConfigVersion)
	}
}

// ---------------------------------------------------------------------------
// Piece 11 tests: File watching
// ---------------------------------------------------------------------------

func TestFileWatchingTriggersReload(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	// Initial load
	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}

	// Start watching
	if err := m.StartWatching(); err != nil {
		t.Fatal(err)
	}
	defer m.StopWatching()

	// Modify the config file externally — write a complete config at current version
	confPath := m.getBitWindowConfigPath()
	newConfig := NewBitcoinConfig()
	newConfig.ConfigVersion = BitcoinConfMigrationsVersion
	newConfig.GlobalSettings["chain"] = "regtest"
	newConfig.GlobalSettings["uacomment"] = "BitWindow-0.2"
	if err := os.WriteFile(confPath, []byte(newConfig.Serialize()), 0644); err != nil {
		t.Fatal(err)
	}

	// Wait for debounce + reload
	time.Sleep(300 * time.Millisecond)

	if m.Network != NetworkRegtest {
		t.Errorf("network = %s, want regtest (should have reloaded)", m.Network)
	}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func newTestManager(tmpDir string) *BitcoinConfManager {
	log := zerolog.Nop()
	return &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		Config:       NewBitcoinConfig(),
		log:          log,
	}
}
