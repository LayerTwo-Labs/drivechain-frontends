package config

import (
	"crypto/sha256"
	_ "embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
	"github.com/rs/zerolog"
)

// ---------------------------------------------------------------------------
// OS detection (Dart: enum OS + OS.current)
// ---------------------------------------------------------------------------

const (
	osLinux   = "linux"
	osMacOS   = "macos"
	osWindows = "windows"
)

func currentOSName() string {
	switch runtime.GOOS {
	case "darwin":
		return osMacOS
	case "windows":
		return osWindows
	default:
		return osLinux
	}
}

// ---------------------------------------------------------------------------
// BinaryDirConfig — directory config + path functions per binary
// 1:1 port of Dart Binary path methods (binaries.dart L1495-1612)
// ---------------------------------------------------------------------------

// BinaryDirConfig holds directory configuration for a single binary.
// Extracted from orchestrator.BinaryConfig for use in the config package.
type BinaryDirConfig struct {
	Name               string
	BinaryName         string
	ChainLayer         int
	Port               int
	DataDir            map[string]string // os -> subdir (default for all networks)
	DataDirMainnet     map[string]string // os -> subdir (mainnet override)
	IsBitcoinCore      bool              // built on Bitcoin Core: Core datadir layout and Linux appdir
	FlutterFrontendDir map[string]string // os -> Flutter app data subdir
}

// AppDir returns the platform base directory for this binary.
// Dart: Binary.appdir() (L1495-1514)
func (b BinaryDirConfig) AppDir() string {
	home := HomeDir()

	switch currentOSName() {
	case osLinux:
		if b.IsBitcoinCore {
			// Dart L1503: "in good style, this is different than all the others"
			return home
		}
		return filepath.Join(home, ".local", "share")

	case osMacOS:
		return filepath.Join(home, "Library", "Application Support")

	case osWindows:
		return filepath.Join(home, "AppData", "Roaming")
	}

	return home
}

// RootDirNetwork returns the root data directory for a specific network.
// Dart: Binary.rootDirNetwork(network) (L1518-1523)
func (b BinaryDirConfig) RootDirNetwork(network Network) string {
	dirs := b.DataDir
	if network == NetworkMainnet && len(b.DataDirMainnet) > 0 {
		dirs = b.DataDirMainnet
	}

	subdir := dirs[currentOSName()]
	if subdir == "" {
		panic(fmt.Sprintf("unsupported OS or network: binary=%s, network=%s, os=%s", b.Name, network, currentOSName()))
	}

	return filepath.Join(b.AppDir(), subdir)
}

// DatadirNetwork returns the network-aware datadir used for most file lookups.
// For bitcoind, if bitcoinOverride is non-empty it is used as the base (from
// the user's `datadir=` setting in bitwindow-bitcoin.conf); otherwise we fall
// back to the platform default. bitcoind and bitwindowd add a per-network
// subdir (e.g. "signet/"); other binaries keep the flat root dir.
// Dart: Binary.datadir() + Binary.datadirNetwork() (L1537-1591)
func (b BinaryDirConfig) DatadirNetwork(network Network, bitcoinOverride string) string {
	baseDir := b.RootDirNetwork(network)
	if b.BinaryName == "bitcoind" && bitcoinOverride != "" {
		baseDir = bitcoinOverride
	}
	switch b.layoutKey() {
	case "bitcoind":
		if network == NetworkMainnet || network == NetworkECash {
			return baseDir
		}
		return filepath.Join(baseDir, network.CoreChainDir())
	case "bitwindowd":
		return filepath.Join(baseDir, network.ReadableName())
	default:
		return baseDir
	}
}

// layoutKey collapses every Bitcoin Core derived binary onto bitcoind, whose
// on-disk layout they share.
func (b BinaryDirConfig) layoutKey() string {
	if b.IsBitcoinCore {
		return "bitcoind"
	}
	return b.BinaryName
}

// RootDir returns the root data directory (same for all networks).
// Panics if directories differ per network.
// Dart: Binary.rootDir() (L1529-1535)
func (b BinaryDirConfig) RootDir() string {
	os := currentOSName()
	defaultDir := b.DataDir[os]
	mainnetDir := ""
	if len(b.DataDirMainnet) > 0 {
		mainnetDir = b.DataDirMainnet[os]
	}

	if mainnetDir != "" && mainnetDir != defaultDir {
		panic(fmt.Sprintf("rootDir() called on %s but directories differ per network (default=%q, mainnet=%q). Use RootDirNetwork(network) instead.", b.Name, defaultDir, mainnetDir))
	}

	return b.RootDirNetwork(NetworkSignet) // any non-mainnet network
}

// FlutterFrontendPath returns the Flutter app's getApplicationSupportDirectory() path.
// Dart: flutterFrontendDir() (L1306-1353)
func (b BinaryDirConfig) FlutterFrontendPath() string {
	home := HomeDir()
	subdir := b.FlutterFrontendDir[currentOSName()]
	if subdir == "" {
		return ""
	}

	switch currentOSName() {
	case osMacOS:
		return filepath.Join(home, "Library", "Application Support", subdir)
	case osWindows:
		return filepath.Join(home, "AppData", "Roaming", subdir)
	default: // linux
		return filepath.Join(home, ".local", "share", subdir)
	}
}

// FrontendDir returns the frontend directory from directory config.
// Dart: frontendDir() (L1604-1612)
func (b BinaryDirConfig) FrontendDir() string {
	return b.FlutterFrontendPath()
}

// ---------------------------------------------------------------------------
// Embedded JSON config — single source of truth for all BinaryDirConfigs
// ---------------------------------------------------------------------------

//go:embed chains_config.json
var embeddedDirConfig []byte

// jsonDirConfig mirrors the JSON structure for BinaryDirConfig loading.
type jsonDirConfig struct {
	Version  int                           `json:"version"`
	Binaries map[string]jsonDirBinaryEntry `json:"binaries"`
}

type jsonDirBinaryEntry struct {
	Name          string `json:"name"`
	ChainLayer    int    `json:"chain_layer"`
	Port          int    `json:"port"`
	IsBitcoinCore bool   `json:"is_bitcoin_core"`
	External      bool   `json:"external"`

	Directories struct {
		Binary          map[string]map[string]string `json:"binary"`
		FlutterFrontend map[string]string            `json:"flutter_frontend"`
	} `json:"directories"`

	Download *struct {
		Binary string `json:"binary"`
	} `json:"download"`
}

var (
	parsedDirConfigs     map[string]BinaryDirConfig
	parsedDirConfigsOnce sync.Once
)

// loadDirConfigs parses the embedded JSON into BinaryDirConfig map, keyed by JSON key.
func loadDirConfigs() map[string]BinaryDirConfig {
	parsedDirConfigsOnce.Do(func() {
		var raw jsonDirConfig
		if err := json.Unmarshal(embeddedDirConfig, &raw); err != nil {
			panic(fmt.Sprintf("config: failed to parse embedded chains_config.json: %v", err))
		}

		result := make(map[string]BinaryDirConfig, len(raw.Binaries))
		for key, jb := range raw.Binaries {
			// An external node keeps its data where its own launcher puts it, so
			// no reset or wipe may resolve a directory for it.
			if jb.External {
				continue
			}
			binaryName := key
			if jb.Download != nil && jb.Download.Binary != "" {
				binaryName = jb.Download.Binary
			}

			dc := BinaryDirConfig{
				Name:          jb.Name,
				BinaryName:    binaryName,
				ChainLayer:    jb.ChainLayer,
				Port:          jb.Port,
				IsBitcoinCore: jb.IsBitcoinCore,
			}

			// Parse directories.binary: "default" -> DataDir, "mainnet" -> DataDirMainnet
			if defaultDirs, ok := jb.Directories.Binary["default"]; ok {
				dc.DataDir = defaultDirs
			}
			if mainnetDirs, ok := jb.Directories.Binary["mainnet"]; ok {
				dc.DataDirMainnet = mainnetDirs
			}

			dc.FlutterFrontendDir = jb.Directories.FlutterFrontend

			result[key] = dc
		}

		parsedDirConfigs = result
	})
	return parsedDirConfigs
}

// AllDirConfigs returns all BinaryDirConfig entries loaded from JSON.
func AllDirConfigs() map[string]BinaryDirConfig {
	return loadDirConfigs()
}

// MustDirConfig returns the BinaryDirConfig for a JSON key, panicking if not found.
func MustDirConfig(jsonKey string) BinaryDirConfig {
	dc, ok := loadDirConfigs()[jsonKey]
	if !ok {
		panic(fmt.Sprintf("config: no dir config for key %q in chains_config.json", jsonKey))
	}
	return dc
}

// Package-level accessors that read from JSON. These replace the old hardcoded vars.
var (
	BitcoinCoreDirs = MustDirConfig("bitcoincore")
	BitWindowDirs   = MustDirConfig("bitwindow")
	EnforcerDirs    = MustDirConfig("enforcer")
	ThunderDirs     = MustDirConfig("thunder")
	BitNamesDirs    = MustDirConfig("bitnames")
	BitAssetsDirs   = MustDirConfig("bitassets")
	ZSideDirs       = MustDirConfig("zside")
	TruthcoinDirs   = MustDirConfig("truthcoin")
	PhotonDirs      = MustDirConfig("photon")
	CoinShiftDirs   = MustDirConfig("coinshift")
	BbcDirs         = MustDirConfig("bbc")
	FreebankDirs    = MustDirConfig("freebank")
)

// DirConfigByName returns the BinaryDirConfig for a given binary name.
// Matches against the JSON key, display Name, or BinaryName (case-insensitive).
// The JSON-key match is what lets runtime config names like "enforcer" resolve
// to the dir config keyed under "enforcer" despite its BinaryName being
// "bip300301-enforcer".
func DirConfigByName(name string) (BinaryDirConfig, bool) {
	lower := strings.ToLower(name)
	for key, d := range loadDirConfigs() {
		if strings.ToLower(key) == lower ||
			strings.ToLower(d.Name) == lower ||
			strings.ToLower(d.BinaryName) == lower {
			return d, true
		}
	}
	return BinaryDirConfig{}, false
}

// ---------------------------------------------------------------------------
// File operations (Dart: Binary methods L169-613)
// ---------------------------------------------------------------------------

// GetExistingFilesInDir returns paths of existing files/directories from a list.
// Dart: _getExistingFilesInDir (L314-331)
// utxoSnapshotPattern matches the assumeutxo snapshots downloaded into the
// datadir root, e.g. utxo-957600.dat.
var utxoSnapshotPattern = regexp.MustCompile(`^utxo-\d+\.dat$`)

// GetMatchingFilesInDir returns entries of dir whose name matches re. A
// missing or unreadable dir yields nothing — callers are enumerating paths to
// delete, so there is nothing to do either way.
func GetMatchingFilesInDir(dir string, re *regexp.Regexp, log zerolog.Logger) []string {
	entries, err := os.ReadDir(dir)
	if err != nil {
		if !os.IsNotExist(err) {
			log.Warn().Err(err).Str("dir", dir).Msg("could not scan for matching files")
		}
		return nil
	}
	var matched []string
	for _, e := range entries {
		if re.MatchString(e.Name()) {
			matched = append(matched, filepath.Join(dir, e.Name()))
		}
	}
	return matched
}

func GetExistingFilesInDir(dir string, files []string, log zerolog.Logger) []string {
	var existing []string
	for _, file := range files {
		p := filepath.Join(dir, file)
		if info, err := os.Stat(p); err == nil {
			_ = info
			existing = append(existing, p)
		}
	}
	return existing
}

// DeleteFilesWithRetry deletes files/directories with retry logic (5 attempts, 1 second delay).
// Dart: deleteFiles (L276-311) + _deleteFilesInDir (L234-273)
func DeleteFilesWithRetry(paths []string, log zerolog.Logger) {
	for _, p := range paths {
		for attempt := 1; attempt <= 5; attempt++ {
			err := os.RemoveAll(p)
			if err == nil {
				log.Debug().Str("path", p).Msg("deleted")
				break
			}
			if os.IsNotExist(err) {
				break
			}
			log.Warn().Err(err).Int("attempt", attempt).Str("path", p).Msg("delete failed")
			if attempt < 5 {
				time.Sleep(1 * time.Second)
			}
		}
	}
}

// GetBlockchainDataPaths returns blockchain data file paths for a binary.
// Dart: getBlockchainDataPaths (L334-381)
func (b BinaryDirConfig) GetBlockchainDataPaths(networkDir string, network Network, log zerolog.Logger) []string {
	switch b.layoutKey() {
	case "bitcoind":
		paths := GetExistingFilesInDir(networkDir, coreChainDataNames, log)
		// assumeutxo snapshots are named for the height they commit to, so a
		// fixed filename can't catch them. They are large and re-downloadable.
		return append(paths, GetMatchingFilesInDir(networkDir, utxoSnapshotPattern, log)...)

	case "bip300301-enforcer":
		return GetExistingFilesInDir(b.RootDir(), enforcerChainDataNames(network), log)

	case "bitwindowd":
		return GetExistingFilesInDir(networkDir, []string{"bitdrive", "bitwindow.db"}, log)

	case "thunder", "bitnames", "bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
		return GetExistingFilesInDir(networkDir, SidechainChainDataNames, log)

	default:
		return nil
	}
}

// wipingSuffix marks a chain-data path that has been renamed aside and is being
// deleted in the background.
const wipingSuffix = ".wiping"

// WipeChainData deletes on-disk chain state for network across all known
// binaries. Wallet files and the bitwindowd database are preserved. bitcoinDatadirOverride is the user's
// datadir= setting for bitcoind, empty for the platform default. active is the
// network whose chain the shared sidechain datadirs hold.
//
// The whole operation runs in the background and returns immediately. It must
// never block the caller: the chain datadir can be large, slow, or on an
// unresponsive volume (e.g. an external disk that's asleep or unplugged), and
// even a readdir or rename against a stalled mount hangs indefinitely. This
// runs inside orchestrator startup, before the RPC listener binds, so a stall
// here surfaced to the frontend as "backend not ready". Doomed paths are
// renamed aside first — atomic and O(1) on the same filesystem — so a freshly
// started bitcoind never sees half-deleted data, then deleted; leftover
// ".wiping" siblings from an interrupted prior wipe are swept into the delete.
func WipeChainData(network, active Network, bitcoinDatadirOverride string, log zerolog.Logger) {
	go WipeChainDataSync(network, active, bitcoinDatadirOverride, log)
}

// SidechainChainDataNames are the entries a sidechain keeps its chain in. The
// datadir is flat across every network, so a swap has to move them.
var SidechainChainDataNames = []string{"data.mdb", "lock.mdb", "logs"}

// coreChainDataNames are the entries a Core datadir keeps its chain in. Kept
// beside GetBlockchainDataPaths, which lists the same set.
var coreChainDataNames = []string{
	".lock", "anchors.dat", "banlist.json", "bitcoin.pid", "bitcoind.pid",
	"blocks", "chainstate", "debug.log", "fee_estimates.dat", "indexes",
	"mempool.dat", "peers.dat", "settings.json",
}

// WipeEnforcerChainDataSync wipes the enforcer's validator and block state for
// network, leaving its wallet. The enforcer keeps one chain per network, not
// per generation, so a eCash network rollover — which stays on eCash and
// so fires no network swap — must clear it here or the new generation inherits
// the old one's validator chain. Renames aside synchronously like
// WipeChainDataSync so a caller recording the wipe can trust it happened.
// It reports whether every path left the live layout, for the same reason
// WipeNetworkScopedChainDataSync does: a caller that records the wipe as done
// would start the enforcer on the retired generation's validator chain.
func WipeEnforcerChainDataSync(network Network, log zerolog.Logger) error {
	var doomed []string
	var stuck []string
	for _, dc := range AllDirConfigs() {
		if dc.BinaryName != "bip300301-enforcer" {
			continue
		}
		for _, name := range enforcerChainDataNames(network) {
			p := filepath.Join(dc.RootDir(), name)
			if _, err := os.Stat(p); err != nil {
				if !os.IsNotExist(err) {
					stuck = append(stuck, p)
				}
				continue
			}
			orphans, _ := filepath.Glob(p + wipingSuffix + "*")
			doomed = append(doomed, orphans...)
			aside := renameAside(p, log)
			if aside == p {
				stuck = append(stuck, p)
			}
			if aside != "" {
				doomed = append(doomed, aside)
			}
		}
	}
	go DeleteFilesWithRetry(doomed, log)
	if len(stuck) > 0 {
		return fmt.Errorf("could not move aside: %s", strings.Join(stuck, ", "))
	}
	return nil
}

// WipeChainDataSync renames the doomed paths aside before returning, then
// deletes them in the background. The rename is what actually makes the old
// chain state unreachable, so callers that record "this data is gone" — the
// eCash network rollover persisting a new catalog, say — must use this:
// with the fully-backgrounded variant the process can exit before the rename
// lands, and the next boot then trusts a record of a wipe that never happened.
//
// Only safe off the startup critical path. The rename is O(1) on the same
// filesystem but can still stall on an unresponsive volume, which is why
// startup keeps WipeChainData.
func WipeChainDataSync(network, active Network, bitcoinDatadirOverride string, log zerolog.Logger) {
	var doomed []string
	for _, dc := range AllDirConfigs() {
		if dc.layoutKey() == "bitwindowd" || (dc.ChainLayer == 2 && network != active) {
			continue
		}
		networkDir := dc.DatadirNetwork(network, bitcoinDatadirOverride)
		for _, p := range dc.GetBlockchainDataPaths(networkDir, network, log) {
			orphans, _ := filepath.Glob(p + wipingSuffix + "*")
			doomed = append(doomed, orphans...)
			if aside := renameAside(p, log); aside != "" {
				doomed = append(doomed, aside)
			}
		}
	}
	go DeleteFilesWithRetry(doomed, log)
}

// renameAside moves a doomed chain path to a unique sibling so the delete can
// run off the startup critical path. Returns the new path, "" if p was already
// gone, or p itself when a rename can't cross filesystems (still deleted in the
// background). A collision means an orphaned wipe still owns that name, so the
// next free suffix is used rather than blocking on a synchronous delete.
func renameAside(p string, log zerolog.Logger) string {
	for i := 0; i < 1000; i++ {
		aside := p + wipingSuffix
		if i > 0 {
			aside = fmt.Sprintf("%s%d", aside, i)
		}
		if _, err := os.Lstat(aside); err == nil {
			continue
		}
		if err := os.Rename(p, aside); err != nil {
			if os.IsNotExist(err) {
				return ""
			}
			log.Warn().Err(err).Str("path", p).Msg("rename-aside failed; deleting in place")
			return p
		}
		return aside
	}
	log.Warn().Str("path", p).Msg("too many orphaned wipes; deleting in place")
	return p
}

// GetWalletPaths returns wallet file paths for a binary.
// Dart: getWalletPaths (L455-499)
func (b BinaryDirConfig) GetWalletPaths(networkDir string, network Network, log zerolog.Logger) []string {
	var paths []string

	switch b.layoutKey() {
	case "bip300301-enforcer":
		names := []string{filepath.Join("wallet", LegacyEnforcerNetworkName(network))}
		if chainDir, err := EnforcerChainDir(network, ECashNetworkID()); err == nil {
			names = append([]string{filepath.Join(chainDir, "wallet")}, names...)
		}
		paths = append(paths, GetExistingFilesInDir(b.RootDir(), names, log)...)

	case "bitcoind":
		// Wallets directory
		walletsDir := filepath.Join(networkDir, "wallets")
		if _, err := os.Stat(walletsDir); err == nil {
			paths = append(paths, walletsDir)
		}
		// Legacy wallet.dat
		legacyWallet := filepath.Join(networkDir, "wallet.dat")
		if _, err := os.Stat(legacyWallet); err == nil {
			paths = append(paths, legacyWallet)
		}

	case "thunder", "bitnames", "bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"wallet.mdb"}, log)...)
		// Each parked wallet.mdb: of another BitWindow wallet, another eCash
		// network, or a seed no wallet here made.
		entries, err := os.ReadDir(networkDir)
		if err != nil && !os.IsNotExist(err) {
			log.Warn().Err(err).Str("dir", networkDir).Msg("list parked sidechain wallets")
		}
		for _, entry := range entries {
			if strings.HasPrefix(entry.Name(), "wallet.mdb.network-") {
				paths = append(paths, filepath.Join(networkDir, entry.Name()))
			}
		}

	case "bitwindowd":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"wallet.json", "wallet_encryption.json"}, log)...)
		// The L1/app wallet also lives in the Flutter frontend dir. Only the L1
		// binary owns it, so a sidechain wipe never reaches it.
		if dir := b.FlutterFrontendPath(); dir != "" {
			paths = append(paths, GetExistingFilesInDir(dir, []string{"wallet.json", "wallet_encryption.json"}, log)...)
		}
	}

	return paths
}

// GetSettingsPaths returns settings file paths for a binary.
// Dart: getSettingsPaths (L384-452)
func (b BinaryDirConfig) GetSettingsPaths(networkDir string, network Network, log zerolog.Logger) []string {
	var paths []string

	// Flutter frontend app directory
	if dir := b.FlutterFrontendPath(); dir != "" {
		paths = append(paths, GetExistingFilesInDir(dir, []string{"settings.json", "debug.log"}, log)...)
	}

	switch b.layoutKey() {
	case "bitcoind":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"settings.json"}, log)...)
		rootDir := b.RootDirNetwork(network)
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{
			"bitwindow-bitcoin.conf", "bitcoin.conf", "drivechain.conf",
		}, log)...)

	case "bip300301-enforcer":
		paths = append(paths, GetExistingFilesInDir(b.RootDir(), []string{"bitwindow-enforcer.conf"}, log)...)

	case "bitwindowd":
		rootDir := BitWindowDirs.RootDir()
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{
			"assets", "bitwindow-bitcoin.conf", logfile.Name,
			"downloads", "pids", "settings.json",
		}, log)...)

	case "thunder":
		rootDir := b.RootDir()
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{"start.sh", "thunder.conf", "thunder.zip", "thunder_app"}, log)...)
		if dir := b.FrontendDir(); dir != "" {
			paths = append(paths, GetExistingFilesInDir(dir, []string{"assets", "downloads", "debug.log", "settings.json"}, log)...)
		}

	case "bitnames", "bitassets", "thunder-orchard", "truthcoin", "photon":
		if dir := b.FrontendDir(); dir != "" {
			paths = append(paths, GetExistingFilesInDir(dir, []string{"assets", "downloads", "debug.log", "settings.json"}, log)...)
		}

	case "coinshift":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"debug.log", "settings.json"}, log)...)
	}

	return paths
}

// GetAllDatadirPaths returns all files in the binary's datadir.
// Dart: getAllDatadirPaths (L595-613)
func (b BinaryDirConfig) GetAllDatadirPaths(networkDir string) []string {
	var paths []string
	_ = filepath.WalkDir(networkDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		paths = append(paths, path)
		return nil
	})
	return paths
}

// GetLogPaths returns log file paths for a binary (for deletion).
// Dart: getLogPaths (L579-627)
func (b BinaryDirConfig) GetLogPaths(networkDir string, network Network, log zerolog.Logger) []string {
	var paths []string

	switch b.layoutKey() {
	case "bitcoind":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"debug.log"}, log)...)

	case "bip300301-enforcer":
		names := []string{"bip300301_enforcer.log", "logs"}
		if chainDir, err := EnforcerChainDir(network, ECashNetworkID()); err == nil {
			names = append(names, filepath.Join(chainDir, "logs"))
		}
		paths = append(paths, GetExistingFilesInDir(networkDir, names, log)...)

	case "bitwindowd":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"miner.log", "server.log"}, log)...)
		rootDir := BitWindowDirs.RootDir()
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{
			logfile.Name, "debug.log", "drivechaind.log",
		}, log)...)

	case "thunder", "bitnames", "bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"logs"}, log)...)
	}

	// Also include Flutter frontend debug.log
	if dir := b.FlutterFrontendPath(); dir != "" {
		paths = append(paths, GetExistingFilesInDir(dir, []string{"debug.log"}, log)...)
	}

	return paths
}

// ---------------------------------------------------------------------------
// Log file resolution (Dart: logPath, _findLatestEnforcerLog, _findLatestDirVersionedLog)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Network helper on Network type
// ---------------------------------------------------------------------------

// ReadableName returns a human-readable network name.
// Dart: toReadableNet() extension
// CoreChainDir is the subdirectory Bitcoin Core writes under its datadir.
// Matches ReadableName everywhere except testnet, which Core stores as
// testnet3.
func (n Network) CoreChainDir() string {
	if n == NetworkTestnet {
		return "testnet3"
	}
	return n.ReadableName()
}

func (n Network) ReadableName() string {
	switch n {
	case NetworkMainnet:
		return "mainnet"
	case NetworkECash:
		return "ecash"
	case NetworkSignet:
		return "signet"
	case NetworkRegtest:
		return "regtest"
	case NetworkTestnet:
		return "testnet"
	default:
		return string(n)
	}
}

// EnforcerChainDir is the enforcer's <fork>/<chain> directory for network,
// relative to its data directory. The enforcer keeps the validator, wallet and
// logs directories in it. ecashID names the eCash network for NetworkECash.
func EnforcerChainDir(n Network, ecashID string) (string, error) {
	fork := enforcerBitcoinFork
	if n == NetworkECash {
		f, ok := EnforcerFork(ecashID)
		if !ok {
			return "", fmt.Errorf("the enforcer has no fork for the eCash network %q", ecashID)
		}
		fork = f
	}
	return filepath.Join(fork, enforcerChainName(n)), nil
}

// enforcerChainName obeys NetworkParams::data_dir in bip300301_enforcer. Every
// eCash network runs chain main. The L2L signet challenge is not the default
// one, so its directory has the signet magic as a suffix.
func enforcerChainName(n Network) string {
	switch n {
	case NetworkMainnet, NetworkECash:
		return "mainnet"
	case NetworkTestnet:
		return "testnet3"
	case NetworkSignet:
		if signet, ok := netcatalog.Embedded().ByID("signet"); ok && signet.NetworkMagic != "" {
			return "signet_" + strings.ToLower(signet.NetworkMagic)
		}
		return "signet"
	default:
		return "regtest"
	}
}

// enforcerChainDataNames lists the validator directories of network, relative
// to the enforcer data directory: the <fork>/<chain> one and the legacy ones.
func enforcerChainDataNames(n Network) []string {
	var names []string
	if chainDir, err := EnforcerChainDir(n, ECashNetworkID()); err == nil {
		names = append(names, filepath.Join(chainDir, "validator"))
	}
	legacy := LegacyEnforcerNetworkName(n)
	names = append(names, filepath.Join("validator", legacy))
	// <root>/bitcoin is also the bitcoin fork directory, which holds the
	// chains and wallets of every Bitcoin network.
	if legacy != enforcerBitcoinFork {
		names = append(names, legacy)
	}
	return names
}

// LegacyEnforcerNetworkName is the directory name that enforcer releases
// before the --fork flag used for a network, in <root>/validator/<name> and
// <root>/wallet/<name>. Mainnet and the networks that fork it share one name.
func LegacyEnforcerNetworkName(n Network) string {
	switch n {
	case NetworkMainnet, NetworkECash:
		return "bitcoin"
	default:
		return n.ReadableName()
	}
}

// LegacyEnforcerValidatorDir is the validator database directory for network
// in the legacy layout.
func LegacyEnforcerValidatorDir(n Network) string {
	return filepath.Join(EnforcerDirs.RootDir(), "validator", LegacyEnforcerNetworkName(n))
}

// LegacyEnforcerWalletDir is the BDK wallet directory for network in the
// legacy layout.
func LegacyEnforcerWalletDir(n Network) string {
	return filepath.Join(EnforcerDirs.RootDir(), "wallet", LegacyEnforcerNetworkName(n))
}

// LegacyEnforcerNetworksCollide reports whether two networks share the
// directories of the legacy layout.
func LegacyEnforcerNetworksCollide(a, b Network) bool {
	return a != b && LegacyEnforcerNetworkName(a) == LegacyEnforcerNetworkName(b)
}

// ---------------------------------------------------------------------------
// Batch 4: Binary file operations
// Dart: deleteBinaries (L169-232), getBinaryPaths (L520-592)
// ---------------------------------------------------------------------------

// ExtraFilesForDeletion returns per-binary extra files to delete from assets dir.
//
// The list has two parts:
//  1. A static set of non-CLI extras (bitcoind's qt/util, bitwindowd's DLLs, etc.)
//     plus CLI names that don't match the "<binary>-cli" pattern (bitnames/bitassets).
//  2. A runtime scan for "<binaryName>-cli" and "<binaryName>-cli.exe" in assetsDir,
//     so sidechains whose CLI is bundled in the archive (thunder, truthcoin, ...)
//     get picked up when present and silently skipped when the archive only ships
//     a raw main binary.
//
// Dart equivalent: deleteBinaries switch statement (L178-231)
func (b BinaryDirConfig) ExtraFilesForDeletion(assetsDir string) []string {
	files := b.staticExtraFiles()
	for _, cli := range []string{b.BinaryName + "-cli", b.BinaryName + "-cli.exe"} {
		if _, err := os.Stat(filepath.Join(assetsDir, cli)); err == nil {
			files = append(files, cli)
		}
	}
	return files
}

func (b BinaryDirConfig) staticExtraFiles() []string {
	switch b.BinaryName {
	case "bitcoind":
		return []string{"bitcoin-cli", "bitcoin-util", "bitcoin-cli.exe", "bitcoin-util.exe", "qt"}
	case "bip300301-enforcer":
		return []string{"LICENSE", "grpcurl"}
	case "bitwindowd":
		return []string{"data", "lib", "bitwindow.exe",
			"flutter_platform_alert_plugin.dll", "flutter_windows.dll",
			"screen_retriever_windows_plugin.dll", "url_launcher_windows_plugin.dll",
			"window_manager_plugin.dll"}
	case "freebankd":
		return []string{"freebank-cli", "freebank-tx", "COPYING"}
	case "bitnames":
		return []string{"bitnames-cli"}
	case "bitassets":
		return []string{"bitassets-cli"}
	case "thunder-orchard":
		return []string{"thunder-orchard"}
	default:
		return nil
	}
}

// GetBinaryPaths returns existing binary + extra file paths in assets dir.
// Dart: getBinaryPaths (L520-592)
func (b BinaryDirConfig) GetBinaryPaths(assetsDir string, log zerolog.Logger) []string {
	baseFiles := []string{
		b.BinaryName,
		strings.TrimSuffix(b.BinaryName, ".exe"),
		b.BinaryName + ".exe",
		b.BinaryName + ".app",
		b.BinaryName + ".meta",
	}
	paths := GetExistingFilesInDir(assetsDir, baseFiles, log)

	extra := b.ExtraFilesForDeletion(assetsDir)
	if len(extra) > 0 {
		paths = append(paths, GetExistingFilesInDir(assetsDir, extra, log)...)
	}

	return paths
}

// ResolveBinaryPath finds the binary executable on disk.
// Dart: resolveBinaryPath (L615-638)
func (b BinaryDirConfig) ResolveBinaryPath(appDir string) (string, error) {
	possiblePaths := b.getPossibleBinaryPaths(b.BinaryName, appDir)

	for _, p := range possiblePaths {
		info, err := os.Stat(p)
		if err != nil {
			continue
		}

		resolvedPath := p
		// Handle .app bundles on macOS
		if runtime.GOOS == "darwin" && strings.HasSuffix(resolvedPath, ".app") {
			base := strings.TrimSuffix(filepath.Base(resolvedPath), ".app")
			resolvedPath = filepath.Join(p, "Contents", "MacOS", base)
		}

		if info.IsDir() || info.Mode().IsRegular() {
			return resolvedPath, nil
		}
	}

	return "", fmt.Errorf("binary %s not found", b.BinaryName)
}

// getPossibleBinaryPaths returns all possible locations for a binary.
// Dart: _getPossibleBinaryPaths (L640-677)
func (b BinaryDirConfig) getPossibleBinaryPaths(baseBinary, appDir string) []string {
	var paths []string
	binDir := filepath.Join(appDir, "assets", "bin")

	paths = append(paths, filepath.Join(binDir, baseBinary))

	// For L1 binaries, also check BitWindow's assets directory
	if b.ChainLayer == 1 && !strings.Contains(strings.ToLower(appDir), "bitwindow") {
		bitwindowDir := filepath.Join(filepath.Dir(appDir), "bitwindow")
		binaryPath := filepath.Join(bitwindowDir, "assets", "bin", baseBinary)
		paths = append(paths, binaryPath)
		if runtime.GOOS == "windows" && !strings.HasSuffix(baseBinary, ".exe") {
			paths = append(paths, binaryPath+".exe")
		}
	}

	// Check .app bundle on macOS
	if runtime.GOOS == "darwin" && !strings.HasSuffix(baseBinary, ".app") {
		paths = append(paths, filepath.Join(binDir, baseBinary+".app"))
	}
	// Check .exe on Windows
	if runtime.GOOS == "windows" && !strings.HasSuffix(baseBinary, ".exe") {
		paths = append(paths, filepath.Join(binDir, baseBinary+".exe"))
	}

	return paths
}

// ---------------------------------------------------------------------------
// Batch 5: Version/update checking
// ---------------------------------------------------------------------------

// BinaryVersion runs the binary with --version and returns the output.
// Dart: binaryVersion (L1615-1677)
func (b BinaryDirConfig) BinaryVersion(appDir string) (string, error) {
	binaryPath, err := b.ResolveBinaryPath(appDir)
	if err != nil {
		return "", err
	}

	if strings.HasSuffix(binaryPath, ".app") {
		return "N/A", nil
	}

	cmd := exec.Command(binaryPath, "--version")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("run --version: %w", err)
	}

	return strings.TrimSpace(string(output)), nil
}

// CalculateHash computes the SHA256 hash of the binary file.
// Dart: calculateHash (L1726-1736)
func (b BinaryDirConfig) CalculateHash(appDir string) (string, error) {
	binaryPath, err := b.ResolveBinaryPath(appDir)
	if err != nil {
		return "", err
	}

	data, err := os.ReadFile(binaryPath)
	if err != nil {
		return "", err
	}

	hash := sha256.Sum256(data)
	return fmt.Sprintf("%x", hash), nil
}
