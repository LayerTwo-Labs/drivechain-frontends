//go:build integration

package orchestrator_test

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1/bmmv1connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	zpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1/zsidev1connect"
	"github.com/stretchr/testify/require"
)

const (
	zsideSlot    = 98
	zsideRPCPort = 6098
	zsideP2PPort = 4098

	enforcerRPCPort = 8122

	// thunder-orchard spends a note only once it is this many checkpoints old.
	zsideAnchorDepth = 3

	// A block template pays its fees back to the wallet, so a transparent
	// balance can move by the fees of the block that confirms it.
	zsideFeeSlack = 10_000
)

// TestZSideWallet drives every zSide wallet flow through drivechaind's
// ZSideService, the Connect API the zSide app calls, against a real
// thunder-orchard node on regtest.
//
// Run: ZSIDE_BIN=... ZSIDE_MAINCHAIN_BITCOIND=... BIP300301_ENFORCER=... \
//
//	go test -tags integration -run TestZSide -v -timeout 20m .
func TestZSideWallet(t *testing.T) {
	zsideBin := os.Getenv("ZSIDE_BIN")
	bitcoind := os.Getenv("ZSIDE_MAINCHAIN_BITCOIND")
	enforcerBin := os.Getenv("BIP300301_ENFORCER")
	if zsideBin == "" || bitcoind == "" || enforcerBin == "" {
		t.Skip("set ZSIDE_BIN, ZSIDE_MAINCHAIN_BITCOIND and BIP300301_ENFORCER to run")
	}

	requirePortsFree(t, mainchainRPCPort, mainchainZMQPort, enforcerPort,
		zsideRPCPort, zsideP2PPort, orchestratorPort, enforcerRPCPort)

	orchBin := buildDrivechaind(t)

	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	ctx, cancel := context.WithTimeout(context.Background(), 18*time.Minute)
	defer cancel()

	// The deposit pays an OP_DRIVECHAIN treasury output, which stock Core does
	// not relay as standard.
	mainDir, enforcer := startMainchain(ctx, t, home, bitcoind, enforcerBin, "-acceptnonstdtxn=1")
	activateSlot(ctx, t, enforcer, zsideSlot, "zSide")

	zsideDir := config.ZSideDirs.DatadirNetwork(config.NetworkRegtest, "")
	require.NoError(t, os.MkdirAll(zsideDir, 0o700))
	startProcess(t, "zside", zsideBin,
		"--headless",
		"--network=regtest",
		"--datadir="+zsideDir,
		fmt.Sprintf("--mainchain-grpc-url=http://127.0.0.1:%d", enforcerPort),
		fmt.Sprintf("--rpc-addr=127.0.0.1:%d", zsideRPCPort),
		fmt.Sprintf("--private-rpc-addr=127.0.0.1:%d", zsideRPCPort),
		fmt.Sprintf("--net-addr=127.0.0.1:%d", zsideP2PPort),
	)

	startOrchestrator(t, orchBin, home, mainDir)
	httpClient := &http.Client{Timeout: 120 * time.Second}
	orchURL := fmt.Sprintf("http://127.0.0.1:%d", orchestratorPort)
	wallets := walletmanagerv1connect.NewWalletManagerServiceClient(connect.NewClient(connecthttp.NewTransport(httpClient, orchURL, connecthttp.WithReadMaxBytes(0))))
	bmm := bmmv1connect.NewBMMServiceClient(connect.NewClient(connecthttp.NewTransport(httpClient, orchURL, connecthttp.WithReadMaxBytes(0))))
	zside := zsidev1connect.NewZSideServiceClient(connect.NewClient(connecthttp.NewTransport(httpClient, orchURL, connecthttp.WithReadMaxBytes(0))))
	waitFor(t, 60*time.Second, "drivechaind", func() bool {
		_, err := wallets.GetWalletStatus(ctx, &wmpb.GetWalletStatusRequest{})
		return err == nil
	})
	waitFor(t, 90*time.Second, "zside through drivechaind", func() bool {
		_, err := zside.GetBlockCount(ctx, &zpb.GetBlockCountRequest{})
		return err == nil
	})

	mnemonic, err := zside.GenerateMnemonic(ctx, &zpb.GenerateMnemonicRequest{})
	require.NoError(t, err, "generate mnemonic")
	_, err = zside.SetSeedFromMnemonic(ctx, &zpb.SetSeedFromMnemonicRequest{
		Mnemonic: mnemonic.Mnemonic,
	})
	require.NoError(t, err, "set seed")

	// Only a Bitcoin Core wallet can build the bare scriptPubKey an M8 needs.
	generateWallet(ctx, t, wallets, "enforcer")
	coreWallet := generateWallet(ctx, t, wallets, "core")
	_, err = wallets.SwitchWallet(ctx, &wmpb.SwitchWalletRequest{WalletId: coreWallet})
	require.NoError(t, err)
	mainAddr, err := wallets.GetNewAddress(ctx, &wmpb.GetNewAddressRequest{})
	require.NoError(t, err)
	mineMainchain(ctx, t, enforcer, 150, mainAddr.Address)
	waitFor(t, 60*time.Second, "bidding funds", func() bool {
		bal, err := wallets.GetBalance(ctx, &wmpb.GetBalanceRequest{})
		return err == nil && bal.ConfirmedSats > 0
	})

	mainchain := newCoreRPC(t, filepath.Join(mainDir, "regtest"), mainchainRPCPort)
	height := func(t *testing.T) int64 {
		t.Helper()
		resp, err := zside.GetBlockCount(ctx, &zpb.GetBlockCountRequest{})
		require.NoError(t, err)
		return resp.Count
	}
	blindMergeMine := func(t *testing.T) {
		t.Helper()
		before := height(t)
		bid, err := bmm.CreateBid(ctx, &bmmpb.CreateBidRequest{
			Sidechain: orchpb.BinaryType_BINARY_TYPE_ZSIDE,
			BidSats:   1000,
		})
		require.NoError(t, err, "create bid")
		require.NotEmpty(t, bid.BmmTxid)
		mineMainchain(ctx, t, enforcer, 1, mainAddr.Address)
		// The node lists no inclusion for a mainchain block it was not given, so
		// the test names it, as the BMM engine does.
		var included string
		require.NoError(t, mainchain.call(ctx, "getbestblockhash", nil, &included))

		deadline := time.Now().Add(60 * time.Second)
		for {
			resp, err := bmm.ConnectBid(ctx, &bmmpb.ConnectBidRequest{
				Sidechain:     orchpb.BinaryType_BINARY_TYPE_ZSIDE,
				CriticalHash:  bid.CriticalHash,
				BlockJson:     bid.BlockJson,
				MainBlockHash: included,
			})
			require.NoError(t, err, "connect bid %s", bid.CriticalHash)
			if resp.Connected {
				break
			}
			if time.Now().After(deadline) {
				t.Fatalf("bid %s for %s in block %s never connected", bid.BmmTxid, bid.CriticalHash, included)
			}
			time.Sleep(time.Second)
		}
		require.Equal(t, before+1, height(t), "the bid must extend the zSide chain")
	}
	balance := func(t *testing.T) *zpb.GetBalanceResponse {
		t.Helper()
		resp, err := zside.GetBalance(ctx, &zpb.GetBalanceRequest{})
		require.NoError(t, err)
		t.Logf("balance: shielded %d, transparent %d", resp.TotalShieldedSats, resp.TotalTransparentSats)
		return resp
	}

	// A transaction no block can take would sit in every later template.
	dropOnFailure := func(t *testing.T, txid string) {
		if !t.Failed() {
			return
		}
		_, err := zside.RemoveFromMempool(ctx, &zpb.RemoveFromMempoolRequest{Txid: txid})
		if err != nil {
			t.Errorf("remove %s from the mempool: %v", txid, err)
		}
	}

	const (
		depositSats  = 50_000_000
		shieldSats   = 10_000_000
		moveSats     = 1_000_000
		unshieldSats = 2_000_000
		withdrawSats = 5_000_000
		feeSats      = 1_000
	)

	t.Run("bmm", func(t *testing.T) {
		require.Zero(t, height(t), "zSide should start empty")
		for range 3 {
			blindMergeMine(t)
		}
	})

	t.Run("deposit", func(t *testing.T) {
		addr, err := zside.GetNewTransparentAddress(ctx, &zpb.GetNewTransparentAddressRequest{})
		require.NoError(t, err)
		deposit, err := wallets.CreateDeposit(ctx, &wmpb.CreateDepositRequest{
			Slot:        zsideSlot,
			Destination: formatDepositAddress(addr.Address, zsideSlot),
			AmountSats:  depositSats,
			FeeSats:     10_000,
		})
		require.NoError(t, err, "create deposit")
		require.NotEmpty(t, deposit.Txid)

		mineMainchain(ctx, t, enforcer, 1, mainAddr.Address)
		blindMergeMine(t)
		require.EqualValues(t, depositSats, balance(t).TotalTransparentSats)
	})

	// The wallet spends only confirmed coins, so each transfer gets its own block.
	t.Run("transparent transfer", func(t *testing.T) {
		before := balance(t)
		dest, err := zside.GetNewTransparentAddress(ctx, &zpb.GetNewTransparentAddressRequest{})
		require.NoError(t, err)
		transfer, err := zside.TransparentTransfer(ctx, &zpb.TransparentTransferRequest{
			Address: dest.Address, AmountSats: moveSats, FeeSats: feeSats,
		})
		require.NoError(t, err, "transparent transfer")
		defer dropOnFailure(t, transfer.Txid)
		blindMergeMine(t)
		require.InDelta(t, before.TotalTransparentSats-feeSats, balance(t).TotalTransparentSats, zsideFeeSlack)
	})

	t.Run("transfer", func(t *testing.T) {
		before := balance(t)
		dest, err := zside.GetNewTransparentAddress(ctx, &zpb.GetNewTransparentAddressRequest{})
		require.NoError(t, err)
		transfer, err := zside.Transfer(ctx, &zpb.TransferRequest{
			Address: dest.Address, AmountSats: moveSats, FeeSats: feeSats,
		})
		require.NoError(t, err, "transfer")
		defer dropOnFailure(t, transfer.Txid)
		coins, err := zside.GetWalletUtxos(ctx, &zpb.GetWalletUtxosRequest{})
		require.NoError(t, err, "wallet coins with a transfer in the mempool")
		require.Contains(t, coins.UtxosJson, `"confirmed":false`, "the change of the transfer waits in the mempool")
		blindMergeMine(t)
		require.InDelta(t, before.TotalTransparentSats-feeSats, balance(t).TotalTransparentSats, zsideFeeSlack)
	})

	t.Run("withdraw", func(t *testing.T) {
		dest, err := wallets.GetNewAddress(ctx, &wmpb.GetNewAddressRequest{})
		require.NoError(t, err)
		withdrawal, err := zside.Withdraw(ctx, &zpb.WithdrawRequest{
			Address: dest.Address, AmountSats: withdrawSats, SideFeeSats: feeSats, MainFeeSats: 10_000,
		})
		require.NoError(t, err, "withdraw")
		defer dropOnFailure(t, withdrawal.Txid)

		// The node bundles withdrawals only at some heights, so mine until it does.
		for range 12 {
			blindMergeMine(t)
			bundle, err := zside.GetPendingWithdrawalBundle(ctx, &zpb.GetPendingWithdrawalBundleRequest{})
			require.NoError(t, err)
			if bundle.BundleJson != "" && bundle.BundleJson != "null" {
				require.Contains(t, bundle.BundleJson, fmt.Sprintf(`"main_address":%q`, dest.Address))
				require.Contains(t, bundle.BundleJson, fmt.Sprintf(`"value":%d`, withdrawSats))
				t.Logf("pending withdrawal bundle at zSide height %d", height(t))
				return
			}
		}
		t.Fatalf("no pending withdrawal bundle at zSide height %d", height(t))
	})

	t.Run("shield", func(t *testing.T) {
		before := balance(t)
		shield, err := zside.Shield(ctx, &zpb.ShieldRequest{AmountSats: shieldSats, FeeSats: feeSats})
		require.NoError(t, err, "shield")
		defer dropOnFailure(t, shield.Txid)
		blindMergeMine(t)
		after := balance(t)
		require.EqualValues(t, before.TotalShieldedSats+shieldSats, after.TotalShieldedSats)
		require.InDelta(t, before.TotalTransparentSats-shieldSats-feeSats, after.TotalTransparentSats, zsideFeeSlack)
		for range zsideAnchorDepth {
			blindMergeMine(t)
		}
	})

	t.Run("shielded transfer", func(t *testing.T) {
		before := balance(t)
		dest, err := zside.GetNewShieldedAddress(ctx, &zpb.GetNewShieldedAddressRequest{})
		require.NoError(t, err)
		transfer, err := zside.ShieldedTransfer(ctx, &zpb.ShieldedTransferRequest{
			Address: dest.Address, AmountSats: moveSats, FeeSats: feeSats,
		})
		require.NoError(t, err, "shielded transfer")
		defer dropOnFailure(t, transfer.Txid)
		blindMergeMine(t)
		require.EqualValues(t, before.TotalShieldedSats-feeSats, balance(t).TotalShieldedSats)
		for range zsideAnchorDepth {
			blindMergeMine(t)
		}
	})

	t.Run("unshield", func(t *testing.T) {
		before := balance(t)
		unshield, err := zside.Unshield(ctx, &zpb.UnshieldRequest{AmountSats: unshieldSats, FeeSats: feeSats})
		require.NoError(t, err, "unshield")
		defer dropOnFailure(t, unshield.Txid)
		blindMergeMine(t)
		after := balance(t)
		require.EqualValues(t, before.TotalShieldedSats-unshieldSats-feeSats, after.TotalShieldedSats)
		require.InDelta(t, before.TotalTransparentSats+unshieldSats, after.TotalTransparentSats, zsideFeeSlack)
	})
}

// formatDepositAddress matches formatDepositAddress in sidechain_core/lib/bitcoin.dart.
func formatDepositAddress(address string, slot int) string {
	prefix := fmt.Sprintf("s%d_%s_", slot, address)
	sum := sha256.Sum256([]byte(prefix))
	return prefix + hex.EncodeToString(sum[:3])
}
