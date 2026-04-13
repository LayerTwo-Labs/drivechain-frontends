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

// ---------------------------------------------------------------------------
// Migration system (Dart: _kEnforcerConfVersion, _enforcerConfMigrations)
// ---------------------------------------------------------------------------

const enforcerConfMigrationsVersion = 2

// EnforcerConfMigration represents a versioned enforcer config migration.
type EnforcerConfMigration struct {
	Version int
	Apply   func(config *EnforcerConfig)
}

// Migration 2: add node-zmq-addr-sequence (now a required enforcer arg).
// Dart: _EnforcerMigration2AddZmqSequence (L358)
var enforcerConfMigrations = []EnforcerConfMigration{
	{
		Version: 2,
		Apply: func(config *EnforcerConfig) {
			if !config.HasSetting("node-zmq-addr-sequence") {
				config.SetSetting("node-zmq-addr-sequence", "tcp://127.0.0.1:29000")
			}
		},
	},
}

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
	ConfigDir   string // override for testing; empty = use EnforcerDirs.RootDir()
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
// Dart: EnforcerConfProvider.create() (L25)
func NewEnforcerConfManager(bitcoinConf *BitcoinConfManager, log zerolog.Logger) (*EnforcerConfManager, error) {
	m := &EnforcerConfManager{
		bitcoinConf: bitcoinConf,
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
		return nil
	}

	if !os.IsNotExist(err) {
		return fmt.Errorf("read enforcer config: %w", err)
	}

	// Dart: content = getDefaultConfig(); file.writeAsString(content);
	content := m.GetDefaultConfig()
	m.Config = ParseEnforcerConfig(content)

	if mkErr := os.MkdirAll(filepath.Dir(m.ConfigPath), 0755); mkErr != nil {
		m.log.Error().Err(mkErr).Msg("failed to create enforcer config directory")
	} else if wErr := os.WriteFile(m.ConfigPath, []byte(content), 0644); wErr != nil {
		m.log.Error().Err(wErr).Str("path", m.ConfigPath).Msg("failed to write default enforcer config")
	} else {
		m.log.Info().Str("path", m.ConfigPath).Msg("created default enforcer config file")
	}

	return nil
}

// SaveConfig writes the current config to disk.
// Dart: _saveConfig (L44)
func (m *EnforcerConfManager) SaveConfig() error {
	if m.Config == nil {
		return nil
	}
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

// NodeRpcDiffers checks if local node-rpc settings differ from BitcoinConfProvider.
// Dart: nodeRpcDiffers (L57)
func (m *EnforcerConfManager) NodeRpcDiffers() bool {
	if m.Config == nil {
		return false
	}

	expected := m.GetExpectedNodeRpcSettings()
	localUser := m.Config.GetSetting("node-rpc-user")
	localPass := m.Config.GetSetting("node-rpc-pass")
	localAddr := m.Config.GetSetting("node-rpc-addr")

	return localUser != expected["node-rpc-user"] ||
		localPass != expected["node-rpc-pass"] ||
		localAddr != expected["node-rpc-addr"]
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

// SyncFromBitcoinConf syncs node-rpc settings from the bitcoin config and saves.
// Dart: syncNodeRpcFromBitcoinConf (L102)
func (m *EnforcerConfManager) SyncFromBitcoinConf() error {
	if m.Config == nil {
		return nil
	}

	expected := m.GetExpectedNodeRpcSettings()
	m.Config.SetSetting("node-rpc-user", expected["node-rpc-user"])
	m.Config.SetSetting("node-rpc-pass", expected["node-rpc-pass"])
	m.Config.SetSetting("node-rpc-addr", expected["node-rpc-addr"])
	m.Config.SetSetting("node-zmq-addr-sequence", expected["node-zmq-addr-sequence"])

	// Sync esplora URL based on current network, but preserve an explicit empty
	// override so callers can intentionally disable the wallet esplora client.
	if value, ok := m.Config.Settings["wallet-esplora-url"]; ok && value == "" {
		// Keep explicit empty override.
	} else {
		esploraURL := EsploraURLForNetwork(m.bitcoinConf.Network)
		if esploraURL != "" {
			m.Config.SetSetting("wallet-esplora-url", esploraURL)
		} else {
			m.Config.RemoveSetting("wallet-esplora-url")
		}
	}

	return m.SaveConfig()
}

// GetDefaultConfig generates the default enforcer config content.
// Dart: getDefaultConfig (L194)
func (m *EnforcerConfManager) GetDefaultConfig() string {
	nodeRpc := m.GetExpectedNodeRpcSettings()
	esploraURL := EsploraURLForNetwork(m.bitcoinConf.Network)

	esploraLine := "# wallet-esplora-url="
	if esploraURL != "" {
		esploraLine = fmt.Sprintf("wallet-esplora-url=%s", esploraURL)
	}

	// Dart: '$kEnforcerConfVersionCommentPrefix$_kEnforcerConfVersion'
	return fmt.Sprintf(`%s%d

# Enforcer Configuration - Generated by BitWindow
# These settings are converted to CLI arguments when the Enforcer starts.

# Enable wallet functionality (default: true)
enable-wallet=true

# Enable mempool support - required for getblocktemplate (default: true)
enable-mempool=true

# Node RPC settings (synced from Bitcoin Core config)
node-rpc-user=%s
node-rpc-pass=%s
node-rpc-addr=%s

# Node ZMQ sequence address (must match zmqpubsequence in bitcoin.conf)
node-zmq-addr-sequence=tcp://127.0.0.1:29000

# Network-specific esplora URL
%s
`, enforcerConfVersionCommentPrefix, enforcerConfMigrationsVersion,
		nodeRpc["node-rpc-user"], nodeRpc["node-rpc-pass"], nodeRpc["node-rpc-addr"],
		esploraLine)
}

// GetCurrentConfigContent returns the current configuration content as string.
// Dart: getCurrentConfigContent (L225)
func (m *EnforcerConfManager) GetCurrentConfigContent() string {
	if m.Config == nil {
		return m.GetDefaultConfig()
	}
	return m.Config.Serialize()
}

// WriteConfig writes raw configuration content to the file.
// Dart: writeConfig (L233)
func (m *EnforcerConfManager) WriteConfig(content string) error {
	config := ParseEnforcerConfig(content)
	m.Config = config

	confPath := m.getConfigPath()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return fmt.Errorf("create dir: %w", err)
	}
	if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}

	m.log.Info().Str("path", confPath).Msg("saved enforcer config")
	return nil
}

// GetCliArgs converts current config settings to CLI arguments for the enforcer.
// Dart: getCliArgs (L275)
func (m *EnforcerConfManager) GetCliArgs() []string {
	var args []string

	if m.Config == nil {
		return args
	}

	for key, value := range m.Config.Settings {
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

	// Add esplora URL if not in config
	if !m.Config.HasSetting("wallet-esplora-url") {
		esploraURL := EsploraURLForNetwork(m.bitcoinConf.Network)
		if esploraURL != "" {
			args = append(args, fmt.Sprintf("--wallet-esplora-url=%s", esploraURL))
		}
	}

	return args
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

// getConfigPath returns the path to the enforcer config file.
// Dart: _getConfigPath (L135) = path.join(Enforcer().rootDir(), 'bitwindow-enforcer.conf')
func (m *EnforcerConfManager) getConfigPath() string {
	if m.ConfigDir != "" {
		return filepath.Join(m.ConfigDir, bitwindowEnforcerConfFilename)
	}
	return filepath.Join(EnforcerDirs.RootDir(), bitwindowEnforcerConfFilename)
}
