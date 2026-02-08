package engines

import (
	"fmt"
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
