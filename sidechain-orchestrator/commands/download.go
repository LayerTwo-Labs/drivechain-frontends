package commands

import (
	"fmt"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

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
