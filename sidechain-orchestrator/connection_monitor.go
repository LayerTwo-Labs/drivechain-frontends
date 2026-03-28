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

// extractStartupError checks if an error message is a -28 warmup error.
// Dart: RPCConnection.extractStartupError (rpc_connection.dart L398-415)
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
	isConnectModeOnly := m.connectModeOnly

	m.mu.Unlock()

	err := m.Checker.Check(ctx)

	m.mu.Lock()
	defer func() {
		m.testing = false
		m.mu.Unlock()
	}()

	// Dart L94-96: stop() was called while ping was in-flight — discard
	if m.pingEpoch != epochBefore {
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
		return
	}

	// Dart L119-124: in connect-mode-only, just stay clean disconnected
	if isConnectModeOnly {
		m.connected = false
		return
	}

	// Dart L165-174: log on state change
	if wasConnected {
		m.log.Info().Str("binary", m.Name).Err(err).Msg("connection lost")
	}

	m.connected = false
	errMsg := err.Error()

	// Dart L178-185: classify error as startup warmup vs real connection error
	// 1. Check for -28 warmup errors (extractStartupError)
	if extracted := extractStartupError(errMsg); extracted != "" {
		m.startupError = extracted
		return
	}

	// 2. Check for known startup patterns (Dart: startupErrors().any(...))
	for _, pattern := range m.startupPatterns {
		if strings.Contains(errMsg, pattern) {
			m.startupError = errMsg
			return
		}
	}

	// 3. Otherwise it's a real connection error
	m.connectionError = errMsg
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

	err := restartFunc(ctx)

	m.mu.Lock()
	m.initializingBinary = false

	if err != nil {
		m.log.Error().Str("binary", m.Name).Err(err).Msg("restart failed")
		m.mu.Unlock()
		return
	}

	// Dart L279-281: if connected after restart, reset count
	if m.connected {
		m.restartCount = 0
	}
	m.mu.Unlock()
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
	defer m.mu.Unlock()

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
	m.connectionError = ""
}

// MarkDisconnected marks the connection as disconnected without sending a stop.
// Dart: RPCConnection.markDisconnected() (rpc_connection.dart L387-396)
// Used when the binary has already been stopped externally.
func (m *ConnectionMonitor) MarkDisconnected() {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.log.Info().Str("binary", m.Name).Msg("marking as disconnected")
	m.connected = false
	m.stoppingBinary = false
	m.connectModeOnly = true // keep timer running, only look for new connections
	m.connectionError = ""
	// Dart L394: cancel restart timer
	if m.restartStop != nil && !m.restartDone {
		close(m.restartStop)
		m.restartDone = true
	}
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
