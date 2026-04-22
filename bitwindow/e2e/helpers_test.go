//go:build e2e

// End-to-end tests that drive `just run` as a subprocess and verify the
// daemons bitwindow manages (bitwindowd, orchestratord) come up, stay up,
// and shut down cleanly on every supported OS.
//
// Run with: go test -tags e2e -v -timeout 20m ./bitwindow/e2e/...
package e2e

import (
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"
)

const (
	bitwindowdName    = "bitwindowd"
	orchestratordName = "orchestratord"

	bitwindowdPort    = 30301
	orchestratordPort = 30400

	// Fixed BIP39 test mnemonic — matches the wallet we create in the
	// restart test. Deterministic derivation means the same wallet id
	// comes out on both boots iff the wallet state was persisted.
	testWalletMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	testWalletName     = "bitwindow-e2e-test"
)

// flutterAppProcessName returns the basename of the Flutter desktop app
// process as it appears in the OS process list — different from bitwindowd!
// Used to target the window-close test's graceful-quit trigger at the GUI.
func flutterAppProcessName() string {
	switch runtime.GOOS {
	case "darwin":
		return "BitWindow"
	case "linux":
		return "bitwindow"
	case "windows":
		return "BitWindows"
	default:
		return "BitWindow"
	}
}

// runHandle owns one `just run` subprocess plus captured output.
type runHandle struct {
	cmd      *exec.Cmd
	dataDir  string
	stdout   *lineBuffer
	stderr   *lineBuffer
	doneCh   chan error
	stopOnce sync.Once
}

// startJustRun launches `just run` in the bitwindow directory with an
// isolated BITWINDOWD_DATADIR so concurrent/repeat runs don't stomp on each
// other. Returns a runHandle the caller must stop.
func startJustRun(t *testing.T, extraEnv map[string]string) *runHandle {
	t.Helper()
	return startJustRunIn(t, makeTempDataDir(t), extraEnv)
}

// makeTempDataDir returns a per-test temp dir with best-effort cleanup. Unlike
// t.TempDir(), a RemoveAll failure doesn't fail the test — on Windows detached
// daemons can keep the exe locked past force-kill, and we'd rather pass the
// test than spuriously fail over a disk-cleanup race.
func makeTempDataDir(t *testing.T) string {
	t.Helper()
	dir, err := os.MkdirTemp("", "bitwindow-e2e-")
	if err != nil {
		t.Fatalf("mkdir temp: %v", err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(dir); err != nil {
			t.Logf("temp dir cleanup (non-fatal): %v", err)
		}
	})
	return dir
}

// startJustRunIn is like startJustRun but uses the given dataDir. Use this to
// reuse state across two consecutive launches (see the restart test).
func startJustRunIn(t *testing.T, dataDir string, extraEnv map[string]string) *runHandle {
	t.Helper()

	bitwindowDir := bitwindowRepoDir(t)

	cmd := exec.Command("just", "run")
	cmd.Dir = bitwindowDir

	env := os.Environ()
	env = append(env,
		"BITWINDOWD_DATADIR="+dataDir,
		"BITWINDOWD_LOG_CONSOLE=1",
	)
	for k, v := range extraEnv {
		env = append(env, k+"="+v)
	}
	cmd.Env = env

	// Put the child in its own process group so we can signal the whole tree
	// (just → bash → flutter run → bitwindow → bitwindowd → orchestratord).
	applyProcessGroup(cmd)

	stdoutPipe, err := cmd.StdoutPipe()
	if err != nil {
		t.Fatalf("stdout pipe: %v", err)
	}
	stderrPipe, err := cmd.StderrPipe()
	if err != nil {
		t.Fatalf("stderr pipe: %v", err)
	}

	if err := cmd.Start(); err != nil {
		t.Fatalf("start `just run`: %v", err)
	}

	h := &runHandle{
		cmd:     cmd,
		dataDir: dataDir,
		stdout:  newLineBuffer(t, "stdout", stdoutPipe),
		stderr:  newLineBuffer(t, "stderr", stderrPipe),
		doneCh:  make(chan error, 1),
	}

	go func() { h.doneCh <- cmd.Wait() }()
	return h
}

// bitwindowRepoDir returns the absolute path to `<repo>/bitwindow`, resolved
// relative to this source file.
func bitwindowRepoDir(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller failed")
	}
	return filepath.Clean(filepath.Join(filepath.Dir(thisFile), ".."))
}

// stop requests graceful shutdown (mirrors a user Ctrl+C / window close) and
// waits for the whole process tree to exit, escalating to SIGTERM and finally
// SIGKILL if needed. Idempotent.
func (h *runHandle) stop(t *testing.T, graceful time.Duration) {
	t.Helper()
	h.stopOnce.Do(func() {
		if err := interruptProcessGroup(h.cmd); err != nil {
			t.Logf("interrupt: %v", err)
		}

		select {
		case <-h.doneCh:
			return
		case <-time.After(graceful):
		}

		t.Logf("graceful stop timed out after %s, escalating to terminate", graceful)
		if err := terminateProcessGroup(h.cmd); err != nil {
			t.Logf("terminate: %v", err)
		}

		select {
		case <-h.doneCh:
			return
		case <-time.After(10 * time.Second):
		}

		t.Logf("terminate ignored, force-killing")
		if err := killProcessGroup(h.cmd); err != nil {
			t.Logf("kill: %v", err)
		}
		<-h.doneCh
		// Dart's Process.start on Windows defaults to detached, so
		// bitwindowd/orchestratord can escape the tree kill. Sweep them
		// by image name too.
		killOrphanDaemons(t)
	})
}


// waitUntil polls pred every interval until it returns true or deadline
// passes. On deadline, fails with msg.
func waitUntil(t *testing.T, deadline time.Duration, interval time.Duration, msg string, pred func() bool) {
	t.Helper()
	end := time.Now().Add(deadline)
	for time.Now().Before(end) {
		if pred() {
			return
		}
		time.Sleep(interval)
	}
	t.Fatalf("timeout after %s: %s", deadline, msg)
}

// processPIDs returns the PIDs of running processes whose executable basename
// matches name (Windows: name + ".exe"). Empty slice means no such process.
func processPIDs(t *testing.T, name string) []int {
	t.Helper()
	if runtime.GOOS == "windows" {
		return tasklistPIDs(t, name+".exe")
	}
	return pgrepPIDs(t, name)
}

func pgrepPIDs(t *testing.T, name string) []int {
	t.Helper()
	out, err := exec.Command("pgrep", "-x", name).Output()
	if err != nil {
		// pgrep exits 1 when nothing matches — treat as empty, not failure.
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) && exitErr.ExitCode() == 1 {
			return nil
		}
		t.Logf("pgrep %q failed: %v", name, err)
		return nil
	}
	return parsePIDs(string(out))
}

func tasklistPIDs(t *testing.T, imageName string) []int {
	t.Helper()
	out, err := exec.Command("tasklist", "/FO", "CSV", "/NH", "/FI", "IMAGENAME eq "+imageName).Output()
	if err != nil {
		t.Logf("tasklist %q failed: %v", imageName, err)
		return nil
	}
	text := string(out)
	if strings.Contains(text, "No tasks are running") || strings.TrimSpace(text) == "" {
		return nil
	}
	var pids []int
	for _, line := range strings.Split(text, "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		fields := strings.Split(line, ",")
		if len(fields) < 2 {
			continue
		}
		raw := strings.Trim(fields[1], "\" ")
		if pid, err := strconv.Atoi(raw); err == nil {
			pids = append(pids, pid)
		}
	}
	return pids
}

func parsePIDs(text string) []int {
	var pids []int
	for _, line := range strings.Split(text, "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		if pid, err := strconv.Atoi(line); err == nil {
			pids = append(pids, pid)
		}
	}
	return pids
}

// lineBuffer tees lines from a pipe to t.Log AND stores them for later
// assertions. Thread-safe.
type lineBuffer struct {
	label string
	mu    sync.Mutex
	lines []string
}

func newLineBuffer(t *testing.T, label string, r io.Reader) *lineBuffer {
	lb := &lineBuffer{label: label}
	go func() {
		scanner := bufio.NewScanner(r)
		scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024)
		for scanner.Scan() {
			line := scanner.Text()
			t.Logf("[%s] %s", label, line)
			lb.append(line)
		}
	}()
	return lb
}

func (lb *lineBuffer) append(line string) {
	lb.mu.Lock()
	lb.lines = append(lb.lines, line)
	lb.mu.Unlock()
}

func (lb *lineBuffer) contains(substr string) bool {
	lb.mu.Lock()
	defer lb.mu.Unlock()
	for _, line := range lb.lines {
		if strings.Contains(line, substr) {
			return true
		}
	}
	return false
}

func (lb *lineBuffer) snapshot() []string {
	lb.mu.Lock()
	defer lb.mu.Unlock()
	out := make([]string, len(lb.lines))
	copy(out, lb.lines)
	return out
}

// dumpDiagnostics writes captured output + the bitwindow debug.log to
// BITWINDOW_TEST_LOG_DIR if set. Call on test failure paths.
func (h *runHandle) dumpDiagnostics(t *testing.T) {
	t.Helper()
	dir := os.Getenv("BITWINDOW_TEST_LOG_DIR")
	if dir == "" {
		return
	}
	target := filepath.Join(dir, t.Name())
	if err := os.MkdirAll(target, 0o755); err != nil {
		t.Logf("mkdir %s: %v", target, err)
		return
	}

	write := func(name, content string) {
		path := filepath.Join(target, name)
		if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
			t.Logf("write %s: %v", path, err)
		}
	}
	write("stdout.log", strings.Join(h.stdout.snapshot(), "\n"))
	write("stderr.log", strings.Join(h.stderr.snapshot(), "\n"))

	if data, err := os.ReadFile(filepath.Join(h.dataDir, "debug.log")); err == nil {
		write("bitwindow-debug.log", string(data))
	}
}

// formatSample returns up to max trailing lines joined with newlines, for use
// in failure messages.
func formatSample(lines []string, max int) string {
	if len(lines) > max {
		lines = lines[len(lines)-max:]
	}
	return strings.Join(lines, "\n")
}

// skipIfNoDisplay bails out of tests on Linux when no display is available.
// `flutter run -d linux` needs a GUI surface; CI sets up Xvfb.
func skipIfNoDisplay(t *testing.T) {
	t.Helper()
	if runtime.GOOS != "linux" {
		return
	}
	if os.Getenv("DISPLAY") == "" && os.Getenv("WAYLAND_DISPLAY") == "" {
		t.Skip("no DISPLAY or WAYLAND_DISPLAY — these tests need a GUI surface (Xvfb in CI)")
	}
}

func prettyPIDs(pids []int) string {
	ss := make([]string, len(pids))
	for i, p := range pids {
		ss[i] = strconv.Itoa(p)
	}
	return fmt.Sprintf("[%s]", strings.Join(ss, ", "))
}

// tcpListening returns true if something is accepting TCP connections on
// 127.0.0.1:port.
func tcpListening(port int) bool {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("127.0.0.1:%d", port), 500*time.Millisecond)
	if err != nil {
		return false
	}
	_ = conn.Close()
	return true
}

// connectCall performs a Connect-JSON unary RPC against an http://host:port
// endpoint. The procedure argument is the fully-qualified protobuf name,
// e.g. "walletmanager.v1.WalletManagerService/GenerateWallet". Returns the
// raw JSON response body on success; returns an error for non-2xx statuses
// with the response body in the error message so test failures are
// actionable.
func connectCall(port int, procedure string, req any) (json.RawMessage, error) {
	body, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("marshal: %w", err)
	}

	url := fmt.Sprintf("http://127.0.0.1:%d/%s", port, procedure)
	httpReq, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("new request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("do: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("status %d: %s", resp.StatusCode, string(respBody))
	}
	return respBody, nil
}

// generateTestWallet creates a deterministic wallet via the orchestrator's
// WalletManagerService and returns its wallet_id. Uses a fixed mnemonic so
// the wallet is identifiable across runs even without bitcoind.
func generateTestWallet(t *testing.T) string {
	t.Helper()
	raw, err := connectCall(orchestratordPort,
		"walletmanager.v1.WalletManagerService/GenerateWallet",
		map[string]string{
			"name":            testWalletName,
			"custom_mnemonic": testWalletMnemonic,
		})
	if err != nil {
		t.Fatalf("GenerateWallet: %v", err)
	}
	var resp struct {
		WalletID string `json:"walletId"`
	}
	if err := json.Unmarshal(raw, &resp); err != nil {
		t.Fatalf("unmarshal GenerateWallet: %v (body: %s)", err, string(raw))
	}
	if resp.WalletID == "" {
		t.Fatalf("GenerateWallet returned empty wallet_id (body: %s)", string(raw))
	}
	return resp.WalletID
}

// walletStatus returns (has_wallet, active_wallet_id) from orchestratord's
// GetWalletStatus. Pure-state RPC — doesn't depend on bitcoind being up.
func walletStatus(t *testing.T) (hasWallet bool, activeID string) {
	t.Helper()
	raw, err := connectCall(orchestratordPort,
		"walletmanager.v1.WalletManagerService/GetWalletStatus",
		map[string]any{})
	if err != nil {
		t.Fatalf("GetWalletStatus: %v", err)
	}
	var resp struct {
		HasWallet      bool   `json:"hasWallet"`
		ActiveWalletID string `json:"activeWalletId"`
	}
	if err := json.Unmarshal(raw, &resp); err != nil {
		t.Fatalf("unmarshal GetWalletStatus: %v (body: %s)", err, string(raw))
	}
	return resp.HasWallet, resp.ActiveWalletID
}

// listWalletIDs returns the wallet_ids stored on orchestratord. Pure state,
// doesn't depend on bitcoind.
func listWalletIDs(t *testing.T) []string {
	t.Helper()
	raw, err := connectCall(orchestratordPort,
		"walletmanager.v1.WalletManagerService/ListWallets",
		map[string]any{})
	if err != nil {
		t.Fatalf("ListWallets: %v", err)
	}
	var resp struct {
		Wallets []struct {
			ID string `json:"id"`
		} `json:"wallets"`
	}
	if err := json.Unmarshal(raw, &resp); err != nil {
		t.Fatalf("unmarshal ListWallets: %v (body: %s)", err, string(raw))
	}
	ids := make([]string, 0, len(resp.Wallets))
	for _, w := range resp.Wallets {
		ids = append(ids, w.ID)
	}
	return ids
}

// waitForPort polls until something accepts TCP on 127.0.0.1:port or deadline.
func waitForPort(t *testing.T, port int, deadline time.Duration, label string) {
	t.Helper()
	waitUntil(t, deadline, 500*time.Millisecond, label+" not listening on port "+strconv.Itoa(port), func() bool {
		return tcpListening(port)
	})
}

// waitForOrchestratorRPC polls ListBinaries (a cheap, always-available RPC)
// until it returns 200 OK or deadline. This proves orchestratord is actually
// serving RPCs, not merely holding a port.
func waitForOrchestratorRPC(t *testing.T, deadline time.Duration) {
	t.Helper()
	waitUntil(t, deadline, 1*time.Second, "orchestratord RPC not responsive", func() bool {
		_, err := connectCall(orchestratordPort,
			"orchestrator.v1.OrchestratorService/ListBinaries",
			map[string]any{})
		return err == nil
	})
}
