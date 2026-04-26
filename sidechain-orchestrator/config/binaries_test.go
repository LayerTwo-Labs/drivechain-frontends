package config

import (
	"os"
	"path/filepath"
	"runtime"
	"testing"
)

func home() string {
	h, _ := os.UserHomeDir()
	return h
}

// Tests verify Go paths match Dart binaries.dart paths exactly.
// Run on each platform to verify platform-specific paths.

func TestBitcoinCoreSignetPath(t *testing.T) {
	p := BitcoinCoreDirs.RootDirNetwork(NetworkSignet)
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "Drivechain")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "Drivechain")
	default: // linux
		want = filepath.Join(home(), ".drivechain")
	}
	if p != want {
		t.Errorf("BitcoinCore signet path = %q, want %q", p, want)
	}
}

func TestBitcoinCoreMainnetPath(t *testing.T) {
	p := BitcoinCoreDirs.RootDirNetwork(NetworkMainnet)
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "Bitcoin")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "Bitcoin")
	default: // linux
		// Dart L1503: BitcoinCore linux appdir is ~/ (home), so mainnet = ~/.bitcoin
		want = filepath.Join(home(), ".bitcoin")
	}
	if p != want {
		t.Errorf("BitcoinCore mainnet path = %q, want %q", p, want)
	}
}

func TestBitcoinCoreForknetPath(t *testing.T) {
	p := BitcoinCoreDirs.RootDirNetwork(NetworkForknet)
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "Drivechain")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "Drivechain")
	default:
		want = filepath.Join(home(), ".drivechain")
	}
	if p != want {
		t.Errorf("BitcoinCore forknet path = %q, want %q", p, want)
	}
}

func TestBitcoinCoreRootDirPanics(t *testing.T) {
	// BitcoinCore has different dirs per network (mainnet vs others), so RootDir() should panic
	defer func() {
		if r := recover(); r == nil {
			t.Error("BitcoinCore.RootDir() should panic because dirs differ per network")
		}
	}()
	BitcoinCoreDirs.RootDir()
}

func TestEnforcerPath(t *testing.T) {
	p := EnforcerDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "bip300301_enforcer")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "bip300301_enforcer")
	default:
		want = filepath.Join(home(), ".local", "share", "bip300301_enforcer")
	}
	if p != want {
		t.Errorf("Enforcer path = %q, want %q", p, want)
	}
}

func TestBitWindowPath(t *testing.T) {
	p := BitWindowDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "bitwindow")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "10520LayertwoLabs", "BitWindow")
	default:
		want = filepath.Join(home(), ".local", "share", "bitwindow")
	}
	if p != want {
		t.Errorf("BitWindow path = %q, want %q", p, want)
	}
}

func TestThunderPath(t *testing.T) {
	p := ThunderDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "Thunder")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "thunder")
	default:
		want = filepath.Join(home(), ".local", "share", "thunder")
	}
	if p != want {
		t.Errorf("Thunder path = %q, want %q", p, want)
	}
}

func TestBitNamesPath(t *testing.T) {
	p := BitNamesDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "plain_bitnames")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "plain_bitnames")
	default:
		want = filepath.Join(home(), ".local", "share", "plain_bitnames")
	}
	if p != want {
		t.Errorf("BitNames path = %q, want %q", p, want)
	}
}

func TestBitAssetsPath(t *testing.T) {
	p := BitAssetsDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "plain_bitassets")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "plain_bitassets")
	default:
		want = filepath.Join(home(), ".local", "share", "plain_bitassets")
	}
	if p != want {
		t.Errorf("BitAssets path = %q, want %q", p, want)
	}
}

func TestZSidePath(t *testing.T) {
	p := ZSideDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "thunder-orchard")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "thunder-orchard")
	default:
		want = filepath.Join(home(), ".local", "share", "thunder-orchard")
	}
	if p != want {
		t.Errorf("ZSide path = %q, want %q", p, want)
	}
}

func TestTruthcoinPath(t *testing.T) {
	p := TruthcoinDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "truthcoin")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "truthcoin")
	default:
		want = filepath.Join(home(), ".local", "share", "truthcoin")
	}
	if p != want {
		t.Errorf("Truthcoin path = %q, want %q", p, want)
	}
}

func TestPhotonPath(t *testing.T) {
	p := PhotonDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "photon")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "photon")
	default:
		want = filepath.Join(home(), ".local", "share", "photon")
	}
	if p != want {
		t.Errorf("Photon path = %q, want %q", p, want)
	}
}

func TestCoinShiftPath(t *testing.T) {
	p := CoinShiftDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "coinshift")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "coinshift")
	default:
		want = filepath.Join(home(), ".local", "share", "coinshift")
	}
	if p != want {
		t.Errorf("CoinShift path = %q, want %q", p, want)
	}
}

func TestBinaryDirConfigRootDirNetwork(t *testing.T) {
	// Test that non-mainnet networks use DataDir, mainnet uses DataDirMainnet
	bc := BitcoinCoreDirs
	signet := bc.RootDirNetwork(NetworkSignet)
	mainnet := bc.RootDirNetwork(NetworkMainnet)

	if signet == mainnet {
		t.Error("signet and mainnet should use different directories for BitcoinCore")
	}
}

func TestFlutterFrontendPath(t *testing.T) {
	// Thunder should have a flutter frontend dir
	p := ThunderDirs.FlutterFrontendPath()
	if p == "" {
		t.Error("Thunder should have a Flutter frontend path")
	}

	// Enforcer should NOT have a flutter frontend dir
	p = EnforcerDirs.FlutterFrontendPath()
	if p != "" {
		t.Errorf("Enforcer should have no Flutter frontend path, got %q", p)
	}
}
