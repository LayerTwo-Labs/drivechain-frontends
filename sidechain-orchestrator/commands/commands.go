package commands

import (
	"fmt"
	"net/http"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/urfave/cli/v2"
)

var GlobalFlags = []cli.Flag{
	&cli.StringFlag{
		Name:    "rpcserver",
		Usage:   "orchestratord RPC address",
		Value:   "localhost:30400",
		EnvVars: []string{"ORCHESTRATOR_RPCSERVER"},
	},
	&cli.StringFlag{
		Name:    "datadir",
		Usage:   "data directory",
		EnvVars: []string{"ORCHESTRATOR_DATADIR"},
	},
	&cli.StringFlag{
		Name:    "network",
		Usage:   "bitcoin network",
		Value:   "signet",
		EnvVars: []string{"ORCHESTRATOR_NETWORK"},
	},
}

// Commands returns all available CLI subcommands.
func Commands() []*cli.Command {
	return []*cli.Command{
		downloadCommand,
		startCommand,
		stopCommand,
		statusCommand,
		logsCommand,
		shutdownCommand,
	}
}

func newClient(cctx *cli.Context) rpc.OrchestratorServiceClient {
	addr := cctx.String("rpcserver")
	url := fmt.Sprintf("http://%s", addr)
	return rpc.NewOrchestratorServiceClient(
		http.DefaultClient,
		url,
		connect.WithGRPC(),
	)
}

var downloadCommand = &cli.Command{
	Name:      "download",
	Usage:     "Download a binary",
	ArgsUsage: "<binary>",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:  "force",
			Usage: "force re-download even if binary exists",
		},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl download <binary>")
		}

		client := newClient(cctx)
		stream, err := client.DownloadBinary(cctx.Context, connect.NewRequest(&pb.DownloadBinaryRequest{
			Name:  cctx.Args().First(),
			Force: cctx.Bool("force"),
		}))
		if err != nil {
			return err
		}

		for stream.Receive() {
			msg := stream.Msg()
			if msg.Error != "" {
				return fmt.Errorf("download error: %s", msg.Error)
			}
			if msg.Message != "" {
				fmt.Println(msg.Message)
			} else if msg.TotalBytes > 0 {
				pct := float64(msg.BytesDownloaded) / float64(msg.TotalBytes) * 100
				fmt.Printf("\r%.1f%% (%d / %d bytes)", pct, msg.BytesDownloaded, msg.TotalBytes)
			}
			if msg.Done {
				fmt.Println("\ndownload complete")
			}
		}

		return stream.Err()
	},
}

var startCommand = &cli.Command{
	Name:      "start",
	Usage:     "Start a binary",
	ArgsUsage: "<binary>",
	Flags: []cli.Flag{
		&cli.StringSliceFlag{
			Name:  "args",
			Usage: "extra arguments to pass to the binary",
		},
		&cli.BoolFlag{
			Name:  "with-deps",
			Usage: "start with full L1 dependency chain",
		},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl start <binary>")
		}

		name := cctx.Args().First()
		client := newClient(cctx)

		if cctx.Bool("with-deps") {
			stream, err := client.StartWithDeps(cctx.Context, connect.NewRequest(&pb.StartWithDepsRequest{
				Target:     name,
				TargetArgs: cctx.StringSlice("args"),
			}))
			if err != nil {
				return err
			}

			for stream.Receive() {
				msg := stream.Msg()
				if msg.Error != "" {
					return fmt.Errorf("startup error: %s", msg.Error)
				}
				fmt.Printf("[%s] %s\n", msg.Stage, msg.Message)
				if msg.Done {
					fmt.Println("startup complete")
				}
			}
			return stream.Err()
		}

		resp, err := client.StartBinary(cctx.Context, connect.NewRequest(&pb.StartBinaryRequest{
			Name:      name,
			ExtraArgs: cctx.StringSlice("args"),
		}))
		if err != nil {
			return err
		}

		fmt.Printf("started %s (PID %d)\n", name, resp.Msg.Pid)
		return nil
	},
}

var stopCommand = &cli.Command{
	Name:      "stop",
	Usage:     "Stop a binary",
	ArgsUsage: "<binary>",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:  "force",
			Usage: "force kill (SIGKILL) instead of graceful shutdown",
		},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl stop <binary>")
		}

		client := newClient(cctx)
		_, err := client.StopBinary(cctx.Context, connect.NewRequest(&pb.StopBinaryRequest{
			Name:  cctx.Args().First(),
			Force: cctx.Bool("force"),
		}))
		if err != nil {
			return err
		}

		fmt.Printf("stopped %s\n", cctx.Args().First())
		return nil
	},
}

var statusCommand = &cli.Command{
	Name:      "status",
	Usage:     "Show status of binaries",
	ArgsUsage: "[binary]",
	Action: func(cctx *cli.Context) error {
		client := newClient(cctx)

		if cctx.NArg() > 0 {
			resp, err := client.GetBinaryStatus(cctx.Context, connect.NewRequest(&pb.GetBinaryStatusRequest{
				Name: cctx.Args().First(),
			}))
			if err != nil {
				return err
			}
			printStatus(resp.Msg.Status)
			return nil
		}

		resp, err := client.ListBinaries(cctx.Context, connect.NewRequest(&pb.ListBinariesRequest{}))
		if err != nil {
			return err
		}

		for _, s := range resp.Msg.Binaries {
			printStatus(s)
		}
		return nil
	},
}

func printStatus(s *pb.BinaryStatusMsg) {
	status := "stopped"
	if s.Running {
		uptime := time.Duration(s.UptimeSeconds) * time.Second
		status = fmt.Sprintf("running (PID %d, up %s)", s.Pid, uptime.Truncate(time.Second))
	}
	if s.Error != "" {
		status = fmt.Sprintf("error: %s", s.Error)
	}

	name := s.DisplayName
	if name == "" {
		name = s.Name
	}
	fmt.Printf("%-25s %s\n", name, status)
}

var logsCommand = &cli.Command{
	Name:      "logs",
	Usage:     "Stream logs from a binary",
	ArgsUsage: "<binary>",
	Flags: []cli.Flag{
		&cli.IntFlag{
			Name:  "tail",
			Usage: "number of recent lines to show",
			Value: 50,
		},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl logs <binary>")
		}

		client := newClient(cctx)
		stream, err := client.StreamLogs(cctx.Context, connect.NewRequest(&pb.StreamLogsRequest{
			Name: cctx.Args().First(),
			Tail: int32(cctx.Int("tail")),
		}))
		if err != nil {
			return err
		}

		for stream.Receive() {
			msg := stream.Msg()
			ts := time.Unix(msg.TimestampUnix, 0).Format("15:04:05")
			fmt.Printf("[%s] [%s] %s\n", ts, msg.Stream, msg.Line)
		}

		return stream.Err()
	},
}

var shutdownCommand = &cli.Command{
	Name:  "shutdown",
	Usage: "Stop all running binaries",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:  "force",
			Usage: "force kill all binaries",
		},
	},
	Action: func(cctx *cli.Context) error {
		client := newClient(cctx)
		stream, err := client.ShutdownAll(cctx.Context, connect.NewRequest(&pb.ShutdownAllRequest{
			Force: cctx.Bool("force"),
		}))
		if err != nil {
			return err
		}

		for stream.Receive() {
			msg := stream.Msg()
			if msg.Error != "" {
				fmt.Printf("error: %s\n", msg.Error)
			}
			if msg.CurrentBinary != "" {
				fmt.Printf("stopping %s (%d/%d)...\n", msg.CurrentBinary, msg.CompletedCount+1, msg.TotalCount)
			}
			if msg.Done {
				fmt.Println("shutdown complete")
			}
		}

		return stream.Err()
	},
}
