package engines

import (
	"errors"
	"testing"
)

func TestIsWalletAlreadyLoadedErr(t *testing.T) {
	cases := []struct {
		name string
		err  error
		want bool
	}{
		{"nil", nil, false},
		{
			"bitcoind -35",
			errors.New(`unknown: -35: Wallet "cheque_watch" is already loaded.`),
			true,
		},
		{"unrelated", errors.New("-18: Requested wallet does not exist or is not loaded"), false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := IsWalletAlreadyLoadedErr(tc.err); got != tc.want {
				t.Fatalf("IsWalletAlreadyLoadedErr(%v) = %v, want %v", tc.err, got, tc.want)
			}
		})
	}
}
