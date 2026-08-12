package commands

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/urfave/cli/v2"

	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1/bmmv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

func newBMMClient(cctx *cli.Context) bmmv1connect.BMMServiceClient {
	return bmmv1connect.NewBMMServiceClient(
		http.DefaultClient,
		fmt.Sprintf("http://%s", cctx.String("rpcserver")),
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir(cctx))),
	)
}

// sidechainType resolves a name the way a person would type it: "inquisition"
// rather than BINARY_TYPE_INQUISITION.
func sidechainType(name string) (pb.BinaryType, error) {
	full := "BINARY_TYPE_" + strings.ToUpper(strings.ReplaceAll(name, "-", "_"))
	value, ok := pb.BinaryType_value[full]
	if !ok {
		return pb.BinaryType_BINARY_TYPE_UNSPECIFIED, fmt.Errorf("unknown sidechain %q", name)
	}
	return pb.BinaryType(value), nil
}

// Flags go before the sidechain name: urfave/cli stops parsing them at the
// first positional argument.
var bmmCommand = &cli.Command{
	Name:  "bmm",
	Usage: "Blind merge mine a sidechain",
	Subcommands: []*cli.Command{
		bmmMineCommand,
		bmmStartCommand,
		bmmStopCommand,
	},
}

var bmmMineCommand = &cli.Command{
	Name:      "mine",
	Usage:     "Mine sidechain blocks, one bid at a time",
	ArgsUsage: "<sidechain>",
	Flags: []cli.Flag{
		&cli.IntFlag{Name: "blocks", Value: 1, Usage: "how many to mine"},
		&cli.Int64Flag{Name: "bid", Value: 1000, Usage: "sats to bid per block"},
		&cli.DurationFlag{Name: "timeout", Value: 60 * time.Second, Usage: "how long to wait for each bid to be taken"},
		&cli.BoolFlag{Name: "generate", Usage: "also mine the mainchain block that takes the bid (regtest)"},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: bmm mine [flags] <sidechain>")
		}
		sidechain, err := sidechainType(cctx.Args().First())
		if err != nil {
			return err
		}
		client := newBMMClient(cctx)

		for i := 1; i <= cctx.Int("blocks"); i++ {
			bid, err := client.CreateBid(cctx.Context, connect.NewRequest(&bmmpb.CreateBidRequest{
				Sidechain: sidechain,
				BidSats:   cctx.Int64("bid"),
			}))
			if err != nil {
				return fmt.Errorf("create bid %d: %w", i, err)
			}
			fmt.Printf("bid %d broadcast: %s\n", i, bid.Msg.BmmTxid)

			// A bid is worth nothing until a mainchain miner takes it. On a real
			// network that is somebody else's decision and all we can do is
			// wait; on regtest we are the miner, so make the block ourselves.
			if cctx.Bool("generate") {
				if err := generateMainchainBlock(cctx); err != nil {
					return fmt.Errorf("generate mainchain block: %w", err)
				}
			}
			deadline := time.Now().Add(cctx.Duration("timeout"))
			for {
				connected, err := client.ConnectBid(cctx.Context, connect.NewRequest(&bmmpb.ConnectBidRequest{
					Sidechain:    sidechain,
					CriticalHash: bid.Msg.CriticalHash,
					BlockJson:    bid.Msg.BlockJson,
				}))
				if err == nil && connected.Msg.Connected {
					fmt.Printf("  connected in mainchain block %s\n", connected.Msg.MainBlockHash)
					break
				}
				if time.Now().After(deadline) {
					return fmt.Errorf("bid %d was not taken within %s", i, cctx.Duration("timeout"))
				}
				time.Sleep(time.Second)
			}
		}
		return nil
	},
}

// generateMainchainBlock mines one block through the enforcer, which is what
// puts the M1/M2 messages in its coinbase. Routed through the orchestrator
// rather than the enforcer directly so the CLI needs one address, not two.
func generateMainchainBlock(cctx *cli.Context) error {
	address, err := enforcerCall(cctx, "WalletService/CreateNewAddress", map[string]any{})
	if err != nil {
		return err
	}
	to, _ := address["address"].(string)
	if to == "" {
		return fmt.Errorf("the enforcer gave no address to mine to")
	}
	_, err = enforcerCall(cctx, "MiningService/GenerateToAddress", map[string]any{"blocks": 1, "address": to})
	return err
}

// enforcerCall speaks Connect's JSON protocol, which is a plain HTTP POST, to
// the enforcer services the orchestrator bridges.
func enforcerCall(cctx *cli.Context, method string, body map[string]any) (map[string]any, error) {
	payload, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}
	url := fmt.Sprintf("http://%s/cusf.mainchain.v1.%s", cctx.String("rpcserver"), method)
	req, err := http.NewRequestWithContext(cctx.Context, http.MethodPost, url, bytes.NewReader(payload))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%s: %s: %s", method, resp.Status, bytes.TrimSpace(raw))
	}
	var out map[string]any
	if len(raw) > 0 {
		if err := json.Unmarshal(raw, &out); err != nil {
			return nil, fmt.Errorf("decode %s: %w", method, err)
		}
	}
	return out, nil
}

var bmmStartCommand = &cli.Command{
	Name:      "start",
	Usage:     "Bid on every mainchain block until stopped",
	ArgsUsage: "<sidechain>",
	Flags: []cli.Flag{
		&cli.Int64Flag{Name: "min-bid", Value: 1000, Usage: "lowest sats to bid"},
		&cli.Int64Flag{Name: "max-bid", Value: 100000, Usage: "highest sats to bid"},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: bmm start [flags] <sidechain>")
		}
		sidechain, err := sidechainType(cctx.Args().First())
		if err != nil {
			return err
		}
		if _, err := newBMMClient(cctx).Start(cctx.Context, connect.NewRequest(&bmmpb.StartRequest{
			Sidechain:  sidechain,
			MinBidSats: cctx.Int64("min-bid"),
			MaxBidSats: cctx.Int64("max-bid"),
		})); err != nil {
			return err
		}
		fmt.Printf("bidding on %s\n", cctx.Args().First())
		return nil
	},
}

var bmmStopCommand = &cli.Command{
	Name:      "stop",
	Usage:     "Stop bidding",
	ArgsUsage: "<sidechain>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() != 1 {
			return fmt.Errorf("usage: bmm stop <sidechain>")
		}
		sidechain, err := sidechainType(cctx.Args().First())
		if err != nil {
			return err
		}
		if _, err := newBMMClient(cctx).Stop(cctx.Context, connect.NewRequest(&bmmpb.StopRequest{
			Sidechain: sidechain,
		})); err != nil {
			return err
		}
		fmt.Printf("stopped bidding on %s\n", cctx.Args().First())
		return nil
	},
}
