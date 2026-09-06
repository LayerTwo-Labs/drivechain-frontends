package api

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// A coin the mempool spends leaves the confirmed count, and a coin on its way
// joins the pending one. One net figure loses that split, and the view then
// calls unconfirmed change a confirmed balance.
func TestApplyMempoolDeltaSplitsTheCreditFromTheDebit(t *testing.T) {
	for _, tc := range []struct {
		name                       string
		confirmed, pending         int64
		delta                      sidechain.MempoolDelta
		wantConfirmed, wantPending int64
	}{
		{
			name:      "a payment on its way waits in pending",
			confirmed: 5000, pending: 0,
			delta:         sidechain.MempoolDelta{CreditSats: 2000},
			wantConfirmed: 5000, wantPending: 2000,
		},
		{
			name:      "a spend of ours moves the whole coin out of confirmed",
			confirmed: 10_000, pending: 0,
			delta:         sidechain.MempoolDelta{CreditSats: 9000, DebitSats: 10_000},
			wantConfirmed: 0, wantPending: 9000,
		},
		{
			name:      "an unrelated receipt stays pending beside the spend",
			confirmed: 10_000, pending: 3000,
			delta:         sidechain.MempoolDelta{CreditSats: 9000, DebitSats: 10_000},
			wantConfirmed: 0, wantPending: 12_000,
		},
		{
			name:      "a debit past the confirmed coins takes the rest from pending",
			confirmed: 1000, pending: 2000,
			delta:         sidechain.MempoolDelta{DebitSats: 2500},
			wantConfirmed: 0, wantPending: 500,
		},
		{
			// A child spends a coin its parent made, so both count gross.
			name:      "a chained spend takes its debit from the new credit",
			confirmed: 0, pending: 0,
			delta:         sidechain.MempoolDelta{CreditSats: 19_000, DebitSats: 10_000},
			wantConfirmed: 0, wantPending: 9000,
		},
		{
			name:      "no mempool means no change",
			confirmed: 5000, pending: 250,
			delta:         sidechain.MempoolDelta{},
			wantConfirmed: 5000, wantPending: 250,
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			confirmed, pending := applyMempoolDelta(tc.confirmed, tc.pending, tc.delta)
			if confirmed != tc.wantConfirmed || pending != tc.wantPending {
				t.Errorf("confirmed=%d pending=%d, want %d and %d",
					confirmed, pending, tc.wantConfirmed, tc.wantPending)
			}
			if confirmed < 0 || pending < 0 {
				t.Error("a balance reads below nothing, and it casts to a huge number")
			}
		})
	}
}
