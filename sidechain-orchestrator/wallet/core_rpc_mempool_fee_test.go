package wallet

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMempoolMinFeeRate(t *testing.T) {
	tests := []struct {
		name          string
		mempoolMinFee float64
		minRelayTxFee float64
		wantRate      float64
		wantErr       bool
	}{
		{
			name:          "default core floor is one sat per vbyte",
			mempoolMinFee: 0.00001,
			minRelayTxFee: 0.00001,
			wantRate:      1,
		},
		{
			name:          "a raised minrelaytxfee wins",
			mempoolMinFee: 0.00001,
			minRelayTxFee: 0.0001,
			wantRate:      10,
		},
		{
			name:          "a full mempool raises the floor above the config",
			mempoolMinFee: 0.00025,
			minRelayTxFee: 0.00001,
			wantRate:      25,
		},
		{
			name:          "no floor at all is an error",
			mempoolMinFee: 0,
			minRelayTxFee: 0,
			wantErr:       true,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			fake := newFakeBitcoind(t)
			fake.handle("getmempoolinfo", func(bitcoindCall) (any, string) {
				return map[string]any{
					"mempoolminfee": test.mempoolMinFee,
					"minrelaytxfee": test.minRelayTxFee,
				}, ""
			})

			rate, err := fake.client(t).MempoolMinFeeRate(context.Background())
			if test.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			require.InDelta(t, test.wantRate, rate, 0.0001)
		})
	}
}
