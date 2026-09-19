package commands

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"text/tabwriter"
	"time"

	"connectrpc.com/connect"
	"github.com/urfave/cli/v2"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/stratum/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/stratum/v1/stratumv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

func newStratumClient(cctx *cli.Context) stratumv1connect.StratumServiceClient {
	return stratumv1connect.NewStratumServiceClient(
		http.DefaultClient,
		fmt.Sprintf("http://%s", cctx.String("rpcserver")),
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir(cctx))),
	)
}

var miningCommand = &cli.Command{
	Name:  "mining",
	Usage: "Mine eCash with ASIC miners on your network",
	Subcommands: []*cli.Command{
		{
			Name:  "stratum",
			Usage: "Run the Stratum server that your miners connect to",
			Subcommands: []*cli.Command{
				stratumStartCommand,
				stratumStopCommand,
				stratumStatusCommand,
				stratumTargetCommand,
			},
		},
		workModeCommand,
	},
}

var stratumStartCommand = &cli.Command{
	Name:  "start",
	Usage: "Start the Stratum server",
	Flags: []cli.Flag{
		&cli.UintFlag{Name: "port", Value: 3333, Usage: "TCP port the miners connect to"},
	},
	Action: func(cctx *cli.Context) error {
		_, err := newStratumClient(cctx).StartStratum(cctx.Context, connect.NewRequest(&pb.StartStratumRequest{
			Port: uint32(cctx.Uint("port")),
		}))
		if err != nil {
			return err
		}
		fmt.Printf("stratum server started on port %d\n", cctx.Uint("port"))
		return nil
	},
}

var stratumStopCommand = &cli.Command{
	Name:  "stop",
	Usage: "Stop the Stratum server",
	Action: func(cctx *cli.Context) error {
		if _, err := newStratumClient(cctx).StopStratum(cctx.Context, connect.NewRequest(&pb.StopStratumRequest{})); err != nil {
			return err
		}
		fmt.Println("stratum server stopped")
		return nil
	},
}

var stratumStatusCommand = &cli.Command{
	Name:  "status",
	Usage: "Show the server, its miners and the blocks they found",
	Action: func(cctx *cli.Context) error {
		resp, err := newStratumClient(cctx).GetStratumStatus(cctx.Context, connect.NewRequest(&pb.GetStratumStatusRequest{}))
		if err != nil {
			return err
		}
		return printStratumStatus(os.Stdout, resp.Msg, time.Now())
	},
}

var stratumTargetCommand = &cli.Command{
	Name:      "target",
	Usage:     "Send the work to this node (solo), a catalog pool, or a custom pool",
	ArgsUsage: "[flags] <solo|pool-id|custom>",
	Before:    rejectFlagAfterArgument,
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "url", Usage: "stratum+tcp URL of a custom pool"},
		&cli.StringFlag{Name: "worker", Usage: "worker name for a custom pool"},
		&cli.StringFlag{Name: "password", Value: "x", Usage: "password for a custom pool"},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() != 1 {
			return fmt.Errorf("usage: mining stratum target [flags] <solo|pool-id|custom>")
		}
		target := stratumTarget(cctx.Args().First(), cctx.String("url"), cctx.String("worker"), cctx.String("password"))
		if _, err := newStratumClient(cctx).SetTarget(cctx.Context, connect.NewRequest(&pb.SetTargetRequest{Target: target})); err != nil {
			return err
		}
		fmt.Printf("stratum target: %s\n", describeTarget(target))
		return nil
	},
}

func stratumTarget(name, url, worker, password string) *pb.Target {
	switch name {
	case "solo":
		return &pb.Target{Kind: pb.TargetKind_TARGET_KIND_SOLO}
	case "custom":
		return &pb.Target{Kind: pb.TargetKind_TARGET_KIND_CUSTOM, Url: url, Worker: worker, Password: password}
	}
	return &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: name}
}

func describeTarget(t *pb.Target) string {
	switch t.GetKind() {
	case pb.TargetKind_TARGET_KIND_POOL:
		return "pool " + t.GetPoolId()
	case pb.TargetKind_TARGET_KIND_CUSTOM:
		return fmt.Sprintf("custom pool %s as %s", t.GetUrl(), t.GetWorker())
	}
	return "solo, your node"
}

var workModeCommand = &cli.Command{
	Name:      "workmode",
	Usage:     "Set the power mode of a connected miner",
	ArgsUsage: "<address> <low|mid|high>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() != 2 {
			return fmt.Errorf("usage: mining workmode <address> <low|mid|high>")
		}
		mode, ok := map[string]pb.WorkMode{
			"low":  pb.WorkMode_WORK_MODE_LOW,
			"mid":  pb.WorkMode_WORK_MODE_MID,
			"high": pb.WorkMode_WORK_MODE_HIGH,
		}[strings.ToLower(cctx.Args().Get(1))]
		if !ok {
			return fmt.Errorf("work mode %q is not low, mid or high", cctx.Args().Get(1))
		}
		_, err := newStratumClient(cctx).SetWorkMode(cctx.Context, connect.NewRequest(&pb.SetWorkModeRequest{
			Address: cctx.Args().First(),
			Mode:    mode,
		}))
		if err != nil {
			return err
		}
		fmt.Printf("%s now mines in %s mode\n", cctx.Args().First(), strings.ToLower(cctx.Args().Get(1)))
		return nil
	},
}

func printStratumStatus(out io.Writer, s *pb.GetStratumStatusResponse, now time.Time) error {
	var b strings.Builder
	if !s.Running {
		_, _ = fmt.Fprintln(&b, "stratum server: stopped")
	} else {
		_, _ = fmt.Fprintf(&b, "stratum server: running on port %d\n", s.Port)
		if s.PoolUrl != "" {
			_, _ = fmt.Fprintf(&b, "pool address:   %s\n", s.PoolUrl)
		}
	}
	_, _ = fmt.Fprintf(&b, "target:         %s\n", describeTarget(s.GetTarget()))
	if s.PayoutAddress != "" {
		_, _ = fmt.Fprintf(&b, "payout address: %s\n", s.PayoutAddress)
	}
	if s.PoolHost != "" {
		state := "disconnected"
		if s.PoolConnected {
			state = "connected"
		}
		_, _ = fmt.Fprintf(&b, "pool:           %s (%s)\n", s.PoolHost, state)
	}
	if s.Error != "" {
		_, _ = fmt.Fprintf(&b, "last error:     %s\n", s.Error)
	}
	if s.Running {
		_, _ = fmt.Fprintf(&b, "hashrate:       %s\n", formatHashrate(s.Hashrate))
		_, _ = fmt.Fprintf(&b, "shares:         %d accepted, %d rejected\n", s.AcceptedShares, s.RejectedShares)
		_, _ = fmt.Fprintf(&b, "best share:     %.0f (network difficulty %.0f)\n", s.BestShare, s.NetworkDifficulty)
	}

	tw := tabwriter.NewWriter(&b, 0, 2, 2, ' ', 0)
	if len(s.Miners) > 0 {
		_, _ = fmt.Fprintln(tw)
		_, _ = fmt.Fprintln(tw, "WORKER\tADDRESS\tHASHRATE\tBEST SHARE\tACCEPTED/REJECTED\tTEMP\tFAN\tPOWER\tMODE\tLAST SHARE")
		for _, m := range s.Miners {
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%.0f\t%d/%d\t%s\t%s\t%s\t%s\t%s\n",
				m.Worker, m.Address, formatHashrate(m.Hashrate), m.BestShare, m.AcceptedShares, m.RejectedShares,
				optional(m.TemperatureCelsius, "%.0f °C"), optional(m.FanPercent, "%.0f%%"),
				optional(m.PowerWatts, "%.0f W"), workModeName(m.WorkMode), lastShare(m, now))
		}
		if err := tw.Flush(); err != nil {
			return err
		}
	}
	if len(s.BlocksFound) > 0 {
		_, _ = fmt.Fprintln(tw)
		_, _ = fmt.Fprintln(tw, "HEIGHT\tHASH\tREWARD (SATS)\tFOUND BY\tTIME\tCONFIRMATIONS")
		for _, block := range s.BlocksFound {
			confirmations := "—"
			if block.Confirmations != nil {
				confirmations = fmt.Sprint(*block.Confirmations)
			}
			_, _ = fmt.Fprintf(tw, "%d\t%s\t%d\t%s\t%s\t%s\n",
				block.Height, block.Hash, block.RewardSats, block.Worker,
				block.FoundTime.AsTime().Local().Format(time.DateTime), confirmations)
		}
		if err := tw.Flush(); err != nil {
			return err
		}
	}
	_, err := io.WriteString(out, b.String())
	return err
}

func formatHashrate(h float64) string {
	units := []string{"H/s", "KH/s", "MH/s", "GH/s", "TH/s", "PH/s"}
	i := 0
	for h >= 1000 && i < len(units)-1 {
		h /= 1000
		i++
	}
	return fmt.Sprintf("%.2f %s", h, units[i])
}

func optional(v *float64, format string) string {
	if v == nil {
		return "—"
	}
	return fmt.Sprintf(format, *v)
}

func workModeName(m pb.WorkMode) string {
	switch m {
	case pb.WorkMode_WORK_MODE_LOW:
		return "low"
	case pb.WorkMode_WORK_MODE_MID:
		return "mid"
	case pb.WorkMode_WORK_MODE_HIGH:
		return "high"
	}
	return "—"
}

func lastShare(m *pb.ConnectedMiner, now time.Time) string {
	if m.LastShareTime == nil {
		return "—"
	}
	return fmt.Sprintf("%s ago", now.Sub(m.LastShareTime.AsTime()).Round(time.Second))
}
