//go:build e2e && windows

package e2e

import (
	"errors"
	"fmt"
	"os/exec"
	"strconv"
	"syscall"
	"testing"
)

// applyProcessGroup spawns the child as the root of a new process group so
// we can kill the tree with taskkill /T.
func applyProcessGroup(cmd *exec.Cmd) {
	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.CreationFlags |= 0x00000200 // CREATE_NEW_PROCESS_GROUP
}

// interruptProcessGroup sends Ctrl+Break to the group (closest Windows
// equivalent of SIGINT for a detached group).
func interruptProcessGroup(cmd *exec.Cmd) error {
	if cmd == nil || cmd.Process == nil {
		return errors.New("no process")
	}
	// GenerateConsoleCtrlEvent is unreliable across process groups that don't
	// share a console — defer to taskkill which is the canonical way to
	// terminate a process tree gracefully on Windows.
	return runTaskkill(cmd.Process.Pid, false)
}

// terminateProcessGroup is the same as interrupt on Windows — taskkill
// without /F asks the process to exit.
func terminateProcessGroup(cmd *exec.Cmd) error {
	if cmd == nil || cmd.Process == nil {
		return errors.New("no process")
	}
	return runTaskkill(cmd.Process.Pid, false)
}

// killProcessGroup force-kills the whole tree (taskkill /T /F).
func killProcessGroup(cmd *exec.Cmd) error {
	if cmd == nil || cmd.Process == nil {
		return errors.New("no process")
	}
	return runTaskkill(cmd.Process.Pid, true)
}

func runTaskkill(pid int, force bool) error {
	args := []string{"/PID", strconv.Itoa(pid), "/T"}
	if force {
		args = append(args, "/F")
	}
	out, err := exec.Command("taskkill", args...).CombinedOutput()
	if err != nil {
		return fmt.Errorf("taskkill %v: %w (output: %s)", args, err, string(out))
	}
	return nil
}

// Clears orphans from a previous crashed run so the next `just run` can bind
// its RPC ports. In-run shutdown is the orchestrator's responsibility.
func sweepPriorRunOrphans(t *testing.T) {
	t.Helper()
	for _, name := range []string{"bitwindowd.exe", "orchestratord.exe", "bitcoind.exe", "bip300301_enforcer.exe"} {
		_ = exec.Command("taskkill", "/F", "/IM", name).Run()
	}
}

// closeAppViaWindowSystem sends WM_CLOSE to the top-level window of the
// given pid — the Windows equivalent of clicking the X button. Goes through
// the Flutter onWindowClose handler, not a POSIX signal.
func closeAppViaWindowSystem(t *testing.T, pid int) error {
	t.Helper()
	// `taskkill` without /F sends WM_CLOSE to the main window of the pid.
	out, err := exec.Command("taskkill", "/PID", strconv.Itoa(pid)).CombinedOutput()
	if err != nil {
		return fmt.Errorf("taskkill WM_CLOSE: %w (output: %s)", err, string(out))
	}
	return nil
}
