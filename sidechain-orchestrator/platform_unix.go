//go:build !windows

package orchestrator

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"syscall"

	"github.com/rs/zerolog"
)

// chmod makes a file executable.
func chmod(path string) error {
	return os.Chmod(path, 0o755)
}

// isPidAlive checks if a process with the given PID is alive.
// Dart: isPidAlive (L91-101) — uses exitCode == 0
func isPidAlive(pid int) bool {
	err := exec.Command("ps", "-p", strconv.Itoa(pid)).Run()
	return err == nil
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

// findPidByName returns the PID of a running process by name.
// Dart equivalent: pgrep approach used when PID files aren't available.
// Uses pgrep which is available on macOS and Linux.
func findPidByName(binaryName string) (int, error) {
	out, err := exec.Command("pgrep", "-x", binaryName).CombinedOutput()
	if err != nil {
		// pgrep returns exit code 1 when no process found
		return 0, fmt.Errorf("no process found for %s", binaryName)
	}

	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	if len(lines) == 0 || lines[0] == "" {
		return 0, fmt.Errorf("no process found for %s", binaryName)
	}

	// Return the first match
	pid, err := strconv.Atoi(strings.TrimSpace(lines[0]))
	if err != nil {
		return 0, fmt.Errorf("parse pid for %s: %w", binaryName, err)
	}

	return pid, nil
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

// raiseOpenFilesLimit sets RLIMIT_NOFILE to a finite value that bitcoind can use.
// When the shell has "unlimited" fds, bitcoind interprets that as -1 and refuses
// to start. We clamp to a concrete value so child processes get a usable limit.
func raiseOpenFilesLimit(log zerolog.Logger) {
	var rLimit syscall.Rlimit
	if err := syscall.Getrlimit(syscall.RLIMIT_NOFILE, &rLimit); err != nil {
		log.Warn().Err(err).Msg("getrlimit NOFILE")
		return
	}

	const desired uint64 = 4096
	// RLIM_INFINITY or very large values confuse bitcoind (shows "-1 available").
	// Treat anything above 1<<60 as infinity and force it down.
	const infinityThreshold uint64 = 1 << 60

	target := desired
	if rLimit.Cur >= infinityThreshold {
		// Current limit is effectively unlimited — set to a sane value
		log.Debug().Uint64("cur", rLimit.Cur).Msg("fd limit is unlimited, clamping")
	} else if rLimit.Cur >= target {
		// Already high enough and finite — nothing to do
		return
	}

	if rLimit.Max < target && rLimit.Max > 0 && rLimit.Max < infinityThreshold {
		target = rLimit.Max
	}

	rLimit.Cur = target
	if err := syscall.Setrlimit(syscall.RLIMIT_NOFILE, &rLimit); err != nil {
		log.Warn().Err(err).Uint64("target", target).Msg("setrlimit NOFILE")
		return
	}

	log.Info().Uint64("new_limit", target).Msg("set open files limit")
}
