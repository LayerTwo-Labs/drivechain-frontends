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

	zsideapi "github.com/LayerTwo-Labs/sidesail/zside/server/api"
	zsiderpc "github.com/LayerTwo-Labs/sidesail/zside/server/gen/zside/v1/zsidev1connect"
	walletrpc "github.com/LayerTwo-Labs/sidesail/zside/server/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/zside/server/rpc"
)

func main() {
	app := &cli.App{
		Name:  "zsided",
		Usage: "ZSide sidechain orchestrator daemon",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "datadir",
				Usage:   "data directory",
				Value:   orchestrator.DefaultDataDir(),
				EnvVars: []string{"ZSIDED_DATADIR"},
			},
			&cli.StringFlag{
				Name:    "network",
				Usage:   "bitcoin network (mainnet, testnet, signet, regtest)",
				Value:   "signet",
				EnvVars: []string{"ZSIDED_NETWORK"},
			},
			&cli.StringFlag{
				Name:    "rpclisten",
				Usage:   "gRPC listen address",
				Value:   "localhost:30303",
				EnvVars: []string{"ZSIDED_RPCLISTEN"},
			},
			&cli.StringFlag{
				Name:    "loglevel",
				Usage:   "log level (debug, info, warn, error)",
				Value:   "info",
				EnvVars: []string{"ZSIDED_LOGLEVEL"},
			},
			&cli.StringFlag{
				Name:    "bitwindow-dir",
				Usage:   "path to bitwindow data directory (for wallet.json)",
				Value:   defaultBitwindowDir(),
				EnvVars: []string{"ZSIDED_BITWINDOW_DIR"},
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
		Msg("starting zsided")

	// Only ZSide-relevant binaries: bitcoind, enforcer, and zside itself
	var configs []orchestrator.BinaryConfig
	for _, name := range []string{"bitcoind", "enforcer", "zside"} {
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

			// Restart the dependency chain: Core → Enforcer → ZSide
			log.Info().Msg("restarting binaries for new network")
			startCh, err := orch.StartWithDeps(ctx, "zside", orchestrator.StartOpts{
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
	orch.WalletSvc = walletSvc

	// Wire up wallet callbacks
	walletNetwork := orchconfig.NetworkFromString(network)

	walletSvc.OnWalletGenerated = func() {
		log.Info().Msg("wallet generated, restarting binaries via orchestrator")
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
		startCh, err := orch.StartWithDeps(ctx, "zside", orchestrator.StartOpts{
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
		var allPaths []string
		for _, dirs := range []orchconfig.BinaryDirConfig{
			orchconfig.BitcoinCoreDirs,
			orchconfig.EnforcerDirs,
			orchconfig.BitWindowDirs,
			orchconfig.ZSideDirs,
		} {
			paths := dirs.GetWalletPaths(dirs.RootDirNetwork(walletNetwork), walletNetwork, log)
			allPaths = append(allPaths, paths...)
		}
		return allPaths
	}
	walletSvc.CoreDataDir = orchconfig.BitcoinCoreDirs.RootDirNetwork(walletNetwork)

	orchHandler := orchapi.NewHandler(orch)
	orchWrapper := zsideapi.NewOrchestratorWrapper(orchHandler, walletSvc, log)
	mux := http.NewServeMux()

	orchPath, orchH := orchrpc.NewOrchestratorServiceHandler(orchWrapper, connect.WithInterceptors())
	mux.Handle(orchPath, orchH)

	// Mount BitcoinConfService
	if orch.BitcoinConf != nil {
		btcConfHandler := orchapi.NewBitcoinConfHandler(orch.BitcoinConf)
		btcConfPath, btcConfH := orchrpc.NewBitcoinConfServiceHandler(btcConfHandler)
		mux.Handle(btcConfPath, btcConfH)
	}

	// Mount EnforcerConfService
	if orch.EnforcerConf != nil {
		enforcerConfHandler := orchapi.NewEnforcerConfHandler(orch.EnforcerConf)
		enforcerConfPath, enforcerConfH := orchrpc.NewEnforcerConfServiceHandler(enforcerConfHandler)
		mux.Handle(enforcerConfPath, enforcerConfH)

		if err := orch.EnforcerConf.StartWatching(); err != nil {
			log.Warn().Err(err).Msg("start enforcer config file watching")
		}
	}

	// Mount ZSideConfService
	zsideConfMgr, err := orchconfig.NewZSideConfManager(orch.BitcoinConf, log)
	if err != nil {
		log.Warn().Err(err).Msg("zside conf manager init")
	} else {
		zsideConfHandler := orchapi.NewZSideConfHandler(zsideConfMgr)
		zsideConfPath, zsideConfH := orchrpc.NewZSideConfServiceHandler(zsideConfHandler)
		mux.Handle(zsideConfPath, zsideConfH)

		if err := zsideConfMgr.StartWatching(); err != nil {
			log.Warn().Err(err).Msg("start zside config file watching")
		}
	}

	zsideRPC := rpc.New("127.0.0.1", 6098)
	zsideHandler := zsideapi.NewZSideHandler(zsideRPC)
	zsidePath, zsideH := zsiderpc.NewZSideServiceHandler(zsideHandler)
	mux.Handle(zsidePath, zsideH)

	walletHandler := zsideapi.NewWalletHandler(walletSvc, log)
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

	log.Info().Msg("zsided shutdown complete")
	return nil
}

func defaultBitwindowDir() string {
	return orchconfig.BitWindowDirs.RootDir()
}
