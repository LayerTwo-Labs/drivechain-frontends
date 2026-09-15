//go:build integration

package wallet_test

import (
	"bytes"
	"context"
	"encoding/hex"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

const coreBurnSats = int64(100_000_000)

func TestCoreWalletBurnIntegration(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()
	node := h.Nodes[0]
	node.FundWallet(t)
	node.WaitForBalance(t)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	net := &chaincfg.RegressionNetParams

	burnScript, err := hex.DecodeString(wallet.ECXBurnScriptHex)
	require.NoError(t, err)
	burnAddress := regtestBurnAddress(t, burnScript)

	t.Run("BurnThroughTheWalletService", func(t *testing.T) {
		client := node.WalletClient
		status, err := client.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		walletID := status.Msg.ActiveWalletId
		requireCoreWallet(t, ctx, client, walletID)

		derived, err := client.DeriveAddresses(ctx, connect.NewRequest(&pb.DeriveAddressesRequest{
			WalletId: walletID, StartIndex: 0, Count: 1,
		}))
		require.NoError(t, err)
		require.Len(t, derived.Msg.Addresses, 1)
		first := derived.Msg.Addresses[0]
		requireCoreReceiveAddress(t, ctx, node.CoreRPC, first)
		dataScript := addressDataScript(t, first)

		created, err := client.CreatePsbt(ctx, connect.NewRequest(&pb.CreatePsbtRequest{
			WalletId:     walletID,
			Destinations: map[string]int64{burnAddress: coreBurnSats},
			OpReturnHex:  hex.EncodeToString([]byte(first)),
		}))
		require.NoError(t, err)

		preview, err := client.DecodeTransaction(ctx, connect.NewRequest(&pb.DecodeTransactionRequest{
			WalletId: walletID, Input: created.Msg.PsbtBase64, CheckOwnership: true,
		}))
		require.NoError(t, err)
		requireBurnPreview(t, preview.Msg, burnScript, dataScript)
		require.Zero(t, preview.Msg.Locktime, "regtest takes no replay locktime")

		signed, err := client.SignPsbt(ctx, connect.NewRequest(&pb.SignPsbtRequest{
			WalletId: walletID, PsbtBase64: created.Msg.PsbtBase64,
		}))
		require.NoError(t, err)
		final, err := client.FinalizePsbt(ctx, connect.NewRequest(&pb.FinalizePsbtRequest{PsbtBase64: signed.Msg.PsbtBase64}))
		require.NoError(t, err)
		sent, err := client.BroadcastTransaction(ctx, connect.NewRequest(&pb.BroadcastTransactionRequest{
			WalletId: walletID, TxHex: final.Msg.RawTxHex,
		}))
		require.NoError(t, err)
		require.Equal(t, preview.Msg.Txid, sent.Msg.Txid)

		require.NoError(t, node.MineToAddress(ctx, 1, first))
		mined, err := node.CoreRPC.GetRawTransaction(ctx, sent.Msg.Txid)
		require.NoError(t, err)
		require.Positive(t, mined.Confirmations)
		onChain, err := wallet.DecodeTransaction(mined.Hex, net)
		require.NoError(t, err)
		requireBurnOutputs(t, onChain.Outputs, burnScript, dataScript)
	})

	t.Run("ReplayLocktimeBindsOnECash", func(t *testing.T) {
		svc := wallet.NewService(t.TempDir(), zerolog.Nop())
		require.NoError(t, svc.Init())
		t.Cleanup(func() { svc.Close() })
		w, err := svc.GenerateWallet("Burn", "", "", nil)
		require.NoError(t, err)
		require.Equal(t, wallet.WalletTypeBitcoinCore, w.WalletType)
		svc.SetNetwork("ecash")
		backend := wallet.NewCoreBackend(svc, node.CoreRPC, wallet.StaticParams(net), zerolog.Nop())

		receive, err := backend.NextReceiveAddress(ctx, w.ID, wallet.ScriptNativeSegwit)
		require.NoError(t, err)
		require.NoError(t, node.MineToAddress(ctx, 101, receive.Address))
		waitForCoreBalance(t, ctx, backend, w.ID)

		addresses, err := wallet.DeriveWalletReceiveAddresses(w, net, 0, 1)
		require.NoError(t, err)
		first := addresses[0]
		requireCoreReceiveAddress(t, ctx, node.CoreRPC, first)
		dataScript := addressDataScript(t, first)

		build := func(allowReplay bool) (*wallet.DecodedTransaction, string) {
			packet, err := backend.CreatePSBT(ctx, w.ID, wallet.SendRequest{
				DestinationsSats: map[string]int64{burnAddress: coreBurnSats},
				OpReturnHex:      hex.EncodeToString([]byte(first)),
				AllowReplay:      allowReplay,
			})
			require.NoError(t, err)
			decoded, err := wallet.DecodeTransaction(packet, net)
			require.NoError(t, err)
			require.True(t, decoded.HasFee)
			requireBurnOutputs(t, decoded.Outputs, burnScript, dataScript)
			signed, err := backend.SignPSBT(ctx, w.ID, packet)
			require.NoError(t, err)
			raw, err := (&wallet.ElectrumBackend{}).FinalizePSBT(signed)
			require.NoError(t, err)
			return decoded, raw
		}

		protected, raw := build(false)
		require.EqualValues(t, replay.ReplayLockTime, protected.Locktime)
		sequences := make([]uint32, len(protected.Inputs))
		for i, in := range protected.Inputs {
			sequences[i] = uint32(in.Sequence)
		}
		require.True(t, replay.Protected(uint32(protected.Locktime), sequences))
		_, err = node.CoreRPC.SendRawTransaction(ctx, raw)
		require.ErrorContains(t, err, "non-final", "stock Core must refuse the replay-protected burn")

		open, raw := build(true)
		require.Zero(t, open.Locktime)
		txid, err := node.CoreRPC.SendRawTransaction(ctx, raw)
		require.NoError(t, err)
		require.Equal(t, open.TxID, txid)
	})
}

func regtestBurnAddress(t *testing.T, burnScript []byte) string {
	t.Helper()
	require.True(t, txscript.IsPayToPubKeyHash(burnScript))
	address, err := btcutil.NewAddressPubKeyHash(burnScript[3:23], &chaincfg.RegressionNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(address)
	require.NoError(t, err)
	require.Equal(t, burnScript, script)
	return address.EncodeAddress()
}

func addressDataScript(t *testing.T, address string) []byte {
	t.Helper()
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(address)).Script()
	require.NoError(t, err)
	return script
}

func requireCoreWallet(t *testing.T, ctx context.Context, client interface {
	ListWallets(context.Context, *connect.Request[pb.ListWalletsRequest]) (*connect.Response[pb.ListWalletsResponse], error)
}, walletID string) {
	t.Helper()
	wallets, err := client.ListWallets(ctx, connect.NewRequest(&pb.ListWalletsRequest{}))
	require.NoError(t, err)
	for _, w := range wallets.Msg.Wallets {
		if w.Id == walletID {
			require.Equal(t, pb.WalletType_WALLET_TYPE_BITCOIN_CORE, w.WalletType)
			return
		}
	}
	t.Fatalf("wallet %s is absent", walletID)
}

// requireCoreReceiveAddress makes sure exactly one Core wallet owns address as receive index 0.
func requireCoreReceiveAddress(t *testing.T, ctx context.Context, rpc *wallet.CoreRPCClient, address string) {
	t.Helper()
	names, err := rpc.ListWallets(ctx)
	require.NoError(t, err)
	owners := 0
	for _, name := range names {
		info, err := rpc.GetAddressInfo(ctx, name, address)
		require.NoError(t, err)
		if !info.IsMine {
			continue
		}
		owners++
		require.False(t, info.IsChange)
		require.True(t, strings.HasSuffix(info.HDKeyPath, "/0/0"), "path %s", info.HDKeyPath)
	}
	require.Equal(t, 1, owners)
}

func requireBurnPreview(t *testing.T, preview *pb.DecodeTransactionResponse, burnScript, dataScript []byte) {
	t.Helper()
	require.True(t, preview.IsPsbt)
	require.True(t, preview.HasTotalInput)
	require.True(t, preview.HasFee)
	require.Positive(t, preview.FeeSats)
	var burns, data int
	var total int64
	for _, out := range preview.Outputs {
		total += out.ValueSats
		script, err := hex.DecodeString(out.ScriptPubkeyHex)
		require.NoError(t, err)
		switch {
		case bytes.Equal(script, burnScript):
			require.Equal(t, coreBurnSats, out.ValueSats)
			burns++
		case bytes.Equal(script, dataScript):
			require.Zero(t, out.ValueSats)
			data++
		default:
			require.True(t, out.IsChange && out.IsMine, "output %d is not wallet change", out.Index)
		}
	}
	require.Equal(t, 1, burns)
	require.Equal(t, 1, data)
	require.Equal(t, preview.TotalOutputSats, total)
	require.Equal(t, preview.TotalInputSats-total, preview.FeeSats)
}

func requireBurnOutputs(t *testing.T, outputs []wallet.DecodedOutput, burnScript, dataScript []byte) {
	t.Helper()
	var burns, data int
	for _, out := range outputs {
		script, err := hex.DecodeString(out.ScriptPubKeyHex)
		require.NoError(t, err)
		switch {
		case bytes.Equal(script, burnScript):
			require.Equal(t, coreBurnSats, out.ValueSats)
			burns++
		case bytes.Equal(script, dataScript):
			require.Zero(t, out.ValueSats)
			data++
		}
	}
	require.Equal(t, 1, burns)
	require.Equal(t, 1, data)
}

func waitForCoreBalance(t *testing.T, ctx context.Context, backend *wallet.CoreBackend, walletID string) {
	t.Helper()
	for {
		confirmed, _, err := backend.Balance(ctx, walletID)
		if err == nil && confirmed > 0 {
			return
		}
		select {
		case <-ctx.Done():
			t.Fatalf("wallet %s has no confirmed balance: %v", walletID, err)
		case <-time.After(500 * time.Millisecond):
		}
	}
}
