package orchestrator

import (
	"fmt"
	"path/filepath"
	"runtime"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

type HealthCheckType int

const (
	HealthCheckTCP        HealthCheckType = iota
	HealthCheckJSONRPC                    // JSON-RPC call (e.g. getblockcount)
	HealthCheckConnectRPC                 // Connect-JSON POST (e.g. cusf.mainchain.v1.ValidatorService/GetChainTip)
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

	// Core variant configuration — only populated for the bitcoincore entry.
	// Keys are variant IDs (e.g. "untouched", "touched", "knots").
	Variants map[string]CoreVariantSpec

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

// CoreVariantSpec describes a single Bitcoin Core build variant.
type CoreVariantSpec struct {
	ID                string
	Subfolder         string
	BaseURL           string
	Files             map[string]string // os -> filename
	AvailableNetworks []string
}

// FileForOS returns the variant's download filename for the current platform.
func (v CoreVariantSpec) FileForOS() (string, error) {
	f, ok := v.Files[currentOS()]
	if !ok || f == "" {
		return "", fmt.Errorf("no download file for variant %s on %s", v.ID, currentOS())
	}
	return f, nil
}

// AvailableOn reports whether the variant is offered for the given network.
func (v CoreVariantSpec) AvailableOn(network string) bool {
	for _, n := range v.AvailableNetworks {
		if n == network {
			return true
		}
	}
	return false
}

// DefaultCoreVariantID is the variant used when no settings file exists.
const DefaultCoreVariantID = "touched"

// BinDir returns the directory where binaries are stored.
func BinDir(dataDir string) string {
	return filepath.Join(dataDir, "assets", "bin")
}

// CoreBinaryPath returns the on-disk path for a given Core variant's binary.
// Variant subfolders keep all three builds coexistent under BinDir.
func CoreBinaryPath(dataDir string, variant CoreVariantSpec, binaryName string) string {
	name := binaryName
	if runtime.GOOS == "windows" {
		name += ".exe"
	}
	if variant.Subfolder == "" {
		return filepath.Join(BinDir(dataDir), name)
	}
	return filepath.Join(BinDir(dataDir), variant.Subfolder, name)
}

// testSidechainSubfolder is the on-disk namespace for layer-2 test/alternative
// builds. Keeps prod and test binaries side-by-side so flipping the toggle
// doesn't trash the cached download.
const testSidechainSubfolder = "test"

// TestSidechainBinaryPath returns the on-disk path for a layer-2 test build.
func TestSidechainBinaryPath(dataDir, binaryName string) string {
	name := binaryName
	if runtime.GOOS == "windows" {
		name += ".exe"
	}
	return filepath.Join(BinDir(dataDir), testSidechainSubfolder, name)
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
// Uses the BitWindow binary directory config loaded from chains_config.json.
func DefaultBitwindowDir() string {
	return config.BitWindowDirs.RootDir()
}

// AllDefaults returns configs for every known binary, loaded from the
// embedded chains_config.json. This is the single source of truth.
func AllDefaults() []BinaryConfig {
	configs, err := parseConfigJSON(embeddedConfig)
	if err != nil {
		panic(fmt.Sprintf("failed to parse embedded chains_config.json: %v", err))
	}
	return configs
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
