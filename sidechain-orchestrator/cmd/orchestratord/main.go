package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/urfave/cli/v2"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	bitassetsrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1/bitassetsv1connect"
	bitnamesrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1/bitnamesv1connect"
	coinshiftrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1/coinshiftv1connect"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	photonrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/photon/v1/photonv1connect"
	thunderrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	truthcoinrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1/truthcoinv1connect"
	walletrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	zsiderpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1/zsidev1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	bitassetssvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	bitnamessvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	coinshiftsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	photonsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	thundersvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	truthcoinsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	zsidesvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
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
			&cli.StringSliceFlag{
				Name:    "binary",
				Usage:   "sidechain binary to start with deps on boot (can be repeated, e.g. --binary=thunder --binary=bitnames)",
				EnvVars: []string{"ORCHESTRATOR_BINARY"},
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

	// Initialize wallet service
	walletSvc := wallet.NewService(bitwindowDir, log)
	walletSvc.OnStopAllBinaries = func() error {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		ch, err := orch.ShutdownAll(shutdownCtx, false)
		if err != nil {
			return err
		}

		for progress := range ch {
			if progress.Error != nil {
				return progress.Error
			}
		}

		return nil
	}
	walletSvc.GetBinaryWalletPaths = func() []string {
		paths := []string{}
		network := config.Network(network)
		for _, cfg := range orch.Configs() {
			dirConfig, ok := config.DirConfigByName(cfg.Name)
			if !ok {
				continue
			}
			paths = append(paths, dirConfig.GetWalletPaths(dirConfig.RootDirNetwork(network), network, log)...)
		}
		return paths
	}
	if orch.BitcoinConf != nil {
		walletSvc.CoreDataDir = config.BitcoinCoreDirs.RootDirNetwork(orch.BitcoinConf.Network)
	}
	if err := walletSvc.Init(); err != nil {
		log.Warn().Err(err).Msg("wallet service init")
	}
	defer walletSvc.Close()
	orch.WalletSvc = walletSvc

	// Adopt orphaned processes from previous session
	if err := orch.AdoptOrphans(ctx); err != nil {
		log.Warn().Err(err).Msg("adopt orphans")
	}

	// Set up gRPC/ConnectRPC server
	handler := api.NewHandler(orch)
	mux := http.NewServeMux()

	path, h := rpc.NewOrchestratorServiceHandler(handler, connect.WithInterceptors())
	mux.Handle(path, h)

	// Wallet manager service
	walletHandler := api.NewWalletHandler(walletSvc)
	walletHandler.SetOrchestrator(orch)
	walletHandler.SetBip47StateStore(bip47state.NewStore(bitwindowDir))

	// Set up wallet engine for Core RPC operations if bitcoin config is available
	if orch.BitcoinConf != nil {
		port := orch.BitcoinConf.GetRPCPort()
		var user, password string
		if orch.BitcoinConf.Config != nil {
			section := orch.BitcoinConf.Network.CoreSection()
			user = orch.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
			password = orch.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
		}

		coreRPC := wallet.NewCoreRPCClient("localhost", port, user, password)
		walletEngine := wallet.NewWalletEngine(walletSvc, coreRPC, network, log)
		walletHandler.SetEngine(walletEngine)

		log.Info().Int("rpc_port", port).Msg("wallet engine initialized with Core RPC")
	}

	// Lazy enforcer wallet client — used for enforcer-type wallets.
	if enforcerCfg, ok := orch.Configs()["enforcer"]; ok {
		enforcerURL := fmt.Sprintf("http://127.0.0.1:%d", enforcerCfg.Port)
		httpClient := &http.Client{
			Transport: &http2.Transport{
				AllowHTTP: true,
				DialTLSContext: func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
					var d net.Dialer
					return d.DialContext(ctx, network, addr)
				},
			},
		}
		enforcerClient := enforcerrpc.NewWalletServiceClient(httpClient, enforcerURL, connect.WithGRPC())
		walletHandler.SetEnforcerWallet(enforcerClient)
		log.Info().Int("enforcer_port", enforcerCfg.Port).Msg("enforcer wallet client registered")
	}

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

	// Generic sidechain config service (all sidechains)
	sidechainConfHandler := api.NewSidechainConfHandler(orch.SidechainConfs)
	scConfPath, scConfH := rpc.NewSidechainConfServiceHandler(sidechainConfHandler, connect.WithInterceptors())
	mux.Handle(scConfPath, scConfH)

	// Per-sidechain typed RPC services (proxy to sidechain binary JSON-RPC)
	for name, cfg := range orch.Configs() {
		proxy := sidechain.NewJSONRPCProxy("127.0.0.1", cfg.Port)
		switch name {
		case "thunder":
			h := thundersvc.NewHandler(proxy)
			path, handler := thunderrpc.NewThunderServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "bitnames":
			h := bitnamessvc.NewHandler(proxy)
			path, handler := bitnamesrpc.NewBitnamesServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "bitassets":
			h := bitassetssvc.NewHandler(proxy)
			path, handler := bitassetsrpc.NewBitAssetsServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "photon":
			h := photonsvc.NewHandler(proxy)
			path, handler := photonrpc.NewPhotonServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "truthcoin":
			h := truthcoinsvc.NewHandler(proxy)
			path, handler := truthcoinrpc.NewTruthcoinServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "coinshift":
			h := coinshiftsvc.NewHandler(proxy)
			path, handler := coinshiftrpc.NewCoinShiftServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "zside":
			h := zsidesvc.NewHandler(proxy)
			path, handler := zsiderpc.NewZSideServiceHandler(h, connect.WithInterceptors())
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		}
	}

	srv := &http.Server{
		Handler: h2c.NewHandler(mux, &http2.Server{
			ReadIdleTimeout: 30 * time.Second,
		}),
	}

	// Bind listener first so we know the port is ours before logging.
	lis, err := net.Listen("tcp", listenAddr)
	if err != nil {
		return fmt.Errorf("listen %s: %w", listenAddr, err)
	}
	log.Info().Str("addr", lis.Addr().String()).Msg("serving gRPC")

	errs := make(chan error, 1)
	go func() {
		if err := srv.Serve(lis); err != nil && err != http.ErrServerClosed {
			errs <- fmt.Errorf("serve: %w", err)
		}
	}()

	// Auto-boot sidechains specified via --binary flags
	binariesToBoot := cctx.StringSlice("binary")
	for _, name := range binariesToBoot {
		go func(target string) {
			log.Info().Str("binary", target).Msg("auto-booting sidechain with deps")
			ch, err := orch.StartWithL1(ctx, target, orchestrator.StartOpts{
				TargetArgs: []string{"--headless"},
			})
			if err != nil {
				log.Error().Err(err).Str("binary", target).Msg("failed to start sidechain")
				return
			}
			for p := range ch {
				if p.Done {
					log.Info().Str("binary", target).Msg("sidechain startup complete")
					break
				}
				if p.Error != nil {
					log.Error().Err(p.Error).Str("binary", target).Msg("sidechain startup error")
					break
				}
			}
		}(name)
	}

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
