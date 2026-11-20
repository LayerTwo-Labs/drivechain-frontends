package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/signal"
	"syscall"

	"github.com/rs/zerolog"
	"github.com/urfave/cli/v2"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/daemon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/instance"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
)

// version is the release this binary comes from. The release build sets it with
// -ldflags "-X main.version=...".
var version = "dev"

func main() {
	if _, err := instance.PortOffset(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
	app := &cli.App{
		Name:    "drivechaind",
		Usage:   "Sidechain orchestrator daemon",
		Version: version,
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "datadir",
				Usage:   "data directory",
				Value:   orchestrator.DefaultDataDir(),
				EnvVars: []string{"ORCHESTRATOR_DATADIR"},
			},
			&cli.StringFlag{
				Name:    "network",
				Usage:   "bitcoin network (mainnet, testnet, signet, regtest, ecash)",
				Value:   config.DefaultNetwork,
				EnvVars: []string{"ORCHESTRATOR_NETWORK"},
			},
			&cli.StringFlag{
				Name:    "rpclisten",
				Usage:   "gRPC listen address",
				Value:   instance.Addr("localhost", 30400),
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
			&cli.StringFlag{
				Name:    "app-home",
				Usage:   "home directory every binary's data directory resolves against (default: the user's home)",
				EnvVars: []string{"ORCHESTRATOR_APP_HOME"},
			},
			&cli.BoolFlag{
				Name:    "local-auth",
				Usage:   "write a per-session cookie token to <bitwindow-dir>/.auth.cookie and require it on every RPC (bitcoind-style local auth)",
				Value:   true,
				EnvVars: []string{"ORCHESTRATOR_LOCAL_AUTH"},
			},
			&cli.StringFlag{
				Name:    "thunder-esplora-url",
				Usage:   "optional Thunder Esplora URL for wallet history; defaults to the local daemon",
				EnvVars: []string{"ORCHESTRATOR_THUNDER_ESPLORA_URL"},
			},
			&cli.StringFlag{
				Name:    "regtest-esplora-url",
				Usage:   "Esplora URL of a self-hosted regtest chain, for light mode on regtest",
				EnvVars: []string{"ORCHESTRATOR_REGTEST_ESPLORA_URL"},
			},
			&cli.StringFlag{
				Name:    "regtest-enforcer-url",
				Usage:   "gRPC URL of a self-hosted regtest enforcer, for light mode on regtest",
				EnvVars: []string{"ORCHESTRATOR_REGTEST_ENFORCER_URL"},
			},
			&cli.StringSliceFlag{
				Name:    "binary",
				Usage:   "sidechain binary to start with deps on boot (can be repeated, e.g. --binary=thunder --binary=bitnames)",
				EnvVars: []string{"ORCHESTRATOR_BINARY"},
			},
			&cli.BoolFlag{
				Name:    "force-backend",
				Usage:   "launch the prod download for the --binary auto-boots instead of the frontend build",
				EnvVars: []string{"ORCHESTRATOR_FORCE_BACKEND"},
			},
			&cli.StringFlag{
				Name:    "logfile",
				Usage:   "append logs to this file instead of stdout (used when bitwindowd spawns us detached and our stdout has no reader)",
				EnvVars: []string{"ORCHESTRATOR_LOGFILE"},
			},
			&cli.IntFlag{
				Name:    "owner-pid",
				Usage:   "shut down once this process exits (the frontend that owns us)",
				EnvVars: []string{"ORCHESTRATOR_OWNER_PID"},
			},
			&cli.StringFlag{
				Name:    "pprof-addr",
				Usage:   "loopback host:port for the pprof debug server; empty disables it",
				EnvVars: []string{"ORCHESTRATOR_PPROF_ADDR"},
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
	// Millisecond timestamps: startup is a sequence of sub-second steps, and
	// the default minute granularity makes it impossible to see which one is slow.
	var logOut io.Writer = zerolog.ConsoleWriter{Out: os.Stdout, TimeFormat: "15:04:05.000"}
	if logPath := cctx.String("logfile"); logPath != "" {
		// O_APPEND so multiple processes (e.g. an old instance still draining
		// and a new instance probing the port) don't truncate each other.
		f, err := os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
		if err != nil {
			fmt.Fprintf(os.Stderr, "open --logfile %q: %v\n", logPath, err)
			os.Exit(1)
		}
		defer f.Close() //nolint:errcheck
		logOut = zerolog.ConsoleWriter{Out: logfile.Tag(f, "orchestrator"), NoColor: true, TimeFormat: "15:04:05.000"}
	}
	log := zerolog.New(logOut).
		Level(level).
		With().
		Timestamp().
		Logger()

	return daemon.Run(ctx, daemon.Config{
		DataDir:           cctx.String("datadir"),
		Network:           cctx.String("network"),
		ListenAddr:        cctx.String("rpclisten"),
		BitwindowDir:      cctx.String("bitwindow-dir"),
		AppHome:           cctx.String("app-home"),
		LocalAuth:         cctx.Bool("local-auth"),
		ThunderEsploraURL: cctx.String("thunder-esplora-url"),
		Regtest: config.RegtestEndpoints{
			EsploraURL:  cctx.String("regtest-esplora-url"),
			EnforcerURL: cctx.String("regtest-enforcer-url"),
		},
		Binaries:     cctx.StringSlice("binary"),
		ForceBackend: cctx.Bool("force-backend"),
		OwnerPID:     cctx.Int("owner-pid"),
		PprofAddr:    cctx.String("pprof-addr"),
		Log:          log,
		Exit:         os.Exit,
	})
}
