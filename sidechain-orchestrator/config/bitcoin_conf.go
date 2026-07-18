package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"

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

// GetRPCHost returns the effective RPC host (rpcconnect or local default).
func (m *BitcoinConfManager) GetRPCHost() string {
	if m.Config != nil {
		section := CoreSectionForNetwork(m.Network)
		if host := m.Config.GetEffectiveSetting("rpcconnect", section); host != "" {
			return host
		}
	}
	return "127.0.0.1"
}

// GetDefaultConfig generates the default bitcoin.conf content.
// Port of getDefaultConfig() from bitcoin_conf_provider.dart.
//
// One unified template across all networks: a common settings block (RPC,
// ZMQ, perf knobs, uacomment) that's identical everywhere, plus per-network
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
	case NetworkDrynet2:
		// drynet2 also runs chain=main. It has no DNS seeds, so it needs an
		// explicit peer. uacomment=drynet2 is the sentinel that tells drynet2
		// apart from forknet in NetworkFromConfig.
		mainSection = `# drynet2-specific settings (drivechain testnet on mainnet params)
[main]
port=8301
rpcport=18302
rpcbind=127.0.0.1
rpcallowip=0.0.0.0/0
addnode=drynet2.drivechain.dev:8335
uacomment=drynet2
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

	return fmt.Sprintf(`%s%d

# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config settings

# Common settings for all networks
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
rpcthreads=10
rpcworkqueue=50
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
signetchallenge=00148835832e28c816b7acd8fdb19772ab2199603a56
acceptnonstdtxn=1
fallbackfee=0.00021

%s
# Testnet-specific settings
[test]
fallbackfee=0.00021

# Regtest-specific settings
[regtest]
fallbackfee=0.00021
`, bitcoinConfVersionCommentPrefix, BitcoinConfMigrationsVersion, currentNetwork, mainSection)
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

// UpdateNetwork writes the new network to the config file. On a cross-group
// swap (default ↔ forknet) it first snapshots the live `datadir=` value into
// the leaving group's slot, then materializes the entering group's slot into
// `datadir=`. Within a group, datadir is left untouched (Bitcoin Core's chain
// subdirs partition the four default networks under the same folder).
// 1:1 port of Dart updateNetwork (frontend_bitcoin_conf_provider.dart L290).
func (m *BitcoinConfManager) UpdateNetwork(n Network) error {
	if m.HasPrivateConf {
		m.log.Warn().Msg("cannot update network - controlled by your bitcoin.conf")
		return nil
	}
	if m.Config == nil {
		return nil
	}

	oldGroup := DatadirGroupForNetwork(m.Network)
	newGroup := DatadirGroupForNetwork(n)
	if oldGroup != newGroup {
		// Snapshot the live datadir into the leaving group's slot so we can
		// restore it on the next swap back. Honor a user's manual
		// datadir= edit by adopting it as the leaving group's value.
		if liveDatadir := m.Config.GetSetting("datadir"); liveDatadir != "" {
			m.Config.SetGroupDatadir(oldGroup, liveDatadir)
		}
	}

	chainValue := "signet"
	switch n {
	case NetworkMainnet, NetworkForknet, NetworkDrynet2:
		chainValue = "main"
	case NetworkTestnet:
		chainValue = "test"
	case NetworkSignet:
		chainValue = "signet"
	case NetworkRegtest:
		chainValue = "regtest"
	}
	m.Config.SetSetting("chain", chainValue)

	m.applyMainSectionDefaults(n)

	if oldGroup != newGroup {
		m.materializeDatadirForGroup(newGroup)
	}

	return m.saveConfig()
}

// loadOrCreateConfigContent loads config content from BitWindow config file, or creates default if missing.
// Runs versioned migrations on load when stored version < current.
// 1:1 port of Dart _loadOrCreateConfigContent (frontend_bitcoin_conf_provider.dart L132).
func (m *BitcoinConfManager) loadOrCreateConfigContent() (string, error) {
	confPath := m.getBitWindowConfigPath()

	data, readErr := os.ReadFile(confPath)
	if readErr == nil {
		content := string(data)
		config := ParseBitcoinConfig(content)

		if migrated, wipeNetworks := RunBitcoinConfMigrations(config); migrated {
			m.wipeStaleChainData(config, wipeNetworks)
			content = config.Serialize()
			if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
				m.log.Error().Err(err).Msg("failed to write migrated config")
			} else {
				m.log.Info().Int("version", config.ConfigVersion).Msg("migrated bitwindow-bitcoin.conf")
			}
		}
		return content, nil
	}

	// The file exists but couldn't be read (permissions, partial write, a
	// directory in its place, transient FS error on the external volume, …).
	// Regenerating defaults here would silently destroy the user's datadir +
	// custom settings — exactly the data-loss bug we're guarding against. Fail
	// closed so the L1 stack refuses to boot rather than clobber a recoverable
	// file. Only a genuine "not found" is a real first-run.
	if !os.IsNotExist(readErr) {
		m.log.Error().Err(readErr).Str("path", confPath).
			Msg("bitwindow-bitcoin.conf exists but is unreadable; refusing to overwrite with defaults")
		return "", fmt.Errorf("read bitcoin config %s: %w", confPath, readErr)
	}

	// First run: no conf on disk. Defense in depth — if a file somehow appears
	// at the path between the read and now, back it up before writing defaults
	// so a regeneration is never destructive.
	if _, statErr := os.Stat(confPath); statErr == nil {
		backupPath := confPath + ".bak"
		if existing, err := os.ReadFile(confPath); err == nil {
			if werr := os.WriteFile(backupPath, existing, 0644); werr != nil {
				m.log.Warn().Err(werr).Str("path", backupPath).Msg("failed to back up existing config before regenerating")
			} else {
				m.log.Warn().Str("backup", backupPath).Msg("backed up existing config before writing defaults")
			}
		}
	}

	content := m.GetDefaultConfig()
	if err := os.MkdirAll(filepath.Dir(confPath), 0755); err != nil {
		m.log.Error().Err(err).Msg("failed to create config directory")
	} else if err := os.WriteFile(confPath, []byte(content), 0644); err != nil {
		m.log.Error().Err(err).Str("path", confPath).Msg("failed to write default config")
	} else {
		m.log.Info().Str("path", confPath).Msg("created default config file (no existing conf found)")
	}

	return content, nil
}

// wipeStaleChainData deletes chain state invalidated by a migration. Runs
// before the bumped config version is persisted, so a crash mid-wipe retries
// the migration (and wipe) on the next boot.
func (m *BitcoinConfManager) wipeStaleChainData(config *BitcoinConfig, networks []Network) {
	if len(networks) == 0 {
		return
	}
	if m.getConfigFileInfo().hasPrivateConf {
		// That user's chain data follows their own bitcoin.conf, not ours.
		m.log.Warn().Msg("skipping chain data wipe - user bitcoin.conf takes precedence")
		return
	}
	for _, n := range networks {
		override := config.GetEffectiveSetting("datadir", CoreSectionForNetwork(n))
		m.log.Info().Str("network", string(n)).Msg("migration invalidated chain data, wiping")
		WipeChainData(n, override, m.log)
	}
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
