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

// FreeBank is a plain-bitassets fork, so the sync-status enumeration must carry
// it with a typed value exactly as it carries bitassets — otherwise
// GetSyncStatus drops slot 130 as UNSPECIFIED and no frontend can render it.
func TestFreebankSyncStatusEnumeratedLikeBitassets(t *testing.T) {
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_FREEBANK, sidechainTypeFromName("freebank"))
	// The bitassets arm it mirrors is unchanged, and an unknown name still
	// drops to UNSPECIFIED so callers keep skipping it.
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_BITASSETS, sidechainTypeFromName("bitassets"))
	assert.Equal(t, pb.SidechainType_SIDECHAIN_TYPE_UNSPECIFIED, sidechainTypeFromName("nosuchchain"))
}

// FreeBank's wallet answers bitcoin_balance, not the JSON-RPC proxy's default
// "balance" method (which freebankd does not implement and answers -32601). The
// registered balance reader — the same bitassets handler the daemon wires for
// it — must dispatch bitcoin_balance.
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

	// Wire the reader the way cmd/drivechaind does for the "freebank" arm.
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
