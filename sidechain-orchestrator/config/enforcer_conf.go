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
// can derive from the active bitcoin.conf / network at boot. They aren't
// part of the default template — GetCliArgs overlays them only when the
// persisted file doesn't already specify a value, so an explicit override
// in bitwindow-enforcer.conf always wins.
var derivedEnforcerSettings = []string{
	"node-rpc-user",
	"node-rpc-pass",
	"node-rpc-addr",
	"node-zmq-addr-sequence",
	"wallet-esplora-url",
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

// No active migrations after derived fields stopped being part of the
// default template. Version is left at 2 so pre-existing v2 files don't
// trigger spurious rewrites.
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
	if err := m.LoadConfig(); err != nil {
		return nil, fmt.Errorf("load enforcer config: %w", err)
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

// WriteConfig writes raw configuration content to the file.
// Dart: writeConfig (L233)
func (m *EnforcerConfManager) WriteConfig(content string) error {
	m.Config = ParseEnforcerConfig(content)

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

// GetCliArgs converts current config settings to CLI arguments for the
// enforcer. Persisted values always win — for the bitcoin-conf-derived
// keys (node-rpc-*, node-zmq-addr-sequence, wallet-esplora-url) we
// fall back to the bitcoin.conf / network derivation only when the
// persisted file doesn't specify a value. That preserves an explicit
// override while keeping fresh installs (no derived keys in the default
// template) network-correct out of the box.
// Dart: getCliArgs (L275)
func (m *EnforcerConfManager) GetCliArgs() []string {
	var args []string
	seen := make(map[string]bool)

	if m.Config != nil {
		for key, value := range m.Config.Settings {
			seen[key] = true
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

	expected := m.GetExpectedNodeRpcSettings()
	for _, key := range []string{"node-rpc-user", "node-rpc-pass", "node-rpc-addr", "node-zmq-addr-sequence"} {
		if seen[key] {
			continue
		}
		if v := expected[key]; v != "" {
			args = append(args, fmt.Sprintf("--%s=%s", key, v))
		}
	}

	if !seen["wallet-esplora-url"] {
		if esploraURL := EsploraURLForNetwork(m.bitcoinConf.Network); esploraURL != "" {
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

// getConfigPath returns the path to the enforcer config file. ConfigDir is
// required at construction time, so there's no global-path fallback —
// previously that fallback caused tests (which never set ConfigDir) to
// open and rewrite the user's real enforcer.conf under
// ~/Library/Application Support/bip300301_enforcer/.
func (m *EnforcerConfManager) getConfigPath() string {
	return filepath.Join(m.ConfigDir, bitwindowEnforcerConfFilename)
}
