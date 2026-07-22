package config

import (
	"strings"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// Network represents the Bitcoin network type.
type Network string

const (
	NetworkMainnet Network = "mainnet"
	NetworkForknet Network = "forknet"
	NetworkDrynet  Network = "drynet"
	NetworkSignet  Network = "signet"
	NetworkRegtest Network = "regtest"
	NetworkTestnet Network = "testnet"
)

// DatadirGroup partitions networks by which folder bitcoind writes to.
// Forknet and drynet both run on chain=main and write to the root of datadir,
// colliding with mainnet and each other — so each needs its own group. The four
// "default" networks share one datadir because Bitcoin Core auto-partitions them
// via chain subdirectories (signet/, testnet3/, regtest/, blocks/ for mainnet).
type DatadirGroup string

const (
	DatadirGroupDefault DatadirGroup = "default"
	DatadirGroupForknet DatadirGroup = "forknet"
	DatadirGroupDrynet  DatadirGroup = "drynet"
)

// drynetGeneration is the live drynet generation ("drynet2"), resolved from the
// network catalog at startup. Package-level because the URL helpers below are
// package functions called from everywhere; guarded because the catalog is
// refreshed on a background goroutine.
var (
	drynetGenerationMu sync.RWMutex
	drynetGeneration   string
)

// SetDrynetGeneration records the resolved drynet generation. Called once the
// network catalog is loaded, before anything dials.
func SetDrynetGeneration(id string) {
	drynetGenerationMu.Lock()
	defer drynetGenerationMu.Unlock()
	drynetGeneration = id
}

// DrynetGeneration returns the live drynet generation, falling back to the
// generation compiled into the binary so the URLs resolve before the catalog
// has been read.
func DrynetGeneration() string {
	drynetGenerationMu.RLock()
	id := drynetGeneration
	drynetGenerationMu.RUnlock()
	if id != "" {
		return id
	}
	return netcatalog.EmbeddedDrynetID()
}

// DatadirGroupForNetwork returns the datadir group a network belongs to.
func DatadirGroupForNetwork(n Network) DatadirGroup {
	switch n {
	case NetworkForknet:
		return DatadirGroupForknet
	case NetworkDrynet:
		return DatadirGroupDrynet
	default:
		return DatadirGroupDefault
	}
}

// RPCPortForNetwork returns the default RPC port for a given network.
func RPCPortForNetwork(n Network) int {
	switch n {
	case NetworkMainnet:
		return 8332
	case NetworkForknet:
		return 18301
	case NetworkDrynet:
		return 18302
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
		// drivechain's own Esplora server. Its routes sit at the root, so the
		// base URL carries no /api suffix (the other networks' do).
		return []string{"https://esplora.mainnet.drivechain.info"}
	case NetworkForknet:
		return []string{"https://explorer.forknet.drivechain.info/api"}
	case NetworkDrynet:
		// drynet's Esplora serves its routes at the root, so no /api suffix.
		// Host carries the generation, so it moves with the network.
		if gen := DrynetGeneration(); gen != "" {
			return []string{"https://esplora." + gen + ".drivechain.dev"}
		}
		return nil
	default:
		return nil
	}
}

// WalletChainSourceURLsForNetwork returns the endpoints the electrum wallet
// reads chain data from, primary first. Mainnet uses the drivechain Electrum
// server (ssl://) — its public HTTP is a mempool.space API that lacks the
// /address/:a/utxo and /fee-estimates endpoints the wallet needs — while other
// networks use their Esplora REST. The scheme (ssl/tcp vs https) selects the
// client. This is deliberately separate from EsploraURLForNetwork, which feeds
// the enforcer's BDK sync and must stay an HTTP Esplora URL.
func WalletChainSourceURLsForNetwork(n Network) []string {
	switch n {
	case NetworkMainnet:
		return []string{"ssl://explorer.mainnet.drivechain.info:50002"}
	default:
		return EsploraURLsForNetwork(n)
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
// Mainnet, forknet and drynet all use "main" since the forks run on mainnet params.
func CoreSectionForNetwork(n Network) string {
	switch n {
	case NetworkMainnet, NetworkForknet, NetworkDrynet:
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
// Handles forknet/drynet detection (chain=main + drivechain=1 in [main]).
func NetworkFromConfig(conf *BitcoinConfig) Network {
	chainSetting := conf.GetSetting("chain")
	if chainSetting != "" {
		switch strings.ToLower(chainSetting) {
		case "main", "mainnet":
			if conf.GetEffectiveSetting("drivechain", "main") == "1" {
				// forknet and drynet both run chain=main + drivechain=1, told
				// apart by the uacomment sentinel drynet writes into [main].
				// That value carries the generation ("drynet2"), so match the
				// prefix — an exact compare would break on every rollover.
				if strings.HasPrefix(conf.GetEffectiveSetting("uacomment", "main"), string(NetworkDrynet)) {
					return NetworkDrynet
				}
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
	case "drynet":
		return NetworkDrynet
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
