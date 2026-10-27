package orchestrator

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func productionCatalog(t *testing.T) {
	t.Helper()
	oldID := config.ECashNetworkID()
	oldHeight := config.PublishedForkHeight(config.NetworkECash)
	config.SetECashNetworkID("mainnet")
	config.SetForkHeight(config.NetworkECash, 973728)
	t.Cleanup(func() { config.SetECashNetworkID(oldID); config.SetForkHeight(config.NetworkECash, oldHeight) })
}
func testNativeSpec() *NativeWalletSpec {
	h := strings.Repeat("1", 64)
	return &NativeWalletSpec{UI: "blue-current", Ready: true, Version: "test-release", Binary: map[string]string{currentOS(): "wallet/bin/wallet"}, Daemon: map[string]string{currentOS(): "node/bin/elementsd"}, CLI: map[string]string{currentOS(): "node/bin/elements-cli"}, Files: map[string]string{currentPlatform(): "bundle.zip"}, DownloadURLs: map[string]string{"default": "https://example.invalid/"}, ArtifactPins: map[string]ArtifactPin{currentPlatform(): {ArchiveSHA256: h, ExecutableSHA256: h}}, DaemonSHA256: map[string]string{currentPlatform(): h}, CLISHA256: map[string]string{currentPlatform(): h}, Identity: ElementsWalletIdentity{Name: "Elements", Target: "btc-ecx-mainnet", Ready: true, Genesis: strings.Repeat("2", 64), Asset: strings.Repeat("3", 64), ParentGenesis: bitcoinGenesis, ParentForkHeight: 973728, ChainDirectory: "elements"}}
}
func TestNativeWalletReleaseGate(t *testing.T) {
	productionCatalog(t)
	cfg := BinaryConfig{Name: "liquid-signet", NativeWallet: testNativeSpec()}
	require.NoError(t, validateNativeWallet(cfg, "ecash"))
	cfg.NativeWallet.UI = "elements-qt"
	require.ErrorContains(t, validateNativeWallet(cfg, "ecash"), "Blue Current")
	cfg.NativeWallet.UI = "blue-current"
	manager, _ := newTestDownloadManager(t)
	target := manager.ResolveTarget(cfg, "ecash", DownloadOptions{})
	require.Equal(t, "bundle.zip", target.FileName)
	require.Contains(t, target.BinPath, "native-wallet")
	cfg.NativeWallet.Ready = false
	dm, _ := newTestDownloadManager(t)
	_, err := dm.Download(context.Background(), cfg, "ecash", false)
	require.ErrorContains(t, err, "973,728")
	cfg.NativeWallet.Ready = true
	cfg.NativeWallet.Identity.Genesis = "a7754ce0debc40baddbd8c47e79d19209685f22c63edaaf8b69cf54116374d7f"
	require.ErrorContains(t, validateNativeWallet(cfg, "ecash"), "distinct production")
	cfg.NativeWallet.Identity.Genesis = strings.Repeat("2", 64)
	cfg.NativeWallet.Identity.ParentForkHeight = 973729
	require.ErrorContains(t, validateNativeWallet(cfg, "ecash"), "973,728")
	cfg.NativeWallet.Identity.ParentForkHeight = 973728
	cfg.NativeWallet.NodeArgs = []string{"-rpcpassword=secret"}
	require.ErrorContains(t, validateNativeWallet(cfg, "ecash"), "setup-owned")
	config.SetECashNetworkID("alphanet")
	require.False(t, nativeWalletSelected(cfg, "ecash"))
	require.NoError(t, validateNativeWallet(cfg, "ecash"))
}
func TestNativeWalletCatalogSurvivesExistingConfig(t *testing.T) {
	merged, err := mergeWithEmbedded([]byte(`{"binaries":{"liquid-signet":{"name":"My Elements","port":29555}}}`))
	require.NoError(t, err)
	configs, err := parseConfigJSON(merged)
	require.NoError(t, err)
	for _, cfg := range configs {
		if cfg.Name == "liquid-signet" {
			require.Equal(t, "My Elements", cfg.DisplayName)
			require.Equal(t, 29555, cfg.Port)
			require.NotNil(t, cfg.NativeWallet)
			require.Equal(t, "blue-current", cfg.NativeWallet.UI)
			require.False(t, cfg.NativeWallet.Ready)
			require.Equal(t, 973728, cfg.NativeWallet.Identity.ParentForkHeight)
			return
		}
	}
	t.Fatal("Elements missing")
}
func TestNativeBundleDownloadAndCacheChecks(t *testing.T) {
	productionCatalog(t)
	dm, dir := newTestDownloadManager(t)
	w := testNativeSpec()
	files := map[string][]byte{}
	for _, entry := range []string{w.Binary[currentOS()], w.Daemon[currentOS()], w.CLI[currentOS()]} {
		files[platformExecutable(entry)] = []byte(entry)
	}
	files["wallet/share/elements-blue-current/assets/font.ttf"] = []byte("font")
	files["node/lib/libelements_haskell.dylib"] = []byte("library")
	var archive bytes.Buffer
	z := zip.NewWriter(&archive)
	for name, data := range files {
		h := &zip.FileHeader{Name: name, Method: zip.Deflate}
		h.SetMode(0o755)
		f, err := z.CreateHeader(h)
		require.NoError(t, err)
		_, err = f.Write(data)
		require.NoError(t, err)
	}
	require.NoError(t, z.Close())
	hash := func(data []byte) string { s := sha256.Sum256(data); return hex.EncodeToString(s[:]) }
	w.ArtifactPins[currentPlatform()] = ArtifactPin{ArchiveSHA256: hash(archive.Bytes()), ExecutableSHA256: hash(files[platformExecutable(w.Binary[currentOS()])])}
	w.DaemonSHA256[currentPlatform()] = hash(files[platformExecutable(w.Daemon[currentOS()])])
	w.CLISHA256[currentPlatform()] = hash(files[platformExecutable(w.CLI[currentOS()])])
	// HTTPS remains required, including tests.
	server := httptest.NewTLSServer(http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) { _, _ = rw.Write(archive.Bytes()) }))
	defer server.Close()
	dm.httpClient = server.Client()
	w.DownloadURLs["default"] = server.URL + "/"
	cfg := BinaryConfig{Name: "liquid-signet", NativeWallet: w}
	progress, err := dm.Download(context.Background(), cfg, "ecash", false)
	require.NoError(t, err)
	done := false
	for p := range progress {
		require.NoError(t, p.Error)
		done = done || p.Done
	}
	require.True(t, done)
	require.NoError(t, verifyNativeBundle(dir, cfg))
	installed := installedBinaryPath(dir, w.component(cfg.Name))
	require.FileExists(t, installed)
	require.FileExists(t, filepath.Join(BinDir(dir), w.component(cfg.Name).InstallSubdir, "wallet/share/elements-blue-current/assets/font.ttf"))
	node := nativeNodeConfig(cfg, "ecash")
	require.NoError(t, os.WriteFile(nativeCLIPath(dir, node), []byte("tampered"), 0o755))
	progress, err = dm.Download(context.Background(), cfg, "ecash", false)
	require.ErrorContains(t, err, "checksum mismatch")
	require.Nil(t, progress)
	// A failed forced update cannot replace the previous bundle.
	w.CLISHA256[currentPlatform()] = strings.Repeat("f", 64)
	progress, err = dm.Download(context.Background(), cfg, "ecash", true)
	require.NoError(t, err)
	failed := false
	for p := range progress {
		if p.Error != nil {
			failed = true
			require.False(t, p.Done)
		}
	}
	require.True(t, failed)
	old, err := os.ReadFile(nativeCLIPath(dir, node))
	require.NoError(t, err)
	require.Equal(t, "tampered", string(old))
}
func TestNativeWalletProfile(t *testing.T) {
	productionCatalog(t)
	o := newTestOrchestrator(t)
	o.Network = "ecash"
	cfg := BinaryConfig{Name: "liquid-signet", Port: 29443, NativeWallet: testNativeSpec()}
	folder := filepath.Join(o.DataDir, "data with spaces")
	path, err := o.writeNativeWalletProfile(cfg, cfg.NativeWallet.component(cfg.Name), folder)
	require.NoError(t, err)
	raw, err := os.ReadFile(path)
	require.NoError(t, err)
	var profile map[string]any
	require.NoError(t, json.Unmarshal(raw, &profile))
	require.Equal(t, false, profile["startNode"])
	require.Equal(t, folder, profile["datadir"])
	node := nativeNodeConfig(cfg, "ecash")
	require.Equal(t, nativeCLIPath(o.DataDir, node), profile["cli"])
	require.NotContains(t, string(raw), "password")
	// Repeat setup replaces its own profile rather than accumulating files.
	again, err := o.writeNativeWalletProfile(cfg, cfg.NativeWallet.component(cfg.Name), folder)
	require.NoError(t, err)
	require.Equal(t, path, again)
}
func TestNativeTarTreeAndTraversal(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	for _, bad := range []bool{false, true} {
		path := filepath.Join(dir, "bundle.tar.gz")
		f, err := os.Create(path)
		require.NoError(t, err)
		gz := gzip.NewWriter(f)
		tw := tar.NewWriter(gz)
		name := "release/lib/runtime.so"
		if bad {
			name = "release/../../escape"
		}
		require.NoError(t, tw.WriteHeader(&tar.Header{Name: name, Mode: 0o755, Size: 3, Typeflag: tar.TypeReg}))
		_, err = tw.Write([]byte("lib"))
		require.NoError(t, err)
		require.NoError(t, tw.Close())
		require.NoError(t, gz.Close())
		require.NoError(t, f.Close())
		_, err = dm.extractTarPreservingTree(path, filepath.Join(dir, "out"), "release")
		if bad {
			require.Error(t, err)
		} else {
			require.NoError(t, err)
			require.FileExists(t, filepath.Join(dir, "out/lib/runtime.so"))
		}
	}
}
