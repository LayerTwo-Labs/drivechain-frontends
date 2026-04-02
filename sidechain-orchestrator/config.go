package orchestrator

import (
	"fmt"
	"path/filepath"
	"runtime"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

type HealthCheckType int

const (
	HealthCheckTCP     HealthCheckType = iota
	HealthCheckJSONRPC                 // JSON-RPC call (e.g. getblockcount)
)

type DownloadSource int

const (
	DownloadSourceDirect DownloadSource = iota // Direct URL from releases.drivechain.info
	DownloadSourceGitHub                       // GitHub releases API (regex matching)
)

// BinaryConfig is the 1:1 Go port of Dart's Binary abstract class + subclasses.
// Every field maps to a Dart property from binaries.dart / sidechains.dart.
type BinaryConfig struct {
	// Core identity — Dart: Binary constructor params (L61-72)
	Name        string // Dart: Binary.name (internal identifier, e.g. "bitcoind", "thunder")
	DisplayName string // Dart: Binary.name in subclass (e.g. "Bitcoin Core (Patched)")
	BinaryName  string // Dart: Binary.binary (executable name, from metadata.downloadConfig.binary)
	Version     string // Dart: Binary.version
	Description string // Dart: Binary.description
	RepoURL     string // Dart: Binary.repoUrl
	Port        int    // Dart: Binary.port
	ChainLayer  int    // Dart: Binary.chainLayer (0=utility, 1=L1, 2=sidechain)
	Slot        int    // Dart: Sidechain.slot (0 for non-sidechains)

	// Directory configuration — Dart: DirectoryConfig class
	DataDir        map[string]string // os -> subdir under AppDir() (default for all networks)
	DataDirMainnet map[string]string // os -> subdir (mainnet override, empty = use DataDir)
	IsBitcoinCore  bool              // Linux appdir exception: ~/ instead of ~/.local/share

	// Flutter frontend directory — Dart: flutterFrontendDir() extension (L1306-1353)
	// Per-OS subdir under the platform app support dir. Empty = no frontend.
	FlutterFrontendDir map[string]string

	// Primary download configuration — Dart: MetadataConfig.downloadConfig
	DownloadSource   DownloadSource
	DownloadURLs     map[string]string // network -> base URL ("default", "forknet", etc.)
	Files            map[string]string // os -> filename or regex pattern
	ForknetFiles     map[string]string // os -> forknet-specific filename (BitcoinCore only)
	ExtractSubfolder map[string]string // os -> subfolder to extract from zip (empty = root)

	// Alternative download configuration — Dart: MetadataConfig.alternativeDownloadConfig
	// Used for test chain builds when SettingsProvider selects it.
	AltDownloadURLs     map[string]string // network -> base URL
	AltBinaryName       string            // Dart: alternativeDownloadConfig.binary
	AltFiles            map[string]string // os -> filename
	AltExtractSubfolder map[string]string // os -> subfolder

	// Dart: MetadataConfig.updateable
	Updateable bool

	// Dart: Binary.startupLogPatterns (regex strings)
	StartupLogPatterns []string

	// Dart: Binary.extraBootArgs
	ExtraBootArgs []string

	// Health check (Go-specific, not in Dart Binary)
	HealthCheckType HealthCheckType
	HealthCheckRPC  string // JSON-RPC method for health check

	// Dependencies: names of binaries that must be running before this one
	Dependencies []string
}

func currentOS() string {
	switch runtime.GOOS {
	case "darwin":
		return "macos"
	case "windows":
		return "windows"
	default:
		return "linux"
	}
}

// Downloadable returns true if this binary has download URLs configured.
func (c BinaryConfig) Downloadable() bool {
	f, _ := c.FileForOS()
	return f != "" && c.BaseURL("default") != ""
}

// FileForOS returns the download filename for the current platform.
func (c BinaryConfig) FileForOS() (string, error) {
	f, ok := c.Files[currentOS()]
	if !ok || f == "" {
		return "", fmt.Errorf("no download file for %s on %s", c.Name, currentOS())
	}
	return f, nil
}

// BaseURL returns the download base URL for a given network.
// Falls back to "default", then to the first available URL.
func (c BinaryConfig) BaseURL(network string) string {
	if url, ok := c.DownloadURLs[network]; ok && url != "" {
		return url
	}
	if url, ok := c.DownloadURLs["default"]; ok {
		return url
	}
	for _, url := range c.DownloadURLs {
		return url
	}
	return ""
}

// AltBaseURL returns the alternative download base URL for a given network.
func (c BinaryConfig) AltBaseURL(network string) string {
	if url, ok := c.AltDownloadURLs[network]; ok && url != "" {
		return url
	}
	if url, ok := c.AltDownloadURLs["default"]; ok {
		return url
	}
	for _, url := range c.AltDownloadURLs {
		return url
	}
	return ""
}

// BinDir returns the directory where binaries are stored.
func BinDir(dataDir string) string {
	return filepath.Join(dataDir, "assets", "bin")
}

// PidDir returns the directory where PID files are stored.
func PidDir(dataDir string) string {
	return filepath.Join(dataDir, "pids")
}

// LogDir returns the directory where logs are stored.
func LogDir(dataDir string) string {
	return filepath.Join(dataDir, "logs")
}

// BinaryPath returns the full path to a binary executable.
func BinaryPath(dataDir, binaryName string) string {
	name := binaryName
	if runtime.GOOS == "windows" {
		name += ".exe"
	}
	return filepath.Join(BinDir(dataDir), name)
}

// DefaultDataDir returns the default data directory for the orchestrator.
// This is the same as the BitWindow data directory, since orchestrator
// stores its assets (binaries, configs) alongside BitWindow.
func DefaultDataDir() string {
	return DefaultBitwindowDir()
}

// DefaultBitwindowDir returns the default BitWindow data directory.
// Uses the BitWindow binary directory config as the single source of truth.
func DefaultBitwindowDir() string {
	return config.BitWindowDirs.RootDir()
}

// DefaultBitcoinCore returns the config for Bitcoin Core (patched).
// Dart: BitcoinCore class (binaries.dart L843-955)
func DefaultBitcoinCore() BinaryConfig {
	return BinaryConfig{
		Name:        "bitcoind",
		DisplayName: "Bitcoin Core",
		BinaryName:  "bitcoind",
		Version:     "30.2",
		Description: "Bitcoin Core",
		RepoURL:     "https://github.com/bitcoin/bitcoin",
		Port:        0, // determined by network at runtime
		ChainLayer:  1,
		Slot:        0,

		DataDir:        map[string]string{"linux": ".drivechain", "macos": "Drivechain", "windows": "Drivechain"},
		DataDirMainnet: map[string]string{"linux": ".bitcoin", "macos": "Bitcoin", "windows": "Bitcoin"},
		IsBitcoinCore:  true,

		DownloadSource: DownloadSourceDirect,
		DownloadURLs: map[string]string{
			"default": "https://bitcoincore.org/bin/bitcoin-core-30.2/",
			"forknet": "https://releases.drivechain.info/",
		},
		Files: map[string]string{
			"linux":   "bitcoin-30.2-x86_64-linux-gnu.tar.gz",
			"macos":   "bitcoin-30.2-x86_64-apple-darwin.tar.gz",
			"windows": "bitcoin-30.2-win64.zip",
		},
		ForknetFiles: map[string]string{
			"linux":   "L1-bitcoin-patched-forknet-x86_64-unknown-linux-gnu.zip",
			"macos":   "L1-bitcoin-patched-forknet-x86_64-apple-darwin.zip",
			"windows": "L1-bitcoin-patched-forknet-x86_64-w64-msvc.zip",
		},
		// extractSubfolder only for forknet (default extracts to root, recursive extraction finds binaries)
		ExtractSubfolder: map[string]string{
			"linux": "forknet", "macos": "forknet", "windows": "forknet",
		},

		// Dart L919-929
		StartupLogPatterns: []string{
			`init message:`,
			`Verifying last \d+ blocks`,
			`Verification progress: \d+%`,
			`Verification: No coin database inconsistencies`,
			`Loading block index`,
			`Done loading`,
			`Synchronizing blockheaders`,
			`Rescan completed in`,
			`Rescan started from block`,
		},

		HealthCheckType: HealthCheckJSONRPC,
		HealthCheckRPC:  "getblockcount",
		Dependencies:    nil,
	}
}

// DefaultEnforcer returns the config for the BIP300301 enforcer.
// Dart: Enforcer class (binaries.dart L1117-1221)
func DefaultEnforcer() BinaryConfig {
	return BinaryConfig{
		Name:        "enforcer",
		DisplayName: "BIP300301 Enforcer",
		BinaryName:  "bip300301-enforcer",
		Version:     "0.1.0",
		Description: "Manages drivechain validation rules",
		RepoURL:     "https://github.com/LayerTwo-Labs/bip300301-enforcer",
		Port:        50051,
		ChainLayer:  1,
		Slot:        0,

		DataDir: map[string]string{"linux": "bip300301_enforcer", "macos": "bip300301_enforcer", "windows": "bip300301_enforcer"},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "bip300301-enforcer-latest-x86_64-apple-darwin.zip",
			"windows": "bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip",
		},

		// Dart L1171-1195
		StartupLogPatterns: []string{
			`Starting up bip300301_enforcer`,
			`verified mainchain REST server is enabled`,
			`verified mainchain REST server at`,
			`created mainchain JSON-RPC client`,
			`Connected to mainchain client network=\w+ blocks=\d+`,
			`Created validator DBs in`,
			`Instantiating \w+ wallet`,
			`creating esplora client esplora_url=`,
			`esplora client initialized height=\d+`,
			`Created database connection to`,
			`Loaded existing BDK wallet`,
			`wallet inner: wired together components`,
			`Listening for JSON-RPC on`,
			`Listening for gRPC on`,
			`Connected to ZMQ server`,
			`Reached main tip at height \d+!`,
			`Synced \d+ headers in`,
			`starting batched sync`,
			`Synced batch of \d+ blocks in`,
			`Synced \d+ blocks in`,
			`enforcer synced to tip!`,
			`Initial mempool sync complete`,
			`initial_mempool_sync:`,
		},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind"},
	}
}

// DefaultBitWindow returns the config for the BitWindow daemon.
// Dart: BitWindow class (binaries.dart L958)
func DefaultBitWindow() BinaryConfig {
	return BinaryConfig{
		Name:        "bitwindowd",
		DisplayName: "BitWindow",
		BinaryName:  "bitwindowd",
		Version:     "latest",
		Description: "GUI for managing drivechain operations",
		RepoURL:     "https://github.com/LayerTwo-Labs/drivechain-frontends/bitwindow",
		Port:        30301,
		ChainLayer:  1,
		Slot:        0,

		// Dart L974-978: allNetworks({ linux: 'bitwindow', ... })
		DataDir: map[string]string{"linux": "bitwindow", "macos": "bitwindow", "windows": "bitwindow"},

		// Dart L1311-1314: Flutter frontend dirs
		FlutterFrontendDir: map[string]string{
			"linux":   "bitwindow",
			"macos":   "bitwindow",
			"windows": "10520LayertwoLabs/BitWindow", // Dart L1313
		},

		DownloadSource:  DownloadSourceDirect,
		DownloadURLs:    map[string]string{}, // not downloadable
		Files:           map[string]string{},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultThunder returns the config for the Thunder sidechain.
// Dart: Thunder class (sidechains.dart L261-356)
func DefaultThunder() BinaryConfig {
	return BinaryConfig{
		Name:        "thunder",
		DisplayName: "Thunder",
		BinaryName:  "thunder",
		Version:     "latest",
		Description: "Large & growing blocksize, plus fraud proofs", // Dart L265
		RepoURL:     "https://github.com/layerTwo-Labs/thunder-rust", // Dart L266
		Port:        6009,
		ChainLayer:  2,
		Slot:        9,

		DataDir: map[string]string{"linux": "thunder", "macos": "Thunder", "windows": "thunder"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.thunder", "macos": "com.layertwolabs.thunder", "windows": "LayerTwoLabs/Thunder",
		},

		// Dart L291-298: primary download
		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S9-Thunder-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip",
		},
		// Dart L300-312: alternative download (test builds)
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "thunder",
		AltFiles: map[string]string{
			"linux":   "test-thunder-x86_64-unknown-linux-gnu.zip",
			"macos":   "test-thunder-x86_64-apple-darwin.zip",
			"windows": "test-thunder-x86_64-windows.exe",
		},
		AltExtractSubfolder: map[string]string{"linux": "thunder", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultBitNames returns the config for the BitNames sidechain.
// Dart: BitNames class (sidechains.dart L358-453)
func DefaultBitNames() BinaryConfig {
	return BinaryConfig{
		Name:        "bitnames",
		DisplayName: "Bitnames",
		BinaryName:  "plain_bitnames",
		Version:     "latest",
		Description: "Variant of BitDNS that aims to replace ICANN", // Dart L362
		RepoURL:     "https://github.com/LayerTwo-Labs/plain-bitnames",
		Port:        6002,
		ChainLayer:  2,
		Slot:        2,

		DataDir: map[string]string{"linux": "plain_bitnames", "macos": "plain_bitnames", "windows": "plain_bitnames"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.bitnames", "macos": "com.layertwolabs.bitnames", "windows": "LayerTwoLabs/BitNames",
		},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "L2-S2-BitNames-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S2-BitNames-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S2-BitNames-latest-x86_64-pc-windows-gnu.zip",
		},
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "bitnames",
		AltFiles: map[string]string{
			"linux": "test-bitnames-x86_64-unknown-linux-gnu.zip", "macos": "test-bitnames-x86_64-apple-darwin.zip", "windows": "test-bitnames-x86_64-windows.exe",
		},
		AltExtractSubfolder: map[string]string{"linux": "bitnames", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultBitAssets returns the config for the BitAssets sidechain.
// Dart: BitAssets class (sidechains.dart L455-550)
func DefaultBitAssets() BinaryConfig {
	return BinaryConfig{
		Name:        "bitassets",
		DisplayName: "BitAssets",
		BinaryName:  "plain_bitassets",
		Version:     "latest",
		Description: "Variant of BitDNS that aims to replace ICANN", // Dart L459
		RepoURL:     "https://github.com/LayerTwo-Labs/plain-bitassets",
		Port:        6004,
		ChainLayer:  2,
		Slot:        4,

		DataDir: map[string]string{"linux": "plain_bitassets", "macos": "plain_bitassets", "windows": "plain_bitassets"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.bitassets", "macos": "com.layertwolabs.bitassets", "windows": "LayerTwoLabs/BitAssets",
		},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "L2-S4-BitAssets-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S4-BitAssets-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S4-BitAssets-latest-x86_64-pc-windows-gnu.zip",
		},
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "bitassets",
		AltFiles: map[string]string{
			"linux": "test-bitassets-x86_64-unknown-linux-gnu.zip", "macos": "test-bitassets-x86_64-apple-darwin.zip", "windows": "test-bitassets-x86_64-windows.exe",
		},
		AltExtractSubfolder: map[string]string{"linux": "bitassets", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultZSide returns the config for the ZSide sidechain.
// Dart: ZSide class (sidechains.dart L164-259)
func DefaultZSide() BinaryConfig {
	return BinaryConfig{
		Name:        "zside",
		DisplayName: "zSide",
		BinaryName:  "thunder-orchard",
		Version:     "0.1.0", // Dart L167
		Description: "ZSide Sidechain", // Dart L168
		RepoURL:     "https://github.com/iwakura-rein/thunder-orchard",
		Port:        6098,
		ChainLayer:  2,
		Slot:        98,

		DataDir: map[string]string{"linux": "thunder-orchard", "macos": "thunder-orchard", "windows": "thunder-orchard"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.zside", "macos": "com.layertwolabs.zside", "windows": "LayerTwoLabs/ZSide",
		},

		// Dart L194-201: primary download (GitHub)
		DownloadSource: DownloadSourceGitHub,
		DownloadURLs:   map[string]string{"default": "https://api.github.com/repos/iwakura-rein/thunder-orchard/releases/latest"},
		Files: map[string]string{
			"linux":   `thunder-orchard-\d+\.\d+\.\d+-x86_64-unknown-linux-gnu`,
			"macos":   `thunder-orchard-\d+\.\d+\.\d+-x86_64-apple-darwin`,
			"windows": "",
		},
		// Dart L203-215: alternative download (test builds)
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "zside",
		AltFiles: map[string]string{
			"linux":   "test-zside-x86_64-unknown-linux-gnu.zip",
			"macos":   "test-zside-x86_64-apple-darwin.zip",
			"windows": "",
		},
		AltExtractSubfolder: map[string]string{"linux": "zside", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultTruthcoin returns the config for the Truthcoin sidechain.
// Dart: Truthcoin class (sidechains.dart L552-647)
func DefaultTruthcoin() BinaryConfig {
	return BinaryConfig{
		Name:        "truthcoin",
		DisplayName: "Truthcoin",
		BinaryName:  "truthcoin",
		Version:     "latest",
		Description: "Bitcoin Hivemind prediction market sidechain", // Dart L556
		RepoURL:     "https://github.com/LayerTwo-Labs/truthcoin",
		Port:        6013,
		ChainLayer:  2,
		Slot:        13,

		DataDir: map[string]string{"linux": "truthcoin", "macos": "truthcoin", "windows": "truthcoin"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.truthcoin", "macos": "com.layertwolabs.truthcoin", "windows": "LayerTwoLabs/Truthcoin",
		},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "L2-S13-Truthcoin-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S13-Truthcoin-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S13-Truthcoin-latest-x86_64-pc-windows-gnu.zip",
		},
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "truthcoin",
		AltFiles: map[string]string{
			"linux": "test-truthcoin-x86_64-unknown-linux-gnu.zip", "macos": "test-truthcoin-x86_64-apple-darwin.zip", "windows": "test-truthcoin-x86_64-windows.exe",
		},
		AltExtractSubfolder: map[string]string{"linux": "truthcoin", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultPhoton returns the config for the Photon sidechain.
// Dart: Photon class (sidechains.dart L649-744)
func DefaultPhoton() BinaryConfig {
	return BinaryConfig{
		Name:        "photon",
		DisplayName: "Photon",
		BinaryName:  "photon",
		Version:     "latest",
		Description: "Photon sidechain", // Dart L653
		RepoURL:     "https://github.com/LayerTwo-Labs/photon",
		Port:        6099,
		ChainLayer:  2,
		Slot:        99,

		DataDir: map[string]string{"linux": "photon", "macos": "photon", "windows": "photon"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.photon", "macos": "com.layertwolabs.photon", "windows": "LayerTwoLabs/Photon",
		},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "L2-S99-Photon-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S99-Photon-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S99-Photon-latest-x86_64-pc-windows-gnu.zip",
		},
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "photon",
		AltFiles: map[string]string{
			"linux": "test-photon-x86_64-unknown-linux-gnu.zip", "macos": "test-photon-x86_64-apple-darwin.zip", "windows": "test-photon-x86_64-windows.exe",
		},
		AltExtractSubfolder: map[string]string{"linux": "photon", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultCoinShift returns the config for the CoinShift sidechain.
// Dart: CoinShift class (sidechains.dart L746-841)
func DefaultCoinShift() BinaryConfig {
	return BinaryConfig{
		Name:        "coinshift",
		DisplayName: "CoinShift",
		BinaryName:  "coinshift",
		Version:     "latest",
		Description: "CoinShift sidechain", // Dart L750
		RepoURL:     "https://github.com/LayerTwo-Labs/coinshift",
		Port:        6255,
		ChainLayer:  2,
		Slot:        255,

		DataDir: map[string]string{"linux": "coinshift", "macos": "coinshift", "windows": "coinshift"},
		FlutterFrontendDir: map[string]string{
			"linux": "com.layertwolabs.coinshift", "macos": "com.layertwolabs.coinshift", "windows": "LayerTwoLabs/Coinshift",
		},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "https://releases.drivechain.info/"},
		Files: map[string]string{
			"linux":   "L2-S255-Coinshift-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S255-Coinshift-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S255-Coinshift-latest-x86_64-pc-windows-gnu.zip",
		},
		AltDownloadURLs: map[string]string{"default": "https://releases.drivechain.info/"},
		AltBinaryName:  "coinshift",
		AltFiles: map[string]string{
			"linux": "test-coinshift-x86_64-unknown-linux-gnu.zip", "macos": "test-coinshift-x86_64-apple-darwin.zip", "windows": "test-coinshift-x86_64-windows.exe",
		},
		AltExtractSubfolder: map[string]string{"linux": "coinshift", "macos": "", "windows": ""},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultGRPCurl returns the config for grpcurl (utility binary).
// Dart: GRPCurl class (binaries.dart L1223-1300)
func DefaultGRPCurl() BinaryConfig {
	return BinaryConfig{
		Name:        "grpcurl",
		DisplayName: "grpcurl",
		BinaryName:  "grpcurl",
		Version:     "latest",
		Description: "Command-line tool for interacting with gRPC servers",
		RepoURL:     "https://github.com/fullstorydev/grpcurl",
		Port:        0,
		ChainLayer:  0,
		Slot:        0,

		DataDir: map[string]string{"linux": "grpcurl", "macos": "grpcurl", "windows": "grpcurl"},

		DownloadSource: DownloadSourceGitHub,
		DownloadURLs:   map[string]string{"default": "https://api.github.com/repos/fullstorydev/grpcurl/releases/latest"},
		Files: map[string]string{
			"linux":   `grpcurl_\d+\.\d+\.\d+_linux_x86_64\.tar\.gz`,
			"macos":   `grpcurl_\d+\.\d+\.\d+_osx_x86_64\.tar\.gz`,
			"windows": `grpcurl_\d+\.\d+\.\d+_windows_x86_64\.zip`,
		},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    nil,
	}
}

// DefaultThunderd returns the config for the Thunder orchestrator daemon.
// Dart: Thunderd class (binaries.dart L1038-1115)
func DefaultThunderd() BinaryConfig {
	return BinaryConfig{
		Name:        "thunderd",
		DisplayName: "Thunderd",
		BinaryName:  "thunderd",
		Version:     "latest",
		Description: "Thunder sidechain orchestrator daemon", // Dart L1042
		RepoURL:     "https://github.com/LayerTwo-Labs/drivechain-frontends/thunder/server",
		Port:        30302,
		ChainLayer:  1,
		Slot:        0,

		// Dart L1054-1063: same dirs as thunder
		DataDir: map[string]string{"linux": "thunder", "macos": "thunder", "windows": "thunder"},
		FlutterFrontendDir: map[string]string{"linux": "thunder", "macos": "thunder", "windows": "thunder"},

		DownloadSource: DownloadSourceDirect,
		DownloadURLs:   map[string]string{}, // not downloadable (bundled)
		Files:          map[string]string{},

		HealthCheckType: HealthCheckTCP,
		Dependencies:    nil,
	}
}

// AllDefaults returns configs for every known binary.
// Dart: BinaryTypeExtension.binary (L31-45)
func AllDefaults() []BinaryConfig {
	return []BinaryConfig{
		DefaultBitcoinCore(),
		DefaultEnforcer(),
		DefaultBitWindow(),
		DefaultThunderd(),
		DefaultThunder(),
		DefaultBitNames(),
		DefaultBitAssets(),
		DefaultZSide(),
		DefaultTruthcoin(),
		DefaultPhoton(),
		DefaultCoinShift(),
		DefaultGRPCurl(),
	}
}

// AllSidechains returns configs for all sidechain binaries (ChainLayer == 2).
// Dart: Sidechain.all (sidechains.dart L49-57)
func AllSidechains() []BinaryConfig {
	var sidechains []BinaryConfig
	for _, c := range AllDefaults() {
		if c.ChainLayer == 2 {
			sidechains = append(sidechains, c)
		}
	}
	return sidechains
}

// BinaryConfigByName returns the default config for a binary by name.
// Dart: Sidechain.fromString (sidechains.dart L23-47)
func BinaryConfigByName(name string) (BinaryConfig, bool) {
	for _, c := range AllDefaults() {
		if c.Name == name || c.BinaryName == name || c.DisplayName == name {
			return c, true
		}
	}
	return BinaryConfig{}, false
}

// BinaryConfigBySlot returns the sidechain config for a given slot number.
// Dart: Sidechain.fromSlot (sidechains.dart L59-66)
func BinaryConfigBySlot(slot int) (BinaryConfig, bool) {
	for _, c := range AllDefaults() {
		if c.Slot == slot && c.ChainLayer == 2 {
			return c, true
		}
	}
	return BinaryConfig{}, false
}

// IsSidechain returns true if this binary is a sidechain (ChainLayer == 2).
func (c BinaryConfig) IsSidechain() bool {
	return c.ChainLayer == 2
}
