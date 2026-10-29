package commands

import (
	"context"
	"encoding/json"
	"fmt"
	"io"

	"github.com/urfave/cli/v2"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

var ecashBurnsCommand = &cli.Command{
	Name:  "burns",
	Usage: "List the ECX burns of 1000 coins or more from a node of the burn network",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "network", Usage: "burn network: alphanet or betanet", Required: true},
		&cli.StringFlag{Name: "core-url", Usage: "RPC URL of a node on that network", Value: "http://127.0.0.1:18302"},
		&cli.StringFlag{Name: "core-cookie", Usage: "path to the node's .cookie file"},
		&cli.StringFlag{Name: "core-user", Usage: "RPC user, when the node has no cookie"},
		&cli.StringFlag{Name: "core-password", Usage: "RPC password, when the node has no cookie"},
	},
	Action: func(cctx *cli.Context) error {
		user, password := cctx.String("core-user"), cctx.String("core-password")
		if path := cctx.String("core-cookie"); path != "" {
			var err error
			if user, password, err = wallet.ReadCoreCookie(path); err != nil {
				return err
			}
		}
		url := cctx.String("core-url")
		call := func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
			return orchestrator.CallBitcoindRPC(ctx, url, user, password, method, params)
		}
		return runECashBurns(cctx.Context, cctx.App.Writer, call, cctx.String("network"))
	},
}

func runECashBurns(ctx context.Context, out io.Writer, call wallet.CoreCall, networkID string) error {
	network := wallet.ECXBurnNetworkByID(networkID)
	if network.Name == "" {
		return fmt.Errorf("%q is no burn network; use alphanet or betanet", networkID)
	}
	entry, ok := netcatalog.Embedded().ByID(networkID)
	if !ok || entry.ForkHeight <= 0 {
		return fmt.Errorf("the catalog has no fork height for %s", networkID)
	}
	burns, err := wallet.CoreECXBurns(ctx, call, network, entry.ForkHeight)
	if err != nil {
		return err
	}
	csv, err := wallet.ECXBurnCSV(burns)
	if err != nil {
		return fmt.Errorf("write the burn csv: %w", err)
	}
	_, err = io.WriteString(out, csv)
	return err
}
