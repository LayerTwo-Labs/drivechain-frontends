package api

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	bitassetssvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
)

// GetSyncStatus shows FreeBank with its own type.
func TestSidechainTypeFromNameKnowsFreebank(t *testing.T) {
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_FREEBANK, sidechainTypeFromName("freebank"))
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_BITASSETS, sidechainTypeFromName("bitassets"))
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_UNSPECIFIED, sidechainTypeFromName("nosuchchain"))
}

// FreeBank has no "balance" RPC, so its balance comes from bitcoin_balance.
func TestFreebankBalanceUsesBitcoinBalanceMethod(t *testing.T) {
	var gotMethod string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			ID     uint64 `json:"id"`
			Method string `json:"method"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		gotMethod = req.Method
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":{"total_sats":300,"available_sats":125}}`))
	}))
	defer srv.Close()
	host, port := hostPort(t, srv)

	bh := bitassetssvc.NewHandler(sidechain.NewJSONRPCProxy(host, port))
	h := &Handler{
		orch:              &orchestrator.Orchestrator{Network: string(config.NetworkRegtest)},
		sidechainBalances: map[string]SidechainBalanceFunc{"freebank": bh.WalletBalance},
	}

	confirmed, pending, err := h.fetchSidechainBalance(
		context.Background(),
		orchestrator.BinaryConfig{Name: "freebank", Host: host, Port: port},
	)
	require.NoError(t, err)
	assert.Equal(t, "bitcoin_balance", gotMethod)
	assert.Equal(t, int64(125), confirmed)
	assert.Equal(t, int64(175), pending)
}
