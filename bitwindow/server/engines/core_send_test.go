package engines_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

func TestSendCoreWithRequiredInputs(t *testing.T) {
	t.Parallel()

	const trackedTxid = "aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11"
	const otherTxid = "bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22bb22"

	t.Run("spends only the required outpoint", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: trackedTxid, Vout: 3, Amount: 1.0},
					{Txid: otherTxid, Vout: 0, Amount: 5.0},
				},
			}), nil)

		mockBitcoind.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.GetNewAddressResponse{
				Address: "tb1qchange0000000000000000000000000000000",
			}), nil)

		// Stop at raw transaction creation: everything the fix is about is
		// visible in that request.
		stop := errors.New("stop")
		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(_ context.Context, req *connect.Request[corepb.CreateRawTransactionRequest]) (*connect.Response[corepb.CreateRawTransactionResponse], error) {
				require.Len(t, req.Msg.Inputs, 1)
				assert.Equal(t, trackedTxid, req.Msg.Inputs[0].Txid)
				assert.Equal(t, uint32(3), req.Msg.Inputs[0].Vout)

				// 1 BTC in, 0.4 BTC out, 10k sats fee -> the rest is change.
				assert.Equal(t, 0.4, req.Msg.Outputs["tb1qdest00000000000000000000000000000000"])
				assert.Equal(t, 0.5999, req.Msg.Outputs["tb1qchange0000000000000000000000000000000"])
				return nil, stop
			})

		_, err := engines.SendCoreWithRequiredInputs(context.Background(), mockBitcoind, "wallet",
			[]engines.CoreOutpoint{{Txid: trackedTxid, Vout: 3}},
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 40_000_000},
			0, 10_000,
		)
		require.ErrorIs(t, err, stop)
	})

	t.Run("does not bill a change output that is never created", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: trackedTxid, Vout: 3, Amount: 0.0001},
				},
			}), nil)

		stop := errors.New("stop")
		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(_ context.Context, req *connect.Request[corepb.CreateRawTransactionRequest]) (*connect.Response[corepb.CreateRawTransactionResponse], error) {
				// 10,000 sats in, 9,780 out, 220 sats fee (110 vB at 2
				// sat/vB) and no change output.
				require.Len(t, req.Msg.Outputs, 1)
				assert.Equal(t, 0.0000978, req.Msg.Outputs["tb1qdest00000000000000000000000000000000"])
				return nil, stop
			})

		_, err := engines.SendCoreWithRequiredInputs(context.Background(), mockBitcoind, "wallet",
			[]engines.CoreOutpoint{{Txid: trackedTxid, Vout: 3}},
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 9_780},
			2, 0,
		)
		require.ErrorIs(t, err, stop)
	})

	t.Run("drops a change output it did not budget for", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: trackedTxid, Vout: 3, Amount: 0.001},
				},
			}), nil)

		stop := errors.New("stop")
		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(_ context.Context, req *connect.Request[corepb.CreateRawTransactionRequest]) (*connect.Response[corepb.CreateRawTransactionResponse], error) {
				// 100,000 sats in, 99,210 out: the 570 sat remainder is above
				// dust but too small to also pay for the change output, so the
				// whole remainder goes to fee rather than underpaying it.
				require.Len(t, req.Msg.Outputs, 1)
				assert.Equal(t, 0.0009921, req.Msg.Outputs["tb1qdest00000000000000000000000000000000"])
				return nil, stop
			})

		_, err := engines.SendCoreWithRequiredInputs(context.Background(), mockBitcoind, "wallet",
			[]engines.CoreOutpoint{{Txid: trackedTxid, Vout: 3}},
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 99_210},
			2, 0,
		)
		require.ErrorIs(t, err, stop)
	})

	t.Run("bills the change output when change is created", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: trackedTxid, Vout: 3, Amount: 1.0},
				},
			}), nil)

		mockBitcoind.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.GetNewAddressResponse{
				Address: "tb1qchange0000000000000000000000000000000",
			}), nil)

		stop := errors.New("stop")
		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(_ context.Context, req *connect.Request[corepb.CreateRawTransactionRequest]) (*connect.Response[corepb.CreateRawTransactionResponse], error) {
				// 1 BTC in, 0.4 BTC out, 282 sats fee (141 vB at 2 sat/vB,
				// change output included) -> the rest is change.
				assert.Equal(t, 0.4, req.Msg.Outputs["tb1qdest00000000000000000000000000000000"])
				assert.Equal(t, 0.59999718, req.Msg.Outputs["tb1qchange0000000000000000000000000000000"])
				return nil, stop
			})

		_, err := engines.SendCoreWithRequiredInputs(context.Background(), mockBitcoind, "wallet",
			[]engines.CoreOutpoint{{Txid: trackedTxid, Vout: 3}},
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 40_000_000},
			2, 0,
		)
		require.ErrorIs(t, err, stop)
	})

	t.Run("errors when the required outpoint is not in the wallet", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: otherTxid, Vout: 0, Amount: 5.0},
				},
			}), nil)

		_, err := engines.SendCoreWithRequiredInputs(context.Background(), mockBitcoind, "wallet",
			[]engines.CoreOutpoint{{Txid: trackedTxid, Vout: 3}},
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 40_000_000},
			0, 10_000,
		)
		require.ErrorContains(t, err, "not found in wallet UTXO set")
	})
}
