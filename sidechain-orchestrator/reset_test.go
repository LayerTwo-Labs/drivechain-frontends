package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"sort"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// newResetTestOrchestrator creates an Orchestrator with a temp datadir and
// a minimal set of configs. The BitwindowDir is set to the temp datadir so
// BinDir resolves inside it.
func newResetTestOrchestrator(t *testing.T) *Orchestrator {
	t.Helper()
	dir := t.TempDir()
	return New(dir, "signet", dir, AllDefaults(), testLogger(t))
}

// seedFile creates a file (with parent dirs) and writes some bytes so
// os.Stat reports a non-zero size.
func seedFile(t *testing.T, path string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte("data"), 0o644))
}

func allCategories() []string {
	return []string{catData, catSoftware, catLogs, catSettings, catWallet}
}

// ---------- GatherFilesToDelete --------------------------------------------

func TestGather_NoSpecs(t *testing.T) {
	o := newResetTestOrchestrator(t)
	files, err := o.GatherFilesToDelete(nil)
	require.NoError(t, err)
	assert.Empty(t, files)
}

func TestGather_OnlyTargetsRequestedBinary(t *testing.T) {
	o := newResetTestOrchestrator(t)

	// node_software lives in BinDir keyed by binary name. Seed bitcoind +
	// thunder; gather only thunder and assert bitcoind never shows up.
	binDir := BinDir(o.BitwindowDir)
	seedFile(t, filepath.Join(binDir, "bitcoind"))
	seedFile(t, filepath.Join(binDir, "thunder"))

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "thunder", Categories: []string{catSoftware}},
	})
	require.NoError(t, err)

	for _, f := range files {
		assert.NotEqual(t, "bitcoind", filepath.Base(f.Path),
			"gather for thunder must not return bitcoind's software")
	}
}

func TestGather_OnlyRequestedCategories(t *testing.T) {
	o := newResetTestOrchestrator(t)

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "bitcoind", Categories: []string{catData, catLogs}},
	})
	require.NoError(t, err)

	allowed := map[string]bool{catData: true, catLogs: true}
	for _, f := range files {
		assert.Truef(t, allowed[f.Category], "unexpected category %q for %q", f.Category, f.Path)
	}
}

func TestGather_StatsExistingFiles(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	seedFile(t, filepath.Join(binDir, "bitcoind"))

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "bitcoind", Categories: []string{catSoftware}},
	})
	require.NoError(t, err)

	var found bool
	for _, f := range files {
		if filepath.Base(f.Path) == "bitcoind" {
			found = true
			assert.False(t, f.IsDirectory)
			assert.Equal(t, int64(len("data")), f.SizeBytes)
			assert.Equal(t, catSoftware, f.Category)
			assert.Equal(t, "bitcoind", f.BinaryName)
		}
	}
	assert.True(t, found, "expected seeded bitcoind binary in gather result")
}

func TestGather_DeduplicatesByPath(t *testing.T) {
	o := newResetTestOrchestrator(t)

	files, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "bitcoind", Categories: allCategories()},
		{BinaryName: "bitwindowd", Categories: allCategories()},
	})
	require.NoError(t, err)

	seen := make(map[string]bool)
	for _, f := range files {
		assert.Falsef(t, seen[f.Path], "duplicate path %q in gather result", f.Path)
		seen[f.Path] = true
	}
}

func TestGather_NoSideEffects(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	testFile := filepath.Join(binDir, "bitcoind")
	seedFile(t, testFile)

	_, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "bitcoind", Categories: []string{catSoftware}},
	})
	require.NoError(t, err)

	_, statErr := os.Stat(testFile)
	assert.NoError(t, statErr, "gather must not delete files")
}

func TestGather_ResultsAreStable(t *testing.T) {
	o := newResetTestOrchestrator(t)

	specs := []GatherSpec{
		{BinaryName: "bitcoind", Categories: []string{catData, catSoftware, catLogs}},
		{BinaryName: "thunder", Categories: allCategories()},
	}

	files1, err := o.GatherFilesToDelete(specs)
	require.NoError(t, err)
	files2, err := o.GatherFilesToDelete(specs)
	require.NoError(t, err)

	sort.Slice(files1, func(i, j int) bool { return files1[i].Path < files1[j].Path })
	sort.Slice(files2, func(i, j int) bool { return files2[i].Path < files2[j].Path })

	require.Equal(t, len(files1), len(files2))
	for i := range files1 {
		assert.Equal(t, files1[i].Path, files2[i].Path)
		assert.Equal(t, files1[i].Category, files2[i].Category)
	}
}

func TestGather_UnknownBinarySkipped(t *testing.T) {
	o := newResetTestOrchestrator(t)
	files, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "not-a-real-binary", Categories: allCategories()},
	})
	require.NoError(t, err)
	assert.Empty(t, files)
}

// ---------- DeleteFiles ----------------------------------------------------

func TestDeleteFiles_DeletesSeededFiles(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	a := filepath.Join(binDir, "bitcoind")
	b := filepath.Join(binDir, "bip300301-enforcer")
	seedFile(t, a)
	seedFile(t, b)

	ch, err := o.DeleteFiles(context.Background(), []string{a, b})
	require.NoError(t, err)

	var events []DeleteEvent
	for evt := range ch {
		events = append(events, evt)
	}

	require.Len(t, events, 2)
	for _, evt := range events {
		assert.Empty(t, evt.Error, "path %q should have deleted cleanly", evt.Path)
	}
	for _, p := range []string{a, b} {
		_, statErr := os.Stat(p)
		assert.True(t, os.IsNotExist(statErr), "file %q should have been deleted", p)
	}
}

func TestDeleteFiles_EmitsOneEventPerPath(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	paths := []string{
		filepath.Join(binDir, "bitcoind"),
		filepath.Join(binDir, "thunder"),
		filepath.Join(binDir, "bip300301-enforcer"),
	}
	for _, p := range paths {
		seedFile(t, p)
	}

	ch, err := o.DeleteFiles(context.Background(), paths)
	require.NoError(t, err)

	seen := map[string]bool{}
	for evt := range ch {
		assert.NotEmpty(t, evt.Path)
		seen[evt.Path] = true
	}
	for _, p := range paths {
		assert.Truef(t, seen[p], "missing delete event for %q", p)
	}
}

func TestDeleteFiles_NonExistentPathSucceeds(t *testing.T) {
	o := newResetTestOrchestrator(t)

	ghost := filepath.Join(o.BitwindowDir, "does-not-exist")
	ch, err := o.DeleteFiles(context.Background(), []string{ghost})
	require.NoError(t, err)

	for evt := range ch {
		assert.Empty(t, evt.Error, "non-existent path should not be a failure")
	}
}

func TestDeleteFiles_Empty(t *testing.T) {
	o := newResetTestOrchestrator(t)
	ch, err := o.DeleteFiles(context.Background(), nil)
	require.NoError(t, err)

	var events []DeleteEvent
	for evt := range ch {
		events = append(events, evt)
	}
	assert.Empty(t, events)
}

func TestDeleteFiles_DeletesNestedDirectoryTree(t *testing.T) {
	o := newResetTestOrchestrator(t)

	binDir := BinDir(o.BitwindowDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	nested := filepath.Join(binDir, "bitcoind")
	deep := filepath.Join(nested, "Contents", "MacOS", "Resources", "en.lproj")
	require.NoError(t, os.MkdirAll(deep, 0o755))
	leaf := filepath.Join(deep, "InfoPlist.strings")
	require.NoError(t, os.WriteFile(leaf, []byte("leaf"), 0o644))

	ch, err := o.DeleteFiles(context.Background(), []string{nested})
	require.NoError(t, err)
	for evt := range ch {
		assert.Empty(t, evt.Error)
	}

	_, leafErr := os.Stat(leaf)
	assert.True(t, os.IsNotExist(leafErr), "deep leaf %s must be deleted", leaf)
	_, rootErr := os.Stat(nested)
	assert.True(t, os.IsNotExist(rootErr), "nested root %s must be deleted", nested)
}

// TestDeleteFiles_WalletPathNotHardDeleted is the core guarantee: a wallet
// path handed to DeleteFiles is moved to wallet_backups/ (when WalletSvc is
// wired) and is never os.RemoveAll'd into oblivion. Either the original still
// exists (no wallet service in this harness) or a wallet_backups/ sibling
// holds it — what must never happen is the keys vanishing entirely.
func TestDeleteFiles_WalletPathNotHardDeleted(t *testing.T) {
	o := newResetTestOrchestrator(t)

	// Seed a thunder wallet at the exact location GatherFilesToDelete reports.
	_, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "thunder", Categories: []string{catWallet}},
	})
	require.NoError(t, err)

	network := config.Network(o.Network)
	dc, ok := config.DirConfigByName("thunder")
	require.True(t, ok)
	walletPath := filepath.Join(dc.DatadirNetwork(network, ""), "wallet.mdb")
	seedFile(t, walletPath)

	// Re-gather now that it exists on disk.
	gathered, err := o.GatherFilesToDelete([]GatherSpec{
		{BinaryName: "thunder", Categories: []string{catWallet}},
	})
	require.NoError(t, err)
	var paths []string
	for _, f := range gathered {
		paths = append(paths, f.Path)
	}
	require.Contains(t, paths, walletPath)

	ch, err := o.DeleteFiles(context.Background(), paths)
	require.NoError(t, err)
	for evt := range ch {
		assert.Empty(t, evt.Error)
	}

	_, origErr := os.Stat(walletPath)
	backupExists := false
	if entries, e := os.ReadDir(filepath.Dir(walletPath)); e == nil {
		for _, ent := range entries {
			if ent.IsDir() && ent.Name() == "wallet_backups" {
				backupExists = true
			}
		}
	}
	assert.True(t, origErr == nil || backupExists,
		"wallet must be preserved in place or moved to wallet_backups/, never hard-deleted")
}

// TestIsWalletPath is the safety-critical classifier: it decides which paths
// get moved to wallet_backups/ vs. hard-deleted. It must catch every chain's
// wallet on both POSIX and Windows path shapes, and must not over-match obvious
// non-wallet data.
func TestIsWalletPath(t *testing.T) {
	empty := map[string]bool{}

	wallets := []string{
		"/home/u/.local/share/thunder/wallet.mdb",    // every L2 sidechain
		"/home/u/.drivechain/signet/wallet.dat",      // bitcoind legacy
		"/home/u/.bitcoin/signet/wallets",            // bitcoind wallets dir
		"/home/u/.bitcoin/signet/wallets/default",    // inside wallets dir
		"/home/u/bip300301_enforcer/wallet/bitcoin",  // enforcer wallet dir
		"/home/u/.local/share/bitwindow/wallet.json", // bitwindowd / frontend
		"/home/u/.local/share/bitwindow/wallet_encryption.json",
		`C:\Users\u\AppData\Roaming\bitwindow\wallet.json`,             // windows separators
		`C:\Users\u\AppData\Roaming\Drivechain\signet\wallets\default`, // windows wallets dir
		`C:\Users\u\AppData\Roaming\Thunder\wallet.mdb`,
	}
	for _, p := range wallets {
		assert.Truef(t, isWalletPath(p, empty), "%q must be classified as a wallet", p)
	}

	nonWallets := []string{
		"/home/u/.bitcoin/signet/blocks",
		"/home/u/.bitcoin/signet/chainstate",
		"/home/u/.local/share/thunder/data.mdb",
		"/home/u/.local/share/thunder/debug.log",
		"/home/u/.local/share/bitwindow/settings.json",
		"/some/walletish/notawallet.dat", // ".dat" but not a wallet file
		`C:\Users\u\AppData\Roaming\bitwindow\settings.json`,
	}
	for _, p := range nonWallets {
		assert.Falsef(t, isWalletPath(p, empty), "%q must NOT be classified as a wallet", p)
	}

	// An explicit set membership always wins, even for an unusual location.
	assert.True(t, isWalletPath("/weird/custom/keys", map[string]bool{"/weird/custom/keys": true}))
}

// ---------- BinaryWalletPaths ----------------------------------------------

// TestBinaryWalletPaths_BitcoindUsesNetworkAwareDatadir guards issue #1627.
// The wallet sweep must look for bitcoind wallets at `<datadir>/<network>/
// wallets/`, not the bare root.
func TestBinaryWalletPaths_BitcoindUsesNetworkAwareDatadir(t *testing.T) {
	o := newResetTestOrchestrator(t)

	override := t.TempDir()
	o.BitcoinConf = &config.BitcoinConfManager{
		Network:         config.Network("signet"),
		DetectedDataDir: override,
	}
	bitcoinNetworkDir := filepath.Join(override, "signet")
	walletsDir := filepath.Join(bitcoinNetworkDir, "wallets")
	require.NoError(t, os.MkdirAll(walletsDir, 0o755))

	paths := o.BinaryWalletPaths()

	found := false
	for _, p := range paths {
		if p == walletsDir {
			found = true
			break
		}
	}
	assert.True(t, found, "bitcoind signet wallets dir must be in BinaryWalletPaths; got: %v", paths)

	bareRootWallets := filepath.Join(override, "wallets")
	for _, p := range paths {
		assert.NotEqual(t, bareRootWallets, p, "must not point at bare-root <override>/wallets")
	}
}
