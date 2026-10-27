package config

import (
	"crypto/sha256"
	"encoding/hex"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func home() string {
	return UserHomeDir()
}

// Tests verify Go paths match Dart binaries.dart paths exactly.
// Run on each platform to verify platform-specific paths.

func TestBitcoinCoreSignetPath(t *testing.T) {
	p := BitcoinCoreDirs.RootDirNetwork(NetworkSignet)
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "Ecash")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "Ecash")
	default: // linux
		want = filepath.Join(home(), ".ecash")
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

func TestBitcoinCoreECashPath(t *testing.T) {
	p := BitcoinCoreDirs.RootDirNetwork(NetworkECash)
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "Ecash")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "Ecash")
	default:
		want = filepath.Join(home(), ".ecash")
	}
	if p != want {
		t.Errorf("BitcoinCore eCash path = %q, want %q", p, want)
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

// The truthcoin node writes truthcoin_dc, not truthcoin, so every path the
// app reads has to name the same folder.
func TestTruthcoinPath(t *testing.T) {
	p := TruthcoinDirs.RootDir()
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "truthcoin_dc")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "truthcoin_dc")
	default:
		want = filepath.Join(home(), ".local", "share", "truthcoin_dc")
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

// FreeBank is a Core fork, so its datadir is the one freebankd picks for itself,
// with no network subdir on eCash. Its .cookie is read from there.
func TestFreebankPath(t *testing.T) {
	p := FreebankDirs.DatadirNetwork(NetworkECash, "")
	var want string
	switch runtime.GOOS {
	case "darwin":
		want = filepath.Join(home(), "Library", "Application Support", "FreeBank")
	case "windows":
		want = filepath.Join(home(), "AppData", "Roaming", "FreeBank")
	default:
		want = filepath.Join(home(), ".freebank")
	}
	if p != want {
		t.Errorf("FreeBank eCash datadir = %q, want %q", p, want)
	}
}

func TestEnforcerChainDirObeysTheEnforcerDataDir(t *testing.T) {
	for _, tc := range []struct {
		network Network
		ecashID string
		want    string
	}{
		{NetworkMainnet, "", filepath.Join("bitcoin", "mainnet")},
		{NetworkECash, "alphanet", filepath.Join("ecash-alphanet", "mainnet")},
		{NetworkECash, "betanet", filepath.Join("ecash-betanet", "mainnet")},
		{NetworkECash, "ecash", filepath.Join("ecash", "mainnet")},
		{NetworkSignet, "", filepath.Join("bitcoin", "signet_13182df0")},
		{NetworkRegtest, "", filepath.Join("bitcoin", "regtest")},
		{NetworkTestnet, "", filepath.Join("bitcoin", "testnet3")},
	} {
		got, err := EnforcerChainDir(tc.network, tc.ecashID)
		require.NoError(t, err, tc.network)
		require.Equal(t, tc.want, got, "%s %s", tc.network, tc.ecashID)
	}

	_, err := EnforcerChainDir(NetworkECash, "drynet4")
	require.ErrorContains(t, err, `"drynet4"`)
}

// The enforcer names a custom signet directory for the BIP325 magic of its
// challenge. The catalog magic must be the magic of the challenge BitWindow writes.
func TestEnforcerSignetDirIsTheMagicOfTheL2LChallenge(t *testing.T) {
	challenge, err := hex.DecodeString("00148835832e28c816b7acd8fdb19772ab2199603a56")
	require.NoError(t, err)
	require.Contains(t, (&BitcoinConfManager{Network: NetworkSignet}).GetDefaultConfig(), "signetchallenge="+hex.EncodeToString(challenge))

	first := sha256.Sum256(append([]byte{byte(len(challenge))}, challenge...))
	second := sha256.Sum256(first[:])
	require.Equal(t, "signet_"+hex.EncodeToString(second[:4]), enforcerChainName(NetworkSignet))
}

func useECashNetworkID(t *testing.T, id string) {
	t.Helper()
	previous := ECashNetworkID()
	SetECashNetworkID(id)
	t.Cleanup(func() { SetECashNetworkID(previous) })
}

func seedEnforcerDirs(t *testing.T, root string, names ...string) {
	t.Helper()
	for _, name := range names {
		require.NoError(t, os.MkdirAll(filepath.Join(root, name), 0o755))
	}
}

func TestEnforcerPathListsHoldTheForkAndTheLegacyLayout(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	useECashNetworkID(t, "betanet")
	root := EnforcerDirs.RootDir()
	require.True(t, strings.HasPrefix(root, home))

	chain := filepath.Join("ecash-betanet", "mainnet")
	signet := filepath.Join("bitcoin", "signet_13182df0")
	seedEnforcerDirs(t, root,
		filepath.Join(chain, "validator"), filepath.Join(chain, "wallet"), filepath.Join(chain, "logs"),
		filepath.Join(signet, "validator"),
		filepath.Join("validator", "bitcoin"), filepath.Join("wallet", "bitcoin"),
		filepath.Join("validator", "signet"), "signet", "logs",
	)
	require.NoError(t, os.WriteFile(filepath.Join(root, "bip300301_enforcer.log"), nil, 0o644))

	data := EnforcerDirs.GetBlockchainDataPaths(root, NetworkECash, zerolog.Nop())
	require.ElementsMatch(t, []string{
		filepath.Join(root, chain, "validator"),
		filepath.Join(root, "validator", "bitcoin"),
	}, data, "<root>/bitcoin holds every Bitcoin chain, so it is never eCash data")

	require.ElementsMatch(t, []string{
		filepath.Join(root, signet, "validator"),
		filepath.Join(root, "validator", "signet"),
		filepath.Join(root, "signet"),
	}, EnforcerDirs.GetBlockchainDataPaths(root, NetworkSignet, zerolog.Nop()))

	require.ElementsMatch(t, []string{
		filepath.Join(root, chain, "wallet"),
		filepath.Join(root, "wallet", "bitcoin"),
	}, EnforcerDirs.GetWalletPaths(root, NetworkECash, zerolog.Nop()))

	logs := EnforcerDirs.GetLogPaths(root, NetworkECash, zerolog.Nop())
	for _, want := range []string{
		filepath.Join(root, chain, "logs"),
		filepath.Join(root, "logs"),
		filepath.Join(root, "bip300301_enforcer.log"),
	} {
		require.Contains(t, logs, want)
	}
}

// A wipe takes the validator chain of both layouts and keeps the wallets.
func TestWipeEnforcerChainDataTakesBothLayouts(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	useECashNetworkID(t, "alphanet")
	root := EnforcerDirs.RootDir()

	chain := filepath.Join("ecash-alphanet", "mainnet")
	seedEnforcerDirs(t, root,
		filepath.Join(chain, "validator"), filepath.Join(chain, "wallet"),
		filepath.Join("validator", "bitcoin"), filepath.Join("wallet", "bitcoin"),
		filepath.Join("bitcoin", "signet_13182df0", "validator"),
	)

	require.NoError(t, WipeEnforcerChainDataSync(NetworkECash, zerolog.Nop()))

	require.NoDirExists(t, filepath.Join(root, chain, "validator"))
	require.NoDirExists(t, filepath.Join(root, "validator", "bitcoin"))
	require.DirExists(t, filepath.Join(root, chain, "wallet"))
	require.DirExists(t, filepath.Join(root, "wallet", "bitcoin"))
	require.DirExists(t, filepath.Join(root, "bitcoin", "signet_13182df0", "validator"))
}
