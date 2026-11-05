//go:build e2e && !windows

package e2e

import (
	"errors"
	"fmt"
	"os/exec"
	"runtime"
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

// forceKillPID kills one process and nothing it spawned, so the daemons have
// to reap themselves.
func forceKillPID(pid int) error {
	if err := syscall.Kill(pid, syscall.SIGKILL); err != nil {
		return fmt.Errorf("kill -9 %d: %w", pid, err)
	}
	return nil
}

// signalPID sends one signal to one process and nothing it spawned, so the
// app runs its own handler and the daemons keep running until it acts.
func signalPID(pid int, sig string) error {
	signals := map[string]syscall.Signal{"SIGINT": syscall.SIGINT, "SIGTERM": syscall.SIGTERM}
	s, known := signals[sig]
	if !known {
		return fmt.Errorf("unknown signal %q", sig)
	}
	if err := syscall.Kill(pid, s); err != nil {
		return fmt.Errorf("%s %d: %w", sig, pid, err)
	}
	return nil
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
		return closeLinuxWindow(pid)
	default:
		return fmt.Errorf("closeAppViaWindowSystem: unsupported GOOS %s", runtime.GOOS)
	}
}
