package wallet

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCancelFeeSats(t *testing.T) {
	tests := []struct {
		name                 string
		evictedSats          int64
		vsize                int64
		incrementalSatPerKvB int64
		rateSatPerVB         int64
		want                 int64
	}{
		{name: "outpays the evicted fees and its own size", evictedSats: 5_000, vsize: 200, incrementalSatPerKvB: 1_000, want: 5_200},
		{name: "rounds the incremental fee up", evictedSats: 5_000, vsize: 201, incrementalSatPerKvB: 100, want: 5_021},
		{name: "pays the market rate when it is higher", evictedSats: 2_000, vsize: 200, incrementalSatPerKvB: 1_000, rateSatPerVB: 20, want: 4_000},
		{name: "pays the floor when it evicts nothing", vsize: 200, incrementalSatPerKvB: 1_000, want: cancelMinFeeSats},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.want, CancelFeeSats(tt.evictedSats, tt.vsize, tt.incrementalSatPerKvB, tt.rateSatPerVB))
		})
	}
}

func TestPlanCancel(t *testing.T) {
	own := []RequiredInput{{TxID: "aa", Vout: 0, AmountSats: 150_000}, {TxID: "bb", Vout: 1, AmountSats: 50_000}}

	plan, reason := planCancel(cancelTx{
		VsizeVBytes: 300, OwnInputs: own, EvictedFeeSats: 6_000,
		IncrementalSatPerKvB: 1_000, ChangeKind: ScriptNativeSegwit,
	})
	require.NotNil(t, plan, reason)
	assert.Equal(t, int64(6_000+300+2+31), plan.FeeSats, "the size bound holds every own input and one change output")
	assert.Equal(t, 200_000-plan.FeeSats, plan.RecoveredSats)
	assert.Equal(t, own, plan.Inputs)

	plan, reason = planCancel(cancelTx{VsizeVBytes: 300, IncrementalSatPerKvB: 1_000})
	assert.Nil(t, plan)
	assert.Contains(t, reason, "signs none of the inputs")

	plan, reason = planCancel(cancelTx{
		VsizeVBytes: 300, OwnInputs: []RequiredInput{{TxID: "aa", AmountSats: 1_500}},
		IncrementalSatPerKvB: 1_000, ChangeKind: ScriptNativeSegwit,
	})
	assert.Nil(t, plan, "a cancel that returns dust gives the coins to the miner")
	assert.Contains(t, reason, "under the 1000 sat cancel fee plus dust")
}
