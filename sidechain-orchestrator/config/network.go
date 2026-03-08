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

// EsploraURLForNetwork returns the esplora API URL for a given network.
func EsploraURLForNetwork(n Network) string {
	switch n {
	case NetworkSignet:
		return "https://explorer.signet.drivechain.info/api"
	case NetworkMainnet:
		return "https://mempool.space/api"
	case NetworkForknet:
		return "https://explorer.forknet.drivechain.info/api"
	case NetworkRegtest:
		return "http://localhost:3003"
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
