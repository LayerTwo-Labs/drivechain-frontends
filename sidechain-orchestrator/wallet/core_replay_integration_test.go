//go:build integration

package wallet_test

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// Each eCash network's node accepts only its own replay locktime, so a Core
// wallet must sign the live network's value and lower every input below
// SEQUENCE_FINAL.
func TestCoreReplayLockTimePerNetwork(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()
	node := h.Nodes[0]

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	net := &chaincfg.RegressionNetParams

	networks := []struct {
		name     string
		lockTime uint32
		other    uint32
	}{
		{name: "betanet", lockTime: 499999999, other: 499999998},
		{name: "mainnet", lockTime: 499999998, other: 499999999},
	}
	for _, network := range networks {
		t.Run(network.name, func(t *testing.T) {
			previous := config.ECashEndpoints()
			t.Cleanup(func() { config.SetECashEndpoints(previous) })
			entry := previous
			entry.ReplayLockTime = network.lockTime
			config.SetECashEndpoints(entry)

			svc := wallet.NewService(t.TempDir(), zerolog.Nop())
			require.NoError(t, svc.Init())
			t.Cleanup(func() { svc.Close() })
			w, err := svc.GenerateWallet("Replay "+network.name, "", "", nil)
			require.NoError(t, err)
			require.Equal(t, wallet.WalletTypeBitcoinCore, w.WalletType)
			svc.SetNetwork("ecash")
			backend := wallet.NewCoreBackend(svc, node.CoreRPC, wallet.StaticParams(net), zerolog.Nop())

			receive, err := backend.NextReceiveAddress(ctx, w.ID, wallet.ScriptNativeSegwit)
			require.NoError(t, err)
			require.NoError(t, node.MineToAddress(ctx, 101, receive.Address))
			waitForCoreBalance(t, ctx, backend, w.ID)
			dest, err := backend.NextReceiveAddress(ctx, w.ID, wallet.ScriptNativeSegwit)
			require.NoError(t, err)

			packet, err := backend.CreatePSBT(ctx, w.ID, wallet.SendRequest{
				DestinationsSats: map[string]int64{dest.Address: 100_000_000},
			})
			require.NoError(t, err)
			signed, err := backend.SignPSBT(ctx, w.ID, packet)
			require.NoError(t, err)
			raw, err := (&wallet.ElectrumBackend{}).FinalizePSBT(signed)
			require.NoError(t, err)

			final, err := wallet.DecodeTransaction(raw, net)
			require.NoError(t, err)
			require.EqualValues(t, network.lockTime, final.Locktime)
			require.NotEmpty(t, final.Inputs)
			sequences := make([]uint32, len(final.Inputs))
			for i, in := range final.Inputs {
				sequences[i] = uint32(in.Sequence)
				require.Less(t, sequences[i], wire.MaxTxInSequenceNum, "input %d is final", i)
			}
			require.True(t, replay.Protected(network.lockTime, uint32(final.Locktime), sequences))
			require.False(t, replay.Protected(network.other, uint32(final.Locktime), sequences))

			_, err = node.CoreRPC.SendRawTransaction(ctx, raw)
			require.ErrorContains(t, err, "non-final", "stock Core must refuse the replay-protected transaction")

			_, err = backend.Send(ctx, w.ID, wallet.SendRequest{
				DestinationsSats: map[string]int64{dest.Address: 100_000_000},
			})
			require.ErrorContains(t, err, "non-final", "the raw send path must stamp the same locktime")
		})
	}
}
