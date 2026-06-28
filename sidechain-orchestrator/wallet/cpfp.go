package wallet

import (
	"fmt"
	"math"
)

// CpfpRequest selects an unconfirmed wallet UTXO (the parent's output that this
// wallet can spend) and a target package fee rate. The backend builds a child
// transaction spending that outpoint so the parent+child package clears the
// target rate.
type CpfpRequest struct {
	ParentTxID string
	ParentVout int
	TargetRate int64 // sat/vB, package fee rate the parent+child must reach
}

// packageChildFee returns the child fee (sats) that makes the parent+child
// package reach targetRate sat/vB:
//
//	child_fee = targetRate*(parentVsize+childVsize) - parentFee
//
// clamped up to the child's own minimum-relay fee (minRelayRate sat/vB) so the
// child alone always relays even when the parent already overpays.
func packageChildFee(targetRate, parentVsize, parentFee, childVsize, minRelayRate int64) int64 {
	pkg := targetRate*(parentVsize+childVsize) - parentFee
	childMin := int64(math.Ceil(float64(childVsize) * float64(minRelayRate)))
	if pkg < childMin {
		return childMin
	}
	return pkg
}

// cpfpChildPlan computes the child fee and the child's single self-send output
// amount for a CPFP spend of a parentValue UTXO. childFee comes from
// packageChildFee; outputSats is what's left for the self-send. Returns an error
// when the child fee would consume the whole parent output.
func cpfpChildPlan(targetRate, parentVsize, parentFee, childVsize, parentValue int64) (childFee, outputSats int64, err error) {
	childFee = packageChildFee(targetRate, parentVsize, parentFee, childVsize, 1)
	if childFee >= parentValue {
		return 0, 0, fmt.Errorf("child fee %d sats exceeds parent output value %d sats", childFee, parentValue)
	}
	return childFee, parentValue - childFee, nil
}
