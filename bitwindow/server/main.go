package main

import (
	"context"
	"fmt"
	"net/http"
	_ "net/http/pprof"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
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

	orchCmd, err := startOrchestratord(bootCtx, conf)
	if err != nil {
		bootLogger.Warn().Err(err).Msg("failed to start orchestratord (may already be running)")
	} else if orchCmd != nil {
		defer func() {
			if orchCmd.Process != nil {
				bootLogger.Info().Int("pid", orchCmd.Process.Pid).Msg("stopping orchestratord")
				_ = orchCmd.Process.Signal(os.Interrupt)
				_ = orchCmd.Wait()
			}
		}()
	}

	network, err := waitForOrchestratorNetwork(bootCtx, conf.OrchestratorAddr, bootLogger)
	if err != nil {
		return fmt.Errorf("read network from orchestratord: %w", err)
	}

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
		return dial.Thunder(ctx, "localhost", 6009)
	}
	bitnamesConnector := func(ctx context.Context) (*bitnames.Client, error) {
		return dial.BitNames(ctx, "localhost", 6002)
	}
	bitassetsConnector := func(ctx context.Context) (*bitassets.Client, error) {
		return dial.BitAssets(ctx, "localhost", 6004)
	}
	truthcoinConnector := func(ctx context.Context) (*truthcoin.Client, error) {
		return dial.Truthcoin(ctx, "localhost", 6013)
	}
	photonConnector := func(ctx context.Context) (*photon.Client, error) {
		return dial.Photon(ctx, "localhost", 6099)
	}
	coinshiftConnector := func(ctx context.Context) (*coinshift.Client, error) {
		return dial.CoinShift(ctx, "localhost", 6255)
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

		OrchestratorAddr: conf.OrchestratorAddr,
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
// If orchestratord is already running (e.g. from a previous session), it adopts
// the existing instance instead of spawning a new one.
func startOrchestratord(ctx context.Context, conf config.Config) (*exec.Cmd, error) {
	log := zerolog.Ctx(ctx)

	// Check if orchestratord is already running by trying to connect.
	orchClient := orchrpc.NewOrchestratorServiceClient(
		http.DefaultClient,
		conf.OrchestratorAddr,
		connect.WithGRPC(),
	)
	_, err := orchClient.ListBinaries(ctx, connect.NewRequest(&orchpb.ListBinariesRequest{}))
	if err == nil {
		log.Info().Msg("orchestratord already running, adopting existing instance")
		return nil, nil
	}

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
	bitwindowDir := conf.BitwindowDir()
	args := []string{
		"--datadir", bitwindowDir,
		"--bitwindow-dir", bitwindowDir,
	}

	log.Info().Str("path", orchPath).Strs("args", args).Msg("starting orchestratord")

	cmd := exec.CommandContext(ctx, orchPath, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("start orchestratord: %w", err)
	}

	log.Info().Int("pid", cmd.Process.Pid).Msg("orchestratord started")

	return cmd, nil
}

// waitForOrchestratorNetwork polls orchestratord for the current network.
// orchestratord owns the bitcoin.conf — bitwindowd is just a consumer of
// that view of the world. Retries for ~15s while orchestratord boots.
func waitForOrchestratorNetwork(ctx context.Context, addr string, log zerolog.Logger) (string, error) {
	if addr == "" {
		return "", fmt.Errorf("orchestrator.addr not configured")
	}

	confClient := orchrpc.NewBitcoinConfServiceClient(http.DefaultClient, addr, connect.WithGRPC())

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
