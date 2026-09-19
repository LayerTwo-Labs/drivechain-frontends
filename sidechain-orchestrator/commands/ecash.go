package commands

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"strings"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/urfave/cli/v2"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

var ecashCommand = &cli.Command{
	Name:  "ecash",
	Usage: "Change ECX networks through drivechaind",
	Subcommands: []*cli.Command{
		ecashMigrateCommand,
		ecashMigrationStatusCommand,
	},
}

var ecashMigrateCommand = &cli.Command{
	Name:  "migrate",
	Usage: "Keep common BTC blocks across an ECX network change",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "from", Usage: "source network ID", Required: true},
		&cli.StringFlag{Name: "to", Usage: "target network ID", Required: true},
		&cli.BoolFlag{Name: "preview", Usage: "read the plan without changes to node files"},
		&cli.BoolFlag{Name: "yes", Usage: "start or resume without a prompt"},
		&cli.BoolFlag{Name: "json", Usage: "write one JSON object per status update"},
	},
	Action: func(cctx *cli.Context) error {
		return runECashMigrate(cctx, newClient(cctx), time.Second)
	},
}

var ecashMigrationStatusCommand = &cli.Command{
	Name:  "migration-status",
	Usage: "Read the saved migration state from drivechaind",
	Flags: []cli.Flag{
		&cli.BoolFlag{Name: "json", Usage: "write the status as JSON"},
	},
	Action: func(cctx *cli.Context) error {
		return runECashMigrationStatus(cctx, newClient(cctx))
	},
}

func runECashMigrate(cctx *cli.Context, client rpc.OrchestratorServiceClient, interval time.Duration) error {
	if cctx.NArg() != 0 {
		return errors.New("use --from and --to without positional arguments")
	}
	fromID := strings.TrimSpace(cctx.String("from"))
	toID := strings.TrimSpace(cctx.String("to"))
	if fromID == "" || toID == "" || fromID == toID {
		return errors.New("set --from and --to to different network IDs")
	}
	if cctx.Bool("json") && !cctx.Bool("yes") && !cctx.Bool("preview") {
		return errors.New("use --yes with --json to start a migration")
	}

	if cctx.Bool("preview") || !cctx.Bool("yes") {
		resp, err := client.PreviewECashMigration(cctx.Context, connect.NewRequest(&pb.PreviewECashMigrationRequest{
			FromId: fromID,
			ToId:   toID,
		}))
		if err != nil {
			return fmt.Errorf("get the migration preview: %w", err)
		}
		if err := checkECashMigrationTarget(resp.Msg.Status, fromID, toID); err != nil {
			return err
		}
		if err := writeECashMigrationStatus(cctx.App.Writer, resp.Msg.Status, cctx.Bool("json")); err != nil {
			return err
		}
		if resp.Msg.Status.Error != "" {
			return errors.New(resp.Msg.Status.Error)
		}
		if cctx.Bool("preview") {
			return nil
		}
		if _, err := fmt.Fprint(cctx.App.ErrWriter, "Start the migration? [y/N] "); err != nil {
			return err
		}
		input := bufio.NewScanner(cctx.App.Reader)
		if !input.Scan() {
			if err := input.Err(); err != nil {
				return fmt.Errorf("read the answer: %w", err)
			}
			return errors.New("use --yes to start without terminal input")
		}
		answer := strings.ToLower(strings.TrimSpace(input.Text()))
		if answer != "y" && answer != "yes" {
			return errors.New("the migration did not start")
		}
	}

	resp, err := client.StartECashMigration(cctx.Context, connect.NewRequest(&pb.StartECashMigrationRequest{
		FromId: fromID,
		ToId:   toID,
	}))
	if err != nil {
		return fmt.Errorf("start the migration: %w", err)
	}
	status := resp.Msg.Status
	if err := checkECashMigrationTarget(status, fromID, toID); err != nil {
		return err
	}
	jobID := status.JobId
	if jobID == "" {
		return errors.New("the daemon returned no migration job ID")
	}

	var previous *pb.ECashMigrationStatus
	for {
		if err := checkECashMigrationTarget(status, fromID, toID); err != nil {
			return err
		}
		if status.JobId != jobID {
			return errors.New("the daemon returned a different migration job")
		}
		if !proto.Equal(previous, status) {
			write := writeECashMigrationStatus
			if previous != nil {
				write = writeECashMigrationProgress
			}
			if err := write(cctx.App.Writer, status, cctx.Bool("json")); err != nil {
				return err
			}
			previous = status
		}
		if status.Error != "" {
			return errors.New(status.Error)
		}
		if status.Complete && !status.Running {
			return nil
		}
		if !status.Running {
			return errors.New("the migration stopped before the local checks passed; repeat the migrate command to resume")
		}

		timer := time.NewTimer(interval)
		select {
		case <-cctx.Done():
			timer.Stop()
			return fmt.Errorf("the daemon keeps the migration job; use ecash migration-status: %w", cctx.Err())
		case <-timer.C:
		}
		next, err := client.GetECashMigrationStatus(cctx.Context, connect.NewRequest(&pb.GetECashMigrationStatusRequest{}))
		if err != nil {
			return fmt.Errorf("read the migration status; use ecash migration-status to check the daemon: %w", err)
		}
		status = next.Msg.Status
	}
}

func runECashMigrationStatus(cctx *cli.Context, client rpc.OrchestratorServiceClient) error {
	if cctx.NArg() != 0 {
		return errors.New("migration-status accepts no positional arguments")
	}
	resp, err := client.GetECashMigrationStatus(cctx.Context, connect.NewRequest(&pb.GetECashMigrationStatusRequest{}))
	if err != nil {
		return fmt.Errorf("read the migration status: %w", err)
	}
	if err := writeECashMigrationStatus(cctx.App.Writer, resp.Msg.Status, cctx.Bool("json")); err != nil {
		return err
	}
	if resp.Msg.Status.Error != "" {
		return errors.New(resp.Msg.Status.Error)
	}
	return nil
}

func checkECashMigrationTarget(status *pb.ECashMigrationStatus, fromID, toID string) error {
	if status == nil {
		return errors.New("the daemon returned no migration status")
	}
	if status.FromId != fromID || status.ToId != toID {
		return errors.New("the daemon returned different migration networks")
	}
	return nil
}

func writeECashMigrationStatus(out io.Writer, status *pb.ECashMigrationStatus, asJSON bool) error {
	if status == nil {
		return errors.New("the daemon returned no migration status")
	}
	if asJSON {
		data, err := (protojson.MarshalOptions{UseProtoNames: true, EmitUnpopulated: true}).Marshal(status)
		if err != nil {
			return fmt.Errorf("encode the migration status: %w", err)
		}
		_, err = fmt.Fprintln(out, string(data))
		return err
	}
	if status.JobId == "" && status.FromId == "" {
		_, err := fmt.Fprintln(out, "No ECX migration record.")
		return err
	}
	chain := fmt.Sprintf("Common block: %d %s\n", status.CommonHeight, status.CommonHash)
	if status.WalletOnly {
		chain = "Wallet conversion: target sync starts from the first block.\n"
	} else if status.BelowFork {
		chain = fmt.Sprintf("Source tip below the fork: no rollback, target sync continues from block %d %s\n", status.CommonHeight, status.CommonHash)
	}
	_, err := fmt.Fprintf(out,
		"Source: %s (%s)\nTarget: %s (%s)\nDaemon data directory: %s\n%sFiles: %d block, %d undo\nPruned: %t; prune height: %d\n",
		status.FromId, status.SourceMagic, status.ToId, status.TargetMagic, status.DataDir,
		chain, status.BlockFiles, status.UndoFiles, status.Pruned, status.PruneHeight)
	if err != nil {
		return err
	}
	return writeECashMigrationProgress(out, status, false)
}

func writeECashMigrationProgress(out io.Writer, status *pb.ECashMigrationStatus, asJSON bool) error {
	if asJSON {
		return writeECashMigrationStatus(out, status, true)
	}
	_, err := fmt.Fprintf(out,
		"Job %s: %s; records: %d/%d; active: %t; local checks complete: %t; network sync: %s\n",
		status.JobId, status.Phase, status.RecordsDone, status.RecordsTotal, status.Running, status.Complete, status.SyncState)
	if err != nil {
		return err
	}
	if status.Error != "" {
		_, err := fmt.Fprintf(out, "Error: %s\n", status.Error)
		return err
	}
	return nil
}
