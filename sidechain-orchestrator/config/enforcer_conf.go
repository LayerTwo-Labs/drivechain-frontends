package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/rs/zerolog"
)

const bitwindowEnforcerConfFilename = "bitwindow-enforcer.conf"

// derivedEnforcerSettings are fields the enforcer needs but that BitWindow
// derives entirely from the active bitcoin.conf / network at boot. Keeping
// them in the persisted enforcer.conf is what produced the regtest-port-on-
// signet bug: the file was written once on regtest, the user swapped to
// signet, the rest of the system updated but the enforcer.conf still said
// `node-rpc-addr=127.0.0.1:18443` and the enforcer dutifully tried to
// REST against regtest.
//
// The persisted file is now restricted to genuine user toggles
// (enable-wallet, enable-mempool, anything the user pastes in by hand);
// these derived fields are stripped on load and overlaid fresh by
// GetCliArgs every boot.
var derivedEnforcerSettings = []string{
	"node-rpc-user",
	"node-rpc-pass",
	"node-rpc-addr",
	"node-zmq-addr-sequence",
	"wallet-esplora-url",
}

func stripDerivedEnforcerSettings(c *EnforcerConfig) {
	if c == nil {
		return
	}
	for _, key := range derivedEnforcerSettings {
		c.RemoveSetting(key)
	}
}

// ---------------------------------------------------------------------------
// Migration system (Dart: _kEnforcerConfVersion, _enforcerConfMigrations)
// ---------------------------------------------------------------------------

const enforcerConfMigrationsVersion = 2

// EnforcerConfMigration represents a versioned enforcer config migration.
type EnforcerConfMigration struct {
	Version int
	Apply   func(config *EnforcerConfig)
}

// No active migrations — derived fields are stripped on every load
// instead, see stripDerivedEnforcerSettings. The version is left at 2 so
// pre-existing v2 files don't trigger spurious rewrites.
var enforcerConfMigrations = []EnforcerConfMigration{}

// RunEnforcerConfMigrations applies pending migrations to an EnforcerConfig.
// Returns true if any migration was applied.
func RunEnforcerConfMigrations(config *EnforcerConfig) bool {
	migrated := false
	for _, m := range enforcerConfMigrations {
		if m.Version <= config.ConfigVersion {
			continue
		}
		m.Apply(config)
		config.ConfigVersion = m.Version
		migrated = true
	}
	return migrated
}

// ---------------------------------------------------------------------------
// EnforcerConfManager
// ---------------------------------------------------------------------------

// EnforcerConfManager manages Enforcer daemon configuration.
// 1:1 port of sail_ui/lib/providers/enforcer_conf_provider.dart.
type EnforcerConfManager struct {
	Config      *EnforcerConfig
	ConfigPath  string
	ConfigDir   string // directory where bitwindow-enforcer.conf lives; required
	bitcoinConf *BitcoinConfManager
	log         zerolog.Logger

	// OnBitcoinConfChanged is called when bitcoin config changes.
	// Set externally; triggers SyncFromBitcoinConf.
	OnBitcoinConfChanged func()

	// File watching (managed by StartWatching/StopWatching)
	watcher   *fsnotify.Watcher
	watchDone chan struct{}
}

// NewEnforcerConfManager creates a new EnforcerConfManager and loads config.
// configDir is the directory where bitwindow-enforcer.conf lives (typically
// the orchestrator's bitwindowDir). It must be set; tests previously
// scribbled on the user's real ~/Library/Application Support/bip300301_enforcer/
// because there was no required dir parameter and the old fallback used a
// hardcoded global path.
// Dart: EnforcerConfProvider.create() (L25)
func NewEnforcerConfManager(bitcoinConf *BitcoinConfManager, configDir string, log zerolog.Logger) (*EnforcerConfManager, error) {
	if configDir == "" {
		return nil, fmt.Errorf("enforcer conf manager requires a non-empty configDir")
	}
	m := &EnforcerConfManager{
		bitcoinConf: bitcoinConf,
		ConfigDir:   configDir,
		log:         log.With().Str("component", "enforcer-conf").Logger(),
	}
	// Dart: await instance.loadConfig();
	if err := m.LoadConfig(); err != nil {
		return nil, fmt.Errorf("load enforcer config: %w", err)
	}
	// Dart: instance._setupFileWatching();
	// (caller should call StartWatching after construction)

	// Dart: instance._listenToBitcoinConf();
	// (handled via OnBitcoinConfChanged callback set by caller)

	// Dart: await instance.syncNodeRpcFromBitcoinConf();
	if err := m.SyncFromBitcoinConf(); err != nil {
		m.log.Warn().Err(err).Msg("failed to sync enforcer config from bitcoin conf")
	}
	return m, nil
}

// LoadConfig loads config from file, or creates default if not exists.
// Runs versioned migrations on load when stored version < current.
// Dart: loadConfig (L148)
func (m *EnforcerConfManager) LoadConfig() error {
	m.ConfigPath = m.getConfigPath()

	data, err := os.ReadFile(m.ConfigPath)
	if err == nil {
		content := string(data)
		config := ParseEnforcerConfig(content)

		// Dart: runConfigMigrations<EnforcerConfig>(config, _kEnforcerConfVersion, ...)
		if RunEnforcerConfMigrations(config) {
			content = config.Serialize()
			if writeErr := os.WriteFile(m.ConfigPath, []byte(content), 0644); writeErr != nil {
				m.log.Error().Err(writeErr).Msg("failed to write migrated enforcer config")
			} else {
				m.log.Info().Int("version", config.ConfigVersion).Msg("migrated bitwindow-enforcer.conf")
			}
		}

		m.Config = ParseEnforcerConfig(content)
		stripDerivedEnforcerSettings(m.Config)
		return nil
	}

	if !os.IsNotExist(err) {
		return fmt.Errorf("read enforcer config: %w", err)
	}

	// Dart: content = getDefaultConfig(); file.writeAsString(content);
	content := m.GetDefaultConfig()
	m.Config = ParseEnforcerConfig(content)
	stripDerivedEnforcerSettings(m.Config)

	if mkErr := os.MkdirAll(filepath.Dir(m.ConfigPath), 0755); mkErr != nil {
		m.log.Error().Err(mkErr).Msg("failed to create enforcer config directory")
	} else if wErr := os.WriteFile(m.ConfigPath, []byte(content), 0644); wErr != nil {
		m.log.Error().Err(wErr).Str("path", m.ConfigPath).Msg("failed to write default enforcer config")
	} else {
		m.log.Info().Str("path", m.ConfigPath).Msg("created default enforcer config file")
	}

	return nil
}

// SaveConfig writes the current config to disk. Strips derived fields
// before serialising so they can never be persisted, even if someone
// (legacy code, a stale RPC, the user pasting them in via WriteConfig)
// puts them back into the in-memory state.
// Dart: _saveConfig (L44)
func (m *EnforcerConfManager) SaveConfig() error {
	if m.Config == nil {
		return nil
	}
	stripDerivedEnforcerSettings(m.Config)
	confPath := m.getConfigPath()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return err
	}
	if err := os.WriteFile(confPath, []byte(m.Config.Serialize()), 0644); err != nil {
		return fmt.Errorf("save enforcer config: %w", err)
	}
	m.log.Info().Str("path", confPath).Msg("saved enforcer config")
	return nil
}

// NodeRpcDiffers used to compare persisted enforcer node-rpc settings
// against the bitcoin.conf-derived values. Now that those settings are
// never persisted (they're overlaid fresh by GetCliArgs each boot),
// "differs" is always false. Kept for the wire-shape compatibility of
// the EnforcerConfService.GetEnforcerConfig RPC.
func (m *EnforcerConfManager) NodeRpcDiffers() bool {
	return false
}

// GetExpectedNodeRpcSettings derives RPC credentials from bitcoin config.
// Dart: getExpectedNodeRpcSettings (L71)
func (m *EnforcerConfManager) GetExpectedNodeRpcSettings() map[string]string {
	const host = "127.0.0.1"
	const defaultZmqSequence = "tcp://127.0.0.1:29000"

	port := m.bitcoinConf.GetRPCPort()

	if m.bitcoinConf.Config == nil {
		return map[string]string{
			"node-rpc-user":          "user",
			"node-rpc-pass":          "password",
			"node-rpc-addr":          fmt.Sprintf("%s:%d", host, port),
			"node-zmq-addr-sequence": defaultZmqSequence,
		}
	}

	networkSection := CoreSectionForNetwork(m.bitcoinConf.Network)

	username := m.bitcoinConf.Config.GetEffectiveSetting("rpcuser", networkSection)
	if username == "" {
		username = "user"
	}

	password := m.bitcoinConf.Config.GetEffectiveSetting("rpcpassword", networkSection)
	if password == "" {
		password = "password"
	}

	zmqSequence := m.bitcoinConf.Config.GetEffectiveSetting("zmqpubsequence", networkSection)
	if zmqSequence == "" {
		zmqSequence = defaultZmqSequence
	}

	return map[string]string{
		"node-rpc-user":          username,
		"node-rpc-pass":          password,
		"node-rpc-addr":          fmt.Sprintf("%s:%d", host, port),
		"node-zmq-addr-sequence": zmqSequence,
	}
}

// SyncFromBitcoinConf used to write bitcoin-conf-derived node-rpc /
// esplora settings into the persisted enforcer.conf. Those fields are
// no longer persisted (they're overlaid fresh by GetCliArgs each boot),
// so this is now a no-op. Kept so the EnforcerConfService.SyncNodeRpc...
// RPC stays callable from older clients without a proto change.
func (m *EnforcerConfManager) SyncFromBitcoinConf() error {
	return nil
}

// GetDefaultConfig generates the default enforcer config content.
//
// node-rpc-{user,pass,addr}, node-zmq-addr-sequence, and wallet-esplora-url
// are deliberately NOT in this template even though the enforcer needs
// them — they're derived from the active bitcoin.conf / network and
// overlaid by GetCliArgs at boot. Persisting them here is what made the
// enforcer.conf desync from Core whenever the user swapped networks.
// Dart: getDefaultConfig (L194)
func (m *EnforcerConfManager) GetDefaultConfig() string {
	return fmt.Sprintf(`%s%d

# Enforcer Configuration - Generated by BitWindow
# These settings are converted to CLI arguments when the Enforcer starts.
#
# node-rpc-* / node-zmq-addr-sequence / wallet-esplora-url are derived
# from your active Bitcoin Core config and current network — BitWindow
# appends them to the CLI args at boot, so adding them here will be
# stripped on the next load.

# Enable wallet functionality (default: true)
enable-wallet=true

# Enable mempool support - required for getblocktemplate (default: true)
enable-mempool=true
`, enforcerConfVersionCommentPrefix, enforcerConfMigrationsVersion)
}

// GetCurrentConfigContent returns the current configuration content as string.
// Dart: getCurrentConfigContent (L225)
func (m *EnforcerConfManager) GetCurrentConfigContent() string {
	if m.Config == nil {
		return m.GetDefaultConfig()
	}
	return m.Config.Serialize()
}

// WriteConfig writes raw configuration content to the file. Derived
// fields pasted in via the UI are stripped before persistence so the
// file can never out-of-band override what GetCliArgs derives at boot.
// Dart: writeConfig (L233)
func (m *EnforcerConfManager) WriteConfig(content string) error {
	config := ParseEnforcerConfig(content)
	stripDerivedEnforcerSettings(config)
	m.Config = config

	cleaned := config.Serialize()
	confPath := m.getConfigPath()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return fmt.Errorf("create dir: %w", err)
	}
	if err := os.WriteFile(confPath, []byte(cleaned), 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}

	m.log.Info().Str("path", confPath).Msg("saved enforcer config")
	return nil
}

// GetCliArgs converts current config settings to CLI arguments for the enforcer.
// Dart: getCliArgs (L275)
func (m *EnforcerConfManager) GetCliArgs() []string {
	var args []string

	if m.Config != nil {
		// User toggles only — derived fields are stripped on load and
		// re-added below from the active bitcoin.conf / network. This
		// guarantees that swapping networks always picks up the new RPC
		// port / esplora URL, even if a stale persisted file slipped
		// through some pre-strip code path.
		for key, value := range m.Config.Settings {
			if isDerivedEnforcerSetting(key) {
				continue
			}
			switch value {
			case "true":
				args = append(args, fmt.Sprintf("--%s", key))
			case "false":
				continue
			default:
				if value != "" {
					args = append(args, fmt.Sprintf("--%s=%s", key, value))
				}
			}
		}
	}

	// Always overlay the bitcoin-conf-derived RPC + ZMQ wiring.
	expected := m.GetExpectedNodeRpcSettings()
	for _, key := range []string{"node-rpc-user", "node-rpc-pass", "node-rpc-addr", "node-zmq-addr-sequence"} {
		if v := expected[key]; v != "" {
			args = append(args, fmt.Sprintf("--%s=%s", key, v))
		}
	}

	// Esplora URL is also network-derived; only attach it on networks
	// where we have a known endpoint.
	if esploraURL := EsploraURLForNetwork(m.bitcoinConf.Network); esploraURL != "" {
		args = append(args, fmt.Sprintf("--wallet-esplora-url=%s", esploraURL))
	}

	return args
}

func isDerivedEnforcerSetting(key string) bool {
	for _, k := range derivedEnforcerSettings {
		if k == key {
			return true
		}
	}
	return false
}

// ---------------------------------------------------------------------------
// File watching
// Dart: _setupFileWatching (L303), _handleFileSystemEvent (L325),
//       _reloadConfigFromFileSystem (L335)
// ---------------------------------------------------------------------------

// StartWatching watches the enforcer config directory for changes.
// On change, it reloads config if content differs.
func (m *EnforcerConfManager) StartWatching() error {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("create watcher: %w", err)
	}

	confDir := filepath.Dir(m.getConfigPath())
	if err := os.MkdirAll(confDir, 0755); err != nil {
		_ = watcher.Close()
		return fmt.Errorf("create watch dir: %w", err)
	}

	if err := watcher.Add(confDir); err != nil {
		_ = watcher.Close()
		return fmt.Errorf("watch dir: %w", err)
	}

	m.watcher = watcher
	m.watchDone = make(chan struct{})

	go m.watchLoop()

	m.log.Debug().Str("dir", confDir).Msg("enforcer config file watching enabled")
	return nil
}

// StopWatching stops the file watcher.
func (m *EnforcerConfManager) StopWatching() {
	if m.watcher != nil {
		_ = m.watcher.Close()
	}
	if m.watchDone != nil {
		<-m.watchDone
	}
}

func (m *EnforcerConfManager) watchLoop() {
	defer close(m.watchDone)

	var debounce *time.Timer
	var mu sync.Mutex

	for {
		select {
		case event, ok := <-m.watcher.Events:
			if !ok {
				return
			}
			// Dart: .where((event) => event.path.endsWith('bitwindow-enforcer.conf'))
			if !strings.HasSuffix(event.Name, bitwindowEnforcerConfFilename) {
				continue
			}
			if event.Op&(fsnotify.Write|fsnotify.Create) == 0 {
				continue
			}

			// Dart: Timer(Duration(milliseconds: 500), () { _reloadConfigFromFileSystem() })
			mu.Lock()
			if debounce != nil {
				debounce.Stop()
			}
			debounce = time.AfterFunc(500*time.Millisecond, func() {
				m.reloadConfigFromFileSystem()
			})
			mu.Unlock()

		case err, ok := <-m.watcher.Errors:
			if !ok {
				return
			}
			m.log.Error().Err(err).Msg("enforcer config watcher error")
		}
	}
}

// reloadConfigFromFileSystem reloads config if file content changed.
// Dart: _reloadConfigFromFileSystem (L335)
func (m *EnforcerConfManager) reloadConfigFromFileSystem() {
	m.log.Info().Msg("reloading enforcer config due to file system change")

	confPath := m.getConfigPath()
	data, err := os.ReadFile(confPath)
	if err != nil {
		m.log.Error().Err(err).Msg("failed to read enforcer config from file system")
		return
	}

	newConfig := ParseEnforcerConfig(string(data))

	// Dart: if (newConfig != currentConfig)
	if m.Config != nil && m.Config.Serialize() == newConfig.Serialize() {
		return // unchanged
	}

	m.Config = newConfig
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// getConfigPath returns the path to the enforcer config file. ConfigDir is
// required at construction time, so there's no global-path fallback —
// previously that fallback caused tests (which never set ConfigDir) to
// open and rewrite the user's real enforcer.conf under
// ~/Library/Application Support/bip300301_enforcer/.
func (m *EnforcerConfManager) getConfigPath() string {
	return filepath.Join(m.ConfigDir, bitwindowEnforcerConfFilename)
}
