//go:build integration

package integrationtest

import (
	"context"
	"encoding/hex"
	"fmt"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
	"github.com/tyler-smith/go-bip32"
)

// generateTestXpub creates a fresh BIP84 account-level tpub for watch-only testing.
func generateTestXpub(t *testing.T) string {
	t.Helper()
	seed, err := hex.DecodeString("bbbb0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1fbbbb")
	require.NoError(t, err)
	masterKey, err := bip32.NewMasterKey(seed)
	require.NoError(t, err)
	purpose, err := masterKey.NewChildKey(bip32.FirstHardenedChild + 84)
	require.NoError(t, err)
	coin, err := purpose.NewChildKey(bip32.FirstHardenedChild + 1)
	require.NoError(t, err)
	account, err := coin.NewChildKey(bip32.FirstHardenedChild + 0)
	require.NoError(t, err)
	pubKey := account.PublicKey()
	serialized, err := pubKey.Serialize()
	require.NoError(t, err)
	raw := serialized[:78]
	copy(raw[0:4], []byte{0x04, 0x35, 0x87, 0xCF})
	return wallet.Base58CheckEncode(raw)
}

// TestBitwindowWalletIntegration exercises the orchestrator's WalletManagerService
// through the same ConnectRPC layer that bitwindow's WalletEngine delegates to.
// This validates that the full gRPC stack works end-to-end with real regtest nodes.
//
// Run with:
//
//	cd bitwindow/server && go test -v -tags integration -run TestBitwindowWalletIntegration -timeout 10m ./integrationtest/
func TestBitwindowWalletIntegration(t *testing.T) {
	h := testharness.New(t, 2)
	defer h.Close()

	nodeA := h.Nodes[0]
	nodeB := h.Nodes[1]
	nodeA.ConnectTo(t, nodeB)

	// =========================================================================
	// Phase 1: Wallet via Orchestrator gRPC
	// =========================================================================
	t.Run("Phase1_WalletViaOrchestrator", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// GenerateWallet (enforcer).
		_, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "bw-enforcer",
		}))
		require.NoError(t, err)

		// GenerateWallet (bitcoinCore).
		genResp, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "bw-core",
		}))
		require.NoError(t, err)
		coreID := genResp.Msg.WalletId

		// EnsureCoreWallets.
		_, err = client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		require.NoError(t, err)

		// Switch to the bitcoinCore wallet.
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: coreID}))
		require.NoError(t, err)

		// GetNewAddress.
		addrResp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		require.True(t, strings.HasPrefix(addrResp.Msg.Address, "bcrt1"))

		// Mine blocks.
		err = nodeA.MineToAddress(ctx, 101, addrResp.Msg.Address)
		require.NoError(t, err)

		// GetBalance.
		bal, err := client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		require.Greater(t, bal.Msg.ConfirmedSats, float64(0))
		t.Logf("balance: %f sats", bal.Msg.ConfirmedSats)

		// SendTransaction cross-node.
		_ = nodeB.FundWallet(t)

		addrBResp, err := nodeB.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)

		sendResp, err := client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{addrBResp.Msg.Address: 50_000_000},
		}))
		require.NoError(t, err)
		require.NotEmpty(t, sendResp.Msg.Txid)
		t.Logf("sent tx: %s", sendResp.Msg.Txid)

		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		nodeA.WaitForSync(t, nodeB)

		// Verify on B side.
		txsB, err := nodeB.WalletClient.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{Count: 200}))
		require.NoError(t, err)
		foundReceive := false
		for _, tx := range txsB.Msg.Transactions {
			if tx.Category == "receive" && tx.AmountSats == 50_000_000 {
				foundReceive = true
				break
			}
		}
		require.True(t, foundReceive, "B should have a 0.5 BTC receive tx")
	})

	// =========================================================================
	// Phase 2: Watch-Only via Orchestrator
	// =========================================================================
	t.Run("Phase2_WatchOnly", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		woXpub := generateTestXpub(t)
		woResp, err := client.CreateWatchOnlyWallet(ctx, connect.NewRequest(&pb.CreateWatchOnlyWalletRequest{
			Name:             "bw-watch",
			XpubOrDescriptor: fmt.Sprintf("wpkh(%s/0/*)", woXpub),
			GradientJson:     `{"background_svg":""}`,
		}))
		require.NoError(t, err)
		woID := woResp.Msg.WalletId

		_, err = client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		require.NoError(t, err)

		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: woID}))
		require.NoError(t, err)

		addrResp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		require.True(t, strings.HasPrefix(addrResp.Msg.Address, "bcrt1"))

		// Fund from a Core wallet.
		list, err := client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		var fundedID string
		for _, w := range list.Msg.Wallets {
			if w.WalletType == "bitcoinCore" {
				fundedID = w.Id
				break
			}
		}
		require.NotEmpty(t, fundedID)
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: fundedID}))
		require.NoError(t, err)

		_, err = client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{addrResp.Msg.Address: 5_000_000},
		}))
		require.NoError(t, err)

		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: woID}))
		require.NoError(t, err)

		bal, err := client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		require.Greater(t, bal.Msg.ConfirmedSats, float64(0))
		t.Logf("watch-only balance: %f sats", bal.Msg.ConfirmedSats)

		// Send from watch-only should fail.
		_, err = client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{"bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080": 1_000_000},
		}))
		require.Error(t, err)
		t.Logf("watch-only send correctly failed: %v", err)
	})

	// =========================================================================
	// Phase 3: Seed Access (cheque engine dependency)
	// =========================================================================
	t.Run("Phase3_SeedAccess", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		seedResp, err := client.GetWalletSeed(ctx, connect.NewRequest(&pb.GetWalletSeedRequest{}))
		require.NoError(t, err)
		require.NotEmpty(t, seedResp.Msg.SeedHex)
		require.Len(t, seedResp.Msg.SeedHex, 128) // 64 bytes = 128 hex chars
		t.Logf("enforcer seed (first 16 chars): %s...", seedResp.Msg.SeedHex[:16])

		list, err := client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		require.NotEmpty(t, list.Msg.Wallets)

		seedResp2, err := client.GetWalletSeed(ctx, connect.NewRequest(&pb.GetWalletSeedRequest{
			WalletId: list.Msg.Wallets[0].Id,
		}))
		require.NoError(t, err)
		require.NotEmpty(t, seedResp2.Msg.SeedHex)
	})
}
