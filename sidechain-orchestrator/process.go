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
	Config       BinaryConfig
	Pid          int
	Cmd          *exec.Cmd
	BinPath      string // resolved executable path used for this process
	PidName      string // PID-file basename used for this process
	Started      time.Time
	Adopted      bool // true if this process was found from a previous session
	Orphan       bool // true if a previous run of this install started it and left it behind
	ForceBackend bool // true if this sidechain was launched with --force-backend (skips flutter_frontend variant)

	mu       sync.Mutex
	logs     []LogEntry // ring buffer
	logSubs  []chan LogEntry
	exitCh   chan struct{} // closed when process exits
	exitCode int
	exitErr  string
	// exitDetails holds the rich crash message: stderr buffer or last
	// error/fatal/panic lines from stdout, with `exitErr` (cmd.Wait
	// status) as a fallback. Populated alongside the OnExit callback so
	// later code paths (waitForConnectedOrExit, daemon-card error
	// rendering) can surface the *actual* crash reason instead of just
	// "exit status 1".
	exitDetails string
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

// ExitErr returns the exit error string (only valid after exitCh is closed).
func (p *ManagedProcess) ExitErr() string {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.exitErr
}

// ExitDetails returns the rich crash message extracted from stderr / last
// error log lines. Empty if the process is still running or exited cleanly.
// Prefer this over ExitErr() in user-facing surfaces — ExitErr only carries
// the Go cmd.Wait status (e.g. "exit status 1"), while ExitDetails carries
// the actual reason the binary printed before dying.
func (p *ManagedProcess) ExitDetails() string {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.exitDetails
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

// ProcessExitInfo is passed to the onExit callback when a process dies.
type ProcessExitInfo struct {
	Name     string
	ExitCode int
	ErrMsg   string // stderr-based error message, empty if clean exit
}

// StartupLogEntry is passed to the OnStartupLog callback when a process line
// matches one of the binary's startup_log_patterns. Used by the UI to show
// a timeline of startup progress messages.
type StartupLogEntry struct {
	Name      string
	Timestamp time.Time
	Message   string
}

// ProcessManager handles spawning, monitoring, and killing processes.
type ProcessManager struct {
	dataDir    string
	pidManager *PidFileManager
	log        zerolog.Logger

	// CoreVariant resolves the binary path for Bitcoin Core when set. If nil
	// (or it returns ok=false), the default flat BinaryPath is used.
	CoreVariant func(config BinaryConfig) (CoreVariantSpec, bool)

	// SidechainVariant resolves the on-disk binary name for layer-2 test
	// builds. ok=false means use the production BinaryName + flat BinaryPath.
	SidechainVariant func(config BinaryConfig) (sidechainVariantSpec, bool)

	mu         sync.Mutex
	processes  map[string]*ManagedProcess // keyed by config name
	lastExited map[string]*ManagedProcess // last exited process, keyed by config name — keeps its logs readable
	starting   map[string]bool            // names reserved by an in-flight StartWithOptions

	// OnExit is called when a process exits. The orchestrator uses this to
	// pipe exit errors into ConnectionMonitor.connectionError for the UI.
	OnExit func(ProcessExitInfo)

	// OnStartupLog is called when a process line matches one of the binary's
	// startup_log_patterns. The orchestrator pushes these to the UI so users
	// see a timeline of startup progress messages.
	// Dart: ProcessManager._captureStartupLog (process_manager.dart L380-395)
	OnStartupLog func(StartupLogEntry)
}

func NewProcessManager(dataDir string, pidManager *PidFileManager, log zerolog.Logger) *ProcessManager {
	return &ProcessManager{
		dataDir:    dataDir,
		pidManager: pidManager,
		log:        log.With().Str("component", "process").Logger(),
		processes:  make(map[string]*ManagedProcess),
		lastExited: make(map[string]*ManagedProcess),
		starting:   make(map[string]bool),
	}
}

// resolvePaths picks the on-disk binary path and PID-file name for a config,
// honouring whichever variant resolver is active. Test sidechain builds use
// a "<bin>-test" PID-file name so prod and test PID files don't collide and
// adopt-orphan can attribute them to the right config. If forceBackend is
// true, the SidechainVariant resolver is skipped — the caller wants the
// prod-download binary instead of the frontend build.
func (pm *ProcessManager) resolvePaths(config BinaryConfig, forceBackend bool) (binPath, pidName string) {
	binPath = BinaryPath(pm.dataDir, config.BinaryName)
	pidName = config.BinaryName

	if pm.CoreVariant != nil {
		if v, ok := pm.CoreVariant(config); ok {
			binPath = CoreBinaryPath(pm.dataDir, v, config.BinaryName)
			return binPath, pidName
		}
	}
	if !forceBackend && pm.SidechainVariant != nil {
		if sv, ok := pm.SidechainVariant(config); ok {
			binPath = TestSidechainBinaryPath(pm.dataDir, sv.BinaryName)
			pidName = sv.BinaryName + "-test"
			return binPath, pidName
		}
	}
	return binPath, pidName
}

// pidNameBinary strips the suffix that marks a GUI companion or a frontend
// build, leaving the executable name the process at that PID reports.
func pidNameBinary(pidName string) string {
	for _, suffix := range []string{"-gui", "-test"} {
		if strings.HasSuffix(pidName, suffix) {
			return strings.TrimSuffix(pidName, suffix)
		}
	}
	return pidName
}

// ProcessStartOptions tweaks process.Start behaviour per-call.
type ProcessStartOptions struct {
	// ForceBackend skips the SidechainVariant resolver so the prod-download
	// binary is launched instead of the frontend build. Set by sidechain
	// Flutter frontends self-booting their backend.
	ForceBackend bool

	// ProcessName overrides the in-memory process slot. Used for managed GUI
	// companions so they don't occupy the backend daemon's slot.
	ProcessName string

	// PidName overrides the PID-file name. Keep GUI companion PID files
	// distinct from backend/test-daemon PID files so orphan adoption cannot
	// confuse the frontend with the daemon.
	PidName string

	// WorkDir overrides the child process working directory. Flutter GUI
	// bundles expect to run beside their lib/data trees.
	WorkDir string
}

// Start launches a binary and returns its PID.
func (pm *ProcessManager) Start(ctx context.Context, config BinaryConfig, args []string, env map[string]string) (int, error) {
	return pm.StartWithOptions(ctx, config, args, env, ProcessStartOptions{})
}

// StartWithOptions is Start with per-call overrides (see ProcessStartOptions).
func (pm *ProcessManager) StartWithOptions(_ context.Context, config BinaryConfig, args []string, env map[string]string, opts ProcessStartOptions) (int, error) {
	processName := opts.ProcessName
	if processName == "" {
		processName = config.Name
	}

	// Reserve the slot under the lock that checks it, so concurrent starts
	// cannot both fork a daemon and have the second registration orphan the first.
	pm.mu.Lock()
	if _, exists := pm.processes[processName]; exists || pm.starting[processName] {
		pm.mu.Unlock()
		return 0, fmt.Errorf("%s is already running", processName)
	}
	pm.starting[processName] = true
	pm.mu.Unlock()
	defer func() {
		pm.mu.Lock()
		delete(pm.starting, processName)
		pm.mu.Unlock()
	}()

	binPath, pidName := pm.resolvePaths(config, opts.ForceBackend)
	if opts.PidName != "" {
		pidName = opts.PidName
	}
	if _, err := os.Stat(binPath); err != nil {
		return 0, fmt.Errorf("binary not found at %s: %w", binPath, err)
	}
	_ = pidName // referenced below for PID file ops

	if err := chmod(binPath); err != nil {
		pm.log.Warn().Err(err).Str("binary", processName).Msg("chmod")
	}

	// Raise file descriptor limit for child processes (bitcoind needs many)
	raiseOpenFilesLimit(pm.log)

	// Use background context so child processes survive beyond the RPC request.
	// The orchestrator manages process lifecycle via Stop/StopAll, not via context.
	cmd := exec.Command(binPath, args...)
	cmd.Dir = pm.dataDir
	if opts.WorkDir != "" {
		cmd.Dir = opts.WorkDir
	}

	// Set environment
	cmd.Env = os.Environ()
	for k, v := range env {
		cmd.Env = append(cmd.Env, k+"="+v)
	}

	configureProcessAttr(cmd)

	// Own the pipes rather than using cmd.StdoutPipe: cmd.Wait closes those the
	// moment the child exits, discarding whatever the readers hadn't drained yet.
	stdout, stdoutW, err := os.Pipe()
	if err != nil {
		return 0, fmt.Errorf("stdout pipe: %w", err)
	}
	stderr, stderrW, err := os.Pipe()
	if err != nil {
		stdout.Close()  //nolint:errcheck // cleanup
		stdoutW.Close() //nolint:errcheck // cleanup
		return 0, fmt.Errorf("stderr pipe: %w", err)
	}
	cmd.Stdout = stdoutW
	cmd.Stderr = stderrW

	startErr := cmd.Start()
	stdoutW.Close() //nolint:errcheck // cleanup
	stderrW.Close() //nolint:errcheck // cleanup
	if startErr != nil {
		stdout.Close() //nolint:errcheck // cleanup
		stderr.Close() //nolint:errcheck // cleanup
		return 0, fmt.Errorf("start %s: %w", processName, startErr)
	}

	runtimeConfig := config
	runtimeConfig.Name = processName
	proc := &ManagedProcess{
		Config:       runtimeConfig,
		Pid:          cmd.Process.Pid,
		Cmd:          cmd,
		BinPath:      binPath,
		PidName:      pidName,
		Started:      time.Now(),
		ForceBackend: opts.ForceBackend,
		logs:         make([]LogEntry, 0, 256),
		exitCh:       make(chan struct{}),
	}

	pm.mu.Lock()
	pm.processes[processName] = proc
	delete(pm.lastExited, processName)
	pm.mu.Unlock()

	// Write PID file
	if err := pm.pidManager.WritePidFile(pidName, cmd.Process.Pid); err != nil {
		pm.log.Warn().Err(err).Str("binary", processName).Msg("write PID file")
	}

	// Add startup marker
	proc.addLog(LogEntry{
		Timestamp: time.Now(),
		Stream:    "marker",
		Line:      fmt.Sprintf("=== %s started (pid %d) ===", processName, cmd.Process.Pid),
	})

	// Compile startup log patterns once for pattern-matching process output.
	// Dart: ProcessManager._captureStartupLog (process_manager.dart L380-395)
	startupLogPatterns := compileStartupPatterns(config.StartupLogPatterns, pm.log)

	// Stderr buffer: keep last 100 lines for error extraction on crash
	var stderrMu sync.Mutex
	var stderrBuffer []string

	// captureStartupLog checks if a line matches any startup pattern and
	// forwards it to the OnStartupLog callback for UI display.
	captureStartupLog := func(line string) {
		if len(startupLogPatterns) == 0 || pm.OnStartupLog == nil {
			return
		}
		for _, re := range startupLogPatterns {
			if re.MatchString(line) {
				pm.OnStartupLog(StartupLogEntry{
					Name:      processName,
					Timestamp: extractLogTimestamp(line),
					Message:   cleanLogMessage(line),
				})
				return
			}
		}
	}

	// Capture stdout
	stdoutDone := make(chan struct{})
	go func() {
		defer close(stdoutDone)
		defer stdout.Close() //nolint:errcheck // cleanup
		scanner := bufio.NewScanner(stdout)
		scanner.Buffer(make([]byte, 1024*1024), 1024*1024)
		for scanner.Scan() {
			line := stripANSI(scanner.Text())
			if isSpam(line) {
				continue
			}
			proc.addLog(LogEntry{
				Timestamp: time.Now(),
				Stream:    "stdout",
				Line:      line,
			})
			captureStartupLog(line)
		}
	}()

	// Capture stderr
	stderrDone := make(chan struct{})
	go func() {
		defer close(stderrDone)
		defer stderr.Close() //nolint:errcheck // cleanup
		scanner := bufio.NewScanner(stderr)
		scanner.Buffer(make([]byte, 1024*1024), 1024*1024)
		for scanner.Scan() {
			line := stripANSI(scanner.Text())
			if isSpam(line) {
				continue
			}
			proc.addLog(LogEntry{
				Timestamp: time.Now(),
				Stream:    "stderr",
				Line:      line,
			})
			captureStartupLog(line)
			// Buffer stderr for error extraction
			stderrMu.Lock()
			stderrBuffer = append(stderrBuffer, line)
			if len(stderrBuffer) > 100 {
				stderrBuffer = stderrBuffer[len(stderrBuffer)-100:]
			}
			stderrMu.Unlock()
		}
	}()

	// Wait for exit in background
	go func() {
		err := cmd.Wait()

		// A descendant that inherited the pipes keeps the readers blocked past the
		// child's exit, so closing them is what bounds the drain.
		drain := time.AfterFunc(2*time.Second, func() {
			stdout.Close() //nolint:errcheck // cleanup
			stderr.Close() //nolint:errcheck // cleanup
			pm.log.Warn().Str("binary", processName).Msg("timed out waiting for output to drain")
		})
		<-stdoutDone
		<-stderrDone
		drain.Stop()

		proc.mu.Lock()
		if err != nil {
			proc.exitErr = err.Error()
		}
		if cmd.ProcessState != nil {
			proc.exitCode = cmd.ProcessState.ExitCode()
		}
		exitCode := proc.exitCode
		proc.mu.Unlock()

		// Build error message from stderr, falling back to last stdout lines.
		// Many binaries (enforcer, sidechains) log errors to stdout via structured
		// loggers, so stderr may be empty even on crash.
		var errMsg string
		if exitCode != 0 {
			stderrMu.Lock()
			if len(stderrBuffer) > 0 {
				errMsg = strings.Join(stderrBuffer, "\n")
			}
			stderrMu.Unlock()

			// Fallback: use last few log lines if stderr was empty.
			// Look for ERROR/WARN/fatal lines first, then fall back to last line.
			if errMsg == "" {
				recentLogs := proc.RecentLogs(50)
				var errorLines []string
				var lastLine string
				for _, l := range recentLogs {
					lastLine = l.Line
					lower := strings.ToLower(l.Line)
					if strings.Contains(lower, "error") || strings.Contains(lower, "fatal") || strings.Contains(lower, "panic") {
						errorLines = append(errorLines, l.Line)
					}
				}
				if len(errorLines) > 0 {
					// Take last 5 error lines max
					if len(errorLines) > 5 {
						errorLines = errorLines[len(errorLines)-5:]
					}
					errMsg = strings.Join(errorLines, "\n")
				} else if lastLine != "" {
					errMsg = lastLine
				}
			}

			if errMsg == "" {
				errMsg = fmt.Sprintf("process exited with code %d", exitCode)
			}

			// Stash the rich crash reason so callers like
			// waitForConnectedOrExit can return the actual error to the
			// frontend instead of overwriting it with the bare cmd.Wait
			// status ("exit status 1").
			proc.mu.Lock()
			proc.exitDetails = errMsg
			proc.mu.Unlock()
		}

		// Add exit marker (like Dart's addExitMarker)
		proc.addLog(LogEntry{
			Timestamp: time.Now(),
			Stream:    "marker",
			Line:      fmt.Sprintf("=== %s exited (code %d) ===", processName, exitCode),
		})

		pm.mu.Lock()
		delete(pm.processes, processName)
		pm.lastExited[processName] = proc
		pm.mu.Unlock()

		_ = pm.pidManager.DeletePidFile(pidName)

		pm.log.Info().
			Str("binary", processName).
			Int("pid", proc.Pid).
			Int("exit_code", exitCode).
			Msg("process exited")

		// Closed last so a waiter sees the drained logs and the recorded exit.
		close(proc.exitCh)

		// Notify the orchestrator so it can update ConnectionMonitor
		if pm.OnExit != nil {
			pm.OnExit(ProcessExitInfo{
				Name:     processName,
				ExitCode: exitCode,
				ErrMsg:   errMsg,
			})
		}
	}()

	pm.log.Info().
		Str("binary", processName).
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

		errMsg := fmt.Sprintf("%s exited immediately (code %d)", processName, exitCode)
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

func (pm *ProcessManager) Stop(_ context.Context, name string, force bool) error {
	pm.mu.Lock()
	proc, exists := pm.processes[name]
	pm.mu.Unlock()

	if !exists {
		return fmt.Errorf("%s is not running", name)
	}

	// An adopted PID came off disk, and the OS reuses PID numbers. Re-read the
	// name before signalling, so a stranger that took the number is dropped
	// rather than killed.
	if proc.Adopted {
		binary := pidNameBinary(proc.PidName)
		if !pm.pidManager.ValidatePid(proc.Pid, binary) {
			pm.forget(name, proc)
			_ = pm.pidManager.DeletePidFile(proc.PidName)
			return fmt.Errorf("stop %s: pid %d is no longer %s", name, proc.Pid, binary)
		}
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

	select {
	case <-proc.exitCh:
		return nil
	case <-time.After(gracefulKillTimeout):
		pm.log.Warn().
			Str("binary", name).
			Dur("timeout", gracefulKillTimeout).
			Msg("graceful shutdown timed out, force killing")
		return forceKillProcess(proc.Pid)
	}
}

func (pm *ProcessManager) WaitForExit(name string, timeout time.Duration) bool {
	pm.mu.Lock()
	proc, exists := pm.processes[name]
	pm.mu.Unlock()

	if !exists {
		return true
	}

	select {
	case <-proc.exitCh:
		return true
	case <-time.After(timeout):
		return false
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

// LastExit returns the exit code of a binary's most recent run. ok is false
// once the binary starts again, and for binaries that never ran.
func (pm *ProcessManager) LastExit(name string) (int, bool) {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	proc, ok := pm.lastExited[name]
	if !ok {
		return 0, false
	}
	return proc.ExitCode(), true
}

// LatestRun returns the running process, or the last exited one when it is
// gone, so crash handlers can still read the logs it died with.
func (pm *ProcessManager) LatestRun(name string) *ManagedProcess {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	if proc, ok := pm.processes[name]; ok {
		return proc
	}
	return pm.lastExited[name]
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
	binPath, pidName := pm.resolvePaths(config, false)
	pm.AdoptProcessResolved(config, pid, binPath, pidName, false)
}

// AdoptProcessWithOptions registers an externally-found process using the
// same path resolution overrides as StartWithOptions.
func (pm *ProcessManager) AdoptProcessWithOptions(config BinaryConfig, pid int, opts ProcessStartOptions) {
	binPath, pidName := pm.resolvePaths(config, opts.ForceBackend)
	pm.AdoptProcessResolved(config, pid, binPath, pidName, opts.ForceBackend)
}

// AdoptProcessResolved registers an externally-found process when the PID file
// name already tells us which on-disk variant it belongs to.
func (pm *ProcessManager) AdoptProcessResolved(config BinaryConfig, pid int, binPath, pidName string, forceBackend bool) {
	// PID discovery returns 0 when every lookup misses. Claiming ownership of a
	// process we cannot signal makes Stop report success without stopping it.
	if pid <= 0 {
		pm.log.Warn().Str("binary", config.Name).Int("pid", pid).Msg("refusing to adopt process with invalid pid")
		return
	}

	pm.mu.Lock()
	defer pm.mu.Unlock()

	if _, exists := pm.processes[config.Name]; exists {
		return
	}

	orphan := pm.startedInAnEarlierRun(pidName, pid)

	delete(pm.lastExited, config.Name)
	pm.processes[config.Name] = &ManagedProcess{
		Config:       config,
		Pid:          pid,
		BinPath:      binPath,
		PidName:      pidName,
		Started:      time.Now(),
		Adopted:      true,
		Orphan:       orphan,
		ForceBackend: forceBackend,
		logs:         make([]LogEntry, 0),
		exitCh:       make(chan struct{}),
	}

	pm.log.Info().Str("binary", config.Name).Int("pid", pid).Msg("adopted orphaned process")

	go pm.watchAdopted(config.Name, pm.processes[config.Name])
}

const adoptedPollInterval = time.Second

// watchAdopted closes the exit channel of an adopted process once it dies.
// Only a parent gets word of a child's exit, so an adopted PID needs a poll.
func (pm *ProcessManager) watchAdopted(name string, proc *ManagedProcess) {
	for {
		time.Sleep(adoptedPollInterval)

		pm.mu.Lock()
		tracked := pm.processes[name] == proc
		pm.mu.Unlock()
		if !tracked {
			return
		}

		if isPidAlive(proc.Pid) {
			continue
		}

		pm.mu.Lock()
		if pm.processes[name] != proc {
			pm.mu.Unlock()
			return
		}
		delete(pm.processes, name)
		pm.lastExited[name] = proc
		pm.mu.Unlock()

		_ = pm.pidManager.DeletePidFile(proc.PidName)
		pm.log.Info().Str("binary", name).Int("pid", proc.Pid).Msg("adopted process exited")
		close(proc.exitCh)
		return
	}
}

// pidRecordSkew covers the gap between a process start and the PID record this
// install writes for it, plus the one-second resolution of a process age.
const pidRecordSkew = 5 * time.Second

// startedInAnEarlierRun reports whether a run of this install started the
// process at pid. The PID record must name it, and the process must be older
// than that record. A stranger that later took the same number is younger, so
// the age is what a bare PID match cannot prove.
func (pm *ProcessManager) startedInAnEarlierRun(pidName string, pid int) bool {
	recorded, err := pm.pidManager.ReadPidFile(pidName)
	if err != nil || recorded != pid {
		return false
	}

	written, err := pm.pidManager.RecordTime(pidName)
	if err != nil {
		pm.log.Warn().Err(err).Str("binary", pidName).Msg("read the PID record time")
		return false
	}

	age, err := processAge(pid)
	if err != nil {
		pm.log.Warn().Err(err).Int("pid", pid).Msg("read the process age")
		return false
	}

	return time.Since(written) <= age+pidRecordSkew
}

// IsOrphan reports whether a previous run of this install started the named
// process and left it behind. False for a process somebody else launched
// against the same data directory.
func (pm *ProcessManager) IsOrphan(name string) bool {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	p, exists := pm.processes[name]
	return exists && p.Orphan
}

// IsAdopted returns true if the named process was adopted (not started by us).
func (pm *ProcessManager) IsAdopted(name string) bool {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	p, exists := pm.processes[name]
	return exists && p.Adopted
}

// ForceBackendFor returns the ForceBackend flag the named process was started
// with. False when the process is unknown — same default as a fresh StartOpts.
func (pm *ProcessManager) ForceBackendFor(name string) bool {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	p, exists := pm.processes[name]
	return exists && p.ForceBackend
}

// Remove removes a process from tracking without stopping it.
// Used for adopted processes that we don't own.
func (pm *ProcessManager) Remove(name string) {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	delete(pm.processes, name)
}

// forget drops a registration that turned out to name somebody else's process
// and releases whoever waits on it. A no-op once watchAdopted got there first.
func (pm *ProcessManager) forget(name string, proc *ManagedProcess) {
	pm.mu.Lock()
	won := pm.processes[name] == proc
	if won {
		delete(pm.processes, name)
	}
	pm.mu.Unlock()

	if won {
		close(proc.exitCh)
	}
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

// compileStartupPatterns compiles the startup_log_patterns from chains_config.json.
// Invalid patterns are logged and skipped.
func compileStartupPatterns(patterns []string, log zerolog.Logger) []*regexp.Regexp {
	compiled := make([]*regexp.Regexp, 0, len(patterns))
	for _, p := range patterns {
		re, err := regexp.Compile(p)
		if err != nil {
			log.Warn().Err(err).Str("pattern", p).Msg("invalid startup log pattern")
			continue
		}
		compiled = append(compiled, re)
	}
	return compiled
}

// extractLogTimestamp extracts a timestamp from common log formats, falling
// back to time.Now() if none is found.
// Dart: ProcessManager._extractTimestamp (process_manager.dart L397-409)
var timestampPattern = regexp.MustCompile(`(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)`)

func extractLogTimestamp(line string) time.Time {
	if match := timestampPattern.FindString(line); match != "" {
		if t, err := time.Parse(time.RFC3339, match); err == nil {
			return t
		}
	}
	return time.Now()
}

// cleanLogMessage strips timestamp prefix and ANSI codes from a log line.
// Dart: ProcessManager._cleanMessage (process_manager.dart L411-419)
var timestampPrefixPattern = regexp.MustCompile(`^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\s*`)

func cleanLogMessage(line string) string {
	cleaned := timestampPrefixPattern.ReplaceAllString(line, "")
	return strings.TrimSpace(stripANSI(cleaned))
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

// RecordTime returns when this install wrote the PID record for a binary.
func (m *PidFileManager) RecordTime(binaryName string) (time.Time, error) {
	info, err := os.Stat(m.pidPath(binaryName))
	if err != nil {
		return time.Time{}, fmt.Errorf("stat the PID file for %s: %w", binaryName, err)
	}
	return info.ModTime(), nil
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

// commMaxLen is the length Linux truncates a process name to (TASK_COMM_LEN-1).
const commMaxLen = 15

// processNameMatches compares a name the OS reported against a binary name.
// macOS reports an executable path, Linux truncates the name to commMaxLen.
// Anything looser adopts a stranger: "thunder-orchard" answered for "thunder".
func processNameMatches(procName, binaryName string) bool {
	procLower := strings.ToLower(filepath.Base(procName))
	binLower := strings.ToLower(binaryName)

	if procLower == binLower {
		return true
	}
	return len(procLower) == commMaxLen && strings.HasPrefix(binLower, procLower)
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
