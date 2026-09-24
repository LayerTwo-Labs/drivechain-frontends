package wallet

import (
	"errors"
	"fmt"

	"connectrpc.com/connect"
)

const (
	// CancelDustSats is the least a cancel can return. Every change kind
	// keeps an output of this size.
	CancelDustSats = 546
	// cancelMinFeeSats is the least a cancel pays, also when it evicts nothing.
	cancelMinFeeSats = 1000
	// electrumIncrementalSatPerKvB is the incremental relay fee a light wallet
	// assumes, because the server does not report the fee of its node.
	electrumIncrementalSatPerKvB = minRelayFeeRate * 1000
)

// CancelPlan is the transaction that cancels an unconfirmed one. It spends the
// wallet's own inputs of that transaction back to a new change address.
type CancelPlan struct {
	Inputs        []RequiredInput
	FeeSats       int64
	RecoveredSats int64
}

// CancelPreview reports what a cancel returns. Plan is nil when the wallet
// cannot cancel the transaction, and Reason tells why.
type CancelPreview struct {
	Plan   *CancelPlan
	Reason string
}

// CancelResult is the cancel a backend broadcast.
type CancelResult struct {
	NewTxID string
	Plan    CancelPlan
}

// CancelFeeSats is what a cancel of vsize vbytes pays to evict evictedSats of
// fees, by BIP125 rules 3 and 4. It pays at least rateSatPerVB.
func CancelFeeSats(evictedSats, vsize, incrementalSatPerKvB, rateSatPerVB int64) int64 {
	feeSats := evictedSats + (incrementalSatPerKvB*vsize+999)/1000
	return max(feeSats, rateSatPerVB*vsize, cancelMinFeeSats)
}

// cancelTx is the unconfirmed transaction a cancel replaces.
type cancelTx struct {
	// VsizeVBytes is the size of the transaction alone, without descendants.
	VsizeVBytes int64
	// OwnInputs are the inputs the wallet signs, with their values.
	OwnInputs []RequiredInput
	// EvictedFeeSats is the fee of the transaction and every descendant.
	EvictedFeeSats       int64
	IncrementalSatPerKvB int64
	RateSatPerVB         int64
	ChangeKind           ScriptKind
}

// planCancel prices a cancel of tx. It returns a reason, and no plan, when the
// cancel cannot return a coin to the wallet.
func planCancel(tx cancelTx) (*CancelPlan, string) {
	if len(tx.OwnInputs) == 0 {
		return nil, "this wallet signs none of the inputs, so it cannot cancel the transaction"
	}
	var totalSats int64
	for _, in := range tx.OwnInputs {
		totalSats += in.AmountSats
	}
	// The cancel holds a subset of the inputs and one output, so this bounds its size.
	vsize := tx.VsizeVBytes + int64(len(tx.OwnInputs)) + int64(outputVsizeForKind(tx.ChangeKind))
	feeSats := CancelFeeSats(tx.EvictedFeeSats, vsize, tx.IncrementalSatPerKvB, tx.RateSatPerVB)
	recoveredSats := totalSats - feeSats
	if recoveredSats < CancelDustSats {
		return nil, fmt.Sprintf(
			"the inputs of this wallet hold %d sats, under the %d sat cancel fee plus dust", totalSats, feeSats)
	}
	return &CancelPlan{Inputs: tx.OwnInputs, FeeSats: feeSats, RecoveredSats: recoveredSats}, ""
}

// allows refuses a cancel the wallet cannot build, and one that pays more
// than maxFeeSats.
func (c *CancelPreview) allows(maxFeeSats int64) error {
	if c.Plan == nil {
		return connect.NewError(connect.CodeFailedPrecondition, errors.New(c.Reason))
	}
	if c.Plan.FeeSats > maxFeeSats {
		return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
			"the cancel fee rose to %d sats, over the %d sats you confirmed", c.Plan.FeeSats, maxFeeSats))
	}
	return nil
}

// cancelSend is the send that broadcasts plan. With no destination, all of the
// inputs less the fee return as change.
func cancelSend(plan CancelPlan) SendRequest {
	return SendRequest{
		RequiredInputs: plan.Inputs,
		FixedFeeSats:   plan.FeeSats,
		Replaceable:    true,
	}
}
