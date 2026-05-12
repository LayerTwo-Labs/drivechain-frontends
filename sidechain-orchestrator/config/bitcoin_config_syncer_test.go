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
// Migration system
// ---------------------------------------------------------------------------

func TestRunBitcoinConfMigrationsFresh(t *testing.T) {
	config := NewBitcoinConfig()
	migrated := RunBitcoinConfMigrations(config)

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

	migrated := RunBitcoinConfMigrations(config)
	if migrated {
		t.Error("should not migrate when already at current version")
	}
}

func TestRunBitcoinConfMigrationsPartial(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 2 // skip migrations 1 and 2

	migrated := RunBitcoinConfMigrations(config)
	if !migrated {
		t.Fatal("expected migrations 3+ to run")
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}

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
	config.GlobalSettings["rpcuser"] = "user"
	config.GlobalSettings["rpcpassword"] = "password"
	config.GlobalSettings["server"] = "1"
	config.GlobalSettings["txindex"] = "1"
	config.GlobalSettings["chain"] = "main"

	migrated := RunBitcoinConfMigrations(config)
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

// ---------------------------------------------------------------------------
// Default config
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

// Mainnet runs the enforcer too, so it must ship the same enforcer-required
// settings (zmqpubsequence) and perf knobs (rpcthreads, rpcworkqueue) as
// signet/forknet. Regression guard for the unify-template change.
func TestGetDefaultConfigMainnetMatchesEnforcerExpectations(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkMainnet}
	conf := m.GetDefaultConfig()

	required := []string{
		"\nzmqpubsequence=tcp://127.0.0.1:29000\n",
		"\nrpcthreads=10\n",
		"\nrpcworkqueue=50\n",
		"\nuacomment=BitWindow-0.2\n",
	}
	for _, line := range required {
		if !strings.Contains(conf, line) {
			t.Errorf("mainnet default config missing %q, got:\n%s", strings.TrimSpace(line), conf)
		}
	}
}

// Bitcoin Core rejects a non-zero fallbackfee on real mainnet. The setting
// can still appear in [signet]/[test]/[regtest] sections (bitcoind only
// applies the matching section), but must NOT be in the global block or
// [main] section.
func TestGetDefaultConfigFallbackfeeNotOnMainnet(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkMainnet}
	conf := m.GetDefaultConfig()

	headerIdx := strings.Index(conf, "\n[")
	globalBlock := conf
	rest := ""
	if headerIdx >= 0 {
		globalBlock = conf[:headerIdx]
		rest = conf[headerIdx:]
	}
	if strings.Contains(globalBlock, "fallbackfee=") {
		t.Errorf("mainnet global block must not include fallbackfee, got:\n%s", globalBlock)
	}

	if mainIdx := strings.Index(rest, "\n[main]"); mainIdx >= 0 {
		mainBlock := rest[mainIdx:]
		if next := strings.Index(mainBlock[1:], "\n["); next >= 0 {
			mainBlock = mainBlock[:next+1]
		}
		if strings.Contains(mainBlock, "fallbackfee=") {
			t.Errorf("mainnet [main] section must not include fallbackfee, got:\n%s", mainBlock)
		}
	}
}

func TestGetDefaultConfigForknetKeepsFallbackfee(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkForknet}
	conf := m.GetDefaultConfig()
	if !strings.Contains(conf, "fallbackfee=0.00021") {
		t.Errorf("forknet default config must include fallbackfee, got:\n%s", conf)
	}
	if !strings.Contains(conf, "drivechain=1") {
		t.Errorf("forknet default config must include drivechain=1, got:\n%s", conf)
	}
}

// ---------------------------------------------------------------------------
// Copy config downstream
// ---------------------------------------------------------------------------

func TestCopyConfigDownstream(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkSignet

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
// HasDatadirForNetwork
// ---------------------------------------------------------------------------

func TestHasDatadirForNetwork(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Config = NewBitcoinConfig()

	// No datadir anywhere — mainnet/forknet should be false
	if m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("forknet should be false when slot is empty")
	}
	if m.HasDatadirForNetwork(NetworkMainnet) {
		t.Error("mainnet should be false when slot/datadir is empty")
	}

	// Non-mainnet/forknet — always true (signet/test/regtest use bitcoind defaults).
	if !m.HasDatadirForNetwork(NetworkSignet) {
		t.Error("signet should always return true")
	}

	// Forknet only honours its own slot, not the live datadir or default slot.
	m.Config.SetSetting("datadir", "/some/path")
	m.Config.SetGroupDatadir(DatadirGroupDefault, "/some/path")
	if m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("forknet should ignore default-group datadir")
	}
	m.Config.SetGroupDatadir(DatadirGroupForknet, "/forknet/path")
	if !m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("forknet should be true when forknet slot is set")
	}

	// Mainnet accepts either the default slot or a top-level datadir= line
	// (so a hand-edited or pre-slot conf isn't rejected at boot).
	m2 := newTestManager(tmpDir)
	m2.Config = NewBitcoinConfig()
	m2.Config.SetSetting("datadir", "/raw/path")
	if !m2.HasDatadirForNetwork(NetworkMainnet) {
		t.Error("mainnet should accept top-level datadir without slot")
	}

	// Section-scoped datadir is ignored — Bitcoin Core only honours the
	// top-level value.
	m3 := newTestManager(tmpDir)
	m3.Config = NewBitcoinConfig()
	m3.Config.SetSetting("datadir", "/section/only", "main")
	if m3.HasDatadirForNetwork(NetworkMainnet) {
		t.Error("section-scoped datadir must not satisfy HasDatadirForNetwork")
	}
}

// Regression: UpdateDataDir writes datadir to the global section (Bitcoin
// Core only honours top-level datadir), so loadStateFromConfig must read
// the global value too. Reading only [main] left DetectedDataDir empty
// after reload, which made DataDirGuard re-prompt and reject the resulting
// navigation — symptom: blank white screen on mainnet boot.
func TestDetectedDataDirSurvivesReloadAfterUpdate(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	chosen := filepath.Join(tmpDir, "blocks")
	require.NoError(t, m.UpdateDataDir(chosen, NetworkMainnet))
	require.Equal(t, chosen, m.DetectedDataDir, "datadir must be visible immediately after UpdateDataDir")

	m2 := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkMainnet,
		log:          zerolog.Nop(),
	}
	require.NoError(t, m2.LoadConfig(true))
	require.Equal(t, chosen, m2.DetectedDataDir, "datadir written to global must be detected after reload")
}

// Per-section datadir still wins when present — covers users with their own
// bitcoin.conf that scopes datadir under [main].
func TestDetectedDataDirPrefersPerNetworkSection(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", "/global/path")
	m.Config.SetSetting("datadir", "/main/path", "main")

	m.loadStateFromConfig()

	require.Equal(t, NetworkMainnet, m.Network)
	require.Equal(t, "/main/path", m.DetectedDataDir)
}

// ---------------------------------------------------------------------------
// UpdateDataDir + materialize/snapshot semantics
// ---------------------------------------------------------------------------

// UpdateDataDir for the inactive group must NOT touch the active datadir=
// line — only the slot is recorded.
func TestUpdateDataDirInactiveGroupLeavesActiveAlone(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkForknet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("drivechain", "1", "main")
	m.Config.SetSetting("datadir", "/forknet/live")
	m.Config.SetGroupDatadir(DatadirGroupForknet, "/forknet/live")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	require.NoError(t, m.UpdateDataDir("/picked/for/mainnet", NetworkMainnet))

	require.Equal(t, "/picked/for/mainnet", m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/forknet/live", m.Config.GetSetting("datadir"), "active datadir must not change when setting inactive group")
}

// UpdateDataDir for the active group must update both the slot AND the live
// datadir= line so bitcoind sees the new path.
func TestUpdateDataDirActiveGroupUpdatesLive(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	require.NoError(t, m.UpdateDataDir("/picked/for/mainnet", NetworkMainnet))

	require.Equal(t, "/picked/for/mainnet", m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/picked/for/mainnet", m.Config.GetSetting("datadir"))
}

// Manual edit: rewrite datadir= directly on disk, reload, swap to forknet —
// default slot must reflect the manual value (snapshot adopts the live edit).
func TestSwapAdoptsManuallyEditedDatadirIntoSlot(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", "/manually/edited")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	// Pre-stage forknet path so the swap is allowed.
	m.Config.SetGroupDatadir(DatadirGroupForknet, "/forknet/path")
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))
	require.NoError(t, m.LoadConfig(false))

	require.NoError(t, m.UpdateNetwork(NetworkForknet))

	require.Equal(t, "/manually/edited", m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/forknet/path", m.Config.GetSetting("datadir"))
}

// Within-group swap (mainnet ↔ signet) leaves datadir= alone and writes no
// slot — Bitcoin Core's chain subdirs partition the four default networks
// under the same folder.
func TestUpdateNetworkWithinDefaultGroupKeepsDatadir(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", "/shared/default")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	require.NoError(t, m.UpdateNetwork(NetworkSignet))

	require.Equal(t, "/shared/default", m.Config.GetSetting("datadir"))
	require.Equal(t, "", m.Config.GetGroupDatadir(DatadirGroupDefault), "no slot writes happen on within-group swap")
	require.Equal(t, "", m.Config.GetGroupDatadir(DatadirGroupForknet))
}

// applyMainSectionDefaults: signet → forknet adds drivechain=1 + alt ports
// under [main]; forknet → mainnet strips them.
func TestApplyMainSectionDefaultsForknetThenMainnet(t *testing.T) {
	m := &BitcoinConfManager{Config: NewBitcoinConfig(), log: zerolog.Nop()}
	m.Config.SetSetting("chain", "signet")

	m.applyMainSectionDefaults(NetworkForknet)
	require.Equal(t, "1", m.Config.GetSetting("drivechain", "main"))
	require.Equal(t, "8300", m.Config.GetSetting("port", "main"))
	require.Equal(t, "18301", m.Config.GetSetting("rpcport", "main"))
	require.Equal(t, "0.00021", m.Config.GetSetting("fallbackfee", "main"))

	m.applyMainSectionDefaults(NetworkMainnet)
	require.Equal(t, "", m.Config.GetSetting("drivechain", "main"))
	require.Equal(t, "", m.Config.GetSetting("port", "main"))
	require.Equal(t, "", m.Config.GetSetting("rpcport", "main"))
	require.Equal(t, "", m.Config.GetSetting("fallbackfee", "main"))
}

// ---------------------------------------------------------------------------
// UpdateNetwork
// ---------------------------------------------------------------------------

func TestUpdateNetworkCallsCallback(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

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
// Full LoadConfig
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

	if m.Config == nil {
		t.Fatal("config should not be nil after load")
	}
	if m.Network != NetworkSignet {
		t.Errorf("network = %s, want signet", m.Network)
	}

	if m.Config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("config version = %d, want %d", m.Config.ConfigVersion, BitcoinConfMigrationsVersion)
	}
}

func TestLoadConfigIdempotent(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}
	v1 := m.Config.ConfigVersion

	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}

	if m.Config.ConfigVersion != v1 {
		t.Errorf("version changed from %d to %d on reload", v1, m.Config.ConfigVersion)
	}
}

// ---------------------------------------------------------------------------
// File watching
// ---------------------------------------------------------------------------

func TestFileWatchingTriggersReload(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}

	if err := m.StartWatching(); err != nil {
		t.Fatal(err)
	}
	defer m.StopWatching()

	confPath := m.getBitWindowConfigPath()
	newConfig := NewBitcoinConfig()
	newConfig.ConfigVersion = BitcoinConfMigrationsVersion
	newConfig.GlobalSettings["chain"] = "regtest"
	newConfig.GlobalSettings["uacomment"] = "BitWindow-0.2"
	if err := os.WriteFile(confPath, []byte(newConfig.Serialize()), 0644); err != nil {
		t.Fatal(err)
	}

	time.Sleep(300 * time.Millisecond)

	if m.Network != NetworkRegtest {
		t.Errorf("network = %s, want regtest (should have reloaded)", m.Network)
	}
}

// ---------------------------------------------------------------------------
// Datadir slot accessors + round-trip
// ---------------------------------------------------------------------------

func TestDatadirSlotsRoundTrip(t *testing.T) {
	src := `# bitwindow-bitcoin-conf-version=8

# bitwindow-datadir-default=/Volumes/SSD/bitcoin
# bitwindow-datadir-forknet=/Volumes/HDD/forknet

datadir=/Volumes/SSD/bitcoin
chain=signet
`
	c := ParseBitcoinConfig(src)
	require.Equal(t, "/Volumes/SSD/bitcoin", c.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/Volumes/HDD/forknet", c.GetGroupDatadir(DatadirGroupForknet))

	c.SetGroupDatadir(DatadirGroupForknet, "/new/forknet/path")

	out := c.Serialize()
	require.Contains(t, out, "# bitwindow-datadir-default=/Volumes/SSD/bitcoin\n")
	require.Contains(t, out, "# bitwindow-datadir-forknet=/new/forknet/path\n")

	// Stable order: default before forknet
	defIdx := strings.Index(out, "# bitwindow-datadir-default=")
	fkIdx := strings.Index(out, "# bitwindow-datadir-forknet=")
	require.Greater(t, fkIdx, defIdx, "default slot should serialize before forknet slot")

	// Re-parse, values stable
	c2 := ParseBitcoinConfig(out)
	require.Equal(t, "/Volumes/SSD/bitcoin", c2.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/new/forknet/path", c2.GetGroupDatadir(DatadirGroupForknet))
}

func TestDatadirSlotsClearedOnEmpty(t *testing.T) {
	c := NewBitcoinConfig()
	c.SetGroupDatadir(DatadirGroupForknet, "/some/path")
	require.Equal(t, "/some/path", c.GetGroupDatadir(DatadirGroupForknet))
	c.SetGroupDatadir(DatadirGroupForknet, "")
	require.Equal(t, "", c.GetGroupDatadir(DatadirGroupForknet))

	out := c.Serialize()
	require.NotContains(t, out, "# bitwindow-datadir-forknet=")
}

func TestDatadirGroupForNetwork(t *testing.T) {
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkMainnet))
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkSignet))
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkTestnet))
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkRegtest))
	require.Equal(t, DatadirGroupForknet, DatadirGroupForNetwork(NetworkForknet))
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
