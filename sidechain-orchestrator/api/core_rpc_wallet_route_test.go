package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// newCoreRPCStub stands in for bitcoind's JSON-RPC endpoint, echoing back the
// request URI it was hit with so tests can assert wallet routing exactly.
func newCoreRPCStub(t *testing.T) (*Handler, *atomic.Int32) {
	t.Helper()

	var hits atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hits.Add(1)
		w.Header().Set("Content-Type", "application/json")
		_, _ = fmt.Fprintf(w, `{"result":%q,"error":null}`, r.RequestURI)
	}))
	t.Cleanup(srv.Close)

	addr, ok := srv.Listener.Addr().(*net.TCPAddr)
	require.True(t, ok)

	cfg := config.NewBitcoinConfig()
	cfg.SetSetting("rpcport", strconv.Itoa(addr.Port))

	h := NewHandler(&orchestrator.Orchestrator{
		BitcoinConf: &config.BitcoinConfManager{
			Network: config.NetworkRegtest,
			Config:  cfg,
		},
	})
	return h, &hits
}

// calledURI runs a wallet-scoped call against the stub and returns the URI the
// stub saw.
func calledURI(t *testing.T, h *Handler, wallet string) string {
	t.Helper()
	raw, err := h.RawCoreCall(context.Background(), "getbalance", "[]", wallet)
	require.NoError(t, err)
	var uri string
	require.NoError(t, json.Unmarshal(raw, &uri))
	return uri
}

func TestCallCoreRPCEscapesWalletSegment(t *testing.T) {
	h, _ := newCoreRPCStub(t)

	assert.Equal(t, "/wallet/wallet%20with%20spaces", calledURI(t, h, "wallet with spaces"))
	assert.Equal(t, "/wallet/multisig_1", calledURI(t, h, "multisig_1"))
	assert.Equal(t, "/", calledURI(t, h, ""))
}

func TestCallCoreRPCRejectsWalletRouteEscape(t *testing.T) {
	// A wallet name carrying a URL separator must never reach bitcoind — it
	// would re-route the call to a different loaded wallet.
	for _, wallet := range []string{
		"foo?bar=baz",
		"foo#frag",
		"../other",
		"..",
		".",
	} {
		t.Run(wallet, func(t *testing.T) {
			h, hits := newCoreRPCStub(t)

			_, err := h.RawCoreCall(context.Background(), "getbalance", "[]", wallet)
			require.Error(t, err)
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
			assert.Zero(t, hits.Load(), "no request should have been sent")
		})
	}
}
