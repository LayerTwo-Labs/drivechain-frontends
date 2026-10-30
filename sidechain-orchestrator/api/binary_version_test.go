package api

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func TestGetBinaryVersion_MissingBinaryReadsNotInstalled(t *testing.T) {
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "versiontest",
		BinaryName:     "versiontest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "http://example.invalid/"},
		Files:          map[string]string{currentPlatform(): "versiontest.zip"},
	})
	client, stop := startTestOrchService(t, orch)
	defer stop()

	resp, err := client.GetBinaryVersion(context.Background(), &pb.GetBinaryVersionRequest{Name: "versiontest"})
	require.NoError(t, err)
	require.Equal(t, "Not installed", resp.Version)
	require.NotEmpty(t, resp.BinaryPath)
}

func TestGetBinaryVersion_UnknownBinaryKeepsTheError(t *testing.T) {
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{Name: "versiontest", BinaryName: "versiontest"})
	client, stop := startTestOrchService(t, orch)
	defer stop()

	resp, err := client.GetBinaryVersion(context.Background(), &pb.GetBinaryVersionRequest{Name: "does-not-exist"})
	require.NoError(t, err)
	require.Contains(t, resp.Version, "Error: ")
}
