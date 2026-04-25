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
		&cli.BoolFlag{Name: "wallets", Usage: "include wallet files (DANGEROUS)"},
		&cli.BoolFlag{Name: "sidechains", Usage: "cascade the reset to sidechain data too"},
	}
}

func resetCategoriesFromCtx(cctx *cli.Context) (blockchain, software, logs, settings, wallets, sidechains bool) {
	return cctx.Bool("blockchain-data"),
		cctx.Bool("node-software"),
		cctx.Bool("logs"),
		cctx.Bool("settings"),
		cctx.Bool("wallets"),
		cctx.Bool("sidechains")
}

func ensureAnyResetCategory(cctx *cli.Context) error {
	blockchain, software, logs, settings, wallets, _ := resetCategoriesFromCtx(cctx)
	if !blockchain && !software && !logs && !settings && !wallets {
		return fmt.Errorf("pick at least one category: --blockchain-data, --node-software, --logs, --settings, --wallets")
	}
	return nil
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
		blockchain, software, logs, settings, wallets, sidechains := resetCategoriesFromCtx(cctx)
		resp, err := client.PreviewResetData(cctx.Context, connect.NewRequest(&pb.PreviewResetDataRequest{
			DeleteBlockchainData: blockchain,
			DeleteNodeSoftware:   software,
			DeleteLogs:           logs,
			DeleteSettings:       settings,
			DeleteWalletFiles:    wallets,
			AlsoResetSidechains:  sidechains,
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
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\n", f.Category, humanBytes(f.SizeBytes), f.Path, kind)
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
			prompt = "this will delete WALLET files (⚠️ funds at risk). proceed?"
		}
		if err := confirmOrAbort(cctx, prompt); err != nil {
			return err
		}

		client := newClient(cctx)
		blockchain, software, logs, settings, wallets, sidechains := resetCategoriesFromCtx(cctx)
		stream, err := client.StreamResetData(cctx.Context, connect.NewRequest(&pb.StreamResetDataRequest{
			DeleteBlockchainData: blockchain,
			DeleteNodeSoftware:   software,
			DeleteLogs:           logs,
			DeleteSettings:       settings,
			DeleteWalletFiles:    wallets,
			AlsoResetSidechains:  sidechains,
		}))
		if err != nil {
			return err
		}

		var last *pb.StreamResetDataResponse
		for stream.Receive() {
			msg := stream.Msg()
			last = msg
			if msg.Done {
				break
			}
			status := "ok"
			if !msg.Success {
				status = fmt.Sprintf("FAIL (%s)", msg.Error)
			}
			fmt.Printf("  %-8s %s  %s\n", status, msg.Category, msg.Path)
		}
		if err := stream.Err(); err != nil {
			return err
		}
		if last != nil && last.Done {
			fmt.Printf("\ndeleted %d, failed %d\n", last.DeletedCount, last.FailedCount)
		}
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
