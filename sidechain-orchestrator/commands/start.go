package commands

import (
	"fmt"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

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
