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
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"

	thunderapi "github.com/LayerTwo-Labs/sidesail/thunder/server/api"
	thunderrpc "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/thunder/v1/thunderv1connect"
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
	configs := []orchestrator.BinaryConfig{
		orchestrator.DefaultBitcoinCore(),
		orchestrator.DefaultEnforcer(),
		orchestrator.DefaultThunder(),
	}
	orch := orchestrator.New(dataDir, network, configs, log)

	if err := orch.AdoptOrphans(ctx); err != nil {
		log.Warn().Err(err).Msg("adopt orphans")
	}

	orchHandler := orchapi.NewHandler(orch)
	mux := http.NewServeMux()

	orchPath, orchH := orchrpc.NewOrchestratorServiceHandler(orchHandler, connect.WithInterceptors())
	mux.Handle(orchPath, orchH)

	thunderRPC := rpc.New("127.0.0.1", 6009)
	thunderHandler := thunderapi.NewThunderHandler(thunderRPC)
	thunderPath, thunderH := thunderrpc.NewThunderServiceHandler(thunderHandler)
	mux.Handle(thunderPath, thunderH)

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
