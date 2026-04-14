package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	_ "net/http/pprof"
	"net/url"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"os/exec"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	engines "github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/version"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/jessevdk/go-flags"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
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

	// Now that the logger is initialized, we can use zerolog.Ctx(ctx) safely
	log := zerolog.Ctx(ctx)
	log.Info().Msgf("logger initialized successfully with file %q", conf.LogPath)

	log.Debug().
		Msgf("initiating database")

	db, err := database.New(ctx, conf)
	if err != nil {
		log.Error().Err(err).Msg("init database")
		return fmt.Errorf("init database: %w", err)
	}
	defer database.SafeDefer(ctx, db.Close)

	// Start orchestratord as a subprocess — it manages bitcoind, enforcer, and sidechains.
	orchCmd, err := startOrchestratord(ctx, conf)
	if err != nil {
		log.Warn().Err(err).Msg("failed to start orchestratord (may already be running)")
	} else {
		defer func() {
			if orchCmd.Process != nil {
				log.Info().Int("pid", orchCmd.Process.Pid).Msg("stopping orchestratord")
				_ = orchCmd.Process.Signal(os.Interrupt)
				_ = orchCmd.Wait()
			}
		}()
	}

	// Tell orchestratord to start the L1 stack (bitcoind → wallet → IBD → enforcer).
	// This runs in the background — bitwindowd doesn't need to wait for it.
	go func() {
		orchClient := orchrpc.NewOrchestratorServiceClient(
			http.DefaultClient,
			conf.OrchestratorAddr,
			connect.WithGRPC(),
		)

		// Wait for orchestratord to be ready.
		for i := 0; i < 30; i++ {
			_, err := orchClient.ListBinaries(ctx, connect.NewRequest(&orchpb.ListBinariesRequest{}))
			if err == nil {
				break
			}
			time.Sleep(500 * time.Millisecond)
		}

		log.Info().Msg("kicking off L1 stack via orchestrator")
		stream, err := orchClient.StartWithL1(ctx, connect.NewRequest(&orchpb.StartWithL1Request{
			Target: "enforcer",
		}))
		if err != nil {
			log.Warn().Err(err).Msg("failed to start L1 stack (non-fatal)")
			return
		}
		for stream.Receive() {
			msg := stream.Msg()
			if msg.GetError() != "" {
				log.Warn().Str("stage", msg.GetStage()).Str("error", msg.GetError()).Msg("L1 startup issue (non-fatal)")
			}
			if msg.GetDone() {
				break
			}
		}
	}()

	bitcoindConnector := func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		bitcoind, err := startCoreProxy(ctx, conf)
		return bitcoind, err
	}

	coreProxy, err := startCoreProxy(ctx, conf)
	if err != nil {
		return fmt.Errorf("init core proxy: %w", err)
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

	// Wallet should be in parent dir (shared across all networks)
	walletDir := filepath.Dir(conf.Datadir)
	chainParams := getChainParams(conf.BitcoinCoreNetwork)
	services := api.Services{
		Database:          db,
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

		ChainParams:      chainParams,
		WalletDir:        walletDir,
		DataDir:          conf.Datadir,
		OrchestratorAddr: conf.OrchestratorAddr,
	}

	// Use this to obtain a random unused port for the core proxy.
	coreProxyListener, err := net.Listen("tcp", "localhost:")
	if err != nil {
		return fmt.Errorf("listen on core proxy: %w", err)
	}

	if err := coreProxyListener.Close(); err != nil {
		return fmt.Errorf("close core proxy listener: %w", err)
	}

	srv, err := api.New(
		ctx,
		services,
		conf,
		coreProxyListener,
		func(ctx context.Context) {
			log.Info().Msg("shutting down")
			cancelCtx()
		},
	)
	if err != nil {
		return err
	}

	// Start the cheque engine
	srv.ChequeEngine.Start(ctx)

	// Auto-unlock unencrypted wallets
	go func() {
		walletPath := filepath.Join(walletDir, "wallet.json")
		encryptionMetadataPath := filepath.Join(walletDir, "wallet_encryption.json")

		// Check if wallet file exists
		if _, err := os.Stat(walletPath); err != nil {
			return
		}

		// If wallet_encryption.json exists, wallet is encrypted - skip auto-unlock
		if _, err := os.Stat(encryptionMetadataPath); err == nil {
			log.Info().Msg("wallet is encrypted, skipping auto-unlock")
			return
		}

		log.Info().Msg("unencrypted wallet detected, auto-unlocking cheque engine")

		// Load wallet data
		walletData, err := os.ReadFile(walletPath)
		if err != nil {
			log.Error().Err(err).Msg("failed to read wallet for auto-unlock")
			return
		}

		var walletMap map[string]any
		if err := json.Unmarshal(walletData, &walletMap); err != nil {
			log.Error().Err(err).Msg("failed to parse wallet for auto-unlock")
			return
		}

		// Unlock the wallet engine with the wallet data
		if err := srv.WalletEngine.Unlock(walletMap); err != nil {
			log.Error().Err(err).Msg("failed to auto-unlock wallet engine")
		} else {
			log.Info().Msg("wallet engine auto-unlocked successfully")
		}
	}()

	bitcoinEngine := engines.NewBitcoind(srv.Bitcoind, db, conf)
	deniabilityEngine := engines.NewDeniability(srv.Wallet, srv.Bitcoind, db, srv.WalletEngine)

	log.Info().Msgf("server: listening on %s", conf.APIHost)

	// Start pprof server for profiling (memory leaks, CPU, etc.)
	// Access at http://localhost:6060/debug/pprof/
	go func() {
		pprofAddr := "localhost:6060"
		log.Info().Msgf("pprof: listening on %s", pprofAddr)
		if err := http.ListenAndServe(pprofAddr, nil); err != nil {
			log.Error().Err(err).Msg("pprof server failed")
		}
	}()

	errs := make(chan error)
	go func() {
		errs <- srv.Serve(ctx, conf.APIHost)
	}()
	go func() {
		errs <- bitcoinEngine.Run(ctx)
	}()
	go func() {
		log.Info().Msgf("core proxy: listening on %s", coreProxyListener.Addr().String())
		errs <- coreProxy.Listen(ctx, coreProxyListener.Addr().String())
	}()
	go func() {
		errs <- deniabilityEngine.Run(ctx)
	}()
	go func() {
		errs <- srv.TimestampEngine.Run(ctx)
	}()
	go func() {
		errs <- srv.NotificationEngine.Run(ctx)
	}()
	go func() {
		errs <- srv.SidechainMonitorEngine.Run(ctx)
	}()

	// Start demo engine if in demo mode (mainnet)
	if conf.IsDemoMode() {
		demoEngine := engines.NewDemoEngine(db)
		go func() {
			errs <- demoEngine.Run(ctx)
		}()
		log.Info().Msg("demo mode enabled: simulating sidechain activity")
	}

	// If Bitcoin Core publishes raw transactions, we can use this to handle
	// pending mempool entries. ZMQ notifications might not be available
	// right away. We want a retry mechanism that doesn't stall startup for
	// the rest of the system.

	go func() {
		var zmqEngine *engines.ZMQ
		const maxAttempts = 20

		for attempt := range maxAttempts {
			var err error
			zmqEngine, err = getZmqEngine(ctx, conf)
			if err != nil {
				// Connection errors during startup are expected
				if connect.CodeOf(err) == connect.CodeUnavailable || strings.Contains(err.Error(), "connection refused") {
					log.Debug().Msg("ZMQ engine: waiting for Bitcoin Core connection")
				} else {
					log.Error().Err(err).Msg("unable to acquire and start ZMQ engine")
				}

				select {
				case <-ctx.Done():
					return

				case <-time.After(time.Second * 5):
				}

				continue
			}

			if attempt != 0 {
				log.Debug().Msgf("ZMQ engine acquired on attempt %d", attempt)
			}
			break

		}

		if zmqEngine == nil {
			log.Warn().Msg("no ZMQ engine acquired, skipping")
			return
		}

		go func() {
			for tx := range zmqEngine.Subscribe() {
				if err := bitcoinEngine.HandleNewRawTransaction(ctx, tx); err != nil {
					log.Error().Err(err).Msgf("handle new raw transaction: %s", tx.TxHash())
				}
			}
		}()

		log.Info().Msg("starting ZMQ engine")
		errs <- zmqEngine.Run(ctx)
	}()

	go func() {
		<-ctx.Done()

		ctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), time.Second*1)
		defer cancel()

		srv.Shutdown(ctx)

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

var (
	coreProxyMu      sync.Mutex
	cachedCoreProxy  *coreproxy.Bitcoind
	coreProxyLogOnce sync.Once
)

func startCoreProxy(ctx context.Context, conf config.Config) (*coreproxy.Bitcoind, error) {
	coreProxyMu.Lock()
	defer coreProxyMu.Unlock()

	// Return cached instance if available
	if cachedCoreProxy != nil {
		return cachedCoreProxy, nil
	}

	coreURL, err := url.Parse(conf.BitcoinCoreURL)
	if err != nil {
		return nil, fmt.Errorf("parse bitcoin core url: %w", err)
	}

	// Log only once
	coreProxyLogOnce.Do(func() {
		at := coreURL.Host
		if conf.BitcoinCoreRpcUser != "" {
			at = fmt.Sprintf("%s:****@%s", conf.BitcoinCoreRpcUser, at)
		}
		zerolog.Ctx(ctx).Info().
			Msgf("starting Bitcoin Core proxy at %s", at)
	})

	logLevel := zerolog.WarnLevel

	// We don't want info logs from the core proxy because the ReconnectLoop()
	// makes it spammy
	warnLogger := zerolog.Ctx(ctx).Level(logLevel)
	initCtx := warnLogger.WithContext(ctx)

	opts := []coreproxy.Option{
		// Also configure the per-request log level
		coreproxy.WithLogging(func(ctx context.Context) *zerolog.Logger {
			log := zerolog.Ctx(ctx).Level(logLevel)
			return &log
		}),

		// We don't want startup of bitwindow to depend on Core running
		coreproxy.WithoutInitialConnectionCheck(),
	}

	if coreURL.Scheme == "https" {
		opts = append(opts, coreproxy.WithTLS())
	}

	proxy, err := coreproxy.NewBitcoind(
		initCtx, coreURL.Host,
		conf.BitcoinCoreRpcUser, conf.BitcoinCoreRpcPassword,
		opts...,
	)
	if err != nil {
		return nil, err
	}

	// Cache on success
	cachedCoreProxy = proxy
	return cachedCoreProxy, nil
}

func getZmqEngine(ctx context.Context, conf config.Config) (*engines.ZMQ, error) {
	btc, err := startCoreProxy(ctx, conf)
	if err != nil {
		return nil, fmt.Errorf("start core proxy: %w", err)
	}

	notifs, err := btc.GetZmqNotifications(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return nil, fmt.Errorf("get zmq notifications: %w", err)
	}

	pubRawTxAddress, foundPubRawTx := lo.Find(notifs.Msg.Notifications,
		func(n *corepb.GetZmqNotificationsResponse_Notification) bool {
			return n.Type == "pubrawtx"
		})

	if !foundPubRawTx {
		return nil, nil
	}

	return engines.NewZMQ(pubRawTxAddress.Address)
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
	orchPath := filepath.Join(filepath.Dir(selfPath), "orchestratord")
	if _, err := os.Stat(orchPath); err != nil {
		return nil, fmt.Errorf("orchestratord not found at %s: %w", orchPath, err)
	}

	// Build args from our config.
	// bitwindow-dir is the parent of the network-specific datadir —
	// wallet.json lives there, not under the network subdirectory.
	bitwindowDir := filepath.Dir(conf.Datadir)
	args := []string{
		"--network", string(conf.BitcoinCoreNetwork),
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

func getChainParams(network config.Network) *chaincfg.Params {
	switch network {
	case config.NetworkMainnet:
		return &chaincfg.MainNetParams
	case config.NetworkForknet:
		return &chaincfg.MainNetParams
	case config.NetworkTestnet:
		return &chaincfg.TestNet3Params
	case config.NetworkSignet:
		return &chaincfg.SigNetParams
	case config.NetworkRegtest:
		return &chaincfg.RegressionNetParams
	default:
		return &chaincfg.SigNetParams
	}
}
