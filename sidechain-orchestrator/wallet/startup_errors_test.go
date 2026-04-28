package wallet

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIsTransientWalletErr(t *testing.T) {
	cases := []struct {
		err  error
		want bool
		name string
	}{
		{nil, false, "nil"},
		{errors.New("loadwallet RPC error -4: Wallet already loading."), true, "wallet-already-loading"},
		{errors.New("loadwallet RPC error -28: Verifying blocks…"), true, "verifying-blocks"},
		{errors.New("rescan in progress: Still rescanning. At block 470818"), true, "still-rescanning"},
		{errors.New("loadwallet RPC error -1: not allowed"), false, "non-transient-error"},
		{errors.New("connection refused"), false, "connection-refused-not-classified"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, IsTransientWalletErr(tc.err))
		})
	}
}
