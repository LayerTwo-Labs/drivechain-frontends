package engines

import (
	"fmt"
	"testing"

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
	if err != nil {
		t.Fatalf("SelectCoins: %v", err)
	}

	if result.ChangeSats != 0 {
		t.Fatalf("expected no change output, got change=%d", result.ChangeSats)
	}

	// Effective value sum must land in [target, target+costOfChange].
	feePerInput := int64(InputVbytes) * feeRate
	costOfChange := int64(OutputVbytes+InputVbytes) * feeRate
	target := sendAmount + int64(OverheadVbytes+OutputVbytes)*feeRate

	var effSum int64
	for _, u := range result.SelectedUTXOs {
		effSum += int64(u.ValueSats) - feePerInput
	}
	if effSum < target || effSum > target+costOfChange {
		t.Fatalf("effective sum %d outside [%d, %d]", effSum, target, target+costOfChange)
	}

	if len(result.SelectedUTXOs) != 1 || result.SelectedUTXOs[0].ValueSats != uint64(exactValue) {
		t.Fatalf("expected the single exact-match UTXO, got %d inputs", len(result.SelectedUTXOs))
	}
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
	if err != nil {
		t.Fatalf("SelectCoins: %v", err)
	}
	if result.ChangeSats != 0 {
		t.Fatalf("expected no change, got %d", result.ChangeSats)
	}

	costOfChange := int64(OutputVbytes+InputVbytes) * feeRate
	var effSum int64
	for _, u := range result.SelectedUTXOs {
		effSum += int64(u.ValueSats) - feePerInput
	}
	if effSum < target || effSum > target+costOfChange {
		t.Fatalf("effective sum %d outside [%d, %d]", effSum, target, target+costOfChange)
	}
	// The big UTXO alone would overshoot by far more than costOfChange, so it
	// must not be the chosen selection.
	if len(result.SelectedUTXOs) == 1 && result.SelectedUTXOs[0].ValueSats == 9_999_999 {
		t.Fatal("BnB picked the oversized UTXO instead of the exact pair")
	}
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
	if err != nil {
		t.Fatalf("expected fallback to succeed, got error: %v", err)
	}

	if len(result.SelectedUTXOs) == 0 {
		t.Fatal("fallback returned no inputs")
	}
	if result.ChangeSats <= 0 {
		t.Fatalf("largest-first fallback should leave change, got %d", result.ChangeSats)
	}
	if got := sumValues(result.SelectedUTXOs); got < sendAmount+result.FeeSats {
		t.Fatalf("selection underfunds tx: inputs=%d need=%d", got, sendAmount+result.FeeSats)
	}
	// Fallback uses largest-first: a single 500k UTXO covers the send.
	if len(result.SelectedUTXOs) != 1 {
		t.Fatalf("expected largest-first to pick 1 input, got %d", len(result.SelectedUTXOs))
	}
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
			if err != nil {
				t.Fatalf("SelectCoins: %v", err)
			}

			for outpoint := range requiredOutpoints {
				found := false
				for _, u := range result.SelectedUTXOs {
					if u.Output == outpoint {
						found = true
						break
					}
				}
				if !found {
					t.Fatalf("required outpoint %s missing from selection", outpoint)
				}
			}

			if result.ChangeSats != 0 {
				t.Fatalf("BnB missed the exact no-change match, produced change=%d", result.ChangeSats)
			}

			costOfChange := int64(OutputVbytes+InputVbytes) * tc.feeRate
			raw := sumValues(result.SelectedUTXOs)
			overpay := raw - tc.sendAmount - result.FeeSats - result.ChangeSats
			if overpay < 0 {
				t.Fatalf("selection underfunds: raw=%d send=%d fee=%d change=%d", raw, tc.sendAmount, result.FeeSats, result.ChangeSats)
			}
			if overpay > costOfChange {
				t.Fatalf("overpay %d exceeds costOfChange %d (raw=%d send=%d fee=%d change=%d)",
					overpay, costOfChange, raw, tc.sendAmount, result.FeeSats, result.ChangeSats)
			}
		})
	}
}
