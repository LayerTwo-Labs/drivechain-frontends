package commands

import (
	"fmt"
	"net/http"

	"connectrpc.com/connect"
	"github.com/urfave/cli/v2"

	thunderpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	thunderrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

// newThunderService talks to the thunder wallet drivechaind serves. Light mode
// runs no thunder node, so a command reads the wallet here rather than at a
// node port.
func newThunderService(cctx *cli.Context) thunderrpc.ThunderServiceClient {
	return thunderrpc.NewThunderServiceClient(
		http.DefaultClient,
		fmt.Sprintf("http://%s", cctx.String("rpcserver")),
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir(cctx))),
	)
}

var thunderAddressCommand = &cli.Command{
	Name:  "address",
	Usage: "Show an address to receive on",
	Action: func(cctx *cli.Context) error {
		resp, err := newThunderService(cctx).GetNewAddress(
			cctx.Context, connect.NewRequest(&thunderpb.GetNewAddressRequest{}))
		if err != nil {
			return err
		}
		fmt.Println(resp.Msg.Address)
		return nil
	},
}

var thunderTransactionsCommand = &cli.Command{
	Name:    "transactions",
	Aliases: []string{"txs"},
	Usage:   "List the transactions that touched this wallet",
	Action: func(cctx *cli.Context) error {
		resp, err := newThunderService(cctx).ListWalletTransactions(
			cctx.Context, connect.NewRequest(&thunderpb.ListWalletTransactionsRequest{}))
		if err != nil {
			return err
		}
		if len(resp.Msg.Transactions) == 0 {
			fmt.Println("this wallet holds no transactions")
			return nil
		}
		for _, tx := range resp.Msg.Transactions {
			fmt.Printf("%s  %s BTC  %s\n",
				tx.Txid, satsToBtcInt(tx.ValueSats), txState(tx, resp.Msg.TipHeight))
		}
		return nil
	},
}

// txState says where one transaction sits, and how many blocks cover it.
//
// A node keeps no height for a coin it holds, so a full-mode row reads as
// confirmed at height zero. Such a row names no height and no depth, because
// both would be invented.
func txState(tx *thunderpb.SidechainWalletTransaction, tipHeight uint32) string {
	switch {
	case !tx.Confirmed:
		return "pending"
	case tx.BlockHeight == 0:
		return "confirmed"
	}
	depth := 0
	if tipHeight >= tx.BlockHeight {
		depth = int(tipHeight-tx.BlockHeight) + 1
	}
	return fmt.Sprintf("height %d (%d confirmations)", tx.BlockHeight, depth)
}
