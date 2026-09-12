package orchestrator

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

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
