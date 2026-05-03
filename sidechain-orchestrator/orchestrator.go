package orchestrator

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"golang.org/x/net/http2"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
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
	BinaryPath      string // absolute path to the launchable binary (variant-aware), empty when not downloaded
	PortInUse       bool   // port is reachable (something is listening)
	Version         string // configured version string
	RepoURL         string // source code repository URL
	StartupLogs     []StartupLogLine
}

// StartupProgress reports progress during StartWithL1. Download fields
// are in megabytes (matches DownloadProgress).
type StartupProgress struct {
	Stage        string // e.g. "downloading-bitcoind", "starting-bitcoind", "waiting-ibd"
	Message      string
	Done         bool
	Error        error
	MBDownloaded int64
	MBTotal      int64
}

// ShutdownProgress reports progress during ShutdownAll.
type ShutdownProgress struct {
	TotalCount     int
	CompletedCount int
	CurrentBinary  string
	Done           bool
	Error          error
}

// StartOpts configures a StartWithL1 call.
type StartOpts struct {
	TargetArgs   []string
	TargetEnv    map[string]string
	CoreArgs     []string
	EnforcerArgs []string
	Immediate    bool // start target without waiting for L1
}

// failBoot routes a StartWithL1 failure to all the places the frontend can
// see it: clears the monitor's initializing flag (otherwise the spinner
// stays forever), records the error on the monitor (so the next
// listBinaries poll surfaces it on BinaryStatus.connection_error → DaemonConnectionCard),
// and emits a StartupProgress on the boot stream (so the caller's awaited
// future actually rejects). Without all three, a fatal boot failure can
// silently look identical to "still initializing", which is exactly how
// the bitcoind-binary-not-found regression hid in the UI.
func failBoot(mon *ConnectionMonitor, ch chan<- StartupProgress, prefix string, err error) {
	mon.SetInitializing(false)
	mon.SetConnectionError(fmt.Sprintf("%s: %v", prefix, err))
	ch <- StartupProgress{Error: fmt.Errorf("%s: %w", prefix, err)}
}

// Orchestrator coordinates binary download, process management, and health checking.
type Orchestrator struct {
	DataDir      string
	Network      string
	BitwindowDir string

	BitcoinConf    *config.BitcoinConfManager
	EnforcerConf   *config.EnforcerConfManager
	SidechainConfs map[string]*config.SidechainConfManager
	WalletSvc      *wallet.Service // for seed injection into sidechain/enforcer args
	WalletEngine   *WalletEngine   // manages wallet→Core mapping, sync, backend routing
	Settings       *SettingsStore

	configs    map[string]BinaryConfig
	download   *DownloadManager
	process    *ProcessManager
	pidManager *PidFileManager
	log        zerolog.Logger

	// Dart: RPCConnection instances — one per binary, for persistent health monitoring
	monitors   map[string]*ConnectionMonitor
	monitorsMu sync.Mutex

	mu sync.RWMutex

	// coreVariantMu serialises the entire stop -> persist -> download -> restart
	// sequence so two concurrent SetCoreVariant calls can't race the on-disk
	// state into an inconsistent shape.
	coreVariantMu sync.Mutex

	// testSidechainsMu serialises the stop -> persist -> wipe sequence for
	// SetTestSidechains. Same reason as coreVariantMu.
	testSidechainsMu sync.Mutex

	// swapNetworkMu serialises the stop -> persist -> restart sequence for
	// SwapNetwork. Same reason as coreVariantMu.
	swapNetworkMu sync.Mutex

	cachedBTCPrice  float64
	cachedPriceTime time.Time
	priceMu         sync.Mutex

	// Cached canonical sidechain header heights from
	// node.<network>.drivechain.info/explorer.v1.ExplorerService/GetChainTips.
	// Used by GetSyncStatus to populate ChainSync.Headers — local sidechains
	// only know what they've indexed, not the network tip. TTL keeps polling
	// reasonable; on fetch failure we keep serving the previous values
	// rather than dropping headers from the response (callers depend on
	// them being non-zero to compute progress percentages).
	explorerMu      sync.Mutex
	explorerHeights map[string]int64
	explorerFetched time.Time

	// Cache for getblockchaininfo. During IBD this RPC can take seconds
	// because it blocks on Core's cs_main lock; without a cache, every
	// caller (orchestrator monitor, frontend SyncProvider, etc.) issues
	// its own copy and they queue behind cs_main, eventually tripping the
	// HTTP client timeout and triggering connection-lost cycles. The
	// cache + single-flight collapses concurrent callers onto one in-flight
	// RPC and serves recent results from memory.
	bciMu        sync.Mutex
	bciInFlight  chan struct{} // non-nil while a fetch is running; closed on completion
	bciInfo      *MainchainBlockchainInfo
	bciErr       error
	bciFetchedAt time.Time

	// httpClientsMu guards the lazy HTTP-client singletons used by the
	// chatty pollers (CoreStatusClient, GetSyncStatus). Each client is built
	// once and reused across every poll — without this, every probe
	// constructed a fresh http.Client whose connection pool died with the
	// call, churning hundreds of TCP connections per second against
	// bitcoind/enforcer/sidechains and exhausting the receivers' fd limits
	// during sync.
	httpClientsMu       sync.Mutex
	coreStatusClient    *CoreStatusClient
	coreStatusClientKey string
	enforcerHTTPClient  *http.Client
	sidechainHTTPClient *http.Client
	explorerHTTPClient  *http.Client

	// stopBinary is the Stop primitive used by SetCoreVariant. Production wires
	// this to o.Stop; tests override it to inject force/graceful failures.
	stopBinary func(ctx context.Context, name string, force bool) error

	// bootBitcoindForVariantSwap boots bitcoind after a variant swap. Returns
	// a channel that is closed when boot is complete. Production wires this to
	// the real boot helper; tests override it to bypass process spawning.
	bootBitcoindForVariantSwap func(ctx context.Context) <-chan StartupProgress
}

// DownloadStateForTest exposes the DownloadManager's per-binary state to
// tests in sibling packages (e.g. api/) so they can poll for completion
// without subscribing to a stream. Returns ok=true while the download is
// in flight.
func (o *Orchestrator) DownloadStateForTest(name string) (DownloadState, bool) {
	return o.download.State(name)
}

// New creates a new Orchestrator.
func New(dataDir, network, bitwindowDir string, configs []BinaryConfig, log zerolog.Logger) *Orchestrator {
	pidMgr := NewPidFileManager(dataDir, log)

	settings, err := NewSettingsStore(bitwindowDir)
	if err != nil {
		log.Warn().Err(err).Msg("orchestrator settings load failed, using defaults")
		settings = &SettingsStore{bitwindowDir: bitwindowDir, current: defaultOrchestratorSettings()}
	}

	orch := &Orchestrator{
		DataDir:      dataDir,
		Network:      network,
		BitwindowDir: bitwindowDir,
		Settings:     settings,
		configs:      lo.SliceToMap(configs, func(c BinaryConfig) (string, BinaryConfig) { return c.Name, c }),
		download:     NewDownloadManager(dataDir, ConfigFilePath(bitwindowDir), log),
		process:      NewProcessManager(dataDir, pidMgr, log),
		pidManager:   pidMgr,
		monitors:     make(map[string]*ConnectionMonitor),
		log:          log.With().Str("component", "orchestrator").Logger(),
	}

	// Variant resolver shared by download + process managers. The persisted
	// ID wins when it's available on the current network; otherwise we clamp
	// to the first network-compatible variant so a user who switched
	// networks doesn't end up launching the wrong build. knots is always
	// ranked last in the fallback order — pure alphabetical was silently
	// picking it over vanilla / drivechain-patched on signet.
	variantResolver := func(c BinaryConfig) (CoreVariantSpec, bool) {
		if !c.IsBitcoinCore {
			return CoreVariantSpec{}, false
		}
		id := orch.Settings.CoreVariant()
		if v, ok := c.Variants[id]; ok && v.AvailableOn(orch.Network) {
			return v, true
		}
		available := FilterVariantsForNetwork(c.Variants, orch.Network)
		if len(available) == 0 {
			return CoreVariantSpec{}, false
		}
		sort.Slice(available, func(i, j int) bool {
			return preferenceLess(available[i].ID, available[j].ID)
		})
		return available[0], true
	}
	orch.download.CoreVariant = func() (CoreVariantSpec, bool) {
		cfg, ok := orch.configs["bitcoind"]
		if !ok {
			return CoreVariantSpec{}, false
		}
		return variantResolver(cfg)
	}
	orch.process.CoreVariant = variantResolver

	// Sidechain variant resolver: returns the alt fields from BinaryConfig
	// when the test toggle is on AND the config actually has alt download
	// data. Anything else falls back to the production fields.
	sidechainVariantResolver := func(c BinaryConfig) (sidechainVariantSpec, bool) {
		if c.ChainLayer != 2 || c.AltBinaryName == "" {
			return sidechainVariantSpec{}, false
		}
		if !orch.Settings.UseTestSidechains() {
			return sidechainVariantSpec{}, false
		}
		fileName := c.AltFiles[currentOS()]
		if fileName == "" {
			return sidechainVariantSpec{}, false
		}
		baseURL := c.AltBaseURL(orch.Network)
		if baseURL == "" {
			return sidechainVariantSpec{}, false
		}
		return sidechainVariantSpec{
			BinaryName:       c.AltBinaryName,
			BaseURL:          baseURL,
			FileName:         fileName,
			ExtractSubfolder: c.AltExtractSubfolder[currentOS()],
		}, true
	}
	orch.download.SidechainVariant = sidechainVariantResolver
	orch.process.SidechainVariant = sidechainVariantResolver

	orch.stopBinary = orch.Stop
	orch.bootBitcoindForVariantSwap = orch.defaultBootBitcoindForVariantSwap

	// Wire process exit events to ConnectionMonitor state.
	// When a process crashes, its stderr error message becomes the monitor's
	// connectionError so the UI can display it.
	orch.process.OnExit = func(info ProcessExitInfo) {
		orch.monitorsMu.Lock()
		mon, ok := orch.monitors[info.Name]
		orch.monitorsMu.Unlock()

		if !ok {
			return
		}

		if info.ExitCode != 0 && info.ErrMsg != "" {
			mon.SetConnectionError(info.ErrMsg)
		}
	}

	// Wire startup log capture: when a process prints a line matching
	// startup_log_patterns, push it into the monitor's startup logs.
	// Dart: ProcessManager._captureStartupLog + Binary.addStartupLog
	orch.process.OnStartupLog = func(entry StartupLogEntry) {
		orch.monitorsMu.Lock()
		mon, ok := orch.monitors[entry.Name]
		orch.monitorsMu.Unlock()

		if !ok {
			return
		}
		mon.AddStartupLog(entry.Timestamp, entry.Message)
	}

	// Initialize config managers for auto-building args
	bitcoinConf, err := config.NewBitcoinConfManager(bitwindowDir, config.Network(network), log)
	if err != nil {
		log.Warn().Err(err).Msg("failed to initialize bitcoin config manager, args must be passed explicitly")
	} else {
		// bitwindow-bitcoin.conf on disk wins. The CLI --network flag only
		// seeds the first-boot default inside NewBitcoinConfManager — once
		// the conf exists, persisted state drives the orchestrator.
		if string(bitcoinConf.Network) != orch.Network {
			log.Info().
				Str("conf_network", string(bitcoinConf.Network)).
				Str("cli_network", network).
				Msg("using persisted network from bitwindow-bitcoin.conf")
			orch.Network = string(bitcoinConf.Network)
		}
		orch.BitcoinConf = bitcoinConf

		enforcerConf, err := config.NewEnforcerConfManager(bitcoinConf, bitwindowDir, log)
		if err != nil {
			log.Warn().Err(err).Msg("failed to initialize enforcer config manager, args must be passed explicitly")
		} else {
			orch.EnforcerConf = enforcerConf
		}

		// Initialize sidechain conf managers for all known sidechains
		scConfs := make(map[string]*config.SidechainConfManager)
		for key, spec := range config.KnownSidechainSpecs {
			scm, err := config.NewSidechainConfManager(spec, bitcoinConf, log)
			if err != nil {
				log.Warn().Err(err).Str("sidechain", key).Msg("failed to initialize sidechain config manager")
				continue
			}
			scConfs[key] = scm
		}
		orch.SidechainConfs = scConfs
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
	// Flip "stopping" before sending the signal so the frontend shows
	// a stopping badge during the graceful-shutdown window. MarkStopped
	// below clears the flag once the process has actually exited.
	o.monitorsMu.Lock()
	if mon, ok := o.monitors[name]; ok {
		mon.SetStopping(true)
	}
	o.monitorsMu.Unlock()

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
	binPath := BinaryPath(o.DataDir, config.BinaryName)
	if config.IsBitcoinCore && o.Settings != nil {
		if v, ok := config.Variants[o.Settings.CoreVariant()]; ok {
			binPath = CoreBinaryPath(o.DataDir, v, config.BinaryName)
		}
	}
	if o.process.SidechainVariant != nil {
		if sv, ok := o.process.SidechainVariant(config); ok {
			binPath = TestSidechainBinaryPath(o.DataDir, sv.BinaryName)
		}
	}
	_, statErr := os.Stat(binPath)
	downloaded := statErr == nil
	status := BinaryStatus{
		Name:         config.Name,
		DisplayName:  config.DisplayName,
		ChainLayer:   config.ChainLayer,
		Port:         config.Port,
		Downloadable: config.Downloadable(),
		Description:  config.Description,
		Downloaded:   downloaded,
		Version:      config.Version,
		RepoURL:      config.RepoURL,
	}
	if downloaded {
		status.BinaryPath = binPath
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
			_ = conn.Close()
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
		status.StartupLogs = mon.StartupLogs()
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

// prefetchBinary downloads a binary in the background and signals completion
// on the returned channel (nil = success, non-nil = failure). Used to
// parallelise enforcer + target downloads with bitcoind's IBD so the binaries
// are already on disk when it's their turn to start.
//
// Safe to call even if the binary is already downloaded — DownloadManager
// short-circuits with a single Done message in that case.
func (o *Orchestrator) prefetchBinary(ctx context.Context, cfg BinaryConfig) <-chan error {
	done := make(chan error, 1)
	go func() {
		defer close(done)
		progressCh, err := o.download.Download(ctx, cfg, o.Network, false)
		if err != nil {
			done <- err
			return
		}
		for p := range progressCh {
			if p.Error != nil {
				done <- p.Error
				return
			}
		}
		done <- nil
	}()
	return done
}

// StartWithL1 starts a binary along with its dependency chain:
// Bitcoin Core -> wait for wallet/IBD -> Enforcer -> target binary.
func (o *Orchestrator) StartWithL1(ctx context.Context, target string, opts StartOpts) (<-chan StartupProgress, error) {
	config, err := o.getConfig(target)
	if err != nil {
		return nil, err
	}

	ch := make(chan StartupProgress, 100)

	go func() {
		defer close(ch)

		if opts.Immediate {
			o.startTargetOnly(ctx, config, opts, ch, nil)
			return
		}

		// Kick off enforcer + target downloads in parallel with bitcoind's IBD.
		// By the time we need to start them, they're already on disk. If the
		// prefetch is still running when we need to start, we block on its
		// completion — which is no worse than the old sequential flow.
		enforcerPrefetch := o.prefetchBinary(ctx, o.configs["enforcer"])
		var targetPrefetch <-chan error
		if config.Name != "enforcer" {
			targetPrefetch = o.prefetchBinary(ctx, config)
		}

		o.prepareCoreArgs(&opts)
		o.prepareEnforcerArgs(&opts)
		o.injectSidechainStarter(config, &opts)

		if !o.startBitcoindOnly(ctx, opts, ch) {
			return
		}

		o.startEnforcerWhenReady(ctx, opts, enforcerPrefetch)

		// Start the target after enforcer is ready.
		o.startTargetOnly(ctx, config, opts, ch, targetPrefetch)
	}()

	return ch, nil
}

// prepareCoreArgs auto-fills opts.CoreArgs from BitcoinConf when empty.
func (o *Orchestrator) prepareCoreArgs(opts *StartOpts) {
	if len(opts.CoreArgs) > 0 || o.BitcoinConf == nil {
		return
	}
	confPath := o.BitcoinConf.GetConfFilePath()
	opts.CoreArgs = []string{fmt.Sprintf("-conf=%s", confPath)}
	o.log.Info().Strs("core_args", opts.CoreArgs).Msg("auto-built core args from config")
}

// prepareEnforcerArgs auto-fills opts.EnforcerArgs from EnforcerConf when empty.
func (o *Orchestrator) prepareEnforcerArgs(opts *StartOpts) {
	if len(opts.EnforcerArgs) > 0 || o.EnforcerConf == nil {
		return
	}
	opts.EnforcerArgs = o.EnforcerConf.GetCliArgs()
	o.log.Info().Strs("enforcer_args", opts.EnforcerArgs).Msg("auto-built enforcer args from config")
}

// injectSidechainStarter writes the sidechain seed to a temp file and appends
// --mnemonic-seed-phrase-path=... to opts.TargetArgs for chainLayer==2 binaries.
// Dart binary_provider.dart L314-326.
func (o *Orchestrator) injectSidechainStarter(config BinaryConfig, opts *StartOpts) {
	if config.ChainLayer != 2 || config.Slot <= 0 || o.WalletSvc == nil {
		return
	}
	if _, err := o.WalletSvc.GetOrDeriveSidechainStarter(config.Slot, config.DisplayName); err != nil {
		o.log.Warn().Err(err).Int("slot", config.Slot).Msg("could not ensure sidechain starter")
	}
	scPath, err := o.WalletSvc.WriteSidechainStarter(config.Slot)
	if err != nil {
		o.log.Warn().Err(err).Int("slot", config.Slot).Msg("failed to write sidechain starter")
		return
	}
	opts.TargetArgs = append(opts.TargetArgs, fmt.Sprintf("--mnemonic-seed-phrase-path=%s", scPath))
	o.log.Info().Str("path", scPath).Int("slot", config.Slot).Msg("injected sidechain starter")
}

// startBitcoindOnly handles the bitcoind portion of a chain boot.
// Returns true on success (or already-running), false on fatal failure
// (failBoot has already surfaced the error to the UI in that case).
//
// Dart parity: rpc_connection.dart L197-232 initBinary pattern.
//  1. startConnectionTimer() — pings once, then starts 1s timer
//  2. if (connected) → "already running, not booting" → return
//  3. else → bootProcess() → wait for connection
func (o *Orchestrator) startBitcoindOnly(ctx context.Context, opts StartOpts, ch chan<- StartupProgress) bool {
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

	coreMon.StartConnectionTimer(ctx)

	if coreMon.Connected() {
		o.log.Info().Str("binary", "bitcoind").Msg("already running, not booting")
		ch <- StartupProgress{Stage: "waiting-bitcoind", Message: "Bitcoin Core already running"}

		if !o.process.IsRunning("bitcoind") {
			pid := o.discoverPid(coreCfg)
			o.process.AdoptProcess(coreCfg, pid)
			o.log.Info().Str("binary", "bitcoind").Int("pid", pid).Msg("adopted externally-running process")
		}
		return true
	}

	coreMon.SetInitializing(true)

	coreArgs := opts.CoreArgs
	coreMon.StartRestartTimer(ctx,
		// Dart binary_provider.dart L490-506: detect -reindex need before restart
		func(restartCtx context.Context) error {
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

	ch <- StartupProgress{Stage: "starting-bitcoind", Message: "starting Bitcoin Core..."}

	downloadCh, err := o.download.Download(ctx, o.configs["bitcoind"], o.Network, false)
	if err != nil {
		failBoot(coreMon, ch, "download bitcoind", err)
		return false
	}
	if err := forwardDownload(downloadCh, ch, "downloading-bitcoind"); err != nil {
		failBoot(coreMon, ch, "download bitcoind", err)
		return false
	}

	// If the process is already in pm.processes (e.g. coreMon.Connected()
	// briefly false during transient RPC blip but the process we own is
	// still alive), wait for the existing process's connection to recover
	// rather than calling Start again — Start would return "bitcoind is
	// already running" and surface a phantom error on the bitcoind card.
	if o.process.IsRunning("bitcoind") {
		o.log.Info().Str("binary", "bitcoind").Msg("process already in tracking map, waiting for connection")
		ch <- StartupProgress{Stage: "waiting-bitcoind", Message: "waiting for Bitcoin Core to accept connections..."}
		if err := waitForConnectedOrExit(ctx, coreMon, o.process.Get("bitcoind")); err != nil {
			failBoot(coreMon, ch, "wait for bitcoind", err)
			return false
		}
		return true
	}

	if _, err := o.process.Start(ctx, o.configs["bitcoind"], opts.CoreArgs, nil); err != nil {
		failBoot(coreMon, ch, "start bitcoind", err)
		return false
	}
	coreProc := o.process.Get("bitcoind")

	ch <- StartupProgress{Stage: "waiting-bitcoind", Message: "waiting for Bitcoin Core to accept connections..."}
	if err := waitForConnectedOrExit(ctx, coreMon, coreProc); err != nil {
		failBoot(coreMon, ch, "wait for bitcoind", err)
		return false
	}
	return true
}

// RestartDaemon stops the named binary and starts it again — single-daemon
// scope. Unlike StartWithL1, this never touches sibling daemons: restarting
// "enforcer" only restarts the enforcer; it never tries to spawn or adopt
// bitcoind. Use it for the "Restart" button on per-daemon UI cards.
//
// The returned channel emits StartupProgress events the same way StartWithL1
// does and is closed when the restart completes (or fails).
func (o *Orchestrator) RestartDaemon(ctx context.Context, name string) (<-chan StartupProgress, error) {
	config, err := o.getConfig(name)
	if err != nil {
		return nil, err
	}

	ch := make(chan StartupProgress, 100)

	go func() {
		defer close(ch)

		// Best-effort stop. If the binary isn't running, fall straight through
		// to start.
		if o.process.IsRunning(name) {
			ch <- StartupProgress{Stage: "stopping-" + name, Message: fmt.Sprintf("stopping %s...", config.DisplayName)}
			if err := o.Stop(ctx, name, false); err != nil {
				o.log.Warn().Err(err).Str("binary", name).Msg("graceful stop failed during restart, escalating to SIGKILL")
				if killErr := o.Stop(ctx, name, true); killErr != nil {
					o.log.Error().Err(killErr).Str("binary", name).Msg("force kill also failed during restart")
					ch <- StartupProgress{Error: fmt.Errorf("stop %s: %w", name, killErr)}
					return
				}
			}
		}

		opts := StartOpts{}

		switch name {
		case "bitcoind":
			o.prepareCoreArgs(&opts)
			if !o.startBitcoindOnly(ctx, opts, ch) {
				return
			}
			ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}

		case "enforcer":
			o.prepareEnforcerArgs(&opts)
			o.startEnforcerWhenReady(ctx, opts, nil)
			ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}

		default:
			o.injectSidechainStarter(config, &opts)
			// startTargetOnly emits its own "done" event.
			o.startTargetOnly(ctx, config, opts, ch, nil)
		}
	}()

	return ch, nil
}

// startEnforcerWhenReady waits for wallet + IBD completion, then starts the enforcer.
// If prefetched is non-nil, the enforcer binary is already being downloaded
// in parallel and we wait on its completion instead of starting a new download.
func (o *Orchestrator) startEnforcerWhenReady(ctx context.Context, opts StartOpts, prefetched <-chan error) {
	// 1. Wait for wallet to exist — enforcer needs the L1 seed.
	if o.WalletSvc != nil && !o.WalletSvc.HasWallet() {
		o.log.Info().Msg("waiting for wallet before starting enforcer")
		for !o.WalletSvc.HasWallet() {
			select {
			case <-ctx.Done():
				return
			case <-o.WalletSvc.StateChanged:
			}
		}
		o.log.Info().Msg("wallet created")
	}

	// 2. Wait for HEADER sync to complete — enforcer starts once Core has
	// the header chain and validates blocks in parallel as Core downloads
	// them. Waiting for full IBD here kept enforcer offline for the entire
	// chain download, which is minutes-to-hours of dead UI for no benefit.
	client, err := o.CoreStatusClient()
	if err == nil {
		o.log.Info().
			Str("core_rpc", fmt.Sprintf("localhost:%d", o.BitcoinConf.GetRPCPort())).
			Msg("waiting for header sync before starting enforcer")
		var lastErr error
		var errCount int
		for {
			complete, err := client.IsHeaderSyncComplete(ctx)
			if err == nil {
				if complete {
					break
				}
				// Headers still coming in, bitcoind is reachable: nothing to
				// log, just wait.
			} else {
				errCount++
				// Surface the RPC error the first time and then once a
				// minute so a persistent misconfig (wrong port / creds)
				// doesn't hide behind silent retries.
				if errCount == 1 || errCount%12 == 0 {
					o.log.Warn().Err(err).Int("attempts", errCount).
						Msg("header-sync check RPC failed; will keep retrying")
				}
				lastErr = err
			}
			select {
			case <-ctx.Done():
				return
			case <-time.After(5 * time.Second):
			}
		}
		if lastErr != nil {
			o.log.Info().Int("recovered_after", errCount).
				Msg("header-sync check recovered after earlier RPC errors")
		}
		o.log.Info().Msg("header sync complete, proceeding with enforcer")
	}

	enforcerCfg := o.configs["enforcer"]
	enforcerChecker := NewHealthChecker(enforcerCfg)
	enforcerMon := o.getOrCreateMonitor("enforcer", enforcerChecker, enforcerStartupPatterns)
	enforcerMon.StartConnectionTimer(ctx)

	if enforcerMon.Connected() {
		o.log.Info().Msg("enforcer already running")
		if !o.process.IsRunning("enforcer") {
			pid := o.discoverPid(enforcerCfg)
			o.process.AdoptProcess(enforcerCfg, pid)
		}
		return
	}

	// 3. Inject L1 seed. If we can't produce one (no enforcer wallet,
	// wallet.json missing, mnemonic empty) we MUST NOT start the enforcer
	// binary — it would boot with no seed, reuse whatever BDK state is on
	// disk from a prior run, and get stuck in "Aborting wallet sync to
	// new checkpoint" loops the user can't escape from. Fail loudly so
	// the frontend's WalletGuard can route the user to create a wallet.
	if o.WalletSvc != nil {
		filtered := make([]string, 0, len(opts.EnforcerArgs))
		for _, arg := range opts.EnforcerArgs {
			if !strings.HasPrefix(arg, "--wallet-seed-file") {
				filtered = append(filtered, arg)
			}
		}
		opts.EnforcerArgs = filtered

		l1Path, err := o.WalletSvc.WriteL1Starter()
		if err != nil {
			o.log.Error().Err(err).Msg("refusing to start enforcer without L1 seed")
			enforcerMon.SetConnectionError(fmt.Sprintf("cannot start enforcer without L1 wallet seed: %v", err))
			enforcerMon.SetInitializing(false)
			return
		}
		opts.EnforcerArgs = append(opts.EnforcerArgs, fmt.Sprintf("--wallet-seed-file=%s", l1Path))
		o.log.Info().Str("path", l1Path).Msg("injected L1 starter for enforcer")
	}

	// Mark initializing for the download + start window. testConnection clears
	// this on the first successful ping; error paths below clear it explicitly.
	enforcerMon.SetInitializing(true)

	// 4. Wait for bitcoind's ZMQ sequence socket to actually accept dials.
	// The enforcer exits 1 the moment its initial ZMQ dial fails — that
	// happens when bitcoind is RPC-reachable but the socket isn't bound yet
	// (early boot) or, much more commonly, when bitcoin.conf is missing
	// zmqpubsequence entirely. Probing first means we either back off until
	// the socket is up, or surface a clear error in the UI instead of an
	// opaque "exit code 1" loop the user can't diagnose.
	if zmqAddr := extractZmqSequenceAddr(opts.EnforcerArgs); zmqAddr != "" {
		if err := waitForZmqReachable(ctx, zmqAddr, &o.log); err != nil {
			enforcerMon.SetConnectionError(err.Error())
			enforcerMon.SetInitializing(false)
			o.log.Error().Err(err).Str("zmq_addr", zmqAddr).Msg("refusing to start enforcer: bitcoind ZMQ socket unreachable")
			return
		}
	}

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

	if prefetched != nil {
		// Download was kicked off in parallel with bitcoind IBD.
		if err := <-prefetched; err != nil {
			enforcerMon.SetInitializing(false)
			o.log.Error().Err(err).Msg("enforcer prefetch download failed")
			return
		}
	} else {
		downloadCh, err := o.download.Download(ctx, enforcerCfg, o.Network, false)
		if err != nil {
			enforcerMon.SetInitializing(false)
			o.log.Error().Err(err).Msg("failed to download enforcer")
			return
		}
		for progress := range downloadCh {
			if progress.Error != nil {
				enforcerMon.SetInitializing(false)
				o.log.Error().Err(progress.Error).Msg("enforcer download error")
				return
			}
		}
	}

	// Race guard: if enforcer is already in pm.processes (e.g. enforcerMon
	// briefly reports not connected during a transient RPC blip but the
	// process we own is still alive), wait for the existing process's
	// connection to recover rather than calling Start again. Without this,
	// process.Start returns "enforcer is already running" and surfaces a
	// phantom error on the enforcer card. Mirrors the bitcoind-side guard.
	if o.process.IsRunning("enforcer") {
		o.log.Info().Str("binary", "enforcer").Msg("process already in tracking map, waiting for connection")
		if err := waitForConnectedOrExit(ctx, enforcerMon, o.process.Get("enforcer")); err != nil {
			enforcerMon.SetInitializing(false)
			o.log.Error().Err(err).Msg("failed to wait for enforcer")
			return
		}
		o.log.Info().Msg("enforcer connection recovered")
		return
	}

	if _, err := o.process.Start(ctx, enforcerCfg, opts.EnforcerArgs, nil); err != nil {
		enforcerMon.SetInitializing(false)
		o.log.Error().Err(err).Msg("failed to start enforcer")
		return
	}

	o.log.Info().Msg("enforcer started")
}

// If prefetched is non-nil, the target binary is already being downloaded in
// parallel and we wait on its completion instead of starting a new download.
func (o *Orchestrator) startTargetOnly(ctx context.Context, config BinaryConfig, opts StartOpts, ch chan<- StartupProgress, prefetched <-chan error) {
	var startupPatterns []string
	var healthOpts HealthCheckOpts
	if config.IsBitcoinCore && o.BitcoinConf != nil {
		if config.Port == 0 {
			config.Port = o.BitcoinConf.GetRPCPort()
		}
		if o.BitcoinConf.Config != nil {
			section := o.BitcoinConf.Network.CoreSection()
			healthOpts.User = o.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
			healthOpts.Password = o.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
		}
		startupPatterns = bitcoindStartupPatterns
		if len(opts.TargetArgs) == 0 {
			confPath := o.BitcoinConf.GetConfFilePath()
			opts.TargetArgs = []string{fmt.Sprintf("-conf=%s", confPath)}
		}
	}
	targetChecker := NewHealthChecker(config, healthOpts)
	targetMon := o.getOrCreateMonitor(config.Name, targetChecker, startupPatterns)

	// Keep the target monitor alive even if the frontend asked us to start
	// the chain before the target RPC is reachable.
	targetMon.StartConnectionTimer(ctx)

	if targetMon.Connected() {
		o.log.Info().Str("binary", config.Name).Msg("target already running, not booting")
		ch <- StartupProgress{Stage: "waiting-" + config.Name, Message: fmt.Sprintf("%s already running", config.DisplayName)}

		if !o.process.IsRunning(config.Name) {
			pid := o.discoverPid(config)
			o.process.AdoptProcess(config, pid)
			o.log.Info().Str("binary", config.Name).Int("pid", pid).Msg("adopted externally-running target process")
		}

		ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
		return
	}

	// Mark initializing for the download + start + wait window. testConnection
	// clears this on the first successful ping; error paths below clear it
	// explicitly.
	targetMon.SetInitializing(true)

	if prefetched != nil {
		// Download was kicked off in parallel with bitcoind IBD.
		ch <- StartupProgress{Stage: "downloading-" + config.Name, Message: fmt.Sprintf("waiting for %s download...", config.DisplayName)}
		if err := <-prefetched; err != nil {
			failBoot(targetMon, ch, "download "+config.Name, err)
			return
		}
	} else {
		ch <- StartupProgress{Stage: "downloading-" + config.Name, Message: fmt.Sprintf("downloading %s...", config.DisplayName)}

		downloadCh, err := o.download.Download(ctx, config, o.Network, false)
		if err != nil {
			failBoot(targetMon, ch, "download "+config.Name, err)
			return
		}
		if err := forwardDownload(downloadCh, ch, "downloading-"+config.Name); err != nil {
			failBoot(targetMon, ch, "download "+config.Name, err)
			return
		}
	}

	// If already running (e.g. enforcer started as a dep), just wait for connection.
	if o.process.IsRunning(config.Name) {
		o.log.Info().Str("binary", config.Name).Msg("process already running, waiting for connection")
		ch <- StartupProgress{Stage: "waiting-" + config.Name, Message: fmt.Sprintf("waiting for %s...", config.DisplayName)}
		if err := waitForConnectedOrExit(ctx, targetMon, o.process.Get(config.Name)); err != nil {
			failBoot(targetMon, ch, "wait for "+config.Name, err)
			return
		}
		ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
		return
	}

	ch <- StartupProgress{Stage: "starting-" + config.Name, Message: fmt.Sprintf("starting %s...", config.DisplayName)}
	o.log.Info().Str("binary", config.Name).Strs("args", opts.TargetArgs).Msg("starting target binary")

	targetArgs := append([]string{}, opts.TargetArgs...)
	targetEnv := map[string]string{}
	for k, v := range opts.TargetEnv {
		targetEnv[k] = v
	}

	targetMon.StartRestartTimer(ctx,
		func(restartCtx context.Context) error {
			_, err := o.process.Start(restartCtx, config, targetArgs, targetEnv)
			return err
		},
		func() (int, bool) {
			proc := o.process.Get(config.Name)
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

	if _, err := o.process.Start(ctx, config, targetArgs, targetEnv); err != nil {
		failBoot(targetMon, ch, "start "+config.Name, err)
		return
	}
	targetProc := o.process.Get(config.Name)

	ch <- StartupProgress{Stage: "waiting-" + config.Name, Message: fmt.Sprintf("waiting for %s to accept connections...", config.DisplayName)}
	if err := waitForConnectedOrExit(ctx, targetMon, targetProc); err != nil {
		failBoot(targetMon, ch, "wait for "+config.Name, err)
		return
	}

	ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
}

// waitForConnectedOrExit blocks until the monitor reports connected, the
// process exits, or ctx is canceled. Errors are returned raw so the caller
// (failBoot) is the single owner of the "wait for X:" prefix — the
// previous version pre-prefixed ctx.Err() and the caller re-prefixed,
// producing surprised users staring at "wait for enforcer: wait for
// enforcer: context canceled" in the daemon card.
func waitForConnectedOrExit(ctx context.Context, mon *ConnectionMonitor, proc *ManagedProcess) error {
	if proc == nil {
		return mon.WaitForConnected(ctx)
	}

	for {
		if mon.Connected() {
			return nil
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-proc.ExitCh():
			exitCode := proc.ExitCode()
			// Prefer the rich crash reason (stderr buffer / last error log
			// lines) over the bare cmd.Wait status. ExitDetails was
			// populated by the process manager just before this channel
			// closed, so it's available now.
			if details := proc.ExitDetails(); details != "" {
				return fmt.Errorf("%s exited with code %d: %s", mon.Name, exitCode, details)
			}
			if exitErr := proc.ExitErr(); exitErr != "" {
				return fmt.Errorf("%s exited with code %d: %s", mon.Name, exitCode, exitErr)
			}
			return fmt.Errorf("%s exited with code %d", mon.Name, exitCode)
		case <-time.After(100 * time.Millisecond):
		}
	}
}

// forwardDownload forwards DownloadProgress events to the StartupProgress channel,
// mapping download fields and returning an error if the download fails.
func forwardDownload(downloadCh <-chan DownloadProgress, startupCh chan<- StartupProgress, stage string) error {
	for p := range downloadCh {
		if p.Error != nil {
			return p.Error
		}
		if p.MBDownloaded > 0 || p.Message != "" {
			startupCh <- StartupProgress{
				Stage:        stage,
				Message:      p.Message,
				MBDownloaded: p.MBDownloaded,
				MBTotal:      p.MBTotal,
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
				TotalCount:     total,
				CompletedCount: completed,
				CurrentBinary:  name,
			}

			// Flip stopping so the frontend shows a shutdown badge for the
			// duration of this binary's graceful-kill window. MarkStopped
			// below clears it.
			o.monitorsMu.Lock()
			if mon, ok := o.monitors[name]; ok {
				mon.SetStopping(true)
			}
			o.monitorsMu.Unlock()

			if !force && o.stopBinaryViaRPC(ctx, name) {
				o.monitorsMu.Lock()
				if mon, ok := o.monitors[name]; ok {
					mon.MarkStopped()
				}
				o.monitorsMu.Unlock()
				completed++
				continue
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
			TotalCount:     total,
			CompletedCount: completed,
			Done:           true,
		}
	}()

	return ch, nil
}

func (o *Orchestrator) stopBinaryViaRPC(_ context.Context, name string) bool {
	var rpcErr error
	switch name {
	case "bitcoind":
		rpcErr = o.callBitcoindStopRPC()
	case "enforcer":
		rpcErr = o.callEnforcerStopRPC()
	default:
		cfg, err := o.getConfig(name)
		if err != nil || !cfg.IsSidechain() || cfg.Port == 0 {
			return false
		}
		rpcErr = o.callSidechainStopRPC(cfg)
	}

	// Wait even if the ack failed — daemons close their RPC listener
	// partway through shutdown, and re-signaling a flushing daemon can
	// corrupt on-disk state.
	if o.process.WaitForExit(name, gracefulKillTimeout) {
		o.log.Info().Err(rpcErr).Str("binary", name).Msg("stopped via RPC")
		return true
	}

	o.log.Warn().Err(rpcErr).Str("binary", name).Msg("RPC stop did not finish; falling back to signal")
	return false
}

func (o *Orchestrator) callBitcoindStopRPC() error {
	client, err := o.CoreStatusClient()
	if err != nil {
		return fmt.Errorf("bitcoind RPC stop: no core client: %w", err)
	}
	// Detached: a near-expired upstream ctx would force an unsafe fallback.
	rpcCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	return client.Stop(rpcCtx)
}

func (o *Orchestrator) callSidechainStopRPC(cfg BinaryConfig) error {
	proxy := sidechain.NewJSONRPCProxy("127.0.0.1", cfg.Port)
	rpcCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	return proxy.Stop(rpcCtx)
}

func (o *Orchestrator) callEnforcerStopRPC() error {
	cfg, ok := o.Configs()["enforcer"]
	if !ok || cfg.Port == 0 {
		return fmt.Errorf("enforcer RPC stop: no config")
	}
	httpClient := &http.Client{
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLSContext: func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
				var d net.Dialer
				return d.DialContext(ctx, network, addr)
			},
		},
	}
	client := enforcerrpc.NewValidatorServiceClient(
		httpClient,
		fmt.Sprintf("http://127.0.0.1:%d", cfg.Port),
		connect.WithGRPC(),
	)
	rpcCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	_, err := client.Stop(rpcCtx, connect.NewRequest(&enforcerpb.StopRequest{}))
	return err
}

// AdoptOrphans reads PID files from a previous session and adopts any
// processes that are still alive. Layer-2 PID files are namespaced by mode
// (e.g. thunder.pid vs thunder-test.pid) so we can attribute the right
// owner when the user has flipped the test-sidechains toggle between runs.
func (o *Orchestrator) AdoptOrphans(ctx context.Context) error {
	pids := o.pidManager.ListPidFiles()
	useTest := o.UseTestSidechains()

	for pidName, pid := range pids {
		// Only adopt PIDs that match the currently-selected mode. A stale
		// prod PID file from before a test-mode flip has nothing in
		// pm.processes — it should sit on disk until the user flips back.
		isTestPid := strings.HasSuffix(pidName, "-test")
		if isTestPid != useTest {
			continue
		}

		realBinaryName := pidName
		if isTestPid {
			realBinaryName = strings.TrimSuffix(pidName, "-test")
		}

		if !o.pidManager.ValidatePid(pid, realBinaryName) {
			o.log.Debug().Str("binary", pidName).Int("pid", pid).Msg("stale PID file, cleaning up")
			_ = o.pidManager.DeletePidFile(pidName)
			continue
		}

		// Find the matching config
		config, found := o.findConfigByBinaryName(realBinaryName)
		if !found {
			o.log.Warn().Str("binary", pidName).Msg("no config for orphaned process")
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

// CoreVariant returns the currently selected Bitcoin Core variant ID.
func (o *Orchestrator) CoreVariant() string {
	if o.Settings == nil {
		return DefaultCoreVariantID
	}
	return o.Settings.CoreVariant()
}

// ListCoreVariants returns the variants offered for the current network.
// On mainnet the slice is empty (the UI hides the picker entirely).
func (o *Orchestrator) ListCoreVariants() []CoreVariantSpec {
	cfg, ok := o.configs["bitcoind"]
	if !ok {
		return nil
	}
	return FilterVariantsForNetwork(cfg.Variants, o.Network)
}

// SetCoreVariant stops bitcoind, persists the new variant, ensures the binary
// is on disk for it, and restarts bitcoind. The whole sequence is serialised
// behind coreVariantMu so concurrent callers can't race the on-disk state.
// On stop failure we escalate to SIGKILL; if even that fails we abort before
// touching settings.
func (o *Orchestrator) SetCoreVariant(ctx context.Context, id string) error {
	if o.Settings == nil {
		return fmt.Errorf("orchestrator settings not initialised")
	}
	if o.Network == "mainnet" {
		return fmt.Errorf("core variant switching is disabled on mainnet")
	}

	coreCfg, ok := o.configs["bitcoind"]
	if !ok {
		return fmt.Errorf("bitcoind config not found")
	}
	variant, ok := coreCfg.Variants[id]
	if !ok {
		return fmt.Errorf("unknown core variant: %s", id)
	}
	if !variant.AvailableOn(o.Network) {
		return fmt.Errorf("variant %s is not available on network %s", id, o.Network)
	}

	o.coreVariantMu.Lock()
	defer o.coreVariantMu.Unlock()

	wasRunning := o.process.IsRunning("bitcoind")
	if wasRunning {
		if err := o.stopBitcoindForVariantSwap(ctx); err != nil {
			return fmt.Errorf("stop bitcoind for core-variant switch: %w", err)
		}
	}

	if _, err := o.Settings.SetCoreVariant(id); err != nil {
		return fmt.Errorf("persist core variant: %w", err)
	}

	// All variants share `bin/bitcoind` — wipe whatever's there so the new
	// variant downloads clean. Without this, force=true on Download would
	// still skip the network fetch when the file's hash matched something
	// it shouldn't (different variant, same path).
	binPath := CoreBinaryPath(o.DataDir, variant, coreCfg.BinaryName)
	if err := os.Remove(binPath); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("wipe existing bitcoind: %w", err)
	}

	progressCh, err := o.download.Download(ctx, coreCfg, o.Network, true)
	if err != nil {
		return fmt.Errorf("ensure variant binary: %w", err)
	}
	for p := range progressCh {
		if p.Error != nil {
			return fmt.Errorf("download variant %s: %w", id, p.Error)
		}
	}

	if !wasRunning {
		return nil
	}

	bootCh := o.bootBitcoindForVariantSwap(ctx)
	for p := range bootCh {
		if p.Error != nil {
			return fmt.Errorf("restart bitcoind: %w", p.Error)
		}
	}
	return nil
}

// SwapNetwork performs an atomic Bitcoin network swap: stop running
// L2 sidechains + enforcer + bitcoind in reverse-dependency order,
// persist the new network to bitwindow-bitcoin.conf, refresh in-memory
// state, then restart the L1 stack if bitcoind/enforcer was running.
// Sidechains are intentionally not auto-restarted — the user re-launches
// them when they want to.
func (o *Orchestrator) SwapNetwork(ctx context.Context, n config.Network) error {
	if o.BitcoinConf == nil {
		return fmt.Errorf("bitcoin config manager not initialised")
	}

	o.swapNetworkMu.Lock()
	defer o.swapNetworkMu.Unlock()

	if config.Network(o.Network) == n {
		return nil
	}

	bitcoindWasRunning := o.process.IsRunning("bitcoind")
	enforcerWasRunning := o.process.IsRunning("enforcer")

	var runningL2 []string
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 && o.process.IsRunning(c.Name) {
			runningL2 = append(runningL2, c.Name)
		}
	}

	for _, name := range runningL2 {
		if err := o.stopForNetworkSwap(ctx, name); err != nil {
			return err
		}
	}
	if enforcerWasRunning {
		if err := o.stopForNetworkSwap(ctx, "enforcer"); err != nil {
			return err
		}
	}
	if bitcoindWasRunning {
		if err := o.stopForNetworkSwap(ctx, "bitcoind"); err != nil {
			return err
		}
	}

	if err := o.BitcoinConf.UpdateNetwork(n); err != nil {
		return fmt.Errorf("persist network: %w", err)
	}
	if err := o.BitcoinConf.LoadConfig(false); err != nil {
		return fmt.Errorf("reload config: %w", err)
	}
	o.Network = string(n)

	if !bitcoindWasRunning && !enforcerWasRunning {
		return nil
	}

	// Fire-and-forget the L1 boot — the network conf is already persisted
	// and the L1 stack is wired to start, which is all the UI needs to
	// move on. Header sync / IBD / enforcer wait would otherwise block
	// this RPC for a minutes-long full connection. Use context.Background
	// so a request cancellation doesn't abort the daemon launch mid-flight.
	bootCh, err := o.StartWithL1(context.Background(), "bitcoind", StartOpts{})
	if err != nil {
		return fmt.Errorf("restart L1 stack on new network: %w", err)
	}
	go func() {
		for p := range bootCh {
			if p.Error != nil {
				o.log.Error().Err(p.Error).Msg("L1 stack restart after network swap failed")
			}
		}
	}()
	return nil
}

// stopForNetworkSwap stops a binary, escalating to SIGKILL on graceful
// failure. Mirrors stopBitcoindForVariantSwap but generic over name.
func (o *Orchestrator) stopForNetworkSwap(ctx context.Context, name string) error {
	if err := o.stopBinary(ctx, name, false); err != nil {
		o.log.Warn().Err(err).Str("binary", name).Msg("graceful stop failed during network swap, escalating to SIGKILL")
		if killErr := o.stopBinary(ctx, name, true); killErr != nil {
			return fmt.Errorf("stop %s for network swap: graceful failed (%v) and force kill failed: %w", name, err, killErr)
		}
	}
	return nil
}

// UseTestSidechains reports the persisted test-sidechains preference.
func (o *Orchestrator) UseTestSidechains() bool {
	if o.Settings == nil {
		return false
	}
	return o.Settings.UseTestSidechains()
}

// SetTestSidechains flips the persisted test-sidechains toggle. The flow is:
//  1. Stop every running layer-2 (sidechain) binary, escalating to SIGKILL on
//     graceful failure.
//  2. Persist the new value before any wipe so a crash leaves coherent state.
//  3. Wipe on-disk binaries for both production and test layouts so the next
//     launch redownloads from the correct source.
//
// We don't auto-restart anything: the frontend triggers redownload + start
// on the user's next StartWithL1.
func (o *Orchestrator) SetTestSidechains(ctx context.Context, enabled bool) error {
	if o.Settings == nil {
		return fmt.Errorf("orchestrator settings not initialised")
	}

	o.testSidechainsMu.Lock()
	defer o.testSidechainsMu.Unlock()

	if o.Settings.UseTestSidechains() == enabled {
		return nil
	}

	// Collect every layer-2 config once; we'll iterate twice (stop + wipe).
	var l2 []BinaryConfig
	for _, c := range o.Configs() {
		if c.ChainLayer == 2 {
			l2 = append(l2, c)
		}
	}

	for _, c := range l2 {
		if !o.process.IsRunning(c.Name) {
			continue
		}
		if err := o.stopBinary(ctx, c.Name, false); err != nil {
			o.log.Warn().Err(err).Str("binary", c.Name).Msg("graceful stop failed during test-sidechains switch, escalating to SIGKILL")
			if killErr := o.stopBinary(ctx, c.Name, true); killErr != nil {
				return fmt.Errorf("stop %s for test-sidechains switch: graceful failed (%v) and force kill failed: %w", c.Name, err, killErr)
			}
		}
	}

	if _, err := o.Settings.SetUseTestSidechains(enabled); err != nil {
		return fmt.Errorf("persist test-sidechains: %w", err)
	}

	for _, c := range l2 {
		o.wipeSidechainBinaries(c)
	}
	return nil
}

// wipeSidechainBinaries removes both prod and test on-disk layouts for a
// layer-2 config so the next download writes to a clean slot. Logs every
// removal so the user has a paper trail of what got nuked.
func (o *Orchestrator) wipeSidechainBinaries(c BinaryConfig) {
	prodPath := BinaryPath(o.DataDir, c.BinaryName)
	if err := os.Remove(prodPath); err == nil {
		o.log.Info().Str("binary", c.Name).Str("path", prodPath).Msg("wiped sidechain binary (prod) for test-sidechains switch")
	} else if !os.IsNotExist(err) {
		o.log.Warn().Err(err).Str("path", prodPath).Msg("could not remove prod sidechain binary")
	}

	if c.AltBinaryName != "" {
		testPath := TestSidechainBinaryPath(o.DataDir, c.AltBinaryName)
		if err := os.Remove(testPath); err == nil {
			o.log.Info().Str("binary", c.Name).Str("path", testPath).Msg("wiped sidechain binary (test) for test-sidechains switch")
		} else if !os.IsNotExist(err) {
			o.log.Warn().Err(err).Str("path", testPath).Msg("could not remove test sidechain binary")
		}
	}
}

// stopBitcoindForVariantSwap stops bitcoind, escalating to SIGKILL on graceful
// failure. Returns an error only when both the graceful and force-kill
// attempts fail so the caller can keep settings/state coherent.
func (o *Orchestrator) stopBitcoindForVariantSwap(ctx context.Context) error {
	if err := o.stopBinary(ctx, "bitcoind", false); err != nil {
		o.log.Warn().Err(err).Msg("graceful stop failed during core-variant switch, escalating to SIGKILL")
		if killErr := o.stopBinary(ctx, "bitcoind", true); killErr != nil {
			return fmt.Errorf("graceful stop failed (%v) and force kill failed: %w", err, killErr)
		}
	}
	return nil
}

// defaultBootBitcoindForVariantSwap reuses the standard L1 boot path so
// timers, port resolution, and health wiring all match a normal user-initiated
// start. We mark the bitcoind monitor stopped first so any restart timer armed
// by an earlier crash can't fire mid-switch and boot the old variant.
func (o *Orchestrator) defaultBootBitcoindForVariantSwap(ctx context.Context) <-chan StartupProgress {
	o.monitorsMu.Lock()
	if mon, ok := o.monitors["bitcoind"]; ok {
		mon.MarkStopped()
	}
	o.monitorsMu.Unlock()

	ch, err := o.StartWithL1(ctx, "bitcoind", StartOpts{Immediate: true})
	if err != nil {
		out := make(chan StartupProgress, 1)
		out <- StartupProgress{Error: err}
		close(out)
		return out
	}
	return ch
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
	Chain                string  `json:"chain"`
	Blocks               int     `json:"blocks"`
	Headers              int     `json:"headers"`
	BestBlockHash        string  `json:"bestblockhash"`
	Difficulty           float64 `json:"difficulty"`
	Time                 int64   `json:"time"`
	MedianTime           int64   `json:"mediantime"`
	VerificationProgress float64 `json:"verificationprogress"`
	InitialBlockDownload bool    `json:"initialblockdownload"`
	ChainWork            string  `json:"chainwork"`
	SizeOnDisk           int64   `json:"size_on_disk"`
	Pruned               bool    `json:"pruned"`
}

// MainchainBalance holds confirmed + unconfirmed balances from bitcoind.
type MainchainBalance struct {
	Confirmed   float64
	Unconfirmed float64
}

// blockchainInfoCacheTTL bounds how often the orchestrator actually issues
// getblockchaininfo against bitcoind. Polling is cheap on the wire but
// during IBD the RPC blocks on cs_main; multiple unbounded callers turned
// every status fetch into a thundering herd against Core. 1s is fresh
// enough for the UI (faster than block intervals on every network) and
// gives Core room to make actual progress between calls.
const blockchainInfoCacheTTL = time.Second

// GetMainchainBlockchainInfo proxies getblockchaininfo from bitcoind. The
// result is cached for [blockchainInfoCacheTTL]; concurrent callers across
// that window share a single in-flight RPC and the same answer.
func (o *Orchestrator) GetMainchainBlockchainInfo(ctx context.Context) (*MainchainBlockchainInfo, error) {
	o.bciMu.Lock()
	// Cache hit on a recent successful fetch — return immediately.
	if o.bciInfo != nil && o.bciErr == nil && time.Since(o.bciFetchedAt) < blockchainInfoCacheTTL {
		info := o.bciInfo
		o.bciMu.Unlock()
		return info, nil
	}
	// A fetch is already in flight — wait for it instead of issuing another.
	if ch := o.bciInFlight; ch != nil {
		o.bciMu.Unlock()
		select {
		case <-ch:
		case <-ctx.Done():
			return nil, ctx.Err()
		}
		o.bciMu.Lock()
		info, err := o.bciInfo, o.bciErr
		o.bciMu.Unlock()
		return info, err
	}
	// We're the leader — install the in-flight signal and run the fetch.
	ch := make(chan struct{})
	o.bciInFlight = ch
	o.bciMu.Unlock()

	info, err := o.fetchMainchainBlockchainInfo(ctx)

	o.bciMu.Lock()
	if err == nil {
		o.bciInfo = info
		o.bciErr = nil
		o.bciFetchedAt = time.Now()
	} else {
		// Don't poison the cached info on transient errors — keep the last
		// good value but record the error for the leader's return. Followers
		// that joined this fetch see the same error via bciErr below.
		o.bciErr = err
	}
	o.bciInFlight = nil
	close(ch)
	o.bciMu.Unlock()

	return info, err
}

// fetchMainchainBlockchainInfo runs the actual getblockchaininfo RPC. Pulled
// out so GetMainchainBlockchainInfo can wrap it with the cache + single-flight
// machinery above.
func (o *Orchestrator) fetchMainchainBlockchainInfo(ctx context.Context) (*MainchainBlockchainInfo, error) {
	client, err := o.CoreStatusClient()
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

// ChainSyncResult is one chain's tip snapshot. Error is set on failure; the
// numeric fields are best-effort zero in that case. While IsDownloading is
// true, Blocks/Headers carry MB downloaded / MB total instead of chain
// heights — the polled API reuses the same fields so adding download state
// didn't require new wire fields.
type ChainSyncResult struct {
	Blocks        int64
	Headers       int64
	Time          int64
	Error         string
	IsDownloading bool
}

// SyncStatus is the atomic snapshot returned by GetSyncStatus. Mainchain +
// enforcer are always populated; Sidechains carries one entry per
// orchestrator-managed L2 sidechain binary, keyed by the binary's logical
// name. Frontends that aren't sidechains (e.g. bitwindow's own bitwindowd
// daemon) are NOT in this map — the orchestrator knows nothing about them.
type SyncStatus struct {
	Mainchain  *ChainSyncResult
	Enforcer   *ChainSyncResult
	Sidechains map[string]*ChainSyncResult
}

// sidechainServicePath maps a binary name to the Connect-RPC service path
// that exposes its block-count RPC. The body is always {} and the response
// has a single int64 `count` field.
var sidechainServicePath = map[string]string{
	"thunder":   "/thunder.v1.ThunderService/GetBlockCount",
	"bitnames":  "/bitnames.v1.BitnamesService/GetBlockCount",
	"bitassets": "/bitassets.v1.BitAssetsService/GetBlockCount",
	"zside":     "/zside.v1.ZSideService/GetBlockCount",
	"photon":    "/photon.v1.PhotonService/GetBlockCount",
	"truthcoin": "/truthcoin.v1.TruthcoinService/GetBlockCount",
	"coinshift": "/coinshift.v1.CoinShiftService/GetBlockCount",
}

// GetSyncStatus fans out concurrent probes — mainchain bitcoind, enforcer
// ValidatorService, plus every known sidechain — and returns them as one
// atomic snapshot. For each slot, an in-flight download takes precedence:
// if DownloadManager.State reports Running, the slot is filled with MB
// downloaded / MB total and IsDownloading=true; otherwise the live RPC
// is queried for the chain tip.
//
// Per-chain errors are surfaced inline on ChainSyncResult.Error — the
// overall call only errors out when no probe could even be dispatched.
func (o *Orchestrator) GetSyncStatus(ctx context.Context) (*SyncStatus, error) {
	out := &SyncStatus{
		Mainchain:  &ChainSyncResult{},
		Enforcer:   &ChainSyncResult{},
		Sidechains: make(map[string]*ChainSyncResult),
	}

	// Pre-populate sidechain map with one slot per L2 sidechain. The
	// frontend uses these to render placeholders even before any binary
	// is running, and to render download progress for binaries that
	// haven't finished installing yet.
	for name, cfg := range o.Configs() {
		if cfg.ChainLayer == 2 {
			out.Sidechains[name] = &ChainSyncResult{}
		}
	}

	var wg sync.WaitGroup

	// Explorer fan-out runs in parallel with the per-chain probes so its
	// network round-trip never serialises behind them. Result is merged
	// into Sidechain.Headers after wg.Wait(); a failed fetch leaves the
	// shared `heights` map nil, which the merge step handles by falling
	// back to slot.Blocks.
	var heights map[string]int64
	wg.Add(1)
	go func() {
		defer wg.Done()
		heights = o.fetchExplorerHeights(ctx)
	}()

	// Mainchain: download check first, then bitcoind getblockchaininfo.
	wg.Add(1)
	go func() {
		defer wg.Done()
		if state, ok := o.download.State("bitcoind"); ok && state.Running {
			out.Mainchain.Blocks = state.MBDownloaded
			out.Mainchain.Headers = state.MBTotal
			out.Mainchain.IsDownloading = true
			return
		}
		info, err := o.GetMainchainBlockchainInfo(ctx)
		if err != nil {
			out.Mainchain.Error = err.Error()
			return
		}
		out.Mainchain.Blocks = int64(info.Blocks)
		out.Mainchain.Headers = int64(info.Headers)
		out.Mainchain.Time = info.Time
	}()

	// Enforcer: download check, then ValidatorService.GetChainTip.
	wg.Add(1)
	go func() {
		defer wg.Done()
		if state, ok := o.download.State("enforcer"); ok && state.Running {
			out.Enforcer.Blocks = state.MBDownloaded
			out.Enforcer.Headers = state.MBTotal
			out.Enforcer.IsDownloading = true
			return
		}
		cfg, ok := o.Configs()["enforcer"]
		if !ok || cfg.Port == 0 {
			out.Enforcer.Error = "enforcer not configured"
			return
		}
		if !o.process.IsRunning("enforcer") {
			out.Enforcer.Error = "not running"
			return
		}
		client := enforcerrpc.NewValidatorServiceClient(
			o.enforcerHTTP(),
			fmt.Sprintf("http://127.0.0.1:%d", cfg.Port),
			connect.WithGRPC(),
		)
		rpcCtx, cancel := context.WithTimeout(ctx, 2*time.Second)
		defer cancel()
		resp, err := client.GetChainTip(rpcCtx, connect.NewRequest(&enforcerpb.GetChainTipRequest{}))
		if err != nil {
			out.Enforcer.Error = err.Error()
			return
		}
		out.Enforcer.Blocks = int64(resp.Msg.GetBlockHeaderInfo().GetHeight())
	}()

	// Sidechains: one goroutine per slot. Download check first, then the
	// chain's block-count RPC.
	for name, slot := range out.Sidechains {
		name, slot := name, slot
		wg.Add(1)
		go func() {
			defer wg.Done()
			if state, ok := o.download.State(name); ok && state.Running {
				slot.Blocks = state.MBDownloaded
				slot.Headers = state.MBTotal
				slot.IsDownloading = true
				return
			}
			cfg, ok := o.Configs()[name]
			if !ok {
				slot.Error = fmt.Sprintf("unknown sidechain: %s", name)
				return
			}
			if !o.process.IsRunning(name) {
				slot.Error = "not running"
				return
			}
			path, known := sidechainServicePath[name]
			if !known {
				slot.Error = fmt.Sprintf("unknown sidechain: %s", name)
				return
			}
			url := fmt.Sprintf("http://localhost:%d%s", cfg.Port, path)
			var resp struct {
				Count int64 `json:"count"`
			}
			if err := connectJSONPost(ctx, o.sidechainHTTP(), url, &resp); err != nil {
				slot.Error = err.Error()
				return
			}
			slot.Blocks = resp.Count
		}()
	}

	wg.Wait()

	// Headers fan-out: dependent chains measure progress against bitcoind's
	// tip. Skip this for downloading slots — their blocks/headers are MB,
	// not chain heights, and overwriting headers would corrupt the meaning.
	if !out.Enforcer.IsDownloading && out.Enforcer.Error == "" {
		if !out.Mainchain.IsDownloading && out.Mainchain.Error == "" {
			out.Enforcer.Headers = out.Mainchain.Headers
		} else {
			out.Enforcer.Headers = out.Enforcer.Blocks
		}
	}
	// Sidechain headers come from the public explorer (fetched in parallel
	// above). The local sidechain RPC only reports blocks it has indexed,
	// which can't act as the goal — that has to be the network tip. Best-
	// effort: when the explorer fetch fails the map is empty and Headers
	// fall back to slot.Blocks so the UI doesn't divide by zero.
	for name, slot := range out.Sidechains {
		if slot.IsDownloading || slot.Error != "" {
			continue
		}
		if h, ok := heights[name]; ok {
			slot.Headers = h
		} else {
			slot.Headers = slot.Blocks
		}
	}

	return out, nil
}

// explorerCacheTTL bounds how often we hit the public explorer. Sidechain
// tips move on the order of a minute; 30 s is plenty fresh for the UI.
const explorerCacheTTL = 30 * time.Second

// fetchExplorerHeights returns the canonical per-sidechain network tip
// heights, keyed by orchestrator binary name (matches the keys in
// SyncStatus.Sidechains). Cached for [explorerCacheTTL]. On failure we
// keep serving the previous values rather than dropping headers entirely.
func (o *Orchestrator) fetchExplorerHeights(ctx context.Context) map[string]int64 {
	o.explorerMu.Lock()
	if !o.explorerFetched.IsZero() && time.Since(o.explorerFetched) < explorerCacheTTL {
		out := o.explorerHeights
		o.explorerMu.Unlock()
		return out
	}
	o.explorerMu.Unlock()

	// "forknet" runs on mainnet params for the L1 but the explorer host
	// keys it as "forknet". The other readable names match the URL slug
	// directly (mainnet/signet/testnet/regtest).
	url := fmt.Sprintf("https://node.%s.drivechain.info/api/explorer.v1.ExplorerService/GetChainTips", o.Network)

	rpcCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	// The Connect-JSON shape: each known sidechain key maps to an object
	// with a `height` string. We tolerate either string or numeric heights
	// because the explorer's previous shape returned numbers; the current
	// one returns strings.
	var resp map[string]struct {
		Height interface{} `json:"height"`
	}
	if err := connectJSONPost(rpcCtx, o.explorerHTTP(), url, &resp); err != nil {
		o.log.Debug().Err(err).Msg("explorer GetChainTips failed; keeping cached heights")
		o.explorerMu.Lock()
		out := o.explorerHeights
		o.explorerMu.Unlock()
		return out
	}

	heights := make(map[string]int64, len(resp))
	for name, entry := range resp {
		switch v := entry.Height.(type) {
		case string:
			if n, err := strconv.ParseInt(v, 10, 64); err == nil {
				heights[name] = n
			}
		case float64:
			heights[name] = int64(v)
		}
	}

	o.explorerMu.Lock()
	o.explorerHeights = heights
	o.explorerFetched = time.Now()
	o.explorerMu.Unlock()

	return heights
}

// connectJSONPost issues a Connect-JSON unary call (POST with empty {} body)
// against url and decodes the response body into out. Used for sidechain
// RPCs the orchestrator doesn't have generated stubs for. The caller passes
// the http.Client so connection pools survive across polls — using
// http.DefaultClient mixed local + remote traffic in one pool and lost
// keep-alive on every call, churning sockets at the receivers.
func connectJSONPost(ctx context.Context, client *http.Client, url string, out interface{}) error {
	rpcCtx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(rpcCtx, http.MethodPost, url, strings.NewReader("{}"))
	if err != nil {
		return fmt.Errorf("build request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read response: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, strings.TrimSpace(string(body)))
	}
	if err := json.Unmarshal(body, out); err != nil {
		return fmt.Errorf("decode response: %w", err)
	}
	return nil
}

// GetMainchainBalance proxies getbalance + getunconfirmedbalance from bitcoind.
func (o *Orchestrator) GetMainchainBalance(ctx context.Context) (*MainchainBalance, error) {
	client, err := o.CoreStatusClient()
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

// CoreStatusClient builds a CoreStatusClient from the current config.
func (o *Orchestrator) CoreStatusClient() (*CoreStatusClient, error) {
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

	// Cache the client (and therefore its underlying http.Client + connection
	// pool) so back-to-back getblockchaininfo / getbalance calls reuse the
	// same TCP connection instead of dialling a fresh one every time. The
	// key is rebuilt only when port/user/password actually change — a
	// SetCoreVariant or auth swap will invalidate it cleanly.
	key := fmt.Sprintf("%d|%s|%s", port, user, password)
	o.httpClientsMu.Lock()
	defer o.httpClientsMu.Unlock()
	if o.coreStatusClient != nil && o.coreStatusClientKey == key {
		return o.coreStatusClient, nil
	}
	o.coreStatusClient = NewCoreStatusClient("localhost", port, user, password)
	o.coreStatusClientKey = key
	return o.coreStatusClient, nil
}

// enforcerHTTP returns the singleton h2c http.Client used to talk to the
// BIP300/301 enforcer's ValidatorService. One client is shared across all
// GetSyncStatus polls so the underlying http2.Transport's connection pool
// survives — previously this was rebuilt per call and the new transport's
// pool was thrown away as soon as the call returned, leaving the
// connection in TIME_WAIT and starting a fresh dial on the next poll.
// MaxConnsPerHost: 1 caps us at one live connection regardless of poll
// concurrency; HTTP/2 multiplexes streams over it.
func (o *Orchestrator) enforcerHTTP() *http.Client {
	o.httpClientsMu.Lock()
	defer o.httpClientsMu.Unlock()
	if o.enforcerHTTPClient != nil {
		return o.enforcerHTTPClient
	}
	o.enforcerHTTPClient = &http.Client{
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLSContext: func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
				var d net.Dialer
				return d.DialContext(ctx, network, addr)
			},
		},
	}
	return o.enforcerHTTPClient
}

// sidechainHTTP returns the singleton HTTP/1 client used for the per-
// sidechain Connect-JSON block-count probes in GetSyncStatus. A single
// shared client is fine because http.Transport keys its connection pool
// by host:port — every sidechain ends up with its own pool, capped at one
// live connection by MaxConnsPerHost.
func (o *Orchestrator) sidechainHTTP() *http.Client {
	o.httpClientsMu.Lock()
	defer o.httpClientsMu.Unlock()
	if o.sidechainHTTPClient != nil {
		return o.sidechainHTTPClient
	}
	o.sidechainHTTPClient = &http.Client{
		Transport: &http.Transport{
			MaxConnsPerHost:     1,
			MaxIdleConnsPerHost: 1,
			IdleConnTimeout:     90 * time.Second,
		},
	}
	return o.sidechainHTTPClient
}

// explorerHTTP returns the singleton HTTPS client used for the public
// explorer GetChainTips fetch. Kept separate from the localhost clients so
// the localhost-tuned MaxConnsPerHost doesn't bleed into a remote call
// where we genuinely benefit from the default pool sizing.
func (o *Orchestrator) explorerHTTP() *http.Client {
	o.httpClientsMu.Lock()
	defer o.httpClientsMu.Unlock()
	if o.explorerHTTPClient != nil {
		return o.explorerHTTPClient
	}
	o.explorerHTTPClient = &http.Client{
		Transport: &http.Transport{
			MaxIdleConnsPerHost: 2,
			IdleConnTimeout:     90 * time.Second,
		},
	}
	return o.explorerHTTPClient
}

// CreateCoreWallet creates a Bitcoin Core wallet from a seed via BIP84 descriptor import.
// Ported from bitwindow/server/engines/wallet_engine.go.
// This is called for non-enforcer (bitcoinCore type) wallets.
func (o *Orchestrator) CreateCoreWallet(walletName string, seedHex string) error {
	client, err := o.CoreStatusClient()
	if err != nil {
		return fmt.Errorf("get core client: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Use wallet_<first8chars> naming convention matching bitwindow
	coreWalletName := fmt.Sprintf("wallet_%s", sanitizeWalletName(walletName))

	o.log.Info().
		Str("wallet", walletName).
		Str("core_name", coreWalletName).
		Msg("creating wallet in Bitcoin Core with BIP84 descriptors")

	if err := client.CreateBitcoinCoreWalletFromSeed(ctx, coreWalletName, seedHex, o.Network); err != nil {
		return fmt.Errorf("create core wallet: %w", err)
	}

	o.log.Info().
		Str("wallet", walletName).
		Str("core_name", coreWalletName).
		Msg("Bitcoin Core wallet created with BIP84 descriptors")
	return nil
}

// CreateCoreWatchOnlyWallet creates a watch-only wallet in Bitcoin Core.
func (o *Orchestrator) CreateCoreWatchOnlyWallet(walletName string, descriptorOrXpub string) error {
	client, err := o.CoreStatusClient()
	if err != nil {
		return fmt.Errorf("get core client: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	coreWalletName := fmt.Sprintf("watch_%s", sanitizeWalletName(walletName))

	o.log.Info().
		Str("wallet", walletName).
		Str("core_name", coreWalletName).
		Msg("creating watch-only wallet in Bitcoin Core")

	if err := client.CreateWatchOnlyWalletInCore(ctx, coreWalletName, descriptorOrXpub); err != nil {
		return fmt.Errorf("create watch-only core wallet: %w", err)
	}

	o.log.Info().
		Str("wallet", walletName).
		Str("core_name", coreWalletName).
		Msg("Bitcoin Core watch-only wallet created")
	return nil
}

// sanitizeWalletName creates a safe wallet name for Bitcoin Core.
func sanitizeWalletName(name string) string {
	// Replace spaces/special chars with underscores, truncate to 20 chars
	var safe []byte
	for _, c := range []byte(name) {
		if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-' {
			safe = append(safe, c)
		} else {
			safe = append(safe, '_')
		}
	}
	s := string(safe)
	if len(s) > 20 {
		s = s[:20]
	}
	return s
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
