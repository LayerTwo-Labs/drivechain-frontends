package chaindata

import (
	"context"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
)

func TestInterceptorAnswersRepeatedReadsFromMemory(t *testing.T) {
	core := newFakeCore()
	e := startEngine(t, core)
	e.zmqUp.Store(true)
	var calls atomic.Int32
	next := connect.UnaryFunc(func(context.Context, connect.AnyRequest) (connect.AnyResponse, error) {
		calls.Add(1)
		return connect.NewResponse(&corepb.ListTransactionsResponse{}), nil
	})
	handler := e.Interceptor().WrapUnary(next)

	read := func(procedure string) {
		req := connect.NewRequest(&corepb.ListTransactionsRequest{})
		_, err := handler(t.Context(), &specRequest{Request: req, procedure: procedure})
		require.NoError(t, err)
	}
	for range 5 {
		read("/bitcoin.bitcoind.v1alpha.BitcoinService/ListTransactions")
	}
	require.Equal(t, int32(1), calls.Load())

	read("/bitcoin.bitcoind.v1alpha.BitcoinService/CreateWallet")
	require.Eventually(t, func() bool { return calls.Load() == 3 }, time.Second, time.Millisecond, "a write refreshes the used read")
}

type specRequest struct {
	*connect.Request[corepb.ListTransactionsRequest]
	procedure string
}

func (r *specRequest) Spec() connect.Spec { return connect.Spec{Procedure: r.procedure} }
