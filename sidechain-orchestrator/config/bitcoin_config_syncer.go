package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"
)

// BitcoinConfMigration represents a versioned config migration.
// Changes maps section name → key → value. Empty section "" means global.
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
// Returns true if any migration was applied.
func RunBitcoinConfMigrations(config *BitcoinConfig) bool {
	migrated := false
	for _, m := range bitcoinConfMigrations {
		if m.Version <= config.ConfigVersion {
			continue
		}
		for section, settings := range m.Changes {
			for key, value := range settings {
				config.SetSetting(key, value, section)
			}
		}
		config.ConfigVersion = m.Version
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
// DetectedDataDir uses GetEffectiveSetting: per-network section first, then
// global. This matches where UpdateDataDir writes (global, since Bitcoin Core
// only honours top-level datadir) and where bitcoind itself reads from. A
// user with their own bitcoin.conf may put datadir under [main] — that still
// wins. Empty here means "no datadir is configured anywhere".
func (m *BitcoinConfManager) loadStateFromConfig() {
	if m.Config == nil {
		return
	}

	m.Network = NetworkFromConfig(m.Config)
	m.DetectedDataDir = m.Config.GetEffectiveSetting("datadir", CoreSectionForNetwork(m.Network))

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

	if !m.HasDatadirForNetwork(newNetwork) {
		return fmt.Errorf("datadir not configured for %s", newNetwork)
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
// Copy config downstream
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
// UpdateDataDir + datadir-group helpers
// ---------------------------------------------------------------------------

// UpdateDataDir records dataDir for forNetwork's datadir group. If the group
// is currently active, it also rewrites the live `datadir=` line so bitcoind
// reads the new path on next boot. Otherwise it only updates the inactive
// group's slot — the active datadir is untouched.
//
// forNetwork must be a known Network value; the group resolution depends on
// it (forknet vs default).
func (m *BitcoinConfManager) UpdateDataDir(dataDir string, forNetwork Network) error {
	if m.HasPrivateConf || m.Config == nil {
		return nil
	}

	cleanDataDir := strings.ReplaceAll(strings.TrimSpace(dataDir), "\\ ", " ")

	group := DatadirGroupForNetwork(forNetwork)
	m.Config.SetGroupDatadir(group, cleanDataDir)

	if group == DatadirGroupForNetwork(m.Network) {
		m.materializeDatadirForGroup(group)
	}

	if err := m.SaveConfig(); err != nil {
		return err
	}
	return m.LoadConfig(false)
}

// materializeDatadirForGroup copies the group's slot value into the live
// `datadir=` line that bitcoind reads, or clears it if the slot is empty.
// Caller is responsible for persisting via SaveConfig.
func (m *BitcoinConfManager) materializeDatadirForGroup(g DatadirGroup) {
	if m.Config == nil {
		return
	}
	path := m.Config.GetGroupDatadir(g)
	if path == "" {
		m.Config.RemoveSetting("datadir")
		return
	}
	m.Config.SetSetting("datadir", path)
}

// HasDatadirForNetwork reports whether a datadir is configured for n's group.
// Mainnet/forknet require an explicit user-chosen path because the platform
// default sits inside ~/Library/Application Support and isn't suitable for
// full chain data; signet/testnet/regtest accept the default (Bitcoin Core
// auto-partitions them under chain subdirs).
func (m *BitcoinConfManager) HasDatadirForNetwork(n Network) bool {
	if m.Config == nil {
		return false
	}
	if n == NetworkForknet {
		return m.Config.GetGroupDatadir(DatadirGroupForknet) != ""
	}
	if n == NetworkMainnet {
		// Mainnet still needs a user-chosen path — it would otherwise write
		// 700+ GB into Library/Application Support.
		if m.Config.GetGroupDatadir(DatadirGroupDefault) != "" {
			return true
		}
		// Tolerate a top-level datadir= without a slot (e.g. user-edited
		// conf or pre-slot install — first cross-group swap will adopt it
		// into the slot).
		return m.Config.GetSetting("datadir") != ""
	}
	return true
}

// applyMainSectionDefaults ensures master's [main] section matches what the
// active network expects. Forknet wants drivechain=1 + the alternate ports;
// real mainnet/the default group want those keys absent. signet/test/regtest
// don't read [main], so this is a no-op for them.
func (m *BitcoinConfManager) applyMainSectionDefaults(n Network) {
	if m.Config == nil {
		return
	}
	switch n {
	case NetworkForknet:
		forknetMainDefaults := []struct{ k, v string }{
			{"port", "8300"},
			{"rpcport", "18301"},
			{"rpcbind", "127.0.0.1"},
			{"rpcallowip", "0.0.0.0/0"},
			{"assumevalid", "0000000000000000000000000000000000000000000000000000000000000000"},
			{"minimumchainwork", "0x00"},
			{"listenonion", "0"},
			{"drivechain", "1"},
			{"fallbackfee", "0.00021"},
		}
		for _, kv := range forknetMainDefaults {
			if !m.Config.HasSetting(kv.k, "main") {
				m.Config.SetSetting(kv.k, kv.v, "main")
			}
		}
	case NetworkMainnet:
		// Strip forknet-only keys; bitcoind on real mainnet must not see
		// drivechain=1 or the alternate port.
		for _, k := range []string{"drivechain", "port", "rpcport", "fallbackfee"} {
			m.Config.RemoveSetting(k, "main")
		}
	}
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
