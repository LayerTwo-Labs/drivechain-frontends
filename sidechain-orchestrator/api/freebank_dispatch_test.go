package api

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

// GetSyncStatus shows FreeBank with its own type.
func TestSidechainTypeFromNameKnowsFreebank(t *testing.T) {
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_FREEBANK, sidechainTypeFromName("freebank"))
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_BITASSETS, sidechainTypeFromName("bitassets"))
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_UNSPECIFIED, sidechainTypeFromName("nosuchchain"))
}

// FreeBank keeps the one wallet its node created and predates getbalances, so
// its balance is getwalletinfo, asked at the root endpoint with the cookie.
func TestFreebankBalanceReadsItsOwnWallet(t *testing.T) {
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir("") })
	datadir := config.FreebankDirs.DatadirNetwork(config.NetworkRegtest, "")
	require.NoError(t, os.MkdirAll(datadir, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(datadir, ".cookie"), []byte("__cookie__:secret"), 0o600))

	var gotPath, gotMethod, gotUser string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string `json:"method"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		gotPath, gotMethod = r.URL.Path, req.Method
		gotUser, _, _ = r.BasicAuth()
		_, _ = w.Write([]byte(`{"result":{"balance":1.0,"unconfirmed_balance":0.25,"immature_balance":0.5},"error":null}`))
	}))
	defer srv.Close()
	host, port := hostPort(t, srv)

	h := &Handler{orch: &orchestrator.Orchestrator{Network: string(config.NetworkRegtest)}}
	confirmed, pending, err := h.fetchSidechainBalance(
		context.Background(),
		orchestrator.BinaryConfig{Name: "freebank", Host: host, Port: port, IsBitcoinCore: true},
	)
	require.NoError(t, err)
	assert.Equal(t, "/", gotPath)
	assert.Equal(t, "getwalletinfo", gotMethod)
	assert.Equal(t, "__cookie__", gotUser)
	assert.Equal(t, int64(100_000_000), confirmed)
	assert.Equal(t, int64(75_000_000), pending)
}
