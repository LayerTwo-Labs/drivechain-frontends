package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/urfave/cli/v2"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	walletrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func main() {
	app := &cli.App{
		Name:  "orchestratord",
		Usage: "Sidechain orchestrator daemon",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "datadir",
				Usage:   "data directory",
				Value:   orchestrator.DefaultDataDir(),
				EnvVars: []string{"ORCHESTRATOR_DATADIR"},
			},
			&cli.StringFlag{
				Name:    "network",
				Usage:   "bitcoin network (mainnet, testnet, signet, regtest)",
				Value:   "signet",
				EnvVars: []string{"ORCHESTRATOR_NETWORK"},
			},
			&cli.StringFlag{
				Name:    "rpclisten",
				Usage:   "gRPC listen address",
				Value:   "localhost:30400",
				EnvVars: []string{"ORCHESTRATOR_RPCLISTEN"},
			},
			&cli.StringFlag{
				Name:    "loglevel",
				Usage:   "log level (debug, info, warn, error)",
				Value:   "info",
				EnvVars: []string{"ORCHESTRATOR_LOGLEVEL"},
			},
			&cli.StringFlag{
				Name:    "bitwindow-dir",
				Usage:   "path to bitwindow data directory",
				Value:   orchestrator.DefaultBitwindowDir(),
				EnvVars: []string{"ORCHESTRATOR_BITWINDOW_DIR"},
			},
		},
		Action: run,
	}

	if err := app.Run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run(cctx *cli.Context) error {
	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	// Set up logging
	level, err := zerolog.ParseLevel(cctx.String("loglevel"))
	if err != nil {
		level = zerolog.InfoLevel
	}
	log := zerolog.New(zerolog.ConsoleWriter{Out: os.Stdout}).
		Level(level).
		With().
		Timestamp().
		Logger()

	dataDir := cctx.String("datadir")
	network := cctx.String("network")
	listenAddr := cctx.String("rpclisten")

	log.Info().
		Str("datadir", dataDir).
		Str("network", network).
		Str("rpclisten", listenAddr).
		Msg("starting orchestratord")

	// Load binary configs from JSON (in bitwindow dir), falling back to hardcoded defaults
	bitwindowDir := cctx.String("bitwindow-dir")
	configPath := orchestrator.ConfigFilePath(bitwindowDir)
	configs := orchestrator.LoadConfigFile(configPath, log)
	orch := orchestrator.New(dataDir, network, bitwindowDir, configs, log)

	// Watch config file for changes
	stopWatch, err := orchestrator.WatchConfigFile(configPath, func(newConfigs []orchestrator.BinaryConfig) {
		orch.UpdateConfigs(newConfigs)
	}, log)
	if err != nil {
		log.Warn().Err(err).Msg("failed to watch config file")
	} else {
		defer stopWatch()
	}

	// Adopt orphaned processes from previous session
	if err := orch.AdoptOrphans(ctx); err != nil {
		log.Warn().Err(err).Msg("adopt orphans")
	}

	// Set up wallet service
	walletSvc := wallet.NewService(bitwindowDir, log)
	if err := walletSvc.Init(); err != nil {
		log.Warn().Err(err).Msg("wallet service init")
	}
	defer walletSvc.Close()

	// Wire wallet engine for Core wallet management
	walletEngine := orchestrator.NewWalletEngine(
		walletSvc,
		orch.CoreStatusClient,
		network,
		log,
	)
	orch.WalletEngine = walletEngine

	// Wire callback: when a non-enforcer wallet is created, also create it in Bitcoin Core
	walletSvc.OnCreateCoreWallet = func(walletName string, seedHex string) error {
		return orch.CreateCoreWallet(walletName, seedHex)
	}

	// Set up gRPC/ConnectRPC server
	handler := api.NewHandler(orch)
	mux := http.NewServeMux()

	path, h := rpc.NewOrchestratorServiceHandler(handler, connect.WithInterceptors())
	mux.Handle(path, h)

	// Wallet manager service
	walletHandler := api.NewWalletHandler(walletSvc)
	walletPath, walletH := walletrpc.NewWalletManagerServiceHandler(walletHandler, connect.WithInterceptors())
	mux.Handle(walletPath, walletH)

	// Bitcoin config service
	if orch.BitcoinConf != nil {
		confHandler := api.NewBitcoinConfHandler(orch.BitcoinConf)
		confPath, confH := rpc.NewBitcoinConfServiceHandler(confHandler, connect.WithInterceptors())
		mux.Handle(confPath, confH)
	}

	// Enforcer config service
	if orch.EnforcerConf != nil {
		enforcerHandler := api.NewEnforcerConfHandler(orch.EnforcerConf)
		enforcerPath, enforcerH := rpc.NewEnforcerConfServiceHandler(enforcerHandler, connect.WithInterceptors())
		mux.Handle(enforcerPath, enforcerH)
	}

	srv := &http.Server{
		Addr:    listenAddr,
		Handler: h2c.NewHandler(mux, &http2.Server{}),
	}

	// Start server
	errs := make(chan error, 1)
	go func() {
		log.Info().Str("addr", listenAddr).Msg("serving gRPC")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errs <- fmt.Errorf("serve: %w", err)
		}
	}()

	// Wait for shutdown signal or error
	select {
	case <-ctx.Done():
		log.Info().Msg("received shutdown signal")
	case err := <-errs:
		log.Error().Err(err).Msg("server error")
		cancel()
	}

	// Graceful shutdown: stop all managed binaries
	log.Info().Msg("shutting down managed binaries...")
	shutdownCh, err := orch.ShutdownAll(context.Background(), false)
	if err != nil {
		log.Error().Err(err).Msg("shutdown all")
	} else {
		for p := range shutdownCh {
			if p.CurrentBinary != "" {
				log.Info().Str("binary", p.CurrentBinary).Msg("stopping")
			}
		}
	}

	// Shutdown HTTP server
	log.Info().Msg("shutting down gRPC server...")
	if err := srv.Close(); err != nil {
		log.Error().Err(err).Msg("close server")
	}

	log.Info().Msg("orchestratord shutdown complete")
	return nil
}
