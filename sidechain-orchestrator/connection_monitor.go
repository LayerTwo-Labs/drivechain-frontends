package orchestrator

import (
	"context"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/rs/zerolog"
)

// ConnectionMonitor is a 1:1 Go port of Dart's RPCConnection (rpc_connection.dart).
//
// It manages:
//   - A persistent 1-second health-check timer (Dart: connectionTimer)
//   - A 500ms restart timer that auto-restarts crashed processes (Dart: restartTimer)
//   - connectModeOnly: after a willful stop, the timer keeps pinging to detect
//     externally started processes, but suppresses errors silently
//
// Dart equivalents:
//   - connectionTimer      → connectionTicker
//   - testConnection()     → testConnection()
//   - connectModeOnly      → connectModeOnly
//   - connected            → connected
//   - startConnectionTimer → StartConnectionTimer()
//   - restartTimer         → restartTicker
//   - startRestartTimer    → StartRestartTimer()
//   - stop()               → MarkStopped()
//   - markDisconnected()   → MarkDisconnected()
//   - _pingEpoch           → pingEpoch
type ConnectionMonitor struct {
	Name    string // binary config name (e.g. "bitcoind")
	Checker HealthChecker
	log     zerolog.Logger

	mu sync.Mutex

	// Dart: connected, connectionError, startupError
	connected       bool
	connectionError string
	startupError    string // warmup message (e.g. "Loading block index...")

	// Dart: startupErrors() — per-binary list of known startup messages
	// that mean "still booting, not an error"
	startupPatterns []string

	// Dart: connectModeOnly — after willful stop, timer keeps running but
	// only looks for new connections, suppresses errors silently
	connectModeOnly bool

	// Dart: _completedStartup — set to true on first successful connection
	completedStartup bool

	// Dart: _initializingBinary
	initializingBinary bool

	// Dart: stoppingBinary
	stoppingBinary bool

	// Dart: _pingEpoch — incremented in stop() so in-flight pings are discarded
	pingEpoch int

	// Dart: _testing — prevents concurrent testConnection calls
	testing bool

	// hasCrashError is set when SetConnectionError is called from a process exit.
	// Prevents the connection timer from overwriting the crash error with "connection refused".
	// Cleared on successful reconnection.
	hasCrashError bool

	// Dart: _restartCount — tracks restart attempts
	restartCount int

	// Timer control
	connectionStop chan struct{}
	restartStop    chan struct{}
	connectionDone bool
	restartDone    bool

	// Restart callback: called when the monitor detects a crashed process
	// that needs restarting. Returns nil on success or error message on failure.
	// Dart: bootProcess parameter in startRestartTimer
	restartFunc func(ctx context.Context) error

	// ExitedFunc: returns (exitCode, exited). Dart: BinaryProvider.exited(binary)
	exitedFunc func() (int, bool)

	// onChange is called whenever connection state changes. The orchestrator
	// uses this to notify watchBinaries subscribers immediately.
	onChange func()

	// startupLogs holds recent startup progress messages (like "Loading block index...")
	// that match the binary's startup_log_patterns. Streamed to the UI via watchBinaries.
	// Dart: Binary.startupLogs (binaries.dart)
	startupLogs []StartupLogLine
}

// StartupLogLine is a timestamped startup progress message.
type StartupLogLine struct {
	Timestamp time.Time
	Message   string
}

// Bitcoin Core startup messages that indicate "still booting, not an error".
// Dart: mainchain_rpc.dart L243-264
var bitcoindStartupPatterns = []string{
	"Loading block index",
	"Opening LevelDB",
	"Rewinding blocks",
	"Verifying blocks",
	"Loading block database",
	"Switching active chainstate",
	"Checking all blk files are present",
	"Pruning blockstore",
	"Loading block filter index",
	"Loading wallet",
	"Verifying wallet",
	"Rescanning",
	"Loading P2P addresses",
	"Loading banlist",
	"Starting network threads",
	"HTTP: starting",
	"Creating work queue",
	"RPC warming up",
	"Done loading",
}

// Enforcer startup messages.
// Dart: enforcer_rpc.dart L154-156
var enforcerStartupPatterns = []string{
	"Validator is not synced",
}

// NewConnectionMonitor creates a monitor for a binary.
// Does NOT start timers — call StartConnectionTimer() and StartRestartTimer().
func NewConnectionMonitor(name string, checker HealthChecker, startupPatterns []string, log zerolog.Logger) *ConnectionMonitor {
	return &ConnectionMonitor{
		Name:            name,
		Checker:         checker,
		startupPatterns: startupPatterns,
		log:             log.With().Str("monitor", name).Logger(),
	}
}

// AddStartupLog appends a startup progress message. Keeps the last 20.
// Dart: Binary.addStartupLog
func (m *ConnectionMonitor) AddStartupLog(ts time.Time, msg string) {
	m.mu.Lock()
	m.startupLogs = append(m.startupLogs, StartupLogLine{Timestamp: ts, Message: msg})
	if len(m.startupLogs) > 20 {
		m.startupLogs = m.startupLogs[len(m.startupLogs)-20:]
	}
	m.mu.Unlock()
	m.notifyChange()
}

// StartupLogs returns a copy of the recent startup progress messages.
func (m *ConnectionMonitor) StartupLogs() []StartupLogLine {
	m.mu.Lock()
	defer m.mu.Unlock()
	out := make([]StartupLogLine, len(m.startupLogs))
	copy(out, m.startupLogs)
	return out
}

// SetConnectionError sets the connection error from an external source (e.g. process crash).
// This is how process exit errors flow into the UI. The error "sticks" — it won't
// be overwritten by generic "connection refused" from the next health check ping.
// It's only cleared when the process reconnects successfully.
func (m *ConnectionMonitor) SetConnectionError(errMsg string) {
	m.mu.Lock()
	m.connected = false
	m.connectionError = errMsg
	m.startupError = ""
	m.hasCrashError = true
	m.mu.Unlock()
	m.notifyChange()
}

// SetOnChange sets the callback fired whenever connection state changes.
func (m *ConnectionMonitor) SetOnChange(fn func()) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.onChange = fn
}

// notifyChange fires the onChange callback if set. Must NOT hold mu.
func (m *ConnectionMonitor) notifyChange() {
	m.mu.Lock()
	fn := m.onChange
	m.mu.Unlock()
	if fn != nil {
		fn()
	}
}

// Connected returns the current connection state.
// Dart: RPCConnection.connected
func (m *ConnectionMonitor) Connected() bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.connected
}

// ConnectionError returns the last connection error (empty if connected).
func (m *ConnectionMonitor) ConnectionError() string {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.connectionError
}

// StartupError returns the current startup/warmup message (e.g. "Loading block index...").
// Dart: RPCConnection.startupError
func (m *ConnectionMonitor) StartupError() string {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.startupError
}

// StoppingBinary returns whether the binary is currently being stopped.
func (m *ConnectionMonitor) StoppingBinary() bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.stoppingBinary
}

// InitializingBinary returns whether the binary is currently starting up.
func (m *ConnectionMonitor) InitializingBinary() bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.initializingBinary
}

// SetInitializing flips the initializing flag and fires onChange so the
// frontend sees the transition immediately (before the next 1s ping).
// Orchestrator calls this around process.Start so the UI shows an "initializing"
// spinner instead of a red X during the fresh-boot window where testConnection
// is still failing.
func (m *ConnectionMonitor) SetInitializing(v bool) {
	m.mu.Lock()
	if m.initializingBinary == v {
		m.mu.Unlock()
		return
	}
	m.initializingBinary = v
	m.mu.Unlock()
	m.notifyChange()
}

// ConnectModeOnly returns whether the monitor is in connect-mode-only
// (willfully stopped, only watching for external restart).
func (m *ConnectionMonitor) ConnectModeOnly() bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.connectModeOnly
}

// extractStartupError checks if an error message is a -28 warmup error.
// Dart: RPCConnection.extractStartupError (rpc_connection.dart L398-415)
// isTransientConnectError reports whether the error is a generic connection
// failure that should not overwrite the previous error state.
// Dart: rpc_connection.dart L148-157
func isTransientConnectError(errMsg string) bool {
	patterns := []string{
		"Connection refused",
		"connection refused",
		"SocketException",
		"computer refused the network",
		"Unknown Error",
		"could not connect at",
		"forcefully terminated",
	}
	for _, p := range patterns {
		if strings.Contains(errMsg, p) {
			return true
		}
	}
	return false
}

func extractStartupError(errMsg string) string {
	if !strings.Contains(errMsg, "-28") {
		return ""
	}
	// Error like: "getblockcount([]): -28 - Loading block index…"
	// Extract everything after the last " - "
	idx := strings.LastIndex(errMsg, " - ")
	if idx != -1 && idx+3 < len(errMsg) {
		return strings.TrimSpace(errMsg[idx+3:])
	}
	return strings.TrimSpace(errMsg)
}

// testConnection pings the binary and updates state.
// Dart: RPCConnection.testConnection() (rpc_connection.dart L82-195)
func (m *ConnectionMonitor) testConnection(ctx context.Context) {
	m.mu.Lock()

	// Dart L84-86: prevent concurrent calls
	if m.testing {
		m.mu.Unlock()
		return
	}
	m.testing = true
	epochBefore := m.pingEpoch
	wasConnected := m.connected
	oldConnErr := m.connectionError
	oldStartupErr := m.startupError
	isConnectModeOnly := m.connectModeOnly

	m.mu.Unlock()

	err := m.Checker.Check(ctx)

	m.mu.Lock()

	// Dart L94-96: stop() was called while ping was in-flight — discard
	if m.pingEpoch != epochBefore {
		m.testing = false
		m.mu.Unlock()
		return
	}

	if err == nil {
		// Dart L99: successful ping → exit connect-mode-only
		m.connectModeOnly = false

		if !wasConnected || m.connectionError != "" {
			// Dart L101-106: we were previously disconnected
			m.log.Info().Str("binary", m.Name).Msg("connection established")
		}

		// Dart L107-111
		m.connected = true
		m.connectionError = ""
		m.startupError = ""
		m.completedStartup = true
		m.restartCount = 0
		m.hasCrashError = false // clear crash error on successful reconnection
		m.initializingBinary = false
	} else if isConnectModeOnly {
		// Dart L119-124: in connect-mode-only, just stay clean disconnected
		m.connected = false
	} else {
		// Dart L165-174: log on state change
		if wasConnected {
			m.log.Info().Str("binary", m.Name).Err(err).Msg("connection lost")
		}

		m.connected = false

		// If we have a crash error from process exit, don't overwrite it with
		// generic "connection refused" from the health check.
		if !m.hasCrashError {
			errMsg := err.Error()

			// Dart L148-157: filter noisy transient errors.
			// Don't show generic "Connection refused" repeatedly, or when stopping.
			// Keep the previous error state instead.
			if !m.stoppingBinary && !isTransientConnectError(errMsg) {
				// Dart L178-185: classify error as startup warmup vs real connection error
				if extracted := extractStartupError(errMsg); extracted != "" {
					m.startupError = extracted
				} else {
					matched := false
					for _, pattern := range m.startupPatterns {
						if strings.Contains(errMsg, pattern) {
							m.startupError = errMsg
							matched = true
							break
						}
					}
					if !matched {
						m.connectionError = errMsg
					}
				}
			}
		}
	}

	changed := m.connected != wasConnected || m.connectionError != oldConnErr || m.startupError != oldStartupErr
	m.testing = false
	m.mu.Unlock()

	if changed {
		m.notifyChange()
	}
}

// StartConnectionTimer starts the 1-second periodic health check.
// Dart: RPCConnection.startConnectionTimer() (rpc_connection.dart L299-319)
//
// 1. Pings once immediately
// 2. Starts a 1-second periodic timer
//
// Returns after the first ping completes (so caller knows if already connected).
func (m *ConnectionMonitor) StartConnectionTimer(ctx context.Context) {
	m.mu.Lock()
	// Cancel any existing timer
	if m.connectionStop != nil && !m.connectionDone {
		close(m.connectionStop)
	}
	m.connectionStop = make(chan struct{})
	m.connectionDone = false
	stopCh := m.connectionStop
	m.mu.Unlock()

	// Dart L307: immediate first ping
	m.log.Info().Str("binary", m.Name).Msg("checking connection")
	m.testConnection(ctx)

	if m.Connected() {
		m.log.Info().Str("binary", m.Name).Msg("already running")
	} else {
		m.log.Info().Str("binary", m.Name).Str("error", m.ConnectionError()).Msg("could not connect")
	}

	// Dart L317: start 1-second periodic timer
	m.log.Info().Str("binary", m.Name).Msg("starting connection timer")
	go func() {
		ticker := time.NewTicker(1 * time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-stopCh:
				return
			case <-ctx.Done():
				return
			case <-ticker.C:
				m.testConnection(ctx)
			}
		}
	}()
}

// StartRestartTimer starts the 500ms restart timer that auto-restarts crashed processes.
// Dart: RPCConnection.startRestartTimer() (rpc_connection.dart L236-286)
//
// Only call this if we STARTED the process ourselves (not for adopted processes).
// Dart: "only start restart timer if this process starts the binary!"
func (m *ConnectionMonitor) StartRestartTimer(ctx context.Context, restartFunc func(ctx context.Context) error, exitedFunc func() (int, bool)) {
	m.mu.Lock()
	m.restartFunc = restartFunc
	m.exitedFunc = exitedFunc

	// Cancel any existing timer
	if m.restartStop != nil && !m.restartDone {
		close(m.restartStop)
	}
	m.restartStop = make(chan struct{})
	m.restartDone = false
	stopCh := m.restartStop
	m.mu.Unlock()

	go func() {
		// Dart L245: Timer.periodic(Duration(milliseconds: 500))
		ticker := time.NewTicker(500 * time.Millisecond)
		defer ticker.Stop()

		for {
			select {
			case <-stopCh:
				return
			case <-ctx.Done():
				return
			case <-ticker.C:
				m.checkAndRestart(ctx)
			}
		}
	}()
}

// checkAndRestart is called every 500ms by the restart timer.
// Dart: the body of the Timer.periodic callback in startRestartTimer (L246-284)
func (m *ConnectionMonitor) checkAndRestart(ctx context.Context) {
	m.mu.Lock()

	// Dart L246: restartOnFailure && (_completedStartup || restartOnInitialFailure)
	// In Go orchestrator, we always want restart behavior after first startup
	if !m.completedStartup {
		m.mu.Unlock()
		return
	}

	// Dart L247-249: still going from the last loop
	if m.initializingBinary {
		m.mu.Unlock()
		return
	}

	// Dart L252-254: we're currently stopping manually
	if m.stoppingBinary {
		m.mu.Unlock()
		return
	}

	// Dart L270-273: we're not connected yet, but in a startup phase!
	// Don't retry then — binary is booting, not crashed.
	if m.startupError != "" {
		m.mu.Unlock()
		return
	}

	// Dart L262-264: too many restarts, give up
	if m.restartCount > 10 {
		m.mu.Unlock()
		return
	}

	// Dart L267-269: we're connected, no need to restart
	if m.connected {
		m.mu.Unlock()
		return
	}

	exitedFunc := m.exitedFunc
	restartFunc := m.restartFunc
	m.mu.Unlock()

	if exitedFunc == nil || restartFunc == nil {
		return
	}

	// Dart L272-273: check if process exited with non-zero code
	exitCode, exited := exitedFunc()
	if !exited || exitCode == 0 {
		return
	}

	// Dart L275-278: process exited unexpectedly, restart it
	m.log.Warn().Str("binary", m.Name).Int("exit_code", exitCode).Msg("process exited unexpectedly, restarting...")

	m.mu.Lock()
	m.restartCount++
	m.initializingBinary = true
	m.mu.Unlock()

	m.notifyChange()

	err := restartFunc(ctx)

	m.mu.Lock()
	m.initializingBinary = false

	if err != nil {
		m.log.Error().Str("binary", m.Name).Err(err).Msg("restart failed")
		m.mu.Unlock()
		m.notifyChange()
		return
	}

	// Dart L279-281: if connected after restart, reset count
	if m.connected {
		m.restartCount = 0
	}
	m.mu.Unlock()
	m.notifyChange()
}

// StopConnectionTimer stops the periodic health check timer.
func (m *ConnectionMonitor) StopConnectionTimer() {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.connectionStop != nil && !m.connectionDone {
		close(m.connectionStop)
		m.connectionDone = true
	}
}

// StopRestartTimer stops the restart timer.
// Dart: restartTimer?.cancel() in stop()
func (m *ConnectionMonitor) StopRestartTimer() {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.restartStop != nil && !m.restartDone {
		close(m.restartStop)
		m.restartDone = true
	}
}

// StopAllTimers stops both timers.
func (m *ConnectionMonitor) StopAllTimers() {
	m.StopConnectionTimer()
	m.StopRestartTimer()
}

// MarkStopped marks the connection as stopped.
// Dart: RPCConnection.stop() (rpc_connection.dart L356-383)
// Timer keeps running in connect-mode-only: it keeps pinging to detect
// externally started processes but suppresses errors silently.
func (m *ConnectionMonitor) MarkStopped() {
	m.mu.Lock()

	// Dart L359: invalidate any in-flight ping
	m.pingEpoch++
	// Dart L360: timer keeps running, but only looks for new connections
	m.connectModeOnly = true
	m.stoppingBinary = true
	// Dart L362: cancel restart timer
	if m.restartStop != nil && !m.restartDone {
		close(m.restartStop)
		m.restartDone = true
	}

	// Dart L371-378: cleanup
	m.connected = false
	m.stoppingBinary = false
	m.initializingBinary = false
	m.connectionError = ""
	m.startupError = ""
	m.hasCrashError = false
	m.startupLogs = nil
	m.mu.Unlock()

	m.notifyChange()
}

// MarkDisconnected marks the connection as disconnected without sending a stop.
// Dart: RPCConnection.markDisconnected() (rpc_connection.dart L387-396)
// Used when the binary has already been stopped externally.
func (m *ConnectionMonitor) MarkDisconnected() {
	m.mu.Lock()

	m.log.Info().Str("binary", m.Name).Msg("marking as disconnected")
	m.connected = false
	m.stoppingBinary = false
	m.connectModeOnly = true // keep timer running, only look for new connections
	m.connectionError = ""
	m.startupError = ""
	m.hasCrashError = false
	// Dart L394: cancel restart timer
	if m.restartStop != nil && !m.restartDone {
		close(m.restartStop)
		m.restartDone = true
	}
	m.mu.Unlock()

	m.notifyChange()
}

// WaitForConnected blocks until connected or context is cancelled.
// Dart: RPCConnection.waitForConnected() (rpc_connection.dart L293-296)
func (m *ConnectionMonitor) WaitForConnected(ctx context.Context) error {
	for {
		if m.Connected() {
			return nil
		}
		select {
		case <-ctx.Done():
			return fmt.Errorf("wait for %s: %w", m.Name, ctx.Err())
		case <-time.After(100 * time.Millisecond):
		}
	}
}
