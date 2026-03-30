package commands

import (
	"bufio"
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
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
			client := newClient(cctx)
			resp, err := client.ListBinaries(cctx.Context, connect.NewRequest(&pb.ListBinariesRequest{}))
			if err != nil {
				return fmt.Errorf("usage: orchestratorctl download <binary>\n  (could not fetch binary list: %w)", err)
			}
			fmt.Println("usage: orchestratorctl download <binary>")
			fmt.Println()
			fmt.Println("available binaries:")
			for _, b := range resp.Msg.Binaries {
				if !b.Downloadable {
					continue
				}
				desc := b.Description
				if desc == "" {
					desc = b.DisplayName
				}
				fmt.Printf("  %-20s %s\n", b.Name, desc)
			}
			return nil
		}

		client := newClient(cctx)
		return runDownload(cctx.Context, client, cctx.Args().First(), cctx.Bool("force"))
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
			Name:  "without-deps",
			Usage: "skip starting L1 dependency chain",
		},
		&cli.BoolFlag{
			Name:    "daemon",
			Aliases: []string{"d"},
			Usage:   "start in background without streaming logs",
		},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return printUsageWithBinaries(cctx, "start")
		}

		name := cctx.Args().First()
		client := newClient(cctx)

		withDeps := !cctx.Bool("without-deps")

		// Check which binaries need downloading.
		var needed []string
		if withDeps {
			needed = []string{"bitcoind", "enforcer", name}
		} else {
			needed = []string{name}
		}

		for _, bin := range needed {
			resp, err := client.GetBinaryStatus(cctx.Context, connect.NewRequest(&pb.GetBinaryStatusRequest{
				Name: bin,
			}))
			if err != nil {
				return err
			}
			s := resp.Msg.Status
			if s.Downloaded || !s.Downloadable {
				continue
			}

			displayName := s.DisplayName
			if displayName == "" {
				displayName = s.Name
			}
			fmt.Printf("%s is not downloaded. download now? [Y/n] ", displayName)

			if !confirmYes() {
				return fmt.Errorf("cannot start %s without %s", name, bin)
			}
			if err := runDownload(cctx.Context, client, bin, false); err != nil {
				return err
			}
			fmt.Println()
		}

		if withDeps {
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
			if err := stream.Err(); err != nil {
				return err
			}
		} else {
			resp, err := client.StartBinary(cctx.Context, connect.NewRequest(&pb.StartBinaryRequest{
				Name:      name,
				ExtraArgs: cctx.StringSlice("args"),
			}))
			if err != nil {
				return err
			}
			fmt.Printf("started %s (PID %d)\n", name, resp.Msg.Pid)
		}

		if cctx.Bool("daemon") {
			return nil
		}

		// Stream logs until ctrl+c, then stop everything we started.
		fmt.Printf("\nstreaming %s logs (ctrl+c to stop)...\n\n", name)

		ctx, cancel := context.WithCancel(cctx.Context)
		defer cancel()

		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
		go func() {
			<-sigCh
			cancel()
		}()

		logStream, err := client.StreamLogs(ctx, connect.NewRequest(&pb.StreamLogsRequest{
			Name: name,
			Tail: 10,
		}))
		if err != nil {
			return err
		}
		for logStream.Receive() {
			msg := logStream.Msg()
			ts := time.Unix(msg.TimestampUnix, 0).Format("15:04:05")
			fmt.Printf("[%s] %s\n", ts, msg.Line)
		}

		// Stop the binaries we started.
		fmt.Println("\nstopping...")
		stopCtx, stopCancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer stopCancel()

		if withDeps {
			shutdownStream, err := client.ShutdownAll(stopCtx, connect.NewRequest(&pb.ShutdownAllRequest{}))
			if err != nil {
				return fmt.Errorf("shutdown: %w", err)
			}
			for shutdownStream.Receive() {
				msg := shutdownStream.Msg()
				if msg.CurrentBinary != "" {
					fmt.Printf("  stopping %s...\n", msg.CurrentBinary)
				}
				if msg.Done {
					fmt.Println("stopped")
				}
			}
			return shutdownStream.Err()
		}

		_, err = client.StopBinary(stopCtx, connect.NewRequest(&pb.StopBinaryRequest{
			Name: name,
		}))
		if err != nil {
			return fmt.Errorf("stop %s: %w", name, err)
		}
		fmt.Printf("stopped %s\n", name)
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
			return printUsageWithBinaries(cctx, "stop")
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
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:    "stream",
			Aliases: []string{"s"},
			Usage:   "stream live status updates",
		},
	},
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

		if cctx.Bool("stream") {
			stream, err := client.WatchBinaries(cctx.Context, connect.NewRequest(&pb.WatchBinariesRequest{}))
			if err != nil {
				return err
			}
			for stream.Receive() {
				fmt.Print("\033[2J\033[H") // clear screen
				for _, s := range stream.Msg().Binaries {
					printStatus(s)
				}
			}
			return stream.Err()
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

func formatBytes(b int64) string {
	const (
		kb = 1024
		mb = kb * 1024
		gb = mb * 1024
	)
	switch {
	case b >= gb:
		return fmt.Sprintf("%.1f GB", float64(b)/float64(gb))
	case b >= mb:
		return fmt.Sprintf("%.1f MB", float64(b)/float64(mb))
	case b >= kb:
		return fmt.Sprintf("%.1f KB", float64(b)/float64(kb))
	default:
		return fmt.Sprintf("%d B", b)
	}
}

// runDownload streams a binary download with a progress bar.
func runDownload(ctx context.Context, client rpc.OrchestratorServiceClient, name string, force bool) error {
	stream, err := client.DownloadBinary(ctx, connect.NewRequest(&pb.DownloadBinaryRequest{
		Name:  name,
		Force: force,
	}))
	if err != nil {
		return err
	}

	showedBar := false
	for stream.Receive() {
		msg := stream.Msg()
		if msg.Error != "" {
			if showedBar {
				fmt.Println()
			}
			return fmt.Errorf("download error: %s", msg.Error)
		}
		if msg.Message != "" && !msg.Done {
			if showedBar {
				fmt.Println()
				showedBar = false
			}
			fmt.Println(msg.Message)
		} else if msg.TotalBytes > 0 {
			pct := float64(msg.BytesDownloaded) / float64(msg.TotalBytes) * 100
			barWidth := 30
			filled := int(pct / 100 * float64(barWidth))
			bar := strings.Repeat("█", filled) + strings.Repeat("░", barWidth-filled)
			fmt.Printf("\r  %s %5.1f%%  %s / %s",
				bar, pct,
				formatBytes(msg.BytesDownloaded),
				formatBytes(msg.TotalBytes),
			)
			showedBar = true
		}
		if msg.Done {
			if showedBar {
				fmt.Println()
			}
			binPath := msg.Message

			if showedBar {
				fmt.Printf("downloaded to %s\n", binPath)
			} else {
				fmt.Printf("already downloaded at %s\n", binPath)
			}

			// Hint about PATH if the binary's directory isn't in PATH.
			binDir := filepath.Dir(binPath)
			pathDirs := filepath.SplitList(os.Getenv("PATH"))
			inPath := false
			for _, d := range pathDirs {
				if d == binDir {
					inPath = true
					break
				}
			}
			if !inPath {
				shell := filepath.Base(os.Getenv("SHELL"))
				switch shell {
				case "fish":
					fmt.Printf("\nthe binary folder is not in your PATH. add it with:\n  fish_add_path %s\n", binDir)
				case "zsh":
					fmt.Printf("\nthe binary folder is not in your PATH. add it with:\n  echo 'export PATH=\"%s:$PATH\"' >> ~/.zshrc && source ~/.zshrc\n", binDir)
				default:
					fmt.Printf("\nthe binary folder is not in your PATH. add it with:\n  echo 'export PATH=\"%s:$PATH\"' >> ~/.bashrc && source ~/.bashrc\n", binDir)
				}
			} else {
				fmt.Printf("\ninstalled. start with:\n  orchestratorctl start %s\n", name)
			}
		}
	}

	return stream.Err()
}

// confirmYes reads a line from stdin and returns true for "y", "Y", or empty (default yes).
func confirmYes() bool {
	scanner := bufio.NewScanner(os.Stdin)
	if !scanner.Scan() {
		return false
	}
	answer := strings.TrimSpace(scanner.Text())
	return answer == "" || strings.EqualFold(answer, "y") || strings.EqualFold(answer, "yes")
}

// printUsageWithBinaries prints a usage line and lists available binaries.
func printUsageWithBinaries(cctx *cli.Context, command string) error {
	client := newClient(cctx)
	resp, err := client.ListBinaries(cctx.Context, connect.NewRequest(&pb.ListBinariesRequest{}))
	if err != nil {
		return fmt.Errorf("usage: orchestratorctl %s <binary>", command)
	}
	fmt.Printf("usage: orchestratorctl %s <binary>\n\navailable binaries:\n", command)
	for _, b := range resp.Msg.Binaries {
		fmt.Printf("  %s\n", b.Name)
	}
	return nil
}

func printStatus(s *pb.BinaryStatusMsg) {
	status := "stopped"
	if s.Running {
		uptime := time.Duration(s.UptimeSeconds) * time.Second
		status = fmt.Sprintf("running (PID %d, up %s)", s.Pid, uptime.Truncate(time.Second))
	} else if s.PortInUse && s.Port > 0 {
		status = fmt.Sprintf("stopped (port %d in use)", s.Port)
	}
	if s.Error != "" {
		status = fmt.Sprintf("error: %s", s.Error)
	}

	fmt.Printf("  %-20s %s\n", s.Name, status)
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
			return printUsageWithBinaries(cctx, "logs")
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
