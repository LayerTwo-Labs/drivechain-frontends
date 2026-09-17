package engines

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/stretchr/testify/assert"
)

func TestWaitsForCore(t *testing.T) {
	tests := []struct {
		name    string
		inIBD   bool
		network config.Network
		want    bool
	}{
		{"mainnet in IBD waits", true, config.NetworkMainnet, true},
		{"ecash in IBD waits", true, config.NetworkECash, true},
		{"mainnet past IBD scans", false, config.NetworkMainnet, false},
		{"regtest in IBD scans", true, config.NetworkRegtest, false},
		{"signet in IBD scans", true, config.NetworkSignet, false},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, WaitsForCore(tc.inIBD, tc.network))
		})
	}
}
