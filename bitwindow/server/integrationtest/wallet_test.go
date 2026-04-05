//go:build integration

package integrationtest

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	api_wallet "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/wallet"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	walletpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
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

// writeTestWalletJSON creates a wallet.json in walletDir with the given wallet ID and seed.
func writeTestWalletJSON(t *testing.T, walletDir, walletID, seedHex string) {
	t.Helper()

	walletData := map[string]any{
		"version":        1,
		"activeWalletId": walletID,
		"wallets": []map[string]any{
			{
				"id":          walletID,
				"name":        "Test Enforcer",
				"wallet_type": "enforcer",
				"master": map[string]any{
					"seed_hex": seedHex,
				},
				"l1": map[string]any{
					"mnemonic": "",
				},
			},
		},
	}

	data, err := json.MarshalIndent(walletData, "", "  ")
	require.NoError(t, err)

	err = os.WriteFile(filepath.Join(walletDir, "wallet.json"), data, 0600)
	require.NoError(t, err)
}

// importChequeDescriptor imports the cheque derivation path descriptor into the
// cheque_watch wallet in Bitcoin Core. This is normally done by ChequeEngine.Start()
// but in tests we do it explicitly.
func importChequeDescriptor(
	t *testing.T, ctx context.Context,
	bitcoind corerpc.BitcoinServiceClient,
	seedHex string, chainParams *chaincfg.Params,
) {
	t.Helper()

	seedBytes, err := hex.DecodeString(seedHex)
	require.NoError(t, err)

	masterKey, err := hdkeychain.NewMaster(seedBytes, chainParams)
	require.NoError(t, err)

	// m/44'/0'/999' (cheque account)
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 44)
	require.NoError(t, err)
	coinType, err := purpose.Derive(hdkeychain.HardenedKeyStart + 0)
	require.NoError(t, err)
	chequeAcct, err := coinType.Derive(hdkeychain.HardenedKeyStart + 999)
	require.NoError(t, err)

	xpub := chequeAcct.String()
	descriptorNoChecksum := fmt.Sprintf("wpkh(%s/*)", xpub)

	// Get Bitcoin Core to add the checksum.
	descInfo, err := bitcoind.GetDescriptorInfo(ctx, connect.NewRequest(&corepb.GetDescriptorInfoRequest{
		Descriptor_: descriptorNoChecksum,
	}))
	require.NoError(t, err)

	descriptor := descInfo.Msg.Descriptor_

	resp, err := bitcoind.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet: engines.ChequeWalletName,
		Requests: []*corepb.ImportDescriptorsRequest_Request{
			{
				Descriptor_: descriptor,
				Active:      true,
				RangeStart:  0,
				RangeEnd:    100,
				Timestamp:   nil,
				Internal:    false,
			},
		},
	}))
	require.NoError(t, err)
	require.NotEmpty(t, resp.Msg.Responses)
	require.True(t, resp.Msg.Responses[0].Success, "descriptor import should succeed")
	t.Logf("imported cheque descriptor into %s", engines.ChequeWalletName)
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

	// =========================================================================
	// Phase 4: Cheques
	// =========================================================================
	t.Run("Phase4_Cheques", func(t *testing.T) {
		ctx, cancel := context.WithTimeout(context.Background(), 180*time.Second)
		defer cancel()

		// --- Wire up bitwindow cheque infrastructure for node A ---

		// Get the enforcer wallet ID and seed from orchestrator.
		listResp, err := nodeA.WalletClient.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		require.NotEmpty(t, listResp.Msg.Wallets)

		// Find the enforcer wallet (first wallet).
		enforcerWallet := listResp.Msg.Wallets[0]
		enforcerID := enforcerWallet.Id
		t.Logf("enforcer wallet ID: %s", enforcerID)

		seedResp, err := nodeA.WalletClient.GetWalletSeed(ctx, connect.NewRequest(&pb.GetWalletSeedRequest{
			WalletId: enforcerID,
		}))
		require.NoError(t, err)
		enforcerSeed := seedResp.Msg.SeedHex
		require.NotEmpty(t, enforcerSeed)

		// Create wallet.json for WalletEngine.
		walletDirA := t.TempDir()
		writeTestWalletJSON(t, walletDirA, enforcerID, enforcerSeed)

		// Create btc-buf bitcoind client pointing at node A's RPC.
		bitcoindA, err := coreproxy.NewBitcoind(
			ctx,
			fmt.Sprintf("127.0.0.1:%d", nodeA.BitcoindRPCPort),
			"test", "test",
		)
		require.NoError(t, err)

		bitcoindSvcA := service.New("bitcoind-A", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return bitcoindA, nil
		})

		// Create WalletEngine.
		walletEngineA := engines.NewWalletEngine(
			func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return bitcoindA, nil },
			nil, // no enforcer connector needed for cheques
			walletDirA,
			&chaincfg.RegressionNetParams,
		)
		walletEngineA.SetOrchestratorClient(nodeA.WalletClient)

		// Create ChequeEngine.
		chequeEngineA := engines.NewChequeEngine(walletEngineA, &chaincfg.RegressionNetParams, bitcoindSvcA)

		// Create SQLite DB for cheques.
		dbA := database.Test(t)

		// Create bitwindow wallet Server.
		serverA := api_wallet.New(
			ctx, dbA, bitcoindSvcA,
			nil, // no enforcer wallet service
			nil, // no crypto service
			chequeEngineA, walletEngineA, walletDirA,
		)

		// --- Step 1: CreateCheque ---
		const chequeAmountSats = 1_000_000 // 0.01 BTC
		createResp, err := serverA.CreateCheque(ctx, connect.NewRequest(&walletpb.CreateChequeRequest{
			WalletId:           enforcerID,
			ExpectedAmountSats: chequeAmountSats,
		}))
		require.NoError(t, err)
		chequeID := createResp.Msg.Id
		chequeAddr := createResp.Msg.Address
		require.NotZero(t, chequeID)
		require.NotEmpty(t, chequeAddr)
		require.True(t, strings.HasPrefix(chequeAddr, "bcrt1"), "expected bcrt1 prefix, got %s", chequeAddr)
		t.Logf("created cheque #%d at %s (derivation index %d)", chequeID, chequeAddr, createResp.Msg.DerivationIndex)

		// --- Step 2: GetCheque → verify not yet funded ---
		getResp, err := serverA.GetCheque(ctx, connect.NewRequest(&walletpb.GetChequeRequest{
			WalletId: enforcerID,
			Id:       chequeID,
		}))
		require.NoError(t, err)
		require.Equal(t, chequeAddr, getResp.Msg.Cheque.Address)
		require.Equal(t, uint64(chequeAmountSats), getResp.Msg.Cheque.ExpectedAmountSats)
		require.False(t, getResp.Msg.Cheque.Funded, "cheque should not be funded yet")

		// --- Step 3: ListCheques → shows up ---
		listChequesResp, err := serverA.ListCheques(ctx, connect.NewRequest(&walletpb.ListChequesRequest{
			WalletId: enforcerID,
		}))
		require.NoError(t, err)
		require.Len(t, listChequesResp.Msg.Cheques, 1)
		require.Equal(t, chequeID, listChequesResp.Msg.Cheques[0].Id)

		// --- Step 4: GetChequePrivateKey → valid WIF ---
		pkResp, err := serverA.GetChequePrivateKey(ctx, connect.NewRequest(&walletpb.GetChequePrivateKeyRequest{
			WalletId: enforcerID,
			Id:       chequeID,
		}))
		require.NoError(t, err)
		wifKey := pkResp.Msg.PrivateKeyWif
		require.NotEmpty(t, wifKey)
		t.Logf("cheque WIF: %s...%s", wifKey[:8], wifKey[len(wifKey)-4:])

		// --- Step 5: Fund the cheque by sending BTC to the cheque address ---
		// Use orchestrator to send from node A's funded wallet.
		// Make sure A's bitcoinCore wallet is active.
		listWallets, err := nodeA.WalletClient.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		var coreWalletID string
		for _, w := range listWallets.Msg.Wallets {
			if w.WalletType == "bitcoinCore" {
				coreWalletID = w.Id
				break
			}
		}
		require.NotEmpty(t, coreWalletID, "should have a bitcoinCore wallet from Phase 1")

		_, err = nodeA.WalletClient.SwitchWallet(ctx, connect.NewRequest(&pb.SwitchWalletRequest{
			WalletId: coreWalletID,
		}))
		require.NoError(t, err)

		sendResp, err := nodeA.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{chequeAddr: chequeAmountSats},
		}))
		require.NoError(t, err)
		require.NotEmpty(t, sendResp.Msg.Txid)
		t.Logf("funded cheque with tx: %s", sendResp.Msg.Txid)

		// --- Step 6a: Set up cheque_watch wallet BEFORE mining ---
		// The cheque_watch wallet needs the cheque descriptor imported.
		// Import it explicitly since we don't run ChequeEngine.Start().

		// First ensure the cheque_watch wallet exists in Bitcoin Core.
		_, err = bitcoindA.CreateWallet(ctx, connect.NewRequest(
			&corepb.CreateWalletRequest{
				Name:               engines.ChequeWalletName,
				DisablePrivateKeys: true,
				Blank:              true,
			},
		))
		// Ignore "already exists" errors.
		if err != nil && !strings.Contains(err.Error(), "already exists") && !strings.Contains(err.Error(), "Database already exists") {
			require.NoError(t, err)
		}

		// Import the cheque descriptor for the enforcer wallet.
		importChequeDescriptor(t, ctx, bitcoindA, enforcerSeed, &chaincfg.RegressionNetParams)

		// --- Step 6b: CheckChequeFunding → funded but UNCONFIRMED ---
		fundingRespUnconf, err := serverA.CheckChequeFunding(ctx, connect.NewRequest(&walletpb.CheckChequeFundingRequest{
			WalletId: enforcerID,
			Id:       chequeID,
		}))
		require.NoError(t, err)
		require.True(t, fundingRespUnconf.Msg.Funded, "cheque should be funded (unconfirmed)")
		require.Equal(t, uint64(chequeAmountSats), fundingRespUnconf.Msg.ActualAmountSats)
		require.NotEmpty(t, fundingRespUnconf.Msg.FundedTxids)
		require.Equal(t, uint32(0), fundingRespUnconf.Msg.MinConfirmations, "funding should be unconfirmed (0 confirmations)")
		t.Logf("cheque funded (unconfirmed): %d sats, min_confirmations=%d, txids: %v",
			fundingRespUnconf.Msg.ActualAmountSats, fundingRespUnconf.Msg.MinConfirmations, fundingRespUnconf.Msg.FundedTxids)

		// --- Step 6c: Mine a block and verify confirmations ---
		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		fundingResp, err := serverA.CheckChequeFunding(ctx, connect.NewRequest(&walletpb.CheckChequeFundingRequest{
			WalletId: enforcerID,
			Id:       chequeID,
		}))
		require.NoError(t, err)
		require.True(t, fundingResp.Msg.Funded, "cheque should be funded")
		require.Equal(t, uint64(chequeAmountSats), fundingResp.Msg.ActualAmountSats)
		require.NotEmpty(t, fundingResp.Msg.FundedTxids)
		require.GreaterOrEqual(t, fundingResp.Msg.MinConfirmations, uint32(1), "funding should have at least 1 confirmation after mining")
		t.Logf("cheque funded (confirmed): %d sats, min_confirmations=%d, txids: %v",
			fundingResp.Msg.ActualAmountSats, fundingResp.Msg.MinConfirmations, fundingResp.Msg.FundedTxids)

		// --- Step 7: SweepCheque on node B ---
		// Set up bitwindow infrastructure for node B.
		listRespB, err := nodeB.WalletClient.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
		require.NoError(t, err)
		require.NotEmpty(t, listRespB.Msg.Wallets)

		// Get a destination address on B.
		destAddrResp, err := nodeB.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)
		destAddr := destAddrResp.Msg.Address
		t.Logf("sweep destination on B: %s", destAddr)

		// Create btc-buf bitcoind client for node B.
		bitcoindB, err := coreproxy.NewBitcoind(
			ctx,
			fmt.Sprintf("127.0.0.1:%d", nodeB.BitcoindRPCPort),
			"test", "test",
		)
		require.NoError(t, err)

		bitcoindSvcB := service.New("bitcoind-B", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return bitcoindB, nil
		})

		// Create a wallet.json and WalletEngine for B using B's enforcer wallet.
		enforcerWalletB := listRespB.Msg.Wallets[0]
		enforcerIDB := enforcerWalletB.Id
		seedRespB, err := nodeB.WalletClient.GetWalletSeed(ctx, connect.NewRequest(&pb.GetWalletSeedRequest{
			WalletId: enforcerIDB,
		}))
		require.NoError(t, err)

		walletDirB := t.TempDir()
		writeTestWalletJSON(t, walletDirB, enforcerIDB, seedRespB.Msg.SeedHex)

		walletEngineB := engines.NewWalletEngine(
			func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return bitcoindB, nil },
			nil,
			walletDirB,
			&chaincfg.RegressionNetParams,
		)
		walletEngineB.SetOrchestratorClient(nodeB.WalletClient)

		chequeEngineB := engines.NewChequeEngine(walletEngineB, &chaincfg.RegressionNetParams, bitcoindSvcB)
		dbB := database.Test(t)

		serverB := api_wallet.New(
			ctx, dbB, bitcoindSvcB,
			nil, nil,
			chequeEngineB, walletEngineB, walletDirB,
		)

		// Ensure the cheque_watch wallet exists on B's Bitcoin Core too.
		_, err = bitcoindB.CreateWallet(ctx, connect.NewRequest(
			&corepb.CreateWalletRequest{
				Name:               engines.ChequeWalletName,
				DisablePrivateKeys: true,
				Blank:              true,
			},
		))
		if err != nil && !strings.Contains(err.Error(), "already exists") && !strings.Contains(err.Error(), "Database already exists") {
			require.NoError(t, err)
		}

		// Import cheque descriptor on B so it can see the cheque UTXO.
		importChequeDescriptor(t, ctx, bitcoindB, enforcerSeed, &chaincfg.RegressionNetParams)

		// Sync B to see A's block.
		nodeA.WaitForSync(t, nodeB)

		// SweepCheque: use the cheque's WIF to sweep funds to B's address.
		sweepResp, err := serverB.SweepCheque(ctx, connect.NewRequest(&walletpb.SweepChequeRequest{
			WalletId:           enforcerIDB,
			PrivateKeyWif:      wifKey,
			DestinationAddress: destAddr,
			FeeSatPerVbyte:     2,
		}))
		require.NoError(t, err)
		require.NotEmpty(t, sweepResp.Msg.Txid)
		require.Greater(t, sweepResp.Msg.AmountSats, uint64(0))
		t.Logf("swept cheque: txid=%s, amount=%d sats", sweepResp.Msg.Txid, sweepResp.Msg.AmountSats)

		// --- Step 8: Mine a block and verify B received funds ---
		// Mine on B so the sweep tx (which is in B's mempool) gets included.
		err = nodeB.Mine(ctx, t, 1)
		require.NoError(t, err)
		nodeB.WaitForSync(t, nodeA)

		// Verify B got the funds by checking balance increase.
		balB, err := nodeB.WalletClient.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		require.NoError(t, err)
		t.Logf("B balance after sweep: %f sats", balB.Msg.ConfirmedSats)

		// The sweep tx should appear in B's transactions.
		txsB, err := nodeB.WalletClient.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{Count: 200}))
		require.NoError(t, err)
		foundSweep := false
		for _, tx := range txsB.Msg.Transactions {
			if tx.Category == "receive" && tx.AmountSats > 0 && tx.AmountSats < chequeAmountSats {
				// Sweep amount = chequeAmount - fee, so it should be slightly less.
				foundSweep = true
				t.Logf("found sweep receive tx: %s (%d sats)", tx.Txid, tx.AmountSats)
				break
			}
		}
		require.True(t, foundSweep, "B should have received the swept cheque funds")

		// --- Step 9: DeleteCheque ---
		// Mark the cheque as swept first (the sweep was done via B, not A's server).
		// CheckChequeFunding on A should show no UTXOs now (they were swept).
		fundingResp2, err := serverA.CheckChequeFunding(ctx, connect.NewRequest(&walletpb.CheckChequeFundingRequest{
			WalletId: enforcerID,
			Id:       chequeID,
		}))
		require.NoError(t, err)
		// After sweep, UTXOs are gone, so funded should be false.
		// The cheque was previously funded but now swept externally.
		t.Logf("post-sweep funding check: funded=%t", fundingResp2.Msg.Funded)

		// Delete the cheque (it was swept, so deletion should work).
		_, err = serverA.DeleteCheque(ctx, connect.NewRequest(&walletpb.DeleteChequeRequest{
			WalletId: enforcerID,
			Id:       chequeID,
		}))
		require.NoError(t, err)

		// Verify it's gone.
		listChequesResp2, err := serverA.ListCheques(ctx, connect.NewRequest(&walletpb.ListChequesRequest{
			WalletId: enforcerID,
		}))
		require.NoError(t, err)
		require.Empty(t, listChequesResp2.Msg.Cheques, "cheque list should be empty after deletion")
		t.Log("cheque deleted successfully")

		// --- Step 10: Zero-conf sweep test ---
		// Create a new cheque, fund it without mining, and sweep immediately.
		// This verifies users can claim cheques before funding confirms.
		t.Log("--- Zero-conf sweep test ---")

		createResp2, err := serverA.CreateCheque(ctx, connect.NewRequest(&walletpb.CreateChequeRequest{
			WalletId:           enforcerID,
			ExpectedAmountSats: chequeAmountSats,
		}))
		require.NoError(t, err)
		chequeID2 := createResp2.Msg.Id
		chequeAddr2 := createResp2.Msg.Address
		require.NotZero(t, chequeID2)
		t.Logf("created zero-conf cheque #%d at %s", chequeID2, chequeAddr2)

		// Get the private key for the new cheque.
		pkResp2, err := serverA.GetChequePrivateKey(ctx, connect.NewRequest(&walletpb.GetChequePrivateKeyRequest{
			WalletId: enforcerID,
			Id:       chequeID2,
		}))
		require.NoError(t, err)
		wifKey2 := pkResp2.Msg.PrivateKeyWif

		// Fund the cheque — do NOT mine.
		sendResp2, err := nodeA.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{chequeAddr2: chequeAmountSats},
		}))
		require.NoError(t, err)
		t.Logf("funded zero-conf cheque with tx: %s (unmined)", sendResp2.Msg.Txid)

		// CheckChequeFunding → funded but unconfirmed.
		// Poll for unconfirmed funding — Bitcoin Core may take a moment to
		// index the unconfirmed UTXO in the watch wallet (especially on Windows).
		var fundingResp3 *connect.Response[walletpb.CheckChequeFundingResponse]
		for i := 0; i < 10; i++ {
			fundingResp3, err = serverA.CheckChequeFunding(ctx, connect.NewRequest(&walletpb.CheckChequeFundingRequest{
				WalletId: enforcerID,
				Id:       chequeID2,
			}))
			require.NoError(t, err)
			if fundingResp3.Msg.Funded {
				break
			}
			time.Sleep(500 * time.Millisecond)
		}
		require.True(t, fundingResp3.Msg.Funded, "zero-conf cheque should be funded")
		require.Equal(t, uint32(0), fundingResp3.Msg.MinConfirmations, "zero-conf cheque should have 0 confirmations")
		t.Logf("zero-conf cheque funded: %d sats, min_confirmations=%d",
			fundingResp3.Msg.ActualAmountSats, fundingResp3.Msg.MinConfirmations)

		// Import cheque descriptor on B (already done above, but the new cheque
		// uses the same HD path so the existing descriptor covers it).

		// SweepCheque with zero confirmations — should succeed.
		// Zero-conf sweep: sweep from A itself (same node sees its own mempool).
		// Cross-node mempool relay in regtest is unreliable for unconfirmed txs.
		destAddrA2, err := nodeA.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
		require.NoError(t, err)

		sweepResp2, err := serverA.SweepCheque(ctx, connect.NewRequest(&walletpb.SweepChequeRequest{
			WalletId:           enforcerID,
			PrivateKeyWif:      wifKey2,
			DestinationAddress: destAddrA2.Msg.Address,
			FeeSatPerVbyte:     2,
		}))
		require.NoError(t, err)
		require.NotEmpty(t, sweepResp2.Msg.Txid)
		require.Greater(t, sweepResp2.Msg.AmountSats, uint64(0))
		t.Logf("zero-conf sweep succeeded: txid=%s, amount=%d sats", sweepResp2.Msg.Txid, sweepResp2.Msg.AmountSats)

		// Mine a block to confirm the sweep.
		err = nodeA.Mine(ctx, t, 1)
		require.NoError(t, err)

		// Verify A received the swept funds back (same node, zero-conf sweep).
		txsA2, err := nodeA.WalletClient.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{Count: 200}))
		require.NoError(t, err)
		foundZeroConfSweep := false
		for _, tx := range txsA2.Msg.Transactions {
			if tx.Txid == sweepResp2.Msg.Txid ||
				(tx.Category == "receive" && tx.Address == destAddrA2.Msg.Address) {
				foundZeroConfSweep = true
				t.Logf("found zero-conf sweep tx: %s (%d sats, confirmations=%d)",
					tx.Txid, tx.AmountSats, tx.Confirmations)
				break
			}
		}
		require.True(t, foundZeroConfSweep, "A should have received the zero-conf swept cheque funds")
		t.Log("zero-conf sweep test passed")
	})
}
