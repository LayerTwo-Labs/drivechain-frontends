package wallet

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
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

// replayNetworks are two eCash networks whose nodes accept different replay
// locktimes.
var replayNetworks = []struct {
	name     string
	lockTime uint32
	other    uint32
}{
	{name: "betanet", lockTime: 499999999, other: 499999998},
	{name: "mainnet", lockTime: 499999998, other: 499999999},
}

// useECashReplayLockTime makes lockTime the live eCash network's replay
// locktime for the rest of the test.
func useECashReplayLockTime(t *testing.T, lockTime uint32) {
	t.Helper()
	previous := config.ECashEndpoints()
	t.Cleanup(func() { config.SetECashEndpoints(previous) })
	entry := previous
	entry.ReplayLockTime = lockTime
	config.SetECashEndpoints(entry)
}
