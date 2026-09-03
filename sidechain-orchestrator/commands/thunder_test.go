package commands

import (
	"testing"

	thunderpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
)

func TestTxStateReadsTheChain(t *testing.T) {
	tests := []struct {
		name string
		tx   *thunderpb.SidechainWalletTransaction
		tip  uint32
		want string
	}{
		{
			name: "no block carries it",
			tx:   &thunderpb.SidechainWalletTransaction{},
			tip:  24,
			want: "pending",
		},
		{
			name: "the tip carries it",
			tx:   &thunderpb.SidechainWalletTransaction{Confirmed: true, BlockHeight: 24},
			tip:  24,
			want: "height 24 (1 confirmations)",
		},
		{
			name: "three blocks cover it",
			tx:   &thunderpb.SidechainWalletTransaction{Confirmed: true, BlockHeight: 22},
			tip:  24,
			want: "height 22 (3 confirmations)",
		},
		{
			// A node reports no height for the coins it holds, so a full-mode
			// row carries none. A depth over height zero would be invented.
			name: "the answer names no height",
			tx:   &thunderpb.SidechainWalletTransaction{Confirmed: true},
			tip:  24,
			want: "confirmed",
		},
		{
			// The index lags the node, so a block can name a height above the
			// tip the same answer carries.
			name: "the tip is behind the block",
			tx:   &thunderpb.SidechainWalletTransaction{Confirmed: true, BlockHeight: 25},
			tip:  24,
			want: "height 25 (0 confirmations)",
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := txState(test.tx, test.tip); got != test.want {
				t.Errorf("txState = %q, want %q", got, test.want)
			}
		})
	}
}
