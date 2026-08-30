package config

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"slices"
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
	"node-rpc-cookie-path",
	"node-rpc-addr",
	"node-zmq-addr-sequence",
	"wallet-esplora-url",
	"network-preset",
}

// enforcerKnownKeys are the settings the shipped enforcer accepts as CLI
// flags. Its argument parser exits on an unknown option, so GetCliArgs drops
// anything outside this set rather than bricking the daemon on a key an old
// conf still carries.
var enforcerKnownKeys = map[string]bool{
	"coinbase-recipient":             true,
	"data-dir":                       true,
	"enable-block-template-server":   true,
	"enable-mempool":                 true,
	"exit-after-sync":                true,
	"log-directory":                  true,
	"log-format":                     true,
	"log-level":                      true,
	"log-rotation":                   true,
	"max-log-file-size-mb":           true,
	"max-log-files":                  true,
	"network-preset":                 true,
	"node-blocks-dir":                true,
	"node-rpc-addr":                  true,
	"node-rpc-cookie-path":           true,
	"node-rpc-pass":                  true,
	"node-rpc-user":                  true,
	"node-zmq-addr-sequence":         true,
	"serve-grpc-addr":                true,
	"serve-rpc-addr":                 true,
	"signet-miner-bitcoin-cli-path":  true,
	"signet-miner-bitcoin-util-path": true,
	"signet-miner-script-debug":      true,
	"signet-miner-script-path":       true,
	"wallet-auto-create":             true,
	"wallet-electrum-host":           true,
	"wallet-electrum-port":           true,
	"wallet-esplora-url":             true,
	"wallet-seed-file":               true,
	"wallet-skip-periodic-sync":      true,
	"wallet-sync-source":             true,
}

// ---------------------------------------------------------------------------
// Migration system (Dart: _kEnforcerConfVersion, _enforcerConfMigrations)
// ---------------------------------------------------------------------------

const enforcerConfMigrationsVersion = 4

// EnforcerConfMigration represents a versioned enforcer config migration.
type EnforcerConfMigration struct {
	Version int
	Apply   func(config *EnforcerConfig)
}

var enforcerConfMigrations = []EnforcerConfMigration{
	{
		// The enforcer runs no wallet. An existing conf keeps enable-wallet
		// forever and never gains the block template server, so it would seed
		// a wallet that never starts and serve no getblocktemplate.
		Version: 3,
		Apply: func(config *EnforcerConfig) {
			config.RemoveSetting("enable-wallet")
			if config.GetSetting("enable-block-template-server") == "" {
				config.SetSetting("enable-block-template-server", "true")
			}
			// The template server needs the mempool, and clap refuses the
			// argv without it. A hand-set false would make the enforcer
			// reject its own arguments.
			config.SetSetting("enable-mempool", "true")
		},
	},
	{
		// The enforcer dropped these three flags and exits on an unknown
		// option, so a conf that still carries one never starts.
		Version: 4,
		Apply: func(config *EnforcerConfig) {
			config.RemoveSetting("serve-json-rpc-addr")
			config.RemoveSetting("wallet-full-scan")
			config.RemoveSetting("signet-miner-coinbase-recipient")
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
	host := m.bitcoinConf.GetRPCHost()
	const defaultZmqSequence = "tcp://127.0.0.1:29000"

	port := m.bitcoinConf.GetRPCPort()

	if m.bitcoinConf.Config == nil {
		return map[string]string{
			"node-rpc-cookie-path":   m.bitcoinConf.GetRPCCookiePath(),
			"node-rpc-addr":          fmt.Sprintf("%s:%d", host, port),
			"node-zmq-addr-sequence": defaultZmqSequence,
		}
	}

	networkSection := CoreSectionForNetwork(m.bitcoinConf.Network)

	zmqSequence := m.bitcoinConf.Config.GetEffectiveSetting("zmqpubsequence", networkSection)
	if zmqSequence == "" {
		zmqSequence = defaultZmqSequence
	}

	settings := map[string]string{
		"node-rpc-addr":          fmt.Sprintf("%s:%d", host, port),
		"node-zmq-addr-sequence": zmqSequence,
	}

	username := m.bitcoinConf.Config.GetEffectiveSetting("rpcuser", networkSection)
	password := m.bitcoinConf.Config.GetEffectiveSetting("rpcpassword", networkSection)
	if username != "" && password != "" {
		settings["node-rpc-user"] = username
		settings["node-rpc-pass"] = password
		return settings
	}

	settings["node-rpc-cookie-path"] = m.bitcoinConf.GetRPCCookiePath()
	return settings
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

# Enable mempool support - the block template server needs it (default: true)
enable-mempool=true

# Serve getblocktemplate and block generation (default: true)
enable-block-template-server=true
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
	// seen[key] is true only when the persisted conf had a NON-EMPTY value
	// for that key. An empty entry (e.g. `node-rpc-user=` left blank in the
	// configurator) used to mark seen=true while emitting no arg, then the
	// overlay below would skip the same key — leaving the enforcer with no
	// rpc-user flag and the cryptic "precisely one of rpc user and cookie
	// must be set" error (#1712). Empty-value keys now fall through to the
	// overlay's default.
	seen := make(map[string]bool)

	if m.Config != nil {
		for key, value := range m.Config.Settings {
			// The enforcer exits on an unknown option, so a key it does not
			// accept is dropped instead of bricking the whole daemon.
			if !enforcerKnownKeys[key] {
				m.log.Warn().Str("key", key).Msg("dropping enforcer setting the binary does not accept")
				continue
			}
			switch value {
			case "true":
				args = append(args, fmt.Sprintf("--%s", key))
				seen[key] = true
			case "false":
				seen[key] = true
				continue
			default:
				if value != "" {
					args = append(args, fmt.Sprintf("--%s=%s", key, value))
					seen[key] = true
				}
				// empty values intentionally leave seen[key] false so the
				// overlay below can supply a derived default.
			}
		}
	}

	expected := m.GetExpectedNodeRpcSettings()
	// The enforcer takes a user or a cookie, never both, so a persisted auth
	// mode drops the derived one rather than being merged with it.
	if seen["node-rpc-user"] || seen["node-rpc-pass"] {
		delete(expected, "node-rpc-cookie-path")
	} else if seen["node-rpc-cookie-path"] {
		delete(expected, "node-rpc-user")
		delete(expected, "node-rpc-pass")
	}
	for _, key := range []string{"node-rpc-user", "node-rpc-pass", "node-rpc-cookie-path", "node-rpc-addr", "node-zmq-addr-sequence"} {
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

	// ECash forks mainnet, so the enforcer needs the network's preset to
	// validate against the right chain. Only eCash builds accept the flag.
	if m.bitcoinConf.Network == NetworkECash && !seen["network-preset"] {
		if id := m.bitcoinConf.ResolvedECashID(); id != "" {
			args = append(args, fmt.Sprintf("--network-preset=%s", id))
		}
	}

	// Regtest has no esplora to point at and no bundled electrs — without
	// an explicit sync source the enforcer dies on startup trying to dial
	// http://localhost:3003. Default to "disabled": BDK still tracks new
	// blocks via the ZMQ feed, just doesn't backfill from a chain server.
	if m.bitcoinConf.Network == NetworkRegtest && !seen["wallet-sync-source"] {
		args = append(args, "--wallet-sync-source=disabled")
	}

	return args
}

const (
	esploraProbeTimeout  = 5 * time.Second
	electrumProbeTimeout = 5 * time.Second
)

// EsploraArgURL returns the URL of the --wallet-esplora-url argument.
func EsploraArgURL(args []string) (string, bool) {
	for _, arg := range args {
		if url, ok := strings.CutPrefix(arg, "--wallet-esplora-url="); ok {
			return url, true
		}
	}
	return "", false
}

// EsploraReachable reports whether an esplora server answers its tip query.
func EsploraReachable(ctx context.Context, baseURL string) bool {
	ctx, cancel := context.WithTimeout(ctx, esploraProbeTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimSuffix(baseURL, "/")+"/blocks/tip/height", nil)
	if err != nil {
		return false
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return false
	}
	defer res.Body.Close() //nolint:errcheck // cleanup
	return res.StatusCode == http.StatusOK
}

// ElectrumReachable reports whether an electrum server answers a version
// handshake. A TLS terminator in front of a dead electrs accepts the
// connection and then serves nothing, so a dial alone proves nothing.
func ElectrumReachable(ctx context.Context, host string, port uint16) bool {
	if host == "" {
		return false
	}
	name, secure := strings.CutPrefix(host, "ssl://")
	address := fmt.Sprintf("%s:%d", name, port)

	ctx, cancel := context.WithTimeout(ctx, electrumProbeTimeout)
	defer cancel()

	conn, err := (&net.Dialer{}).DialContext(ctx, "tcp", address)
	if err != nil {
		return false
	}
	if secure {
		conn = tls.Client(conn, &tls.Config{ServerName: name, MinVersion: tls.VersionTLS12})
	}
	defer conn.Close() //nolint:errcheck // cleanup

	deadline, _ := ctx.Deadline()
	if err := conn.SetDeadline(deadline); err != nil {
		return false
	}
	if _, err := conn.Write([]byte(`{"jsonrpc":"2.0","id":0,"method":"server.version","params":["bitwindow","1.4"]}` + "\n")); err != nil {
		return false
	}

	var reply struct {
		Result []string `json:"result"`
	}
	if err := json.NewDecoder(conn).Decode(&reply); err != nil {
		return false
	}
	return len(reply.Result) > 0
}

// WithElectrumFallback points the enforcer wallet at an electrum server in
// place of esplora. A pinned wallet-sync-source wins, and so does an empty host.
func WithElectrumFallback(args []string, host string, port uint16) []string {
	pinned := slices.ContainsFunc(args, func(arg string) bool {
		return strings.HasPrefix(arg, "--wallet-sync-source=")
	})
	if host == "" || pinned {
		return args
	}

	out := slices.DeleteFunc(slices.Clone(args), func(arg string) bool {
		return strings.HasPrefix(arg, "--wallet-esplora-url=")
	})
	return append(out,
		"--wallet-sync-source=electrum",
		fmt.Sprintf("--wallet-electrum-host=%s", host),
		fmt.Sprintf("--wallet-electrum-port=%d", port),
	)
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

// RetargetECashNetwork moves persisted settings onto the eCash network id, and
// reports whether the file changed. previousID is the network they came from,
// empty when it is unknown.
//
// GetCliArgs treats a persisted value as an explicit override, and every start
// calls this. So the endpoint moves only when it still names previousID, while
// the preset always moves — no preset but the running fork's is correct.
func (m *EnforcerConfManager) RetargetECashNetwork(previousID, id string) (bool, error) {
	if m.bitcoinConf == nil {
		return false, nil
	}
	return m.RetargetECashNetworkFor(m.bitcoinConf.Network, previousID, id)
}

// RetargetECashNetworkFor is RetargetECashNetwork for a switch that has not
// landed yet. The caller names the network that will be active, because the
// enforcer conf has to be right before anything reads it — the L1 boot reads it
// on a goroutine the swap starts.
func (m *EnforcerConfManager) RetargetECashNetworkFor(target Network, previousID, id string) (bool, error) {
	if m.Config == nil || id == "" || target != NetworkECash {
		return false, nil
	}

	changed := false
	// The preset names the fork the enforcer validates against, so it has to
	// match the network that boots. No other value is correct.
	if preset, persisted := m.Config.Settings["network-preset"]; persisted && preset != id {
		m.Config.Settings["network-preset"] = id
		changed = true
	}
	// The endpoint may be the user's own. Only one that still names the retired
	// network is this function's to change.
	if previousID != "" && previousID != id {
		if url, persisted := m.Config.Settings["wallet-esplora-url"]; persisted &&
			strings.Contains(url, previousID) {
			if want := EsploraURLForNetwork(NetworkECash); want != "" && want != url {
				m.Config.Settings["wallet-esplora-url"] = want
				changed = true
			}
		}
	}
	if !changed {
		return false, nil
	}

	return true, m.SaveConfig()
}
