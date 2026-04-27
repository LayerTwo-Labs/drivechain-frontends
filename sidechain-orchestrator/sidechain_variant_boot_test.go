package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSidechainVariant_DownloadAndBoot is the end-to-end check requested by
// users hitting the "test-sidechain downloads but bitwindow can't find it"
// regression: with the test-sidechains toggle on, the orchestrator must
//
//  1. download the alternative archive into `bin/test/<binary>/`,
//  2. lay it out so the resolver matches sidechain-orchestrator/config.go's
//     TestSidechainBinaryPath (Linux: bare binary; macOS: <Title>.app
//     bundle; Windows: <name>.exe), and
//  3. when ProcessManager.Start is called with the same SidechainVariant
//     resolver, actually launch the test variant — not the prod binary or
//     a stale path.
//
// Crucially this is a real-process test: we compile a small Go binary into
// the archive and verify the running process's exec path is the test
// variant on disk. A unit test asserting only resolved paths won't catch a
// regression where the resolver returns one path but Start exec's a
// different one.
func TestSidechainVariant_DownloadAndBoot(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("real-binary launch path differs on Windows; CI runs the Linux/macOS variants")
	}

	fakeBin := buildFakeSidechainBinary(t)

	binName := "thunder"
	archiveFiles := map[string][]byte{}
	switch runtime.GOOS {
	case "darwin":
		// Minimal Flutter-shaped .app: orchestrator's TestSidechainBinaryPath
		// scans for any `.app` and returns Contents/MacOS/<TitleCase>.
		archiveFiles["Thunder.app/Contents/Info.plist"] = []byte("<?xml version=\"1.0\"?>\n")
		archiveFiles["Thunder.app/Contents/MacOS/Thunder"] = fakeBin
	default:
		archiveFiles[binName] = fakeBin
	}
	archive := makeZipBytes(t, archiveFiles)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(archive)))
		_, _ = w.Write(archive)
	}))
	defer srv.Close()

	dataDir := t.TempDir()
	log := testLogger(t)

	dm := NewDownloadManager(dataDir, "", log)
	dm.httpClient = srv.Client()

	cfg := makeSidechainConfig(srv.URL + "/")
	resolver := func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{
			BinaryName: c.AltBinaryName,
			BaseURL:    c.AltBaseURL("default"),
			FileName:   c.AltFiles[currentOS()],
		}, true
	}
	dm.SidechainVariant = resolver
	require.True(t, dm.SidechainVariant != nil)

	// Step 1 + 2: test-variant download lands under bin/test/<binary>/.
	ch, err := dm.Download(context.Background(), cfg, "default", true)
	require.NoError(t, err)
	last := drainProgress(t, ch)
	require.True(t, last.Done, "download did not complete: %+v", last)

	scDir := TestSidechainDir(dataDir, "thunder")
	binPath := TestSidechainBinaryPath(dataDir, "thunder")
	t.Logf("test variant dir: %s", scDir)
	t.Logf("test variant binary: %s", binPath)

	// Step 3: resolved binary exists, is a regular file, has nonzero size,
	// and the on-disk layout matches the orchestrator's expectations.
	info, err := os.Stat(binPath)
	require.NoError(t, err, "binary not found at expected test-variant path %s", binPath)
	require.False(t, info.IsDir(), "%s should be a regular file", binPath)
	require.NotZero(t, info.Size(), "%s is empty", binPath)
	require.NoError(t, os.Chmod(binPath, 0o755), "chmod +x test variant")

	// And the prod path stays empty — flipping the toggle must not double-write.
	prodPath := filepath.Join(BinDir(dataDir), "thunder")
	if runtime.GOOS == "windows" {
		prodPath += ".exe"
	}
	if _, err := os.Stat(prodPath); err == nil {
		t.Fatalf("prod binary unexpectedly present at %s when only test variant was downloaded", prodPath)
	}

	// Step 4: ProcessManager.Start with the same SidechainVariant resolver
	// boots the test variant. We share the dataDir with the download
	// manager so resolvePaths walks the same tree.
	pm := NewProcessManager(dataDir, NewPidFileManager(dataDir, log), log)
	pm.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: c.AltBinaryName}, true
	}

	// Status (used to populate the BinaryStatusMsg.binary_path RPC field)
	// must report the same test-variant path so the frontend trusts the
	// orchestrator instead of duplicating filesystem-resolution logic.
	o := New(dataDir, "signet", t.TempDir(), []BinaryConfig{cfg}, log)
	o.process.SidechainVariant = func(c BinaryConfig) (sidechainVariantSpec, bool) {
		return sidechainVariantSpec{BinaryName: c.AltBinaryName}, true
	}
	st := o.Status(cfg.Name)
	require.True(t, st.Downloaded, "Status reports not-downloaded for %s", cfg.Name)
	assert.Equal(t, binPath, st.BinaryPath,
		"Status.BinaryPath %q must equal TestSidechainBinaryPath %q for variant-aware resolution", st.BinaryPath, binPath)

	pid, err := pm.Start(context.Background(), cfg, nil, nil)
	require.NoError(t, err)
	require.NotZero(t, pid)
	t.Cleanup(func() { _ = pm.Stop(context.Background(), cfg.Name, true) })

	// Cmd.Path is the binPath we passed to exec.Command — the kernel
	// successfully exec'd it, so this assertion catches a Start path that
	// resolves to the wrong binary even when resolvePaths is correct.
	proc := pm.Get(cfg.Name)
	require.NotNil(t, proc, "ManagedProcess for %s missing after Start", cfg.Name)
	t.Logf("process %d Cmd.Path: %s", pid, proc.Cmd.Path)
	assert.Equal(t, binPath, proc.Cmd.Path,
		"ProcessManager exec'd %q, expected the test-variant resolved path %q", proc.Cmd.Path, binPath)
	assert.True(t, strings.HasPrefix(proc.Cmd.Path, scDir),
		"process exe %q must live under test-variant dir %q", proc.Cmd.Path, scDir)

	// Wait briefly so the OS-level "is alive" check is meaningful, then
	// confirm we still see the process. A binary that's wrong arch or
	// missing libs would have already exited; sticking around for ~250ms
	// rules that out without slowing the suite.
	time.Sleep(250 * time.Millisecond)
	assert.True(t, pm.IsRunning(cfg.Name), "test variant %s exited immediately after start", cfg.Name)
}

// buildFakeSidechainBinary compiles a minimal sidechain-shaped binary for
// the current OS. The binary blocks on SIGTERM/SIGINT so the test can stat
// /proc + lsof while it's alive, then exits cleanly when killed.
func buildFakeSidechainBinary(t *testing.T) []byte {
	t.Helper()

	src := `package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	fmt.Fprintln(os.Stderr, "TEST_SIDECHAIN_VARIANT_BOOT")
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
	<-ch
}
`

	srcDir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(srcDir, "main.go"), []byte(src), 0o644))

	outName := "fake-sidechain"
	if runtime.GOOS == "windows" {
		outName += ".exe"
	}
	outPath := filepath.Join(srcDir, outName)

	cmd := exec.Command("go", "build", "-o", outPath, "main.go")
	cmd.Dir = srcDir
	cmd.Env = append(os.Environ(), "CGO_ENABLED=0")
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("go build fake sidechain binary: %v\n%s", err, out)
	}

	data, err := os.ReadFile(outPath)
	require.NoError(t, err)
	return data
}

