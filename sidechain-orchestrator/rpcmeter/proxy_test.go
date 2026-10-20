package rpcmeter

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

type testBitcoinService struct {
	corerpc.UnimplementedBitcoinServiceHandler
	failure atomic.Bool
}

func (s *testBitcoinService) GetBlockchainInfo(context.Context, *connect.Request[corepb.GetBlockchainInfoRequest]) (*connect.Response[corepb.GetBlockchainInfoResponse], error) {
	if s.failure.Load() {
		return nil, connect.NewError(connect.CodeUnavailable, errors.New("the node is offline"))
	}
	return connect.NewResponse(&corepb.GetBlockchainInfoResponse{Blocks: 42}), nil
}

func TestProxyAuthAndMetrics(t *testing.T) {
	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)
	meter := New(t.Context(), zerolog.Nop(), 0)
	service := new(testBitcoinService)
	mux := http.NewServeMux()
	mux.Handle(corerpc.NewBitcoinServiceHandler(service,
		connect.WithInterceptors(localauth.Interceptor(dir), meter.Interceptor()),
	))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	client := corerpc.NewBitcoinServiceClient(server.Client(), server.URL)
	_, err = client.GetBlockchainInfo(t.Context(), connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	require.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
	meter.mu.Lock()
	require.Empty(t, meter.stats)
	meter.mu.Unlock()

	client = corerpc.NewBitcoinServiceClient(server.Client(), server.URL,
		connect.WithInterceptors(localauth.Interceptor(dir)),
	)
	response, err := client.GetBlockchainInfo(t.Context(), connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	require.NoError(t, err)
	require.Equal(t, uint32(42), response.Msg.Blocks)
	service.failure.Store(true)
	_, err = client.GetBlockchainInfo(t.Context(), connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))

	meter.mu.Lock()
	defer meter.mu.Unlock()
	stat := meter.stats["GetBlockchainInfo"]
	require.NotNil(t, stat)
	require.Equal(t, int64(2), stat.count)
	require.Equal(t, int64(1), stat.errors)
	require.Positive(t, stat.totalDur)
}
