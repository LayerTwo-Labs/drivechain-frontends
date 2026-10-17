package engines

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"

	walletpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
)

func bnbUTXOs(values ...int64) []*walletpb.UnspentOutput {
	utxos := make([]*walletpb.UnspentOutput, len(values))
	for i, v := range values {
		utxos[i] = &walletpb.UnspentOutput{
			Output:    fmt.Sprintf("txid-%d:%d", i, i),
			ValueSats: uint64(v),
		}
	}
	return utxos
}

func sumValues(utxos []*walletpb.UnspentOutput) int64 {
	var total int64
	for _, u := range utxos {
		total += int64(u.ValueSats)
	}
	return total
}

func TestBranchAndBoundExactMatchNoChange(t *testing.T) {
	const feeRate = 10 // sat/vB
	numOutputs := 2    // destination + (potential) change

	// One UTXO whose effective value exactly funds a no-change send: pick the
	// send amount so that value == amount + noChangeFee for a single input.
	sendAmount := int64(100_000)
	// no-change fee for 1 input, 1 send output: overhead + input + output.
	noChangeFee := int64(OverheadVbytes+InputVbytes+OutputVbytes) * feeRate
	exactValue := sendAmount + noChangeFee

	utxos := bnbUTXOs(exactValue, 250_000, 37_000)

	result, err := SelectCoins(
		utxos,
		map[string]bool{},
		sendAmount,
		feeRate,
		numOutputs,
		walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND,
		map[string]bool{},
	)
	require.NoError(t, err)

	require.Zero(t, result.ChangeSats)

	// Effective value sum must land in [target, target+costOfChange].
	feePerInput := int64(InputVbytes) * feeRate
	costOfChange := int64(OutputVbytes+InputVbytes) * feeRate
	target := sendAmount + int64(OverheadVbytes+OutputVbytes)*feeRate

	var effSum int64
	for _, u := range result.SelectedUTXOs {
		effSum += int64(u.ValueSats) - feePerInput
	}
	require.GreaterOrEqual(t, effSum, target)
	require.LessOrEqual(t, effSum, target+costOfChange)

	require.Len(t, result.SelectedUTXOs, 1)
	require.Equal(t, uint64(exactValue), result.SelectedUTXOs[0].ValueSats)
}

func TestBranchAndBoundEffectiveValueAccountsForInputFee(t *testing.T) {
	const feeRate = 50 // high rate so input fee dominates
	numOutputs := 2

	// Two small UTXOs whose effective values (value minus input fee) sum exactly
	// to the no-change target — a naive nominal-value selector would miss this.
	sendAmount := int64(20_000)
	feePerInput := int64(InputVbytes) * feeRate
	target := sendAmount + int64(OverheadVbytes+OutputVbytes)*feeRate
	halfEff := target / 2

	// value = desired effective value + input fee.
	a := halfEff + feePerInput
	b := (target - halfEff) + feePerInput

	utxos := bnbUTXOs(a, b, 9_999_999)

	result, err := SelectCoins(
		utxos,
		map[string]bool{},
		sendAmount,
		feeRate,
		numOutputs,
		walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND,
		map[string]bool{},
	)
	require.NoError(t, err)
	require.Zero(t, result.ChangeSats)

	costOfChange := int64(OutputVbytes+InputVbytes) * feeRate
	var effSum int64
	for _, u := range result.SelectedUTXOs {
		effSum += int64(u.ValueSats) - feePerInput
	}
	require.GreaterOrEqual(t, effSum, target)
	require.LessOrEqual(t, effSum, target+costOfChange)
	// The big UTXO alone would overshoot by far more than costOfChange, so it
	// must not be the chosen selection.
	require.False(t, len(result.SelectedUTXOs) == 1 && result.SelectedUTXOs[0].ValueSats == 9_999_999)
}

func TestBranchAndBoundFallsBackWhenNoExactMatch(t *testing.T) {
	const feeRate = 10
	numOutputs := 2

	// Values chosen so no subset's effective value lands within costOfChange of
	// the target; BnB must fail and fall back to largest-first, still returning a
	// valid funded selection (with change).
	utxos := bnbUTXOs(500_000, 500_000, 500_000)
	sendAmount := int64(120_000)

	result, err := SelectCoins(
		utxos,
		map[string]bool{},
		sendAmount,
		feeRate,
		numOutputs,
		walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND,
		map[string]bool{},
	)
	require.NoError(t, err)

	require.NotEmpty(t, result.SelectedUTXOs)
	require.Positive(t, result.ChangeSats)
	require.GreaterOrEqual(t, sumValues(result.SelectedUTXOs), sendAmount+result.FeeSats)
	// Fallback uses largest-first: a single 500k UTXO covers the send.
	require.Len(t, result.SelectedUTXOs, 1)
}

// exactMatchAvail returns the value of a single available UTXO whose effective
// value, added to the required inputs, exactly funds a no-change transaction.
// A correct BnB must select it (change == 0); the double-counted-fee bug aims
// too high, rejects it, and falls back to a wasteful change-bearing selection.
func exactMatchAvail(required []int64, sendAmount, feeRate int64) int64 {
	feePerInput := int64(InputVbytes) * feeRate
	var requiredEffective int64
	for _, v := range required {
		requiredEffective += v - feePerInput
	}
	noChangeOverhead := int64(OverheadVbytes+OutputVbytes) * feeRate
	target := sendAmount + noChangeOverhead - requiredEffective
	return target + feePerInput
}

func TestBranchAndBoundRequiredInputsOverpayBounded(t *testing.T) {
	cases := []struct {
		name       string
		required   []int64
		others     []int64
		sendAmount int64
		feeRate    int64
	}{
		{
			name:       "two required, large send",
			required:   []int64{1_433_279, 1_511_030},
			others:     []int64{5_000_000, 88_000},
			sendAmount: 6_703_424,
			feeRate:    157,
		},
		{
			name:       "one required, insufficient alone",
			required:   []int64{200_000},
			others:     []int64{900_000, 50_000},
			sendAmount: 500_000,
			feeRate:    30,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			available := append([]int64{exactMatchAvail(tc.required, tc.sendAmount, tc.feeRate)}, tc.others...)
			all := bnbUTXOs(append(append([]int64{}, tc.required...), available...)...)
			requiredOutpoints := make(map[string]bool)
			for i := range tc.required {
				requiredOutpoints[all[i].Output] = true
			}

			result, err := SelectCoins(
				all,
				map[string]bool{},
				tc.sendAmount,
				tc.feeRate,
				2,
				walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND,
				requiredOutpoints,
			)
			require.NoError(t, err)

			for outpoint := range requiredOutpoints {
				found := false
				for _, u := range result.SelectedUTXOs {
					if u.Output == outpoint {
						found = true
						break
					}
				}
				require.True(t, found)
			}

			require.Zero(t, result.ChangeSats)

			costOfChange := int64(OutputVbytes+InputVbytes) * tc.feeRate
			raw := sumValues(result.SelectedUTXOs)
			overpay := raw - tc.sendAmount - result.FeeSats - result.ChangeSats
			require.GreaterOrEqual(t, overpay, int64(0))
			require.LessOrEqual(t, overpay, costOfChange)
		})
	}
}
