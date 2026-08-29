package commands

import (
	"encoding/hex"
	"fmt"
	"os"
	"text/tabwriter"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/urfave/cli/v2"
)

var resetCommand = &cli.Command{
	Name:  "reset",
	Usage: "Preview or run a data reset via drivechaind",
	Subcommands: []*cli.Command{
		resetPreviewCommand,
		resetRunCommand,
		rejectBlockCommand,
		acceptBlockCommand,
		resetToBlockCommand,
	},
}

var rejectBlockCommand = &cli.Command{
	Name:      "reject-block",
	Usage:     "Drop a block the node must not follow, and take the best remaining branch",
	ArgsUsage: "<hash>",
	Flags: []cli.Flag{
		&cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"},
		&cli.UintFlag{Name: "enforcer-wait", Usage: "seconds to wait for the enforcer to follow before rebuilding it"},
	},
	Action: func(cctx *cli.Context) error {
		hash := cctx.Args().First()
		if cctx.NArg() != 1 || !isBlockHash(hash) {
			return fmt.Errorf("pass the 64-character hash of the block to reject")
		}

		if err := confirmOrAbort(cctx, fmt.Sprintf("this drops block %s and every block above it. proceed?", hash)); err != nil {
			return err
		}

		req := &pb.RejectBlockRequest{
			BlockHash:           hash,
			EnforcerWaitSeconds: uint32(cctx.Uint("enforcer-wait")),
		}
		resp, err := newClient(cctx).RejectBlock(cctx.Context, connect.NewRequest(req))
		if err != nil {
			return err
		}

		fmt.Printf("core tip: %d %s\n", resp.Msg.CoreHeight, resp.Msg.CoreTipHash)
		switch resp.Msg.Outcome {
		case pb.RejectOutcome_REJECT_OUTCOME_SWITCHED_BRANCH:
			fmt.Println("chain:    followed another branch")
		case pb.RejectOutcome_REJECT_OUTCOME_PARKED_ON_PARENT:
			fmt.Println("chain:    parked on the rejected block's parent, no other branch yet")
		case pb.RejectOutcome_REJECT_OUTCOME_ALREADY_INACTIVE:
			fmt.Println("chain:    unchanged, the block already sat off the active chain")
		default:
			fmt.Println("chain:    unchanged")
		}
		if resp.Msg.EnforcerError != "" {
			return fmt.Errorf("core moved but the enforcer did not follow: %s", resp.Msg.EnforcerError)
		}
		if !resp.Msg.EnforcerChecked {
			fmt.Println("enforcer: not queried, it reads the chain on its next start")
			return nil
		}
		if resp.Msg.EnforcerRebuilt {
			fmt.Println("enforcer: validator chain deleted, rebuilds from the local core")
			return nil
		}
		fmt.Printf("enforcer: on core's chain, tip %d\n", resp.Msg.EnforcerHeight)
		return nil
	},
}

var resetToBlockCommand = &cli.Command{
	Name:      "reset-to-block",
	Usage:     "Move the chain back to a block, then sync forward to the tip again",
	ArgsUsage: "<height|hash>",
	Flags: []cli.Flag{
		&cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"},
		&cli.UintFlag{Name: "enforcer-wait", Usage: "seconds to wait for the enforcer to follow before rebuilding it"},
	},
	Action: func(cctx *cli.Context) error {
		target := cctx.Args().First()
		if cctx.NArg() != 1 || target == "" {
			return fmt.Errorf("pass the height or the 64-character hash of the block to reset to")
		}

		if err := confirmOrAbort(cctx, fmt.Sprintf("this drops every block above %s, then replays them. proceed?", target)); err != nil {
			return err
		}

		req := &pb.ResetToBlockRequest{
			Target:              target,
			EnforcerWaitSeconds: uint32(cctx.Uint("enforcer-wait")),
		}
		stream, err := newClient(cctx).ResetToBlock(cctx.Context, connect.NewRequest(req))
		if err != nil {
			return err
		}
		defer func() { _ = stream.Close() }()

		var last *pb.ResetToBlockResponse
		for stream.Receive() {
			msg := stream.Msg()
			last = msg
			fmt.Printf("%-13s %s\n", resetPhaseLabel(msg.Phase), msg.Message)
		}
		if err := stream.Err(); err != nil {
			return err
		}
		if last == nil {
			return fmt.Errorf("the reset reported nothing")
		}
		if last.EnforcerError != "" {
			return fmt.Errorf("core replayed but the enforcer did not follow: %s", last.EnforcerError)
		}
		if !last.EnforcerChecked {
			fmt.Println("enforcer:     not queried, it reads the chain on its next start")
			return nil
		}
		if last.EnforcerRebuilt {
			fmt.Println("enforcer:     validator chain deleted, rebuilds from the local core")
			return nil
		}
		fmt.Printf("enforcer:     on core's chain, tip %d\n", last.EnforcerHeight)
		return nil
	},
}

func resetPhaseLabel(p pb.ResetPhase) string {
	switch p {
	case pb.ResetPhase_RESET_PHASE_RESOLVE:
		return "resolve:"
	case pb.ResetPhase_RESET_PHASE_MOVE_BACK:
		return "move back:"
	case pb.ResetPhase_RESET_PHASE_SYNC_FORWARD:
		return "sync forward:"
	case pb.ResetPhase_RESET_PHASE_ENFORCER:
		return "enforcer:"
	case pb.ResetPhase_RESET_PHASE_DONE:
		return "done:"
	}
	return "reset:"
}

var acceptBlockCommand = &cli.Command{
	Name:      "accept-block",
	Usage:     "Undo reject-block, so the node may follow that branch again",
	ArgsUsage: "<hash>",
	Flags: []cli.Flag{
		&cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"},
		&cli.UintFlag{Name: "enforcer-wait", Usage: "seconds to wait for the enforcer to follow before rebuilding it"},
	},
	Action: func(cctx *cli.Context) error {
		hash := cctx.Args().First()
		if cctx.NArg() != 1 || !isBlockHash(hash) {
			return fmt.Errorf("pass the 64-character hash of the block to accept")
		}

		if err := confirmOrAbort(cctx, fmt.Sprintf("this lets the node follow block %s again. proceed?", hash)); err != nil {
			return err
		}

		req := &pb.AcceptBlockRequest{
			BlockHash:           hash,
			EnforcerWaitSeconds: uint32(cctx.Uint("enforcer-wait")),
		}
		resp, err := newClient(cctx).AcceptBlock(cctx.Context, connect.NewRequest(req))
		if err != nil {
			return err
		}

		fmt.Printf("core tip: %d %s\n", resp.Msg.CoreHeight, resp.Msg.CoreTipHash)
		if resp.Msg.EnforcerError != "" {
			return fmt.Errorf("core moved but the enforcer did not follow: %s", resp.Msg.EnforcerError)
		}
		if !resp.Msg.EnforcerChecked {
			fmt.Println("enforcer: not queried, it reads the chain on its next start")
			return nil
		}
		if resp.Msg.EnforcerRebuilt {
			fmt.Println("enforcer: validator chain deleted, rebuilds from the local core")
			return nil
		}
		fmt.Printf("enforcer: on core's chain, tip %d\n", resp.Msg.EnforcerHeight)
		return nil
	},
}

// isBlockHash reports whether s reads as a block hash: 64 hex characters.
func isBlockHash(s string) bool {
	if len(s) != 64 {
		return false
	}
	_, err := hex.DecodeString(s)
	return err == nil
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
			pb.BinaryType_BINARY_TYPE_BBC,
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
		prompt := "this will delete data via drivechaind. proceed?"
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
