//go:build windows

package orchestrator

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"

	"github.com/rs/zerolog"
)

func chmod(_ string) error {
	return nil // no-op on Windows
}

func isPidAlive(pid int) bool {
	out, err := exec.Command("tasklist", "/FI", fmt.Sprintf("PID eq %d", pid), "/NH").CombinedOutput()
	if err != nil {
		return false
	}
	return strings.Contains(string(out), strconv.Itoa(pid))
}

// getProcessName returns the executable name for a given PID.
// Dart: getProcessName (L112-151) — parses first quoted value, strips .exe
func getProcessName(pid int) (string, error) {
	out, err := exec.Command("tasklist", "/FI", fmt.Sprintf("PID eq %d", pid), "/FO", "CSV", "/NH").CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("tasklist command: %w", err)
	}

	line := strings.TrimSpace(string(out))
	if line == "" || strings.Contains(line, "No tasks") {
		return "", fmt.Errorf("no process found for PID %d", pid)
	}

	// CSV format: "image_name","pid","session","session#","mem_usage"
	parts := strings.SplitN(line, ",", 2)
	if len(parts) < 1 {
		return "", fmt.Errorf("parse tasklist output for PID %d", pid)
	}

	name := strings.Trim(parts[0], `"`)

	// Dart L133-135: Remove .exe suffix for comparison
	if strings.HasSuffix(strings.ToLower(name), ".exe") {
		name = name[:len(name)-4]
	}

	return name, nil
}

func killProcess(pid int) error {
	cmd := exec.Command("taskkill", "/PID", strconv.Itoa(pid))
	if err := cmd.Run(); err != nil {
		if !isPidAlive(pid) {
			return nil
		}
		return fmt.Errorf("taskkill %d: %w", pid, err)
	}
	return nil
}

func forceKillProcess(pid int) error {
	cmd := exec.Command("taskkill", "/F", "/PID", strconv.Itoa(pid))
	if err := cmd.Run(); err != nil {
		if !isPidAlive(pid) {
			return nil
		}
		return fmt.Errorf("taskkill /F %d: %w", pid, err)
	}
	return nil
}

// raiseOpenFilesLimit is a no-op on Windows (no RLIMIT_NOFILE).
func raiseOpenFilesLimit(_ zerolog.Logger) {}
