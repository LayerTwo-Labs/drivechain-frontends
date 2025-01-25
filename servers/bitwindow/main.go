package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"time"

	"connectrpc.com/connect"
	database "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/database"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/dial"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/dir"
	bitcoind_engine "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/engines"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/server"
	pb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/jessevdk/go-flags"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/samber/lo"
)

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	logger := zerolog.
		New(zerolog.NewConsoleWriter()).
		Level(zerolog.InfoLevel)

	zerolog.DefaultContextLogger = &logger

	if err := realMain(ctx, cancel); err != nil {

		// Error has been printed to the console!
		if _, ok := lo.ErrorsAs[*flags.Error](err); ok {
			os.Exit(1)
		}
		// the zerolog logger won't work here, because the file logger is closed.
		// what we do instead is a simple printf
		fmt.Printf("main: got error: %T - %v\n", err, err)
		os.Exit(1)
	}
}

func realMain(ctx context.Context, cancelCtx context.CancelFunc) error {
	conf, err := readConfig()
	if err != nil {
		if !flags.WroteHelp(err) {
			zerolog.Ctx(ctx).Error().Err(err).Msg("read config")
		}
		return err
	}

	const binaryName = "bitwindowd"
	datadir, err := dir.GetDataDir(binaryName)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("get data dir")
		return err
	}
	if conf.LogPath == "" {
		conf.LogPath = filepath.Join(datadir, "debug.log")
	}

	logFile, err := os.OpenFile(conf.LogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		return fmt.Errorf("open log file: %w", err)
	}

	if err := initLogger(logFile); err != nil {
		return fmt.Errorf("initialize logger")
	}

	// Now that the logger is initialized, we can use zerolog.Ctx(ctx) safely
	log := zerolog.Ctx(ctx)
	log.Info().Msgf("logger initialized successfully with file %q", conf.LogPath)

	log.Debug().
		Msgf("initiating database")

	db, err := database.New(ctx)
	if err != nil {
		log.Error().Err(err).Msg("init database")
		return fmt.Errorf("init database: %w", err)
	}
	defer db.Close()

	proxy, err := startCoreProxy(ctx, conf)
	if err != nil {
		log.Error().Err(err).Msg("start core proxy")
		return err
	}

	info, err := proxy.GetBlockchainInfo(ctx, connect.NewRequest(&pb.GetBlockchainInfoRequest{}))
	if err != nil {
		log.Error().Err(err).Msg("get blockchain info")
		return err
	}
	log.Info().Msgf("blockchain info: %s", info.Msg.String())

	enforcer, wallet, err := connectEnforcerWithRetry(ctx, conf.EnforcerHost)
	if err != nil {
		log.Error().Err(err).Msg("connect to enforcer")
		return err
	}

	srv, err := server.New(ctx, proxy, wallet, enforcer, db, func() {
		log.Info().Msg("shutting down")
		// cancelling this context will trigger the server to shutdown
		cancelCtx()
	})
	if err != nil {
		return err
	}

	bitcoinEngine := bitcoind_engine.New(proxy, db)

	log.Info().Msgf("server: listening on %s", conf.APIHost)

	errs := make(chan error)
	go func() {
		errs <- bitcoinEngine.Run(ctx)
	}()
	go func() {
		errs <- srv.Serve(ctx, conf.APIHost)
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

func initLogger(logFile *os.File) error {
	// We want pretty printing to the file as well. This is not meant for
	// centralized log ingestion, where JSON is crucial.
	logWriter := zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
		w.Out = logFile
		w.NoColor = true // ANSI colors don't work well with file output.
	})
	multiWriter := zerolog.MultiLevelWriter(
		zerolog.NewConsoleWriter(),
		logWriter,
	)

	logger := zerolog.New(multiWriter).
		With().
		Timestamp().
		Logger().
		Level(zerolog.InfoLevel)
	zerolog.DefaultContextLogger = &logger

	return nil
}

func startCoreProxy(ctx context.Context, conf Config) (*coreproxy.Bitcoind, error) {
	core, err := coreproxy.NewBitcoind(
		ctx, conf.BitcoinCoreHost,
		conf.BitcoinCoreRpcUser, conf.BitcoinCoreRpcPassword,
	)
	if err != nil {
		return nil, err
	}

	return core, nil
}

// connectEnforcerWithRetry attempts to connect to the enforcer for up to 1 minute
func connectEnforcerWithRetry(ctx context.Context, host string) (rpc.ValidatorServiceClient, rpc.WalletServiceClient, error) {
	var enforcer rpc.ValidatorServiceClient
	var wallet rpc.WalletServiceClient

	// Try connecting immediately first
	enforcer, wallet, err := dial.Enforcer(ctx, host)
	if err == nil {
		log.Info().Msg("successfully connected to enforcer")
		return enforcer, wallet, nil
	}
	log.Debug().Err(err).Msg("could not connect to enforcer, retrying")

	timeout := time.After(1 * time.Minute)
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	// if initial connection fails, retry for 1 minute. enforcer might be syncing
	for {
		select {
		case <-timeout:
			log.Warn().Msg("could not connect to enforcer after 1 minute, continuing without enforcer")
			return nil, nil, nil
		case <-ticker.C:
			enforcer, wallet, err = dial.Enforcer(ctx, host)
			if err != nil {
				log.Debug().Err(err).Msg("could not connect to enforcer, retrying")
				continue
			}
			log.Info().Msg("successfully connected to enforcer")
			return enforcer, wallet, nil
		case <-ctx.Done():
			return nil, nil, ctx.Err()
		}
	}
}
