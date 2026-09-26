//go:build integration

package wallet_test

import (
	"context"
	"encoding/hex"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/btcsuite/btcd/chaincfg"
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

// Core holds the BIP47 notification key as a single key, and lists its unused
// address beside the receive addresses. A legacy receive request must never
// hand it out.
func TestCoreLegacyReceiveSkipsTheBip47Key(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()
	node := h.Nodes[0]

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	client := node.WalletClient

	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	gen, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
		Name:           "Legacy",
		CustomMnemonic: mnemonic,
		ScriptType:     "legacy",
	}))
	require.NoError(t, err)
	walletID := gen.Msg.WalletId
	requireCoreWallet(t, ctx, client, walletID)
	coreName := "wallet_" + walletID[:8]

	_, notification, err := bip47.DeriveOwnNotificationKey(
		hex.EncodeToString(wallet.MnemonicToSeed(mnemonic, "")), &chaincfg.RegressionNetParams)
	require.NoError(t, err)

	// The first read loads the Core wallet, and the backend imports the
	// notification key in the background. Its address is then the only
	// unused one Core lists.
	_, err = client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{WalletId: walletID}))
	require.NoError(t, err)
	require.Eventually(t, func() bool {
		info, err := node.CoreRPC.GetAddressInfo(ctx, coreName, notification.EncodeAddress())
		return err == nil && info.IsMine
	}, 2*time.Minute, time.Second)
	info, err := node.CoreRPC.GetAddressInfo(ctx, coreName, notification.EncodeAddress())
	require.NoError(t, err)
	require.NotContains(t, info.ParentDesc, "*")

	for range 3 {
		resp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{WalletId: walletID}))
		require.NoError(t, err)
		require.NotEqual(t, notification.EncodeAddress(), resp.Msg.Address)
		info, err := node.CoreRPC.GetAddressInfo(ctx, coreName, resp.Msg.Address)
		require.NoError(t, err)
		require.Contains(t, info.ParentDesc, "*", resp.Msg.Address)
	}
}
