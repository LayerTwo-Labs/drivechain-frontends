package api

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// hostPort splits a test server's URL into the two fields a BinaryConfig holds.
func hostPort(t *testing.T, srv *httptest.Server) (string, int) {
	t.Helper()
	parsed, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portText, err := net.SplitHostPort(parsed.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return host, port
}

// A CUSF chain answers every interface, so nothing about it is optional.
func TestCusfChainSatisfiesEveryInterface(t *testing.T) {
	node, err := sidechainNode(orchestrator.BinaryConfig{Name: "thunder", Port: 6009}, config.NetworkRegtest)
	require.NoError(t, err)

	_, drivesBMM := node.(sidechain.BMMNode)
	assert.True(t, drivesBMM)
	_, proposesBundles := node.(sidechain.WithdrawalNode)
	assert.True(t, proposesBundles)
}

// A Core fork answers what it answers. Bbc drives BMM and settles withdrawals
// elsewhere, so the caller reads that from the type.
func TestCoreForkAnswersOnlyWhatItDrives(t *testing.T) {
	cfg := orchestrator.BinaryConfig{Name: "bbc", DisplayName: "Big Block Covenant", Port: 18743, IsBitcoinCore: true}
	node, err := sidechainNode(cfg, config.NetworkRegtest)
	require.NoError(t, err)

	bmm, err := bmmNode(cfg, config.NetworkRegtest)
	require.NoError(t, err)
	assert.NotNil(t, bmm)

	_, err = withdrawalNode(node, cfg.DisplayName)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Big Block Covenant")
	assert.Contains(t, err.Error(), "proposes no withdrawal bundle")
}

// FreeBank blind merge mines with its own refreshbmm ticker and settles
// withdrawals on its own paths, so it is a Node and nothing more.
func TestFreebankAnswersNeitherBMMNorWithdrawals(t *testing.T) {
	cfg := orchestrator.BinaryConfig{Name: "freebank", DisplayName: "FreeBank", Port: 8342, IsBitcoinCore: true}
	node, err := sidechainNode(cfg, config.NetworkRegtest)
	require.NoError(t, err)

	_, err = bmmNode(cfg, config.NetworkRegtest)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "FreeBank")
	assert.Contains(t, err.Error(), "produces its own blocks")

	_, err = withdrawalNode(node, cfg.DisplayName)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "proposes no withdrawal bundle")
}

// A chain with no directory config names itself in the failure, rather than
// dialling a port that belongs to something else.
func TestCoreForkWithoutDirsFails(t *testing.T) {
	_, err := sidechainNode(orchestrator.BinaryConfig{Name: "nosuchchain", IsBitcoinCore: true}, config.NetworkRegtest)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "nosuchchain")
}

// One balance path serves every chain. It reads the node the config names, and
// counts what is not spendable as pending.
func TestBalanceReadsTheNodeTheConfigNames(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":{"total_sats":300,"available_sats":125}}`))
	}))
	defer srv.Close()
	host, port := hostPort(t, srv)

	h := &Handler{orch: &orchestrator.Orchestrator{Network: string(config.NetworkRegtest)}}
	confirmed, pending, err := h.fetchSidechainBalance(
		context.Background(),
		orchestrator.BinaryConfig{Name: "bitnames", Host: host, Port: port},
	)
	require.NoError(t, err)
	assert.Equal(t, int64(125), confirmed)
	assert.Equal(t, int64(175), pending)
}

func TestThunderBalanceUsesTheRegisteredHandler(t *testing.T) {
	h := &Handler{
		orch: &orchestrator.Orchestrator{Network: string(config.NetworkRegtest)},
		sidechainBalances: map[string]SidechainBalanceFunc{
			"thunder": func(context.Context) (int64, int64, error) {
				return 900, 400, nil
			},
		},
	}
	confirmed, pending, err := h.fetchSidechainBalance(
		context.Background(),
		// A port nothing listens on: a dial here fails the test.
		orchestrator.BinaryConfig{Name: "thunder", Host: "127.0.0.1", Port: 1},
	)
	require.NoError(t, err)
	assert.Equal(t, int64(400), confirmed)
	assert.Equal(t, int64(500), pending)
}
