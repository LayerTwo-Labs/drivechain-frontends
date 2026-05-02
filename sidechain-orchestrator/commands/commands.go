package commands

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"regexp"
	"reflect"
	"strings"
	"syscall"
	"time"
	"unicode"

	"connectrpc.com/connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
	"github.com/rs/zerolog"
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
	&cli.BoolFlag{
		Name:    "auto-download",
		Usage:   "automatically download binaries when needed (for CI)",
		EnvVars: []string{"ORCHESTRATOR_AUTO_DOWNLOAD"},
	},
}

// Commands returns all available CLI subcommands.
func Commands() []*cli.Command {
	cmds := []*cli.Command{
		downloadCommand,
		wipeCommand,
		startCommand,
		stopCommand,
		statusCommand,
		logsCommand,
		shutdownCommand,
		infoCommand,
		balanceCommand,
		priceCommand,
		doctorCommand,
		versionCommand,
		updateCommand,
		whichCommand,
		walletCommand,
		testSidechainsCommand,
		resetCommand,
	}

	// Add sidechain proxy commands
	cmds = append(cmds, createSidechainCommands()...)

	return cmds
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

		autoDownload := cctx.Bool("auto-download") || os.Getenv("ORCHESTRATOR_AUTO_DOWNLOAD") != ""
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

			if autoDownload {
				fmt.Printf("%s is not downloaded. Downloading now...\n", displayName)
			} else {
				fmt.Printf("%s is not downloaded. download now? [Y/n] ", displayName)
				if !confirmYes() {
					return fmt.Errorf("cannot start %s without %s", name, bin)
				}
			}

			if err := runDownload(cctx.Context, client, bin, false); err != nil {
				return err
			}
			fmt.Println()
		}

		if withDeps {
			stream, err := client.StartWithL1(cctx.Context, connect.NewRequest(&pb.StartWithL1Request{
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

var wipeCommand = &cli.Command{
	Name:      "wipe",
	Usage:     "Stop a binary and delete its data",
	ArgsUsage: "<binary>",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:  "include-wallets",
			Usage: "also delete wallet files",
		},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return printUsageWithBinaries(cctx, "wipe")
		}

		name := cctx.Args().First()
		network := config.Network(cctx.String("network"))

		dirConfig, ok := config.DirConfigByName(name)
		if !ok {
			return fmt.Errorf("unknown binary: %s", name)
		}

		// Stop the binary if possible.
		client := newClient(cctx)
		_, _ = client.StopBinary(cctx.Context, connect.NewRequest(&pb.StopBinaryRequest{Name: name, Force: true}))

		// Delete the downloaded binary.
		dataDir := cctx.String("datadir")
		if dataDir == "" {
			dataDir = orchestrator.DefaultDataDir()
		}
		binPath := binaryPathFor(dataDir, name)
		if err := os.Remove(binPath); err == nil {
			fmt.Printf("removed %s\n", binPath)
		}

		// Delete blockchain data, logs, settings.
		log := zerolog.Nop()
		networkDir := dirConfig.RootDirNetwork(network)
		for _, p := range dirConfig.GetBlockchainDataPaths(networkDir, network, log) {
			if err := os.RemoveAll(p); err == nil {
				fmt.Printf("removed %s\n", p)
			}
		}
		for _, p := range dirConfig.GetSettingsPaths(networkDir, network, log) {
			if err := os.RemoveAll(p); err == nil {
				fmt.Printf("removed %s\n", p)
			}
		}

		if cctx.Bool("include-wallets") {
			for _, p := range dirConfig.GetWalletPaths(networkDir, network, log) {
				if err := os.RemoveAll(p); err == nil {
					fmt.Printf("removed %s\n", p)
				}
			}
		}

		fmt.Printf("\nwiped %s\n", name)
		return nil
	},
}

var infoCommand = &cli.Command{
	Name:  "info",
	Usage: "Show blockchain info",
	Action: func(cctx *cli.Context) error {
		client := newClient(cctx)

		mainchain, err := client.GetMainchainBlockchainInfo(cctx.Context, connect.NewRequest(&pb.GetMainchainBlockchainInfoRequest{}))
		if err != nil {
			fmt.Printf("mainchain: unavailable (%v)\n", err)
		} else {
			m := mainchain.Msg
			fmt.Println("mainchain:")
			fmt.Printf("  chain:    %s\n", m.Chain)
			fmt.Printf("  blocks:   %d\n", m.Blocks)
			fmt.Printf("  headers:  %d\n", m.Headers)
			fmt.Printf("  progress: %.4f%%\n", m.VerificationProgress*100)
			fmt.Printf("  ibd:      %v\n", m.InitialBlockDownload)
			fmt.Printf("  size:     %s\n", formatBytes(m.SizeOnDisk))
		}

		enforcer, err := client.GetEnforcerBlockchainInfo(cctx.Context, connect.NewRequest(&pb.GetEnforcerBlockchainInfoRequest{}))
		if err != nil {
			fmt.Printf("\nenforcer: unavailable (%v)\n", err)
		} else {
			e := enforcer.Msg
			fmt.Println("\nenforcer:")
			fmt.Printf("  blocks:   %d\n", e.Blocks)
			fmt.Printf("  headers:  %d\n", e.Headers)
		}

		return nil
	},
}

var balanceCommand = &cli.Command{
	Name:  "balance",
	Usage: "Show mainchain wallet balance",
	Action: func(cctx *cli.Context) error {
		client := newClient(cctx)
		resp, err := client.GetMainchainBalance(cctx.Context, connect.NewRequest(&pb.GetMainchainBalanceRequest{}))
		if err != nil {
			return err
		}
		fmt.Printf("confirmed:   %.8f BTC\n", resp.Msg.Confirmed)
		fmt.Printf("unconfirmed: %.8f BTC\n", resp.Msg.Unconfirmed)
		return nil
	},
}

var priceCommand = &cli.Command{
	Name:  "price",
	Usage: "Show current BTC/USD price",
	Action: func(cctx *cli.Context) error {
		client := newClient(cctx)
		resp, err := client.GetBTCPrice(cctx.Context, connect.NewRequest(&pb.GetBTCPriceRequest{}))
		if err != nil {
			return err
		}
		t := time.Unix(resp.Msg.LastUpdatedUnix, 0)
		fmt.Printf("$%.2f (updated %s)\n", resp.Msg.Btcusd, t.Format("15:04:05"))
		return nil
	},
}

var doctorCommand = &cli.Command{
	Name:  "doctor",
	Usage: "Check system health and suggest next steps",
	Action: func(cctx *cli.Context) error {
		client := newClient(cctx)
		resp, err := client.ListBinaries(cctx.Context, connect.NewRequest(&pb.ListBinariesRequest{}))
		if err != nil {
			return fmt.Errorf("cannot reach orchestrator daemon: %w", err)
		}

		var notDownloaded []string
		var notRunning []string
		allGood := true

		for _, b := range resp.Msg.Binaries {
			if !b.Downloadable {
				continue
			}

			name := b.Name
			var parts []string

			if b.Downloaded {
				parts = append(parts, "downloaded")
			} else {
				parts = append(parts, "not downloaded")
				notDownloaded = append(notDownloaded, name)
				allGood = false
			}

			if b.Running {
				parts = append(parts, fmt.Sprintf("running (PID %d)", b.Pid))
			} else if b.PortInUse && b.Port > 0 {
				parts = append(parts, fmt.Sprintf("not running (port %d in use)", b.Port))
				allGood = false
			} else {
				parts = append(parts, "not running")
				if b.Downloaded {
					notRunning = append(notRunning, name)
				}
			}

			check := "+"
			if !b.Downloaded || !b.Running {
				check = "-"
			}
			fmt.Printf("  %s %-20s %s\n", check, name, strings.Join(parts, ", "))
		}

		if allGood && len(notRunning) == 0 {
			fmt.Println("\nall good!")
			return nil
		}

		fmt.Println("\nget started:")
		for _, name := range notDownloaded {
			fmt.Printf("  orchestratorctl download %s\n", name)
		}
		for _, name := range notRunning {
			fmt.Printf("  orchestratorctl start %s\n", name)
		}

		return nil
	},
}

var versionCommand = &cli.Command{
	Name:  "version",
	Usage: "Show version info for all binaries",
	Action: func(cctx *cli.Context) error {
		dataDir := cctx.String("datadir")
		if dataDir == "" {
			dataDir = orchestrator.DefaultDataDir()
		}

		client := newClient(cctx)
		resp, err := client.ListBinaries(cctx.Context, connect.NewRequest(&pb.ListBinariesRequest{}))
		if err != nil {
			return fmt.Errorf("cannot reach orchestrator daemon: %w", err)
		}

		for _, b := range resp.Msg.Binaries {
			if !b.Downloadable {
				continue
			}

			ver := "not downloaded"
			if b.Downloaded {
				ver = binaryVersion(binaryPathFor(dataDir, b.Name))
			}

			fmt.Printf("  %-20s %-25s %s\n", b.Name, ver, b.RepoUrl)
		}

		return nil
	},
}

// binaryVersion runs a binary with --version and extracts the version string.
// Ported from Dart: Binary.binaryVersion (binaries.dart L1751-1814)
func binaryVersion(binPath string) string {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, binPath, "--version")
	out, err := cmd.Output()
	if err != nil {
		return "unknown"
	}

	output := strings.TrimSpace(string(out))
	if output == "" {
		return "unknown"
	}

	lines := strings.Split(output, "\n")

	// Enforcer: look for bip300301_enforcer_lib line + commit
	if strings.Contains(binPath, "enforcer") || strings.Contains(binPath, "bip300301") {
		var versionLine, commitLine string
		for _, line := range lines {
			if strings.Contains(line, "bip300301_enforcer_lib") {
				versionLine = line
			}
			if strings.Contains(strings.TrimSpace(line), "commit:") {
				commitLine = line
			}
		}
		if versionLine != "" {
			ver := extractVersion(versionLine)
			commit := extractCommit(commitLine)
			if ver != "" && commit != "" {
				return ver + " (" + commit + ")"
			}
			if ver != "" {
				return ver
			}
			return versionLine
		}
	}

	// Generic: extract semver from output
	if ver := extractVersion(output); ver != "" {
		return ver
	}

	return lines[0]
}

var updateCommand = &cli.Command{
	Name:      "update",
	Usage:     "Re-download the latest version of a binary",
	ArgsUsage: "<binary>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return printUsageWithBinaries(cctx, "update")
		}

		name := cctx.Args().First()
		client := newClient(cctx)

		// Stop if running.
		status, err := client.GetBinaryStatus(cctx.Context, connect.NewRequest(&pb.GetBinaryStatusRequest{Name: name}))
		if err != nil {
			return err
		}
		if status.Msg.Status.Running {
			fmt.Printf("stopping %s...\n", name)
			if _, err := client.StopBinary(cctx.Context, connect.NewRequest(&pb.StopBinaryRequest{Name: name})); err != nil {
				return fmt.Errorf("stop %s: %w", name, err)
			}
		}

		return runDownload(cctx.Context, client, name, true)
	},
}

var whichCommand = &cli.Command{
	Name:      "which",
	Usage:     "Print the path to a binary",
	ArgsUsage: "<binary>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return printUsageWithBinaries(cctx, "which")
		}

		dataDir := cctx.String("datadir")
		if dataDir == "" {
			dataDir = orchestrator.DefaultDataDir()
		}

		name := cctx.Args().First()
		binPath := binaryPathFor(dataDir, name)

		if _, err := os.Stat(binPath); err != nil {
			fmt.Printf("%s (not downloaded)\n", binPath)
		} else {
			fmt.Println(binPath)
		}
		return nil
	},
}

// binaryPathFor returns the on-disk path the orchestrator currently uses for
// a binary. For bitcoind it consults orchestrator_settings.json so it picks
// up whichever Core variant is active; for everything else it falls back to
// the legacy flat layout.
func binaryPathFor(dataDir, name string) string {
	if name != "bitcoind" {
		return orchestrator.BinaryPath(dataDir, name)
	}
	return orchestrator.ActiveCoreBinaryPath(
		dataDir,
		orchestrator.DefaultBitwindowDir(),
		orchestrator.AllDefaults(),
		name,
	)
}

func extractVersion(s string) string {
	re := regexp.MustCompile(`v?(\d+\.\d+\.\d+)`)
	m := re.FindStringSubmatch(s)
	if len(m) > 1 {
		return m[1]
	}
	return ""
}

func extractCommit(s string) string {
	re := regexp.MustCompile(`commit:\s*([a-f0-9]+)`)
	m := re.FindStringSubmatch(s)
	if len(m) > 1 {
		return m[1]
	}
	return ""
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

// ---------------------------------------------------------------------------
// Sidechain proxy commands
// ---------------------------------------------------------------------------

// createSidechainCommands dynamically creates sidechain proxy commands.
func createSidechainCommands() []*cli.Command {
	return []*cli.Command{
		createGenericSidechainCommand("bitassets", newBitassetsClient),
		createGenericSidechainCommand("bitnames", newBitnamesClient),
		createGenericSidechainCommand("coinshift", newCoinshiftClient),
		createGenericSidechainCommand("photon", newPhotonClient),
		createGenericSidechainCommand("thunder", newThunderClient),
		createGenericSidechainCommand("truthcoin", newTruthcoinClient),
		createGenericSidechainCommand("zside", newZsideClient),
	}
}

// SidechainClient interface for all sidechain RPC clients
type SidechainClient interface {
	// Every sidechain client should have these core methods
	Balance(ctx context.Context) (interface{}, error)
	OpenAPISchema(ctx context.Context) (json.RawMessage, error)
}

// ClientFactory creates a new sidechain client for the given port
type ClientFactory func(port int) SidechainClient

// BitnamesClientWrapper adapts the bitnames.Client to SidechainClient interface
type BitnamesClientWrapper struct {
	*bitnames.Client
}

func (w *BitnamesClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *BitnamesClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// ThunderClientWrapper adapts the thunder.Client to SidechainClient interface
type ThunderClientWrapper struct {
	*thunder.Client
}

func (w *ThunderClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *ThunderClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// BitassetsClientWrapper adapts the bitassets.Client to SidechainClient interface
type BitassetsClientWrapper struct {
	*bitassets.Client
}

func (w *BitassetsClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *BitassetsClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// CoinshiftClientWrapper adapts the coinshift.Client to SidechainClient interface
type CoinshiftClientWrapper struct {
	*coinshift.Client
}

func (w *CoinshiftClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *CoinshiftClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// PhotonClientWrapper adapts the photon.Client to SidechainClient interface
type PhotonClientWrapper struct {
	*photon.Client
}

func (w *PhotonClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *PhotonClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// TruthcoinClientWrapper adapts the truthcoin.Client to SidechainClient interface
type TruthcoinClientWrapper struct {
	*truthcoin.Client
}

func (w *TruthcoinClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *TruthcoinClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// ZsideClientWrapper adapts the zside.Client to SidechainClient interface
type ZsideClientWrapper struct {
	*zside.Client
}

func (w *ZsideClientWrapper) Balance(ctx context.Context) (interface{}, error) {
	return w.Client.Balance(ctx)
}

func (w *ZsideClientWrapper) OpenAPISchema(ctx context.Context) (json.RawMessage, error) {
	return w.Client.OpenAPISchema(ctx)
}

// Client factory functions
func newBitassetsClient(port int) SidechainClient {
	return &BitassetsClientWrapper{bitassets.NewClient("localhost", port)}
}

func newBitnamesClient(port int) SidechainClient {
	return &BitnamesClientWrapper{bitnames.NewClient("localhost", port)}
}

func newCoinshiftClient(port int) SidechainClient {
	return &CoinshiftClientWrapper{coinshift.NewClient("localhost", port)}
}

func newPhotonClient(port int) SidechainClient {
	return &PhotonClientWrapper{photon.NewClient("localhost", port)}
}

func newThunderClient(port int) SidechainClient {
	return &ThunderClientWrapper{thunder.NewClient("localhost", port)}
}

func newTruthcoinClient(port int) SidechainClient {
	return &TruthcoinClientWrapper{truthcoin.NewClient("localhost", port)}
}

func newZsideClient(port int) SidechainClient {
	return &ZsideClientWrapper{zside.NewClient("localhost", port)}
}

// createGenericSidechainCommand creates a command with sidechain-specific subcommands
func createGenericSidechainCommand(sidechainName string, clientFactory ClientFactory) *cli.Command {
	return &cli.Command{
		Name:  sidechainName,
		Usage: fmt.Sprintf("Manage %s sidechain", titleCase(sidechainName)),
		Subcommands: []*cli.Command{
			createMethodCommand(sidechainName, "balance", "Show wallet balance", clientFactory, "Balance"),
			createMethodCommand(sidechainName, "generate-schema", "Generate OpenAPI schema", clientFactory, "OpenAPISchema"),
		},
	}
}

// createMethodCommand creates a command that calls a specific method on the sidechain client
func createMethodCommand(sidechainName, cmdName, usage string, clientFactory ClientFactory, methodName string) *cli.Command {
	return &cli.Command{
		Name:  cmdName,
		Usage: usage,
		Action: func(cctx *cli.Context) error {
			return runSidechainMethod(cctx, sidechainName, clientFactory, methodName)
		},
	}
}

// runSidechainMethod executes a method on the sidechain client with smart binary management
func runSidechainMethod(cctx *cli.Context, sidechainName string, clientFactory ClientFactory, methodName string) error {
	client := newClient(cctx)
	
	// Check if binary is downloaded
	resp, err := client.GetBinaryStatus(cctx.Context, connect.NewRequest(&pb.GetBinaryStatusRequest{
		Name: sidechainName,
	}))
	if err != nil {
		return fmt.Errorf("failed to check %s status: %w", sidechainName, err)
	}

	status := resp.Msg.Status
	if !status.Downloaded {
		// Binary not downloaded - ask user or auto-download in CI
		autoDownload := cctx.Bool("auto-download") || os.Getenv("ORCHESTRATOR_AUTO_DOWNLOAD") != ""
		displayName := status.DisplayName
		if displayName == "" {
			displayName = titleCase(sidechainName)
		}

		if autoDownload {
			fmt.Printf("%s is not downloaded. Downloading now...\n", displayName)
		} else {
			fmt.Printf("%s is not downloaded. download now? [Y/n] ", displayName)
			if !confirmYes() {
				return fmt.Errorf("cannot run %s command without %s binary", methodName, sidechainName)
			}
		}

		// Download the binary
		if err := runDownload(cctx.Context, client, sidechainName, false); err != nil {
			return fmt.Errorf("failed to download %s: %w", sidechainName, err)
		}
		fmt.Println()
	}

	// Get the port for the sidechain
	port, err := getSidechainPort(sidechainName)
	if err != nil {
		return fmt.Errorf("failed to get port for %s: %w", sidechainName, err)
	}

	// Create the sidechain client and call the method
	sidechainClient := clientFactory(port)
	return callClientMethod(cctx.Context, sidechainClient, methodName)
}

// callClientMethod uses reflection to call the specified method on the client
func callClientMethod(ctx context.Context, client SidechainClient, methodName string) error {
	clientValue := reflect.ValueOf(client)
	method := clientValue.MethodByName(methodName)
	
	if !method.IsValid() {
		return fmt.Errorf("method %s not found on client", methodName)
	}

	// Call the method with context
	results := method.Call([]reflect.Value{reflect.ValueOf(ctx)})
	if len(results) != 2 {
		return fmt.Errorf("unexpected return values from method %s", methodName)
	}

	// Check for error (second return value)
	if !results[1].IsNil() {
		err := results[1].Interface().(error)
		return fmt.Errorf("%s error: %w", methodName, err)
	}

	// Handle the result (first return value)
	result := results[0].Interface()
	return outputResult(result)
}

// outputResult formats and prints the result
func outputResult(result interface{}) error {
	switch v := result.(type) {
	case json.RawMessage:
		// For OpenAPI schema, pretty print JSON
		var formatted interface{}
		if err := json.Unmarshal(v, &formatted); err != nil {
			return fmt.Errorf("failed to parse JSON result: %w", err)
		}
		pretty, err := json.MarshalIndent(formatted, "", "  ")
		if err != nil {
			return fmt.Errorf("failed to format JSON result: %w", err)
		}
		fmt.Println(string(pretty))
	default:
		// For balance and other structured data, use JSON for consistency
		pretty, err := json.MarshalIndent(result, "", "  ")
		if err != nil {
			return fmt.Errorf("failed to format result: %w", err)
		}
		fmt.Println(string(pretty))
	}
	return nil
}

// getSidechainPort returns the default port for a sidechain
func getSidechainPort(sidechainName string) (int, error) {
	// These ports match the default ports used by each sidechain
	switch sidechainName {
	case "bitnames":
		return 38332, nil
	case "thunder":
		return 48332, nil
	case "bitassets":
		return 28332, nil
	case "coinshift":
		return 58332, nil
	case "photon":
		return 18332, nil
	case "truthcoin":
		return 68332, nil
	case "zside":
		return 78332, nil
	default:
		return 0, fmt.Errorf("unknown sidechain: %s", sidechainName)
	}
}

// titleCase capitalizes the first letter of a string
func titleCase(s string) string {
	if s == "" {
		return s
	}
	r := []rune(s)
	r[0] = unicode.ToUpper(r[0])
	return string(r)
}
