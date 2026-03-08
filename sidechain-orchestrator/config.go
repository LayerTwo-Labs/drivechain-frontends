package orchestrator

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
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

type BinaryConfig struct {
	Name        string
	DisplayName string
	BinaryName  string // executable name (e.g. "thunder", "bitcoind")
	Port        int
	ChainLayer  int // 0=utility, 1=L1, 2=sidechain
	Slot        int // sidechain slot number (0 for non-sidechains)

	// Download configuration
	DownloadSource DownloadSource
	DownloadURL    string            // base URL for releases (or GitHub API URL)
	Files          map[string]string // os -> filename or regex pattern

	// Health check
	HealthCheckType HealthCheckType
	HealthCheckRPC  string // JSON-RPC method for health check (e.g. "getblockcount")

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

// FileForOS returns the download filename for the current platform.
func (c BinaryConfig) FileForOS() (string, error) {
	f, ok := c.Files[currentOS()]
	if !ok || f == "" {
		return "", fmt.Errorf("no download file for %s on %s", c.Name, currentOS())
	}
	return f, nil
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

// DefaultDataDir returns the default data directory (~/.sail).
func DefaultDataDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return filepath.Join(".", ".sail")
	}
	return filepath.Join(home, ".sail")
}

// DefaultBitwindowDir returns the default BitWindow data directory.
func DefaultBitwindowDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return filepath.Join(".", ".drivechain", "bitwindow")
	}
	return filepath.Join(home, ".drivechain", "bitwindow")
}

// DefaultBitcoinCore returns the config for Bitcoin Core (patched).
func DefaultBitcoinCore() BinaryConfig {
	files := map[string]string{
		"linux":   "L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip",
		"macos":   "L1-bitcoin-patched-latest-x86_64-apple-darwin.zip",
		"windows": "L1-bitcoin-patched-latest-x86_64-w64-msvc.zip",
	}

	return BinaryConfig{
		Name:            "bitcoind",
		DisplayName:     "Bitcoin Core (Patched)",
		BinaryName:      "bitcoind",
		Port:            0, // determined by network at runtime
		ChainLayer:      1,
		Slot:            0,
		DownloadSource:  DownloadSourceDirect,
		DownloadURL:     "https://releases.drivechain.info/",
		Files:           files,
		HealthCheckType: HealthCheckJSONRPC,
		HealthCheckRPC:  "getblockcount",
		Dependencies:    nil,
	}
}

// DefaultEnforcer returns the config for the BIP300301 enforcer.
func DefaultEnforcer() BinaryConfig {
	return BinaryConfig{
		Name:        "enforcer",
		DisplayName: "BIP300301 Enforcer",
		BinaryName:  "bip300301-enforcer",
		Port:        50051,
		ChainLayer:  1,
		Slot:        0,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "bip300301-enforcer-latest-x86_64-apple-darwin.zip",
			"windows": "bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind"},
	}
}

// DefaultBitWindow returns the config for the BitWindow daemon.
func DefaultBitWindow() BinaryConfig {
	return BinaryConfig{
		Name:            "bitwindowd",
		DisplayName:     "BitWindow",
		BinaryName:      "bitwindowd",
		Port:            30301,
		ChainLayer:      1,
		Slot:            0,
		DownloadSource:  DownloadSourceDirect,
		DownloadURL:     "", // not downloadable
		Files:           map[string]string{},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultThunder returns the config for the Thunder sidechain.
func DefaultThunder() BinaryConfig {
	return BinaryConfig{
		Name:        "thunder",
		DisplayName: "Thunder",
		BinaryName:  "thunder",
		Port:        6009,
		ChainLayer:  2,
		Slot:        9,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S9-Thunder-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultBitNames returns the config for the BitNames sidechain.
func DefaultBitNames() BinaryConfig {
	return BinaryConfig{
		Name:        "bitnames",
		DisplayName: "Bitnames",
		BinaryName:  "plain_bitnames",
		Port:        6002,
		ChainLayer:  2,
		Slot:        2,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "L2-S2-BitNames-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S2-BitNames-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S2-BitNames-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultBitAssets returns the config for the BitAssets sidechain.
func DefaultBitAssets() BinaryConfig {
	return BinaryConfig{
		Name:        "bitassets",
		DisplayName: "BitAssets",
		BinaryName:  "plain_bitassets",
		Port:        6004,
		ChainLayer:  2,
		Slot:        4,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "L2-S4-BitAssets-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S4-BitAssets-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S4-BitAssets-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultZSide returns the config for the ZSide sidechain.
func DefaultZSide() BinaryConfig {
	return BinaryConfig{
		Name:        "zside",
		DisplayName: "zSide",
		BinaryName:  "thunder-orchard",
		Port:        6098,
		ChainLayer:  2,
		Slot:        98,
		DownloadSource: DownloadSourceGitHub,
		DownloadURL:    "https://api.github.com/repos/iwakura-rein/thunder-orchard/releases/latest",
		Files: map[string]string{
			"linux":   `thunder-orchard-\d+\.\d+\.\d+-x86_64-unknown-linux-gnu`,
			"macos":   `thunder-orchard-\d+\.\d+\.\d+-x86_64-apple-darwin`,
			"windows": "", // not available
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultTruthcoin returns the config for the Truthcoin sidechain.
func DefaultTruthcoin() BinaryConfig {
	return BinaryConfig{
		Name:        "truthcoin",
		DisplayName: "Truthcoin",
		BinaryName:  "truthcoin",
		Port:        6013,
		ChainLayer:  2,
		Slot:        13,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "L2-S13-Truthcoin-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S13-Truthcoin-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S13-Truthcoin-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultPhoton returns the config for the Photon sidechain.
func DefaultPhoton() BinaryConfig {
	return BinaryConfig{
		Name:        "photon",
		DisplayName: "Photon",
		BinaryName:  "photon",
		Port:        6099,
		ChainLayer:  2,
		Slot:        99,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "L2-S99-Photon-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S99-Photon-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S99-Photon-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultCoinShift returns the config for the CoinShift sidechain.
func DefaultCoinShift() BinaryConfig {
	return BinaryConfig{
		Name:        "coinshift",
		DisplayName: "CoinShift",
		BinaryName:  "coinshift",
		Port:        6255,
		ChainLayer:  2,
		Slot:        255,
		DownloadSource: DownloadSourceDirect,
		DownloadURL:    "https://releases.drivechain.info/",
		Files: map[string]string{
			"linux":   "L2-S255-Coinshift-latest-x86_64-unknown-linux-gnu.zip",
			"macos":   "L2-S255-Coinshift-latest-x86_64-apple-darwin.zip",
			"windows": "L2-S255-Coinshift-latest-x86_64-pc-windows-gnu.zip",
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    []string{"bitcoind", "enforcer"},
	}
}

// DefaultGRPCurl returns the config for grpcurl (utility binary).
func DefaultGRPCurl() BinaryConfig {
	return BinaryConfig{
		Name:        "grpcurl",
		DisplayName: "grpcurl",
		BinaryName:  "grpcurl",
		Port:        0,
		ChainLayer:  0,
		Slot:        0,
		DownloadSource: DownloadSourceGitHub,
		DownloadURL:    "https://api.github.com/repos/fullstorydev/grpcurl/releases/latest",
		Files: map[string]string{
			"linux":   `grpcurl_\d+\.\d+\.\d+_linux_x86_64\.tar\.gz`,
			"macos":   `grpcurl_\d+\.\d+\.\d+_osx_x86_64\.tar\.gz`,
			"windows": `grpcurl_\d+\.\d+\.\d+_windows_x86_64\.zip`,
		},
		HealthCheckType: HealthCheckTCP,
		Dependencies:    nil,
	}
}

// AllDefaults returns configs for every known binary.
func AllDefaults() []BinaryConfig {
	return []BinaryConfig{
		DefaultBitcoinCore(),
		DefaultEnforcer(),
		DefaultBitWindow(),
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
