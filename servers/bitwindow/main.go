package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/bdk"
	database "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/database"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/dial"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/dir"
	bitcoind_engine "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/engines"
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

	if err := realMain(ctx); err != nil {
		cancel()

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

func realMain(ctx context.Context) error {
	conf, err := readConfig()
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("read config")
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

	cleanup, err := initFileLogger(conf)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("init logger")
		return err
	}
	defer cleanup()

	// Now that the logger is initialized, we can use zerolog.Ctx(ctx) safely
	log := zerolog.Ctx(ctx)
	log.Info().Msg("logger initialized successfully")

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

	enforcer, err := dial.Enforcer(ctx, conf.EnforcerHost)
	if err != nil {
		log.Error().Err(err).Msg("connect to enforcer")
		// enforcer does not work right now, but we still want to test
		// the rest of the server
	}

	log.Info().Msgf("blockchain info: %s", info.Msg.String())

	electrumProtocol := "ssl"
	if conf.ElectrumNoSSL {
		electrumProtocol = "tcp"
	}

	const network = "signet"
	wallet, err := bdk.NewWallet(
		ctx, network,
		fmt.Sprintf("%s://%s", electrumProtocol, conf.ElectrumHost),
		conf.Passphrase, conf.XPrivOverride,
	)
	if err != nil {
		return err
	}

	if conf.DescriptorPrint {
		log.Info().
			Str("descriptor", wallet.Descriptor).
			Msg("bdk: descriptor is")
	}

	// Verify the wallet is wired together correctly
	if err := wallet.Sync(ctx); err != nil {
		return fmt.Errorf("initial wallet sync: %w", err)
	}

	log.Debug().
		Msgf("initiating electrum connection at %s", wallet.Electrum)

	srv, err := server.New(ctx, proxy, wallet, enforcer, db)
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

func initFileLogger(conf Config) (func(), error) {
	if conf.LogPath == "" {
		return func() {}, nil
	}

	logFile, err := os.OpenFile(conf.LogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		return nil, fmt.Errorf("failed to open log file: %w", err)
	}

	multiWriter := zerolog.MultiLevelWriter(
		zerolog.NewConsoleWriter(),
		logFile,
	)

	logger := zerolog.New(multiWriter).
		With().
		Timestamp().
		Logger().
		Level(zerolog.InfoLevel)
	zerolog.DefaultContextLogger = &logger

	log.Info().Str("file", logFile.Name()).Msg("logging to file")

	return func() {
		if err := logFile.Close(); err != nil {
			log.Error().Err(err).Msg("failed to close log file")
		}
		log.Info().Msg("closed log file")
	}, nil
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
