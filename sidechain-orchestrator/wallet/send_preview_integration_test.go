//go:build integration

package wallet_test

import (
	"context"
	"math"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// smallCoinWallet funds a new Core wallet with count coins of previewCoinSats,
// and returns its id and an address of the funded wallet.
func smallCoinWallet(ctx context.Context, t *testing.T, node *testharness.Node, count int) (smallID, fundedAddress string) {
	t.Helper()
	client := node.WalletClient
	fundedAddress = node.FundWallet(t)
	node.WaitForBalance(t)
	wallets, err := client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
	require.NoError(t, err)
	var fundedID string
	for _, w := range wallets.Msg.Wallets {
		if w.Name == node.Name+"-core" {
			fundedID = w.Id
		}
	}
	require.NotEmpty(t, fundedID, "FundWallet mines to the Core wallet")

	gen, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{Name: "small-coins"}))
	require.NoError(t, err)
	smallID = gen.Msg.WalletId
	_, err = client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
	require.NoError(t, err)

	// The wallet hands out a new receive address only after the last one
	// received coins, so every coin gets its own send and block.
	for range count {
		addr, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{WalletId: smallID}))
		require.NoError(t, err)
		_, err = client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			WalletId:           fundedID,
			Destinations:       map[string]int64{addr.Msg.Address: previewCoinSats},
			FeeRateSatPerVbyte: 1,
		}))
		require.NoError(t, err)
		require.NoError(t, node.MineToAddress(ctx, 1, fundedAddress))
	}
	utxos, err := client.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{WalletId: smallID}))
	require.NoError(t, err)
	require.Len(t, utxos.Msg.Utxos, count)

	return smallID, fundedAddress
}

const (
	previewCoinCount = 25
	previewCoinSats  = int64(100_000)
)

// TestPreviewSendMatchesTheBroadcast gives a Core wallet many small coins,
// previews a send that needs most of them, and holds the preview to the
// transaction that Core builds, signs and puts in its mempool.
func TestPreviewSendMatchesTheBroadcast(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()

	node := h.Nodes[0]
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	client := node.WalletClient

	smallID, fundedAddress := smallCoinWallet(ctx, t, node, previewCoinCount)

	send := map[string]int64{fundedAddress: 20 * previewCoinSats}
	const rate = 2
	var preview *connect.Response[pb.PreviewSendResponse]
	var err error
	// The second preview reuses the change address of the first.
	for range 2 {
		preview, err = client.PreviewSend(ctx, connect.NewRequest(&pb.PreviewSendRequest{
			WalletId:           smallID,
			Destinations:       send,
			FeeRateSatPerVbyte: rate,
		}))
		require.NoError(t, err)
	}
	twoInputGuess := int64(rate * (10 + 2*148 + 2*34))
	assert.Greater(t, preview.Msg.FeeSats, twoInputGuess, "21 coins cost more than the two-coin guess")

	// Core picks coins at random, so the send pins the coins the preview priced.
	sent, err := client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           smallID,
		Destinations:       send,
		FeeRateSatPerVbyte: rate,
		RequiredInputs:     preview.Msg.Inputs,
	}))
	require.NoError(t, err)
	entry, err := node.CoreRPC.GetMempoolEntry(ctx, sent.Msg.Txid)
	require.NoError(t, err)

	assert.Equal(t, int64(math.Round(entry.Fees.Base*1e8)), preview.Msg.FeeSats, "the send pays the fee the preview showed")
	assert.GreaterOrEqual(t, preview.Msg.VsizeVbytes, entry.Vsize)
	assert.LessOrEqual(t, preview.Msg.VsizeVbytes-entry.Vsize, int64(previewCoinCount), "a signature is at most 1 byte under the size Core assumes")
}

// TestPreviewSendPricesTheBip47Notification previews a first payment to a
// payment code and holds the preview to both transactions in the mempool.
func TestPreviewSendPricesTheBip47Notification(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()

	node := h.Nodes[0]
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	client := node.WalletClient

	smallID, _ := smallCoinWallet(ctx, t, node, previewCoinCount)
	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), &chaincfg.RegressionNetParams)
	require.NoError(t, err)
	send := map[string]int64{recipient.Base58(): 5 * previewCoinSats}

	const rate = 2
	preview, err := client.PreviewSend(ctx, connect.NewRequest(&pb.PreviewSendRequest{
		WalletId:           smallID,
		Destinations:       send,
		FeeRateSatPerVbyte: rate,
	}))
	require.NoError(t, err)
	notification := preview.Msg.NotificationInput
	require.NotNil(t, notification, "a first payment publishes a notification")
	for _, in := range preview.Msg.Inputs {
		require.False(t, in.Txid == notification.Txid && in.Vout == notification.Vout,
			"the payment leaves the notification coin alone")
	}

	sent, err := client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           smallID,
		Destinations:       send,
		FeeRateSatPerVbyte: rate,
		RequiredInputs:     preview.Msg.Inputs,
		NotificationInput:  notification,
	}))
	require.NoError(t, err)

	notificationTxid, err := node.CoreRPC.TxSpendingPrevout(ctx, notification.Txid, int(notification.Vout))
	require.NoError(t, err)
	require.NotEmpty(t, notificationTxid, "the notification spends the coin the preview picked")
	require.NotEqual(t, sent.Msg.Txid, notificationTxid)

	fee := func(txid string) int64 {
		entry, err := node.CoreRPC.GetMempoolEntry(ctx, txid)
		require.NoError(t, err)
		return int64(math.Round(entry.Fees.Base * 1e8))
	}
	assert.Equal(t, preview.Msg.NotificationFeeSats, fee(notificationTxid))
	assert.Equal(t, preview.Msg.FeeSats, fee(sent.Msg.Txid))
}

// TestPreviewSendBip47OneCoinSendsBoth previews a first payment to a payment
// code from a one-coin wallet. The payment spends the notification change, so
// the preview is an estimate, and both transactions reach the mempool.
func TestPreviewSendBip47OneCoinSendsBoth(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()

	node := h.Nodes[0]
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	client := node.WalletClient

	smallID, _ := smallCoinWallet(ctx, t, node, 1)
	utxos, err := client.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{WalletId: smallID}))
	require.NoError(t, err)
	coin := utxos.Msg.Utxos[0]

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), &chaincfg.RegressionNetParams)
	require.NoError(t, err)
	send := map[string]int64{recipient.Base58(): previewCoinSats / 2}

	const rate = 2
	preview, err := client.PreviewSend(ctx, connect.NewRequest(&pb.PreviewSendRequest{
		WalletId:           smallID,
		Destinations:       send,
		FeeRateSatPerVbyte: rate,
	}))
	require.NoError(t, err)
	assert.True(t, preview.Msg.FeeIsEstimate)
	assert.Positive(t, preview.Msg.FeeSats)
	assert.Positive(t, preview.Msg.NotificationFeeSats)
	assert.Empty(t, preview.Msg.Inputs)
	assert.Nil(t, preview.Msg.NotificationInput)

	sent, err := client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           smallID,
		Destinations:       send,
		FeeRateSatPerVbyte: rate,
	}))
	require.NoError(t, err)

	notificationTxid, err := node.CoreRPC.TxSpendingPrevout(ctx, coin.Txid, int(coin.Vout))
	require.NoError(t, err)
	require.NotEmpty(t, notificationTxid, "the notification spends the only coin")
	require.NotEqual(t, sent.Msg.Txid, notificationTxid)
	for _, txid := range []string{notificationTxid, sent.Msg.Txid} {
		_, err := node.CoreRPC.GetMempoolEntry(ctx, txid)
		require.NoError(t, err, "transaction %s is in the mempool", txid)
	}
}
