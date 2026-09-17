//go:build integration

package wallet_test

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/stretchr/testify/require"
)

// The receive table reads the Balance column off this RPC, and the coin list
// reads listunspent. A user read the two side by side and found every row
// disagreed, because Core reports gross lifetime receipts. This drives a real
// Core wallet and holds the two together.
func TestCoreReceiveBalancesMatchTheCoins(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()
	node := h.Nodes[0]
	node.FundWallet(t)
	node.WaitForBalance(t)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	client := node.WalletClient

	status, err := client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
	require.NoError(t, err)
	walletID := status.Msg.ActiveWalletId
	requireCoreWallet(t, ctx, client, walletID)

	checkAgrees := func(t *testing.T, stage string) {
		t.Helper()
		unspent, err := client.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{WalletId: walletID}))
		require.NoError(t, err)
		receive, err := client.ListReceiveAddresses(ctx, connect.NewRequest(&pb.ListReceiveAddressesRequest{WalletId: walletID}))
		require.NoError(t, err)

		coins := map[string]int64{}
		for _, u := range unspent.Msg.Utxos {
			coins[u.Address] += u.AmountSats
		}
		listed := map[string]bool{}
		for _, a := range receive.Msg.Addresses {
			listed[a.Address] = true
			require.Equal(t, coins[a.Address], a.AmountSats,
				"%s: address %s holds %d satoshis in the coin list", stage, a.Address, coins[a.Address])
		}
		for address, sats := range coins {
			require.True(t, listed[address],
				"%s: address %s holds %d satoshis but the receive list drops it", stage, address, sats)
		}
	}

	checkAgrees(t, "after the wallet is funded")

	// The spent and change states are unit-tested against every descriptor
	// shape in TestCoreReceiveListReportsCurrentBalance and
	// TestDescriptorIsChange. A send here adds no coverage and costs a
	// broadcast, which outruns the RPC client on a loaded runner.
}
