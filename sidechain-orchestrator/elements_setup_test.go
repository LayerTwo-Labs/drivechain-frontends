package orchestrator

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func TestElementsNativeDownloadExtraction(t *testing.T) {
	binary := os.Getenv("ELEMENTS_ALPHA_TEST_BINARY")
	if binary == "" {
		t.Skip("set ELEMENTS_ALPHA_TEST_BINARY to qualify real extraction")
	}
	dm, dir := newTestDownloadManager(t)
	payload, err := os.ReadFile(binary)
	require.NoError(t, err)
	archivePath := filepath.Join(dir, "alpha.zip")
	makeZipFile(t, archivePath, map[string][]byte{"liquid-signet": payload})
	archive, err := os.ReadFile(archivePath)
	require.NoError(t, err)
	archiveHash := sha256.Sum256(archive)
	binaryHash := sha256.Sum256(payload)
	cfg := BinaryConfig{Name: "liquid-signet", BinaryName: "liquid-signet", ArtifactPins: map[string]ArtifactPin{
		currentPlatform(): {ArchiveSHA256: hex.EncodeToString(archiveHash[:]), ExecutableSHA256: hex.EncodeToString(binaryHash[:])},
	}}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(archive) }))
	defer server.Close()
	target := DownloadTarget{Source: DownloadSourceDirect, BaseURL: server.URL + "/", FileName: "alpha.zip", ExtractName: "liquid-signet", BinPath: filepath.Join(BinDir(dir), "liquid-signet")}
	claims, busy := dm.claim([]DownloadTarget{target})
	require.Empty(t, busy)
	require.NoError(t, dm.install(context.Background(), cfg, "ecash", claims, func(DownloadProgress) bool { return true }))
	require.NoError(t, verifyElementsArtifact(cfg, target.BinPath, false))
	output, err := exec.Command(target.BinPath, "-version").CombinedOutput()
	require.NoError(t, err, string(output))
	require.Contains(t, string(output), "Elements")
}

func TestElementsArtifactIntegrity(t *testing.T) {
	payload := []byte("synthetic artifact, not executable")
	sum := sha256.Sum256(payload)
	hash := hex.EncodeToString(sum[:])
	cfg := BinaryConfig{Name: "liquid-signet", ArtifactPins: map[string]ArtifactPin{
		currentPlatform(): {ArchiveSHA256: hash, ExecutableSHA256: hash},
	}}
	path := filepath.Join(t.TempDir(), "artifact")
	require.NoError(t, os.WriteFile(path, payload, 0600))
	for _, archive := range []bool{false, true} {
		require.NoError(t, verifyElementsArtifact(cfg, path, archive))
	}
	link := path + ".link"
	require.NoError(t, os.Symlink(path, link))
	require.ErrorContains(t, verifyElementsArtifact(cfg, link, false), "regular file")
	require.NoError(t, os.WriteFile(path, []byte("changed"), 0600))
	require.ErrorContains(t, verifyElementsArtifact(cfg, path, false), "checksum mismatch")
	cfg.ArtifactPins = nil
	require.ErrorContains(t, verifyElementsArtifact(cfg, path, false), "no valid artifact pin")
}

func TestElementsDownloadVerifiesBeforeExtraction(t *testing.T) {
	payload := []byte("synthetic archive")
	sum := sha256.Sum256(payload)
	cfg := BinaryConfig{Name: "liquid-signet", ArtifactPins: map[string]ArtifactPin{
		currentPlatform(): {ArchiveSHA256: hex.EncodeToString(sum[:])},
	}}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(payload) }))
	defer server.Close()
	dm, dir := newTestDownloadManager(t)
	target := DownloadTarget{Source: DownloadSourceDirect, BaseURL: server.URL + "/", FileName: "artifact.zip"}
	_, err := dm.fetchArchive(context.Background(), cfg, target, dir, func(DownloadProgress) bool { return true })
	require.NoError(t, err)
	cfg.ArtifactPins[currentPlatform()] = ArtifactPin{ArchiveSHA256: hex.EncodeToString(make([]byte, 32))}
	_, err = dm.fetchArchive(context.Background(), cfg, target, dir, func(DownloadProgress) bool { return true })
	require.ErrorContains(t, err, "checksum mismatch")
	entries, err := os.ReadDir(BinDir(dir))
	require.NoError(t, err)
	require.Empty(t, entries)
}

func TestElementsNativeStartupConfiguration(t *testing.T) {
	o := newTestOrchestrator(t)
	old := config.ECashNetworkID()
	config.SetECashNetworkID("alphanet")
	t.Cleanup(func() { config.SetECashNetworkID(old) })
	o.Network = "ecash"
	parent, err := config.NewBitcoinConfManager(t.TempDir(), config.NetworkECash, testLogger(t))
	require.NoError(t, err)
	o.BitcoinConf = parent
	cfg, ok := BinaryConfigByName("liquid-signet")
	require.True(t, ok)
	var opts StartOpts
	require.NoError(t, o.prepareSidechainArgs(cfg, &opts))
	require.Len(t, opts.TargetArgs, 2)
	require.Contains(t, opts.TargetArgs[0], "-datadir=")
	require.Contains(t, opts.TargetArgs[1], "-conf=")
	require.NotContains(t, opts.TargetArgs, "--network=ecash")
	var restart StartOpts
	require.NoError(t, o.prepareSidechainArgs(cfg, &restart))
	require.Equal(t, opts.TargetArgs, restart.TargetArgs)
	custom := StartOpts{TargetArgs: []string{"-drivechainl1blocksync=1"}}
	require.ErrorContains(t, o.prepareSidechainArgs(cfg, &custom), "custom flags")
	require.IsType(t, &elementsAlphaHealthCheck{}, NewHealthChecker(cfg))
	o.BitcoinConf = nil
	require.ErrorContains(t, o.prepareSidechainArgs(cfg, &StartOpts{}), "parent configuration")
}

func TestElementsDownloadRejectsObsoleteAndCachedPackages(t *testing.T) {
	for _, cached := range []bool{false, true} {
		for _, force := range []bool{false, true} {
			dm, dir := newTestDownloadManager(t)
			cfg := BinaryConfig{Name: "liquid-signet", BinaryName: "liquid-signet"}
			if cached {
				require.NoError(t, os.MkdirAll(BinDir(dir), 0o700))
				require.NoError(t, os.WriteFile(filepath.Join(BinDir(dir), cfg.BinaryName), []byte("obsolete"), 0o700))
			}
			ch, err := dm.Download(context.Background(), cfg, "ecash", force)
			require.EqualError(t, err, elementsSetupUnavailable)
			require.Nil(t, ch)
		}
	}
}

func TestElementsStartAndRestartFailBeforeTouchingProcesses(t *testing.T) {
	o := newTestOrchestrator(t)
	ch, err := o.StartWithL1(context.Background(), "liquid-signet", StartOpts{})
	require.EqualError(t, err, elementsSetupUnavailable)
	require.Nil(t, ch)
	ch, err = o.RestartDaemon(context.Background(), "liquid-signet")
	require.EqualError(t, err, elementsSetupUnavailable)
	require.Nil(t, ch)
	pid, err := o.Start(context.Background(), "liquid-signet", nil, nil)
	require.EqualError(t, err, elementsSetupUnavailable)
	require.Zero(t, pid)
}

func TestElementsSetupGateDoesNotAffectOtherBinaries(t *testing.T) {
	for _, cfg := range AllDefaults() {
		if cfg.Name != "liquid-signet" {
			require.NoError(t, checkElementsSetup(cfg), cfg.Name)
		}
	}
}

func TestElementsMetadataDoesNotAdvertiseObsoleteDownloads(t *testing.T) {
	var expected any
	for _, path := range []string{"chains_config.json", "config/chains_config.json", "../sidechain_core/assets/chains_config.json"} {
		data, err := os.ReadFile(path)
		require.NoError(t, err)
		var document map[string]json.RawMessage
		require.NoError(t, json.Unmarshal(data, &document))
		var binaries map[string]json.RawMessage
		require.NoError(t, json.Unmarshal(document["binaries"], &binaries))
		var entry any
		require.NoError(t, json.Unmarshal(binaries["liquid-signet"], &entry))
		if expected == nil {
			expected = entry
		} else {
			require.Equal(t, expected, entry, path)
		}
	}
	cfg, ok := BinaryConfigByName("liquid-signet")
	require.True(t, ok)
	require.Equal(t, "Elements Alpha", cfg.DisplayName)
	for _, value := range cfg.DownloadURLs {
		require.Empty(t, value)
	}
	for _, value := range cfg.Files {
		require.Empty(t, value)
	}
}
