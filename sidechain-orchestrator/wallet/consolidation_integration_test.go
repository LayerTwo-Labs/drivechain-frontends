//go:build integration

package wallet_test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The consolidation planner in bitwindow/lib/utils/consolidation.dart sizes a
// transaction with the weight the orchestrator reports for every coin. This
// test measures a real transaction that Bitcoin Core builds and signs, and
// holds the calculation to it.
const (
	maxStandardTxVbytes       = 100000
	consolidationTargetVbytes = 98000
	segwitOutputScriptBytes   = 22
)

func varIntLen(value int) int {
	switch {
	case value < 0xfd:
		return 1
	case value <= 0xffff:
		return 3
	default:
		return 5
	}
}

// estimateConsolidationVbytes mirrors consolidationVbytes in the Dart planner.
// It adds the weight the backend reports per coin, so no script kind is guessed.
func estimateConsolidationVbytes(inputs []*pb.UnspentOutput, outputScriptBytes int) int {
	weight := 4 * 8 // version and locktime
	weight += 4 * varIntLen(len(inputs))
	weight += 4 * varIntLen(1)
	// The segwit marker and flag. Every coin this test spends carries a
	// witness, so no input adds an empty witness byte.
	weight += 2
	for _, utxo := range inputs {
		weight += int(utxo.InputWeightUnits)
	}
	weight += 4 * (8 + 1 + outputScriptBytes)
	return (weight + 3) / 4
}

func outpoint(txid string, vout int32) string {
	return fmt.Sprintf("%s:%d", txid, vout)
}

// mineBlocks mines in chunks, because one generatetoaddress call for hundreds
// of blocks passes the Core RPC client timeout.
func mineBlocks(ctx context.Context, t *testing.T, node *testharness.Node, address string, blocks int) {
	t.Helper()

	const chunk = 100
	for left := blocks; left > 0; left -= chunk {
		next := min(left, chunk)
		require.NoError(t, node.MineToAddress(ctx, next, address), "mine %d blocks", next)
	}
}

// sendConsolidation merges every coin in inputs into one new address, the same
// way ConsolidationProvider does: the fee comes out of the single output, and
// Core adds no coin of its own.
func sendConsolidation(
	ctx context.Context, t *testing.T, node *testharness.Node, inputs []*pb.UnspentOutput,
) (txid string, destination string, totalSats int64) {
	t.Helper()

	addrResp, err := node.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	require.NoError(t, err, "get a fresh address for the consolidation")
	destination = addrResp.Msg.Address

	for _, utxo := range inputs {
		totalSats += utxo.AmountSats
	}

	sendResp, err := node.WalletClient.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		Destinations:          map[string]int64{destination: totalSats},
		FeeRateSatPerVbyte:    1,
		SubtractFeeFromAmount: true,
		RequiredInputs:        inputs,
	}))
	require.NoError(t, err, "broadcast the consolidation of %d coins", len(inputs))

	return sendResp.Msg.Txid, destination, totalSats
}

// TestConsolidationIntegration mines 1000 blocks, consolidates half the coins,
// consolidates the rest, and mines one block that holds both transactions.
func TestConsolidationIntegration(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()

	node := h.Nodes[0]
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	defer cancel()

	// FundWallet already mines 101 blocks to a segwit address. 899 more make
	// 1000, and a coinbase matures after 100 blocks, which leaves about 900
	// spendable coins. Half of them land on a taproot address, so the wallet
	// holds two script kinds and a coin count caps nothing.
	segwitAddress := node.FundWallet(t)

	taprootResp, err := node.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{
		AddressType: pb.AddressType_ADDRESS_TYPE_TAPROOT,
	}))
	require.NoError(t, err, "get a taproot address")
	taprootAddress := taprootResp.Msg.Address
	require.NotEqual(t, segwitAddress, taprootAddress)

	mineBlocks(ctx, t, node, taprootAddress, 450)
	mineBlocks(ctx, t, node, segwitAddress, 449)
	node.WaitForBalance(t)
	miningAddress := segwitAddress

	height, err := node.CoreRPC.GetBlockCount(ctx)
	require.NoError(t, err)
	require.Equal(t, 1000, height, "the chain holds 1000 blocks")

	unspentResp, err := node.WalletClient.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{}))
	require.NoError(t, err)
	coins := unspentResp.Msg.Utxos
	require.GreaterOrEqual(t, len(coins), 800, "1000 blocks leave the mature coinbase coins")

	kinds := map[int32]int{}
	for _, c := range coins {
		require.Positive(t, c.InputWeightUnits, "the backend sizes coin %s:%d from its descriptor", c.Txid, c.Vout)
		kinds[c.InputWeightUnits]++
	}
	require.Len(t, kinds, 2, "the wallet holds coins of two script kinds")
	require.Positive(t, kinds[231], "taproot coins weigh 231 weight units")
	require.Positive(t, kinds[272], "segwit coins weigh 272 weight units")
	t.Logf("the wallet holds %d spendable coins across %d script kinds", len(coins), len(kinds))

	firstHalf := coins[:len(coins)/2]
	secondHalf := coins[len(coins)/2:]

	spent := make(map[string]bool, len(coins))
	for _, coin := range coins {
		spent[outpoint(coin.Txid, coin.Vout)] = true
	}

	var (
		firstTxid, secondTxid           string
		firstAddress, secondAddress     string
		firstTotalSats, secondTotalSats int64
	)

	t.Run("consolidate the first half", func(t *testing.T) {
		firstTxid, firstAddress, firstTotalSats = sendConsolidation(ctx, t, node, firstHalf)
		t.Logf("first consolidation %s merges %d coins", firstTxid, len(firstHalf))
	})

	t.Run("consolidate the rest while the first waits in the mempool", func(t *testing.T) {
		secondTxid, secondAddress, secondTotalSats = sendConsolidation(ctx, t, node, secondHalf)
		require.NotEqual(t, firstTxid, secondTxid)

		// Both transactions sit in the mempool at the same time. They spend
		// separate coins, so neither one depends on the other.
		for _, txid := range []string{firstTxid, secondTxid} {
			entry, err := node.CoreRPC.GetMempoolEntry(ctx, txid)
			require.NoError(t, err, "transaction %s waits in the mempool", txid)
			require.Positive(t, entry.Vsize)
		}
	})

	t.Run("each transaction merges only the coins it got", func(t *testing.T) {
		for _, tc := range []struct {
			name        string
			txid        string
			inputs      []*pb.UnspentOutput
			destination string
			totalSats   int64
		}{
			{"first half", firstTxid, firstHalf, firstAddress, firstTotalSats},
			{"second half", secondTxid, secondHalf, secondAddress, secondTotalSats},
		} {
			t.Run(tc.name, func(t *testing.T) {
				decoded, err := node.WalletClient.DecodeTransaction(ctx, connect.NewRequest(&pb.DecodeTransactionRequest{
					Input: tc.txid,
				}))
				require.NoError(t, err)
				msg := decoded.Msg

				wanted := make(map[string]bool, len(tc.inputs))
				for _, utxo := range tc.inputs {
					wanted[outpoint(utxo.Txid, utxo.Vout)] = true
				}

				require.Len(t, msg.Inputs, len(tc.inputs), "no coin joins or leaves the selection")
				for _, input := range msg.Inputs {
					assert.True(t, wanted[outpoint(input.PrevTxid, input.PrevVout)],
						"input %s:%d belongs to the selection", input.PrevTxid, input.PrevVout)
				}

				// One output and no change. The fee comes out of that output,
				// so the merged coins do not pull in a coin to pay it.
				require.Len(t, msg.Outputs, 1, "consolidation leaves one coin")
				assert.Equal(t, tc.destination, msg.Outputs[0].Address)
				assert.Equal(t, tc.totalSats, msg.TotalInputSats)
				assert.Positive(t, msg.FeeSats)
				assert.Equal(t, tc.totalSats-msg.FeeSats, msg.Outputs[0].ValueSats)

				// The estimate must never fall below the size Core measures.
				// An estimate that is too low builds a transaction above the
				// standard limit, and every node drops it.
				// The calculation must never fall below the size Core
				// measures. A number that is too low builds a transaction
				// above the standard limit, and every node drops it.
				estimate := estimateConsolidationVbytes(tc.inputs, segwitOutputScriptBytes)
				measured := int(msg.VsizeVbytes)
				assert.LessOrEqual(t, measured, maxStandardTxVbytes, "Core relays the transaction")
				assert.GreaterOrEqual(t, estimate, measured,
					"the calculation for %d inputs stays at or above the true size", len(tc.inputs))

				// The only gap left is signature grinding. Core grinds for a
				// low R value, so it signs with 70 or 71 bytes where the
				// calculation allows 72. That is 2 weight units per input at
				// most, and one vbyte of rounding. A structural mistake, such
				// as a missed input base or a missed witness, costs far more.
				assert.LessOrEqual(t, estimate-measured, ((2*len(tc.inputs))/4)+1,
					"the calculation matches the true size, apart from short signatures")
				t.Logf("%d inputs: %d vbytes measured, %d vbytes calculated", len(tc.inputs), measured, estimate)
			})
		}
	})

	t.Run("a transaction filled to the target stays below the standard limit", func(t *testing.T) {
		// The planner stops a transaction at the target. Fill one with the
		// coin kind that weighs the least, because that kind fits the most.
		lightest := coins[0]
		for _, c := range coins {
			if c.InputWeightUnits < lightest.InputWeightUnits {
				lightest = c
			}
		}

		filled := []*pb.UnspentOutput{}
		for {
			next := append(filled, lightest)
			if estimateConsolidationVbytes(next, segwitOutputScriptBytes) > consolidationTargetVbytes {
				break
			}
			filled = next
		}

		require.LessOrEqual(t, estimateConsolidationVbytes(filled, segwitOutputScriptBytes), maxStandardTxVbytes)
		t.Logf("the target holds %d coins of %d weight units", len(filled), lightest.InputWeightUnits)
	})

	t.Run("one block confirms both transactions", func(t *testing.T) {
		require.NoError(t, node.MineToAddress(ctx, 1, miningAddress), "mine the block that holds both")

		var blockhash string
		for _, txid := range []string{firstTxid, secondTxid} {
			details, err := node.WalletClient.GetTransactionDetails(ctx, connect.NewRequest(&pb.GetTransactionDetailsRequest{
				Txid: txid,
			}))
			require.NoError(t, err)
			require.GreaterOrEqual(t, details.Msg.Confirmations, int32(1), "transaction %s confirms", txid)
			require.NotEmpty(t, details.Msg.Blockhash)

			if blockhash == "" {
				blockhash = details.Msg.Blockhash
				continue
			}
			require.Equal(t, blockhash, details.Msg.Blockhash, "one block holds both transactions")
		}
	})

	t.Run("the merged coins are gone and two coins take their place", func(t *testing.T) {
		afterResp, err := node.WalletClient.ListUnspent(ctx, connect.NewRequest(&pb.ListUnspentRequest{}))
		require.NoError(t, err)

		merged := map[string]bool{}
		for _, coin := range afterResp.Msg.Utxos {
			require.False(t, spent[outpoint(coin.Txid, coin.Vout)],
				"coin %s:%d went into a consolidation and must be spent", coin.Txid, coin.Vout)
			if coin.Txid == firstTxid || coin.Txid == secondTxid {
				merged[coin.Txid] = true
			}
		}

		require.True(t, merged[firstTxid], "the first consolidation leaves one coin")
		require.True(t, merged[secondTxid], "the second consolidation leaves one coin")
	})
}
