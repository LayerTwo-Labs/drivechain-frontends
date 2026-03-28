package orchestrator

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/rs/zerolog"
)

// LogEntry represents a line of output from a managed process.
type LogEntry struct {
	Timestamp time.Time
	Stream    string // "stdout" or "stderr"
	Line      string
}

// ManagedProcess represents a running process managed by the orchestrator.
type ManagedProcess struct {
	Config  BinaryConfig
	Pid     int
	Cmd     *exec.Cmd
	Started time.Time
	Adopted bool // true if this process was found from a previous session

	mu       sync.Mutex
	logs     []LogEntry // ring buffer
	logSubs  []chan LogEntry
	exitCh   chan struct{} // closed when process exits
	exitCode int
	exitErr  string
}

// ExitCh returns a channel that is closed when the process exits.
func (p *ManagedProcess) ExitCh() <-chan struct{} {
	return p.exitCh
}

// ExitCode returns the process exit code (only valid after exitCh is closed).
func (p *ManagedProcess) ExitCode() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.exitCode
}

const maxLogEntries = 5000

func (p *ManagedProcess) addLog(entry LogEntry) {
	p.mu.Lock()
	defer p.mu.Unlock()

	p.logs = append(p.logs, entry)
	if len(p.logs) > maxLogEntries {
		p.logs = p.logs[len(p.logs)-maxLogEntries:]
	}

	for _, sub := range p.logSubs {
		select {
		case sub <- entry:
		default: // don't block if subscriber is slow
		}
	}
}

// Subscribe returns a channel that receives new log entries and a cancel function.
func (p *ManagedProcess) Subscribe() (<-chan LogEntry, func()) {
	p.mu.Lock()
	defer p.mu.Unlock()

	ch := make(chan LogEntry, 100)
	p.logSubs = append(p.logSubs, ch)

	cancel := func() {
		p.mu.Lock()
		defer p.mu.Unlock()
		for i, sub := range p.logSubs {
			if sub == ch {
				p.logSubs = append(p.logSubs[:i], p.logSubs[i+1:]...)
				close(ch)
				return
			}
		}
	}

	return ch, cancel
}

// RecentLogs returns the most recent log entries.
func (p *ManagedProcess) RecentLogs(n int) []LogEntry {
	p.mu.Lock()
	defer p.mu.Unlock()

	if n >= len(p.logs) {
		result := make([]LogEntry, len(p.logs))
		copy(result, p.logs)
		return result
	}
	result := make([]LogEntry, n)
	copy(result, p.logs[len(p.logs)-n:])
	return result
}

// ProcessManager handles spawning, monitoring, and killing processes.
type ProcessManager struct {
	dataDir    string
	pidManager *PidFileManager
	log        zerolog.Logger

	mu        sync.Mutex
	processes map[string]*ManagedProcess // keyed by config name
}

func NewProcessManager(dataDir string, pidManager *PidFileManager, log zerolog.Logger) *ProcessManager {
	return &ProcessManager{
		dataDir:    dataDir,
		pidManager: pidManager,
		log:        log.With().Str("component", "process").Logger(),
		processes:  make(map[string]*ManagedProcess),
	}
}

// Start launches a binary and returns its PID.
func (pm *ProcessManager) Start(_ context.Context, config BinaryConfig, args []string, env map[string]string) (int, error) {
	pm.mu.Lock()
	if _, exists := pm.processes[config.Name]; exists {
		pm.mu.Unlock()
		return 0, fmt.Errorf("%s is already running", config.Name)
	}
	pm.mu.Unlock()

	binPath := BinaryPath(pm.dataDir, config.BinaryName)
	if _, err := os.Stat(binPath); err != nil {
		return 0, fmt.Errorf("binary not found at %s: %w", binPath, err)
	}

	if err := chmod(binPath); err != nil {
		pm.log.Warn().Err(err).Str("binary", config.Name).Msg("chmod")
	}

	// Raise file descriptor limit for child processes (bitcoind needs many)
	raiseOpenFilesLimit(pm.log)

	// Use background context so child processes survive beyond the RPC request.
	// The orchestrator manages process lifecycle via Stop/StopAll, not via context.
	cmd := exec.Command(binPath, args...)
	cmd.Dir = pm.dataDir

	// Set environment
	cmd.Env = os.Environ()
	for k, v := range env {
		cmd.Env = append(cmd.Env, k+"="+v)
	}

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return 0, fmt.Errorf("stdout pipe: %w", err)
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return 0, fmt.Errorf("stderr pipe: %w", err)
	}

	if err := cmd.Start(); err != nil {
		return 0, fmt.Errorf("start %s: %w", config.Name, err)
	}

	proc := &ManagedProcess{
		Config:  config,
		Pid:     cmd.Process.Pid,
		Cmd:     cmd,
		Started: time.Now(),
		logs:    make([]LogEntry, 0, 256),
		exitCh:  make(chan struct{}),
	}

	pm.mu.Lock()
	pm.processes[config.Name] = proc
	pm.mu.Unlock()

	// Write PID file
	if err := pm.pidManager.WritePidFile(config.BinaryName, cmd.Process.Pid); err != nil {
		pm.log.Warn().Err(err).Str("binary", config.Name).Msg("write PID file")
	}

	// Capture stdout
	go func() {
		scanner := bufio.NewScanner(stdout)
		scanner.Buffer(make([]byte, 1024*1024), 1024*1024)
		for scanner.Scan() {
			line := scanner.Text()
			if isSpam(line) {
				continue
			}
			proc.addLog(LogEntry{
				Timestamp: time.Now(),
				Stream:    "stdout",
				Line:      stripANSI(line),
			})
		}
	}()

	// Capture stderr
	go func() {
		scanner := bufio.NewScanner(stderr)
		scanner.Buffer(make([]byte, 1024*1024), 1024*1024)
		for scanner.Scan() {
			line := scanner.Text()
			if isSpam(line) {
				continue
			}
			proc.addLog(LogEntry{
				Timestamp: time.Now(),
				Stream:    "stderr",
				Line:      stripANSI(line),
			})
		}
	}()

	// Wait for exit in background
	go func() {
		err := cmd.Wait()
		proc.mu.Lock()
		if err != nil {
			proc.exitErr = err.Error()
		}
		if cmd.ProcessState != nil {
			proc.exitCode = cmd.ProcessState.ExitCode()
		}
		proc.mu.Unlock()

		close(proc.exitCh)

		pm.mu.Lock()
		delete(pm.processes, config.Name)
		pm.mu.Unlock()

		_ = pm.pidManager.DeletePidFile(config.BinaryName)

		pm.log.Info().
			Str("binary", config.Name).
			Int("pid", proc.Pid).
			Int("exit_code", proc.exitCode).
			Msg("process exited")
	}()

	pm.log.Info().
		Str("binary", config.Name).
		Int("pid", cmd.Process.Pid).
		Msg("started process")

	// Early exit detection: if the process exits within 500ms, return an error
	select {
	case <-proc.exitCh:
		proc.mu.Lock()
		exitErr := proc.exitErr
		exitCode := proc.exitCode
		proc.mu.Unlock()

		// Collect last few stderr lines for the error message
		logs := proc.RecentLogs(10)
		var stderrLines []string
		for _, l := range logs {
			if l.Stream == "stderr" {
				stderrLines = append(stderrLines, l.Line)
			}
		}

		errMsg := fmt.Sprintf("%s exited immediately (code %d)", config.Name, exitCode)
		if exitErr != "" {
			errMsg += ": " + exitErr
		}
		if len(stderrLines) > 0 {
			errMsg += "\nstderr: " + strings.Join(stderrLines, "\n")
		}

		return 0, fmt.Errorf("%s", errMsg)

	case <-time.After(500 * time.Millisecond):
		// Process is still running after 500ms, consider it started
	}

	return cmd.Process.Pid, nil
}

// Stop gracefully stops a process. If force is true, sends SIGKILL immediately.
func (pm *ProcessManager) Stop(_ context.Context, name string, force bool) error {
	pm.mu.Lock()
	proc, exists := pm.processes[name]
	pm.mu.Unlock()

	if !exists {
		return fmt.Errorf("%s is not running", name)
	}

	if force {
		if err := forceKillProcess(proc.Pid); err != nil {
			return fmt.Errorf("force kill %s: %w", name, err)
		}
		return nil
	}

	if err := killProcess(proc.Pid); err != nil {
		return fmt.Errorf("stop %s: %w", name, err)
	}

	// Wait for the process to exit (with timeout)
	select {
	case <-proc.exitCh:
		return nil
	case <-time.After(10 * time.Second):
		// Force kill after timeout
		pm.log.Warn().Str("binary", name).Msg("graceful shutdown timed out, force killing")
		return forceKillProcess(proc.Pid)
	}
}

// StopAll stops all running processes.
func (pm *ProcessManager) StopAll(ctx context.Context, force bool) error {
	pm.mu.Lock()
	names := make([]string, 0, len(pm.processes))
	for name := range pm.processes {
		names = append(names, name)
	}
	pm.mu.Unlock()

	var firstErr error
	for _, name := range names {
		if err := pm.Stop(ctx, name, force); err != nil {
			pm.log.Warn().Err(err).Str("binary", name).Msg("stop")
			if firstErr == nil {
				firstErr = err
			}
		}
	}
	return firstErr
}

// Get returns the managed process for a binary, or nil if not running.
func (pm *ProcessManager) Get(name string) *ManagedProcess {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	return pm.processes[name]
}

// IsRunning checks if a binary is currently running.
func (pm *ProcessManager) IsRunning(name string) bool {
	return pm.Get(name) != nil
}

// ListRunning returns the names of all running processes.
func (pm *ProcessManager) ListRunning() []string {
	pm.mu.Lock()
	defer pm.mu.Unlock()

	names := make([]string, 0, len(pm.processes))
	for name := range pm.processes {
		names = append(names, name)
	}
	return names
}

// AdoptProcess registers an externally-found process (from a PID file).
func (pm *ProcessManager) AdoptProcess(config BinaryConfig, pid int) {
	pm.mu.Lock()
	defer pm.mu.Unlock()

	if _, exists := pm.processes[config.Name]; exists {
		return
	}

	pm.processes[config.Name] = &ManagedProcess{
		Config:  config,
		Pid:     pid,
		Started: time.Now(),
		Adopted: true,
		logs:    make([]LogEntry, 0),
		exitCh:  make(chan struct{}),
	}

	pm.log.Info().Str("binary", config.Name).Int("pid", pid).Msg("adopted orphaned process")
}

// IsAdopted returns true if the named process was adopted (not started by us).
func (pm *ProcessManager) IsAdopted(name string) bool {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	p, exists := pm.processes[name]
	return exists && p.Adopted
}

// Remove removes a process from tracking without stopping it.
// Used for adopted processes that we don't own.
func (pm *ProcessManager) Remove(name string) {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	delete(pm.processes, name)
}

// Spam filter patterns (ported from Dart isSpam function)
var spamPatterns = []*regexp.Regexp{
	regexp.MustCompile(`tower_http`),
	regexp.MustCompile(`Ripemd160`),
	regexp.MustCompile(`rpc: fetch completed in`),
}

// isSpam returns true if a log line should be filtered out.
func isSpam(line string) bool {
	for _, p := range spamPatterns {
		if p.MatchString(line) {
			return true
		}
	}
	return false
}

var ansiPattern = regexp.MustCompile(`\x1b\[[0-9;]*[a-zA-Z]`)

func stripANSI(s string) string {
	return ansiPattern.ReplaceAllString(s, "")
}

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
