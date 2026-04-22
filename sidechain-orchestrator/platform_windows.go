//go:build windows

package orchestrator

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/rs/zerolog"
)

const (
	// bitcoind's LevelDB flush can outlast a signet-node's 10s on a warm SSD.
	gracefulKillTimeout = 30 * time.Second

	// Windows keeps file handles briefly after TerminateProcess; reset sweeps
	// can otherwise hit ERROR_SHARING_VIOLATION.
	postKillFileLockGrace = 5 * time.Second

	createNewProcessGroup = 0x00000200
	ctrlBreakEvent        = 1
)

var (
	kernel32                     = syscall.NewLazyDLL("kernel32.dll")
	procGenerateConsoleCtrlEvent = kernel32.NewProc("GenerateConsoleCtrlEvent")
)

func chmod(_ string) error { return nil }

// configureProcessAttr is a prerequisite for GenerateConsoleCtrlEvent —
// without a dedicated group the signal would also hit orchestratord.
func configureProcessAttr(cmd *exec.Cmd) {
	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.CreationFlags |= createNewProcessGroup
}

func isPidAlive(pid int) bool {
	out, err := exec.Command("tasklist", "/FI", fmt.Sprintf("PID eq %d", pid), "/NH").CombinedOutput()
	if err != nil {
		return false
	}
	return strings.Contains(string(out), strconv.Itoa(pid))
}

func getProcessName(pid int) (string, error) {
	out, err := exec.Command("tasklist", "/FI", fmt.Sprintf("PID eq %d", pid), "/FO", "CSV", "/NH").CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("tasklist command: %w", err)
	}

	line := strings.TrimSpace(string(out))
	if line == "" || strings.Contains(line, "No tasks") {
		return "", fmt.Errorf("no process found for PID %d", pid)
	}

	parts := strings.SplitN(line, ",", 2)
	if len(parts) < 1 {
		return "", fmt.Errorf("parse tasklist output for PID %d", pid)
	}

	name := strings.Trim(parts[0], `"`)
	if strings.HasSuffix(strings.ToLower(name), ".exe") {
		name = name[:len(name)-4]
	}

	return name, nil
}

func findPidByName(binaryName string) (int, error) {
	out, err := exec.Command("tasklist", "/FI", fmt.Sprintf("IMAGENAME eq %s.exe", binaryName), "/FO", "CSV", "/NH").CombinedOutput()
	if err != nil {
		return 0, fmt.Errorf("tasklist for %s: %w", binaryName, err)
	}

	line := strings.TrimSpace(string(out))
	if line == "" || strings.Contains(line, "No tasks") {
		return 0, fmt.Errorf("no process found for %s", binaryName)
	}

	parts := strings.SplitN(line, ",", 3)
	if len(parts) < 2 {
		return 0, fmt.Errorf("parse tasklist output for %s", binaryName)
	}

	pidStr := strings.Trim(parts[1], `"`)
	pid, err := strconv.Atoi(strings.TrimSpace(pidStr))
	if err != nil {
		return 0, fmt.Errorf("parse pid for %s: %w", binaryName, err)
	}

	return pid, nil
}

// killProcess sends CTRL_BREAK to the child's process group. Console-subsystem
// daemons (bitcoind, enforcer, sidechains) trap this and flush cleanly; GUI
// WM_CLOSE via plain taskkill does not reach them.
func killProcess(pid int) error {
	ret, _, err := procGenerateConsoleCtrlEvent.Call(
		uintptr(ctrlBreakEvent),
		uintptr(uint32(pid)),
	)
	if ret == 0 {
		if !isPidAlive(pid) {
			return nil
		}
		return fmt.Errorf("GenerateConsoleCtrlEvent pid=%d: %w", pid, err)
	}
	return nil
}

func forceKillProcess(pid int) error {
	cmd := exec.Command("taskkill", "/F", "/T", "/PID", strconv.Itoa(pid))
	if err := cmd.Run(); err != nil {
		if !isPidAlive(pid) {
			return nil
		}
		return fmt.Errorf("taskkill /F /T %d: %w", pid, err)
	}
	return nil
}

func raiseOpenFilesLimit(_ zerolog.Logger) {}
