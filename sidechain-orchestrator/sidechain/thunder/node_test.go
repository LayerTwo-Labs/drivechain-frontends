package thunder

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

type bootHost struct {
	sidechain.Host
	backendOnly bool
}

func (h bootHost) BackendOnly() bool { return h.backendOnly }

func TestNodeArgs(t *testing.T) {
	for _, test := range []struct {
		name        string
		network     string
		backendOnly bool
		want        []string
	}{
		{
			name: "a bare betanet node dials the seed", network: "betanet", backendOnly: true,
			want: []string{"--headless", "--add-peer=seed.beta.ecash.eu.com:4009"},
		},
		{name: "another network keeps its own seeds", network: "signet", backendOnly: true, want: []string{"--headless"}},
		{name: "the frontend build takes no node argument", network: "betanet"},
	} {
		t.Run(test.name, func(t *testing.T) {
			args, err := NewNode("127.0.0.1", 1, test.network).Args(context.Background(), bootHost{backendOnly: test.backendOnly})
			require.NoError(t, err)
			assert.Equal(t, test.want, args)
		})
	}
}
