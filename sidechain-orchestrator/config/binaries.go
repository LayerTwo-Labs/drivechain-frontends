package config

import (
	"crypto/sha256"
	_ "embed"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"sort"
	"strings"
	"sync"
	"time"

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
	Name          string
	BinaryName    string
	ChainLayer    int
	Port          int
	DataDir       map[string]string // os -> subdir (default for all networks)
	DataDirMainnet map[string]string // os -> subdir (mainnet override)
	IsBitcoinCore bool              // Linux appdir exception
	FlutterFrontendDir map[string]string // os -> Flutter app data subdir
}

// AppDir returns the platform base directory for this binary.
// Dart: Binary.appdir() (L1495-1514)
func (b BinaryDirConfig) AppDir() string {
	home, _ := os.UserHomeDir()

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
	switch b.BinaryName {
	case "bitcoind":
		if network == NetworkMainnet || network == NetworkForknet {
			return baseDir
		}
		return filepath.Join(baseDir, network.ReadableName())
	case "bitwindowd":
		return filepath.Join(baseDir, network.ReadableName())
	default:
		return baseDir
	}
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
	home, _ := os.UserHomeDir()
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
	switch b.BinaryName {
	case "bitcoind":
		return GetExistingFilesInDir(networkDir, []string{
			".lock", "anchors.dat", "banlist.json", "bitcoin.pid", "bitcoind.pid",
			"blocks", "chainstate", "debug.log", "fee_estimates.dat", "indexes",
			"mempool.dat", "peers.dat", "settings.json",
		}, log)

	case "bip300301-enforcer":
		rootdir := b.RootDir()
		networkName := strings.ReplaceAll(strings.ReplaceAll(network.ReadableName(), "mainnet", "bitcoin"), "forknet", "bitcoin")
		return GetExistingFilesInDir(rootdir, []string{"validator", "bitwindow-enforcer.conf", networkName}, log)

	case "bitwindowd":
		return GetExistingFilesInDir(networkDir, []string{"bitdrive", "bitwindow.db"}, log)

	case "thunder", "plain_bitnames", "plain_bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
		return GetExistingFilesInDir(networkDir, []string{"data.mdb", "lock.mdb", "logs"}, log)

	default:
		return nil
	}
}

// GetWalletPaths returns wallet file paths for a binary.
// Dart: getWalletPaths (L455-499)
func (b BinaryDirConfig) GetWalletPaths(networkDir string, network Network, log zerolog.Logger) []string {
	var paths []string

	switch b.BinaryName {
	case "bip300301-enforcer":
		rootdir := b.RootDir()
		networkName := strings.ReplaceAll(strings.ReplaceAll(network.ReadableName(), "mainnet", "bitcoin"), "forknet", "bitcoin")
		walletDir := filepath.Join(rootdir, "wallet", networkName)
		if _, err := os.Stat(walletDir); err == nil {
			paths = append(paths, walletDir)
		}

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

	case "thunder", "plain_bitnames", "plain_bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"wallet.mdb"}, log)...)

	case "bitwindowd":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"wallet.json", "wallet_encryption.json"}, log)...)
	}

	// Also check Flutter frontend app directory
	if dir := b.FlutterFrontendPath(); dir != "" {
		paths = append(paths, GetExistingFilesInDir(dir, []string{"wallet.json", "wallet_encryption.json"}, log)...)
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

	switch b.BinaryName {
	case "bitcoind":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"settings.json"}, log)...)
		rootDir := b.RootDirNetwork(network)
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{
			"bitwindow-bitcoin.conf", "bitcoin.conf", "drivechain.conf",
		}, log)...)

	case "bitwindowd":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"server.log"}, log)...)
		rootDir := BitWindowDirs.RootDir()
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{
			"assets", "bitwindow-bitcoin.conf", "bitwindow-mainnet.conf",
			"bitwindow-forknet.conf", "debug.log", "downloads", "pids", "settings.json",
		}, log)...)

	case "thunder":
		rootDir := b.RootDir()
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{"start.sh", "thunder.conf", "thunder.zip", "thunder_app"}, log)...)
		if dir := b.FrontendDir(); dir != "" {
			paths = append(paths, GetExistingFilesInDir(dir, []string{"assets", "downloads", "debug.log", "settings.json"}, log)...)
		}

	case "plain_bitnames", "plain_bitassets", "thunder-orchard", "truthcoin", "photon":
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
func (b BinaryDirConfig) GetLogPaths(networkDir string, log zerolog.Logger) []string {
	var paths []string

	switch b.BinaryName {
	case "bitcoind":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"debug.log"}, log)...)

	case "bip300301-enforcer":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"bip300301_enforcer.log", "logs"}, log)...)

	case "bitwindowd":
		paths = append(paths, GetExistingFilesInDir(networkDir, []string{"server.log"}, log)...)
		rootDir := BitWindowDirs.RootDir()
		paths = append(paths, GetExistingFilesInDir(rootDir, []string{"debug.log"}, log)...)

	case "thunder", "plain_bitnames", "plain_bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
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

// LogPath returns the log file path for this binary.
// Dart: logPath (L1378-1392)
func (b BinaryDirConfig) LogPath(networkDir string) string {
	switch b.BinaryName {
	case "bitcoind":
		return filepath.Join(networkDir, "debug.log")

	case "bitwindowd":
		return filepath.Join(networkDir, "server.log")

	case "bip300301-enforcer":
		return findLatestEnforcerLog(networkDir)

	case "thunder", "plain_bitnames", "plain_bitassets", "thunder-orchard", "truthcoin", "photon", "coinshift":
		return findLatestDirVersionedLog(networkDir)

	default:
		return ""
	}
}

// findLatestEnforcerLog finds the latest enforcer log file.
// Dart: _findLatestEnforcerLog (L1394-1437)
func findLatestEnforcerLog(datadirNetwork string) string {
	logsDir := filepath.Join(datadirNetwork, "logs")
	fallback := filepath.Join(datadirNetwork, "bip300301_enforcer.log")

	entries, err := os.ReadDir(logsDir)
	if err != nil {
		return fallback
	}

	pattern := regexp.MustCompile(`^bip300301_enforcer\.log\.(\d{4}-\d{2}-\d{2})\.(\d+)$`)
	type logEntry struct {
		path string
		date string
		seq  int
	}
	var logs []logEntry

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		m := pattern.FindStringSubmatch(e.Name())
		if m == nil {
			continue
		}
		seq := 0
		_, _ = fmt.Sscanf(m[2], "%d", &seq)
		logs = append(logs, logEntry{filepath.Join(logsDir, e.Name()), m[1], seq})
	}

	if len(logs) == 0 {
		return fallback
	}

	// Sort by date desc, then seq desc (latest first)
	sort.Slice(logs, func(i, j int) bool {
		if logs[i].date != logs[j].date {
			return logs[i].date > logs[j].date
		}
		return logs[i].seq > logs[j].seq
	})

	return logs[0].path
}

// findLatestDirVersionedLog finds the latest version-directory log file.
// Dart: _findLatestDirVersionedLog (L1439-1493)
func findLatestDirVersionedLog(datadirNetwork string) string {
	logsDir := filepath.Join(datadirNetwork, "logs")
	fallback := filepath.Join(logsDir, "unknown.log")

	entries, err := os.ReadDir(logsDir)
	if err != nil {
		return fallback
	}

	// Find version directories (v0.1.0, v1.2.3, etc.)
	var versionDirs []string
	for _, e := range entries {
		if e.IsDir() && strings.HasPrefix(e.Name(), "v") {
			versionDirs = append(versionDirs, e.Name())
		}
	}

	if len(versionDirs) == 0 {
		return fallback
	}

	// Sort by version number descending
	sort.Slice(versionDirs, func(i, j int) bool {
		return compareVersions(versionDirs[i][1:], versionDirs[j][1:]) > 0
	})

	latestDir := filepath.Join(logsDir, versionDirs[0])
	logEntries, err := os.ReadDir(latestDir)
	if err != nil {
		return fallback
	}

	var logFiles []string
	for _, e := range logEntries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".log") {
			logFiles = append(logFiles, e.Name())
		}
	}

	if len(logFiles) == 0 {
		return fallback
	}

	// Sort by date in filename descending (YYYY-MM-DD.log)
	sort.Slice(logFiles, func(i, j int) bool {
		dateI := strings.TrimSuffix(logFiles[i], ".log")
		dateJ := strings.TrimSuffix(logFiles[j], ".log")
		return dateI > dateJ
	})

	return filepath.Join(latestDir, logFiles[0])
}

// compareVersions compares two semver strings. Returns >0 if a>b, <0 if a<b, 0 if equal.
func compareVersions(a, b string) int {
	aParts := strings.Split(a, ".")
	bParts := strings.Split(b, ".")

	for i := 0; i < len(aParts) && i < len(bParts); i++ {
		ai, bi := 0, 0
		_, _ = fmt.Sscanf(aParts[i], "%d", &ai)
		_, _ = fmt.Sscanf(bParts[i], "%d", &bi)
		if ai != bi {
			return ai - bi
		}
	}
	return len(aParts) - len(bParts)
}

// ---------------------------------------------------------------------------
// Network helper on Network type
// ---------------------------------------------------------------------------

// ReadableName returns a human-readable network name.
// Dart: toReadableNet() extension
func (n Network) ReadableName() string {
	switch n {
	case NetworkMainnet:
		return "mainnet"
	case NetworkForknet:
		return "forknet"
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
	case "plain_bitnames":
		return []string{"bitnames-cli"}
	case "plain_bitassets":
		return []string{"bitassets-cli"}
	case "thunder-orchard":
		return []string{"thunder-orchard"}
	default:
		return nil
	}
}

// DeleteBinaries deletes binary files and extra files from the assets directory.
// Dart: deleteBinaries (L169-232)
func (b BinaryDirConfig) DeleteBinaries(assetsDir string, log zerolog.Logger) {
	// Delete raw binary assets
	baseFiles := []string{
		b.BinaryName,
		strings.TrimSuffix(b.BinaryName, ".exe"),
		b.BinaryName + ".exe",
		b.BinaryName + ".app",
		b.BinaryName + ".meta",
	}
	DeleteFilesWithRetry(pathsInDir(assetsDir, baseFiles), log)

	// Delete extra per-binary files
	extra := b.ExtraFilesForDeletion(assetsDir)
	if len(extra) > 0 {
		DeleteFilesWithRetry(pathsInDir(assetsDir, extra), log)
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

// ConnectionString returns a display string for this binary's connection.
// Dart: connectionString (L778-793)
func (b BinaryDirConfig) ConnectionString() string {
	return fmt.Sprintf("%s :%d", b.Name, b.Port)
}

func pathsInDir(dir string, files []string) []string {
	var paths []string
	for _, f := range files {
		paths = append(paths, filepath.Join(dir, f))
	}
	return paths
}

// ---------------------------------------------------------------------------
// Batch 5: Version/update checking
// ---------------------------------------------------------------------------

// GitHubCache caches GitHub API responses with a 1-minute TTL.
// Dart: _GitHubCache (L813-840)
type GitHubCache struct {
	entries map[string]*githubCacheEntry
}

type githubCacheEntry struct {
	releaseDate *time.Time
	timestamp   time.Time
}

var globalGitHubCache = &GitHubCache{entries: make(map[string]*githubCacheEntry)}

func (c *GitHubCache) Get(url string) (*time.Time, bool) {
	entry, ok := c.entries[url]
	if !ok {
		return nil, false
	}
	if time.Since(entry.timestamp) >= 1*time.Minute {
		delete(c.entries, url)
		return nil, false
	}
	return entry.releaseDate, true
}

func (c *GitHubCache) Set(url string, releaseDate *time.Time) {
	c.entries[url] = &githubCacheEntry{releaseDate: releaseDate, timestamp: time.Now()}
}

// CheckReleaseDate checks the release date for a binary without downloading.
// Dart: _checkReleaseDate (L680-691)
func (b BinaryDirConfig) CheckReleaseDate(downloadURL string, downloadSource int, fileName string) (*time.Time, error) {
	if strings.Contains(downloadURL, "github.com") {
		return checkGithubReleaseDate(downloadURL)
	}
	return checkDirectReleaseDate(downloadURL, fileName)
}

// checkGithubReleaseDate checks the GitHub API for release date.
// Dart: _checkGithubReleaseDate (L693-737)
func checkGithubReleaseDate(url string) (*time.Time, error) {
	if cached, ok := globalGitHubCache.Get(url); ok {
		return cached, nil
	}

	resp, err := http.Get(url)
	if err != nil {
		globalGitHubCache.Set(url, nil)
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode == 403 || resp.StatusCode != 200 {
		globalGitHubCache.Set(url, nil)
		return nil, fmt.Errorf("GitHub API returned %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		globalGitHubCache.Set(url, nil)
		return nil, err
	}

	// Simple JSON parsing for published_at
	var release struct {
		PublishedAt string `json:"published_at"`
	}
	if err := json.Unmarshal(body, &release); err != nil {
		globalGitHubCache.Set(url, nil)
		return nil, err
	}

	if release.PublishedAt == "" {
		globalGitHubCache.Set(url, nil)
		return nil, fmt.Errorf("no published_at in release")
	}

	t, err := time.Parse(time.RFC3339, release.PublishedAt)
	if err != nil {
		globalGitHubCache.Set(url, nil)
		return nil, err
	}

	globalGitHubCache.Set(url, &t)
	return &t, nil
}

// checkDirectReleaseDate checks the Last-Modified header for a direct download.
// Dart: _checkDirectReleaseDate (L739-771)
func checkDirectReleaseDate(baseURL, fileName string) (*time.Time, error) {
	if fileName == "" || baseURL == "" {
		return nil, nil
	}

	downloadURL := baseURL + fileName

	resp, err := http.Head(downloadURL)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("HEAD %s returned %d", downloadURL, resp.StatusCode)
	}

	lastModified := resp.Header.Get("Last-Modified")
	if lastModified == "" {
		return nil, fmt.Errorf("no Last-Modified header")
	}

	t, err := http.ParseTime(lastModified)
	if err != nil {
		return nil, err
	}

	return &t, nil
}

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

// ---------------------------------------------------------------------------
// Batch 6: Metadata/state types
// ---------------------------------------------------------------------------

// DownloadProgress tracks download progress for a binary.
// Dart: DownloadInfo class (L1969-2025)
type DownloadProgress struct {
	Progress     float64   // bytes downloaded
	Total        float64   // total bytes
	Error        string    // error message
	Message      string    // status message
	Hash         string    // SHA256 hash
	DownloadedAt time.Time // when download completed
	IsDownloading bool
}

// ProgressPercent returns the download progress as a percentage (0.0-1.0).
// Dart: DownloadInfo.progressPercent getter
func (d DownloadProgress) ProgressPercent() float64 {
	if d.Total <= 0 {
		return 0
	}
	return d.Progress / d.Total
}

// ProcessLogEntry stores a single process log line.
// Dart: ProcessLogEntry class (L2027-2035)
type ProcessLogEntry struct {
	Timestamp time.Time
	Message   string
}

// ShutdownProgressInfo reports progress during shutdown.
// Dart: ShutdownProgress class (L1954-1966)
type ShutdownProgressInfo struct {
	TotalCount    int
	CompletedCount int
	CurrentBinary string
	IsForceKill   bool
}
