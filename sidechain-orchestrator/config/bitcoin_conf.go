package config

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strconv"

	"github.com/rs/zerolog"
)

const bitwindowBitcoinConfFilename = "bitwindow-bitcoin.conf"

// BitcoinConfManager manages Bitcoin Core configuration files.
// Port of the data/config logic from sail_ui/lib/providers/bitcoin_conf_provider.dart.
// UI-specific logic (file watching, navigation, restart) is omitted.
type BitcoinConfManager struct {
	BitwindowDir   string
	Network        Network
	Config         *BitcoinConfig
	ConfigPath     string
	DetectedDataDir string
	HasPrivateConf bool
	log            zerolog.Logger
}

// NewBitcoinConfManager creates a new BitcoinConfManager and loads config.
func NewBitcoinConfManager(bitwindowDir string, log zerolog.Logger) (*BitcoinConfManager, error) {
	m := &BitcoinConfManager{
		BitwindowDir: bitwindowDir,
		Network:      NetworkSignet, // default before config is loaded
		log:          log.With().Str("component", "bitcoin-conf").Logger(),
	}
	if err := m.LoadConfig(); err != nil {
		return nil, fmt.Errorf("load bitcoin config: %w", err)
	}
	return m, nil
}

// LoadConfig loads or creates the Bitcoin configuration file.
func (m *BitcoinConfManager) LoadConfig() error {
	content, err := m.loadOrCreateConfigContent()
	if err != nil {
		return err
	}

	m.Config = ParseBitcoinConfig(content)
	m.Network = NetworkFromConfig(m.Config)
	m.DetectedDataDir = m.Config.GetEffectiveSetting("datadir", CoreSectionForNetwork(m.Network))

	// Check for user's private bitcoin.conf
	confInfo := m.getConfigFileInfo()
	m.HasPrivateConf = confInfo.hasPrivateConf
	m.ConfigPath = confInfo.path

	if m.HasPrivateConf {
		privateContent, err := os.ReadFile(confInfo.path)
		if err == nil {
			m.Config = ParseBitcoinConfig(string(privateContent))
			m.Network = NetworkFromConfig(m.Config)
			m.DetectedDataDir = m.Config.GetEffectiveSetting("datadir", CoreSectionForNetwork(m.Network))
		}
	}

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
func (m *BitcoinConfManager) GetDefaultConfig() string {
	currentNetwork := CoreSectionForNetwork(m.Network)

	// Real mainnet gets minimal standard Bitcoin Core config
	if m.Network == NetworkMainnet {
		mainnetDatadir := m.rootDirNetwork(NetworkMainnet)
		return fmt.Sprintf(`# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config settings

# Standard Bitcoin Core mainnet configuration
datadir=%s
rpcuser=user
rpcpassword=password
server=1
listen=1
txindex=1
chain=main
`, mainnetDatadir)
	}

	// Build [main] section based on network
	var mainSection string
	if m.Network == NetworkForknet {
		mainSection = `# Forknet-specific settings (drivechain testnet on mainnet params)
[main]
port=8300
rpcport=18301
rpcbind=127.0.0.1
rpcallowip=0.0.0.0/0
zmqpubhashblock=tcp://127.0.0.1:29001
zmqpubhashtx=tcp://127.0.0.1:29002
zmqpubrawblock=tcp://127.0.0.1:29003
zmqpubrawtx=tcp://127.0.0.1:29004
assumevalid=0000000000000000000000000000000000000000000000000000000000000000
minimumchainwork=0x00
listenonion=0
drivechain=1
`
	} else {
		mainSection = `# Fill mainnet-specific settings here
[main]
`
	}

	return fmt.Sprintf(`# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config settings

# Common settings for all networks
rpcuser=user
rpcpassword=password
server=1
listen=1
txindex=1
zmqpubsequence=tcp://127.0.0.1:29000
rpcthreads=20
rpcworkqueue=100
rest=1
fallbackfee=0.00021
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

%s
# Testnet-specific settings
[test]

# Regtest-specific settings
[regtest]
`, currentNetwork, mainSection)
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

// UpdateNetwork updates the network setting in the config.
func (m *BitcoinConfManager) UpdateNetwork(n Network) error {
	if m.HasPrivateConf || m.Config == nil {
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

	if n == NetworkForknet {
		m.Config.SetSetting("drivechain", "1", "main")
	} else if n == NetworkMainnet {
		m.Config.RemoveSetting("drivechain", "main")
	}

	m.Network = n
	return m.SaveConfig()
}

// loadOrCreateConfigContent loads existing config or creates default.
func (m *BitcoinConfManager) loadOrCreateConfigContent() (string, error) {
	confPath := m.getBitWindowConfigPath()

	data, err := os.ReadFile(confPath)
	if err == nil {
		return string(data), nil
	}

	if !os.IsNotExist(err) {
		return "", fmt.Errorf("read config: %w", err)
	}

	// Create default config
	content := m.GetDefaultConfig()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		m.log.Error().Err(err).Msg("failed to create config directory")
	} else if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
		m.log.Error().Err(err).Str("path", confPath).Msg("failed to write default config")
	} else {
		m.log.Info().Str("path", confPath).Msg("created default bitcoin config")
	}

	return content, nil
}

type configFileInfo struct {
	hasPrivateConf bool
	path           string
}

// getConfigFileInfo checks for user's bitcoin.conf vs generated config.
// Mirrors _getConfigFileInfo() from bitcoin_conf_provider.dart and
// confFile() from binaries.dart.
func (m *BitcoinConfManager) getConfigFileInfo() configFileInfo {
	// Determine where to look for bitcoin.conf
	var confDir string
	if m.Network == NetworkMainnet {
		confDir = filepath.Join(bitcoinAppDir(), "Bitcoin")
	} else {
		confDir = drivechainDir()
	}

	// Check for user's bitcoin.conf first
	bitcoinConfPath := filepath.Join(confDir, "bitcoin.conf")
	if _, err := os.Stat(bitcoinConfPath); err == nil {
		return configFileInfo{hasPrivateConf: true, path: bitcoinConfPath}
	}

	// Use master config in BitWindow directory
	return configFileInfo{
		hasPrivateConf: false,
		path:           filepath.Join(m.BitwindowDir, bitwindowBitcoinConfFilename),
	}
}

func (m *BitcoinConfManager) getBitWindowConfigPath() string {
	return filepath.Join(m.BitwindowDir, bitwindowBitcoinConfFilename)
}

// rootDirNetwork returns the root data directory for a network.
func (m *BitcoinConfManager) rootDirNetwork(n Network) string {
	switch n {
	case NetworkMainnet:
		return filepath.Join(bitcoinAppDir(), "Bitcoin")
	default:
		return drivechainDir()
	}
}

// bitcoinAppDir returns the platform-specific Bitcoin application directory.
func bitcoinAppDir() string {
	home, _ := os.UserHomeDir()
	switch runtime.GOOS {
	case "darwin":
		return filepath.Join(home, "Library", "Application Support")
	case "windows":
		return filepath.Join(home, "AppData", "Roaming")
	default: // linux
		return home
	}
}

// drivechainDir returns the Drivechain data directory.
func drivechainDir() string {
	home, _ := os.UserHomeDir()
	switch runtime.GOOS {
	case "darwin":
		return filepath.Join(home, "Library", "Application Support", "Drivechain")
	case "windows":
		return filepath.Join(home, "AppData", "Roaming", "Drivechain")
	default: // linux
		return filepath.Join(home, ".drivechain")
	}
}
