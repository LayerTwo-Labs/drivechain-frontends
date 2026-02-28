package commands

import (
	"fmt"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

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
