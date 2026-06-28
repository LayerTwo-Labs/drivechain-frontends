package engines

import (
	"fmt"
	"math"
	"math/rand"
	"sort"

	walletpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
)

// Coin selection constants (P2WPKH)
const (
	InputVbytes    = 68
	OutputVbytes   = 31
	OverheadVbytes = 10
)

// CoinSelectionResult holds the result of coin selection
type CoinSelectionResult struct {
	SelectedUTXOs  []*walletpb.UnspentOutput
	TotalInputSats int64
	FeeSats        int64
	ChangeSats     int64
}

// InsufficientFundsError is returned when there aren't enough funds
type InsufficientFundsError struct {
	Needed       int64
	Available    int64
	FrozenAmount int64
	Message      string
}

func (e *InsufficientFundsError) Error() string {
	return e.Message
}

// SelectCoins selects UTXOs for a transaction using the specified strategy
func SelectCoins(
	allUTXOs []*walletpb.UnspentOutput,
	frozenOutpoints map[string]bool,
	targetSats int64,
	feeSatsPerVbyte int64,
	numOutputs int,
	strategy walletpb.CoinSelectionStrategy,
	requiredOutpoints map[string]bool,
) (*CoinSelectionResult, error) {
	if numOutputs <= 0 {
		numOutputs = 2 // default: destination + change
	}

	// Build required UTXOs list and available pool
	var required []*walletpb.UnspentOutput
	var available []*walletpb.UnspentOutput

	for _, utxo := range allUTXOs {
		outpoint := utxo.Output

		if requiredOutpoints[outpoint] {
			required = append(required, utxo)
		} else if !frozenOutpoints[outpoint] {
			available = append(available, utxo)
		}
	}

	// Start with required UTXOs
	selected := make([]*walletpb.UnspentOutput, len(required))
	copy(selected, required)

	var selectedAmount int64
	for _, utxo := range selected {
		selectedAmount += int64(utxo.ValueSats)
	}

	// Fee estimation function
	estimateFee := func(inputCount int) int64 {
		vsize := int64(OverheadVbytes + (inputCount * InputVbytes) + (numOutputs * OutputVbytes))
		return vsize * feeSatsPerVbyte
	}

	// Check if required UTXOs already cover target + fee
	fee := estimateFee(len(selected))
	needed := targetSats + fee

	if selectedAmount >= needed {
		return &CoinSelectionResult{
			SelectedUTXOs:  selected,
			TotalInputSats: selectedAmount,
			FeeSats:        fee,
			ChangeSats:     selectedAmount - targetSats - fee,
		}, nil
	}

	if strategy == walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND {
		if result := selectBranchAndBound(required, available, targetSats, feeSatsPerVbyte, numOutputs); result != nil {
			return result, nil
		}
		// Fall back to largest-first when BnB finds no exact match.
		strategy = walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST
	}

	// Sort available UTXOs by strategy
	sortByStrategy(available, strategy)

	// Add UTXOs until we have enough
	for _, utxo := range available {
		selected = append(selected, utxo)
		selectedAmount += int64(utxo.ValueSats)

		// Recalculate fee with new input count
		fee = estimateFee(len(selected))
		needed = targetSats + fee

		if selectedAmount >= needed {
			return &CoinSelectionResult{
				SelectedUTXOs:  selected,
				TotalInputSats: selectedAmount,
				FeeSats:        fee,
				ChangeSats:     selectedAmount - targetSats - fee,
			}, nil
		}
	}

	// Not enough funds
	totalAvailable := selectedAmount
	var totalFrozen int64
	for _, utxo := range allUTXOs {
		if frozenOutpoints[utxo.Output] {
			totalFrozen += int64(utxo.ValueSats)
		}
	}

	var message string
	if totalFrozen > 0 && totalAvailable+totalFrozen >= needed {
		message = fmt.Sprintf(
			"Insufficient funds. %d sats are frozen. Unfreeze some UTXOs to complete this transaction.",
			totalFrozen,
		)
	} else {
		message = fmt.Sprintf(
			"Insufficient funds. Need %d sats, have %d sats available.",
			needed, totalAvailable,
		)
	}

	return nil, &InsufficientFundsError{
		Needed:       needed,
		Available:    totalAvailable,
		FrozenAmount: totalFrozen,
		Message:      message,
	}
}

// branchAndBoundMaxTries caps the depth-first search, matching Bitcoin Core.
const branchAndBoundMaxTries = 100_000

// selectBranchAndBound runs Bitcoin Core's Branch-and-Bound search: it looks for
// a subset of UTXOs whose effective value (value minus the fee to spend each
// input) lands in [target, target+costOfChange], producing a transaction that
// needs no change output. Returns nil when no such exact match exists so the
// caller can fall back to another strategy.
//
// target is the send amount plus the fee for a no-change transaction (overhead +
// send outputs, with one fewer output than numOutputs since no change is added).
// costOfChange is the fee to create a change output now plus the fee to spend it
// later.
func selectBranchAndBound(
	required, available []*walletpb.UnspentOutput,
	targetSats, feeSatsPerVbyte int64,
	numOutputs int,
) *CoinSelectionResult {
	feePerInput := int64(InputVbytes) * feeSatsPerVbyte

	sendOutputs := numOutputs - 1
	if sendOutputs < 1 {
		sendOutputs = 1
	}
	noChangeOverhead := int64(OverheadVbytes+(sendOutputs*OutputVbytes)) * feeSatsPerVbyte
	costOfChange := int64(OutputVbytes+InputVbytes) * feeSatsPerVbyte

	effective := func(u *walletpb.UnspentOutput) int64 {
		return int64(u.ValueSats) - feePerInput
	}

	var requiredEffective int64
	for _, u := range required {
		requiredEffective += effective(u)
	}

	target := targetSats + noChangeOverhead - requiredEffective
	if target <= 0 {
		return nil
	}

	pool := make([]*walletpb.UnspentOutput, 0, len(available))
	var poolTotal int64
	for _, u := range available {
		ev := effective(u)
		if ev <= 0 {
			continue // spending this input costs more than it adds
		}
		pool = append(pool, u)
		poolTotal += ev
	}
	if poolTotal < target {
		return nil
	}

	sort.Slice(pool, func(i, j int) bool {
		return effective(pool[i]) > effective(pool[j])
	})

	effs := make([]int64, len(pool))
	for i, u := range pool {
		effs[i] = effective(u)
	}

	bestSelection := []bool{}
	currSelection := make([]bool, len(pool))
	var bestWaste int64 = math.MaxInt64

	var remaining int64 = poolTotal
	tries := branchAndBoundMaxTries

	var search func(depth int, currValue int64) bool
	search = func(depth int, currValue int64) bool {
		if tries <= 0 {
			return false
		}

		if currValue >= target {
			waste := currValue - target
			if waste <= costOfChange && waste < bestWaste {
				bestWaste = waste
				bestSelection = make([]bool, len(currSelection))
				copy(bestSelection, currSelection)
			}
			return true
		}
		if depth >= len(pool) {
			return false
		}
		if currValue+remaining < target {
			return false
		}

		tries--

		// Include branch.
		remaining -= effs[depth]
		currSelection[depth] = true
		search(depth+1, currValue+effs[depth])
		currSelection[depth] = false
		remaining += effs[depth]

		// Omit branch.
		search(depth+1, currValue)
		return false
	}

	search(0, 0)

	if bestWaste == math.MaxInt64 {
		return nil
	}

	selected := make([]*walletpb.UnspentOutput, len(required))
	copy(selected, required)
	for i, picked := range bestSelection {
		if picked {
			selected = append(selected, pool[i])
		}
	}

	var totalInput int64
	for _, u := range selected {
		totalInput += int64(u.ValueSats)
	}

	fee := int64(OverheadVbytes+(len(selected)*InputVbytes)+(sendOutputs*OutputVbytes)) * feeSatsPerVbyte

	return &CoinSelectionResult{
		SelectedUTXOs:  selected,
		TotalInputSats: totalInput,
		FeeSats:        fee,
		ChangeSats:     0,
	}
}

// sortByStrategy sorts UTXOs according to the given strategy
func sortByStrategy(utxos []*walletpb.UnspentOutput, strategy walletpb.CoinSelectionStrategy) {
	switch strategy {
	case walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST,
		walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_UNSPECIFIED:
		sort.Slice(utxos, func(i, j int) bool {
			return utxos[i].ValueSats > utxos[j].ValueSats
		})
	case walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_SMALLEST_FIRST:
		sort.Slice(utxos, func(i, j int) bool {
			return utxos[i].ValueSats < utxos[j].ValueSats
		})
	case walletpb.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_RANDOM:
		rand.Shuffle(len(utxos), func(i, j int) {
			utxos[i], utxos[j] = utxos[j], utxos[i]
		})
	}
}

// EstimateFee estimates transaction fee for given parameters
func EstimateFee(inputCount int, numOutputs int, feeSatsPerVbyte int64) int64 {
	if numOutputs <= 0 {
		numOutputs = 2
	}
	vsize := int64(OverheadVbytes + (inputCount * InputVbytes) + (numOutputs * OutputVbytes))
	return vsize * feeSatsPerVbyte
}
