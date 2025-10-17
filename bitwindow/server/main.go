package main

import (
	"context"
	"fmt"
	"net"
	"os"
	"os/signal"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	engines "github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/version"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	coreproxy "github.com/barebitcoin/btc-buf/server"
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

	services := api.Services{
		Database:          db,
		BitcoindConnector: bitcoindConnector,
		WalletConnector:   walletConnector,
		EnforcerConnector: enforcerConnector,
		CryptoConnector:   cryptoConnector,
	}

	// Use this to obtain a random unused port for the core proxy.
	coreProxyListener, err := net.Listen("tcp", "localhost:")
	if err != nil {
		return fmt.Errorf("listen on core proxy: %w", err)
	}

	if err := coreProxyListener.Close(); err != nil {
		return fmt.Errorf("close core proxy listener: %w", err)
	}

	config := api.Config{
		BitcoinCoreProxyHost: coreProxyListener.Addr().String(),
		GUIBootedMainchain:   conf.GuiBootedMainchain,
		GUIBootedEnforcer:    conf.GuiBootedEnforcer,
		OnShutdown: func() {
			log.Info().Msg("shutting down")
			cancelCtx()
		},
	}
	srv, err := api.New(
		ctx,
		services,
		config,
	)
	if err != nil {
		return err
	}

	bitcoinEngine := engines.NewBitcoind(srv.Bitcoind, db, conf)
	deniabilityEngine := engines.NewDeniability(srv.Wallet, srv.Bitcoind, db)

	log.Info().Msgf("server: listening on %s", conf.APIHost)

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
				log.Error().Err(err).Msg("unable to acquire and start ZMQ engine")

				select {
				case <-ctx.Done():
					return

				case <-time.After(time.Second * 5):
					log.Debug().Msgf("waited a bit for the ZMQ engine, trying again")
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
		Level(logLevel)

	zerolog.DefaultContextLogger = &logger
}

func startCoreProxy(ctx context.Context, conf config.Config) (*coreproxy.Bitcoind, error) {
	logLevel := zerolog.WarnLevel

	// We don't want info logs from the core proxy because the ReconnectLoop()
	// makes it spammy
	warnLogger := zerolog.Ctx(ctx).Level(logLevel)
	ctx = warnLogger.WithContext(ctx)

	core, err := coreproxy.NewBitcoind(
		ctx, conf.BitcoinCoreHost,
		conf.BitcoinCoreRpcUser, conf.BitcoinCoreRpcPassword,

		// Also configure the per-request log level
		coreproxy.WithLogging(func(ctx context.Context) *zerolog.Logger {
			log := zerolog.Ctx(ctx).Level(logLevel)
			return &log
		}),

		// We don't want startup of bitwindow to depend on Core running
		coreproxy.WithoutInitialConnectionCheck(),
	)
	if err != nil {
		return nil, err
	}

	return core, nil
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
