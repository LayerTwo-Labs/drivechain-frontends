package commands

import (
	"fmt"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

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
