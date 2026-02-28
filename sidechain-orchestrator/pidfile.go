package orchestrator

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/rs/zerolog"
)

// PidFileManager handles PID file read/write/validate operations.
// PID files are stored at {dataDir}/pids/{binaryName}.pid
type PidFileManager struct {
	pidDir string
	log    zerolog.Logger
}

func NewPidFileManager(dataDir string, log zerolog.Logger) *PidFileManager {
	dir := PidDir(dataDir)
	_ = os.MkdirAll(dir, 0o755)
	return &PidFileManager{
		pidDir: dir,
		log:    log.With().Str("component", "pidfile").Logger(),
	}
}

func (m *PidFileManager) pidPath(binaryName string) string {
	return filepath.Join(m.pidDir, binaryName+".pid")
}

func (m *PidFileManager) WritePidFile(binaryName string, pid int) error {
	path := m.pidPath(binaryName)
	if err := os.WriteFile(path, []byte(strconv.Itoa(pid)), 0o644); err != nil {
		m.log.Warn().Err(err).Str("binary", binaryName).Msg("write PID file")
		return fmt.Errorf("write PID file for %s: %w", binaryName, err)
	}
	m.log.Debug().Str("binary", binaryName).Int("pid", pid).Msg("wrote PID file")
	return nil
}

func (m *PidFileManager) ReadPidFile(binaryName string) (int, error) {
	path := m.pidPath(binaryName)
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return 0, err
		}
		return 0, fmt.Errorf("read PID file for %s: %w", binaryName, err)
	}

	pid, err := strconv.Atoi(strings.TrimSpace(string(data)))
	if err != nil {
		// Invalid PID file, clean it up
		m.log.Warn().Str("binary", binaryName).Str("content", string(data)).Msg("invalid PID file, deleting")
		_ = m.DeletePidFile(binaryName)
		return 0, fmt.Errorf("parse PID file for %s: %w", binaryName, err)
	}

	return pid, nil
}

func (m *PidFileManager) DeletePidFile(binaryName string) error {
	path := m.pidPath(binaryName)
	if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
		m.log.Warn().Err(err).Str("binary", binaryName).Msg("delete PID file")
		return fmt.Errorf("delete PID file for %s: %w", binaryName, err)
	}
	return nil
}

// ValidatePid checks if a PID is alive and belongs to the expected binary.
// Returns true only if the process is alive AND the process name matches.
func (m *PidFileManager) ValidatePid(pid int, binaryName string) bool {
	if !isPidAlive(pid) {
		return false
	}

	procName, err := getProcessName(pid)
	if err != nil {
		m.log.Debug().Err(err).Int("pid", pid).Msg("get process name")
		return false
	}

	return processNameMatches(procName, binaryName)
}

// processNameMatches compares process names case-insensitively with bidirectional
// contains check (handles truncated names from ps).
func processNameMatches(procName, binaryName string) bool {
	procLower := strings.ToLower(procName)
	binLower := strings.ToLower(binaryName)

	return strings.Contains(procLower, binLower) || strings.Contains(binLower, procLower)
}

// ListPidFiles returns all PID files and their PIDs.
func (m *PidFileManager) ListPidFiles() map[string]int {
	result := make(map[string]int)

	entries, err := os.ReadDir(m.pidDir)
	if err != nil {
		return result
	}

	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".pid") {
			continue
		}
		binaryName := strings.TrimSuffix(entry.Name(), ".pid")
		pid, err := m.ReadPidFile(binaryName)
		if err != nil {
			continue
		}
		result[binaryName] = pid
	}

	return result
}
