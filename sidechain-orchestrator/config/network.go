package config

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/samber/lo"
)

// Network represents the Bitcoin network type.
type Network string

const (
	NetworkMainnet Network = "mainnet"
	NetworkForknet Network = "forknet"
	NetworkECash   Network = "ecash"
	NetworkSignet  Network = "signet"
	NetworkRegtest Network = "regtest"
	NetworkTestnet Network = "testnet"
)

// DefaultNetwork is the network an install runs with no saved config and no
// --network/ORCHESTRATOR_NETWORK override. Every binary reads this one value,
// so the daemon and the control CLI cannot target different networks. Variant
// builds override it at link time:
//
//	go build -ldflags "-X <this package>.DefaultNetwork=forknet"
var DefaultNetwork = string(NetworkECash)

// AllNetworks lists every network the app can run.
func AllNetworks() []Network {
	return []Network{
		NetworkMainnet, NetworkForknet, NetworkECash,
		NetworkSignet, NetworkRegtest, NetworkTestnet,
	}
}

// DatadirGroup partitions networks by which folder bitcoind writes to.
// Forknet and eCash both run on chain=main and write to the root of datadir,
// colliding with mainnet and each other — so each needs its own group. The four
// "default" networks share one datadir because Bitcoin Core auto-partitions them
// via chain subdirectories (signet/, testnet3/, regtest/, blocks/ for mainnet).
type DatadirGroup string

const (
	DatadirGroupDefault DatadirGroup = "default"
	DatadirGroupForknet DatadirGroup = "forknet"
	DatadirGroupECash   DatadirGroup = "ecash"
)

// ecashNetworkID is the live eCash network id ("alphanet"), resolved from the
// network catalog at startup. Package-level because the URL helpers below are
// package functions called from everywhere; guarded because the catalog is
// refreshed on a background goroutine.
var (
	ecashMu        sync.RWMutex
	ecashNetworkID string
	ecashPeers     = map[string]string{}
	forkHeights    = map[Network]int{}
	displayNames   = map[Network]string{}
	ecashEndpoints netcatalog.Network
	published      = map[Network]netcatalog.Network{}
)

// SetECashPeer records the seed address published for a eCash network.
func SetECashPeer(id, address string) {
	if id == "" || address == "" {
		return
	}
	ecashMu.Lock()
	defer ecashMu.Unlock()
	ecashPeers[id] = address
}

// PublishedECashPeer returns the catalog's seed address for an eCash network,
// empty when the catalog carried none.
func PublishedECashPeer(id string) string {
	ecashMu.RLock()
	defer ecashMu.RUnlock()
	return ecashPeers[id]
}

// SetNetworkDisplayName records a network's published name ("ECash 4"), so the
// UI names the fork that is actually coming.
func SetNetworkDisplayName(network Network, name string) {
	ecashMu.Lock()
	defer ecashMu.Unlock()
	if name != "" {
		displayNames[network] = name
	}
}

// PublishedDisplayName returns a network's catalog name, empty when unset.
func PublishedDisplayName(network Network) string {
	ecashMu.RLock()
	defer ecashMu.RUnlock()
	return displayNames[network]
}

// SetForkHeight records a network's published fork height. Called once the
// catalog is loaded, before anything counts down to it.
func SetForkHeight(network Network, height int) {
	ecashMu.Lock()
	defer ecashMu.Unlock()
	if height > 0 {
		forkHeights[network] = height
	}
}

// PublishedForkHeight returns a network's catalog fork height, 0 when the
// catalog carried none.
func PublishedForkHeight(network Network) int {
	ecashMu.RLock()
	defer ecashMu.RUnlock()
	return forkHeights[network]
}

// SetECashNetworkID records the resolved eCash network. Called once the
// network catalog is loaded, before anything dials.
func SetECashNetworkID(id string) {
	ecashMu.Lock()
	defer ecashMu.Unlock()
	ecashNetworkID = id
}

// ECashNetworkID returns the live eCash network, falling back to the
// id compiled into the binary so the URLs resolve before the catalog
// has been read.
func ECashNetworkID() string {
	ecashMu.RLock()
	id := ecashNetworkID
	ecashMu.RUnlock()
	if id != "" {
		return id
	}
	return netcatalog.EmbeddedECashID()
}

// SetECashEndpoints records the endpoints the catalog publishes for the live
// eCash network. Called once the network catalog is loaded, before anything
// dials.
func SetECashEndpoints(n netcatalog.Network) {
	ecashMu.Lock()
	defer ecashMu.Unlock()
	ecashEndpoints = n
}

// ECashEndpoints returns the live eCash network's published endpoints,
// falling back to the copy compiled into the binary so the URLs resolve before
// the catalog has been read.
func ECashEndpoints() netcatalog.Network {
	ecashMu.RLock()
	n := ecashEndpoints
	ecashMu.RUnlock()
	if n.ID != "" {
		return n
	}
	return netcatalog.EmbeddedECash()
}

// SetNetworkEndpoints records the entry the catalog publishes for a network.
// Called once the network catalog is adopted, before anything dials. The
// compiled-in copy is adopted at startup, so no read falls in a gap.
func SetNetworkEndpoints(network Network, n netcatalog.Network) {
	ecashMu.Lock()
	defer ecashMu.Unlock()
	published[network] = n
}

// PublishedEndpoints returns the entry the catalog publishes for a network,
// zero when it lists none. eCash keys off its resolved entry, because its id is
// free-form and names no network slot.
func PublishedEndpoints(network Network) netcatalog.Network {
	if network == NetworkECash {
		return ECashEndpoints()
	}
	ecashMu.RLock()
	defer ecashMu.RUnlock()
	return published[network]
}

// ECashExplorerHost is the host BitWindow links block, transaction and address
// pages at for the live eCash network, empty when it publishes no explorer.
func ECashExplorerHost() string {
	return ECashEndpoints().ExplorerHost()
}

// DatadirGroupForNetwork returns the datadir group a network belongs to.
func DatadirGroupForNetwork(n Network) DatadirGroup {
	switch n {
	case NetworkForknet:
		return DatadirGroupForknet
	case NetworkECash:
		return DatadirGroupECash
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
	case NetworkECash:
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
	case NetworkECash:
		if backend := ECashEndpoints().BackendURL("esplora"); backend != "" {
			return []string{backend}
		}
		return nil
	default:
		return nil
	}
}

// SplitCheckEsploraURLs returns the public BTC-mainnet esplora servers the
// split engine reads, primary first.
func SplitCheckEsploraURLs() []string {
	return []string{"https://mempool.space/api", "https://blockstream.info/api"}
}

// IsEcashFork reports whether the network runs the eCash fork flow (claims,
// split UI).
func IsEcashFork(n Network) bool {
	return n == NetworkForknet || n == NetworkECash
}

// SharesBitcoinHistory reports whether the network forked off BTC mainnet, so
// its pre-fork outpoints also exist on BTC. Forknet is excluded: it is a
// fresh-genesis rehearsal chain that only reuses mainnet params, so none of its
// outpoints can ever exist on Bitcoin.
func SharesBitcoinHistory(n Network) bool {
	return n == NetworkECash
}

// WalletChainSourceURLsForNetwork returns the endpoints the electrum wallet
// reads chain data from, best first. The catalog decides which networks read
// an Electrum-protocol server: where it publishes one, the whole published list
// applies, so the Fulcrum server serves the wallet and the Esplora stays as the
// fallback. The rest keep the built-in endpoints. Mainnet's built-in one is the
// drivechain Electrum server (ssl://), because its public HTTP is a
// mempool.space API that lacks the /address/:a/utxo and /fee-estimates
// endpoints the wallet needs. The scheme (ssl/tcp vs https) selects the client.
// This is deliberately separate from EsploraURLForNetwork, which feeds the
// enforcer's BDK sync and must stay an HTTP Esplora URL.
func WalletChainSourceURLsForNetwork(n Network) []string {
	if entry := PublishedEndpoints(n); entry.ElectrumURL() != "" {
		return entry.ChainSourceURLs()
	}
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

// ElectrumHostPortForNetwork returns a network's electrum server, or an empty
// host when none exists. The ssl:// prefix selects TLS in the enforcer client.
func ElectrumHostPortForNetwork(n Network) (string, uint16) {
	switch n {
	case NetworkMainnet:
		return "ssl://explorer.mainnet.drivechain.info", 50002
	case NetworkECash:
		return splitElectrumURL(ECashEndpoints().ElectrumURL())
	default:
		return "", 0
	}
}

// splitElectrumURL splits a published electrum backend ("ssl://host:50002")
// into the scheme-qualified host and its port. Anything unparsable, or without
// a port, yields an empty host — the caller treats that as "no electrum".
func splitElectrumURL(raw string) (string, uint16) {
	if raw == "" {
		return "", 0
	}
	u, err := url.Parse(raw)
	if err != nil || u.Scheme == "" || u.Hostname() == "" {
		return "", 0
	}
	port, err := strconv.ParseUint(u.Port(), 10, 16)
	if err != nil {
		return "", 0
	}
	return u.Scheme + "://" + u.Hostname(), uint16(port)
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
// Mainnet, forknet and eCash all use "main" since the forks run on mainnet params.
func CoreSectionForNetwork(n Network) string {
	switch n {
	case NetworkMainnet, NetworkForknet, NetworkECash:
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

// ecashUACommentPrefix marks a generated bitcoin.conf as eCash. The suffix is
// the catalog id, which is free-form, so only the prefix is a sentinel.
const ecashUACommentPrefix = "ecash-"

// legacyECashUAComment is the sentinel the drynet series wrote.
const legacyECashUAComment = "drynet"

// legacyECashDatadirGroup is the slot name the drynet series wrote.
const legacyECashDatadirGroup DatadirGroup = "drynet"

// ECashUAComment returns the uacomment a generated eCash bitcoin.conf carries.
func ECashUAComment(id string) string {
	return ecashUACommentPrefix + id
}

// IsECashUAComment reports whether a uacomment marks an eCash install. A bare
// "drynet<N>" is what builds before the free-form ids wrote. It is read, never
// written: a conf that carries it still names an eCash chain, and reading it as
// forknet would boot the wrong network behind the user's back.
func IsECashUAComment(uacomment string) bool {
	return strings.HasPrefix(uacomment, ecashUACommentPrefix) ||
		strings.HasPrefix(uacomment, legacyECashUAComment)
}

// ECashIDFromUAComment returns the eCash network id a uacomment names, empty
// when it names none.
func ECashIDFromUAComment(uacomment string) string {
	if !IsECashUAComment(uacomment) {
		return ""
	}
	return strings.TrimPrefix(uacomment, ecashUACommentPrefix)
}

// NetworkForCatalogEntry maps a published catalog entry onto the slot it runs
// in. Every eCash entry shares one slot, whatever its id; the rest are named
// after the slot itself. false means the app cannot run that entry.
func NetworkForCatalogEntry(id, family string) (Network, bool) {
	if family == netcatalog.FamilyECash {
		return NetworkECash, true
	}
	return LookupNetwork(id)
}

// NetworkFromConfig detects the network from a parsed BitcoinConfig.
// Handles forknet/ecash detection (chain=main + drivechain=1 in [main]).
// fallback is returned when the config carries no chain=/testnet=/signet=/
// regtest= selector at all — signet for our own managed conf, but the network
// the file was found under for a user's private bitcoin.conf.
func NetworkFromConfig(conf *BitcoinConfig, fallback Network) Network {
	chainSetting := conf.GetSetting("chain")
	if chainSetting != "" {
		switch strings.ToLower(chainSetting) {
		case "main", "mainnet":
			if conf.GetEffectiveSetting("drivechain", "main") == "1" {
				// forknet and eCash both run chain=main + drivechain=1, told
				// apart by the uacomment sentinel eCash writes into [main].
				if IsECashUAComment(conf.GetEffectiveSetting("uacomment", "main")) {
					return NetworkECash
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

	return fallback
}

// NetworkFromString converts a string (e.g. CLI flag) to a Network value,
// falling back to signet for anything it does not recognise.
func NetworkFromString(s string) Network {
	n, ok := LookupNetwork(s)
	if !ok {
		panic(fmt.Sprintf("unknown network %q", s))
	}
	return n
}

// LookupNetwork converts a string to a Network value and reports whether it
// named one. Callers that write per-network state need the flag: a catalog id
// such as "alphanet" is not a network name, and the signet fallback would
// otherwise stamp that entry's values onto signet.
func LookupNetwork(s string) (Network, bool) {
	switch strings.ToLower(s) {
	case "mainnet", "main", "bitcoin":
		return NetworkMainnet, true
	case "forknet":
		return NetworkForknet, true
	// "drynet" is what launch scripts and ORCHESTRATOR_NETWORK carried before
	// the rename. It is read, never written: falling through to signet would
	// boot a different network than the caller asked for.
	case "ecash", "drynet":
		return NetworkECash, true
	case "testnet", "test", "testnet4":
		return NetworkTestnet, true
	case "signet":
		return NetworkSignet, true
	case "regtest":
		return NetworkRegtest, true
	default:
		return NetworkSignet, false
	}
}

// ChainParamsFor gives the address encoding and coin type a network takes.
// Every Network value has params; a value outside the set is a programming
// error, and a guess here is a wrong address.
func ChainParamsFor(n Network) *chaincfg.Params {
	switch n {
	// Forknet and eCash run on mainnet params: same encoding, same coin type.
	case NetworkMainnet, NetworkForknet, NetworkECash:
		return &chaincfg.MainNetParams
	case NetworkTestnet:
		return &chaincfg.TestNet3Params
	case NetworkSignet:
		return &chaincfg.SigNetParams
	case NetworkRegtest:
		return &chaincfg.RegressionNetParams
	}
	panic(fmt.Sprintf("no chain params for network %q", n))
}

// SupportsLightMode reports whether a network can run without a local node.
// Light mode reads the chain from Esplora, so a network with no Esplora server
// — regtest and testnet — runs in full mode only.
func SupportsLightMode(n Network) bool {
	return EsploraURLForNetwork(n) != ""
}

// LightModeNetworks lists the networks light mode can serve.
func LightModeNetworks() []Network {
	return lo.Filter(AllNetworks(), func(n Network, _ int) bool { return SupportsLightMode(n) })
}
