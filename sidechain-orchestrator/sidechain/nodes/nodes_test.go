package nodes

import (
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bbc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/freebank"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/solana"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
)

// Two transports carry connect_block, and both give it its own deadline. A
// chain that arrives with a client of its own would cap connect_block at the
// ordinary 30 seconds, so it fails here first.
func TestEveryBmmSidechainTakesAnAuditedTransport(t *testing.T) {
	chains := []struct {
		name string
		core bool
	}{
		{name: "thunder"},
		{name: "bitnames"},
		{name: "coinshift"},
		{name: "truthcoin"},
		{name: "zside"},
		{name: "solana"},
		{name: "bbc", core: true},
		{name: "freebank", core: true},
	}

	for _, chain := range chains {
		t.Run(chain.name, func(t *testing.T) {
			node, err := New(chain.name, "127.0.0.1", 1, chain.core, config.NetworkSignet)
			require.NoError(t, err)

			bmm, ok := node.(sidechain.BMMNode)
			require.True(t, ok, "the BMM engine drives this chain")

			switch bmm.(type) {
			case *sidechain.JSONRPCProxy, *bbc.Client, *freebank.Client, *zside.Node, *thunder.Node, *solana.Client:
			default:
				assert.Failf(t, "unaudited transport", "%s takes %T", chain.name, bmm)
			}
		})
	}
}

func TestSelfMinedSidechainIsNoBmmNode(t *testing.T) {
	for _, name := range []string{"bitassets", "photon"} {
		t.Run(name, func(t *testing.T) {
			node, err := New(name, "127.0.0.1", 1, false, config.NetworkSignet)
			require.NoError(t, err)

			_, isBMM := node.(sidechain.BMMNode)
			assert.False(t, isBMM, "the node serves no block template")
			_, proposes := node.(sidechain.WithdrawalNode)
			assert.True(t, proposes, "the node proposes withdrawal bundles")
		})
	}
}

func TestProxySendsTheNodeCookie(t *testing.T) {
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir("") })

	var got string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		got = r.Header.Get("Authorization")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":1}`))
	}))
	t.Cleanup(srv.Close)
	host, portText, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)

	writeCookie := func(t *testing.T, path string) {
		t.Helper()
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
		require.NoError(t, os.WriteFile(path, []byte("abc123"), 0o600))
	}
	writeCookie(t, truthcoin.CookieFile(config.NetworkSignet))
	writeCookie(t, coinshift.CookieFile(config.NetworkSignet))

	for name, want := range map[string]string{
		"truthcoin": "Bearer abc123",
		"coinshift": "Bearer abc123",
		"thunder":   "",
	} {
		t.Run(name, func(t *testing.T) {
			got = "unset"
			node, err := New(name, host, port, false, config.NetworkSignet)
			require.NoError(t, err)

			_, err = node.GetBlockCount(t.Context())
			require.NoError(t, err)
			assert.Equal(t, want, got)
		})
	}
}
