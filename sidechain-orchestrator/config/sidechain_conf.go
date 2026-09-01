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
	case NetworkForknet:
		return "forknet"
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
	// PortStyle determines which config keys are used for network ports.
	// "grpc" = rpc-addr, net-addr, mainchain-grpc-url (thunder, zside, photon, etc.)
	// "zmq"  = rpc-port, net-addr, zmq-addr (bitassets, bitnames)
	PortStyle string
	// DirKey is the chains_config.json key for the data directory lookup.
	DirKey string
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

# RPC port
rpc-port=%s

# P2P networking address
net-addr=%s

# ZMQ notification address
zmq-addr=%s
`, m.Spec.Name, m.Spec.Name, ports["rpc-port"], ports["net-addr"], ports["zmq-addr"])

	default: // "grpc"
		return fmt.Sprintf(`# %s Configuration - Generated by Drivechaind
# These settings are converted to CLI arguments when %s starts.

# Run in headless mode (no GUI)
headless=true

# Log level for console output
log-level=DEBUG

# Log level for file output
log-level-file=WARN

# RPC server address
rpc-addr=%s

# P2P networking address
net-addr=%s

# Mainchain (Enforcer) gRPC connection URL
mainchain-grpc-url=%s
`, m.Spec.Name, m.Spec.Name, ports["rpc-addr"], ports["net-addr"], ports["mainchain-grpc-url"])
	}
}

// getNetworkPorts returns port mappings for the given network, derived from BasePort.
func (m *SidechainConfManager) getNetworkPorts(network string) map[string]string {
	base := m.Spec.BasePort
	var offset int
	switch network {
	case "regtest":
		offset = 10000
	case "mainnet":
		offset = 20000
	default: // signet
		offset = 0
	}

	rpcPort := base + offset
	netPort := base - 2000 + offset

	switch m.Spec.PortStyle {
	case "zmq":
		zmqPort := base + 22000 + offset
		return map[string]string{
			"rpc-port": fmt.Sprintf("%d", rpcPort),
			"net-addr": fmt.Sprintf("0.0.0.0:%d", netPort),
			"zmq-addr": fmt.Sprintf("127.0.0.1:%d", zmqPort),
		}
	default: // "grpc"
		return map[string]string{
			"rpc-addr":           fmt.Sprintf("127.0.0.1:%d", rpcPort),
			"net-addr":           fmt.Sprintf("0.0.0.0:%d", netPort),
			"mainchain-grpc-url": "http://localhost:50051",
		}
	}
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

// SyncNetworkFromBitcoinConf points the generated endpoints at the network the
// mainchain runs. A value the user typed is not the generated value on any
// network, so the sync keeps it.
func (m *SidechainConfManager) SyncNetworkFromBitcoinConf() error {
	if m.Config == nil || m.BitcoinConf == nil {
		return nil
	}

	changed := false
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
	for _, network := range []string{"signet", "regtest", "mainnet"} {
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
	case NetworkForknet, NetworkECash:
		return "mainnet"
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
		PortStyle:      "grpc",
		DirKey:         "thunder",
	},
	"bitassets": {
		Name:           "BitAssets",
		ConfigFilename: "bitassets.conf",
		BasePort:       6004,
		PortStyle:      "zmq",
		DirKey:         "bitassets",
	},
	"bitnames": {
		Name:           "BitNames",
		ConfigFilename: "bitnames.conf",
		BasePort:       6002,
		PortStyle:      "zmq",
		DirKey:         "bitnames",
	},
	"zside": {
		Name:           "ZSide",
		ConfigFilename: "zside.conf",
		BasePort:       6098,
		PortStyle:      "grpc",
		DirKey:         "zside",
	},
	"photon": {
		Name:           "Photon",
		ConfigFilename: "photon.conf",
		BasePort:       6099,
		PortStyle:      "grpc",
		DirKey:         "photon",
	},
	"truthcoin": {
		Name:           "Truthcoin",
		ConfigFilename: "truthcoin.conf",
		BasePort:       6013,
		PortStyle:      "grpc",
		DirKey:         "truthcoin",
	},
	"coinshift": {
		Name:           "CoinShift",
		ConfigFilename: "coinshift.conf",
		BasePort:       6255,
		PortStyle:      "grpc",
		DirKey:         "coinshift",
	},
	"liquid-signet": {
		Name:           "Liquid Signet",
		ConfigFilename: "liquid-signet.conf",
		BasePort:       29443,
		PortStyle:      "grpc",
		DirKey:         "liquid-signet",
	},
}
