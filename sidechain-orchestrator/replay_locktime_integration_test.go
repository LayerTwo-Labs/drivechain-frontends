//go:build integration

package orchestrator_test

import (
	"context"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
)

// TestReplayLockTime proves the magic-nLockTime replay protection end to end,
// for both locktimes in use. Each node confirms a transaction stamped with its
// own network's locktime and rejects the other as non-final; stock bitcoind
// rejects both.
//
// It needs prebuilt binaries, supplied via env:
//
//	BITCOIND_STOCK         - an unpatched bitcoind
//	BITCOIND_REPLAY        - the betanet patch (final at 499999999)
//	BITCOIND_ECASH_MAINNET - the eCash v1 node (final at 499999998), optional
//
// Run: BITCOIND_STOCK=... BITCOIND_REPLAY=... BITCOIND_ECASH_MAINNET=... go test -tags integration -run TestReplayLockTime ./...
func TestReplayLockTime(t *testing.T) {
	stock := os.Getenv("BITCOIND_STOCK")
	replayBin := os.Getenv("BITCOIND_REPLAY")
	if stock == "" || replayBin == "" {
		t.Skip("set BITCOIND_STOCK and BITCOIND_REPLAY to run")
	}

	// Stock bitcoind rejects both stamps as non-final, but a normal send still
	// confirms — proving the wallet and harness work.
	t.Run("StockRejects", func(t *testing.T) {
		node := startFundedNode(t, stock)
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		defer cancel()

		dest := freshAddress(ctx, t, node)

		normal, err := node.WalletClient.SendTransaction(ctx, &pb.SendTransactionRequest{
			Destinations: map[string]int64{dest: 100_000_000},
		})
		require.NoError(t, err, "normal send should succeed on stock bitcoind")
		require.NoError(t, node.Mine(ctx, t, 1))
		requireConfirmed(ctx, t, node, normal.Txid)

		for _, lockTime := range []uint32{betanetLockTime, ecashMainnetLockTime} {
			_, err = broadcastProtected(ctx, t, node, dest, lockTime)
			require.Error(t, err, "stock bitcoind must reject locktime %d", lockTime)
			require.Contains(t, strings.ToLower(err.Error()), "non-final")
		}
	})

	t.Run("BetanetConfirmsItsLockTime", func(t *testing.T) {
		requireNodeTakesOnly(t, replayBin, betanetLockTime, ecashMainnetLockTime)
	})

	t.Run("ECashMainnetConfirmsItsLockTime", func(t *testing.T) {
		mainnetBin := os.Getenv("BITCOIND_ECASH_MAINNET")
		if mainnetBin == "" {
			t.Skip("set BITCOIND_ECASH_MAINNET to run")
		}
		requireNodeTakesOnly(t, mainnetBin, ecashMainnetLockTime, betanetLockTime)
	})
}

const (
	betanetLockTime      = netcatalog.DefaultReplayLockTime
	ecashMainnetLockTime = uint32(499999998)
)

// requireNodeTakesOnly checks that a patched node rejects the other network's
// stamp as non-final and confirms its own.
func requireNodeTakesOnly(t *testing.T, bitcoindBin string, own, other uint32) {
	t.Helper()
	node := startFundedNode(t, bitcoindBin)
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	dest := freshAddress(ctx, t, node)

	_, err := broadcastProtected(ctx, t, node, dest, other)
	require.Error(t, err, "the node must reject locktime %d", other)
	require.Contains(t, strings.ToLower(err.Error()), "non-final")

	txid, err := broadcastProtected(ctx, t, node, dest, own)
	require.NoError(t, err, "the node must accept locktime %d", own)

	// Without a non-final input the locktime would be ignored.
	raw, err := node.CoreRPC.GetRawTransaction(ctx, txid)
	require.NoError(t, err)
	require.EqualValues(t, own, raw.Locktime)
	require.True(t, hasNonFinalInput(raw), "replay tx must have a non-final input")

	require.NoError(t, node.Mine(ctx, t, 1))
	requireConfirmed(ctx, t, node, txid)
}

// broadcastProtected builds, signs and broadcasts one transaction that carries
// the magic nLockTime, straight through Core RPC. The wallet request field only
// drops the stamp, so the raw path is the one way to force it on regtest.
func broadcastProtected(ctx context.Context, t *testing.T, n *testharness.Node, dest string, lockTime uint32) (string, error) {
	t.Helper()
	coreWallet := coreWalletName(ctx, t, n)

	outputs := []map[string]any{{dest: 1.0}}
	rawHex, err := n.CoreRPC.CreateRawTransaction(ctx, []wallet.RawInput{}, outputs, lockTime)
	require.NoError(t, err)

	// replaceable lowers every funded input below SEQUENCE_FINAL, else the
	// locktime has no effect.
	funded, err := n.CoreRPC.FundRawTransaction(ctx, coreWallet, rawHex, map[string]any{
		"fee_rate":    2,
		"replaceable": true,
	})
	require.NoError(t, err)

	signed, err := n.CoreRPC.SignRawTransactionWithWallet(ctx, coreWallet, funded.Hex)
	require.NoError(t, err)
	require.True(t, signed.Complete, "the core wallet must sign every input")

	return n.CoreRPC.SendRawTransaction(ctx, signed.Hex)
}

// coreWalletName finds the loaded Core wallet that holds coins. The harness
// also loads an unfunded enforcer wallet.
func coreWalletName(ctx context.Context, t *testing.T, n *testharness.Node) string {
	t.Helper()
	loaded, err := n.CoreRPC.ListWallets(ctx)
	require.NoError(t, err)
	for _, name := range loaded {
		utxos, err := n.CoreRPC.ListUnspent(ctx, name)
		require.NoError(t, err)
		if len(utxos) > 0 {
			return name
		}
	}
	t.Fatalf("no loaded core wallet holds coins: %v", loaded)
	return ""
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
	resp, err := n.WalletClient.GetNewAddress(ctx, &pb.GetNewAddressRequest{})
	require.NoError(t, err)
	return resp.Address
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
