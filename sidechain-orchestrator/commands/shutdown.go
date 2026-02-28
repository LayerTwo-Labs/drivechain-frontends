package commands

import (
	"fmt"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

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
