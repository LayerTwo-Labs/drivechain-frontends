package config

import "strings"

// Network represents the Bitcoin network type.
type Network string

const (
	NetworkMainnet Network = "mainnet"
	NetworkForknet Network = "forknet"
	NetworkSignet  Network = "signet"
	NetworkRegtest Network = "regtest"
	NetworkTestnet Network = "testnet"
)

// DatadirGroup partitions networks by which folder bitcoind writes to.
// Forknet runs on chain=main and writes to the root of datadir, colliding
// with mainnet — so it needs its own group. The four "default" networks
// share one datadir because Bitcoin Core auto-partitions them via chain
// subdirectories (signet/, testnet3/, regtest/, blocks/ for mainnet).
type DatadirGroup string

const (
	DatadirGroupDefault DatadirGroup = "default"
	DatadirGroupForknet DatadirGroup = "forknet"
)

// DatadirGroupForNetwork returns the datadir group a network belongs to.
func DatadirGroupForNetwork(n Network) DatadirGroup {
	if n == NetworkForknet {
		return DatadirGroupForknet
	}
	return DatadirGroupDefault
}

// RPCPortForNetwork returns the default RPC port for a given network.
func RPCPortForNetwork(n Network) int {
	switch n {
	case NetworkMainnet:
		return 8332
	case NetworkForknet:
		return 18301
	case NetworkTestnet:
		return 18332
	case NetworkSignet:
		return 38332
	case NetworkRegtest:
		return 18443
	default:
		return 38332 // fallback to signet
	}
}

// EsploraURLsForNetwork returns the esplora API URLs for a network, primary
// first. The wallet rotates to the next on a rate-limit/outage, so a network
// can list multiple providers for resilience. Regtest returns nil — no public
// esplora exists for it and we don't ship a local one, so the enforcer falls
// back to wallet-sync-source=disabled (see GetCliArgs in enforcer_conf.go).
func EsploraURLsForNetwork(n Network) []string {
	switch n {
	case NetworkSignet:
		return []string{"https://explorer.signet.drivechain.info/api"}
	case NetworkMainnet:
		// mempool.space first, blockstream.info as fallback. Both are reference
		// Esplora REST APIs; the wallet sends a browser User-Agent so mempool
		// (which drops non-browser clients) serves it.
		return []string{"https://mempool.space/api", "https://blockstream.info/api"}
	case NetworkForknet:
		return []string{"https://explorer.forknet.drivechain.info/api"}
	default:
		return nil
	}
}

// EsploraURLForNetwork returns a network's primary esplora API URL (or "" when
// none exists), for callers that take a single endpoint such as the enforcer's
// wallet-sync-source.
func EsploraURLForNetwork(n Network) string {
	urls := EsploraURLsForNetwork(n)
	if len(urls) == 0 {
		return ""
	}
	return urls[0]
}

// RemoteOrchestratorURLForNetwork returns the URL of a hosted, read-only
// orchestrator for a given network. Electrum wallets run no local Core or
// enforcer, so they read chain/BIP300 state from this remote instance while
// signing and broadcasting locally. Mirrors node.<network>.drivechain.info.
// Networks without a hosted instance return "".
func RemoteOrchestratorURLForNetwork(n Network) string {
	switch n {
	case NetworkSignet:
		return "https://orchestrator.signet.drivechain.info"
	case NetworkForknet:
		return "https://orchestrator.forknet.drivechain.info"
	default:
		return ""
	}
}

// ElectrumWalletSupportedForNetwork reports whether a network can run electrum
// wallets. The wallet signs and broadcasts over Esplora, so an Esplora backend
// is all it needs. Drivechain reads (sidechains/BIP300) additionally require a
// hosted orchestrator (RemoteOrchestratorURLForNetwork) and are gated
// separately; mainnet has Esplora but no orchestrator, so it runs wallet-only.
func ElectrumWalletSupportedForNetwork(n Network) bool {
	return EsploraURLForNetwork(n) != ""
}

// RemoteBitwindowURLForNetwork returns the URL of a hosted, read-only
// bitwindowd for a given network. Companion to
// RemoteOrchestratorURLForNetwork for the bitwindow-side read RPCs (news,
// explorer, address book, stats). Networks without a hosted instance return "".
func RemoteBitwindowURLForNetwork(n Network) string {
	switch n {
	case NetworkSignet:
		return "https://bitwindow.signet.drivechain.info"
	case NetworkForknet:
		return "https://bitwindow.forknet.drivechain.info"
	default:
		return ""
	}
}

// CoreSection returns the Bitcoin Core config section name for this network.
func (n Network) CoreSection() string {
	return CoreSectionForNetwork(n)
}

// CoreSectionForNetwork returns the Bitcoin Core config section name for a network.
// Both mainnet and forknet use "main" since forknet runs on mainnet params.
func CoreSectionForNetwork(n Network) string {
	switch n {
	case NetworkMainnet, NetworkForknet:
		return "main"
	case NetworkTestnet:
		return "test"
	case NetworkSignet:
		return "signet"
	case NetworkRegtest:
		return "regtest"
	default:
		return "unknown"
	}
}

// NetworkFromConfig detects the network from a parsed BitcoinConfig.
// Handles forknet detection (chain=main + drivechain=1 in [main] section).
func NetworkFromConfig(conf *BitcoinConfig) Network {
	chainSetting := conf.GetSetting("chain")
	if chainSetting != "" {
		switch strings.ToLower(chainSetting) {
		case "main", "mainnet":
			drivechainSetting := conf.GetEffectiveSetting("drivechain", "main")
			if drivechainSetting == "1" {
				return NetworkForknet
			}
			return NetworkMainnet
		case "test", "testnet":
			return NetworkTestnet
		case "signet":
			return NetworkSignet
		case "regtest":
			return NetworkRegtest
		default:
			return NetworkSignet
		}
	}

	// Legacy format: check individual flags
	if conf.GetSetting("testnet") == "1" {
		return NetworkTestnet
	}
	if conf.GetSetting("signet") == "1" {
		return NetworkSignet
	}
	if conf.GetSetting("regtest") == "1" {
		return NetworkRegtest
	}

	return NetworkSignet
}

// NetworkFromString converts a string (e.g. CLI flag) to a Network value.
func NetworkFromString(s string) Network {
	switch strings.ToLower(s) {
	case "mainnet", "main":
		return NetworkMainnet
	case "forknet":
		return NetworkForknet
	case "testnet", "test":
		return NetworkTestnet
	case "signet":
		return NetworkSignet
	case "regtest":
		return NetworkRegtest
	default:
		return NetworkSignet
	}
}
