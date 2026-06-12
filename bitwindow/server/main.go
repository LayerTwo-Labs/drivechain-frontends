package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
	"net"
	"net/http"
	_ "net/http/pprof"
	"net/url"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"

	"os/exec"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/version"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/jessevdk/go-flags"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

func main() {
	start := time.Now()

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)

	if err := realMain(ctx, cancel); err != nil {

		// Error has been printed to the console!
		if _, ok := lo.ErrorsAs[*flags.Error](err); ok {
			cancel()
			os.Exit(1)
		}

		if log := zerolog.Ctx(ctx); log != nil {
			log.Error().Err(err).
				Msgf("main: finished with error after %s", time.Since(start))
		}

		fmt.Fprintf(os.Stderr, "main: finished with error after %s: %s (%T)\n", time.Since(start), err, err)
		cancel()
		os.Exit(1)
	}
}

func realMain(ctx context.Context, cancelCtx context.CancelFunc) error {
	conf, err := config.Parse()
	if err != nil {
		if flags.WroteHelp(err) {
			return nil
		}
		return fmt.Errorf("read config: %w", err)
	}

	// Handle version flag
	if conf.Version {
		//nolint:forbidigo
		fmt.Println(version.String())
		return nil
	}

	// orchestratord is the canonical owner of the bitcoin.conf — both the
	// network identity and the RPC creds live there. We start it first, wait
	// for it to be ready, then ask it for the network. bitwindowd never
	// parses bitcoin.conf itself.
	bootLogger := zerolog.New(os.Stderr).With().Timestamp().Logger()
	bootCtx := bootLogger.WithContext(ctx)

	// Base bitwindow dir (pre-Finalize) holding wallet.json and the shared
	// .auth.cookie. Capture before Finalize suffixes Datadir with the network,
	// and point the orchestrator (Bitcoind proxy) client at it for local auth.
	bitwindowDir := conf.BitwindowDir()
	dial.SetCookieDir(bitwindowDir)

	if _, err := startOrchestratord(bootCtx, conf); err != nil {
		return fmt.Errorf("start orchestratord: %w", err)
	}

	// Best-effort relay Shutdown to orchestratord on any bitwindowd exit path
	// (Ctrl-C, panic, etc.). The window-close flow goes through
	// BitwindowdService.Stop which has already relayed by the time this
	// fires — Shutdown is idempotent on the orchestrator side, so the double
	// call is harmless. orchestratord is detached and survives bitwindowd's
	// exit either way.
	defer relayShutdownToOrchestratord(conf.OrchestratorAddr, bitwindowDir, bootLogger)

	network, err := waitForOrchestratorNetwork(bootCtx, conf.OrchestratorAddr, bitwindowDir, bootLogger)
	if err != nil {
		return fmt.Errorf("read network from orchestratord: %w", err)
	}

	// Adopting a still-draining orchestratord (cancel its pending exit, await
	// in-flight stops) is owned by Flutter — see bootBitwindowBackend in
	// bitwindow/lib/main.dart. That way the UI loads immediately and shows a
	// "waiting for previous shutdown" status instead of blocking bitwindowd's
	// startup. bitwindowd doesn't need to wait: its own bitcoind connections
	// will retry once the new stack comes up.

	if err := conf.Finalize(config.Network(network)); err != nil {
		return fmt.Errorf("finalize config: %w", err)
	}

	logFile, err := os.OpenFile(conf.LogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		return fmt.Errorf("open log file: %w", err)
	}

	logLevel, err := zerolog.ParseLevel(conf.LogLevel)
	if err != nil {
		return fmt.Errorf("parse log level: %w", err)
	}
	// Take care not to use zerolog before this point
	initLogger(logFile, logLevel)

	log := zerolog.Ctx(ctx)
	log.Info().Msgf("logger initialized successfully with file %q", conf.LogPath)
	log.Info().
		Str("network", string(conf.BitcoinCoreNetwork)).
		Msg("aligned bitwindowd to orchestratord network")

	// Network alignment at startup. Subsequent network swaps are handled
	// in-process via Server.Recycle — bitwindowd never exits across a swap.

	bitcoindConnector := func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return dial.Bitcoind(ctx, conf.OrchestratorAddr)
	}

	enforcerConnector := func(ctx context.Context) (rpc.ValidatorServiceClient, error) {
		validator, err := dial.EnforcerValidator(ctx, conf.EnforcerHost)
		return validator, err
	}

	walletConnector := func(ctx context.Context) (rpc.WalletServiceClient, error) {
		wallet, err := dial.EnforcerWallet(ctx, conf.EnforcerHost)
		return wallet, err
	}

	cryptoConnector := func(ctx context.Context) (cryptorpc.CryptoServiceClient, error) {
		crypto, err := dial.EnforcerCrypto(ctx, conf.EnforcerHost)
		return crypto, err
	}

	// Sidechain connectors
	thunderConnector := func(ctx context.Context) (*thunder.Client, error) {
		host, port, err := splitAddr(conf.ThunderAddr)
		if err != nil {
			return nil, fmt.Errorf("thunder.addr: %w", err)
		}
		return dial.Thunder(ctx, host, port)
	}
	bitnamesConnector := func(ctx context.Context) (*bitnames.Client, error) {
		host, port, err := splitAddr(conf.BitnamesAddr)
		if err != nil {
			return nil, fmt.Errorf("bitnames.addr: %w", err)
		}
		return dial.BitNames(ctx, host, port)
	}
	bitassetsConnector := func(ctx context.Context) (*bitassets.Client, error) {
		host, port, err := splitAddr(conf.BitassetsAddr)
		if err != nil {
			return nil, fmt.Errorf("bitassets.addr: %w", err)
		}
		return dial.BitAssets(ctx, host, port)
	}
	truthcoinConnector := func(ctx context.Context) (*truthcoin.Client, error) {
		host, port, err := splitAddr(conf.TruthcoinAddr)
		if err != nil {
			return nil, fmt.Errorf("truthcoin.addr: %w", err)
		}
		return dial.Truthcoin(ctx, host, port)
	}
	photonConnector := func(ctx context.Context) (*photon.Client, error) {
		host, port, err := splitAddr(conf.PhotonAddr)
		if err != nil {
			return nil, fmt.Errorf("photon.addr: %w", err)
		}
		return dial.Photon(ctx, host, port)
	}
	coinshiftConnector := func(ctx context.Context) (*coinshift.Client, error) {
		host, port, err := splitAddr(conf.CoinshiftAddr)
		if err != nil {
			return nil, fmt.Errorf("coinshift.addr: %w", err)
		}
		return dial.CoinShift(ctx, host, port)
	}

	services := api.Services{
		BitcoindConnector: bitcoindConnector,
		WalletConnector:   walletConnector,
		EnforcerConnector: enforcerConnector,
		CryptoConnector:   cryptoConnector,

		// Sidechain connectors
		ThunderConnector:   thunderConnector,
		BitNamesConnector:  bitnamesConnector,
		BitAssetsConnector: bitassetsConnector,
		TruthcoinConnector: truthcoinConnector,
		PhotonConnector:    photonConnector,
		CoinShiftConnector: coinshiftConnector,

		OrchestratorAddr:    conf.OrchestratorAddr,
		EnforcerJSONRPCAddr: conf.EnforcerJSONRPCAddr,
		BitwindowDir:        bitwindowDir,
	}

	// api.New builds the long-lived service connectors, then constructs the
	// initial Runtime (per-network DB, engines, sub-handlers) and starts its
	// engines. Subsequent network swaps recycle the Runtime in-process —
	// the bitwindowd process never exits across a swap.
	srv, err := api.New(
		ctx,
		services,
		conf,
		func(ctx context.Context) {
			log.Info().Msg("shutting down")
			cancelCtx()
		},
	)
	if err != nil {
		return err
	}

	log.Info().Msgf("server: listening on %s", conf.APIHost)

	go func() {
		pprofAddr := "localhost:6060"
		log.Info().Msgf("pprof: listening on %s", pprofAddr)
		if err := http.ListenAndServe(pprofAddr, nil); err != nil {
			log.Error().Err(err).Msg("pprof server failed")
		}
	}()

	errs := make(chan error, 1)
	go func() {
		errs <- srv.Serve(ctx, conf.APIHost)
	}()

	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), time.Second*5)
		defer cancel()
		srv.Shutdown(shutdownCtx)
		errs <- nil
	}()

	return <-errs
}

func initLogger(logFile *os.File, logLevel zerolog.Level) {
	// Quirk: unless this is set, milliseconds are not included
	// in any timestamp written by zerolog.
	zerolog.TimeFieldFormat = time.RFC3339Nano

	const timeFormat = time.DateTime + ".000"
	// We want pretty printing to the file as well. This is not meant for
	// centralized log ingestion, where JSON is crucial.
	logWriter := zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
		w.Out = logFile
		w.NoColor = true // ANSI colors don't work well with file output.
		w.TimeFormat = timeFormat
	})
	multiWriter := zerolog.MultiLevelWriter(
		zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
			w.TimeFormat = timeFormat
		}),
		logWriter,
	)

	logger := zerolog.New(multiWriter).
		With().
		Timestamp().
		Caller().
		Logger().
		Level(logLevel).
		Hook(zerolog.HookFunc(func(e *zerolog.Event, level zerolog.Level, msg string) {
			// Filter out noisy btc-buf infrastructure connection logs
			if strings.Contains(msg, "Established connection to RPC server") {
				e.Discard()
			}
			// Filter out Bitcoin Core startup messages that appear during connection attempts
			if isNoisyStartupMessage(msg) {
				e.Discard()
			}
		}))

	zerolog.DefaultContextLogger = &logger
}

// isNoisyStartupMessage returns true for Bitcoin Core startup messages that
// should be filtered from logs during initialization.
func isNoisyStartupMessage(msg string) bool {
	noisyPatterns := []string{
		"Loading block index",
		"Opening LevelDB",
		"Verifying blocks",
		"Replaying blocks",
		"Rescanning",
		"Loading wallet",
		"Loading P2P addresses",
		"Loading banlist",
		"Starting network threads",
		"Flushing wallet",
		"Imported mempool transactions",
		"Done loading",
		"Loading mempool",
		"Shutdown: In progress",
		"Shutdown requested",
		"does not accept connections",
	}

	for _, pattern := range noisyPatterns {
		if strings.Contains(msg, pattern) {
			return true
		}
	}

	return false
}

// startOrchestratord starts the orchestrator daemon as a subprocess.
func startOrchestratord(ctx context.Context, conf config.Config) (*exec.Cmd, error) {
	log := zerolog.Ctx(ctx)
	bitwindowDir := conf.BitwindowDir()

	// If a previous orchestratord is still draining, adopt it only after it
	// proves it knows the cookie. This avoids sending the bearer token to an
	// arbitrary listener that managed to occupy the port.
	adopted, err := existingOrchestratorAdoptable(conf.OrchestratorAddr, bitwindowDir)
	if err != nil {
		return nil, err
	}
	if adopted {
		log.Info().Str("addr", conf.OrchestratorAddr).Msg("orchestratord already running, adopting verified instance")
		return nil, nil
	}

	// Don't touch the cookie here: orchestratord overwrites it with a fresh
	// token once it owns the listener. Deleting it from bitwindowd could yank
	// the cookie out from under a still-live orchestratord we failed to adopt.

	// Find the orchestratord binary next to our own binary.
	selfPath, err := os.Executable()
	if err != nil {
		return nil, fmt.Errorf("find self path: %w", err)
	}
	orchName := "orchestratord"
	if runtime.GOOS == "windows" {
		orchName += ".exe"
	}
	orchPath := filepath.Join(filepath.Dir(selfPath), orchName)
	if _, err := os.Stat(orchPath); err != nil {
		return nil, fmt.Errorf("orchestratord not found at %s: %w", orchPath, err)
	}

	// orchestratord owns the bitcoin.conf — pick up network from there, not
	// from a CLI flag we'd have to keep aligned. conf.Datadir is the raw
	// bitwindow base dir at this point (Finalize runs *after* we've queried
	// orchestratord for the network).
	args := []string{
		"--datadir", bitwindowDir,
		"--bitwindow-dir", bitwindowDir,
	}

	// Detached: orchestratord owns its own lifecycle and outlives bitwindowd.
	// On window close, bitwindowd relays a Shutdown RPC and exits immediately,
	// while orchestratord keeps draining bitcoind for up to ~90s in the
	// background. See plan: "Detach orchestratord + bitwindowd-mediated
	// shutdown with mid-shutdown recovery".
	//
	// - exec.Command (no Context): bitwindowd's ctx cancellation does NOT
	//   propagate to orchestratord.
	// - Setpgid: orchestratord runs in its own process group, so bitwindowd's
	//   exit doesn't deliver SIGHUP to it.
	// - --logfile: orchestratord writes its zerolog stream to a file, since
	//   stdout/stderr become orphaned once bitwindowd exits.
	// - Stdout/Stderr → log file too: catches anything not routed through
	//   zerolog (panics, child-process spew). Bitwindowd's fd closes when the
	//   defer below runs; orchestratord inherits an independent fd that
	//   survives.
	// - Process.Release: tells the Go runtime to stop tracking the child so we
	//   don't dangle a finalizer waiting on a process we've handed to init.
	orchLogPath := filepath.Join(bitwindowDir, "orchestratord.log")
	// On a fresh install the bitwindow dir doesn't exist yet; opening the log
	// would fail, orchestratord would never spawn, and the UI would poll a dead
	// port until timeout. Ensure the dir exists first.
	if err := os.MkdirAll(bitwindowDir, 0o755); err != nil {
		return nil, fmt.Errorf("create bitwindow dir %s: %w", bitwindowDir, err)
	}
	orchLogFile, err := os.OpenFile(orchLogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		return nil, fmt.Errorf("open orchestratord log %s: %w", orchLogPath, err)
	}
	defer orchLogFile.Close() //nolint:errcheck — child has its own fd post-spawn

	args = append(args, "--logfile", orchLogPath)

	log.Info().Str("path", orchPath).Strs("args", args).Str("logfile", orchLogPath).Msg("starting orchestratord (detached)")

	cmd := exec.Command(orchPath, args...)
	configureOrchestratordSpawn(cmd)
	cmd.Stdout = orchLogFile
	cmd.Stderr = orchLogFile

	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("start orchestratord: %w", err)
	}

	log.Info().Int("pid", cmd.Process.Pid).Msg("orchestratord started")

	if err := cmd.Process.Release(); err != nil {
		log.Warn().Err(err).Msg("release orchestratord process handle (continuing — child is independent)")
	}

	return cmd, nil
}

func existingOrchestratorAdoptable(addr, bitwindowDir string) (bool, error) {
	hostPort, err := orchestratorHostPort(addr)
	if err != nil {
		return false, err
	}
	conn, err := net.DialTimeout("tcp", hostPort, 200*time.Millisecond)
	if err != nil {
		return false, nil
	}
	_ = conn.Close()

	ok, err := verifyExistingOrchestrator(addr, bitwindowDir)
	if err != nil {
		return false, fmt.Errorf("orchestrator RPC address %s is already in use by an unverified listener: %w", hostPort, err)
	}
	if !ok {
		return false, fmt.Errorf("orchestrator RPC address %s is already in use by an unverified listener; refusing to send local-auth cookie", hostPort)
	}
	return true, nil
}

func verifyExistingOrchestrator(addr, bitwindowDir string) (bool, error) {
	token, err := localauth.ReadCookie(bitwindowDir)
	if err != nil {
		return false, fmt.Errorf("read local auth cookie: %w", err)
	}
	if token == "" {
		return false, fmt.Errorf("local auth cookie is missing")
	}

	nonceBytes := make([]byte, 32)
	if _, err := rand.Read(nonceBytes); err != nil {
		return false, fmt.Errorf("generate challenge nonce: %w", err)
	}
	nonce := hex.EncodeToString(nonceBytes)

	u, err := orchestratorURL(addr)
	if err != nil {
		return false, err
	}
	u.Path = "/local-auth/challenge"
	q := u.Query()
	q.Set("nonce", nonce)
	u.RawQuery = q.Encode()

	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return false, fmt.Errorf("build challenge request: %w", err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return false, fmt.Errorf("challenge request failed: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return false, fmt.Errorf("challenge status %s", resp.Status)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1024))
	if err != nil {
		return false, fmt.Errorf("read challenge response: %w", err)
	}
	got := strings.TrimSpace(string(body))
	return localauth.VerifyChallengeResponse(token, nonce, got), nil
}

func orchestratorURL(addr string) (*url.URL, error) {
	raw := strings.TrimSpace(addr)
	if raw == "" {
		return nil, fmt.Errorf("orchestrator.addr not configured")
	}
	if !strings.Contains(raw, "://") {
		raw = "http://" + raw
	}
	u, err := url.Parse(raw)
	if err != nil {
		return nil, fmt.Errorf("parse orchestrator.addr %q: %w", addr, err)
	}
	if u.Host == "" {
		return nil, fmt.Errorf("orchestrator.addr %q has no host", addr)
	}
	return u, nil
}

func orchestratorHostPort(addr string) (string, error) {
	u, err := orchestratorURL(addr)
	if err != nil {
		return "", err
	}
	return u.Host, nil
}

// waitForOrchestratorNetwork polls orchestratord for the current network.
// orchestratord owns the bitcoin.conf — bitwindowd is just a consumer of
// relayShutdownToOrchestratord fires the orchestratord Shutdown RPC on
// bitwindowd exit. Best-effort: orchestratord acks immediately (the drain
// runs in its own goroutine), and Shutdown is idempotent so a duplicate call
// (Stop handler already relayed) is harmless. Short timeout so a dead/wedged
// orchestratord doesn't keep bitwindowd hanging on shutdown.
func relayShutdownToOrchestratord(addr, bitwindowDir string, log zerolog.Logger) {
	if addr == "" {
		return
	}
	client := orchrpc.NewOrchestratorServiceClient(http.DefaultClient, addr, connect.WithGRPC(), connect.WithInterceptors(localauth.Interceptor(bitwindowDir)))
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if _, err := client.Shutdown(ctx, connect.NewRequest(&orchpb.ShutdownRequest{})); err != nil {
		log.Warn().Err(err).Msg("relay Shutdown to orchestratord on exit (continuing)")
		return
	}
	log.Info().Msg("relayed Shutdown to orchestratord on exit")
}

// that view of the world. Retries for ~15s while orchestratord boots.
func waitForOrchestratorNetwork(ctx context.Context, addr, bitwindowDir string, log zerolog.Logger) (string, error) {
	if addr == "" {
		return "", fmt.Errorf("orchestrator.addr not configured")
	}

	confClient := orchrpc.NewBitcoinConfServiceClient(http.DefaultClient, addr, connect.WithGRPC(), connect.WithInterceptors(localauth.Interceptor(bitwindowDir)))

	for i := 0; i < 30; i++ {
		resp, err := confClient.GetBitcoinConfig(ctx, connect.NewRequest(&orchpb.GetBitcoinConfigRequest{}))
		if err == nil {
			network := resp.Msg.GetNetwork()
			if network == "" {
				return "", fmt.Errorf("orchestratord returned empty network")
			}
			log.Info().Str("network", network).Int("attempts", i+1).Msg("aligned to orchestratord network")
			return network, nil
		}
		if i == 29 {
			return "", fmt.Errorf("orchestratord did not become ready: %w", err)
		}
		select {
		case <-ctx.Done():
			return "", ctx.Err()
		case <-time.After(500 * time.Millisecond):
		}
	}
	return "", fmt.Errorf("orchestratord did not become ready in time")
}

// splitAddr parses a host:port flag value.
func splitAddr(addr string) (string, int, error) {
	host, portStr, err := net.SplitHostPort(addr)
	if err != nil {
		return "", 0, err
	}
	port, err := strconv.Atoi(portStr)
	if err != nil {
		return "", 0, fmt.Errorf("invalid port %q: %w", portStr, err)
	}
	return host, port, nil
}
