package thunder

import "testing"

// This rule decides whether a request reads the node or the index. Getting it
// wrong either sends a running node's wallet to a third party, or leaves a
// light install asking a binary that is not there.
func TestNewModePicksTheRightWallet(t *testing.T) {
	const hosted = "https://index.example/thunder"

	for _, test := range []struct {
		name      string
		light     bool
		indexURL  string
		localNode bool
	}{
		{
			name:      "a light install with an index runs no node",
			light:     true,
			indexURL:  hosted,
			localNode: false,
		},
		{
			name:      "a network with no index falls back to the node",
			light:     true,
			indexURL:  "",
			localNode: true,
		},
		{
			name:      "a full install keeps its node, and reads history there",
			light:     false,
			indexURL:  hosted,
			localNode: true,
		},
		{
			name:      "a full install with no index reads only the node",
			light:     false,
			indexURL:  "",
			localNode: true,
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			mode := NewMode(test.light, test.indexURL, nil)
			if mode.LocalNode != test.localNode {
				t.Errorf("LocalNode = %v, want %v", mode.LocalNode, test.localNode)
			}
			if mode.IndexURL != test.indexURL {
				t.Errorf("IndexURL = %q, want %q", mode.IndexURL, test.indexURL)
			}
		})
	}
}
