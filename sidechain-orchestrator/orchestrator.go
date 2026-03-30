package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

// BinaryStatus represents the current state of a managed binary.
type BinaryStatus struct {
	Name            string
	DisplayName     string
	Running         bool
	Healthy         bool
	Pid             int
	Uptime          time.Duration
	ChainLayer      int
	Port            int
	Error           string
	Connected       bool   // from ConnectionMonitor
	StartupError    string // warmup message (e.g. "Loading block index...")
	ConnectionError string // real connection error
	Stopping        bool   // binary is being stopped
	Initializing    bool   // binary is starting up / restarting
	ConnectModeOnly bool   // willfully stopped, only watching for external restart
	Downloadable    bool   // binary has download URLs configured
	Description     string // short description of the binary
	Downloaded      bool   // binary file exists on disk
	PortInUse       bool   // port is reachable (something is listening)
}

// StartupProgress reports progress during StartWithDeps.
type StartupProgress struct {
	Stage           string // e.g. "downloading-bitcoind", "starting-bitcoind", "waiting-ibd"
	Message         string
	Done            bool
	Error           error
	BytesDownloaded int64
	TotalBytes      int64
}

// ShutdownProgress reports progress during ShutdownAll.
type ShutdownProgress struct {
	TotalCount    int
	CompletedCount int
	CurrentBinary string
	Done          bool
	Error         error
}

// StartOpts configures a StartWithDeps call.
type StartOpts struct {
	TargetArgs   []string
	TargetEnv    map[string]string
	CoreArgs     []string
	EnforcerArgs []string
	Immediate    bool // start target without waiting for L1
}

// Orchestrator coordinates binary download, process management, and health checking.
type Orchestrator struct {
	DataDir      string
	Network      string
	BitwindowDir string

	BitcoinConf  *config.BitcoinConfManager
	EnforcerConf *config.EnforcerConfManager
	WalletSvc    *wallet.Service // for seed injection into sidechain/enforcer args

	configs    map[string]BinaryConfig
	download   *DownloadManager
	process    *ProcessManager
	pidManager *PidFileManager
	log        zerolog.Logger

	// Dart: RPCConnection instances — one per binary, for persistent health monitoring
	monitors   map[string]*ConnectionMonitor
	monitorsMu sync.Mutex

	mu sync.RWMutex

	cachedBTCPrice    float64
	cachedPriceTime   time.Time
	priceMu           sync.Mutex
}

// New creates a new Orchestrator.
func New(dataDir, network, bitwindowDir string, configs []BinaryConfig, log zerolog.Logger) *Orchestrator {
	pidMgr := NewPidFileManager(dataDir, log)

	orch := &Orchestrator{
		DataDir:      dataDir,
		Network:      network,
		BitwindowDir: bitwindowDir,
		configs:      lo.SliceToMap(configs, func(c BinaryConfig) (string, BinaryConfig) { return c.Name, c }),
		download:     NewDownloadManager(dataDir, ConfigFilePath(bitwindowDir), log),
		process:      NewProcessManager(dataDir, pidMgr, log),
		pidManager:   pidMgr,
		monitors:     make(map[string]*ConnectionMonitor),
		log:          log.With().Str("component", "orchestrator").Logger(),
	}

	// Initialize config managers for auto-building args
	bitcoinConf, err := config.NewBitcoinConfManager(bitwindowDir, log)
	if err != nil {
		log.Warn().Err(err).Msg("failed to initialize bitcoin config manager, args must be passed explicitly")
	} else {
		orch.BitcoinConf = bitcoinConf

		enforcerConf, err := config.NewEnforcerConfManager(bitcoinConf, log)
		if err != nil {
			log.Warn().Err(err).Msg("failed to initialize enforcer config manager, args must be passed explicitly")
		} else {
			orch.EnforcerConf = enforcerConf
		}
	}

	return orch
}

// getOrCreateMonitor returns the ConnectionMonitor for a binary, creating one if needed.
// Dart: each RPCConnection has its own connection timer + state.
func (o *Orchestrator) getOrCreateMonitor(name string, checker HealthChecker, startupPatterns []string) *ConnectionMonitor {
	o.monitorsMu.Lock()
	defer o.monitorsMu.Unlock()

	if mon, ok := o.monitors[name]; ok {
		return mon
	}

	mon := NewConnectionMonitor(name, checker, startupPatterns, o.log)
	o.monitors[name] = mon
	return mon
}

// StopAllMonitors stops all connection monitor timers.
func (o *Orchestrator) StopAllMonitors() {
	o.monitorsMu.Lock()
	defer o.monitorsMu.Unlock()

	for _, mon := range o.monitors {
		mon.StopAllTimers()
	}
}

// discoverPid attempts to find the real PID of an externally-running process.
// Dart: PidFileManager.readPidFile with fallback to BitcoinCorePidTracker/pgrep.
//
// Strategy:
//  1. Check bitwindow's PID directory (the primary app may have written it)
//  2. Check the native bitcoind.pid in Bitcoin Core's datadir
//  3. Fall back to pgrep by binary name
func (o *Orchestrator) discoverPid(cfg BinaryConfig) int {
	// 1. Check bitwindow's PID directory
	// Dart: PidFileManager stores at {appDir}/pids/{binaryName}.pid
	if o.BitwindowDir != "" {
		bitwindowPidMgr := NewPidFileManager(o.BitwindowDir, o.log)
		pid, err := bitwindowPidMgr.ReadPidFile(cfg.BinaryName)
		if err == nil && pid > 0 {
			if o.pidManager.ValidatePid(pid, cfg.BinaryName) {
				o.log.Info().Str("binary", cfg.Name).Int("pid", pid).Msg("found PID from bitwindow PID directory")
				return pid
			}
		}
	}

	// 2. For Bitcoin Core: check native bitcoind.pid in datadir
	// Dart: BitcoinCorePidTracker watches {datadir}/{network}/bitcoind.pid
	if cfg.Name == "bitcoind" && o.BitcoinConf != nil {
		// Build path: {datadir}/{network-subdir}/bitcoind.pid
		dataDir := o.BitcoinConf.DetectedDataDir
		if dataDir == "" {
			dataDir = config.BitcoinCoreDirs.RootDirNetwork(o.BitcoinConf.Network)
		}
		networkSubdir := config.CoreSectionForNetwork(o.BitcoinConf.Network)
		pidPath := ""
		if networkSubdir == "main" {
			pidPath = dataDir + "/bitcoind.pid"
		} else {
			pidPath = dataDir + "/" + networkSubdir + "/bitcoind.pid"
		}

		if data, err := os.ReadFile(pidPath); err == nil {
			if pid, err := strconv.Atoi(strings.TrimSpace(string(data))); err == nil && pid > 0 {
				if isPidAlive(pid) {
					o.log.Info().Str("binary", cfg.Name).Int("pid", pid).Str("path", pidPath).Msg("found PID from native bitcoind.pid")
					return pid
				}
			}
		}
	}

	// 3. Fall back to pgrep
	pid, err := findPidByName(cfg.BinaryName)
	if err == nil && pid > 0 {
		o.log.Info().Str("binary", cfg.Name).Int("pid", pid).Msg("found PID via pgrep")
		return pid
	}

	return 0
}

// UpdateConfigs replaces the binary configs with new ones (e.g. from a reloaded JSON file).
// Preserves Go-specific runtime state (running processes, health checks).
func (o *Orchestrator) UpdateConfigs(configs []BinaryConfig) {
	o.mu.Lock()
	defer o.mu.Unlock()
	for _, c := range configs {
		o.configs[c.Name] = c
	}
}

// Download downloads a binary if missing (or forces re-download).
func (o *Orchestrator) Download(ctx context.Context, name string, force bool) (<-chan DownloadProgress, error) {
	config, err := o.getConfig(name)
	if err != nil {
		return nil, err
	}
	return o.download.Download(ctx, config, o.Network, force)
}

// Start starts a binary with the given args and env.
func (o *Orchestrator) Start(ctx context.Context, name string, args []string, env map[string]string) (int, error) {
	config, err := o.getConfig(name)
	if err != nil {
		return 0, err
	}
	return o.process.Start(ctx, config, args, env)
}

// Stop stops a running binary and marks its monitor as stopped so
// the restart timer won't automatically bring it back.
func (o *Orchestrator) Stop(ctx context.Context, name string, force bool) error {
	err := o.process.Stop(ctx, name, force)

	// Always mark the monitor as stopped, even if process.Stop failed
	// (e.g. "not running"). This ensures the restart timer won't
	// try to bring it back after a manual stop.
	o.monitorsMu.Lock()
	if mon, ok := o.monitors[name]; ok {
		mon.MarkStopped()
	}
	o.monitorsMu.Unlock()

	return err
}

// Status returns the current status of a binary.
func (o *Orchestrator) Status(name string) BinaryStatus {
	config, err := o.getConfig(name)
	if err != nil {
		return BinaryStatus{Name: name, Error: err.Error()}
	}

	proc := o.process.Get(name)
	_, downloaded := os.Stat(BinaryPath(o.DataDir, config.BinaryName))
	status := BinaryStatus{
		Name:         config.Name,
		DisplayName:  config.DisplayName,
		ChainLayer:   config.ChainLayer,
		Port:         config.Port,
		Downloadable: config.Downloadable(),
		Description:  config.Description,
		Downloaded:   downloaded == nil,
	}

	if proc != nil {
		status.Running = true
		status.Pid = proc.Pid
		status.Uptime = time.Since(proc.Started)
	}

	// Quick port probe if not already known to be running.
	if config.Port > 0 && !status.Running {
		conn, err := net.DialTimeout("tcp", fmt.Sprintf("localhost:%d", config.Port), 200*time.Millisecond)
		if err == nil {
			conn.Close()
			status.PortInUse = true
		}
	}

	// Pull connection state from monitor if available
	o.monitorsMu.Lock()
	if mon, ok := o.monitors[name]; ok {
		status.Connected = mon.Connected()
		status.Healthy = mon.Connected()
		status.StartupError = mon.StartupError()
		status.ConnectionError = mon.ConnectionError()
		status.Stopping = mon.StoppingBinary()
		status.Initializing = mon.InitializingBinary()
		status.ConnectModeOnly = mon.ConnectModeOnly()
	}
	o.monitorsMu.Unlock()

	return status
}

// ListAll returns the status of every configured binary,
// sorted by chain layer (L1 first) then name.
func (o *Orchestrator) ListAll() []BinaryStatus {
	o.mu.RLock()
	defer o.mu.RUnlock()

	statuses := make([]BinaryStatus, 0, len(o.configs))
	for name := range o.configs {
		statuses = append(statuses, o.Status(name))
	}
	sort.Slice(statuses, func(i, j int) bool {
		if statuses[i].ChainLayer != statuses[j].ChainLayer {
			return statuses[i].ChainLayer < statuses[j].ChainLayer
		}
		return statuses[i].Name < statuses[j].Name
	})
	return statuses
}

// Logs returns a channel of log entries for a binary and a cancel function.
func (o *Orchestrator) Logs(name string) (<-chan LogEntry, func(), error) {
	proc := o.process.Get(name)
	if proc == nil {
		return nil, nil, fmt.Errorf("%s is not running", name)
	}
	ch, cancel := proc.Subscribe()
	return ch, cancel, nil
}

// RecentLogs returns the most recent log entries for a binary.
func (o *Orchestrator) RecentLogs(name string, n int) ([]LogEntry, error) {
	proc := o.process.Get(name)
	if proc == nil {
		return nil, fmt.Errorf("%s is not running", name)
	}
	return proc.RecentLogs(n), nil
}

// StartWithDeps starts a binary along with its dependency chain:
// Bitcoin Core -> wait for wallet/IBD -> Enforcer -> target binary.
func (o *Orchestrator) StartWithDeps(ctx context.Context, target string, opts StartOpts) (<-chan StartupProgress, error) {
	config, err := o.getConfig(target)
	if err != nil {
		return nil, err
	}

	ch := make(chan StartupProgress, 100)

	go func() {
		defer close(ch)

		if opts.Immediate {
			o.startTargetOnly(ctx, config, opts, ch)
			return
		}

		// Auto-build core args if none provided and config manager is available
		if len(opts.CoreArgs) == 0 && o.BitcoinConf != nil {
			confPath := o.BitcoinConf.GetConfFilePath()
			opts.CoreArgs = []string{fmt.Sprintf("-conf=%s", confPath)}
			o.log.Info().Strs("core_args", opts.CoreArgs).Msg("auto-built core args from config")
		}

		// Auto-build enforcer args if none provided and config manager is available
		if len(opts.EnforcerArgs) == 0 && o.EnforcerConf != nil {
			opts.EnforcerArgs = o.EnforcerConf.GetCliArgs()
			o.log.Info().Strs("enforcer_args", opts.EnforcerArgs).Msg("auto-built enforcer args from config")
		}

		// Dart enforcer_rpc.dart L66-69: inject L1 seed for enforcer
		// Dart: always tries, no HasWallet/IsUnlocked guard — fails gracefully
		if o.WalletSvc != nil {
			// Dart L66: strip old --wallet-seed-file args before adding new
			filtered := make([]string, 0, len(opts.EnforcerArgs))
			for _, arg := range opts.EnforcerArgs {
				if !strings.HasPrefix(arg, "--wallet-seed-file") {
					filtered = append(filtered, arg)
				}
			}
			opts.EnforcerArgs = filtered

			l1Path, err := o.WalletSvc.WriteL1Starter()
			if err != nil {
				o.log.Warn().Err(err).Msg("failed to write L1 starter, continuing without")
			} else {
				opts.EnforcerArgs = append(opts.EnforcerArgs, fmt.Sprintf("--wallet-seed-file=%s", l1Path))
				o.log.Info().Str("path", l1Path).Msg("injected L1 starter for enforcer")
			}
		}

		// Dart binary_provider.dart L314-326: inject sidechain seed for chainLayer==2 targets
		// Dart: always tries for any chainLayer==2, no HasWallet/IsUnlocked guard
		if config.ChainLayer == 2 && config.Slot > 0 && o.WalletSvc != nil {
			// Dart L321: walletWriter.getSidechainStarter(slot) — ensure exists
			if _, err := o.WalletSvc.GetOrDeriveSidechainStarter(config.Slot, config.DisplayName); err != nil {
				o.log.Warn().Err(err).Int("slot", config.Slot).Msg("could not ensure sidechain starter")
			}
			// Dart L322: walletReader.writeSidechainStarter(slot) — write to temp file
			scPath, err := o.WalletSvc.WriteSidechainStarter(config.Slot)
			if err != nil {
				o.log.Warn().Err(err).Int("slot", config.Slot).Msg("failed to write sidechain starter")
			} else {
				opts.TargetArgs = append(opts.TargetArgs, fmt.Sprintf("--mnemonic-seed-phrase-path=%s", scPath))
				o.log.Info().Str("path", scPath).Int("slot", config.Slot).Msg("injected sidechain starter")
			}
		}

		// === Bitcoin Core: initBinary pattern (rpc_connection.dart L197-232) ===
		//
		// Dart flow:
		//   1. startConnectionTimer() — pings once, then starts 1s timer
		//   2. if (connected) → "already running, not booting" → return
		//   3. else → bootProcess() → wait for connection
		//
		// The connection timer keeps running persistently so that after a
		// stop() the monitor enters connectModeOnly and can detect
		// externally-restarted processes.

		coreCfg := o.configs["bitcoind"]
		var coreHealthOpts HealthCheckOpts
		if o.BitcoinConf != nil {
			if coreCfg.Port == 0 {
				coreCfg.Port = o.BitcoinConf.GetRPCPort()
			}
			if o.BitcoinConf.Config != nil {
				section := o.BitcoinConf.Network.CoreSection()
				coreHealthOpts.User = o.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
				coreHealthOpts.Password = o.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
			}
		}
		coreChecker := NewHealthChecker(coreCfg, coreHealthOpts)
		coreMon := o.getOrCreateMonitor("bitcoind", coreChecker, bitcoindStartupPatterns)

		// Dart L208: await startConnectionTimer()
		coreMon.StartConnectionTimer(ctx)

		// Dart L209-213: if (connected) { "already running, not booting"; return }
		if coreMon.Connected() {
			o.log.Info().Str("binary", "bitcoind").Msg("already running, not booting")
			ch <- StartupProgress{Stage: "waiting-bitcoind", Message: "Bitcoin Core already running"}

			// Adopt with real PID if possible (Dart: PidFileManager.readPidFile)
			if !o.process.IsRunning("bitcoind") {
				pid := o.discoverPid(coreCfg)
				o.process.AdoptProcess(coreCfg, pid)
				o.log.Info().Str("binary", "bitcoind").Int("pid", pid).Msg("adopted externally-running process")
			}
		} else {
			// Dart L216-217: only start restart timer if this process starts the binary!
			coreArgs := opts.CoreArgs // capture for closure
			coreMon.StartRestartTimer(ctx,
				// restartFunc: re-start bitcoind
				// Dart binary_provider.dart L490-506: detect -reindex need before restart
				func(restartCtx context.Context) error {
					// Check stderr logs for reindex marker before restarting
					// Dart L491-492: logs.any((line) => line.contains('Please restart with -reindex'))
					proc := o.process.Get("bitcoind")
					if proc != nil {
						logs := proc.RecentLogs(100)
						for _, entry := range logs {
							if strings.Contains(entry.Line, "Please restart with -reindex") {
								o.log.Warn().Msg("Bitcoin Core needs reindex, adding -reindex flag for next boot attempt")
								hasReindex := false
								for _, arg := range coreArgs {
									if arg == "-reindex" {
										hasReindex = true
										break
									}
								}
								if !hasReindex {
									coreArgs = append(coreArgs, "-reindex")
								}
								break
							}
						}
					}

					_, err := o.process.Start(restartCtx, o.configs["bitcoind"], coreArgs, nil)
					return err
				},
				// exitedFunc: check if bitcoind exited with non-zero code
				func() (int, bool) {
					proc := o.process.Get("bitcoind")
					if proc == nil {
						return 0, false
					}
					select {
					case <-proc.ExitCh():
						return proc.ExitCode(), true
					default:
						return 0, false
					}
				},
			)

			// Dart L219: log + bootProcess
			ch <- StartupProgress{Stage: "starting-bitcoind", Message: "starting Bitcoin Core..."}

			downloadCh, err := o.download.Download(ctx, o.configs["bitcoind"], o.Network, false)
			if err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("download bitcoind: %w", err)}
				return
			}
			if err := forwardDownload(downloadCh, ch, "downloading-bitcoind"); err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("download bitcoind: %w", err)}
				return
			}

			if _, err := o.process.Start(ctx, o.configs["bitcoind"], opts.CoreArgs, nil); err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("start bitcoind: %w", err)}
				return
			}

			// Wait for the connection timer to detect bitcoind is healthy
			ch <- StartupProgress{Stage: "waiting-bitcoind", Message: "waiting for Bitcoin Core to accept connections..."}
			if err := coreMon.WaitForConnected(ctx); err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("wait for bitcoind: %w", err)}
				return
			}
		}

		// === Enforcer: same initBinary pattern ===
		if config.ChainLayer == 2 {
			enforcerCfg := o.configs["enforcer"]
			enforcerChecker := NewHealthChecker(enforcerCfg)
			enforcerMon := o.getOrCreateMonitor("enforcer", enforcerChecker, enforcerStartupPatterns)

			// Dart L208: await startConnectionTimer()
			enforcerMon.StartConnectionTimer(ctx)

			// Dart L209-213: if (connected) → skip
			if enforcerMon.Connected() {
				o.log.Info().Str("binary", "enforcer").Msg("already running, not booting")
				ch <- StartupProgress{Stage: "waiting-enforcer", Message: "BIP300301 enforcer already running"}

				if !o.process.IsRunning("enforcer") {
					pid := o.discoverPid(enforcerCfg)
					o.process.AdoptProcess(enforcerCfg, pid)
					o.log.Info().Str("binary", "enforcer").Int("pid", pid).Msg("adopted externally-running process")
				}
			} else {
				// Dart L216-217: only start restart timer if this process starts the binary!
				enfOpts := opts
				enforcerMon.StartRestartTimer(ctx,
					func(restartCtx context.Context) error {
						_, err := o.process.Start(restartCtx, o.configs["enforcer"], enfOpts.EnforcerArgs, nil)
						return err
					},
					func() (int, bool) {
						proc := o.process.Get("enforcer")
						if proc == nil {
							return 0, false
						}
						select {
						case <-proc.ExitCh():
							return proc.ExitCode(), true
						default:
							return 0, false
						}
					},
				)

				ch <- StartupProgress{Stage: "starting-enforcer", Message: "starting BIP300301 enforcer..."}

				downloadCh, err := o.download.Download(ctx, o.configs["enforcer"], o.Network, false)
				if err != nil {
					ch <- StartupProgress{Error: fmt.Errorf("download enforcer: %w", err)}
					return
				}
				if err := forwardDownload(downloadCh, ch, "downloading-enforcer"); err != nil {
					ch <- StartupProgress{Error: fmt.Errorf("download enforcer: %w", err)}
					return
				}

				if _, err := o.process.Start(ctx, o.configs["enforcer"], opts.EnforcerArgs, nil); err != nil {
					ch <- StartupProgress{Error: fmt.Errorf("start enforcer: %w", err)}
					return
				}

				ch <- StartupProgress{Stage: "waiting-enforcer", Message: "waiting for enforcer to accept connections..."}
				if err := enforcerMon.WaitForConnected(ctx); err != nil {
					ch <- StartupProgress{Error: fmt.Errorf("wait for enforcer: %w", err)}
					return
				}
			}
		}

		// Start the target binary
		o.startTargetOnly(ctx, config, opts, ch)
	}()

	return ch, nil
}

func (o *Orchestrator) startTargetOnly(ctx context.Context, config BinaryConfig, opts StartOpts, ch chan<- StartupProgress) {
	ch <- StartupProgress{Stage: "downloading-" + config.Name, Message: fmt.Sprintf("downloading %s...", config.DisplayName)}

	downloadCh, err := o.download.Download(ctx, config, o.Network, false)
	if err != nil {
		ch <- StartupProgress{Error: fmt.Errorf("download %s: %w", config.Name, err)}
		return
	}
	if err := forwardDownload(downloadCh, ch, "downloading-"+config.Name); err != nil {
		ch <- StartupProgress{Error: fmt.Errorf("download %s: %w", config.Name, err)}
		return
	}

	ch <- StartupProgress{Stage: "starting-" + config.Name, Message: fmt.Sprintf("starting %s...", config.DisplayName)}

	if _, err := o.process.Start(ctx, config, opts.TargetArgs, opts.TargetEnv); err != nil {
		ch <- StartupProgress{Error: fmt.Errorf("start %s: %w", config.Name, err)}
		return
	}

	ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
}

// forwardDownload forwards DownloadProgress events to the StartupProgress channel,
// mapping download fields and returning an error if the download fails.
func forwardDownload(downloadCh <-chan DownloadProgress, startupCh chan<- StartupProgress, stage string) error {
	for p := range downloadCh {
		if p.Error != nil {
			return p.Error
		}
		if p.BytesDownloaded > 0 || p.Message != "" {
			startupCh <- StartupProgress{
				Stage:           stage,
				Message:         p.Message,
				BytesDownloaded: p.BytesDownloaded,
				TotalBytes:      p.TotalBytes,
			}
		}
	}
	return nil
}

// ShutdownAll stops all running binaries in reverse dependency order.
func (o *Orchestrator) ShutdownAll(ctx context.Context, force bool) (<-chan ShutdownProgress, error) {
	running := o.process.ListRunning()
	ch := make(chan ShutdownProgress, len(running)+1)

	go func() {
		defer close(ch)

		total := len(running)
		completed := 0

		// Sort: stop sidechains first, then enforcer, then bitcoind
		ordered := orderForShutdown(running)

		for _, name := range ordered {
			// Dart binary_provider.dart pattern: don't shut down processes we
			// didn't start. If it was adopted (running externally), just
			// remove it from our tracking — the owning process manages its
			// lifecycle.
			if o.process.IsAdopted(name) {
				// Dart binary_provider.dart pattern: don't shut down processes we
				// didn't start. The owning process manages its lifecycle.
				// Dart RPCConnection.markDisconnected() — keep timer in connectModeOnly
				o.log.Info().Str("binary", name).Msg("adopted process, skipping shutdown (not ours to stop)")
				o.process.Remove(name)

				// Transition monitor to connect-mode-only so it can detect
				// if the process comes back (Dart: connectModeOnly = true)
				o.monitorsMu.Lock()
				if mon, ok := o.monitors[name]; ok {
					mon.MarkDisconnected()
				}
				o.monitorsMu.Unlock()

				completed++
				continue
			}

			ch <- ShutdownProgress{
				TotalCount:    total,
				CompletedCount: completed,
				CurrentBinary: name,
			}

			if err := o.process.Stop(ctx, name, force); err != nil {
				o.log.Warn().Err(err).Str("binary", name).Msg("stop during shutdown")
			}

			// Dart RPCConnection.stop() — mark as stopped, timer enters connectModeOnly
			o.monitorsMu.Lock()
			if mon, ok := o.monitors[name]; ok {
				mon.MarkStopped()
			}
			o.monitorsMu.Unlock()

			completed++
		}

		ch <- ShutdownProgress{
			TotalCount:    total,
			CompletedCount: completed,
			Done:          true,
		}
	}()

	return ch, nil
}

// AdoptOrphans reads PID files from a previous session and adopts any
// processes that are still alive.
func (o *Orchestrator) AdoptOrphans(ctx context.Context) error {
	pids := o.pidManager.ListPidFiles()

	for binaryName, pid := range pids {
		if !o.pidManager.ValidatePid(pid, binaryName) {
			o.log.Debug().Str("binary", binaryName).Int("pid", pid).Msg("stale PID file, cleaning up")
			_ = o.pidManager.DeletePidFile(binaryName)
			continue
		}

		// Find the matching config
		config, found := o.findConfigByBinaryName(binaryName)
		if !found {
			o.log.Warn().Str("binary", binaryName).Msg("no config for orphaned process")
			continue
		}

		o.process.AdoptProcess(config, pid)
		o.log.Info().Str("binary", config.Name).Int("pid", pid).Msg("adopted orphaned process")
	}

	return nil
}

// ProcessManager returns the underlying process manager (for direct access if needed).
func (o *Orchestrator) ProcessManager() *ProcessManager {
	return o.process
}

// Configs returns the binary configs.
func (o *Orchestrator) Configs() map[string]BinaryConfig {
	o.mu.RLock()
	defer o.mu.RUnlock()
	return o.configs
}

// GetBTCPrice returns the current BTC/USD price, caching for 10 seconds.
func (o *Orchestrator) GetBTCPrice() (float64, time.Time, error) {
	o.priceMu.Lock()
	defer o.priceMu.Unlock()

	if time.Since(o.cachedPriceTime) < 10*time.Second && o.cachedBTCPrice > 0 {
		return o.cachedBTCPrice, o.cachedPriceTime, nil
	}

	resp, err := http.Get("https://blockchain.info/ticker")
	if err != nil {
		return o.cachedBTCPrice, o.cachedPriceTime, fmt.Errorf("fetch BTC price: %w", err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	if resp.StatusCode != http.StatusOK {
		return o.cachedBTCPrice, o.cachedPriceTime, fmt.Errorf("fetch BTC price: HTTP %d", resp.StatusCode)
	}

	var ticker map[string]struct {
		Last float64 `json:"last"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&ticker); err != nil {
		return o.cachedBTCPrice, o.cachedPriceTime, fmt.Errorf("decode BTC price: %w", err)
	}

	usd, ok := ticker["USD"]
	if !ok {
		return o.cachedBTCPrice, o.cachedPriceTime, fmt.Errorf("USD not found in ticker response")
	}

	o.cachedBTCPrice = usd.Last
	o.cachedPriceTime = time.Now()

	return o.cachedBTCPrice, o.cachedPriceTime, nil
}

// MainchainBlockchainInfo holds the result of bitcoind's getblockchaininfo.
type MainchainBlockchainInfo struct {
	Chain                 string  `json:"chain"`
	Blocks                int     `json:"blocks"`
	Headers               int     `json:"headers"`
	BestBlockHash         string  `json:"bestblockhash"`
	Difficulty            float64 `json:"difficulty"`
	Time                  int64   `json:"time"`
	MedianTime            int64   `json:"mediantime"`
	VerificationProgress  float64 `json:"verificationprogress"`
	InitialBlockDownload  bool    `json:"initialblockdownload"`
	ChainWork             string  `json:"chainwork"`
	SizeOnDisk            int64   `json:"size_on_disk"`
	Pruned                bool    `json:"pruned"`
}

// EnforcerBlockchainInfo holds minimal chain tip info from the enforcer.
type EnforcerBlockchainInfo struct {
	Blocks  int
	Headers int
	Time    int64
}

// MainchainBalance holds confirmed + unconfirmed balances from bitcoind.
type MainchainBalance struct {
	Confirmed   float64
	Unconfirmed float64
}

// GetMainchainBlockchainInfo proxies getblockchaininfo from bitcoind.
func (o *Orchestrator) GetMainchainBlockchainInfo(ctx context.Context) (*MainchainBlockchainInfo, error) {
	client, err := o.coreStatusClient()
	if err != nil {
		return nil, err
	}

	result, err := client.call(ctx, "getblockchaininfo")
	if err != nil {
		return nil, fmt.Errorf("getblockchaininfo: %w", err)
	}

	var info MainchainBlockchainInfo
	if err := json.Unmarshal(result, &info); err != nil {
		return nil, fmt.Errorf("decode getblockchaininfo: %w", err)
	}

	return &info, nil
}

// GetEnforcerBlockchainInfo returns chain tip info for the enforcer.
// The enforcer mirrors mainchain blocks, so when running we proxy the mainchain
// block count. This avoids needing cusf proto stubs in the orchestrator.
func (o *Orchestrator) GetEnforcerBlockchainInfo(ctx context.Context) (*EnforcerBlockchainInfo, error) {
	if !o.process.IsRunning("enforcer") {
		return &EnforcerBlockchainInfo{}, nil
	}

	// The enforcer tracks mainchain blocks, so use mainchain block count as a proxy.
	mainInfo, err := o.GetMainchainBlockchainInfo(ctx)
	if err != nil {
		// Enforcer is running but we can't reach bitcoind — return zeros
		return &EnforcerBlockchainInfo{}, nil
	}

	return &EnforcerBlockchainInfo{
		Blocks:  mainInfo.Blocks,
		Headers: mainInfo.Headers,
		Time:    mainInfo.Time,
	}, nil
}

// GetMainchainBalance proxies getbalance + getunconfirmedbalance from bitcoind.
func (o *Orchestrator) GetMainchainBalance(ctx context.Context) (*MainchainBalance, error) {
	client, err := o.coreStatusClient()
	if err != nil {
		return nil, err
	}

	result, err := client.call(ctx, "getbalance")
	if err != nil {
		return nil, fmt.Errorf("getbalance: %w", err)
	}
	var confirmed float64
	if err := json.Unmarshal(result, &confirmed); err != nil {
		return nil, fmt.Errorf("decode getbalance: %w", err)
	}

	result, err = client.call(ctx, "getunconfirmedbalance")
	if err != nil {
		return nil, fmt.Errorf("getunconfirmedbalance: %w", err)
	}
	var unconfirmed float64
	if err := json.Unmarshal(result, &unconfirmed); err != nil {
		return nil, fmt.Errorf("decode getunconfirmedbalance: %w", err)
	}

	return &MainchainBalance{Confirmed: confirmed, Unconfirmed: unconfirmed}, nil
}

// coreStatusClient builds a CoreStatusClient from the current config.
func (o *Orchestrator) coreStatusClient() (*CoreStatusClient, error) {
	if o.BitcoinConf == nil {
		return nil, fmt.Errorf("bitcoin config not available")
	}

	port := o.BitcoinConf.GetRPCPort()
	var user, password string
	if o.BitcoinConf.Config != nil {
		section := o.BitcoinConf.Network.CoreSection()
		user = o.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
		password = o.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
	}

	return NewCoreStatusClient("localhost", port, user, password), nil
}


func (o *Orchestrator) getConfig(name string) (BinaryConfig, error) {
	o.mu.RLock()
	defer o.mu.RUnlock()

	// Exact match first.
	if config, ok := o.configs[name]; ok {
		return config, nil
	}

	// Case-insensitive fallback: match against Name or DisplayName.
	lower := strings.ToLower(name)
	for _, config := range o.configs {
		if strings.ToLower(config.Name) == lower || strings.ToLower(config.DisplayName) == lower {
			return config, nil
		}
	}

	return BinaryConfig{}, fmt.Errorf("unknown binary: %s", name)
}

func (o *Orchestrator) findConfigByBinaryName(binaryName string) (BinaryConfig, bool) {
	o.mu.RLock()
	defer o.mu.RUnlock()

	for _, config := range o.configs {
		if processNameMatches(config.BinaryName, binaryName) {
			return config, true
		}
	}
	return BinaryConfig{}, false
}

// orderForShutdown returns binary names ordered for shutdown:
// sidechains first (layer 2), then enforcer, then bitcoind.
func orderForShutdown(names []string) []string {
	var sidechains, l1, other []string
	for _, name := range names {
		switch name {
		case "bitcoind":
			l1 = append([]string{name}, l1...) // bitcoind last in l1
		case "enforcer":
			l1 = append(l1, name) // enforcer before bitcoind
		default:
			if name == "bitwindowd" {
				other = append(other, name)
			} else {
				sidechains = append(sidechains, name)
			}
		}
	}

	result := make([]string, 0, len(names))
	result = append(result, sidechains...)
	result = append(result, other...)
	// Enforcer before bitcoind
	for _, name := range l1 {
		if name != "bitcoind" {
			result = append(result, name)
		}
	}
	for _, name := range l1 {
		if name == "bitcoind" {
			result = append(result, name)
		}
	}
	return result
}
