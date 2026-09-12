package config

import (
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/rs/zerolog"
)

// SidechainConfByName finds the manager for a binary name. The chains config
// writes a display name like "Thunder", and the specs are keyed "thunder".
func SidechainConfByName(confs map[string]*SidechainConfManager, name string) *SidechainConfManager {
	lower := strings.ToLower(name)
	for key, scm := range confs {
		if strings.ToLower(key) == lower || strings.ToLower(scm.Spec.Name) == lower {
			return scm
		}
	}
	return nil
}

// SidechainSpecByName finds the spec for a binary name, by the same rule as
// SidechainConfByName.
func SidechainSpecByName(name string) (SidechainConfSpec, bool) {
	lower := strings.ToLower(name)
	for key, spec := range KnownSidechainSpecs {
		if strings.ToLower(key) == lower || strings.ToLower(spec.Name) == lower {
			return spec, true
		}
	}
	return SidechainConfSpec{}, false
}

// legacyNetworkKey is a network key that older conf files carry. The network is
// always downstream of the mainchain conf, so the file holds none of its own,
// and SyncNetworkFromBitcoinConf drops the key it finds.
const legacyNetworkKey = "network"

// CliNetworkFlag is the flag a CUSF sidechain daemon reads for its network.
// The launch path stops a daemon that gets no such flag, because the daemon
// then picks its own default network.
const CliNetworkFlag = "--network"

// CusfNetworkName gives the network name a CUSF sidechain daemon accepts for
// the mainchain network n, on the eCash generation ecashID. It returns "" when
// the daemon has no such network, and the launch path then stops the daemon.
//
// eCash carries a generation the daemon does not model: only alphanet has a
// name in the daemon's own enum. A generation such as drynet4 runs a build
// with its own magic, so a name from another generation stops it from syncing.
func CusfNetworkName(n Network, ecashID string) string {
	switch n {
	case NetworkRegtest:
		return "regtest"
	case NetworkECash:
		if ecashID == "alphanet" {
			return "alphanet"
		}
		return ""
	case NetworkSignet:
		return "signet"
	default:
		return ""
	}
}

// SidechainConfSpec defines how a sidechain's configuration should be managed.
type SidechainConfSpec struct {
	// Name is the sidechain name (e.g. "thunder", "bitassets").
	Name string
	// ConfigFilename is the config file name (e.g. "thunder.conf").
	ConfigFilename string
	// BasePort is the signet RPC port (e.g. 6009 for thunder).
	BasePort int
	// CliArgKeys are the conf keys the launch path passes on the command
	// line, in order. An empty list passes nothing. Name a key only after you
	// read the daemon's own CLI: a flag it does not know stops it on the first
	// boot, and a port it does not share with BinaryConfig.Port hides it from
	// the health check.
	CliArgKeys []string
	// EnforcerArg is the daemon flag for its mainchain URL or host.
	EnforcerArg string
	// PortStyle names the second endpoint the daemon binds, next to its RPC
	// and P2P ports.
	// "grpc" = mainchain-grpc-url (thunder, zside, photon, etc.)
	// "zmq"  = zmq-addr, the block hash publisher (bitassets, bitnames)
	PortStyle string
	// RPCKey is the conf key that holds the RPC endpoint. The daemons differ:
	// bitassets takes a bare port on --rpc-port, and the rest take a socket
	// address on --rpc-addr. An empty value reads as "rpc-addr".
	RPCKey string
	// DirKey is the chains_config.json key for the data directory lookup.
	DirKey string
}

// rpcEndpointKey names the conf key that holds the RPC endpoint.
func (s SidechainConfSpec) rpcEndpointKey() string {
	if s.RPCKey == "" {
		return "rpc-addr"
	}
	return s.RPCKey
}

// EnforcerArgs returns the daemon arguments for a mainchain endpoint.
func (s SidechainConfSpec) EnforcerArgs(endpoint string) ([]string, error) {
	switch s.EnforcerArg {
	case "mainchain-grpc-url":
		return []string{"--mainchain-grpc-url=" + endpoint}, nil
	case "mainchain-grpc-host":
		u, err := url.Parse(endpoint)
		if err != nil {
			return nil, fmt.Errorf("parse the enforcer endpoint: %w", err)
		}
		if u.Scheme != "http" || u.Hostname() == "" || u.Port() == "" || (u.Path != "" && u.Path != "/") {
			return nil, fmt.Errorf("%s accepts only an HTTP enforcer endpoint with a host and port", s.Name)
		}
		host := u.Hostname()
		if strings.Contains(host, ":") {
			host = "[" + host + "]"
		}
		return []string{"--mainchain-grpc-host=" + host, "--mainchain-grpc-port=" + u.Port()}, nil
	default:
		return nil, fmt.Errorf("%s does not support a remote enforcer", s.Name)
	}
}

// SidechainConfManager manages a sidechain's key-value config file.
// Generic replacement for ThunderConfManager and ZSideConfManager.
type SidechainConfManager struct {
	Config     *GenericAppConfig
	ConfigPath string
	Spec       SidechainConfSpec

	// BitcoinConf is the mainchain conf the sidechain network follows.
	BitcoinConf *BitcoinConfManager

	log zerolog.Logger

	watcher   *fsnotify.Watcher
	watchDone chan struct{}
}

// NewSidechainConfManager creates a new conf manager for the given sidechain.
func NewSidechainConfManager(spec SidechainConfSpec, bitcoinConf *BitcoinConfManager, log zerolog.Logger) (*SidechainConfManager, error) {
	m := &SidechainConfManager{
		Spec:        spec,
		BitcoinConf: bitcoinConf,
		log:         log.With().Str("component", spec.Name+"-conf").Logger(),
	}
	if err := m.LoadConfig(); err != nil {
		return nil, fmt.Errorf("load %s config: %w", spec.Name, err)
	}
	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		m.log.Warn().Err(err).Msgf("failed to sync %s config from bitcoin conf", spec.Name)
	}
	return m, nil
}

// LoadConfig loads the config from file, or creates default if not exists.
func (m *SidechainConfManager) LoadConfig() error {
	m.ConfigPath = m.getConfigPath()

	data, err := os.ReadFile(m.ConfigPath)
	if err == nil {
		m.Config = ParseGenericAppConfig(string(data))
		return nil
	}

	if !os.IsNotExist(err) {
		return fmt.Errorf("read %s config: %w", m.Spec.Name, err)
	}

	content := m.GetDefaultConfig()
	m.Config = ParseGenericAppConfig(content)

	if mkErr := os.MkdirAll(filepath.Dir(m.ConfigPath), 0755); mkErr != nil {
		m.log.Error().Err(mkErr).Msgf("failed to create %s config directory", m.Spec.Name)
	} else if wErr := os.WriteFile(m.ConfigPath, []byte(content), 0644); wErr != nil {
		m.log.Error().Err(wErr).Str("path", m.ConfigPath).Msgf("failed to write default %s config", m.Spec.Name)
	} else {
		m.log.Info().Str("path", m.ConfigPath).Msgf("created default %s config file", m.Spec.Name)
	}

	return nil
}

// GetDefaultConfig generates the default config content.
func (m *SidechainConfManager) GetDefaultConfig() string {
	ports := m.getNetworkPorts(m.resolveNetwork())
	rpcKey := m.Spec.rpcEndpointKey()

	switch m.Spec.PortStyle {
	case "zmq":
		return fmt.Sprintf(`# %s Configuration - Generated by Drivechaind
# These settings are converted to CLI arguments when %s starts.

# Run in headless mode (no GUI)
headless=true

# Log level for console output
log-level=DEBUG

# Log level for file output
log-level-file=WARN

# RPC endpoint
%s=%s

# P2P networking address
net-addr=%s

# ZMQ notification address
zmq-addr=%s

config-version=%d
`, m.Spec.Name, m.Spec.Name, rpcKey, ports[rpcKey], ports["net-addr"], ports["zmq-addr"], SidechainConfMigrationsVersion)

	default: // "grpc"
		return fmt.Sprintf(`# %s Configuration - Generated by Drivechaind
# These settings are converted to CLI arguments when %s starts.

# Run in headless mode (no GUI)
headless=true

# Log level for console output
log-level=DEBUG

# Log level for file output
log-level-file=WARN

# RPC endpoint
%s=%s

# P2P networking address
net-addr=%s

# Mainchain (Enforcer) gRPC connection URL
mainchain-grpc-url=%s

config-version=%d
`, m.Spec.Name, m.Spec.Name, rpcKey, ports[rpcKey], ports["net-addr"], ports["mainchain-grpc-url"], SidechainConfMigrationsVersion)
	}
}

// networkPortOffset returns what a network adds to a sidechain's base port,
// following the offsets Bitcoin Core gives its own chains: mainnet 8332,
// testnet3 18332, signet 38332.
//
// The live chain answers at the base port. That is the port a daemon listens
// on with no arguments, and the port its seed peers name, so a node started by
// hand and a node started by the launcher reach each other.
func networkPortOffset(network string) int {
	switch network {
	case "regtest":
		return 10000
	case "signet":
		return 30000
	default: // eCash, the live chain
		return 0
	}
}

// portGroups names every group getNetworkPorts answers with. A value from any
// of them came from an earlier sync, never from the user.
var portGroups = []string{"ecash", "regtest", "signet"}

// getNetworkPorts returns port mappings for the given network, derived from BasePort.
func (m *SidechainConfManager) getNetworkPorts(network string) map[string]string {
	return m.endpointsForOffset(networkPortOffset(network))
}

// endpointsForOffset builds the endpoints a port scheme gives, from what that
// scheme adds to the base port.
func (m *SidechainConfManager) endpointsForOffset(offset int) map[string]string {
	base := m.Spec.BasePort

	rpcPort := base + offset
	netPort := base - 2000 + offset

	endpoints := map[string]string{
		"net-addr": fmt.Sprintf("0.0.0.0:%d", netPort),
	}
	switch key := m.Spec.rpcEndpointKey(); key {
	case "rpc-port":
		endpoints[key] = strconv.Itoa(rpcPort)
	default:
		endpoints[key] = fmt.Sprintf("127.0.0.1:%d", rpcPort)
	}
	switch m.Spec.PortStyle {
	case "zmq":
		endpoints["zmq-addr"] = fmt.Sprintf("127.0.0.1:%d", base+22000+offset)
	default: // "grpc"
		endpoints["mainchain-grpc-url"] = "http://localhost:50051"
	}
	return endpoints
}

// GetCliArgs converts the named config keys to CLI args, and adds the network
// the daemon runs on.
func (m *SidechainConfManager) GetCliArgs() []string {
	var args []string
	if m.Config == nil || len(m.Spec.CliArgKeys) == 0 {
		return args
	}

	for _, key := range m.Spec.CliArgKeys {
		switch value := m.Config.GetSetting(key); value {
		case "", "false":
			continue
		case "true":
			args = append(args, fmt.Sprintf("--%s", key))
		default:
			args = append(args, fmt.Sprintf("--%s=%s", key, value))
		}
	}

	if m.BitcoinConf != nil {
		if name := CusfNetworkName(m.BitcoinConf.Network, ECashNetworkID()); name != "" {
			args = append(args, fmt.Sprintf("%s=%s", CliNetworkFlag, name))
		}
	}

	return args
}

// GetNetwork returns the network the sidechain follows. It reads the mainchain
// conf, never the sidechain file, so the two can never disagree.
func (m *SidechainConfManager) GetNetwork() string {
	return m.resolveNetwork()
}

// WriteConfig writes raw config content to file.
func (m *SidechainConfManager) WriteConfig(content string) error {
	m.Config = ParseGenericAppConfig(content)

	confPath := m.getConfigPath()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return fmt.Errorf("create dir: %w", err)
	}
	if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}

	m.log.Info().Str("path", confPath).Msgf("saved %s config", m.Spec.Name)
	return nil
}

// sidechainConfVersionKey records which port-scheme migrations already ran.
// A daemon never reads it, because the launch path passes only CliArgKeys.
const sidechainConfVersionKey = "config-version"

// sidechainConfMigration retires one port scheme. Offsets holds what that
// scheme added to the base port on each network it knew.
type sidechainConfMigration struct {
	Version int
	Offsets map[string]int
}

// sidechainConfMigrations lists every retired port scheme, oldest first. A
// migration drops an endpoint its scheme wrote, and the sync then writes the
// value the current scheme gives the same key.
var sidechainConfMigrations = []sidechainConfMigration{
	{
		Version: 1,
		Offsets: map[string]int{"mainnet": 20000, "regtest": 10000, "signet": 0},
	},
}

// SidechainConfMigrationsVersion is the version a config carries after every
// migration runs. A new config file starts there and skips them all.
var SidechainConfMigrationsVersion = len(sidechainConfMigrations)

// runConfMigrations drops every endpoint a retired port scheme wrote, and
// records which migrations ran. It reports whether the config changed.
func (m *SidechainConfManager) runConfMigrations() bool {
	version, _ := strconv.Atoi(m.Config.GetSetting(sidechainConfVersionKey))
	changed := false

	for _, migration := range sidechainConfMigrations {
		if migration.Version <= version {
			continue
		}
		for _, offset := range migration.Offsets {
			for key, retired := range m.endpointsForOffset(offset) {
				if m.Config.GetSetting(key) != retired {
					continue
				}
				m.Config.RemoveSetting(key)
			}
		}
		m.Config.SetSetting(sidechainConfVersionKey, strconv.Itoa(migration.Version))
		changed = true
	}

	return changed
}

// SyncNetworkFromBitcoinConf points the generated endpoints at the network the
// mainchain runs. A value the user typed is not the generated value on any
// network, so the sync keeps it.
func (m *SidechainConfManager) SyncNetworkFromBitcoinConf() error {
	if m.Config == nil || m.BitcoinConf == nil {
		return nil
	}

	changed := m.runConfMigrations()
	if m.Config.GetSetting(legacyNetworkKey) != "" {
		m.Config.RemoveSetting(legacyNetworkKey)
		changed = true
	}
	for key, value := range m.getNetworkPorts(m.resolveNetwork()) {
		current := m.Config.GetSetting(key)
		if current == value || !m.isGeneratedEndpoint(key, current) {
			continue
		}
		m.Config.SetSetting(key, value)
		changed = true
	}
	if !changed {
		return nil
	}
	return m.saveConfig()
}

// isGeneratedEndpoint reports whether value is the value this key takes on one
// of the networks. Such a value came from an earlier sync, so a network change
// may replace it. Anything else came from the user, and the sync keeps it.
//
// A user who types the value another network generates loses it. The file
// records no author, so the two cases read the same.
func (m *SidechainConfManager) isGeneratedEndpoint(key, value string) bool {
	if value == "" {
		return true
	}
	for _, network := range portGroups {
		if m.getNetworkPorts(network)[key] == value {
			return true
		}
	}
	return false
}

func (m *SidechainConfManager) resolveNetwork() string {
	if m.BitcoinConf == nil {
		return "signet"
	}
	switch m.BitcoinConf.Network {
	case NetworkRegtest:
		return "regtest"
	case NetworkECash:
		return "ecash"
	default:
		return "signet"
	}
}

func (m *SidechainConfManager) saveConfig() error {
	if m.Config == nil {
		return nil
	}
	confPath := m.getConfigPath()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return err
	}
	if err := os.WriteFile(confPath, []byte(m.Config.Serialize()), 0644); err != nil {
		return fmt.Errorf("save %s config: %w", m.Spec.Name, err)
	}
	m.log.Info().Str("path", confPath).Msgf("saved %s config", m.Spec.Name)
	return nil
}

func (m *SidechainConfManager) getConfigPath() string {
	dirs := MustDirConfig(m.Spec.DirKey)
	return filepath.Join(dirs.RootDir(), m.Spec.ConfigFilename)
}

// StartWatching watches the config directory for file changes.
func (m *SidechainConfManager) StartWatching() error {
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

	m.log.Debug().Str("dir", confDir).Msgf("%s config file watching enabled", m.Spec.Name)
	return nil
}

func (m *SidechainConfManager) StopWatching() {
	if m.watcher != nil {
		_ = m.watcher.Close()
	}
	if m.watchDone != nil {
		<-m.watchDone
	}
}

func (m *SidechainConfManager) watchLoop() {
	defer close(m.watchDone)

	var debounce *time.Timer
	var mu sync.Mutex

	for {
		select {
		case event, ok := <-m.watcher.Events:
			if !ok {
				return
			}
			if !strings.HasSuffix(event.Name, m.Spec.ConfigFilename) {
				continue
			}
			if event.Op&(fsnotify.Write|fsnotify.Create) == 0 {
				continue
			}

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
			m.log.Error().Err(err).Msgf("%s config watcher error", m.Spec.Name)
		}
	}
}

func (m *SidechainConfManager) reloadConfigFromFileSystem() {
	m.log.Info().Msgf("reloading %s config due to file system change", m.Spec.Name)

	confPath := m.getConfigPath()
	data, err := os.ReadFile(confPath)
	if err != nil {
		m.log.Error().Err(err).Msgf("failed to read %s config", m.Spec.Name)
		return
	}

	newConfig := ParseGenericAppConfig(string(data))
	if m.Config != nil && m.Config.Serialize() == newConfig.Serialize() {
		return
	}

	m.Config = newConfig
}

// KnownSidechainSpecs defines the configuration specs for all known sidechains.
var KnownSidechainSpecs = map[string]SidechainConfSpec{
	"thunder": {
		Name:           "Thunder",
		ConfigFilename: "thunder.conf",
		BasePort:       6009,
		CliArgKeys:     []string{"net-addr", "mainchain-grpc-url"},
		EnforcerArg:    "mainchain-grpc-url",
		PortStyle:      "grpc",
		RPCKey:         "rpc-addr",
		DirKey:         "thunder",
	},
	"bitassets": {
		EnforcerArg:    "mainchain-grpc-host",
		Name:           "BitAssets",
		ConfigFilename: "bitassets.conf",
		BasePort:       6004,
		CliArgKeys:     []string{"net-addr", "zmq-addr"},
		PortStyle:      "zmq",
		RPCKey:         "rpc-port",
		DirKey:         "bitassets",
	},
	"bitnames": {
		EnforcerArg:    "mainchain-grpc-host",
		Name:           "BitNames",
		ConfigFilename: "bitnames.conf",
		BasePort:       6002,
		CliArgKeys:     []string{"net-addr", "zmq-addr"},
		PortStyle:      "zmq",
		RPCKey:         "rpc-addr",
		DirKey:         "bitnames",
	},
	"zside": {
		EnforcerArg:    "mainchain-grpc-url",
		Name:           "ZSide",
		ConfigFilename: "zside.conf",
		BasePort:       6098,
		PortStyle:      "grpc",
		RPCKey:         "rpc-addr",
		DirKey:         "zside",
	},
	"photon": {
		EnforcerArg:    "mainchain-grpc-url",
		Name:           "Photon",
		ConfigFilename: "photon.conf",
		BasePort:       6099,
		CliArgKeys:     []string{"net-addr", "mainchain-grpc-url"},
		PortStyle:      "grpc",
		RPCKey:         "rpc-addr",
		DirKey:         "photon",
	},
	"truthcoin": {
		EnforcerArg:    "mainchain-grpc-host",
		Name:           "Truthcoin",
		ConfigFilename: "truthcoin.conf",
		BasePort:       6013,
		PortStyle:      "grpc",
		RPCKey:         "rpc-addr",
		DirKey:         "truthcoin",
	},
	"coinshift": {
		EnforcerArg:    "mainchain-grpc-url",
		Name:           "CoinShift",
		ConfigFilename: "coinshift.conf",
		BasePort:       6255,
		CliArgKeys:     []string{"net-addr", "mainchain-grpc-url"},
		PortStyle:      "grpc",
		RPCKey:         "rpc-addr",
		DirKey:         "coinshift",
	},
	"liquid-signet": {
		Name:           "Elements Alpha",
		ConfigFilename: "liquid-signet.conf",
		BasePort:       29443,
		PortStyle:      "grpc",
		RPCKey:         "rpc-addr",
		DirKey:         "liquid-signet",
	},
}
