package wallet

import (
	"fmt"
	"math"
)

const (
	// minRelayFeeRate is the sat/vB a replacement adds on top of the fee it
	// replaces, so the mempool accepts it (BIP125 rule 4).
	minRelayFeeRate = 1
	// coreBumpFeeTarget is the confirmation target, in blocks, behind the fee
	// rate a fee bump suggests.
	coreBumpFeeTarget = 3
)

func btcToSats(btc float64) int64 {
	return int64(math.Round(btc * 1e8))
}

// BumpFeeRequest replaces an unconfirmed transaction with one that pays more.
type BumpFeeRequest struct {
	TxID string
	// NewFeeRate is the sat/vB the replacement pays. Zero asks the backend for
	// its own estimate.
	NewFeeRate int64
	// FeeFromVout takes the higher fee from that output. Nil takes it from the
	// change output.
	FeeFromVout *int
}

// BumpFeeOutput is one output of the transaction the higher fee can come from.
type BumpFeeOutput struct {
	Vout       int
	AmountSats int64
	Address    string
	// IsChange marks an output the wallet pays back to itself.
	IsChange bool
	// IsMine marks an output the wallet can spend.
	IsMine bool
	// DustSats is the amount below which the output cannot stay.
	DustSats int64
	// VsizeBytes is what this output costs the transaction.
	VsizeBytes int64
}

// BumpFeePlan is the replacement transaction a fee bump builds.
type BumpFeePlan struct {
	OldFeeSats   int64
	NewFeeSats   int64
	ExtraFeeSats int64
	NewFeeRate   float64
	FeeFromVout  int
	AmountBefore int64
	AmountAfter  int64
	// OutputRemoved drops the output, because the rest of it falls under the
	// dust limit. Its remainder joins the fee.
	OutputRemoved bool
	// ReducesPayment marks a plan that pays the fee out of a recipient's
	// output, so the recipient gets less.
	ReducesPayment bool
}

// BumpFeeResult is the replacement a fee bump broadcast.
type BumpFeeResult struct {
	NewTxID string
	Plan    BumpFeePlan
}

// BumpFeePreview reports what a fee bump costs, before it happens.
type BumpFeePreview struct {
	InputCount    int
	VsizeVBytes   int64
	OldFeeSats    int64
	OldFeeRate    float64
	SuggestedRate int64
	Outputs       []BumpFeeOutput
	Plan          *BumpFeePlan
	Reason        string
	// CanReplace marks a transaction this wallet can sign again. A fee rate that
	// is too low leaves Plan empty, but CanReplace stays true.
	CanReplace bool
	// HasChild marks a transaction another one already spends.
	HasChild bool
	// AddsInputs marks a backend that funds a higher fee from another coin when
	// the chosen output cannot cover it. A replacement then holds even with no
	// plan to show.
	AddsInputs bool
}

func changeOutput(outputs []BumpFeeOutput) (BumpFeeOutput, bool) {
	for _, o := range outputs {
		if o.IsChange {
			return o, true
		}
	}
	return BumpFeeOutput{}, false
}

func pickBumpFeeOutput(outputs []BumpFeeOutput, vout *int) (BumpFeeOutput, error) {
	if vout == nil {
		target, ok := changeOutput(outputs)
		if !ok {
			return BumpFeeOutput{}, fmt.Errorf("transaction has no change output, so the higher fee has no output to come from")
		}
		return target, nil
	}
	for _, o := range outputs {
		if o.Vout != *vout {
			continue
		}
		if o.Address == "" {
			return BumpFeeOutput{}, fmt.Errorf("output %d has no address, so it cannot pay the fee", *vout)
		}
		return o, nil
	}
	return BumpFeeOutput{}, fmt.Errorf("output %d is not part of the transaction", *vout)
}

// replacementVsize is the largest size the replacement can reach. It holds the
// same inputs and no more outputs, so only a signature can grow, by one byte
// per input at most.
func replacementVsize(vsize int64, inputCount int) int64 {
	return vsize + int64(inputCount)
}

// minBumpFeeRate is the lowest sat/vB a replacement of a transaction of vsize
// vbytes paying oldFeeSats can use. It answers for the largest replacement, so
// a signature that grows by a byte cannot drop the fee under the relay floor.
func minBumpFeeRate(oldFeeSats, vsize int64, inputCount int) int64 {
	if vsize <= 0 {
		return 0
	}
	worst := replacementVsize(vsize, inputCount)
	return int64(math.Ceil(float64(oldFeeSats+worst*minRelayFeeRate) / float64(vsize)))
}

// bumpFeeTx is the transaction a fee bump replaces. InputCount sizes the worst
// case the replacement can reach once it carries new signatures.
type bumpFeeTx struct {
	OldFeeSats  int64
	VsizeBytes  int64
	InputCount  int
	OutputCount int
}

// planBumpFee computes the replacement that pays newFeeRate, and takes the
// higher fee out of target.
func planBumpFee(tx bumpFeeTx, newFeeRate int64, target BumpFeeOutput) (BumpFeePlan, error) {
	oldFeeSats, vsize, inputCount := tx.OldFeeSats, tx.VsizeBytes, tx.InputCount
	if vsize <= 0 {
		return BumpFeePlan{}, fmt.Errorf("transaction size %d vB is not valid", vsize)
	}
	if newFeeRate <= 0 {
		return BumpFeePlan{}, fmt.Errorf("fee rate must be positive")
	}
	minRate := minBumpFeeRate(oldFeeSats, vsize, inputCount)
	if newFeeRate < minRate {
		return BumpFeePlan{}, fmt.Errorf("fee rate %d sat/vB does not replace a transaction that pays %d sats; use %d sat/vB or more", newFeeRate, oldFeeSats, minRate)
	}
	if newFeeRate > math.MaxInt64/vsize {
		return BumpFeePlan{}, fmt.Errorf("fee rate %d sat/vB is too high for a transaction of %d vB", newFeeRate, vsize)
	}

	newFee := vsize * newFeeRate
	extra := newFee - oldFeeSats
	remainder := target.AmountSats - extra
	if remainder < 0 {
		return BumpFeePlan{}, fmt.Errorf("output %d holds %d sats, and the higher fee takes %d sats", target.Vout, target.AmountSats, extra)
	}

	plan := BumpFeePlan{
		OldFeeSats:     oldFeeSats,
		NewFeeSats:     newFee,
		ExtraFeeSats:   extra,
		FeeFromVout:    target.Vout,
		AmountBefore:   target.AmountSats,
		AmountAfter:    remainder,
		ReducesPayment: !target.IsChange,
	}
	// The replacement pays the same fee over fewer bytes once an output goes
	// away, so it carries a higher rate than the one asked for.
	paidVsize := vsize
	if remainder < target.DustSats {
		if tx.OutputCount <= 1 {
			return BumpFeePlan{}, fmt.Errorf("output %d is the only output, and the higher fee leaves it under the dust limit", target.Vout)
		}
		plan.OutputRemoved = true
		plan.AmountAfter = 0
		plan.NewFeeSats = oldFeeSats + target.AmountSats
		plan.ExtraFeeSats = target.AmountSats
		if target.VsizeBytes > 0 && target.VsizeBytes < vsize {
			paidVsize = vsize - target.VsizeBytes
		}
	}
	plan.NewFeeRate = float64(plan.NewFeeSats) / float64(paidVsize)
	return plan, nil
}

// signalsBip125 reports whether any input carries a sequence below the final
// one, which marks a transaction its sender allows a replacement of.
func signalsBip125(sequences []int64) bool {
	for _, sequence := range sequences {
		if sequence < 0xfffffffe {
			return true
		}
	}
	return false
}
