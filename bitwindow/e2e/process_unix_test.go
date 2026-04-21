//go:build e2e && !windows

package e2e

import (
	"errors"
	"fmt"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"syscall"
	"testing"
)

// applyProcessGroup puts the child in a fresh process group so we can signal
// the whole tree via a negative PID.
func applyProcessGroup(cmd *exec.Cmd) {
	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.Setpgid = true
}

// interruptProcessGroup sends SIGINT to the whole process group (Ctrl+C).
func interruptProcessGroup(cmd *exec.Cmd) error {
	return signalGroup(cmd, syscall.SIGINT)
}

// terminateProcessGroup sends SIGTERM to the whole process group.
func terminateProcessGroup(cmd *exec.Cmd) error {
	return signalGroup(cmd, syscall.SIGTERM)
}

// killProcessGroup sends SIGKILL to the whole process group.
func killProcessGroup(cmd *exec.Cmd) error {
	return signalGroup(cmd, syscall.SIGKILL)
}

func signalGroup(cmd *exec.Cmd, sig syscall.Signal) error {
	if cmd == nil || cmd.Process == nil {
		return errors.New("no process")
	}
	// Negative PID → signal the entire process group.
	pgid, err := syscall.Getpgid(cmd.Process.Pid)
	if err != nil {
		return fmt.Errorf("getpgid: %w", err)
	}
	if err := syscall.Kill(-pgid, sig); err != nil {
		return fmt.Errorf("kill -%d -%d: %w", sig, pgid, err)
	}
	return nil
}

// closeAppViaWindowSystem triggers a graceful "user closed the window"
// event for the Flutter app identified by pid. This exercises the GUI
// close path — onWindowClose in root_page.dart — NOT the POSIX signal
// path that setupSignalHandlers listens for. On Unix we dispatch to
// platform-specific tools; see the corresponding _windows variant for
// WM_CLOSE.
func closeAppViaWindowSystem(t *testing.T, pid int) error {
	t.Helper()
	switch runtime.GOOS {
	case "darwin":
		// AppleScript "tell application ... to quit" dispatches the
		// Cocoa quit Apple Event — the same thing Cmd+Q / the red X
		// produce. Does NOT translate into a POSIX signal.
		script := fmt.Sprintf(`tell application "%s" to quit`, flutterAppProcessName())
		out, err := exec.Command("osascript", "-e", script).CombinedOutput()
		if err != nil {
			// -128 "User canceled" = the app intercepted the quit and
			// is running its own shutdown flow (window_manager's
			// setPreventClose(true) + onWindowClose handler). That's
			// exactly what we want — the event WAS dispatched and is
			// being handled. Treat as success.
			if strings.Contains(string(out), "(-128)") {
				return nil
			}
			return fmt.Errorf("osascript quit: %w (output: %s)", err, string(out))
		}
		return nil
	case "linux":
		// Log every window xdotool sees for this pid so we can tell
		// whether WM_DELETE_WINDOW actually has a target.
		searchOut, searchErr := exec.Command("xdotool", "search", "--pid", strconv.Itoa(pid)).CombinedOutput()
		t.Logf("xdotool search --pid %d → err=%v, windows=%q", pid, searchErr, strings.TrimSpace(string(searchOut)))

		out, err := exec.Command("xdotool", "search", "--pid", strconv.Itoa(pid), "windowclose").CombinedOutput()
		t.Logf("xdotool windowclose → err=%v, out=%q", err, strings.TrimSpace(string(out)))

		// Xvfb runs without a window manager, so WM_DELETE_WINDOW has
		// no one to deliver it. Fall back to SIGTERM on the Flutter
		// app pid — setupSignalHandlers in main.dart handles SIGTERM
		// and runs BinaryProvider.onShutdown. Same end state.
		if killErr := syscall.Kill(pid, syscall.SIGTERM); killErr != nil {
			t.Logf("SIGTERM to pid %d failed: %v", pid, killErr)
		}
		return nil
	default:
		return fmt.Errorf("closeAppViaWindowSystem: unsupported GOOS %s", runtime.GOOS)
	}
}
