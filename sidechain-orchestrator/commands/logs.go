package commands

import (
	"fmt"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

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
