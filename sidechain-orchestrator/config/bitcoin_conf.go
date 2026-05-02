package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/fsnotify/fsnotify"
	"github.com/rs/zerolog"
)

const bitwindowBitcoinConfFilename = "bitwindow-bitcoin.conf"

// BitcoinConfManager manages Bitcoin Core configuration files.
// Port of the data/config logic from sail_ui/lib/providers/bitcoin_conf_provider.dart.
// UI-specific logic (file watching, navigation, restart) is omitted.
type BitcoinConfManager struct {
	BitwindowDir    string
	Network         Network
	Config          *BitcoinConfig
	ConfigPath      string
	DetectedDataDir string
	HasPrivateConf  bool
	log             zerolog.Logger

	// OnNetworkChanged is called after a network switch completes.
	// Set by the server to restart services (orchestrator binaries).
	OnNetworkChanged func()

	// File watching (managed by StartWatching/StopWatching)
	watcher   *fsnotify.Watcher
	watchDone chan struct{}
}

// NewBitcoinConfManager creates a new BitcoinConfManager and loads config.
// defaultNetwork seeds the network used to generate the conf on first boot
// (when no bitwindow-bitcoin.conf exists yet); once the conf exists, its
// chain= setting drives the manager and the seed is ignored.
func NewBitcoinConfManager(bitwindowDir string, defaultNetwork Network, log zerolog.Logger) (*BitcoinConfManager, error) {
	if defaultNetwork == "" {
		defaultNetwork = NetworkSignet
	}
	m := &BitcoinConfManager{
		BitwindowDir: bitwindowDir,
		Network:      defaultNetwork,
		log:          log.With().Str("component", "bitcoin-conf").Logger(),
	}
	if err := m.LoadConfig(true); err != nil {
		return nil, fmt.Errorf("load bitcoin config: %w", err)
	}
	return m, nil
}

// LoadConfig loads or creates the Bitcoin configuration file.
// 1:1 port of Dart loadConfig (frontend_bitcoin_conf_provider.dart L103).
func (m *BitcoinConfManager) LoadConfig(isFirst bool) error {
	oldNetwork := m.Network

	content, err := m.loadOrCreateConfigContent()
	if err != nil {
		m.log.Error().Err(err).Msg("failed to load config")
		return err
	}

	m.parseAndApplyConfig(content)

	if m.tryLoadPrivateConfig() {
		return nil // Private config loaded, we're done, just use that
	}

	m.handleNetworkChangeIfNeeded(oldNetwork, isFirst)

	if err := m.CopyConfigDownstream(); err != nil {
		m.log.Warn().Err(err).Msg("copy downstream on load")
	}

	// _promptForDatadirIfNeeded — UI-only, skipped in Go backend

	return nil
}

// GetConfFilePath returns the resolved -conf= path to pass to bitcoind.
// Mirrors the confFile() logic from binaries.dart.
func (m *BitcoinConfManager) GetConfFilePath() string {
	confInfo := m.getConfigFileInfo()
	return confInfo.path
}

// GetRPCPort returns the effective RPC port (config or network default).
func (m *BitcoinConfManager) GetRPCPort() int {
	if m.Config != nil {
		section := CoreSectionForNetwork(m.Network)
		portStr := m.Config.GetEffectiveSetting("rpcport", section)
		if portStr != "" {
			if port, err := strconv.Atoi(portStr); err == nil {
				return port
			}
		}
	}
	return RPCPortForNetwork(m.Network)
}

// GetDefaultConfig generates the default bitcoin.conf content.
// Port of getDefaultConfig() from bitcoin_conf_provider.dart.
//
// One unified template across all networks: a common settings block (datadir,
// RPC, ZMQ, perf knobs, uacomment) that's identical everywhere, plus per-network
// [main]/[signet]/[test]/[regtest] sections for the actual differences. The
// enforcer is now expected to run on mainnet too, so it gets the same perf
// settings (rpcthreads, rpcworkqueue) and ZMQ wiring as the other networks.
//
// fallbackfee deliberately lives only in the non-mainnet sections — Bitcoin
// Core rejects a non-zero fallbackfee on mainnet, and the setting is mainly
// useful for testnet/signet/regtest where fee estimation is unreliable.
func (m *BitcoinConfManager) GetDefaultConfig() string {
	currentNetwork := CoreSectionForNetwork(m.Network)

	// Per-network [main] section overrides. Mainnet has no [main] overrides;
	// signet/testnet/regtest options live in their own sections below.
	// Forknet uses [main] because its chain= is "main" (it's a drivechain
	// testnet on mainnet params).
	var mainSection string
	switch m.Network {
	case NetworkForknet:
		// Forknet runs as chain=main, so fallbackfee belongs here (not in
		// the common block) — Bitcoin Core rejects fallbackfee on real
		// mainnet but accepts it on this drivechain testnet.
		mainSection = `# Forknet-specific settings (drivechain testnet on mainnet params)
[main]
port=8300
rpcport=18301
rpcbind=127.0.0.1
rpcallowip=0.0.0.0/0
assumevalid=0000000000000000000000000000000000000000000000000000000000000000
minimumchainwork=0x00
listenonion=0
drivechain=1
fallbackfee=0.00021
`
	default:
		mainSection = `# Mainnet-specific settings
[main]
`
	}

	// Pin datadir explicitly so bitcoind doesn't silently fall back to
	// ~/.bitcoin/Bitcoin/etc. Mainnet → Bitcoin Core's standard datadir;
	// every other network → Drivechain dir.
	datadir := m.rootDirNetwork(m.Network)

	return fmt.Sprintf(`%s%d

# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config settings

# Common settings for all networks
datadir=%s
rpcuser=user
rpcpassword=password
server=1
listen=1
txindex=1
zmqpubsequence=tcp://127.0.0.1:29000
zmqpubhashblock=tcp://127.0.0.1:29001
zmqpubhashtx=tcp://127.0.0.1:29002
zmqpubrawblock=tcp://127.0.0.1:29003
zmqpubrawtx=tcp://127.0.0.1:29004
rpcthreads=20
rpcworkqueue=100
rest=1
uacomment=BitWindow-0.2
chain=%s # current network

# [Sections]
# If you want to confine an option to just one network,
# you should add it in the relevant section.

# EXCEPTIONS: The options addnode, connect, port, bind,
# rpcport, rpcbind and wallet
# only apply to mainnet unless they appear in the
# appropriate section below.

# Signet-specific settings
[signet]
addnode=172.105.148.135:38333
signetblocktime=600
signetchallenge=a91484fa7c2460891fe5212cb08432e21a4207909aa987
acceptnonstdtxn=1
fallbackfee=0.00021

%s
# Testnet-specific settings
[test]
fallbackfee=0.00021

# Regtest-specific settings
[regtest]
fallbackfee=0.00021
`, bitcoinConfVersionCommentPrefix, BitcoinConfMigrationsVersion, datadir, currentNetwork, mainSection)
}

// SaveConfig writes the current config to disk.
func (m *BitcoinConfManager) SaveConfig() error {
	if m.Config == nil || m.HasPrivateConf {
		return nil
	}
	confPath := m.getBitWindowConfigPath()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		return err
	}
	return os.WriteFile(confPath, []byte(m.Config.Serialize()), 0644)
}

// UpdateNetwork writes the new network to the config file.
// 1:1 port of Dart updateNetwork (frontend_bitcoin_conf_provider.dart L290).
func (m *BitcoinConfManager) UpdateNetwork(n Network) error {
	if m.HasPrivateConf {
		m.log.Warn().Msg("cannot update network - controlled by your bitcoin.conf")
		return nil
	}
	if m.Config == nil {
		return nil
	}

	chainValue := "signet"
	switch n {
	case NetworkMainnet:
		chainValue = "main"
	case NetworkForknet:
		chainValue = "main"
	case NetworkTestnet:
		chainValue = "test"
	case NetworkSignet:
		chainValue = "signet"
	case NetworkRegtest:
		chainValue = "regtest"
	}
	m.Config.SetSetting("chain", chainValue)

	switch n {
	case NetworkForknet:
		m.Config.SetSetting("drivechain", "1", "main")
	case NetworkMainnet:
		m.Config.RemoveSetting("drivechain", "main")
	default:
	}

	return m.saveConfig()
}

// loadOrCreateConfigContent loads config content from BitWindow config file, or creates default if missing.
// Runs versioned migrations on load when stored version < current.
// First migrates bitwindow-forknet.conf, then checks network to apply forknet data.
// 1:1 port of Dart _loadOrCreateConfigContent (frontend_bitcoin_conf_provider.dart L132).
func (m *BitcoinConfManager) loadOrCreateConfigContent() (string, error) {
	confPath := m.getBitWindowConfigPath()

	// Always migrate forknet and mainnet configs first (if they exist or have pending migrations)
	if err := m.migrateForknetConfig(); err != nil {
		m.log.Warn().Err(err).Msg("migrate forknet config")
	}
	if err := m.migrateMainnetConfig(); err != nil {
		m.log.Warn().Err(err).Msg("migrate mainnet config")
	}

	if data, err := os.ReadFile(confPath); err == nil {
		content := string(data)
		config := ParseBitcoinConfig(content)

		// Determine if current config is forknet (chain=main + drivechain=1)
		chainSetting := strings.ToLower(config.GetSetting("chain"))
		drivechainSetting := config.GetEffectiveSetting("drivechain", "main")
		isForknet := (chainSetting == "main" || chainSetting == "mainnet") && drivechainSetting == "1"

		// Run migrations — forknet data only applies to [main] if currently on forknet
		if RunBitcoinConfMigrations(config, isForknet) {
			content = config.Serialize()
			if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
				m.log.Error().Err(err).Msg("failed to write migrated config")
			} else {
				m.log.Info().Int("version", config.ConfigVersion).Bool("isForknet", isForknet).Msg("migrated bitwindow-bitcoin.conf")
			}
		}
		return content, nil
	}

	// Create default config
	content := m.GetDefaultConfig()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		m.log.Error().Err(err).Msg("failed to create config directory")
	} else if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
		m.log.Error().Err(err).Str("path", confPath).Msg("failed to write default config")
	} else {
		m.log.Info().Str("path", confPath).Msg("created default config file")
	}

	return content, nil
}

type configFileInfo struct {
	hasPrivateConf bool
	path           string
}

// getConfigFileInfo checks for user's bitcoin.conf vs generated config.
// Dart: _getConfigFileInfo (L529-544)
func (m *BitcoinConfManager) getConfigFileInfo() configFileInfo {
	// Dart: For mainnet, use standard Bitcoin datadir; otherwise use Drivechain datadir
	confDir := BitcoinCoreDirs.RootDirNetwork(m.Network)

	// Always check for bitcoin.conf first - user config takes priority
	bitcoinConfPath := filepath.Join(confDir, "bitcoin.conf")
	if _, err := os.Stat(bitcoinConfPath); err == nil {
		return configFileInfo{hasPrivateConf: true, path: bitcoinConfPath}
	}

	// Use master config file in BitWindow directory (source of truth)
	return configFileInfo{
		hasPrivateConf: false,
		path:           filepath.Join(m.BitwindowDir, bitwindowBitcoinConfFilename),
	}
}

func (m *BitcoinConfManager) getBitWindowConfigPath() string {
	return filepath.Join(m.BitwindowDir, bitwindowBitcoinConfFilename)
}

// rootDirNetwork returns the root data directory for a network.
// Dart: BitcoinCore().rootDirNetwork(network)
func (m *BitcoinConfManager) rootDirNetwork(n Network) string {
	return BitcoinCoreDirs.RootDirNetwork(n)
}
