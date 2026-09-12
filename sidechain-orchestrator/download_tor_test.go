package orchestrator

import (
	"context"
	"crypto/sha256"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestPinnedTorArchive(t *testing.T) {
	payload := []byte("verified bundle")
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { _, _ = w.Write(payload) }))
	defer server.Close()
	dm, dir := newTestDownloadManager(t)
	target := DownloadTarget{Source: DownloadSourceDirect, BaseURL: server.URL + "/", FileName: "bundle.zip"}
	config := BinaryConfig{Name: "bitnames-tor", RequireHash: true, ArchiveHashes: map[string]ArchiveHash{currentPlatform(): {SHA256: fmt.Sprintf("%x", sha256.Sum256(payload)), Size: int64(len(payload))}}}
	send := func(DownloadProgress) bool { return true }
	_, err := dm.fetchArchive(context.Background(), config, target, dir, send)
	require.NoError(t, err)
	payload[0] ^= 1
	_, err = dm.fetchArchive(context.Background(), config, target, dir, send)
	require.ErrorContains(t, err, "hash mismatch")
	config.ArchiveHashes = nil
	_, err = dm.fetchArchive(context.Background(), config, target, dir, send)
	require.ErrorContains(t, err, "no trusted archive hash")
}

func TestTorBundleRequiresRuntimeAndPreservesTree(t *testing.T) {
	dm, dir := newTestDownloadManager(t)
	archive := filepath.Join(dir, "bundle.zip")
	exe, tor := "bitnames-tor", "tor"
	if runtime.GOOS == "windows" {
		exe += ".exe"
		tor += ".exe"
	}
	config := BinaryConfig{Name: "bitnames-tor", PreserveArchiveTree: true}
	target := DownloadTarget{ExtractName: "bitnames-tor", ExtractSubfolder: "bitnames-tor"}
	makeZipFile(t, archive, map[string][]byte{"bitnames-tor/" + exe: []byte("launcher")})
	_, err := dm.extractBinary(archive, config, target, dir, "signet")
	require.ErrorContains(t, err, "missing required executable")
	_, err = os.Stat(filepath.Join(BinDir(dir), exe))
	require.True(t, os.IsNotExist(err))
	makeZipFile(t, archive, map[string][]byte{"bitnames-tor/" + exe: []byte("launcher"), "bitnames-tor/tor/" + tor: []byte("runtime")})
	_, err = dm.extractBinary(archive, config, target, dir, "signet")
	require.NoError(t, err)
	content, err := os.ReadFile(filepath.Join(BinDir(dir), "tor", tor))
	require.NoError(t, err)
	require.Equal(t, "runtime", string(content))
}
