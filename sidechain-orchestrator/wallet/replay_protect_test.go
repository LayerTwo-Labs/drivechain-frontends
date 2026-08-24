package wallet

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestReplayProtect(t *testing.T) {
	cases := []struct {
		network     string
		allowReplay bool
		want        bool
	}{
		{network: "ecash", want: true},
		{network: "ecash", allowReplay: true},
		{network: "mainnet"},
		{network: "forknet"},
		{network: "signet"},
		{network: "regtest"},
		{network: ""},
	}
	for _, c := range cases {
		t.Run(c.network, func(t *testing.T) {
			require.Equal(t, c.want, ReplayProtect(c.network, c.allowReplay))
		})
	}
}
