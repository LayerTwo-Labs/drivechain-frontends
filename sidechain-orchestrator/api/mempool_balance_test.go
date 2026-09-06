package api

import "testing"

// A spend of ours makes the delta negative. An unsigned cast of that turns a
// smaller balance into a near maximum one.
func TestApplyMempoolDeltaNeverReportsLessThanNothing(t *testing.T) {
	for _, tc := range []struct {
		name                       string
		confirmed, pending, delta  int64
		wantConfirmed, wantPending int64
	}{
		{"a payment on its way waits in pending", 5000, 0, 2000, 5000, 2000},
		{"a spend takes from pending first", 5000, 3000, -1000, 5000, 2000},
		{"a bigger spend then takes from the confirmed coins", 5000, 1000, -3000, 3000, 0},
		{"a spend of everything leaves nothing", 1000, 0, -4000, 0, 0},
		{"no mempool means no change", 5000, 250, 0, 5000, 250},
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
