package commands

import (
	"fmt"
	"os"
	"text/tabwriter"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

var resetCommand = &cli.Command{
	Name:  "reset",
	Usage: "Preview or run a data reset via orchestratord",
	Subcommands: []*cli.Command{
		resetPreviewCommand,
		resetRunCommand,
	},
}

func resetCategoryFlags() []cli.Flag {
	return []cli.Flag{
		&cli.BoolFlag{Name: "blockchain-data", Usage: "include blockchain data"},
		&cli.BoolFlag{Name: "node-software", Usage: "include downloaded node binaries"},
		&cli.BoolFlag{Name: "logs", Usage: "include log files"},
		&cli.BoolFlag{Name: "settings", Usage: "include config / settings files"},
		&cli.BoolFlag{Name: "wallets", Usage: "include wallet files (moved to wallet_backups/)"},
		&cli.BoolFlag{Name: "sidechains", Usage: "cascade the reset to sidechain data too"},
	}
}

func ensureAnyResetCategory(cctx *cli.Context) error {
	if !cctx.Bool("blockchain-data") && !cctx.Bool("node-software") &&
		!cctx.Bool("logs") && !cctx.Bool("settings") && !cctx.Bool("wallets") {
		return fmt.Errorf("pick at least one category: --blockchain-data, --node-software, --logs, --settings, --wallets")
	}
	return nil
}

// resetSpecs builds the per-binary deletion request from the category flags.
// L1 (bitcoind, enforcer, bitwindowd) is always included; sidechains only when
// --sidechains is set.
func resetSpecs(cctx *cli.Context) []*pb.SingleDeletion {
	var dts []pb.DeletionType
	if cctx.Bool("blockchain-data") {
		dts = append(dts, pb.DeletionType_DELETION_TYPE_DATA)
	}
	if cctx.Bool("node-software") {
		dts = append(dts, pb.DeletionType_DELETION_TYPE_SOFTWARE)
	}
	if cctx.Bool("logs") {
		dts = append(dts, pb.DeletionType_DELETION_TYPE_LOGS)
	}
	if cctx.Bool("settings") {
		dts = append(dts, pb.DeletionType_DELETION_TYPE_SETTINGS)
	}
	if cctx.Bool("wallets") {
		dts = append(dts, pb.DeletionType_DELETION_TYPE_WALLET)
	}

	bins := []pb.BinaryType{
		pb.BinaryType_BINARY_TYPE_BITCOIND,
		pb.BinaryType_BINARY_TYPE_ENFORCER,
		pb.BinaryType_BINARY_TYPE_BITWINDOWD,
	}
	if cctx.Bool("sidechains") {
		bins = append(bins,
			pb.BinaryType_BINARY_TYPE_THUNDER,
			pb.BinaryType_BINARY_TYPE_ZSIDE,
			pb.BinaryType_BINARY_TYPE_BITNAMES,
			pb.BinaryType_BINARY_TYPE_BITASSETS,
			pb.BinaryType_BINARY_TYPE_TRUTHCOIN,
			pb.BinaryType_BINARY_TYPE_PHOTON,
			pb.BinaryType_BINARY_TYPE_COINSHIFT,
		)
	}

	specs := make([]*pb.SingleDeletion, 0, len(bins))
	for _, b := range bins {
		specs = append(specs, &pb.SingleDeletion{Binary: b, Deletions: dts})
	}
	return specs
}

var resetPreviewCommand = &cli.Command{
	Name:  "preview",
	Usage: "List what a reset would delete without touching anything",
	Flags: resetCategoryFlags(),
	Action: func(cctx *cli.Context) error {
		if err := ensureAnyResetCategory(cctx); err != nil {
			return err
		}
		client := newClient(cctx)
		resp, err := client.GatherFilesToDelete(cctx.Context, connect.NewRequest(&pb.GatherFilesToDeleteRequest{
			Items: resetSpecs(cctx),
		}))
		if err != nil {
			return err
		}
		if len(resp.Msg.Files) == 0 {
			fmt.Println("nothing to delete")
			return nil
		}

		var totalBytes int64
		tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "CATEGORY\tSIZE\tPATH\tKIND")
		for _, f := range resp.Msg.Files {
			kind := "file"
			if f.IsDirectory {
				kind = "dir"
			}
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\n", f.DeletionType, humanBytes(f.SizeBytes), f.Path, kind)
			totalBytes += f.SizeBytes
		}
		if err := tw.Flush(); err != nil {
			return err
		}
		fmt.Printf("\n%d items, %s total\n", len(resp.Msg.Files), humanBytes(totalBytes))
		return nil
	},
}

var resetRunCommand = &cli.Command{
	Name:  "run",
	Usage: "Execute a reset — streams progress as files are deleted",
	Flags: append(resetCategoryFlags(), &cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"}),
	Action: func(cctx *cli.Context) error {
		if err := ensureAnyResetCategory(cctx); err != nil {
			return err
		}
		prompt := "this will delete data via orchestratord. proceed?"
		if cctx.Bool("wallets") {
			prompt = "this will move WALLET files to wallet_backups/ and delete the rest. proceed?"
		}
		if err := confirmOrAbort(cctx, prompt); err != nil {
			return err
		}

		client := newClient(cctx)

		// Gather the concrete paths, then hand them to the dumb deleter.
		gathered, err := client.GatherFilesToDelete(cctx.Context, connect.NewRequest(&pb.GatherFilesToDeleteRequest{
			Items: resetSpecs(cctx),
		}))
		if err != nil {
			return err
		}
		if len(gathered.Msg.Files) == 0 {
			fmt.Println("nothing to delete")
			return nil
		}

		// Hand the same selection to the deleter; it re-resolves paths
		// server-side so only gather-reported files can be removed.
		stream, err := client.DeleteFiles(cctx.Context, connect.NewRequest(&pb.DeleteFilesRequest{Items: resetSpecs(cctx)}))
		if err != nil {
			return err
		}

		deleted, failed := 0, 0
		for stream.Receive() {
			msg := stream.Msg()
			if msg.Error == "" {
				deleted++
				fmt.Printf("  ok    %s\n", msg.Path)
			} else {
				failed++
				fmt.Printf("  FAIL  %s (%s)\n", msg.Path, msg.Error)
			}
		}
		if err := stream.Err(); err != nil {
			return err
		}
		fmt.Printf("\ndeleted %d, failed %d\n", deleted, failed)
		return nil
	},
}

// humanBytes turns a byte count into a short human-readable string: 1.2 MB etc.
func humanBytes(n int64) string {
	const unit = 1024
	if n < unit {
		return fmt.Sprintf("%d B", n)
	}
	div, exp := int64(unit), 0
	for i := n / unit; i >= unit; i /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(n)/float64(div), "KMGTPE"[exp])
}
