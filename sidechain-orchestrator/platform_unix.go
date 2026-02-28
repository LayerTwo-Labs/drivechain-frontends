//go:build !windows

package orchestrator

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"syscall"
)

// chmod makes a file executable.
func chmod(path string) error {
	return os.Chmod(path, 0o755)
}

// isPidAlive checks if a process with the given PID is alive.
func isPidAlive(pid int) bool {
	out, err := exec.Command("ps", "-p", strconv.Itoa(pid)).CombinedOutput()
	if err != nil {
		return false
	}
	return strings.Contains(string(out), strconv.Itoa(pid))
}

// getProcessName returns the executable name for a given PID.
func getProcessName(pid int) (string, error) {
	out, err := exec.Command("ps", "-p", strconv.Itoa(pid), "-o", "comm=").CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("ps command: %w", err)
	}
	name := strings.TrimSpace(string(out))
	if name == "" {
		return "", fmt.Errorf("empty process name for PID %d", pid)
	}
	return name, nil
}

// killProcess sends SIGTERM, then SIGKILL if the process doesn't exit.
func killProcess(pid int) error {
	proc, err := os.FindProcess(pid)
	if err != nil {
		return fmt.Errorf("find process %d: %w", pid, err)
	}

	if err := proc.Signal(syscall.SIGTERM); err != nil {
		// Process might already be dead
		if !isPidAlive(pid) {
			return nil
		}
		return fmt.Errorf("send SIGTERM to %d: %w", pid, err)
	}

	return nil
}

// forceKillProcess sends SIGKILL immediately.
func forceKillProcess(pid int) error {
	proc, err := os.FindProcess(pid)
	if err != nil {
		return fmt.Errorf("find process %d: %w", pid, err)
	}

	if err := proc.Signal(syscall.SIGKILL); err != nil {
		if !isPidAlive(pid) {
			return nil
		}
		return fmt.Errorf("send SIGKILL to %d: %w", pid, err)
	}

	return nil
}

// gracefulShutdownSignal returns the signal used for graceful shutdown.
func gracefulShutdownSignal() os.Signal {
	return syscall.SIGTERM
}
