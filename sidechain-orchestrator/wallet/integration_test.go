//go:build integration

package wallet_test

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
	// Use a fixed seed different from any wallet in the test to ensure truly watch-only.
	seed, err := hex.DecodeString("aaaa0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1faaaa")
	require.NoError(t, err)
	masterKey, err := bip32.NewMasterKey(seed)
	require.NoError(t, err)

	purpose, err := masterKey.NewChildKey(bip32.FirstHardenedChild + 84)
	require.NoError(t, err)
	coin, err := purpose.NewChildKey(bip32.FirstHardenedChild + 1) // testnet/regtest
	require.NoError(t, err)
	account, err := coin.NewChildKey(bip32.FirstHardenedChild + 0)
	require.NoError(t, err)

	// Get public key version
	pubKey := account.PublicKey()

	// Serialize and fix version bytes for tpub (0x043587CF)
	serialized, err := pubKey.Serialize()
	require.NoError(t, err)
	// Strip checksum (last 4 bytes of 82-byte serialization)
	raw := serialized[:78]
	copy(raw[0:4], []byte{0x04, 0x35, 0x87, 0xCF}) // tpub version
	result := wallet.Base58CheckEncode(raw)
	t.Logf("generated test tpub: %s", result[:20]+"...")
	return result
}

func TestWalletIntegration(t *testing.T) {
	h := testharness.New(t, 2)
	defer h.Close()

	nodeA := h.Nodes[0]
	nodeB := h.Nodes[1]

	// Connect A ↔ B for p2p.
	nodeA.ConnectTo(t, nodeB)

	// =========================================================================
	// Phase 1: Wallet Lifecycle
	// =========================================================================
	t.Run("Phase1_WalletLifecycle", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// Clean slate.
		_, err := client.DeleteAllWallets(ctx, connect.NewRequest(&pb.DeleteAllWalletsRequest{}))
		require.NoError(t, err, "DeleteAllWallets")

		// GenerateWallet → verify response.
		genResp, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "Wallet-A1",
		}))
		require.NoError(t, err)
		require.NotEmpty(t, genResp.Msg.WalletId)
		require.NotEmpty(t, genResp.Msg.Mnemonic)
		walletA1ID := genResp.Msg.WalletId
		t.Logf("generated wallet A1: %s", walletA1ID)

		// ListWallets → shows up.
		listResp, err := client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		require.Len(t, listResp.Msg.Wallets, 1)
		require.Equal(t, walletA1ID, listResp.Msg.Wallets[0].Id)

		// GetWalletStatus → has_wallet=true, unlocked=true.
		statusResp, err := client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.True(t, statusResp.Msg.HasWallet)
		require.True(t, statusResp.Msg.Unlocked)
		require.False(t, statusResp.Msg.Encrypted)

		// Create a second wallet and switch back.
		genResp2, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "Wallet-A2",
		}))
		require.NoError(t, err)
		walletA2ID := genResp2.Msg.WalletId

		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: walletA1ID}))
		require.NoError(t, err)

		statusResp, err = client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.Equal(t, walletA1ID, statusResp.Msg.ActiveWalletId)

		// UpdateWalletMetadata.
		_, err = client.UpdateWalletMetadata(ctx, connect.NewRequest(&pb.UpdateWalletMetadataRequest{
			WalletId: walletA1ID,
			Name:     "Wallet-A1-Renamed",
		}))
		require.NoError(t, err)

		// EncryptWallet.
		_, err = client.EncryptWallet(ctx, connect.NewRequest(&pb.EncryptWalletRequest{Password: "pass1"}))
		require.NoError(t, err)

		statusResp, err = client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.True(t, statusResp.Msg.Encrypted)

		// LockWallet.
		_, err = client.LockWallet(ctx, connect.NewRequest(&pb.LockWalletRequest{}))
		require.NoError(t, err)

		statusResp, err = client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.False(t, statusResp.Msg.Unlocked)

		// UnlockWallet.
		_, err = client.UnlockWallet(ctx, connect.NewRequest(&pb.UnlockWalletRequest{Password: "pass1"}))
		require.NoError(t, err)

		statusResp, err = client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.True(t, statusResp.Msg.Unlocked)

		// ChangePassword.
		_, err = client.ChangePassword(ctx, connect.NewRequest(&pb.ChangePasswordRequest{
			OldPassword: "pass1",
			NewPassword: "pass2",
		}))
		require.NoError(t, err)

		// Lock + unlock with new password.
		_, err = client.LockWallet(ctx, connect.NewRequest(&pb.LockWalletRequest{}))
		require.NoError(t, err)
		_, err = client.UnlockWallet(ctx, connect.NewRequest(&pb.UnlockWalletRequest{Password: "pass2"}))
		require.NoError(t, err)

		// RemoveEncryption.
		_, err = client.RemoveEncryption(ctx, connect.NewRequest(&pb.RemoveEncryptionRequest{Password: "pass2"}))
		require.NoError(t, err)

		statusResp, err = client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.False(t, statusResp.Msg.Encrypted)

		// DeleteWallet (the second one).
		_, err = client.DeleteWallet(ctx, connect.NewRequest(&pb.DeleteWalletRequest{WalletId: walletA2ID}))
		require.NoError(t, err)

		listResp, err = client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		require.Len(t, listResp.Msg.Wallets, 1)
	})

	// =========================================================================
	// Phase 2: Core Wallet Ops
	// =========================================================================
	t.Run("Phase2_CoreWalletOps", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// The first wallet from Phase 1 should still be active (type=enforcer).
		// Generate a new bitcoinCore wallet since the enforcer type doesn't
		// create a Core wallet via EnsureCoreWallets.
		genResp, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "Core-Wallet-A",
		}))
		require.NoError(t, err)
		_ = genResp.Msg.WalletId

		// EnsureCoreWallets → descriptor wallet created in Core.
		ensureResp, err := client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		require.NoError(t, err)
		require.Greater(t, ensureResp.Msg.SyncedCount, int32(0))

		// Switch to the bitcoinCore wallet.
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{
			WalletId: genResp.Msg.WalletId,
		}))
		require.NoError(t, err)

		// GetNewAddress → returns bcrt1... address.
		addrResp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		require.True(t, strings.HasPrefix(addrResp.Msg.Address, "bcrt1"), "expected bcrt1 prefix, got %s", addrResp.Msg.Address)
		addr := addrResp.Msg.Address

		// Mine 101 blocks to that address.
		err = nodeA.MineToAddress(ctx, 101, addr)
		require.NoError(t, err)

		// GetBalance → verify > 0 (poll on Windows where indexing is slow).
		nodeA.WaitForBalance(t)
		balResp, err := client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		require.Greater(t, balResp.Msg.ConfirmedSats, float64(0), "balance should be positive after mining")
		t.Logf("balance after mining: %f sats", balResp.Msg.ConfirmedSats)

		// ListTransactions → verify coinbase txs.
		txResp, err := client.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{Count: 10}))
		require.NoError(t, err)
		require.NotEmpty(t, txResp.Msg.Transactions)
		// At least one should be immature or generate.
		found := false
		for _, tx := range txResp.Msg.Transactions {
			if tx.Category == "immature" || tx.Category == "generate" {
				found = true
				break
			}
		}
		require.True(t, found, "expected at least one coinbase transaction")

		// ListUnspent → verify UTXOs exist.
		utxoResp, err := client.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{}))
		require.NoError(t, err)
		require.NotEmpty(t, utxoResp.Msg.Utxos)

		// ListReceiveAddresses → verify.
		rcvResp, err := client.ListReceiveAddresses(ctx, connect.NewRequest(&pb.ListReceiveAddressesRequest{}))
		require.NoError(t, err)
		require.NotEmpty(t, rcvResp.Msg.Addresses)

		// GetTransactionDetails on a coinbase tx.
		if len(txResp.Msg.Transactions) > 0 {
			txid := txResp.Msg.Transactions[0].Txid
			detailResp, err := client.GetTransactionDetails(ctx, connect.NewRequest(&pb.GetTransactionDetailsRequest{Txid: txid}))
			require.NoError(t, err)
			require.NotNil(t, detailResp.Msg.Transaction)
			require.NotEmpty(t, detailResp.Msg.RawHex)
		}
	})

	// =========================================================================
	// Phase 3: Cross-Node Sending
	// =========================================================================
	t.Run("Phase3_CrossNodeSending", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
		defer cancel()

		// Generate + fund wallet on B.
		addrB := nodeB.FundWallet(t)
		_ = addrB

		// Get a fresh address on B.
		addrBResp, err := nodeB.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		addrBRecv := addrBResp.Msg.Address

		// Send 1 BTC from A to B.
		sendResp, err := nodeA.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{addrBRecv: 100_000_000}, // 1 BTC in sats
		}))
		require.NoError(t, err)
		require.NotEmpty(t, sendResp.Msg.Txid)
		t.Logf("sent tx: %s", sendResp.Msg.Txid)

		// Mine 1 block on A.
		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		// Wait for B to sync.
		nodeA.WaitForSync(t, nodeB)

		// GetBalance on B → verify ~1 BTC (100_000_000 sats).
		balB, err := nodeB.WalletClient.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		// B had mining rewards + 1 BTC received. Just check the received tx shows up.
		txsB, err := nodeB.WalletClient.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{Count: 200}))
		require.NoError(t, err)
		foundReceive := false
		for _, tx := range txsB.Msg.Transactions {
			if tx.Category == "receive" && tx.AmountSats == 100_000_000 {
				foundReceive = true
				break
			}
		}
		require.True(t, foundReceive, "B should have a 1 BTC receive tx")
		t.Logf("B balance: %f sats (confirmed)", balB.Msg.ConfirmedSats)
	})

	// =========================================================================
	// Phase 4: Multiple Wallets
	// =========================================================================
	t.Run("Phase4_MultipleWallets", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// Create a second bitcoinCore wallet on A.
		gen2, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "Second-Core-Wallet",
		}))
		require.NoError(t, err)
		wallet2ID := gen2.Msg.WalletId

		// EnsureCoreWallets → both exist in Core.
		_, err = client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		require.NoError(t, err)

		// Get address on second wallet.
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: wallet2ID}))
		require.NoError(t, err)

		addrResp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		addr2 := addrResp.Msg.Address

		// Switch back to first Core wallet for sending.
		list, err := client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		var coreWalletID string
		for _, w := range list.Msg.Wallets {
			if w.WalletType == "bitcoinCore" && w.Id != wallet2ID {
				coreWalletID = w.Id
				break
			}
		}
		require.NotEmpty(t, coreWalletID, "should find the first bitcoinCore wallet")
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: coreWalletID}))
		require.NoError(t, err)

		// Send from first to second.
		_, err = client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{addr2: 50_000_000}, // 0.5 BTC
		}))
		require.NoError(t, err)

		// Mine 1 block.
		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		// Check balance on second wallet.
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: wallet2ID}))
		require.NoError(t, err)

		nodeA.WaitForBalance(t)
		balResp, err := client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		require.Greater(t, balResp.Msg.ConfirmedSats, float64(0), "second wallet should have received funds")
		t.Logf("second wallet balance: %f sats", balResp.Msg.ConfirmedSats)
	})

	// =========================================================================
	// Phase 5: Watch-Only
	// =========================================================================
	t.Run("Phase5_WatchOnly", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// Create watch-only wallet from an xpub descriptor.
		// Generate a fresh keypair so we get a valid tpub for regtest.
		woXpub := generateTestXpub(t)
		woResp, err := client.CreateWatchOnlyWallet(ctx, connect.NewRequest(&pb.CreateWatchOnlyWalletRequest{
			Name:             "WatchOnly-Test",
			XpubOrDescriptor: fmt.Sprintf("wpkh(%s/0/*)", woXpub),
			GradientJson:     `{"background_svg":""}`,
		}))
		require.NoError(t, err)
		woID := woResp.Msg.WalletId

		// EnsureCoreWallets.
		_, err = client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		require.NoError(t, err)

		// Switch to watch-only.
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: woID}))
		require.NoError(t, err)

		// Get an address from the watch-only wallet.
		woAddrResp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		woAddr := woAddrResp.Msg.Address
		require.True(t, strings.HasPrefix(woAddr, "bcrt1"))

		// Switch to funded wallet and send to watch-only address.
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
			Destinations: map[string]int64{woAddr: 10_000_000},
		}))
		require.NoError(t, err)

		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		// Switch to watch-only and check balance.
		_, err = client.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{WalletId: woID}))
		require.NoError(t, err)

		nodeA.WaitForBalance(t)
		balResp, err := client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		require.Greater(t, balResp.Msg.ConfirmedSats, float64(0), "watch-only should see balance")
		t.Logf("watch-only balance: %f sats", balResp.Msg.ConfirmedSats)

		// SendTransaction from watch-only → should FAIL (no private keys).
		_, err = client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{"bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080": 1_000_000},
		}))
		require.Error(t, err, "sending from watch-only wallet should fail")
		t.Logf("watch-only send correctly failed: %v", err)
	})

	// =========================================================================
	// Phase 6: Bump Fee
	// =========================================================================
	t.Run("Phase6_BumpFee", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// Switch to a funded bitcoinCore wallet.
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

		// Send a transaction.
		addrResp, err := client.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)

		sendResp, err := client.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{addrResp.Msg.Address: 5_000_000},
		}))
		require.NoError(t, err)
		origTxid := sendResp.Msg.Txid

		// BumpFee.
		bumpResp, err := client.BumpFee(ctx, connect.NewRequest(&pb.BumpFeeRequest{
			Txid: origTxid,
		}))
		require.NoError(t, err)
		require.NotEmpty(t, bumpResp.Msg.NewTxid)
		require.NotEqual(t, origTxid, bumpResp.Msg.NewTxid)
		t.Logf("bumped fee: %s → %s", origTxid, bumpResp.Msg.NewTxid)

		// Mine 1 block.
		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)
	})

	// =========================================================================
	// Phase 7: Wipe and Restart
	// =========================================================================
	t.Run("Phase7_WipeAndRestart", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()
		client := nodeA.WalletClient

		// DeleteAllWallets on A → wipes everything.
		_, err := client.DeleteAllWallets(ctx, connect.NewRequest(&pb.DeleteAllWalletsRequest{}))
		require.NoError(t, err)

		// GetWalletStatus → has_wallet=false.
		statusResp, err := client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		require.False(t, statusResp.Msg.HasWallet)

		// GenerateWallet → fresh start.
		genResp, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "Fresh-Wallet",
		}))
		require.NoError(t, err)
		require.NotEmpty(t, genResp.Msg.WalletId)

		// Generate a second (bitcoinCore type) so EnsureCoreWallets has something.
		gen2, err := client.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: "Fresh-Core",
		}))
		require.NoError(t, err)
		_ = gen2

		// EnsureCoreWallets → works from scratch.
		ensureResp, err := client.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		require.NoError(t, err)
		require.Greater(t, ensureResp.Msg.SyncedCount, int32(0))
	})
}
