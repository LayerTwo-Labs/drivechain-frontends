package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"
)

// ---------------------------------------------------------------------------
// Piece 1: ForknetConfig + MainnetConfig types
// ---------------------------------------------------------------------------

const kForknetConfVersionCommentPrefix = "# bitwindow-forknet-conf-version="
const kMainnetConfVersionCommentPrefix = "# bitwindow-mainnet-conf-version="

// ForknetConfig stores [main] section settings when network is forknet.
// Stored in bitwindow-forknet.conf alongside the master bitcoin config.
//
// Order matters: Set/Parse track insertion order so Serialize emits keys in
// the same order they appeared on disk.
type ForknetConfig struct {
	Settings map[string]string
	Order    []string
	Version  int
}

func NewForknetConfig() *ForknetConfig {
	return &ForknetConfig{
		Settings: make(map[string]string),
	}
}

func (c *ForknetConfig) Set(key, value string) {
	if _, exists := c.Settings[key]; !exists {
		c.Order = append(c.Order, key)
	}
	c.Settings[key] = value
}

func (c *ForknetConfig) Delete(key string) {
	delete(c.Settings, key)
	c.Order = removeFromOrder(c.Order, key)
}

func ParseForknetConfig(content string) *ForknetConfig {
	c := NewForknetConfig()
	for _, line := range strings.Split(content, "\n") {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, kForknetConfVersionCommentPrefix) {
			vStr := strings.TrimSpace(trimmed[len(kForknetConfVersionCommentPrefix):])
			if v, err := strconv.Atoi(vStr); err == nil {
				c.Version = v
			}
			continue
		}
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		if eqIdx := strings.Index(trimmed, "="); eqIdx > 0 {
			key := strings.TrimSpace(trimmed[:eqIdx])
			value := strings.TrimSpace(trimmed[eqIdx+1:])
			c.Set(key, value)
		}
	}
	return c
}

func (c *ForknetConfig) Serialize() string {
	var b strings.Builder
	fmt.Fprintf(&b, "%s%d\n", kForknetConfVersionCommentPrefix, c.Version)
	for _, key := range orderedKeys(c.Order, c.Settings) {
		fmt.Fprintf(&b, "%s=%s\n", key, c.Settings[key])
	}
	return b.String()
}

// MainnetConfig stores [main] section settings when network is mainnet.
// Stored in bitwindow-mainnet.conf alongside the master bitcoin config.
type MainnetConfig struct {
	Settings map[string]string
	Order    []string
	Version  int
}

func NewMainnetConfig() *MainnetConfig {
	return &MainnetConfig{
		Settings: make(map[string]string),
	}
}

func (c *MainnetConfig) Set(key, value string) {
	if _, exists := c.Settings[key]; !exists {
		c.Order = append(c.Order, key)
	}
	c.Settings[key] = value
}

func (c *MainnetConfig) Delete(key string) {
	delete(c.Settings, key)
	c.Order = removeFromOrder(c.Order, key)
}

func ParseMainnetConfig(content string) *MainnetConfig {
	c := NewMainnetConfig()
	for _, line := range strings.Split(content, "\n") {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, kMainnetConfVersionCommentPrefix) {
			vStr := strings.TrimSpace(trimmed[len(kMainnetConfVersionCommentPrefix):])
			if v, err := strconv.Atoi(vStr); err == nil {
				c.Version = v
			}
			continue
		}
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		if eqIdx := strings.Index(trimmed, "="); eqIdx > 0 {
			key := strings.TrimSpace(trimmed[:eqIdx])
			value := strings.TrimSpace(trimmed[eqIdx+1:])
			c.Set(key, value)
		}
	}
	return c
}

func (c *MainnetConfig) Serialize() string {
	var b strings.Builder
	fmt.Fprintf(&b, "%s%d\n", kMainnetConfVersionCommentPrefix, c.Version)
	for _, key := range orderedKeys(c.Order, c.Settings) {
		fmt.Fprintf(&b, "%s=%s\n", key, c.Settings[key])
	}
	return b.String()
}

// orderedKeys returns keys from settings using the tracked order, with any
// stray keys (set via direct map writes) appended at the end.
func orderedKeys(order []string, settings map[string]string) []string {
	seen := make(map[string]struct{}, len(order))
	out := make([]string, 0, len(settings))
	for _, k := range order {
		if _, ok := settings[k]; ok {
			out = append(out, k)
			seen[k] = struct{}{}
		}
	}
	for k := range settings {
		if _, ok := seen[k]; !ok {
			out = append(out, k)
		}
	}
	return out
}

// ---------------------------------------------------------------------------
// Piece 2: Migration system + 4 migrations
// ---------------------------------------------------------------------------

// BitcoinConfMigration represents a versioned config migration.
// Changes maps section name → key → value.
// Special section "forknet" applies to [main] when on forknet.
// Special section "mainnet" applies to [main] when on mainnet.
// Empty string "" means global (no section).
type BitcoinConfMigration struct {
	Version int
	Changes map[string]map[string]string
}

var bitcoinConfMigrations = []BitcoinConfMigration{
	{
		Version: 1,
		Changes: map[string]map[string]string{
			"signet": {
				"addnode":         "172.105.148.135:38343",
				"signetblocktime": "600",
				"signetchallenge": "a91484fa7c2460891fe5212cb08432e21a4207909aa987",
			},
		},
	},
	{
		Version: 2,
		Changes: map[string]map[string]string{
			"signet": {
				"addnode":         "172.105.148.135:38333",
				"signetblocktime": "60",
				"signetchallenge": "00141551188e5153533b4fdd555449e640d9cc129456",
				"acceptnonstdtxn": "1",
			},
		},
	},
	{
		Version: 3,
		Changes: map[string]map[string]string{
			"signet": {
				"addnode":         "172.105.148.135:38333",
				"signetblocktime": "600",
				"signetchallenge": "a91484fa7c2460891fe5212cb08432e21a4207909aa987",
			},
		},
	},
	{
		Version: 4,
		Changes: map[string]map[string]string{
			"": {
				"uacomment": "BitWindow-0.2",
			},
		},
	},
	{
		// Mainnet support shipped with a "minimal" mainnet template that
		// dropped rest=1. The enforcer requires REST on every network, so
		// without this the enforcer dies at boot. Backfill it for existing
		// configs that predate the fixed default.
		Version: 5,
		Changes: map[string]map[string]string{
			"": {
				"rest": "1",
			},
		},
	},
	{
		// The mainnet template also dropped zmqpubsequence. Without it the
		// enforcer dies at boot with "ZMQ address for mempool sync is not
		// reachable" and the L1 stack never comes up. Backfill globally
		// (the line is harmless on signet/forknet, where the same value is
		// already in the default template).
		Version: 6,
		Changes: map[string]map[string]string{
			"": {
				"zmqpubsequence": "tcp://127.0.0.1:29000",
			},
		},
	},
	{
		// Mainnet now runs the enforcer too, so it should get the same
		// throughput knobs as the signet/forknet defaults. Without these
		// the enforcer's burst of RPC calls during sync can starve other
		// callers on a 4-thread default RPC pool.
		Version: 7,
		Changes: map[string]map[string]string{
			"": {
				"rpcthreads":   "20",
				"rpcworkqueue": "100",
			},
		},
	},
	{
		// bitwindowd's ZMQ engine requires pubrawtx (and the others) to
		// stream tx/block notifications. Previously these only lived in
		// forknet's [main] section, which left signet/testnet/mainnet
		// users with "unable to acquire ZMQ engine" loops and a
		// degraded daemon link. Move them globally — Bitcoin Core happily
		// accepts the same zmqpub* lines on every network, and the
		// per-forknet copies were just duplication.
		Version: 8,
		Changes: map[string]map[string]string{
			"": {
				"zmqpubhashblock": "tcp://127.0.0.1:29001",
				"zmqpubhashtx":    "tcp://127.0.0.1:29002",
				"zmqpubrawblock":  "tcp://127.0.0.1:29003",
				"zmqpubrawtx":     "tcp://127.0.0.1:29004",
			},
		},
	},
}

// BitcoinConfMigrationsVersion is the highest migration version.
var BitcoinConfMigrationsVersion = 8

// RunBitcoinConfMigrations applies pending migrations to a BitcoinConfig.
// isForknet controls whether "forknet" or "mainnet" section data applies to [main].
// Returns true if any migration was applied.
func RunBitcoinConfMigrations(config *BitcoinConfig, isForknet bool) bool {
	migrated := false
	for _, m := range bitcoinConfMigrations {
		if m.Version <= config.ConfigVersion {
			continue
		}
		for section, settings := range m.Changes {
			targetSection := section

			if section == "forknet" {
				if !isForknet {
					continue
				}
				targetSection = "main"
			}
			if section == "mainnet" {
				if isForknet {
					continue
				}
				targetSection = "main"
			}

			for key, value := range settings {
				config.SetSetting(key, value, targetSection)
			}
		}
		config.ConfigVersion = m.Version
		migrated = true
	}
	return migrated
}

// RunForknetConfMigrations applies forknet-specific migration data to a ForknetConfig.
func RunForknetConfMigrations(config *ForknetConfig) bool {
	migrated := false
	for _, m := range bitcoinConfMigrations {
		if m.Version <= config.Version {
			continue
		}
		if forknetChanges, ok := m.Changes["forknet"]; ok {
			for key, value := range forknetChanges {
				config.Set(key, value)
			}
		}
		config.Version = m.Version
		migrated = true
	}
	return migrated
}

// RunMainnetConfMigrations applies mainnet-specific migration data to a MainnetConfig.
func RunMainnetConfMigrations(config *MainnetConfig) bool {
	migrated := false
	for _, m := range bitcoinConfMigrations {
		if m.Version <= config.Version {
			continue
		}
		if mainnetChanges, ok := m.Changes["mainnet"]; ok {
			for key, value := range mainnetChanges {
				config.Set(key, value)
			}
		}
		config.Version = m.Version
		migrated = true
	}
	return migrated
}

// ---------------------------------------------------------------------------
// 1:1 ports from frontend_bitcoin_conf_provider.dart
// ---------------------------------------------------------------------------

// parseAndApplyConfig parses config content and updates state (network, datadir).
// Dart: _parseAndApplyConfig (L244)
func (m *BitcoinConfManager) parseAndApplyConfig(content string) {
	m.Config = ParseBitcoinConfig(content)
	m.loadStateFromConfig()
}

// tryLoadPrivateConfig checks for user's private bitcoin.conf and loads if exists.
// Returns true if private config was loaded.
// Dart: _tryLoadPrivateConfig (L251)
func (m *BitcoinConfManager) tryLoadPrivateConfig() bool {
	confInfo := m.getConfigFileInfo()
	m.HasPrivateConf = confInfo.hasPrivateConf
	m.ConfigPath = confInfo.path

	if !m.HasPrivateConf {
		return false
	}

	privateContent, err := os.ReadFile(confInfo.path)
	if err != nil {
		return false
	}

	m.parseAndApplyConfig(string(privateContent))
	return true
}

// handleNetworkChangeIfNeeded handles network change: refresh derived state
// + restart services. We deliberately don't restore master's [main] from a
// per-network backup file anymore — that mechanism kept silently wiping
// user-set keys (notably datadir) whenever the backup happened to lack
// them. Master's [main] is now the single source of truth and survives
// network swaps as-is. Bitcoin Core ignores [main] when chain != main, so
// stale forknet keys leaking into master while on signet are harmless.
func (m *BitcoinConfManager) handleNetworkChangeIfNeeded(oldNetwork Network, isFirst bool) {
	networkChanged := !isFirst && oldNetwork != m.Network
	if !networkChanged {
		return
	}

	m.loadStateFromConfig()

	if m.OnNetworkChanged != nil {
		m.OnNetworkChanged()
	}
}

// loadStateFromConfig loads network and datadir state from currentConfig.
// Dart: _loadStateFromConfig (L595)
//
// DetectedDataDir reads only the per-network section (no global fallback) so
// "user has explicitly chosen one" is the same question as "is this empty?".
// The DataDirGuard / swap prompt rely on that. The global default still
// reaches bitcoind via the on-disk conf file — this is purely a UI signal.
func (m *BitcoinConfManager) loadStateFromConfig() {
	if m.Config == nil {
		return
	}

	m.Network = NetworkFromConfig(m.Config)
	m.DetectedDataDir = m.Config.GetSetting("datadir", CoreSectionForNetwork(m.Network))

	// Ensure datadir exists — Bitcoin Core fails with a cryptic assertion error (exit code -6) if it doesn't
	if m.DetectedDataDir != "" {
		_ = os.MkdirAll(m.DetectedDataDir, 0755)
	}
}

// writeConfigFile writes config to file without triggering LoadConfig.
// Dart: _writeConfigFile (L490)
func (m *BitcoinConfManager) writeConfigFile() error {
	if m.Config == nil {
		return nil
	}
	if m.HasPrivateConf {
		return nil
	}

	confInfo := m.getConfigFileInfo()
	if err := os.MkdirAll(filepath.Dir(confInfo.path), 0755); err != nil {
		return fmt.Errorf("create dir: %w", err)
	}
	if err := os.WriteFile(confInfo.path, []byte(m.Config.Serialize()), 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}
	m.log.Debug().Str("path", confInfo.path).Msg("wrote config file")
	return nil
}

// saveConfig writes config to disk and reloads. The per-network [main]
// backup (formerly written here when not switching networks) was removed
// — see handleNetworkChangeIfNeeded for the rationale.
func (m *BitcoinConfManager) saveConfig() error {
	if m.Config == nil {
		return nil
	}
	if m.HasPrivateConf {
		m.log.Warn().Msg("cannot save - user bitcoin.conf takes precedence")
		return nil
	}

	if err := m.writeConfigFile(); err != nil {
		return err
	}

	return m.LoadConfig(false)
}

// GetCurrentConfigContent returns the current configuration content as string.
// Dart: getCurrentConfigContent (L747)
func (m *BitcoinConfManager) GetCurrentConfigContent() string {
	if m.Config == nil {
		return m.GetDefaultConfig()
	}
	return m.Config.Serialize()
}

// WriteConfig writes raw configuration content to the appropriate file.
// Dart: writeConfig (L756)
func (m *BitcoinConfManager) WriteConfig(content string) error {
	if m.HasPrivateConf {
		m.log.Warn().Msg("cannot write config - user bitcoin.conf takes precedence")
		return nil
	}

	confInfo := m.getConfigFileInfo()
	if err := os.MkdirAll(filepath.Dir(confInfo.path), 0755); err != nil {
		return fmt.Errorf("create dir: %w", err)
	}
	if err := os.WriteFile(confInfo.path, []byte(content), 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}
	m.log.Info().Str("path", confInfo.path).Msg("saved config")
	return nil
}

// SwapNetwork checks datadir availability before switching networks.
// Dart: swapNetwork (L356) — UI parts (router.push) skipped.
func (m *BitcoinConfManager) SwapNetwork(newNetwork Network) error {
	if m.HasPrivateConf {
		m.log.Warn().Msg("cannot swap network - controlled by user bitcoin.conf")
		return nil
	}
	if m.Network == newNetwork {
		return nil
	}

	// Check if the new network requires a datadir that isn't configured yet
	if isMainnetOrForknet(newNetwork) {
		if !m.HasDatadirForNetwork(newNetwork) {
			// In Go backend, we can't show a UI dialog.
			// Return an error so the RPC handler can communicate this to the frontend.
			return fmt.Errorf("datadir not configured for %s", newNetwork)
		}
	}

	return m.UpdateNetwork(newNetwork)
}

// CommitNetworkChange commits a pending network change.
// Dart: commitNetworkChange (L411)
func (m *BitcoinConfManager) CommitNetworkChange(newNetwork Network) error {
	if m.HasPrivateConf {
		m.log.Warn().Msg("cannot commit network change - controlled by user bitcoin.conf")
		return nil
	}
	if m.Network == newNetwork {
		return nil
	}
	return m.UpdateNetwork(newNetwork)
}

// ---------------------------------------------------------------------------
// Piece 4: getMainSectionPath + default [main] sections + helpers
// ---------------------------------------------------------------------------

func isMainnetOrForknet(n Network) bool {
	return n == NetworkMainnet || n == NetworkForknet
}

// getMainSectionPath returns the path to the per-network [main] section backup file.
func (m *BitcoinConfManager) getMainSectionPath(n Network) string {
	name := "bitwindow-mainnet.conf"
	if n == NetworkForknet {
		name = "bitwindow-forknet.conf"
	}
	return filepath.Join(m.BitwindowDir, name)
}

// getDefaultMainSection returns the default [main] section settings for a
// network, plus a stable key order so Serialize emits keys in a predictable
// sequence on first creation.
func getDefaultMainSection(n Network) (map[string]string, []string) {
	if n == NetworkForknet {
		order := []string{
			"port",
			"rpcport",
			"rpcbind",
			"rpcallowip",
			"zmqpubhashblock",
			"zmqpubhashtx",
			"zmqpubrawblock",
			"zmqpubrawtx",
			"assumevalid",
			"minimumchainwork",
			"listenonion",
			"drivechain",
			"fallbackfee",
		}
		settings := map[string]string{
			"port":             "8300",
			"rpcport":          "18301",
			"rpcbind":          "127.0.0.1",
			"rpcallowip":       "0.0.0.0/0",
			"zmqpubhashblock":  "tcp://127.0.0.1:29001",
			"zmqpubhashtx":     "tcp://127.0.0.1:29002",
			"zmqpubrawblock":   "tcp://127.0.0.1:29003",
			"zmqpubrawtx":      "tcp://127.0.0.1:29004",
			"assumevalid":      "0000000000000000000000000000000000000000000000000000000000000000",
			"minimumchainwork": "0x00",
			"listenonion":      "0",
			"drivechain":       "1",
			"fallbackfee":      "0.00021",
		}
		return settings, order
	}
	return map[string]string{}, nil
}

// ---------------------------------------------------------------------------
// Piece 5: [main] section save/load per-network
// ---------------------------------------------------------------------------

// SaveMainSectionForNetwork saves the current [main] section to the per-network backup file.
// Preserves the existing version in the file if it exists.
func (m *BitcoinConfManager) SaveMainSectionForNetwork(n Network) error {
	if m.Config == nil || !isMainnetOrForknet(n) {
		return nil
	}

	confPath := m.getMainSectionPath(n)
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return fmt.Errorf("create dir: %w", err)
	}

	mainSettings := m.Config.NetworkSettings["main"]
	mainOrder := m.Config.NetworkOrder["main"]

	if n == NetworkForknet {
		fc := NewForknetConfig()
		fc.Version = BitcoinConfMigrationsVersion

		// Preserve existing version if file exists
		if data, err := os.ReadFile(confPath); err == nil {
			fc.Version = ParseForknetConfig(string(data)).Version
		}

		for _, k := range orderedKeys(mainOrder, mainSettings) {
			fc.Set(k, mainSettings[k])
		}
		return os.WriteFile(confPath, []byte(fc.Serialize()), 0644)
	}

	// Mainnet
	mc := NewMainnetConfig()
	mc.Version = BitcoinConfMigrationsVersion

	if data, err := os.ReadFile(confPath); err == nil {
		mc.Version = ParseMainnetConfig(string(data)).Version
	}

	for _, k := range orderedKeys(mainOrder, mainSettings) {
		mc.Set(k, mainSettings[k])
	}
	return os.WriteFile(confPath, []byte(mc.Serialize()), 0644)
}

// LoadMainSectionForNetwork loads the [main] section from the per-network backup file.
// If the file doesn't exist, applies default settings for the network.
//
// An empty backup file (just the version comment, no settings) does NOT clobber
// master's [main] — that path used to wipe a freshly-set datadir on the next
// network swap because the backup had been auto-created at v7 with zero
// settings. Treat empty-but-present the same as missing.
func (m *BitcoinConfManager) LoadMainSectionForNetwork(n Network) error {
	if m.Config == nil || !isMainnetOrForknet(n) {
		return nil
	}

	confPath := m.getMainSectionPath(n)
	data, err := os.ReadFile(confPath)
	if err != nil {
		if os.IsNotExist(err) {
			m.log.Info().Str("network", string(n)).Msg("no saved [main] section, using defaults")
			settings, order := getDefaultMainSection(n)
			m.Config.ReplaceSection("main", settings, order)
			return nil
		}
		return fmt.Errorf("read main section: %w", err)
	}

	if n == NetworkForknet {
		fc := ParseForknetConfig(string(data))
		if len(fc.Settings) == 0 {
			m.log.Info().Str("network", string(n)).Str("path", confPath).Msg("empty [main] backup; keeping master's [main]")
			return nil
		}
		newMain := make(map[string]string, len(fc.Settings))
		for k, v := range fc.Settings {
			newMain[k] = v
		}
		m.Config.ReplaceSection("main", newMain, append([]string(nil), fc.Order...))
	} else {
		mc := ParseMainnetConfig(string(data))
		if len(mc.Settings) == 0 {
			m.log.Info().Str("network", string(n)).Str("path", confPath).Msg("empty [main] backup; keeping master's [main]")
			return nil
		}
		newMain := make(map[string]string, len(mc.Settings))
		for k, v := range mc.Settings {
			newMain[k] = v
		}
		m.Config.ReplaceSection("main", newMain, append([]string(nil), mc.Order...))
	}

	m.log.Info().Str("network", string(n)).Str("path", confPath).Msg("loaded [main] section")
	return nil
}

// ---------------------------------------------------------------------------
// Piece 6: Migrate forknet/mainnet configs on load
// ---------------------------------------------------------------------------

// migrateForknetConfig loads/creates bitwindow-forknet.conf and runs migrations.
func (m *BitcoinConfManager) migrateForknetConfig() error {
	confPath := m.getMainSectionPath(NetworkForknet)

	var fc *ForknetConfig
	if data, err := os.ReadFile(confPath); err == nil {
		fc = ParseForknetConfig(string(data))
	} else {
		fc = NewForknetConfig()
		settings, order := getDefaultMainSection(NetworkForknet)
		for _, k := range orderedKeys(order, settings) {
			fc.Set(k, settings[k])
		}
	}

	if RunForknetConfMigrations(fc) {
		if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
			return err
		}
		if err := os.WriteFile(confPath, []byte(fc.Serialize()), 0644); err != nil {
			return err
		}
		m.log.Info().Int("version", fc.Version).Msg("migrated bitwindow-forknet.conf")
	}
	return nil
}

// migrateMainnetConfig loads/creates bitwindow-mainnet.conf and runs migrations.
func (m *BitcoinConfManager) migrateMainnetConfig() error {
	confPath := m.getMainSectionPath(NetworkMainnet)

	var mc *MainnetConfig
	if data, err := os.ReadFile(confPath); err == nil {
		mc = ParseMainnetConfig(string(data))
	} else {
		mc = NewMainnetConfig()
		settings, order := getDefaultMainSection(NetworkMainnet)
		for _, k := range orderedKeys(order, settings) {
			mc.Set(k, settings[k])
		}
	}

	if RunMainnetConfMigrations(mc) {
		if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
			return err
		}
		if err := os.WriteFile(confPath, []byte(mc.Serialize()), 0644); err != nil {
			return err
		}
		m.log.Info().Int("version", mc.Version).Msg("migrated bitwindow-mainnet.conf")
	}
	return nil
}

// ---------------------------------------------------------------------------
// Piece 7: Copy config downstream
// ---------------------------------------------------------------------------

// getDownstreamConfigPath returns the path where bitcoin config should be
// copied for Bitcoin Core to find it.
// Dart: _getDownstreamConfigPath (L552-554)
func (m *BitcoinConfManager) getDownstreamConfigPath() string {
	return filepath.Join(BitcoinCoreDirs.RootDirNetwork(m.Network), bitwindowBitcoinConfFilename)
}

// CopyConfigDownstream copies the master config from the BitWindow directory
// to the downstream location where Bitcoin Core expects it.
// The downstream file is read-only — any changes should be made to the master.
func (m *BitcoinConfManager) CopyConfigDownstream() error {
	sourcePath := m.getBitWindowConfigPath()
	destPath := m.getDownstreamConfigPath()

	sourceContent, err := os.ReadFile(sourcePath)
	if err != nil {
		return fmt.Errorf("read source config: %w", err)
	}

	header := fmt.Sprintf(`# ============================================================================
# READ-ONLY COPY - CHANGES TO THIS FILE WILL BE OVERWRITTEN.
# ============================================================================
# This file is automatically generated from the master configuration at:
#   %s
#
# Any changes made to this file will be OVERWRITTEN.
# To modify Bitcoin Core settings, edit the master file above.
# ============================================================================

`, sourcePath)

	if err := os.MkdirAll(filepath.Dir(destPath), 0755); err != nil {
		return fmt.Errorf("create downstream dir: %w", err)
	}
	if err := os.WriteFile(destPath, []byte(header+string(sourceContent)), 0644); err != nil {
		return fmt.Errorf("write downstream: %w", err)
	}

	m.log.Debug().Str("src", sourcePath).Str("dst", destPath).Msg("copied config downstream")
	return nil
}

// ---------------------------------------------------------------------------
// Piece 9: UpdateDataDir with cross-network logic
// ---------------------------------------------------------------------------

// UpdateDataDir sets the global datadir on master's bitwindow-bitcoin.conf.
// Bitcoin Core only honours datadir at the top level — section-scoped
// datadir lines are silently ignored at startup — so this writes to the
// global block. forNetwork is accepted for API compat but ignored: there
// is one datadir for the whole app, applied across every network. Bitcoin
// Core itself appends the per-chain subdir (signet/, testnet3/, etc.).
func (m *BitcoinConfManager) UpdateDataDir(dataDir string, forNetwork Network) error {
	_ = forNetwork
	if m.HasPrivateConf || m.Config == nil {
		return nil
	}

	cleanDataDir := strings.ReplaceAll(strings.TrimSpace(dataDir), "\\ ", " ")
	if cleanDataDir == "" {
		m.Config.RemoveSetting("datadir")
	} else {
		m.Config.SetSetting("datadir", cleanDataDir)
	}

	if err := m.SaveConfig(); err != nil {
		return err
	}
	return m.LoadConfig(false)
}

// ---------------------------------------------------------------------------
// Piece 10: HasDatadirForNetwork
// ---------------------------------------------------------------------------

// HasDatadirForNetwork reports whether a global datadir is configured.
// Mainnet and forknet require an explicit user-chosen path because the
// platform default sits inside ~/Library/Application Support and is not
// suitable for full mainnet data; signet / testnet / regtest accept the
// default. The value is global — the same one applies to every network.
func (m *BitcoinConfManager) HasDatadirForNetwork(n Network) bool {
	if !isMainnetOrForknet(n) {
		return true
	}
	if m.Config == nil {
		return false
	}
	return m.Config.GetSetting("datadir") != ""
}

// ---------------------------------------------------------------------------
// Piece 11: File watching
// ---------------------------------------------------------------------------

// StartWatching watches the BitWindow directory for changes to the master
// bitcoin config file. On change, it reloads config and copies downstream.
// Must be called after LoadConfig. Call StopWatching to clean up.
func (m *BitcoinConfManager) StartWatching() error {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("create watcher: %w", err)
	}

	// Ensure directory exists
	if err := os.MkdirAll(m.BitwindowDir, 0755); err != nil {
		_ = watcher.Close()
		return fmt.Errorf("create watch dir: %w", err)
	}

	if err := watcher.Add(m.BitwindowDir); err != nil {
		_ = watcher.Close()
		return fmt.Errorf("watch dir: %w", err)
	}

	m.watcher = watcher
	m.watchDone = make(chan struct{})

	go m.watchLoop()

	m.log.Debug().Str("dir", m.BitwindowDir).Msg("config file watching started")
	return nil
}

// StopWatching stops the file watcher.
func (m *BitcoinConfManager) StopWatching() {
	if m.watcher != nil {
		_ = m.watcher.Close()
	}
	if m.watchDone != nil {
		<-m.watchDone
	}
}

func (m *BitcoinConfManager) watchLoop() {
	defer close(m.watchDone)

	var debounce *time.Timer
	var mu sync.Mutex

	for {
		select {
		case event, ok := <-m.watcher.Events:
			if !ok {
				return
			}
			if !strings.HasSuffix(event.Name, bitwindowBitcoinConfFilename) {
				continue
			}
			if event.Op&(fsnotify.Write|fsnotify.Create) == 0 {
				continue
			}

			mu.Lock()
			if debounce != nil {
				debounce.Stop()
			}
			debounce = time.AfterFunc(50*time.Millisecond, func() {
				m.handleConfigFileChange()
			})
			mu.Unlock()

		case err, ok := <-m.watcher.Errors:
			if !ok {
				return
			}
			m.log.Error().Err(err).Msg("config watcher error")
		}
	}
}

func (m *BitcoinConfManager) handleConfigFileChange() {
	confPath := m.getBitWindowConfigPath()
	data, err := os.ReadFile(confPath)
	if err != nil {
		m.log.Error().Err(err).Msg("read changed config")
		return
	}

	// Skip if content unchanged
	newConfig := ParseBitcoinConfig(string(data))
	if m.Config != nil && m.Config.Serialize() == newConfig.Serialize() {
		m.log.Debug().Msg("config unchanged, skipping reload")
		return
	}

	m.log.Info().Msg("config file changed, reloading")
	if err := m.LoadConfig(false); err != nil {
		m.log.Error().Err(err).Msg("reload config after file change")
	}
}
