package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	engines "github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	bitcoindrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	coreproxy "github.com/barebitcoin/btc-buf/server"
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

	bitcoindConnector := func(ctx context.Context) (bitcoindrpc.BitcoinServiceClient, error) {
		return startCoreProxy(ctx, conf)
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

	config := api.Config{
		GUIBootedMainchain: conf.GuiBootedMainchain,
		GUIBootedEnforcer:  conf.GuiBootedEnforcer,
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
		errs <- deniabilityEngine.Run(ctx)
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

func startCoreProxy(ctx context.Context, conf config.Config) (bitcoindrpc.BitcoinServiceClient, error) {
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
	)
	if err != nil {
		return nil, err
	}

	return core, nil
}
