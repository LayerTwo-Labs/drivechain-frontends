package orchestrator

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

// BinaryStatus represents the current state of a managed binary.
type BinaryStatus struct {
	Name        string
	DisplayName string
	Running     bool
	Healthy     bool
	Pid         int
	Uptime      time.Duration
	ChainLayer  int
	Port        int
	Error       string
}

// StartupProgress reports progress during StartWithDeps.
type StartupProgress struct {
	Stage   string // e.g. "downloading-bitcoind", "starting-bitcoind", "waiting-ibd"
	Message string
	Done    bool
	Error   error
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

	configs    map[string]BinaryConfig
	download   *DownloadManager
	process    *ProcessManager
	pidManager *PidFileManager
	log        zerolog.Logger

	mu sync.RWMutex
}

// New creates a new Orchestrator.
func New(dataDir, network, bitwindowDir string, configs []BinaryConfig, log zerolog.Logger) *Orchestrator {
	pidMgr := NewPidFileManager(dataDir, log)

	orch := &Orchestrator{
		DataDir:      dataDir,
		Network:      network,
		BitwindowDir: bitwindowDir,
		configs:      lo.SliceToMap(configs, func(c BinaryConfig) (string, BinaryConfig) { return c.Name, c }),
		download:     NewDownloadManager(dataDir, log),
		process:      NewProcessManager(dataDir, pidMgr, log),
		pidManager:   pidMgr,
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

// Download downloads a binary if missing (or forces re-download).
func (o *Orchestrator) Download(ctx context.Context, name string, force bool) (<-chan DownloadProgress, error) {
	config, err := o.getConfig(name)
	if err != nil {
		return nil, err
	}
	return o.download.Download(ctx, config, force)
}

// Start starts a binary with the given args and env.
func (o *Orchestrator) Start(ctx context.Context, name string, args []string, env map[string]string) (int, error) {
	config, err := o.getConfig(name)
	if err != nil {
		return 0, err
	}
	return o.process.Start(ctx, config, args, env)
}

// Stop stops a running binary.
func (o *Orchestrator) Stop(ctx context.Context, name string, force bool) error {
	return o.process.Stop(ctx, name, force)
}

// Status returns the current status of a binary.
func (o *Orchestrator) Status(name string) BinaryStatus {
	config, err := o.getConfig(name)
	if err != nil {
		return BinaryStatus{Name: name, Error: err.Error()}
	}

	proc := o.process.Get(name)
	status := BinaryStatus{
		Name:        config.Name,
		DisplayName: config.DisplayName,
		ChainLayer:  config.ChainLayer,
		Port:        config.Port,
	}

	if proc != nil {
		status.Running = true
		status.Pid = proc.Pid
		status.Uptime = time.Since(proc.Started)
	}

	return status
}

// ListAll returns the status of every configured binary.
func (o *Orchestrator) ListAll() []BinaryStatus {
	o.mu.RLock()
	defer o.mu.RUnlock()

	statuses := make([]BinaryStatus, 0, len(o.configs))
	for name := range o.configs {
		statuses = append(statuses, o.Status(name))
	}
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

		// Start Bitcoin Core if needed
		if !o.process.IsRunning("bitcoind") {
			ch <- StartupProgress{Stage: "starting-bitcoind", Message: "starting Bitcoin Core..."}

			downloadCh, err := o.download.Download(ctx, o.configs["bitcoind"], false)
			if err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("download bitcoind: %w", err)}
				return
			}
			for p := range downloadCh {
				if p.Error != nil {
					ch <- StartupProgress{Error: fmt.Errorf("download bitcoind: %w", p.Error)}
					return
				}
			}

			if _, err := o.process.Start(ctx, o.configs["bitcoind"], opts.CoreArgs, nil); err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("start bitcoind: %w", err)}
				return
			}
		}

		// Wait for Bitcoin Core health
		ch <- StartupProgress{Stage: "waiting-bitcoind", Message: "waiting for Bitcoin Core to accept connections..."}
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
		if err := WaitForHealthy(ctx, coreChecker, 2*time.Second); err != nil {
			ch <- StartupProgress{Error: fmt.Errorf("wait for bitcoind: %w", err)}
			return
		}

		// Start enforcer if needed
		if config.ChainLayer == 2 && !o.process.IsRunning("enforcer") {
			ch <- StartupProgress{Stage: "starting-enforcer", Message: "starting BIP300301 enforcer..."}

			downloadCh, err := o.download.Download(ctx, o.configs["enforcer"], false)
			if err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("download enforcer: %w", err)}
				return
			}
			for p := range downloadCh {
				if p.Error != nil {
					ch <- StartupProgress{Error: fmt.Errorf("download enforcer: %w", p.Error)}
					return
				}
			}

			if _, err := o.process.Start(ctx, o.configs["enforcer"], opts.EnforcerArgs, nil); err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("start enforcer: %w", err)}
				return
			}

			ch <- StartupProgress{Stage: "waiting-enforcer", Message: "waiting for enforcer to accept connections..."}
			enforcerChecker := NewHealthChecker(o.configs["enforcer"])
			if err := WaitForHealthy(ctx, enforcerChecker, 2*time.Second); err != nil {
				ch <- StartupProgress{Error: fmt.Errorf("wait for enforcer: %w", err)}
				return
			}
		}

		// Start the target binary
		o.startTargetOnly(ctx, config, opts, ch)
	}()

	return ch, nil
}

func (o *Orchestrator) startTargetOnly(ctx context.Context, config BinaryConfig, opts StartOpts, ch chan<- StartupProgress) {
	ch <- StartupProgress{Stage: "downloading-" + config.Name, Message: fmt.Sprintf("downloading %s...", config.DisplayName)}

	downloadCh, err := o.download.Download(ctx, config, false)
	if err != nil {
		ch <- StartupProgress{Error: fmt.Errorf("download %s: %w", config.Name, err)}
		return
	}
	for p := range downloadCh {
		if p.Error != nil {
			ch <- StartupProgress{Error: fmt.Errorf("download %s: %w", config.Name, p.Error)}
			return
		}
	}

	ch <- StartupProgress{Stage: "starting-" + config.Name, Message: fmt.Sprintf("starting %s...", config.DisplayName)}

	if _, err := o.process.Start(ctx, config, opts.TargetArgs, opts.TargetEnv); err != nil {
		ch <- StartupProgress{Error: fmt.Errorf("start %s: %w", config.Name, err)}
		return
	}

	ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", config.DisplayName), Done: true}
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
			ch <- ShutdownProgress{
				TotalCount:    total,
				CompletedCount: completed,
				CurrentBinary: name,
			}

			if err := o.process.Stop(ctx, name, force); err != nil {
				o.log.Warn().Err(err).Str("binary", name).Msg("stop during shutdown")
			}
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

func (o *Orchestrator) getConfig(name string) (BinaryConfig, error) {
	o.mu.RLock()
	defer o.mu.RUnlock()

	config, ok := o.configs[name]
	if !ok {
		return BinaryConfig{}, fmt.Errorf("unknown binary: %s", name)
	}
	return config, nil
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
