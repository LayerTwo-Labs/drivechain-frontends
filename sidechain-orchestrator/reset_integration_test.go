// Integration tests for reset path discovery. Targets the specific
// Windows bug: after booting bitcoind, enforcer, bitwindowd, the user's
// preview lists only 12 items (BitWindow flutter dir + one file under
// Drivechain/) and completely misses the binary data dirs.
//
// Strategy: redirect os.UserHomeDir() into t.TempDir() via HOME /
// USERPROFILE, then seed every file layout a real boot would produce.
// GatherFilesToDelete MUST enumerate every seeded path or the UI lies to
// the user about what a reset will touch.

package orchestrator

import (
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// redirectHome points os.UserHomeDir() at a temp directory so AppDir()
// resolves inside the test's sandbox. Returns the redirected home.
func redirectHome(t *testing.T) string {
	t.Helper()
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	return home
}

// appRoot returns the platform AppDir root under the redirected home,
// matching config.BinaryDirConfig.AppDir().
func appRoot(home string) string {
	switch runtime.GOOS {
	case "darwin":
		return filepath.Join(home, "Library", "Application Support")
	case "windows":
		return filepath.Join(home, "AppData", "Roaming")
	default:
		return filepath.Join(home, ".local", "share")
	}
}

// linuxHome returns the literal home dir for Bitcoin Core, which Dart
// and the Go port treat as special on Linux (no .local/share prefix).
func linuxHome(home string) string { return home }

// bitcoindRoot returns the Bitcoin Core datadir root under the
// redirected home, matching RootDirNetwork on non-mainnet.
func bitcoindRoot(home string) string {
	if runtime.GOOS == "linux" {
		return filepath.Join(linuxHome(home), ".drivechain")
	}
	return filepath.Join(appRoot(home), "Drivechain")
}

// bitwindowRoot returns the Flutter bitwindow app root.
func bitwindowRoot(home string) string {
	switch runtime.GOOS {
	case "darwin":
		return filepath.Join(appRoot(home), "bitwindow")
	case "windows":
		// Matches chains_config.json "windows": "10520LayertwoLabs/BitWindow"
		return filepath.Join(appRoot(home), "10520LayertwoLabs", "BitWindow")
	default:
		return filepath.Join(appRoot(home), "bitwindow")
	}
}

func enforcerRoot(home string) string {
	return filepath.Join(appRoot(home), "bip300301_enforcer")
}

// writeStub creates a file with parent directories. Used to seed a
// file-system layout matching what the real binaries produce at boot.
func writeStub(t *testing.T, path string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte("stub"), 0o644))
}

func writeDir(t *testing.T, path string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(path, 0o755))
}

// l1Specs requests every category for the L1 stack (bitcoind + enforcer +
// bitwindowd) — the set the global reset page would build.
func l1Specs() []GatherSpec {
	return []GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: allCategories()},
		{Binary: ResetBinaryEnforcer, Categories: allCategories()},
		{Binary: ResetBinaryBitwindowd, Categories: allCategories()},
	}
}

// bootedLayout seeds a realistic post-boot tree for bitcoind + enforcer
// + bitwindowd on the given network. Returns the absolute paths that
// GatherFilesToDelete MUST enumerate.
func bootedLayout(t *testing.T, home, network string) []string {
	t.Helper()

	var want []string
	add := func(paths ...string) { want = append(want, paths...) }

	bcRoot := bitcoindRoot(home)
	bcNet := filepath.Join(bcRoot, network)
	bwRoot := bitwindowRoot(home)
	bwNet := filepath.Join(bwRoot, network)
	enfRoot := enforcerRoot(home)

	// --- bitcoind: simulate it ran on `network`, indexing blocks. -----------
	for _, f := range []string{
		".lock", "anchors.dat", "banlist.json", "bitcoind.pid",
		"debug.log", "fee_estimates.dat", "mempool.dat", "peers.dat",
		"settings.json",
	} {
		writeStub(t, filepath.Join(bcNet, f))
	}
	writeDir(t, filepath.Join(bcNet, "blocks"))
	writeStub(t, filepath.Join(bcNet, "blocks", "blk00000.dat"))
	writeDir(t, filepath.Join(bcNet, "chainstate"))
	writeStub(t, filepath.Join(bcNet, "chainstate", "CURRENT"))
	writeDir(t, filepath.Join(bcNet, "indexes"))
	writeDir(t, filepath.Join(bcNet, "wallets"))
	writeStub(t, filepath.Join(bcNet, "wallets", "wallet.dat"))

	// Settings: bitwindow-bitcoin.conf lives at Drivechain/ root.
	writeStub(t, filepath.Join(bcRoot, "bitwindow-bitcoin.conf"))

	add(
		filepath.Join(bcNet, ".lock"),
		filepath.Join(bcNet, "anchors.dat"),
		filepath.Join(bcNet, "banlist.json"),
		filepath.Join(bcNet, "bitcoind.pid"),
		filepath.Join(bcNet, "blocks"),
		filepath.Join(bcNet, "chainstate"),
		filepath.Join(bcNet, "debug.log"),
		filepath.Join(bcNet, "fee_estimates.dat"),
		filepath.Join(bcNet, "indexes"),
		filepath.Join(bcNet, "mempool.dat"),
		filepath.Join(bcNet, "peers.dat"),
		filepath.Join(bcNet, "settings.json"),
		filepath.Join(bcNet, "wallets"),
		filepath.Join(bcRoot, "bitwindow-bitcoin.conf"),
	)

	// --- enforcer: simulate it ran on `network`. -----------------------------
	writeDir(t, filepath.Join(enfRoot, "validator"))
	writeStub(t, filepath.Join(enfRoot, "bitwindow-enforcer.conf"))
	// networkName: collect logic replaces mainnet/forknet with "bitcoin".
	networkName := network
	if network == "mainnet" || network == "forknet" {
		networkName = "bitcoin"
	}
	writeDir(t, filepath.Join(enfRoot, networkName))
	writeDir(t, filepath.Join(enfRoot, "wallet", networkName))
	// GetLogPaths for enforcer checks <rootdir> (no network subdir) so
	// that is where we seed the logs we expect the preview to find.
	writeStub(t, filepath.Join(enfRoot, "bip300301_enforcer.log"))
	writeDir(t, filepath.Join(enfRoot, "logs"))

	add(
		filepath.Join(enfRoot, "validator"),
		filepath.Join(enfRoot, "bitwindow-enforcer.conf"),
		filepath.Join(enfRoot, networkName),
		filepath.Join(enfRoot, "wallet", networkName),
		filepath.Join(enfRoot, "bip300301_enforcer.log"),
		filepath.Join(enfRoot, "logs"),
	)

	// --- bitwindowd: flutter app data + signet/ subdir. ----------------------
	writeStub(t, filepath.Join(bwNet, "bitwindow.db"))
	writeStub(t, filepath.Join(bwNet, "server.log"))
	writeStub(t, filepath.Join(bwNet, "wallet.json"))
	writeStub(t, filepath.Join(bwNet, "wallet_encryption.json"))
	writeDir(t, filepath.Join(bwNet, "bitdrive"))

	for _, f := range []string{
		"bitwindow-bitcoin.conf", "debug.log", "settings.json",
		"wallet.json", "wallet_encryption.json",
	} {
		writeStub(t, filepath.Join(bwRoot, f))
	}
	writeDir(t, filepath.Join(bwRoot, "assets"))
	writeDir(t, filepath.Join(bwRoot, "downloads"))
	writeDir(t, filepath.Join(bwRoot, "pids"))

	add(
		filepath.Join(bwNet, "bitwindow.db"),
		filepath.Join(bwNet, "server.log"),
		filepath.Join(bwNet, "wallet.json"),
		filepath.Join(bwNet, "wallet_encryption.json"),
		filepath.Join(bwNet, "bitdrive"),
		filepath.Join(bwRoot, "assets"),
		filepath.Join(bwRoot, "bitwindow-bitcoin.conf"),
		filepath.Join(bwRoot, "debug.log"),
		filepath.Join(bwRoot, "downloads"),
		filepath.Join(bwRoot, "pids"),
		filepath.Join(bwRoot, "settings.json"),
		filepath.Join(bwRoot, "wallet.json"),
		filepath.Join(bwRoot, "wallet_encryption.json"),
	)

	return want
}

// TestGather_EnumeratesBootedBitcoindEnforcerBitwindow is the direct
// reproducer for the user's "only 12 items" screenshot. After seeding a
// realistic post-boot layout, the gather MUST surface every blockchain_data /
// wallet / log / settings file the binaries created.
func TestGather_EnumeratesBootedBitcoindEnforcerBitwindow(t *testing.T) {
	home := redirectHome(t)
	bitwindowDir := bitwindowRoot(home)
	require.NoError(t, os.MkdirAll(bitwindowDir, 0o755))

	network := "signet"
	expected := bootedLayout(t, home, network)

	dataDir := t.TempDir()
	o := New(dataDir, network, bitwindowDir, AllDefaults(), testLogger(t))

	files, err := o.GatherFilesToDelete(l1Specs())
	require.NoError(t, err)

	got := make(map[string]struct{}, len(files))
	for _, f := range files {
		got[filepath.Clean(f.Path)] = struct{}{}
	}

	var missing []string
	for _, p := range expected {
		if _, ok := got[filepath.Clean(p)]; !ok {
			missing = append(missing, p)
		}
	}
	sort.Strings(missing)

	if len(missing) > 0 {
		t.Logf("gather returned %d paths; expected at least %d", len(files), len(expected))
		for _, f := range files {
			t.Logf("  %s [%v]", f.Path, f.Category)
		}
		t.Fatalf("gather is missing %d booted paths:\n  %s",
			len(missing), strings.Join(missing, "\n  "))
	}
}

// TestGather_FindsBitcoindBlockchainData boots the exact scenario from the
// user's "12 items" screenshot: bitcoind signet subdir full of block data.
func TestGather_FindsBitcoindBlockchainData(t *testing.T) {
	home := redirectHome(t)
	bitwindowDir := bitwindowRoot(home)
	require.NoError(t, os.MkdirAll(bitwindowDir, 0o755))

	network := "signet"
	bcRoot := bitcoindRoot(home)
	bcNet := filepath.Join(bcRoot, network)

	writeDir(t, filepath.Join(bcNet, "blocks"))
	writeStub(t, filepath.Join(bcNet, "blocks", "blk00000.dat"))
	writeDir(t, filepath.Join(bcNet, "chainstate"))
	writeStub(t, filepath.Join(bcNet, "chainstate", "CURRENT"))
	writeStub(t, filepath.Join(bcNet, "debug.log"))

	o := New(t.TempDir(), network, bitwindowDir, AllDefaults(), testLogger(t))

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData, catLogs}},
	})
	require.NoError(t, err)

	mustFind := []string{
		filepath.Join(bcNet, "blocks"),
		filepath.Join(bcNet, "chainstate"),
		filepath.Join(bcNet, "debug.log"),
	}

	got := map[string]struct{}{}
	for _, f := range files {
		got[filepath.Clean(f.Path)] = struct{}{}
	}

	var missing []string
	for _, p := range mustFind {
		if _, ok := got[filepath.Clean(p)]; !ok {
			missing = append(missing, p)
		}
	}
	if len(missing) > 0 {
		for _, f := range files {
			t.Logf("  %s [%v]", f.Path, f.Category)
		}
		t.Fatalf("gather failed to enumerate bitcoind blockchain data:\n  %s",
			strings.Join(missing, "\n  "))
	}
}

// TestGather_PerSidechainScoping confirms that gathering a single sidechain
// (thunder) returns its data and nothing from another sidechain.
func TestGather_PerSidechainScoping(t *testing.T) {
	home := redirectHome(t)
	bitwindowDir := bitwindowRoot(home)
	require.NoError(t, os.MkdirAll(bitwindowDir, 0o755))

	thunder := config.ThunderDirs
	thunderRoot := thunder.RootDir()
	writeStub(t, filepath.Join(thunderRoot, "data.mdb"))
	writeStub(t, filepath.Join(thunderRoot, "lock.mdb"))
	writeStub(t, filepath.Join(thunderRoot, "wallet.mdb"))
	writeDir(t, filepath.Join(thunderRoot, "logs"))

	o := New(t.TempDir(), "signet", bitwindowDir, AllDefaults(), testLogger(t))

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{Binary: ResetBinaryThunder, Categories: allCategories()},
	})
	require.NoError(t, err)

	thunderSeen := false
	for _, f := range files {
		if strings.Contains(f.Path, thunderRoot) {
			thunderSeen = true
		}
		assert.NotContains(t, f.Path, "bitnames",
			"gathering thunder must not surface another sidechain's paths")
	}
	assert.True(t, thunderSeen, "gathering thunder must enumerate its data dir")
}
