package nodes

import (
	"context"
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
			case *sidechain.JSONRPCProxy, *bbc.Client, *freebank.Client, *zside.Node, *solana.Client:
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

type bootHost struct {
	sidechain.Host
	backendOnly bool
}

func (h bootHost) BackendOnly() bool { return h.backendOnly }

// The seeds the betanet nodes hold do not answer, so a bare node with no seed
// peer of ours syncs no block.
func TestBareBetanetNodeDialsTheSeedHost(t *testing.T) {
	original := config.ECashNetworkID()
	t.Cleanup(func() { config.SetECashNetworkID(original) })
	config.SetECashNetworkID("betanet")

	for name, want := range map[string][]string{
		"thunder":   {"--headless", "--add-peer=seed.beta.ecash.eu.com:4009"},
		"bitnames":  {"--headless", "--add-peer=seed.beta.ecash.eu.com:4002"},
		"bitassets": {"--headless", "--add-peer=seed.beta.ecash.eu.com:4004"},
		"coinshift": {"--headless", "--add-peer=seed.beta.ecash.eu.com:4255"},
		"truthcoin": {"--headless", "--add-peer=seed.beta.ecash.eu.com:4013"},
		"zside":     {"--headless", "--add-peer=seed.beta.ecash.eu.com:4098"},
		// Photon takes no --add-peer, and an unknown flag stops its node.
		"photon": {"--headless"},
	} {
		t.Run(name, func(t *testing.T) {
			node, err := New(name, "127.0.0.1", 1, false, config.NetworkECash)
			require.NoError(t, err)

			args, err := node.Args(context.Background(), bootHost{backendOnly: true})
			require.NoError(t, err)
			assert.Equal(t, want, args)

			args, err = node.Args(context.Background(), bootHost{})
			require.NoError(t, err)
			assert.Empty(t, args, "the frontend build takes no node argument")
		})
	}
}

func TestNodeOffBetanetKeepsItsOwnSeeds(t *testing.T) {
	original := config.ECashNetworkID()
	t.Cleanup(func() { config.SetECashNetworkID(original) })

	for _, test := range []struct {
		generation string
		network    config.Network
	}{
		{generation: "betanet", network: config.NetworkSignet},
		{generation: "betanet", network: config.NetworkRegtest},
		{generation: "ecash", network: config.NetworkECash},
	} {
		t.Run(test.generation+"/"+string(test.network), func(t *testing.T) {
			config.SetECashNetworkID(test.generation)
			node, err := New("zside", "127.0.0.1", 1, false, test.network)
			require.NoError(t, err)

			args, err := node.Args(context.Background(), bootHost{backendOnly: true})
			require.NoError(t, err)
			assert.Equal(t, []string{"--headless"}, args)
		})
	}
}
