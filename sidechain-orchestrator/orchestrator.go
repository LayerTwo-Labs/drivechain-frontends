package orchestrator

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"maps"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"golang.org/x/net/http2"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/datasource"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/fork"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/lease"
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
	UpdateAvailable bool      // a newer build is published than the one on disk
	RemoteTimestamp time.Time // Last-Modified of the published download
	LocalTimestamp  time.Time // mtime of the binary on disk
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
	// ForceBackend skips the frontend build for the target binary. Set by
	// sidechain Flutter frontends when self-booting their backend so the
	// toggle doesn't swap in another Flutter bundle inside them.
	ForceBackend bool
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
	DataDir string
	// Network is the active Bitcoin network. Write via setNetwork and read
	// concurrently via CurrentNetwork.
	Network      string
	networkMu    sync.RWMutex
	BitwindowDir string

	// Catalog is the resolved network catalog (service endpoints, explorer
	// templates, and the live eCash network id).
	Catalog netcatalog.Catalog

	// rawConfigs holds the binary configs exactly as loaded, placeholders
	// intact. Expansion is not reversible, so a later generation has to be
	// applied to these rather than to the already-expanded o.configs.
	rawConfigs map[string]BinaryConfig

	// pendingSnapshot is a UTXO snapshot to apply the next time bitcoind comes
	// up. Guarded by mu.
	pendingSnapshot *SnapshotSource

	// ecashID is the live eCash network ("alphanet"). Guarded by mu; read
	// by UpdateConfigs to expand the placeholder in freshly loaded configs.
	ecashID string

	// releases reports whether a newer build of each binary is published.
	releases *ReleaseChecker

	BitcoinConf    *config.BitcoinConfManager
	EnforcerConf   *config.EnforcerConfManager
	SidechainConfs map[string]*config.SidechainConfManager
	WalletSvc      *wallet.Service   // for seed injection into sidechain/enforcer args
	NetParams      wallet.ParamsFunc // chain params of the active network
	Settings       *SettingsStore

	// forkEngine is the single source of truth for eCash fork state; wired by
	// InitForkEngine once Core RPC is up.
	// the enforcer wallet's UTXOs (set later, once the enforcer client exists).
	forkEngine *fork.Engine

	// forkScanner enumerates the wallets and their coins for the fork engine
	// and for the split engine; wired by InitForkEngine.
	forkScanner *forkWalletScanner

	// chainTip reads the height from the wallet chain source (esplora or
	// electrum), so an electrum wallet gets a tip with no local Core.
	chainTip ChainTipSource

	// clearedMark is the block an eCash rewind lifted the bar from, kept so a
	// rollback can put that bar back. Guarded by swapNetworkMu, which every
	// eCash switch holds.
	clearedMark string

	// walletEngine is reset on a network swap; nil in tests that don't wire it.
	walletEngine *wallet.WalletEngine

	configs    map[string]BinaryConfig
	download   *DownloadManager
	process    *ProcessManager
	ownerMu    sync.Mutex
	ownerLock  *OwnerLock
	pidManager *PidFileManager
	clients    *lease.Lease
	log        zerolog.Logger

	// Dart: RPCConnection instances — one per binary, for persistent health monitoring
	monitors   map[string]*ConnectionMonitor
	monitorsMu sync.Mutex

	mu sync.RWMutex

	// coreVariantMu serialises the entire stop -> persist -> download -> restart
	// sequence so two concurrent SetCoreVariant calls can't race the on-disk
	// state into an inconsistent shape.
	coreVariantMu sync.Mutex

	// rejectMu serialises RejectBlock against AcceptBlock. A reject holds it
	// across the enforcer wait, so an accept cannot restore the branch the
	// reject still reconciles against.
	rejectMu sync.Mutex

	// testSidechainsMu serialises the stop -> persist -> wipe sequence for

	// swapNetworkMu serialises the stop -> persist -> restart sequence for
	// SwapNetwork. Same reason as coreVariantMu.
	swapNetworkMu sync.Mutex
	// pendingSwap records a swap that committed the network but failed before
	// the wallet was rebound, so calling SwapNetwork again resumes it.
	pendingSwap *pendingNetworkSwap

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
	explorerHeightsCache *CachedConnection[map[string]int64]

	// Cached chain-tip connections. Every chain (L1 bitcoind, enforcer, every
	// L2 sidechain) goes through the same CachedConnection[T] primitive: TTL
	// cache + single-flight + preserve-last-good-on-error. Only the underlying
	// Connection differs. bitcoindInfo is the single source of truth for
	// getblockchaininfo — both the rich external Connect RPC
	// (GetMainchainBlockchainInfo) and the lean GetSyncStatus dispatch read
	// through it via a projection, so one HTTP call per TTL covers both.
	syncConnMu        sync.Mutex
	bitcoindInfo      *CachedConnection[*MainchainBlockchainInfo]
	bitcoindSync      Connection[*ChainSyncResult]
	enforcerSync      *CachedConnection[*ChainSyncResult]
	sidechainSyncs    map[string]*CachedConnection[*ChainSyncResult]
	chainFork         *CachedConnection[*ChainForkState]
	chainStates       *CachedConnection[*CoreChainStates]
	chainSourceHeight *CachedConnection[int]

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
	explorerHTTPClient  *http.Client

	// stopBinary is the Stop primitive used by SetCoreVariant. Production wires
	// this to o.Stop; tests override it to inject force/graceful failures.
	stopBinary func(ctx context.Context, name string, force bool, options ...StopOptions) error

	// bootBitcoindForVariantSwap boots bitcoind after a variant swap. Returns
	// a channel that is closed when boot is complete. Production wires this to
	// the real boot helper; tests override it to bypass process spawning.
	bootBitcoindForVariantSwap func(ctx context.Context) <-chan StartupProgress

	// catalogURL is where the published network catalog is fetched from. Tests
	// point it at their own server.
	catalogURL string

	// coreReachable reports whether something answers on Core's RPC port.
	// Overridable so tests don't depend on what is listening on this machine.
	coreReachable func() bool

	// Detached-daemon lifecycle. See shutdown.go.
	shutdownMu    sync.Mutex
	shutdownState int32         // shutdownState* constants
	shutdownIdle  chan struct{} // closed when a drain completes; nil between drains

	// Bumped by every drain. Detached work that outlives its caller (the reset
	// restart) captures it up front and bails if it moved.
	shutdownGen atomic.Uint64
	// Drains that started but have not finished. A reset issued while one runs
	// cannot tell its own generation from the drain's, so it refuses instead.
	drainsActive atomic.Int64
}

// DownloadStateForTest exposes the DownloadManager's per-binary state to
// tests in sibling packages (e.g. api/) so they can poll for completion
// without subscribing to a stream. Returns ok=true while the download is
// in flight.
func (o *Orchestrator) DownloadStateForTest(name string) (DownloadState, bool) {
	return o.download.State(name)
}

// DownloadStates returns the live download snapshot for every binary the
// manager is currently fetching. Empty map means no in-flight downloads.
// Source of truth for the GetDownloadStatus RPC.
func (o *Orchestrator) DownloadStates() map[string]DownloadState {
	return o.download.States()
}

// New creates a new Orchestrator.
// SetOwnerLock records the lock this run holds. A nil lock means the install
// belongs to somebody else, so the drain leaves adopted binaries alone.
func (o *Orchestrator) SetOwnerLock(lock *OwnerLock) {
	o.ownerMu.Lock()
	defer o.ownerMu.Unlock()
	o.ownerLock = lock
}

// mayStopAdopted reports whether an adopted binary is ours to stop: a run of
// this install started it, and the owner lock proves no other install is alive
// to claim it.
func (o *Orchestrator) mayStopAdopted(name string) bool {
	return o.process.IsOrphan(name) && o.OwnsInstall()
}

// OwnsInstall reports whether this run holds the owner lock, and may therefore
// stop the binaries it finds running.
func (o *Orchestrator) OwnsInstall() bool {
	if o == nil {
		return false
	}
	o.ownerMu.Lock()
	defer o.ownerMu.Unlock()
	return o.ownerLock != nil
}

func New(dataDir, network, bitwindowDir string, configs []BinaryConfig, log zerolog.Logger) *Orchestrator {
	pidMgr := NewPidFileManager(dataDir, log)

	settings, err := NewSettingsStore(bitwindowDir)
	if err != nil {
		log.Warn().Err(err).Msg("orchestrator settings load failed, using defaults")
		settings = &SettingsStore{bitwindowDir: bitwindowDir, current: defaultOrchestratorSettings()}
	}

	downloads := NewDownloadManager(dataDir, ConfigFilePath(bitwindowDir), log)

	orch := &Orchestrator{
		releases:     NewReleaseChecker(downloads, log),
		DataDir:      dataDir,
		Network:      network,
		BitwindowDir: bitwindowDir,
		Settings:     settings,
		configs:      lo.SliceToMap(configs, func(c BinaryConfig) (string, BinaryConfig) { return c.Name, c }),
		rawConfigs:   lo.SliceToMap(configs, func(c BinaryConfig) (string, BinaryConfig) { return c.Name, c }),
		download:     downloads,
		process:      NewProcessManager(dataDir, pidMgr, log),
		pidManager:   pidMgr,
		monitors:     make(map[string]*ConnectionMonitor),
		log:          log.With().Str("component", "orchestrator").Logger(),
	}

	// Variant resolver shared by download + process managers.
	variantResolver := func(c BinaryConfig) (CoreVariantSpec, bool) {
		return ResolveCoreVariant(c, orch.Settings.CoreVariant(), orch.CurrentNetwork())
	}
	orch.download.CoreVariant = func() (CoreVariantSpec, bool) {
		// Through the locked accessor: a config reload rewrites this map while
		// Status reads it on another goroutine.
		cfg, err := orch.getConfig("bitcoind")
		if err != nil {
			return CoreVariantSpec{}, false
		}
		return variantResolver(cfg)
	}
	orch.process.CoreVariant = variantResolver

	// Sidechain variant resolver: returns the alt fields from BinaryConfig,
	// which are the Flutter frontend build. A layer-2 binary without them, and
	// a caller that asks for ForceBackend, fall back to the production daemon.
	sidechainVariantResolver := func(c BinaryConfig) (sidechainVariantSpec, bool) {
		if c.ChainLayer != 2 || c.AltBinaryName == "" {
			return sidechainVariantSpec{}, false
		}
		fileName := fileForPlatform(c.AltFiles)
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
	orch.coreReachable = orch.dialCoreRPC
	orch.catalogURL = netcatalog.DefaultURL

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
			orch.setNetwork(string(bitcoinConf.Network))
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
// enforcerReachable reports whether the enforcer answers RPC, whether or not
// this process started it. A connect-only enforcer never enters ProcessManager.
func (o *Orchestrator) enforcerReachable() bool {
	if o.process.IsRunning("enforcer") {
		return true
	}
	o.monitorsMu.Lock()
	mon, ok := o.monitors["enforcer"]
	o.monitorsMu.Unlock()
	return ok && mon.Connected()
}

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
		pidPath := filepath.Join(o.BitcoinConf.DataDir(), "bitcoind.pid")

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
	if o.rawConfigs == nil {
		o.rawConfigs = make(map[string]BinaryConfig, len(configs))
	}
	for _, c := range configs {
		o.rawConfigs[c.Name] = c
		o.configs[c.Name] = expandECashPlaceholder(c, o.ecashID)
	}
}

// Download downloads a binary if missing (or forces re-download).
func (o *Orchestrator) Download(ctx context.Context, name string, force bool, options ...DownloadOptions) (<-chan DownloadProgress, error) {
	var opts DownloadOptions
	if len(options) > 0 {
		opts = options[0]
	}
	config, err := o.getConfig(name)
	if err != nil {
		return nil, err
	}
	return o.download.DownloadWithOptions(ctx, config, o.Network, force, opts)
}

// Start starts a binary with the given args and env.
func (o *Orchestrator) Start(ctx context.Context, name string, args []string, env map[string]string) (int, error) {
	config, err := o.getConfig(name)
	if err != nil {
		return 0, err
	}
	// A layer-2 binary starts its frontend, which then asks for the backend slot
	// under this same name, so the frontend takes the GUI slot instead.
	if config.ChainLayer == 2 && o.process.SidechainVariant != nil {
		if sv, ok := o.process.SidechainVariant(config); ok {
			guiName := sidechainGUIProcessName(config.Name)
			return o.process.StartWithOptions(ctx, config, args, env, ProcessStartOptions{
				ProcessName: guiName,
				PidName:     guiName,
				// A Linux bundle reads its sibling lib/ and data/ trees.
				WorkDir: filepath.Dir(TestSidechainBinaryPath(o.DataDir, sv.BinaryName)),
			})
		}
	}
	return o.process.Start(ctx, config, args, env)
}

// Stop stops a running binary and marks its monitor as stopped so
// the restart timer won't automatically bring it back.
// StopOptions tweaks Stop behaviour per-call.
type StopOptions struct {
	// ForceBackend leaves the sidechain's GUI companion running. Set by
	// sidechain Flutter apps, which are that companion.
	ForceBackend bool
}

func (o *Orchestrator) Stop(ctx context.Context, name string, force bool, options ...StopOptions) error {
	var opts StopOptions
	if len(options) > 0 {
		opts = options[0]
	}

	// Validate the target up front so stopping an unknown/typo'd binary is a
	// real error rather than a silent no-op success. A known-but-not-running
	// binary still passes here and is handled as a no-op below.
	if _, err := o.getConfig(name); err != nil {
		return err
	}

	// Flip "stopping" before sending the signal so the frontend shows
	// a stopping badge during the graceful-shutdown window. MarkStopped
	// below clears the flag once the process has actually exited.
	o.monitorsMu.Lock()
	if mon, ok := o.monitors[name]; ok {
		mon.SetStopping(true)
	}
	o.monitorsMu.Unlock()

	var guiErr error
	if !opts.ForceBackend {
		_, guiErr = o.stopSidechainGUI(ctx, name, force)
	}

	// Stopping a daemon that isn't running is a no-op success, not an error:
	// first-launch wallet restore stops the L1 stack before rebooting, and on
	// first launch those daemons were never started.
	var err error
	if o.process.IsRunning(name) {
		err = o.process.Stop(ctx, name, force)
	}

	// Always mark the monitor as stopped, even if process.Stop failed
	// (e.g. "not running"). This ensures the restart timer won't
	// try to bring it back after a manual stop.
	o.monitorsMu.Lock()
	if mon, ok := o.monitors[name]; ok {
		mon.MarkStopped()
	}
	o.monitorsMu.Unlock()

	if err != nil {
		return err
	}
	return guiErr
}

func (o *Orchestrator) stopSidechainGUI(ctx context.Context, name string, force bool) (bool, error) {
	guiName := sidechainGUIProcessName(name)
	if !o.process.IsRunning(guiName) {
		return false, nil
	}
	adopted := o.process.IsAdopted(guiName)
	if err := o.process.Stop(ctx, guiName, force || adopted); err != nil {
		return true, fmt.Errorf("stop %s GUI: %w", name, err)
	}
	if adopted {
		o.process.Remove(guiName)
		_ = o.pidManager.DeletePidFile(guiName)
	}
	return true, nil
}

// Status returns the current status of a binary.
func (o *Orchestrator) Status(name string) BinaryStatus {
	return o.StatusWithOptions(name, DownloadOptions{})
}

// StatusWithOptions returns the current status of a binary. ForceBackend skips
// the test sidechain resolver, so a sidechain app reports the daemon it runs
// instead of the test build BitWindow launches.
func (o *Orchestrator) StatusWithOptions(name string, opts DownloadOptions) BinaryStatus {
	config, err := o.getConfig(name)
	if err != nil {
		return BinaryStatus{Name: name, Error: err.Error()}
	}

	proc := o.process.Get(name)
	// requestedPath is the download this caller's own options select. A running
	// process can come from the other one — a sidechain app boots its prod
	// backend under the same name — so the release check must not read its path.
	requestedPath := BinaryPath(o.DataDir, config.BinaryName)
	if config.IsMainchainCore() && o.process.CoreVariant != nil {
		if v, ok := o.process.CoreVariant(config); ok {
			requestedPath = CoreBinaryPath(o.DataDir, v, config.BinaryName)
		}
	}
	if o.process.SidechainVariant != nil && !opts.ForceBackend {
		if sv, ok := o.process.SidechainVariant(config); ok {
			requestedPath = TestSidechainBinaryPath(o.DataDir, sv.BinaryName)
		}
	}
	_, statErr := os.Stat(requestedPath)
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
		status.BinaryPath = requestedPath
	}

	if o.releases != nil {
		if check, ok := o.releases.Check(config, o.CurrentNetwork(), requestedPath); ok {
			status.UpdateAvailable = check.UpdateAvailable()
			status.RemoteTimestamp = check.Remote
			status.LocalTimestamp = check.Local
		}
	}

	if proc != nil {
		status.Running = true
		status.Pid = proc.Pid
		status.Uptime = time.Since(proc.Started)
	}

	// Quick port probe if not already known to be running.
	if config.Port > 0 && !status.Running {
		conn, err := net.DialTimeout("tcp", config.RPCAddr(), 200*time.Millisecond)
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
	return o.ListAllWithOptions(DownloadOptions{})
}

// ListAllWithOptions is ListAll with the force-backend lever of
// StatusWithOptions.
func (o *Orchestrator) ListAllWithOptions(opts DownloadOptions) []BinaryStatus {
	// Snapshot names and release before Status: it re-acquires o.mu via
	// getConfig, and a queued writer would deadlock the nested read lock.
	o.mu.RLock()
	names := make([]string, 0, len(o.configs))
	for name := range o.configs {
		names = append(names, name)
	}
	o.mu.RUnlock()

	statuses := make([]BinaryStatus, 0, len(names))
	for _, name := range names {
		statuses = append(statuses, o.StatusWithOptions(name, opts))
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
	proc := o.logProcess(name)
	if proc == nil {
		return nil, nil, fmt.Errorf("%s is not running", name)
	}
	ch, cancel := proc.Subscribe()
	return ch, cancel, nil
}

// RecentLogs returns the most recent log entries for a binary.
func (o *Orchestrator) RecentLogs(name string, n int) ([]LogEntry, error) {
	proc := o.logProcess(name)
	if proc == nil {
		return nil, fmt.Errorf("%s is not running", name)
	}
	return proc.RecentLogs(n), nil
}

// logProcess resolves a logical binary name to the process that holds its logs.
// A sidechain the user starts runs as its frontend in the GUI slot, so asking
// for "thunder" before its backend registers must reach that frontend.
func (o *Orchestrator) logProcess(name string) *ManagedProcess {
	if proc := o.process.Get(name); proc != nil {
		return proc
	}
	return o.process.Get(sidechainGUIProcessName(name))
}

// prefetchBinary downloads a binary in the background and signals completion
// on the returned channel (nil = success, non-nil = failure). Used to
// parallelise enforcer + target downloads with bitcoind's IBD so the binaries
// are already on disk when it's their turn to start.
//
// Safe to call even if the binary is already downloaded — DownloadManager
// short-circuits with a single Done message in that case.
func (o *Orchestrator) prefetchBinary(ctx context.Context, cfg BinaryConfig, forceBackend bool) <-chan error {
	done := make(chan error, 1)
	go func() {
		defer close(done)
		progressCh, err := o.download.DownloadWithOptions(ctx, cfg, o.Network, false, DownloadOptions{ForceBackend: forceBackend})
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
	if err := o.refuseWhileParked(); err != nil {
		return nil, err
	}
	// Mainnet, forknet and eCash keep their chain outside the platform default,
	// so booting before the user picks a directory syncs a second copy over
	// whatever they already run. The node mode gate above and this one are the
	// only gates here, so no frontend can force the local stack up.
	if plan := o.PlanNetworkChange(NetworkChangeRequest{}); plan.MustSelectDatadir {
		return nil, fmt.Errorf("network %s has no data directory yet; pick one before starting the Bitcoin backends", plan.Network)
	}

	ch := make(chan StartupProgress, 100)

	go func() {
		defer close(ch)

		// Light mode reads the chain from a remote server, so the local L1 stack
		// never boots. An L1 target (bitcoind/enforcer) is then a no-op; a
		// sidechain target (ChainLayer 2) still starts, just without L1 under
		// it, since the caller asked for that binary. The node mode is the only
		// gate here, so no frontend can force the local stack up.
		skipLocalL1 := o.NodeMode() == NodeModeLight
		if skipLocalL1 && config.ChainLayer != 2 {
			o.log.Info().Str("target", target).Msg("light mode; skipping the local Bitcoin backends")
			ch <- StartupProgress{Stage: "skipped-l1", Message: "light mode — no local Bitcoin backends needed", Done: true}
			return
		}

		// A sidechain under an electrum wallet has no local enforcer at :50051,
		// so rewire it to the hosted orchestrator's mainchain service (or fail
		// cleanly if none exists) before any start path below launches it.
		if skipLocalL1 && !o.pointSidechainAtRemoteMainchain(config, &opts, ch) {
			return
		}

		// If a previous bitwindowd's drain is still in flight, adopt it:
		// flip the will-exit bit off and block until the drained stops
		// finish. UI surfacing happens via per-binary startup logs inside
		// the helper. No-op in the steady state.
		o.awaitDrainForBoot(ctx)

		if opts.Immediate {
			o.startTargetOnly(ctx, config, opts, ch, nil)
			return
		}

		// Kick off enforcer + target downloads in parallel with bitcoind's IBD.
		// By the time we need to start them, they're already on disk. If the
		// prefetch is still running when we need to start, we block on its
		// completion — which is no worse than the old sequential flow.
		var enforcerPrefetch <-chan error
		if !skipLocalL1 {
			enforcerPrefetch = o.prefetchBinary(ctx, o.configs["enforcer"], false)
		}
		var targetPrefetch <-chan error
		if config.Name != "enforcer" {
			targetPrefetch = o.prefetchBinary(ctx, config, opts.ForceBackend)
		}

		o.prepareCoreArgs(&opts)
		o.prepareEnforcerArgs(&opts)
		o.prepareSidechainArgs(config, &opts)
		o.injectSidechainStarter(config, &opts)
		o.injectHeadlessForForcedBackend(config, &opts)

		// Electrum: skip the local L1 boot entirely and start the target alone.
		if !skipLocalL1 {
			if !o.startBitcoindOnly(ctx, opts, ch) {
				return
			}

			o.startEnforcerWhenReady(ctx, opts, enforcerPrefetch)

			// Wait for enforcer's gRPC port to actually accept dials before
			// launching the sidechain target. startEnforcerWhenReady returns
			// once it has spawned the process — the gRPC bind on :50051 lands
			// 2-3s later. Without this wait, sidechain backends race the bind
			// and exit with "tcp connect error" against the CUSF mainchain
			// service. Gated on ChainLayer == 2 so the L1 binaries (bitcoind,
			// enforcer as target) don't wait on themselves.
			if config.ChainLayer == 2 {
				enforcerCfg := o.configs["enforcer"]
				enforcerMon := o.getOrCreateMonitor("enforcer", NewHealthChecker(enforcerCfg), enforcerStartupPatterns)
				if errMsg := enforcerMon.ConnectionError(); errMsg != "" {
					failBoot(enforcerMon, ch, "wait for enforcer", fmt.Errorf("%s", errMsg))
					return
				}
				if err := waitForConnectedOrExit(ctx, enforcerMon, o.process.Get("enforcer")); err != nil {
					failBoot(enforcerMon, ch, "wait for enforcer", err)
					return
				}
			}
		}

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
	opts.CoreArgs = []string{
		fmt.Sprintf("-conf=%s", confPath),
		fmt.Sprintf("-datadir=%s", o.BitcoinConf.RootDataDir()),
	}
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

// prepareSidechainArgs fills opts.TargetArgs from the sidechain's conf. Without
// it a layer-2 daemon gets no network or port flags at all and boots on its own
// built-in signet default. Merges per flag rather than bailing out on a
// non-empty TargetArgs, so an override the caller already placed — electrum's
// --mainchain-grpc-url — wins on that flag and still gets the rest of the conf.
func (o *Orchestrator) prepareSidechainArgs(config BinaryConfig, opts *StartOpts) {
	if config.ChainLayer != 2 || config.IsBitcoinCore {
		return
	}
	scm := o.SidechainConfs[config.Name]
	if scm == nil || scm.Spec.ConfOnly {
		return
	}
	// The conf's network and ports track the active L1 network.
	if err := scm.SyncNetworkFromBitcoinConf(); err != nil {
		o.log.Warn().Err(err).Str("binary", config.Name).Msg("failed to sync sidechain conf from bitcoin conf")
	}
	preset := make(map[string]bool, len(opts.TargetArgs))
	for _, arg := range opts.TargetArgs {
		preset[cliFlagName(arg)] = true
	}
	var fromConf []string
	for _, arg := range scm.GetCliArgs() {
		if !preset[cliFlagName(arg)] {
			fromConf = append(fromConf, arg)
		}
	}
	opts.TargetArgs = append(fromConf, opts.TargetArgs...)
	o.log.Info().Str("binary", config.Name).Strs("target_args", opts.TargetArgs).Msg("auto-built sidechain args from config")
}

// cliFlagName is the --flag part of a "--flag=value" or "--flag" argument.
func cliFlagName(arg string) string {
	name, _, _ := strings.Cut(arg, "=")
	return name
}

// injectSidechainStarter writes the sidechain seed to a temp file and appends
// --mnemonic-seed-phrase-path=... to opts.TargetArgs for chainLayer==2 binaries.
// Dart binary_provider.dart L314-326.
func (o *Orchestrator) injectSidechainStarter(config BinaryConfig, opts *StartOpts) {
	if config.ChainLayer != 2 || config.Slot <= 0 || o.WalletSvc == nil {
		return
	}
	// Core exits on an unknown option, so a Core derived sidechain takes the
	// same starter over RPC instead — see ensureCoreSidechainWallet.
	if config.IsBitcoinCore {
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

// ensureCoreSidechainWallet gives a Core derived sidechain the wallet its slot
// starter describes, which is what the CUSF chains get from the seed flag. The
// node must be accepting RPC; Core creates no wallet on its own, so without
// this every wallet call answers "no wallet is loaded".
func (o *Orchestrator) ensureCoreSidechainWallet(ctx context.Context, cfg BinaryConfig) error {
	if !cfg.IsBitcoinCore || cfg.ChainLayer != 2 || cfg.Slot <= 0 || o.WalletSvc == nil {
		return nil
	}
	mnemonic, err := o.WalletSvc.GetOrDeriveSidechainStarter(cfg.Slot, cfg.DisplayName)
	if err != nil {
		return fmt.Errorf("sidechain starter: %w", err)
	}
	dirs, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return fmt.Errorf("no directory config for %s", cfg.Name)
	}
	cookiePath := filepath.Join(dirs.DatadirNetwork(config.Network(o.Network), ""), ".cookie")
	user, password, err := config.ReadCookieFile(cookiePath)
	if err != nil {
		return err
	}
	rpc := wallet.NewCoreRPCClient(wallet.StaticCoreEndpoint(cfg.RPCHost(), cfg.Port, user, password))
	return wallet.EnsureCoreWalletFromMnemonic(
		ctx, rpc, o.log, sidechain.CoreWalletName, mnemonic, o.NetParams.Resolve(),
	)
}

var errNoMainchainForSidechain = errors.New("this sidechain needs a local enforcer, so it runs in full mode only")

// pointSidechainAtRemoteMainchain rewires a ChainLayer-2 target to a hosted
// orchestrator's CUSF mainchain service when the active wallet is electrum,
// which runs no local enforcer. The --mainchain-grpc-url CLI flag overrides the
// localhost:50051 value persisted in the sidechain's conf; without it the
// daemon dials a dead port and exits with an opaque "tcp connect error".
// Returns false — boot already failed on ch — when the sidechain has no remote
// mainchain to reach, so we never launch a daemon that cannot work.
func (o *Orchestrator) pointSidechainAtRemoteMainchain(cfg BinaryConfig, opts *StartOpts, ch chan<- StartupProgress) bool {
	fail := func() bool {
		mon := o.getOrCreateMonitor(cfg.Name, NewHealthChecker(cfg), nil)
		failBoot(mon, ch, "start "+cfg.Name, errNoMainchainForSidechain)
		return false
	}

	// zmq-style sidechains (bitnames, bitassets) carry no mainchain-grpc-url and
	// have no way to reach a remote enforcer.
	scm := o.SidechainConfs[cfg.Name]
	if scm == nil || scm.Spec.PortStyle != "grpc" {
		return fail()
	}

	remote := config.RemoteOrchestratorURLForNetwork(config.Network(o.Network))
	if remote == "" {
		return fail()
	}

	opts.TargetArgs = append(opts.TargetArgs, "--mainchain-grpc-url="+remote)
	o.log.Info().Str("binary", cfg.Name).Str("mainchain-grpc-url", remote).
		Msg("electrum wallet active — pointing sidechain at remote mainchain")
	return true
}

// injectHeadlessForForcedBackend appends --headless to opts.TargetArgs when a
// sidechain frontend asked us to launch the real Rust backend (ForceBackend).
// Without this, the backend pops its built-in GUI and the user ends up with
// two windows for the same sidechain.
func (o *Orchestrator) injectHeadlessForForcedBackend(config BinaryConfig, opts *StartOpts) {
	if !opts.ForceBackend || config.ChainLayer != 2 {
		return
	}
	if slices.Contains(opts.TargetArgs, "--headless") {
		return
	}
	opts.TargetArgs = append(opts.TargetArgs, "--headless")
}

// startBitcoindOnly handles the bitcoind portion of a chain boot.
// Returns true on success (or already-running), false on fatal failure
// (failBoot has already surfaced the error to the UI in that case).
//
// parkedStateOutstanding names a live path a swap moved aside and never brought
// back. A daemon started over one builds fresh state, and the restore then
// refuses to overwrite it — so the real copy strands.
//
// It reports the paths rather than restoring them: a conf write that failed
// half way makes o.Network stale, and restoring on a stale network puts the
// outgoing state where the incoming one looks. Only a start reads the conf
// again, so recovery belongs there.
func (o *Orchestrator) parkedStateOutstanding() []string {
	var outstanding []string
	active := config.Network(o.Network)
	for path := range o.swapStatePaths(active) {
		if _, err := os.Stat(path); err == nil {
			continue
		}
		if _, ok := latestParkedPath(path, active); ok {
			outstanding = append(outstanding, path)
		}
	}
	return outstanding
}

// refuseWhileParked stops a daemon start while a swap's state is still aside.
func (o *Orchestrator) refuseWhileParked() error {
	outstanding := o.parkedStateOutstanding()
	if len(outstanding) == 0 {
		return nil
	}
	return fmt.Errorf(
		"a network change left state aside and could not bring it back — restart BitWindow to finish it (%s)",
		strings.Join(outstanding, ", "),
	)
}

// Dart parity: rpc_connection.dart L197-232 initBinary pattern.// Dart parity: rpc_connection.dart L197-232 initBinary pattern.
//  1. startConnectionTimer() — pings once, then starts 1s timer
//  2. if (connected) → "already running, not booting" → return
//  3. else → bootProcess() → wait for connection
func (o *Orchestrator) startBitcoindOnly(ctx context.Context, opts StartOpts, ch chan<- StartupProgress) (started bool) {
	// A UTXO snapshot can only be loaded against a live, RPC-reachable node, so
	// every path that brings bitcoind up gets the apply for free rather than
	// each caller having to remember it.
	defer func() {
		if !started {
			return
		}
		o.maybeApplySnapshot(ctx, ch)
	}()

	coreCfg := o.configs["bitcoind"]
	var coreHealthOpts HealthCheckOpts
	if o.BitcoinConf != nil {
		if coreCfg.Port == 0 {
			coreCfg.Port = o.BitcoinConf.GetRPCPort()
		}
		coreHealthOpts.Credentials = o.BitcoinConf.GetRPCCredentials
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
			proc := o.process.LatestRun("bitcoind")
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
		o.exitedFunc("bitcoind"),
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
func (o *Orchestrator) RestartDaemon(ctx context.Context, name string, options ...StopOptions) (<-chan StartupProgress, error) {
	var opts StopOptions
	if len(options) > 0 {
		opts = options[0]
	}

	config, err := o.getConfig(name)
	if err != nil {
		return nil, err
	}
	if err := o.refuseWhileParked(); err != nil {
		return nil, err
	}

	ch := make(chan StartupProgress, 100)

	go func() {
		defer close(ch)

		// Capture the original boot mode before Stop drops the ManagedProcess
		// record. Without this, restarting a sidechain that was launched with
		// --force-backend forgets the flag and spawns the flutter_frontend
		// variant instead — a second GUI window on top of the existing one.
		forceBackend := opts.ForceBackend || o.process.ForceBackendFor(name)

		// Best-effort stop. If the binary isn't running, fall straight through
		// to start.
		if o.process.IsRunning(name) {
			ch <- StartupProgress{Stage: "stopping-" + name, Message: fmt.Sprintf("stopping %s...", config.DisplayName)}
			stopOpts := StopOptions{ForceBackend: forceBackend}
			if err := o.Stop(ctx, name, false, stopOpts); err != nil {
				o.log.Warn().Err(err).Str("binary", name).Msg("graceful stop failed during restart, escalating to SIGKILL")
				if killErr := o.Stop(ctx, name, true, stopOpts); killErr != nil {
					o.log.Error().Err(killErr).Str("binary", name).Msg("force kill also failed during restart")
					ch <- StartupProgress{Error: fmt.Errorf("stop %s: %w", name, killErr)}
					return
				}
			}
		}

		opts := StartOpts{ForceBackend: forceBackend}

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
			o.prepareSidechainArgs(config, &opts)
			o.injectSidechainStarter(config, &opts)
			o.injectHeadlessForForcedBackend(config, &opts)
			// startTargetOnly emits its own "done" event.
			o.startTargetOnly(ctx, config, opts, ch, nil)
		}
	}()

	return ch, nil
}

// exitedFunc reports the exit code of a binary's last run, for the restart timer.
func (o *Orchestrator) exitedFunc(name string) func() (int, bool) {
	return func() (int, bool) { return o.process.LastExit(name) }
}

// startEnforcerWhenReady waits for wallet + IBD completion, then starts the enforcer.
// If prefetched is non-nil, the enforcer binary is already being downloaded
// in parallel and we wait on its completion instead of starting a new download.
func (o *Orchestrator) startEnforcerWhenReady(ctx context.Context, opts StartOpts, prefetched <-chan error) {
	// A switch that could not finish its enforcer cleanup journalled it. Here,
	// because a leftover validator chain serves the retired generation.
	if err := o.ApplyPendingEnforcerWipe(); err != nil {
		o.log.Error().Err(err).Msg("could not clear the enforcer chain a switch left behind")
		mon := o.getOrCreateMonitor("enforcer", NewHealthChecker(o.configs["enforcer"]), enforcerStartupPatterns)
		mon.SetConnectionError(err.Error())
		mon.SetInitializing(false)
		return
	}

	// 1. Wait for wallet to exist — enforcer needs the L1 seed.
	if o.WalletSvc != nil && !o.WalletSvc.HasWallet() {
		o.log.Info().Msg("waiting for wallet before starting enforcer")
		sub := o.WalletSvc.Subscribe(ctx)
		for !o.WalletSvc.HasWallet() {
			select {
			case <-ctx.Done():
				return
			case <-sub:
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
			Str("core_rpc", fmt.Sprintf("%s:%d", o.BitcoinConf.GetRPCHost(), o.BitcoinConf.GetRPCPort())).
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

	// The enforcer runs with no wallet, so it takes no seed. Every arg a
	// caller carried over from an older config would seed a wallet that never
	// starts, and writing the L1 mnemonic to disk for it leaks the seed.
	filtered := make([]string, 0, len(opts.EnforcerArgs))
	for _, arg := range opts.EnforcerArgs {
		if !strings.HasPrefix(arg, "--wallet-seed-file") &&
			!strings.HasPrefix(arg, "--coinbase-recipient") {
			filtered = append(filtered, arg)
		}
	}
	opts.EnforcerArgs = filtered

	// With no wallet the enforcer cannot derive a payout address, and it
	// refuses to serve block templates without one. Pay to the starter wallet.
	if o.WalletSvc != nil {
		recipient, err := o.WalletSvc.CoinbaseRecipient(o.NetParams.Resolve())
		if err != nil {
			o.log.Error().Err(err).Msg("refusing to start the enforcer with no coinbase recipient")
			enforcerMon.SetConnectionError(fmt.Sprintf("cannot start the enforcer without a payout address: %v", err))
			enforcerMon.SetInitializing(false)
			return
		}
		opts.EnforcerArgs = append(opts.EnforcerArgs, fmt.Sprintf("--coinbase-recipient=%s", recipient))
		o.log.Info().Str("address", recipient).Msg("the block reward pays to the starter wallet")
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
			_, err := o.process.Start(restartCtx, o.configs["enforcer"], enfOpts.EnforcerArgs, enforcerEnv())
			return err
		},
		o.exitedFunc("enforcer"),
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

	// Log the literal argv at the actual spawn site: the auto-built-args log in
	// prepareEnforcerArgs fires before the seed args are stripped. Helps
	// diagnose "precisely one of rpc user and cookie must be set" -class errors
	// (#1712), where the question is whether --node-rpc-user reaches the binary.
	o.log.Info().Strs("argv", opts.EnforcerArgs).Msg("starting enforcer with final argv")

	if _, err := o.process.Start(ctx, enforcerCfg, opts.EnforcerArgs, enforcerEnv()); err != nil {
		enforcerMon.SetInitializing(false)
		o.log.Error().Err(err).Msg("failed to start enforcer")
		return
	}

	o.log.Info().Msg("enforcer started")
}

// enforcerEnv returns the environment overlay applied when launching the
// enforcer. RUST_BACKTRACE is set so panics emit a backtrace in the logs we
// already capture — without it the user sees only "the enforcer crashed",
// which is useless for triage.
func enforcerEnv() map[string]string {
	return map[string]string{
		"RUST_BACKTRACE": "1",
	}
}

// If prefetched is non-nil, the target binary is already being downloaded in
// parallel and we wait on its completion instead of starting a new download.
func (o *Orchestrator) startTargetOnly(ctx context.Context, config BinaryConfig, opts StartOpts, ch chan<- StartupProgress, prefetched <-chan error) {
	var startupPatterns []string
	var healthOpts HealthCheckOpts
	if config.IsMainchainCore() && o.BitcoinConf != nil {
		if config.Port == 0 {
			config.Port = o.BitcoinConf.GetRPCPort()
		}
		healthOpts.Credentials = o.BitcoinConf.GetRPCCredentials
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

	// A call that opens the frontend must reach the launch below even when the
	// backend already answers: a backend that outlived its window would
	// otherwise stop Start from opening the window again.
	opensFrontend := false
	if !opts.ForceBackend && config.ChainLayer == 2 && o.process.SidechainVariant != nil {
		_, opensFrontend = o.process.SidechainVariant(config)
	}

	if targetMon.Connected() {
		// Adopt first, whichever way this call goes. An unadopted daemon would
		// survive Stop, because Stop closes only what o.process tracks.
		if !o.process.IsRunning(config.Name) {
			pid := o.discoverPid(config)
			o.process.AdoptProcessWithOptions(config, pid, ProcessStartOptions{ForceBackend: opts.ForceBackend})
			o.log.Info().Str("binary", config.Name).Int("pid", pid).Msg("adopted externally-running target process")
		}

		if !opensFrontend {
			o.log.Info().Str("binary", config.Name).Msg("target already running, not booting")
			ch <- StartupProgress{Stage: "waiting-" + config.Name, Message: fmt.Sprintf("%s already running", config.DisplayName)}
			ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
			return
		}
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

		downloadCh, err := o.download.DownloadWithOptions(ctx, config, o.Network, false, DownloadOptions{ForceBackend: opts.ForceBackend})
		if err != nil {
			failBoot(targetMon, ch, "download "+config.Name, err)
			return
		}
		if err := forwardDownload(downloadCh, ch, "downloading-"+config.Name); err != nil {
			failBoot(targetMon, ch, "download "+config.Name, err)
			return
		}
	}

	// Launch the sidechain's own Flutter app as a managed GUI companion and stop
	// here. It uses a separate process slot, so the app's
	// StartWithL1(ForceBackend=true) callback can still start the real backend
	// daemon under config.Name while BitWindow's Stop(config.Name) closes the
	// GUI. It runs after the download above, because the bundle has to be on
	// disk before it can open.
	if opensFrontend {
		if sv, ok := o.process.SidechainVariant(config); ok {
			guiName := sidechainGUIProcessName(config.Name)
			if !o.process.IsRunning(guiName) {
				binPath := TestSidechainBinaryPath(o.DataDir, sv.BinaryName)
				o.log.Info().Str("binary", config.Name).Str("gui", guiName).Msg("launching test sidechain GUI")
				_, err := o.process.StartWithOptions(
					ctx,
					config,
					nil,
					nil,
					ProcessStartOptions{
						ProcessName: guiName,
						PidName:     guiName,
						WorkDir:     filepath.Dir(binPath),
					},
				)
				if err != nil {
					failBoot(targetMon, ch, "open "+config.Name, err)
					return
				}
			}
			targetMon.SetInitializing(false)
			ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s opened", config.DisplayName), Done: true}
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
		if err := o.ensureCoreSidechainWallet(ctx, config); err != nil {
			failBoot(targetMon, ch, "wallet for "+config.Name, err)
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
	procOpts := ProcessStartOptions{ForceBackend: opts.ForceBackend}

	targetMon.StartRestartTimer(ctx,
		func(restartCtx context.Context) error {
			_, err := o.process.StartWithOptions(restartCtx, config, targetArgs, targetEnv, procOpts)
			return err
		},
		o.exitedFunc(config.Name),
	)

	if _, err := o.process.StartWithOptions(ctx, config, targetArgs, targetEnv, procOpts); err != nil {
		failBoot(targetMon, ch, "start "+config.Name, err)
		return
	}
	targetProc := o.process.Get(config.Name)

	ch <- StartupProgress{Stage: "waiting-" + config.Name, Message: fmt.Sprintf("waiting for %s to accept connections...", config.DisplayName)}
	if err := waitForConnectedOrExit(ctx, targetMon, targetProc); err != nil {
		failBoot(targetMon, ch, "wait for "+config.Name, err)
		return
	}

	if err := o.ensureCoreSidechainWallet(ctx, config); err != nil {
		failBoot(targetMon, ch, "wallet for "+config.Name, err)
		return
	}

	ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
}

func sidechainGUIProcessName(name string) string {
	return name + "-gui"
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
	o.shutdownGen.Add(1)
	o.drainsActive.Add(1)
	running := o.process.ListRunning()
	ch := make(chan ShutdownProgress, len(running)+1)

	go func() {
		defer close(ch)
		defer o.drainsActive.Add(-1)

		total := len(running)
		completed := 0

		// Sort: stop sidechains first, then enforcer, then bitcoind
		ordered := orderForShutdown(running)

		for _, name := range ordered {
			// Skipping every adopted binary is what made one bad exit permanent.
			if o.process.IsAdopted(name) && !o.mayStopAdopted(name) {
				o.log.Info().Str("binary", name).Msg("not ours to stop, skipping shutdown")
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

	// Any other error may follow a request that landed: bitcoind answers `stop`
	// and then drops the connection while it flushes, and re-signaling it there
	// can corrupt on-disk state. Wait that one out.
	if unreachable(rpcErr) {
		o.log.Info().Err(rpcErr).Str("binary", name).Msg("stop RPC never reached the daemon, signalling instead")
		return false
	}

	if o.process.WaitForExit(name, gracefulKillTimeout) {
		o.log.Info().Err(rpcErr).Str("binary", name).Msg("stopped via RPC")
		return true
	}

	o.log.Warn().Err(rpcErr).Str("binary", name).Msg("RPC stop did not finish; falling back to signal")
	return false
}

// errNoStopClient means the stop RPC had nothing to send the request with.
var errNoStopClient = errors.New("no stop client")

// unreachable reports whether the stop RPC never got to the daemon, so no
// shutdown is under way and waiting for one buys nothing.
func unreachable(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, errNoStopClient) {
		return true
	}
	if errors.Is(err, syscall.ECONNREFUSED) || errors.Is(err, syscall.EHOSTUNREACH) {
		return true
	}
	var netErr *net.OpError
	return errors.As(err, &netErr) && netErr.Op == "dial"
}

func (o *Orchestrator) callBitcoindStopRPC() error {
	client, err := o.CoreStatusClient()
	if err != nil {
		return fmt.Errorf("bitcoind RPC stop: %w: %w", errNoStopClient, err)
	}
	// Detached: a near-expired upstream ctx would force an unsafe fallback.
	rpcCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	return client.Stop(rpcCtx)
}

func (o *Orchestrator) callSidechainStopRPC(cfg BinaryConfig) error {
	proxy := sidechain.NewJSONRPCProxy(cfg.RPCHost(), cfg.Port)
	rpcCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	return proxy.Stop(rpcCtx)
}

func (o *Orchestrator) callEnforcerStopRPC() error {
	cfg, ok := o.Configs()["enforcer"]
	if !ok || cfg.Port == 0 {
		return fmt.Errorf("enforcer RPC stop: %w: no config", errNoStopClient)
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
		cfg.RPCURL(),
		connect.WithGRPC(),
	)
	rpcCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	_, err := client.Stop(rpcCtx, connect.NewRequest(&enforcerpb.StopRequest{}))
	return err
}

// AdoptOrphans reads PID files from a previous session and adopts any
// processes that are still alive. A layer-2 binary writes thunder-test.pid for
// the frontend build and thunder.pid for a ForceBackend daemon, so the
// frontend build is adopted first.
func (o *Orchestrator) AdoptOrphans(ctx context.Context) error {
	pids := o.pidManager.ListPidFiles()
	pidNames := make([]string, 0, len(pids))
	for pidName := range pids {
		pidNames = append(pidNames, pidName)
	}
	sort.SliceStable(pidNames, func(i, j int) bool {
		return adoptPriority(pidNames[i]) < adoptPriority(pidNames[j])
	})

	for _, pidName := range pidNames {
		pid := pids[pidName]
		// A prod PID file stays eligible: a sidechain Flutter app runs its own
		// backend with --force-backend. A GUI companion PID file is adopted too,
		// so Stop() can clean up a frontend the orchestrator opened.
		isTestPid := strings.HasSuffix(pidName, "-test")
		isGUIPid := strings.HasSuffix(pidName, "-gui")

		realBinaryName := pidName
		if isGUIPid {
			realBinaryName = strings.TrimSuffix(pidName, "-gui")
		} else if isTestPid {
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

		binPath := BinaryPath(o.DataDir, config.BinaryName)
		if isGUIPid {
			config.Name = sidechainGUIProcessName(config.Name)
			if config.AltBinaryName != "" {
				binPath = TestSidechainBinaryPath(o.DataDir, config.AltBinaryName)
			} else {
				binPath = TestSidechainBinaryPath(o.DataDir, realBinaryName)
			}
		} else if isTestPid {
			// A -test PID is a frontend from an older layout. It goes in the GUI
			// slot, so the backend slot stays free for <sidechain>.pid.
			config.Name = sidechainGUIProcessName(config.Name)
			binPath = TestSidechainBinaryPath(o.DataDir, realBinaryName)
		} else if config.IsMainchainCore() && o.process.CoreVariant != nil {
			if v, ok := o.process.CoreVariant(config); ok {
				binPath = CoreBinaryPath(o.DataDir, v, config.BinaryName)
			}
		}
		o.process.AdoptProcessResolved(config, pid, binPath, pidName, false)
		o.log.Info().Str("binary", config.Name).Int("pid", pid).Msg("adopted orphaned process")
	}

	return nil
}

func adoptPriority(pidName string) int {
	if strings.HasSuffix(pidName, "-test") {
		return 0
	}
	return 1
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
		if o.pendingSwap == nil || o.pendingSwap.network != n {
			return nil
		}
		// A tail an eCash fork switch left owes more than the restart: the two
		// records, the enforcer conf, the wallet scans and the caches.
		if o.pendingSwap.fromECashID != "" {
			o.mu.RLock()
			toID := o.ecashID
			o.mu.RUnlock()
			return o.finishECashSwitch(o.pendingSwap.fromECashID, toID, o.pendingSwap.restartL1)
		}
		return o.finishNetworkSwap(n, o.pendingSwap.restartL1)
	}
	// A tail an eCash switch left must not outlive the swap that replaces it:
	// its records still name the outgoing fork, and this swap strips the conf
	// sentinel that says otherwise.
	if err := o.drainECashTail(); err != nil {
		return err
	}

	plan := o.PlanNetworkChange(NetworkChangeRequest{Network: string(n)})
	if plan.MustSelectDatadir {
		return fmt.Errorf("datadir not configured for %s", n)
	}
	if plan.NoChainSource {
		return fmt.Errorf("%s has no chain source for an electrum wallet: switch to a wallet with a local node first", n)
	}

	bitcoindWasRunning := o.process.IsRunning("bitcoind")
	enforcerWasRunning := o.process.IsRunning("enforcer")
	// Read before the stops below, which make both daemons read as stopped.
	restartL1 := o.owedRestartL1()

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

	if err := o.parkOutgoingSwapState(); err != nil {
		return err
	}

	// Both failures leave the state parked on purpose. A write that got as far
	// as naming n makes o.Network stale, and restoring on that would put the
	// outgoing state at the live paths for a conf that names the target — which
	// then opens the previous network's database. The next start reads the conf
	// and restores whatever it names, whichever way the write landed.
	if err := o.BitcoinConf.UpdateNetwork(n); err != nil {
		o.log.Warn().Err(err).Str("network", string(n)).
			Msg("network-swap state stays parked, the next start restores what the conf names")
		return fmt.Errorf("persist network: %w", err)
	}
	if err := o.BitcoinConf.LoadConfig(false); err != nil {
		o.log.Warn().Err(err).Str("network", string(n)).
			Msg("network-swap state stays parked, the next start restores what the conf names")
		return fmt.Errorf("reload config: %w", err)
	}
	o.setNetwork(string(n))
	o.clearNetworkSwapCaches()

	// Installed before the tail below, which can fail. Without it a retry reads
	// the network as already swapped, takes the no-op path and reports success
	// while the state is still parked and the daemons are still down.
	o.pendingSwap = &pendingNetworkSwap{network: n, restartL1: restartL1}
	return o.finishNetworkSwap(n, restartL1)
}

// pendingNetworkSwap is the tail of a swap whose network is already committed.
type pendingNetworkSwap struct {
	network   config.Network
	restartL1 bool
	// fromECashID is the network an eCash switch left. The retry rewrites the
	// enforcer conf with it, which is where the retired endpoint still sits.
	fromECashID string
}

// owedRestartL1 reports whether the L1 stack has to come back up: it runs now,
// or a switch that stopped it left the note that says so. Read it before any
// stop, which makes a running daemon read as stopped.
//
// Call it with swapNetworkMu held.
func (o *Orchestrator) owedRestartL1() bool {
	if o.process.IsRunning("bitcoind") || o.process.IsRunning("enforcer") {
		return true
	}
	return o.pendingSwap != nil && o.pendingSwap.restartL1
}

// finishNetworkSwap rebinds wallet state and restarts L1. Everything here is
// retryable: the caller keeps pendingSwap until it returns nil.
func (o *Orchestrator) finishNetworkSwap(n config.Network, restartL1 bool) error {
	// First, and on every retry: the network is durable by now, so this brings
	// back whatever it parked on its way out. A daemon started over an absent
	// path builds fresh state that a later park files above the real one.
	if err := o.RestoreParkedSwapState(); err != nil {
		return fmt.Errorf("restore the state %s parked: %w", n, err)
	}

	// Eager, before anything can read: wallet state derived from the outgoing
	// network must not outlive the swap.
	if o.walletEngine != nil {
		if err := o.walletEngine.ResetForNetwork(string(n)); err != nil {
			return fmt.Errorf("reset wallet state for %s: %w", n, err)
		}
	}

	if !restartL1 {
		o.pendingSwap = nil
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
	o.pendingSwap = nil
	return nil
}

// parkOutgoingSwapState moves the state a swap would otherwise destroy out of
// the way, filed under the network leaving. Its other half is
// RestoreParkedSwapState, which runs once the new network is durable.
//
// Sidechains keep one flat datadir and the enforcer shares directories between
// colliding networks, so both networks want the same paths. A delete would cost
// the user a full sidechain resync — and the enforcer's keys — every swap.
func (o *Orchestrator) parkOutgoingSwapState() error {
	from := config.Network(o.Network)
	moved := make(map[string]string)
	for path := range o.swapStatePaths(from) {
		switch _, err := os.Stat(path); {
		case os.IsNotExist(err):
			continue
		case err != nil:
			// Skipping on an unreadable path leaves the outgoing state in the
			// shared live path. Once access recovers the target opens it, and
			// its own parked copy stays ignored.
			o.unparkPartialMove(moved)
			return fmt.Errorf("read %s before parking it: %w", path, err)
		}
		outgoing, err := freeParkedPath(path, from)
		if err != nil {
			o.unparkPartialMove(moved)
			return err
		}
		if err := os.Rename(path, outgoing); err != nil {
			// Half a park is worse than none: the conf still names this
			// network while some of its state is gone from the live paths.
			o.unparkPartialMove(moved)
			return fmt.Errorf("park %s under %s: %w", path, from, err)
		}
		moved[path] = outgoing
		o.log.Info().Str("path", path).Str("parked_under", string(from)).
			Msg("parked network-swap state")
	}
	return nil
}

// unparkPartialMove puts back what a failed park already moved.
func (o *Orchestrator) unparkPartialMove(moved map[string]string) {
	for path, parked := range moved {
		if err := os.Rename(parked, path); err != nil {
			o.log.Error().Err(err).Str("path", path).Str("parked", parked).
				Msg("could not put back state a failed park moved")
		}
	}
}

// RestoreParkedSwapState brings back what the active network parked on its way
// out. It runs after a swap and at every start, so a crash between the park and
// the conf write costs nothing: the next start restores whatever the conf names.
//
// It never overwrites. A live path is the newer state by definition, and the
// parked copy under it stays on disk.
func (o *Orchestrator) RestoreParkedSwapState() error {
	active := config.Network(o.Network)
	for path := range o.swapStatePaths(active) {
		switch _, err := os.Stat(path); {
		case err == nil:
			continue
		case !os.IsNotExist(err):
			// A path we cannot read may hold live state. Restoring over it
			// would bury that; leaving it costs a retry.
			return fmt.Errorf("read %s before restoring it: %w", path, err)
		}
		incoming, ok := latestParkedPath(path, active)
		if !ok {
			continue
		}
		if err := os.Rename(incoming, path); err != nil {
			// Starting a daemon over an absent path builds fresh state, which a
			// later park files as the newest slot and hides the real one.
			return fmt.Errorf("restore %s from %s: %w", path, incoming, err)
		}
		o.log.Info().Str("path", path).Str("network", string(active)).
			Msg("restored parked network-swap state")
	}
	return nil
}

// swapStatePaths lists the live paths a swap has to move for network n: the
// sidechain stores it shares with every other network, the enforcer state that
// collides, and any path a park left behind.
func (o *Orchestrator) swapStatePaths(n config.Network) map[string]bool {
	paths := make(map[string]bool)
	for _, other := range config.AllNetworks() {
		for _, path := range enforcerNetworkSwapStatePaths(n, other) {
			paths[path] = true
		}
	}

	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}
	for _, c := range o.Configs() {
		if c.ChainLayer != 2 {
			continue
		}
		dc, ok := config.DirConfigByName(c.Name)
		if !ok {
			continue
		}
		networkDir := dc.DatadirNetwork(n, bitcoinOverride)
		// The names, not what stat can see: GetBlockchainDataPaths omits a path
		// it cannot read, and an omitted path never reaches the fail-closed
		// check in parkOutgoingSwapState.
		for _, name := range config.SidechainChainDataNames {
			paths[filepath.Join(networkDir, name)] = true
		}
		// The list above only reports files that exist, and a parked one does
		// not — so without this the swap home never finds its own state.
		for _, path := range parkedPathsFor(networkDir, n) {
			paths[path] = true
		}
	}
	return paths
}

// parkedPathsFor returns the live paths whose state n parked in dir, numbered
// slots included: an interrupted swap parks under a numbered one, and skipping
// those would leave that state stranded for good.
func parkedPathsFor(dir string, n config.Network) []string {
	suffix := ".network-" + string(n)
	seen := make(map[string]bool)
	var paths []string
	for _, pattern := range []string{"*" + suffix, "*" + suffix + ".*"} {
		matches, err := filepath.Glob(filepath.Join(dir, pattern))
		if err != nil {
			continue
		}
		for _, m := range matches {
			live := m[:strings.LastIndex(m, suffix)]
			if live == "" || seen[live] {
				continue
			}
			seen[live] = true
			paths = append(paths, live)
		}
	}
	return paths
}

// latestParkedPath returns the newest slot n parked, which is the highest
// numbered one. An interrupted swap parks the live state above an older copy
// nothing restored, so the number orders them.
func latestParkedPath(path string, n config.Network) (string, bool) {
	base := parkedPath(path, n)
	newest := ""
	for i := 0; i < 20; i++ {
		candidate := base
		if i > 0 {
			candidate = fmt.Sprintf("%s.%d", base, i)
		}
		if _, err := os.Stat(candidate); err == nil {
			newest = candidate
		}
	}
	return newest, newest != ""
}

// parkedPath is where path lives while another network runs.
func parkedPath(path string, n config.Network) string {
	return path + ".network-" + string(n)
}

// freeParkedPath returns a parked name nothing occupies. A swap interrupted
// before its restore leaves one behind, and overwriting it would delete the
// very state parking exists to keep.
func freeParkedPath(path string, n config.Network) (string, error) {
	base := parkedPath(path, n)
	for i := 0; i < 20; i++ {
		candidate := base
		if i > 0 {
			candidate = fmt.Sprintf("%s.%d", base, i)
		}
		if _, err := os.Stat(candidate); os.IsNotExist(err) {
			return candidate, nil
		}
	}
	return "", fmt.Errorf("no free parking slot for %s under %s", path, n)
}

// enforcerNetworkSwapStatePaths returns the enforcer state a swap from -> to
// must move. The enforcer files its validator chain and wallet per network, so
// both survive a swap untouched; state only has to move when the two networks
// share those directories, leaving the outgoing chain where the incoming one
// will look for its own.
func enforcerNetworkSwapStatePaths(from, to config.Network) []string {
	if !config.EnforcerNetworksCollide(from, to) {
		return nil
	}
	return []string{
		config.EnforcerValidatorDir(from),
		config.EnforcerWalletDir(from),
		filepath.Join(config.EnforcerDirs.RootDir(), config.EnforcerNetworkName(from)),
	}
}

// CurrentNetwork reads the active network, safe against a concurrent swap.
func (o *Orchestrator) CurrentNetwork() string {
	o.networkMu.RLock()
	defer o.networkMu.RUnlock()
	return o.Network
}

func (o *Orchestrator) setNetwork(n string) {
	o.networkMu.Lock()
	o.Network = n
	o.networkMu.Unlock()
}

func (o *Orchestrator) clearNetworkSwapCaches() {
	o.syncConnMu.Lock()
	o.explorerHeightsCache = nil
	o.bitcoindInfo = nil
	o.bitcoindSync = nil
	o.enforcerSync = nil
	o.sidechainSyncs = nil
	o.chainFork = nil
	o.chainStates = nil
	o.chainSourceHeight = nil
	o.syncConnMu.Unlock()

	o.httpClientsMu.Lock()
	o.coreStatusClient = nil
	o.coreStatusClientKey = ""
	o.enforcerHTTPClient = nil
	o.explorerHTTPClient = nil
	o.httpClientsMu.Unlock()

	// An endpoint the user picked for the outgoing network serves a different
	// chain, so the incoming network's default applies until they pick again.
	if o.Settings != nil && o.Settings.ElectrumServerURL() != "" {
		if err := o.PersistElectrumServerURL(""); err != nil {
			o.log.Error().Err(err).Msg("clear electrum server override on network swap")
		}
	}
}

// RestartL1 stops the L1 stack (enforcer + bitcoind) and boots it again on
// the current config. Running sidechains are left alone — they reconnect once
// the enforcer is back. This is the single server-side entry point for the
// "Restart Bitcoin Core and Enforcer" UI flow; the frontend must not
// hand-orchestrate stop/start itself. Stops are guarded by IsRunning, so a
// not-running daemon is skipped rather than treated as an error.
func (o *Orchestrator) RestartL1(ctx context.Context) error {
	if o.process.IsRunning("enforcer") {
		if err := o.stopForNetworkSwap(ctx, "enforcer"); err != nil {
			return err
		}
	}
	if o.process.IsRunning("bitcoind") {
		if err := o.stopForNetworkSwap(ctx, "bitcoind"); err != nil {
			return err
		}
	}

	// Fire-and-forget the L1 boot — returning lets the UI move on while
	// bitcoind IBD / enforcer wait run in the background. context.Background
	// so a request cancellation can't abort the launch mid-flight.
	bootCh, err := o.StartWithL1(context.Background(), "bitcoind", StartOpts{})
	if err != nil {
		return fmt.Errorf("restart L1 stack: %w", err)
	}
	go func() {
		for p := range bootCh {
			if p.Error != nil {
				o.log.Error().Err(p.Error).Msg("L1 stack restart failed")
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

// DefaultElectrumServerURL returns the built-in Esplora endpoint for the
// current network, the value used when the user has set no override.
func (o *Orchestrator) DefaultElectrumServerURL() string {
	urls := config.WalletChainSourceURLsForNetwork(config.NetworkFromString(o.Network))
	if len(urls) == 0 {
		return ""
	}
	return urls[0]
}

// ElectrumServerOverride returns the persisted user Esplora override, or ""
// when none is set (the network default applies).
func (o *Orchestrator) ElectrumServerOverride() string {
	if o.Settings == nil {
		return ""
	}
	return o.Settings.ElectrumServerURL()
}

// PersistElectrumServerURL stores a runtime Esplora endpoint override so it
// survives restart. An empty url clears the override (reset to default).
func (o *Orchestrator) PersistElectrumServerURL(url string) error {
	if o.Settings == nil {
		return fmt.Errorf("orchestrator settings not initialised")
	}
	_, err := o.Settings.SetElectrumServerURL(url)
	return err
}

// TorConfigOverride returns the persisted Tor routing preference (enabled,
// proxy address), or (false, "") when settings are unavailable.
func (o *Orchestrator) TorConfigOverride() (bool, string) {
	if o.Settings == nil {
		return false, ""
	}
	return o.Settings.TorConfig()
}

// PersistTorConfig stores the Tor routing preference so it survives restart.
func (o *Orchestrator) PersistTorConfig(enabled bool, proxy string) error {
	if o.Settings == nil {
		return fmt.Errorf("orchestrator settings not initialised")
	}
	_, _, err := o.Settings.SetTorConfig(enabled, proxy)
	return err
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

// EnforcerValidator returns a client for the enforcer's validator service.
func (o *Orchestrator) EnforcerValidator() (enforcerrpc.ValidatorServiceClient, error) {
	cfg, ok := o.Configs()["enforcer"]
	if !ok || cfg.Port == 0 {
		return nil, fmt.Errorf("enforcer not configured")
	}
	return enforcerrpc.NewValidatorServiceClient(o.enforcerHTTP(), cfg.RPCURL(), connect.WithGRPC()), nil
}

// ChainTip returns the mainchain tip the enforcer has validated.
func (o *Orchestrator) ChainTip(ctx context.Context) (string, int32, error) {
	validator, err := o.EnforcerValidator()
	if err != nil {
		return "", 0, err
	}
	resp, err := validator.GetChainTip(ctx, connect.NewRequest(&enforcerpb.GetChainTipRequest{}))
	if err != nil {
		return "", 0, err
	}
	info := resp.Msg.GetBlockHeaderInfo()
	return info.GetBlockHash().GetHex().GetValue(), int32(info.GetHeight()), nil
}

// Configs returns a snapshot of the binary configs. Handing out the live map
// would let a config reload write it while a caller ranges over it, which Go
// turns into an unrecoverable fatal error.
func (o *Orchestrator) Configs() map[string]BinaryConfig {
	o.mu.RLock()
	defer o.mu.RUnlock()
	return maps.Clone(o.configs)
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

// chainSyncCacheTTL bounds how often the orchestrator re-fetches a chain's
// tip. Matches the frontend's aggressive poll cadence so the UI gets fresh
// numbers every tick without us issuing more than one RPC per chain per tick.
const chainSyncCacheTTL = 100 * time.Millisecond

// chainForkCacheTTL bounds the fork probe. A refused branch stays refused, so
// this reads far less often than the tip itself.
const chainForkCacheTTL = 30 * time.Second

// chainStatesCacheTTL bounds the getchainstates probe. Core verifies the blocks
// below a snapshot over hours, so a second-old number is still current.
const chainStatesCacheTTL = 2 * time.Second

// Connection is the only thing that differs between chains: a pure RPC call
// that returns one typed value or an error. No caching, no single-flight,
// no error preservation. Implementations wrap their wire protocol and
// nothing else — the surrounding machinery (TTL cache, single-flight,
// last-good-on-error) lives in CachedConnection and applies uniformly to
// L1 and L2.
type Connection[T any] interface {
	Fetch(ctx context.Context) (T, error)
}

// CachedConnection wraps any Connection with TTL cache + single-flight +
// preserve-last-good-on-error. THIS is the only caching primitive in the
// orchestrator's chain-tip plumbing — every chain ends up here so the UI
// sees identical timing semantics across the board.
type CachedConnection[T any] struct {
	inner Connection[T]
	ttl   time.Duration

	mu       sync.Mutex
	last     T
	hasLast  bool
	lastErr  error
	fetched  time.Time
	inFlight chan struct{}
}

func (c *CachedConnection[T]) Fetch(ctx context.Context) (T, error) {
	c.mu.Lock()
	// Cache hit on a recent successful fetch — return immediately.
	if c.hasLast && c.lastErr == nil && time.Since(c.fetched) < c.ttl {
		out := c.last
		c.mu.Unlock()
		return out, nil
	}
	// A fetch is already in flight — wait for it instead of issuing another.
	if ch := c.inFlight; ch != nil {
		c.mu.Unlock()
		select {
		case <-ch:
		case <-ctx.Done():
			var zero T
			return zero, ctx.Err()
		}
		c.mu.Lock()
		out, err := c.last, c.lastErr
		c.mu.Unlock()
		return out, err
	}
	// We're the leader — install the in-flight signal and run the fetch.
	ch := make(chan struct{})
	c.inFlight = ch
	c.mu.Unlock()

	res, err := c.inner.Fetch(ctx)

	c.mu.Lock()
	if err == nil {
		c.last = res
		c.hasLast = true
		c.lastErr = nil
		c.fetched = time.Now()
	} else {
		// Don't poison the cached value on transient errors — keep the last
		// good value but record the error for the leader's return. Followers
		// that joined this fetch see the same error via lastErr below.
		c.lastErr = err
	}
	c.inFlight = nil
	close(ch)

	out := c.last
	c.mu.Unlock()
	if err != nil {
		return out, err
	}
	return out, nil
}

// projected adapts Connection[A] into Connection[B] via a pure transform.
// Used to expose one cached source of truth through multiple typed views —
// e.g. bitcoind's getblockchaininfo powers both the rich Connect RPC and the
// lean ChainSyncResult dispatch without issuing two HTTP calls per second.
type projected[A, B any] struct {
	inner Connection[A]
	fn    func(A) B
}

func (p *projected[A, B]) Fetch(ctx context.Context) (B, error) {
	a, err := p.inner.Fetch(ctx)
	var zero B
	if err != nil {
		return zero, err
	}
	return p.fn(a), nil
}

// Project decorates a Connection[A] with a transform A→B.
func Project[A, B any](inner Connection[A], fn func(A) B) Connection[B] {
	return &projected[A, B]{inner: inner, fn: fn}
}

// bitcoindInfoConnection is the raw getblockchaininfo RPC. No caching —
// CachedConnection wraps it for that.
type bitcoindInfoConnection struct{ o *Orchestrator }

func (c *bitcoindInfoConnection) Fetch(ctx context.Context) (*MainchainBlockchainInfo, error) {
	client, err := c.o.CoreStatusClient()
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

// ChainForkState is what Core knows about branches it refuses and about the
// tips its peers announce.
type ChainForkState struct {
	PeerBestHeight     int64
	RejectedBranch     bool
	RefusedBranchStart int64
}

// chainForkConnection reads getchaintips and getpeerinfo. A sync bar that only
// compares blocks to headers reads "100%" on a node that rejects the network's
// chain, because Core counts neither the refused branch nor its headers.
type chainForkConnection struct{ o *Orchestrator }

func (c *chainForkConnection) Fetch(ctx context.Context) (*ChainForkState, error) {
	client, err := c.o.CoreStatusClient()
	if err != nil {
		return nil, err
	}

	tipsRaw, err := client.call(ctx, "getchaintips")
	if err != nil {
		return nil, fmt.Errorf("getchaintips: %w", err)
	}
	var tips []coreChainTip
	if err := json.Unmarshal(tipsRaw, &tips); err != nil {
		return nil, fmt.Errorf("decode getchaintips: %w", err)
	}

	peersRaw, err := client.call(ctx, "getpeerinfo")
	if err != nil {
		return nil, fmt.Errorf("getpeerinfo: %w", err)
	}
	var peers []corePeerTip
	if err := json.Unmarshal(peersRaw, &peers); err != nil {
		return nil, fmt.Errorf("decode getpeerinfo: %w", err)
	}

	state := forkStateFrom(tips, peers)
	return &state, nil
}

// coreChainTip is one entry of getchaintips. BranchLen is zero on the active
// chain, so that entry names the node's own tip.
type coreChainTip struct {
	Height    int64  `json:"height"`
	Status    string `json:"status"`
	BranchLen int64  `json:"branchlen"`
}

// forkHeight is where this branch leaves the node's own chain.
func (t coreChainTip) forkHeight() int64 {
	if t.BranchLen < 1 {
		return t.Height
	}
	return t.Height - t.BranchLen + 1
}

// corePeerTip is what one peer announces. A fresh peer reports only
// StartHeight until headers arrive.
type corePeerTip struct {
	SyncedHeaders int64 `json:"synced_headers"`
	StartHeight   int64 `json:"startingheight"`
}

// forkStateFrom reads the two lists. A refused branch below the active tip is
// ordinary history, so only one at or above it counts.
func forkStateFrom(tips []coreChainTip, peers []corePeerTip) ChainForkState {
	var active, rejected int64
	for _, tip := range tips {
		if tip.BranchLen == 0 {
			active = tip.Height
		}
		if tip.Status == "invalid" {
			rejected = max(rejected, tip.Height)
		}
	}

	var refused int64
	for _, tip := range tips {
		if tip.Status != "invalid" || tip.Height < active {
			continue
		}
		if fork := tip.forkHeight(); refused == 0 || fork < refused {
			refused = fork
		}
	}

	var best int64
	for _, peer := range peers {
		best = max(best, peer.SyncedHeaders, peer.StartHeight)
	}

	return ChainForkState{
		PeerBestHeight:     best,
		RejectedBranch:     rejected > 0 && rejected >= active,
		RefusedBranchStart: refused,
	}
}

// chainStatesConnection reads getchainstates. A node behind a UTXO snapshot
// counts the tip in Blocks long before it verifies the blocks below it.
type chainStatesConnection struct{ o *Orchestrator }

// Fetch reports no snapshot on a Core that has no getchainstates at all. That
// answer is cached; the cache holds its TTL only after a success, so returning
// an error would re-probe an old Core on every 100ms poll. Every other failure
// stays an error, which keeps the last-good heights instead of blanking them.
func (c *chainStatesConnection) Fetch(ctx context.Context) (*CoreChainStates, error) {
	states, err := c.o.chainStatesFrom(ctx)
	if err == nil {
		return &states, nil
	}
	if CoreLacksMethod(err) {
		return &CoreChainStates{}, nil
	}
	return nil, err
}

// chainStatesCached returns the shared cache for the getchainstates probe.
func (o *Orchestrator) chainStatesCached() *CachedConnection[*CoreChainStates] {
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	if o.chainStates == nil {
		o.chainStates = &CachedConnection[*CoreChainStates]{
			inner: &chainStatesConnection{o: o},
			ttl:   chainStatesCacheTTL,
		}
	}
	return o.chainStates
}

// chainForkCached returns the shared cache for the fork probe. Two more RPCs
// per poll would be wasteful: a refused branch stays refused.
func (o *Orchestrator) chainForkCached() *CachedConnection[*ChainForkState] {
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	if o.chainFork == nil {
		o.chainFork = &CachedConnection[*ChainForkState]{
			inner: &chainForkConnection{o: o},
			ttl:   chainForkCacheTTL,
		}
	}
	return o.chainFork
}

// enforcerSyncConnection is the raw ValidatorService.GetChainTip RPC.
// Headers stay zero — the GetSyncStatus merge step fills them from the
// mainchain tip.
type enforcerSyncConnection struct{ o *Orchestrator }

func (c *enforcerSyncConnection) Fetch(ctx context.Context) (*ChainSyncResult, error) {
	cfg, ok := c.o.Configs()["enforcer"]
	if !ok || cfg.Port == 0 {
		return nil, fmt.Errorf("enforcer not configured")
	}
	src := datasource.NewEnforcerSource(
		func(context.Context) (enforcerrpc.ValidatorServiceClient, error) {
			return enforcerrpc.NewValidatorServiceClient(c.o.enforcerHTTP(), cfg.RPCURL(), connect.WithGRPC()), nil
		},
	)
	rpcCtx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	resp, err := src.ChainTip(rpcCtx, &enforcerpb.GetChainTipRequest{})
	if err != nil {
		return nil, err
	}
	return &ChainSyncResult{
		Blocks: int64(resp.GetBlockHeaderInfo().GetHeight()),
	}, nil
}

// sidechainSyncConnection is the JSON-RPC `getblockcount` probe for one L2
// sidechain. Headers stay zero — the GetSyncStatus merge step fills them
// from the public explorer.
type sidechainSyncConnection struct {
	o    *Orchestrator
	name string
}

func (c *sidechainSyncConnection) Fetch(ctx context.Context) (*ChainSyncResult, error) {
	cfg, ok := c.o.Configs()[c.name]
	if !ok {
		return nil, fmt.Errorf("unknown sidechain: %s", c.name)
	}
	proxy := sidechain.NewJSONRPCProxy(cfg.RPCHost(), cfg.Port)
	count, err := proxy.GetBlockCount(ctx)
	if err != nil {
		return nil, err
	}
	return &ChainSyncResult{Blocks: count}, nil
}

// mainchainInfoToSync projects a *MainchainBlockchainInfo down to the lean
// *ChainSyncResult view that GetSyncStatus dispatches on.
func mainchainInfoToSync(info *MainchainBlockchainInfo) *ChainSyncResult {
	if info == nil {
		return nil
	}
	return &ChainSyncResult{
		Blocks:  int64(info.Blocks),
		Headers: int64(info.Headers),
		Time:    info.Time,
	}
}

// bitcoindInfoCached returns the single cached Connection backing both
// GetMainchainBlockchainInfo (rich external Connect RPC) and the lean
// GetSyncStatus dispatch. Built lazily on first use.
func (o *Orchestrator) bitcoindInfoCached() *CachedConnection[*MainchainBlockchainInfo] {
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	if o.bitcoindInfo == nil {
		o.bitcoindInfo = &CachedConnection[*MainchainBlockchainInfo]{
			inner: &bitcoindInfoConnection{o: o},
			ttl:   chainSyncCacheTTL,
		}
	}
	return o.bitcoindInfo
}

// syncConnectionFor returns the cached *ChainSyncResult connection for name,
// building (and memoising) it on first use. Names match the BinaryConfig
// keys: "bitcoind", "enforcer", or any L2 sidechain key. For "bitcoind" the
// returned value wraps a Project over bitcoindInfoCached so the rich
// connection and the sync view share one in-flight RPC.
func (o *Orchestrator) syncConnectionFor(name string) Connection[*ChainSyncResult] {
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	switch name {
	case "bitcoind":
		if o.bitcoindInfo == nil {
			o.bitcoindInfo = &CachedConnection[*MainchainBlockchainInfo]{
				inner: &bitcoindInfoConnection{o: o},
				ttl:   chainSyncCacheTTL,
			}
		}
		if o.bitcoindSync == nil {
			o.bitcoindSync = Project[*MainchainBlockchainInfo, *ChainSyncResult](o.bitcoindInfo, mainchainInfoToSync)
		}
		return o.bitcoindSync
	case "enforcer":
		if o.enforcerSync == nil {
			o.enforcerSync = &CachedConnection[*ChainSyncResult]{
				inner: &enforcerSyncConnection{o: o},
				ttl:   chainSyncCacheTTL,
			}
		}
		return o.enforcerSync
	default:
		if o.sidechainSyncs == nil {
			o.sidechainSyncs = make(map[string]*CachedConnection[*ChainSyncResult])
		}
		if c, ok := o.sidechainSyncs[name]; ok {
			return c
		}
		c := &CachedConnection[*ChainSyncResult]{
			inner: &sidechainSyncConnection{o: o, name: name},
			ttl:   chainSyncCacheTTL,
		}
		o.sidechainSyncs[name] = c
		return c
	}
}

// GetMainchainBlockchainInfo proxies getblockchaininfo from bitcoind through
// the shared cache. Signature is load-bearing — the public Connect RPC at
// api/orchestrator_handler.go:216 returns this rich type directly.
func (o *Orchestrator) GetMainchainBlockchainInfo(ctx context.Context) (*MainchainBlockchainInfo, error) {
	return o.bitcoindInfoCached().Fetch(ctx)
}

// ChainSyncResult is one chain's tip snapshot. Error is set on failure; the
// numeric fields are best-effort zero in that case.
type ChainSyncResult struct {
	Blocks  int64
	Headers int64
	Time    int64
	Error   string
	// PeerBestHeight is the highest tip any peer announces, zero when unknown.
	PeerBestHeight int64
	// RejectedBranch is true when the node marked a branch at or above its own
	// tip invalid. Together with a higher PeerBestHeight it means the node
	// refuses the chain its peers follow.
	RejectedBranch bool
	// RefusedBranchStart is where the refused branch leaves this node's
	// chain, zero when none. The invalid block sits at or above it.
	RefusedBranchStart int64
	// VerifiedBlocks is the height Core verified from genesis, zero when it
	// loaded no UTXO snapshot. Mainchain only.
	VerifiedBlocks int64
	// VerifiedGoal is the height VerifiedBlocks counts towards: the snapshot's
	// base block, zero when no snapshot is loaded. Mainchain only.
	VerifiedGoal int64
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
	// ChainSource is the tip the wallet chain source reports. An electrum
	// wallet runs no local node, so this is the only height it has.
	ChainSource *ChainSyncResult
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
		Mainchain:   &ChainSyncResult{},
		Enforcer:    &ChainSyncResult{},
		Sidechains:  make(map[string]*ChainSyncResult),
		ChainSource: &ChainSyncResult{},
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

	// Unified dispatch: build (slot, conn, validate) tuples covering L1 +
	// L2. validate returns the short-circuit error string for slots that
	// shouldn't reach Fetch (config missing, process not running, etc). The
	// dispatch loop body below is RPC-agnostic — only conn differs.
	type job struct {
		slot     *ChainSyncResult
		conn     Connection[*ChainSyncResult]
		validate func() string
	}
	jobs := []job{
		{
			slot: out.Mainchain,
			conn: o.syncConnectionFor("bitcoind"),
			validate: func() string {
				if _, ok := o.Configs()["bitcoind"]; !ok {
					return "bitcoind not configured"
				}
				return ""
			},
		},
		{
			slot: out.Enforcer,
			conn: o.syncConnectionFor("enforcer"),
			validate: func() string {
				cfg, ok := o.Configs()["enforcer"]
				if !ok || cfg.Port == 0 {
					return "enforcer not configured"
				}
				if !o.enforcerReachable() {
					return "not running"
				}
				return ""
			},
		},
	}
	for name, slot := range out.Sidechains {
		name, slot := name, slot
		jobs = append(jobs, job{
			slot: slot,
			conn: o.syncConnectionFor(name),
			validate: func() string {
				if _, ok := o.Configs()[name]; !ok {
					return fmt.Sprintf("unknown sidechain: %s", name)
				}
				if !o.process.IsRunning(name) {
					return "not running"
				}
				return ""
			},
		})
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

	wg.Add(1)
	go func() {
		defer wg.Done()
		height, err := o.ChainSourceHeight(ctx)
		if err != nil {
			out.ChainSource.Error = err.Error()
			return
		}
		out.ChainSource.Blocks, out.ChainSource.Headers = int64(height), int64(height)
	}()

	var fork *ChainForkState
	wg.Add(1)
	go func() {
		defer wg.Done()
		state, err := o.chainForkCached().Fetch(ctx)
		if err != nil {
			o.log.Debug().Err(err).Msg("chain fork probe failed")
		}
		// The cache returns its last good state next to a transient error, so
		// a failed refresh must not clear an active off-chain warning.
		if state != nil {
			fork = state
		}
	}()

	for _, j := range jobs {
		j := j
		wg.Add(1)
		go func() {
			defer wg.Done()
			if msg := j.validate(); msg != "" {
				j.slot.Error = msg
				return
			}
			res, err := j.conn.Fetch(ctx)
			// Only surface the error when there's no cached value to fall
			// back on — otherwise keep showing the last-good numbers so
			// the UI's progress doesn't snap to zero on a transient
			// timeout. Same behaviour for L1 (bitcoind) and L2.
			if err != nil && (res == nil || res.Blocks == 0) {
				j.slot.Error = err.Error()
				return
			}
			if res != nil {
				j.slot.Blocks = res.Blocks
				j.slot.Headers = res.Headers
				j.slot.Time = res.Time
			}
		}()
	}

	var chainStates *CoreChainStates
	wg.Add(1)
	go func() {
		defer wg.Done()
		states, err := o.chainStatesCached().Fetch(ctx)
		if err != nil {
			o.log.Debug().Err(err).Msg("getchainstates probe failed")
		}
		// The cache hands back its last good states next to a transient error,
		// so a failed refresh must not blank the verified heights.
		if states != nil {
			chainStates = states
		}
	}()

	wg.Wait()

	if chainStates != nil && out.Mainchain.Error == "" {
		out.Mainchain.VerifiedBlocks = chainStates.VerifiedBlocks
		out.Mainchain.VerifiedGoal = chainStates.VerifiedGoal
	}

	if fork != nil && out.Mainchain.Error == "" {
		out.Mainchain.PeerBestHeight = fork.PeerBestHeight
		out.Mainchain.RejectedBranch = fork.RejectedBranch
		out.Mainchain.RefusedBranchStart = fork.RefusedBranchStart
	}

	// Headers fan-out: dependent chains measure progress against bitcoind's
	// tip. Errored slots are skipped so we don't overwrite their zero state
	// with stale mainchain numbers.
	if out.Enforcer.Error == "" {
		if out.Mainchain.Error == "" {
			out.Enforcer.Headers = out.Mainchain.Headers
		} else {
			out.Enforcer.Headers = out.Enforcer.Blocks
		}
	}
	// Sidechain headers come from the public explorer (fetched in parallel
	// above). The local sidechain RPC only reports blocks it has indexed,
	// which can't act as the goal — that has to be the network tip. The
	// explorer is a best-effort UX extra: only signet has one today, so on
	// mainnet/testnet/regtest/ecash the fetch always fails. When it does,
	// leave Headers at zero. The previous behaviour set Headers=Blocks,
	// which made progress = blocks/blocks = 1.0 and rendered every running
	// sidechain as fully synced even mid-IBD — a far worse failure mode
	// than a stuck-at-zero progress bar.
	for name, slot := range out.Sidechains {
		if slot.Error != "" {
			continue
		}
		if h, ok := heights[name]; ok {
			slot.Headers = h
		}
	}

	return out, nil
}

// invalidateSyncConnectionCacheForTest forces the named CachedConnection's
// TTL window to expire so the next Fetch call refetches. Test-only helper
// used by get_sync_status_test.go to drive last-good-on-error coverage
// without poking at unexported cache fields directly.
func (o *Orchestrator) invalidateSyncConnectionCacheForTest(name string) {
	// Building the connection first guarantees the cache field is non-nil.
	_ = o.syncConnectionFor(name)
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	switch name {
	case "bitcoind":
		c := o.bitcoindInfo
		c.mu.Lock()
		c.fetched = time.Now().Add(-time.Hour)
		c.mu.Unlock()
	case "enforcer":
		c := o.enforcerSync
		c.mu.Lock()
		c.fetched = time.Now().Add(-time.Hour)
		c.mu.Unlock()
	default:
		c := o.sidechainSyncs[name]
		c.mu.Lock()
		c.fetched = time.Now().Add(-time.Hour)
		c.mu.Unlock()
	}
}

// explorerCacheTTL bounds how often we hit the public explorer. Sidechain
// tips move on the order of a minute; 30 s is plenty fresh for the UI.
const explorerCacheTTL = 30 * time.Second

// explorerHeightsConnection is the raw GetChainTips RPC against the public
// drivechain.info explorer. No caching — CachedConnection wraps it for that.
type explorerHeightsConnection struct{ o *Orchestrator }

func (c *explorerHeightsConnection) Fetch(ctx context.Context) (map[string]int64, error) {
	// Only networks with hosted infrastructure have a public explorer. ECash
	// lives on drivechain.dev under a per-generation host and publishes no tip
	// endpoint at all, so building a drivechain.info URL for it just dials a
	// name that has never existed, once per poll.
	network := config.NetworkFromString(c.o.Network)
	if config.RemoteOrchestratorURLForNetwork(network) == "" {
		return nil, fmt.Errorf("no public explorer for %s", network)
	}
	// Readable names match the explorer URL slug directly.
	url := fmt.Sprintf("https://node.%s.drivechain.info/api/explorer.v1.ExplorerService/GetChainTips", network.ReadableName())

	rpcCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	// The Connect-JSON shape: each known sidechain key maps to an object
	// with a `height` string. We tolerate either string or numeric heights
	// because the explorer's previous shape returned numbers; the current
	// one returns strings.
	var resp map[string]struct {
		Height interface{} `json:"height"`
	}
	if err := connectJSONPost(rpcCtx, c.o.explorerHTTP(), url, &resp); err != nil {
		return nil, err
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
	return heights, nil
}

// explorerHeightsCached returns the single CachedConnection backing every
// public-explorer fetch. Built lazily on first use under the shared
// syncConnMu so concurrent first-callers don't race to build two of them.
func (o *Orchestrator) explorerHeightsCached() *CachedConnection[map[string]int64] {
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	if o.explorerHeightsCache == nil {
		o.explorerHeightsCache = &CachedConnection[map[string]int64]{
			inner: &explorerHeightsConnection{o: o},
			ttl:   explorerCacheTTL,
		}
	}
	return o.explorerHeightsCache
}

// fetchExplorerHeights returns the canonical per-sidechain network-tip
// heights, keyed by orchestrator binary name. Cached for [explorerCacheTTL]
// via the same CachedConnection primitive every chain-tip probe uses. On
// failure we keep serving the previous values rather than dropping headers
// entirely — the error is logged at debug and swallowed so callers (i.e.
// GetSyncStatus's header-merge step) don't need to think about it.
func (o *Orchestrator) fetchExplorerHeights(ctx context.Context) map[string]int64 {
	heights, err := o.explorerHeightsCached().Fetch(ctx)
	if err != nil {
		o.log.Debug().Err(err).Msg("explorer GetChainTips failed; keeping cached heights")
	}
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
	user, password, err := o.BitcoinConf.GetRPCCredentials()
	if err != nil {
		return nil, fmt.Errorf("core rpc credentials: %w", err)
	}

	// Cache the client (and therefore its underlying http.Client + connection
	// pool) so back-to-back getblockchaininfo / getbalance calls reuse the
	// same TCP connection instead of dialling a fresh one every time. The
	// key is rebuilt only when host/port/user/password actually change — a
	// SetCoreVariant or auth swap will invalidate it cleanly.
	host := o.BitcoinConf.GetRPCHost()
	key := fmt.Sprintf("%s|%d|%s|%s", host, port, user, password)
	o.httpClientsMu.Lock()
	defer o.httpClientsMu.Unlock()
	if o.coreStatusClient != nil && o.coreStatusClientKey == key {
		return o.coreStatusClient, nil
	}
	o.coreStatusClient = NewCoreStatusClient(host, port, user, password)
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
		if processNameMatches(config.BinaryName, binaryName) || processNameMatches(config.Name, binaryName) {
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
