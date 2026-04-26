package commands

import (
	"fmt"
	"strings"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/urfave/cli/v2"
)

var testSidechainsCommand = &cli.Command{
	Name:  "test-sidechains",
	Usage: "Toggle the test-sidechain build flavour for layer-2 binaries",
	Subcommands: []*cli.Command{
		testSidechainsStatusCommand,
		testSidechainsSetCommand,
	},
}

var testSidechainsStatusCommand = &cli.Command{
	Name:  "status",
	Usage: "Show whether test-sidechain builds are active",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		resp, err := client.GetTestSidechains(cctx.Context, connect.NewRequest(&pb.GetTestSidechainsRequest{}))
		if err != nil {
			return err
		}
		fmt.Println(testSidechainsLabel(resp.Msg.Enabled))
		return nil
	},
}

var testSidechainsSetCommand = &cli.Command{
	Name:      "set",
	Usage:     "Switch between production and test sidechain builds",
	ArgsUsage: "<production|test>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl test-sidechains set <production|test>")
		}
		enabled, err := parseTestSidechainsArg(cctx.Args().First())
		if err != nil {
			return err
		}
		client := newWalletClient(cctx)
		if _, err := client.SetTestSidechains(cctx.Context, connect.NewRequest(&pb.SetTestSidechainsRequest{Enabled: enabled})); err != nil {
			return err
		}
		fmt.Printf("test-sidechains: %s\n", testSidechainsLabel(enabled))
		fmt.Println("layer-2 binaries were stopped and removed; they will redownload on next start.")
		return nil
	},
}

func testSidechainsLabel(enabled bool) string {
	if enabled {
		return "test"
	}
	return "production"
}

func parseTestSidechainsArg(s string) (bool, error) {
	switch strings.ToLower(strings.TrimSpace(s)) {
	case "test", "true", "on", "1":
		return true, nil
	case "production", "prod", "false", "off", "0":
		return false, nil
	default:
		return false, fmt.Errorf("invalid value %q (expected production|test)", s)
	}
}
