package api

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// A second deposit on a ctip our own unconfirmed deposit already spends reads
// as an RBF replacement. Core rejects it, or it evicts the recorded first one.
func TestCtipStillPendingHoldsBackASecondDeposit(t *testing.T) {
	pending := ctipStillPending("ctip-txid", "deposit-txid", mempoolDeposit{found: true, confirmations: 0})

	require.True(t, pending)
}

// The ctip already carries our deposit, so the chain moved on.
func TestCtipStillPendingPassesWhenTheCtipHoldsOurDeposit(t *testing.T) {
	pending := ctipStillPending("deposit-txid", "deposit-txid", mempoolDeposit{found: true, confirmations: 0})

	require.False(t, pending)
}

// A deposit the network dropped must release the slot, or the user never
// deposits to it again.
func TestCtipStillPendingPassesWhenTheChainLostTheDeposit(t *testing.T) {
	pending := ctipStillPending("ctip-txid", "deposit-txid", mempoolDeposit{found: false})

	require.False(t, pending)
}

// A confirmed deposit spends nothing more. A stale ctip is the enforcer's lag,
// and Core reports a spent input on its own.
func TestCtipStillPendingPassesOnAConfirmedDeposit(t *testing.T) {
	pending := ctipStillPending("ctip-txid", "deposit-txid", mempoolDeposit{found: true, confirmations: 3})

	require.False(t, pending)
}

func TestCtipStillPendingPassesWithNoDepositOnRecord(t *testing.T) {
	pending := ctipStillPending("ctip-txid", "", mempoolDeposit{found: true, confirmations: 0})

	require.False(t, pending)
}
