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
	orchapi "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	orchconfig "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"

	thunderapi "github.com/LayerTwo-Labs/sidesail/thunder/server/api"
	thunderrpc "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/thunder/v1/thunderv1connect"
	walletrpc "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/thunder/server/rpc"
)

func main() {
	app := &cli.App{
		Name:  "thunderd",
		Usage: "Thunder sidechain orchestrator daemon",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "datadir",
				Usage:   "data directory",
				Value:   orchestrator.DefaultDataDir(),
				EnvVars: []string{"THUNDERD_DATADIR"},
			},
			&cli.StringFlag{
				Name:    "network",
				Usage:   "bitcoin network (mainnet, testnet, signet, regtest)",
				Value:   "signet",
				EnvVars: []string{"THUNDERD_NETWORK"},
			},
			&cli.StringFlag{
				Name:    "rpclisten",
				Usage:   "gRPC listen address",
				Value:   "localhost:30302",
				EnvVars: []string{"THUNDERD_RPCLISTEN"},
			},
			&cli.StringFlag{
				Name:    "loglevel",
				Usage:   "log level (debug, info, warn, error)",
				Value:   "info",
				EnvVars: []string{"THUNDERD_LOGLEVEL"},
			},
			&cli.StringFlag{
				Name:    "bitwindow-dir",
				Usage:   "path to bitwindow data directory (for wallet.json)",
				Value:   defaultBitwindowDir(),
				EnvVars: []string{"THUNDERD_BITWINDOW_DIR"},
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
		Msg("starting thunderd")

	// Only Thunder-relevant binaries: bitcoind, enforcer, and thunder itself
	var configs []orchestrator.BinaryConfig
	for _, name := range []string{"bitcoind", "enforcer", "thunder"} {
		cfg, ok := orchestrator.BinaryConfigByName(name)
		if !ok {
			log.Fatal().Str("binary", name).Msg("binary config not found")
		}
		configs = append(configs, cfg)
	}
	bitwindowDir := cctx.String("bitwindow-dir")
	orch := orchestrator.New(dataDir, network, bitwindowDir, configs, log)

	if err := orch.AdoptOrphans(ctx); err != nil {
		log.Warn().Err(err).Msg("adopt orphans")
	}

	// Set up config file watching and network-change callback
	if orch.BitcoinConf != nil {
		orch.BitcoinConf.OnNetworkChanged = func() {
			// Dart: _onBitcoinConfChanged → syncNodeRpcFromBitcoinConf
			if orch.EnforcerConf != nil {
				if err := orch.EnforcerConf.SyncFromBitcoinConf(); err != nil {
					log.Warn().Err(err).Msg("sync enforcer conf after network change")
				}
			}

			log.Info().Msg("network changed, stopping all binaries")
			shutdownCh, err := orch.ShutdownAll(ctx, false)
			if err != nil {
				log.Error().Err(err).Msg("shutdown on network change")
				return
			}
			for p := range shutdownCh {
				if p.CurrentBinary != "" {
					log.Info().Str("binary", p.CurrentBinary).Msg("stopping for network change")
				}
			}

			// Restart the dependency chain: Core → Enforcer → Thunder
			log.Info().Msg("restarting binaries for new network")
			startCh, err := orch.StartWithDeps(ctx, "thunder", orchestrator.StartOpts{
				TargetArgs: []string{"--headless"},
			})
			if err != nil {
				log.Error().Err(err).Msg("start with deps after network change")
				return
			}
			for p := range startCh {
				if p.Error != nil {
					log.Error().Err(p.Error).Msg("restart after network change")
					break
				}
				log.Info().Str("stage", p.Stage).Str("msg", p.Message).Msg("restarting")
			}
		}
		if err := orch.BitcoinConf.StartWatching(); err != nil {
			log.Warn().Err(err).Msg("start config file watching")
		}
	}

	// Initialize wallet service
	walletSvc := wallet.NewService(bitwindowDir, log)
	if err := walletSvc.Init(); err != nil {
		log.Warn().Err(err).Msg("wallet service init")
	}

	// Set wallet service on orchestrator for seed injection
	// Dart: BinaryProvider.start L314-326 + enforcer_rpc.dart L66-69
	orch.WalletSvc = walletSvc

	// Wire up wallet callbacks — matches Dart WalletWriterProvider behavior
	walletNetwork := orchconfig.NetworkFromString(network)

	walletSvc.OnWalletGenerated = func() {
		// Dart L115-132: restartEnforcer — stop enforcer, wait 3s, restart
		log.Info().Msg("wallet generated, restarting enforcer via orchestrator")
		shutdownCh, err := orch.ShutdownAll(ctx, false)
		if err != nil {
			log.Warn().Err(err).Msg("stop binaries after wallet gen")
			return
		}
		for p := range shutdownCh {
			if p.CurrentBinary != "" {
				log.Info().Str("binary", p.CurrentBinary).Msg("stopping after wallet gen")
			}
		}
		// Restart the dependency chain
		startCh, err := orch.StartWithDeps(ctx, "thunder", orchestrator.StartOpts{
			TargetArgs: []string{"--headless"},
		})
		if err != nil {
			log.Warn().Err(err).Msg("restart after wallet gen")
			return
		}
		for p := range startCh {
			if p.Error != nil {
				log.Error().Err(p.Error).Msg("restart after wallet gen")
				break
			}
		}
	}
	walletSvc.OnStopAllBinaries = func() error {
		// Dart L562-575: stop all binaries
		shutdownCh, err := orch.ShutdownAll(ctx, false)
		if err != nil {
			return err
		}
		for p := range shutdownCh {
			if p.CurrentBinary != "" {
				log.Info().Str("binary", p.CurrentBinary).Msg("stopping for wallet wipe")
			}
		}
		return nil
	}
	walletSvc.GetBinaryWalletPaths = func() []string {
		// Dart L600-608: collect wallet paths from all binaries
		var allPaths []string
		for _, dirs := range []orchconfig.BinaryDirConfig{
			orchconfig.BitcoinCoreDirs,
			orchconfig.EnforcerDirs,
			orchconfig.BitWindowDirs,
			orchconfig.ThunderDirs,
		} {
			paths := dirs.GetWalletPaths(dirs.RootDirNetwork(walletNetwork), walletNetwork, log)
			allPaths = append(allPaths, paths...)
		}
		return allPaths
	}
	walletSvc.CoreDataDir = orchconfig.BitcoinCoreDirs.RootDirNetwork(walletNetwork)

	orchHandler := orchapi.NewHandler(orch)
	orchWrapper := thunderapi.NewOrchestratorWrapper(orchHandler, walletSvc, log)
	mux := http.NewServeMux()

	orchPath, orchH := orchrpc.NewOrchestratorServiceHandler(orchWrapper, connect.WithInterceptors())
	mux.Handle(orchPath, orchH)

	// Mount BitcoinConfService so the Flutter frontend can read/write bitcoin config via RPC
	if orch.BitcoinConf != nil {
		btcConfHandler := orchapi.NewBitcoinConfHandler(orch.BitcoinConf)
		btcConfPath, btcConfH := orchrpc.NewBitcoinConfServiceHandler(btcConfHandler)
		mux.Handle(btcConfPath, btcConfH)
	}

	// Mount EnforcerConfService and set up bitcoin conf → enforcer conf sync
	if orch.EnforcerConf != nil {
		enforcerConfHandler := orchapi.NewEnforcerConfHandler(orch.EnforcerConf)
		enforcerConfPath, enforcerConfH := orchrpc.NewEnforcerConfServiceHandler(enforcerConfHandler)
		mux.Handle(enforcerConfPath, enforcerConfH)

		if err := orch.EnforcerConf.StartWatching(); err != nil {
			log.Warn().Err(err).Msg("start enforcer config file watching")
		}
	}

	// Mount ThunderConfService
	thunderConfMgr, err := orchconfig.NewThunderConfManager(orch.BitcoinConf, log)
	if err != nil {
		log.Warn().Err(err).Msg("thunder conf manager init")
	} else {
		thunderConfHandler := orchapi.NewThunderConfHandler(thunderConfMgr)
		thunderConfPath, thunderConfH := orchrpc.NewThunderConfServiceHandler(thunderConfHandler)
		mux.Handle(thunderConfPath, thunderConfH)

		if err := thunderConfMgr.StartWatching(); err != nil {
			log.Warn().Err(err).Msg("start thunder config file watching")
		}
	}

	thunderRPC := rpc.New("127.0.0.1", 6009)
	thunderHandler := thunderapi.NewThunderHandler(thunderRPC)
	thunderPath, thunderH := thunderrpc.NewThunderServiceHandler(thunderHandler)
	mux.Handle(thunderPath, thunderH)

	walletHandler := thunderapi.NewWalletHandler(walletSvc, log)
	walletPath, walletH := walletrpc.NewWalletManagerServiceHandler(walletHandler)
	mux.Handle(walletPath, walletH)

	srv := &http.Server{
		Addr:    listenAddr,
		Handler: h2c.NewHandler(mux, &http2.Server{}),
	}

	errs := make(chan error, 1)
	go func() {
		log.Info().Str("addr", listenAddr).Msg("serving gRPC")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errs <- fmt.Errorf("serve: %w", err)
		}
	}()

	select {
	case <-ctx.Done():
		log.Info().Msg("received shutdown signal")
	case err := <-errs:
		log.Error().Err(err).Msg("server error")
		cancel()
	}

	walletSvc.Close()
	if orch.BitcoinConf != nil {
		orch.BitcoinConf.StopWatching()
	}
	if orch.EnforcerConf != nil {
		orch.EnforcerConf.StopWatching()
	}

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

	log.Info().Msg("shutting down gRPC server...")
	if err := srv.Close(); err != nil {
		log.Error().Err(err).Msg("close server")
	}

	log.Info().Msg("thunderd shutdown complete")
	return nil
}

func defaultBitwindowDir() string {
	return orchconfig.BitWindowDirs.RootDir()
}
