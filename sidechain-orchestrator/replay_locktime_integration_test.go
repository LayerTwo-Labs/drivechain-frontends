//go:build integration

package orchestrator_test

import (
	"context"
	"os"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
)

// TestReplayLockTime proves the magic-nLockTime replay protection end to end.
// A transaction stamped with nLockTime = 499999999 is rejected as non-final by
// a stock bitcoind but confirmed by a patched bitcoind-replay.
//
// It needs two prebuilt binaries, supplied via env:
//
//	BITCOIND_STOCK  - an unpatched bitcoind
//	BITCOIND_REPLAY - bitcoind with the IsFinalTx locktime skip
//
// Run: BITCOIND_STOCK=... BITCOIND_REPLAY=... go test -tags integration -run TestReplayLockTime ./...
func TestReplayLockTime(t *testing.T) {
	stock := os.Getenv("BITCOIND_STOCK")
	replayBin := os.Getenv("BITCOIND_REPLAY")
	if stock == "" || replayBin == "" {
		t.Skip("set BITCOIND_STOCK and BITCOIND_REPLAY to run")
	}

	// Stock bitcoind rejects the replay-protected send as non-final, but a
	// normal send still confirms — proving the wallet and harness work.
	t.Run("StockRejects", func(t *testing.T) {
		node := startFundedNode(t, stock)
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()

		dest := freshAddress(ctx, t, node)

		normal, err := node.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations: map[string]int64{dest: 100_000_000},
		}))
		require.NoError(t, err, "normal send should succeed on stock bitcoind")
		require.NoError(t, node.Mine(ctx, t, 1))
		requireConfirmed(ctx, t, node, normal.Msg.Txid)

		_, err = node.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations:  map[string]int64{dest: 100_000_000},
			ReplayProtect: true,
		}))
		require.Error(t, err, "stock bitcoind must reject the replay-protected tx")
		require.Contains(t, strings.ToLower(err.Error()), "non-final")
	})

	// bitcoind-replay accepts the same replay-protected send and confirms it.
	t.Run("ReplayConfirms", func(t *testing.T) {
		node := startFundedNode(t, replayBin)
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()

		dest := freshAddress(ctx, t, node)

		resp, err := node.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
			Destinations:  map[string]int64{dest: 100_000_000},
			ReplayProtect: true,
		}))
		require.NoError(t, err, "bitcoind-replay must accept the replay-protected tx")
		txid := resp.Msg.Txid

		// The broadcast tx really carries the magic locktime and a non-final
		// input — without the latter the locktime would be ignored.
		raw, err := node.CoreRPC.GetRawTransaction(ctx, txid)
		require.NoError(t, err)
		require.EqualValues(t, replay.ReplayLockTime, raw.Locktime)
		require.True(t, hasNonFinalInput(raw), "replay tx must have a non-final input")

		require.NoError(t, node.Mine(ctx, t, 1))
		requireConfirmed(ctx, t, node, txid)
	})
}

// startFundedNode brings up a one-node harness against a specific bitcoind and
// returns it with a funded Core wallet.
func startFundedNode(t *testing.T, bitcoindBin string) *testharness.Node {
	t.Helper()
	t.Setenv("BITCOIND_BIN", bitcoindBin)
	h := testharness.New(t, 1)
	node := h.Nodes[0]
	node.FundWallet(t)
	node.WaitForBalance(t)
	return node
}

func freshAddress(ctx context.Context, t *testing.T, n *testharness.Node) string {
	t.Helper()
	resp, err := n.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	require.NoError(t, err)
	return resp.Msg.Address
}

func requireConfirmed(ctx context.Context, t *testing.T, n *testharness.Node, txid string) {
	t.Helper()
	raw, err := n.CoreRPC.GetRawTransaction(ctx, txid)
	require.NoError(t, err)
	require.Greater(t, raw.Confirmations, int32(0), "tx %s should be confirmed", txid)
}

func hasNonFinalInput(raw *wallet.RawTransaction) bool {
	for _, in := range raw.Vin {
		if in.Sequence < 0xffffffff {
			return true
		}
	}
	return false
}
