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

func TestSendCoreWithFixedFee(t *testing.T) {
	t.Parallel()

	const smallTxid = "cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33cc33"
	const largeTxid = "dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44dd44"

	t.Run("selects inputs and pays exactly the fixed fee", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		// Once to select the inputs, once to resolve their values.
		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: smallTxid, Vout: 3, Amount: 1.0},
					{Txid: largeTxid, Vout: 0, Amount: 5.0},
				},
			}), nil).
			Times(2)

		mockBitcoind.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.GetNewAddressResponse{
				Address: "tb1qchange0000000000000000000000000000000",
			}), nil)

		stop := errors.New("stop")
		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(_ context.Context, req *connect.Request[corepb.CreateRawTransactionRequest]) (*connect.Response[corepb.CreateRawTransactionResponse], error) {
				// Largest first: the 5 BTC UTXO covers outputs + fee on its own.
				require.Len(t, req.Msg.Inputs, 1)
				assert.Equal(t, largeTxid, req.Msg.Inputs[0].Txid)

				// 5 BTC in, 0.4 BTC out, exactly 5k sats fee -> the rest is change.
				assert.Equal(t, 0.4, req.Msg.Outputs["tb1qdest00000000000000000000000000000000"])
				assert.Equal(t, 4.59995, req.Msg.Outputs["tb1qchange0000000000000000000000000000000"])
				return nil, stop
			})

		_, err := engines.SendCoreWithFixedFee(context.Background(), mockBitcoind, "wallet",
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 40_000_000},
			5_000,
		)
		require.ErrorIs(t, err, stop)
	})

	t.Run("errors when the wallet cannot cover outputs plus fee", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: smallTxid, Vout: 3, Amount: 0.1},
				},
			}), nil)

		_, err := engines.SendCoreWithFixedFee(context.Background(), mockBitcoind, "wallet",
			map[string]uint64{"tb1qdest00000000000000000000000000000000": 40_000_000},
			5_000,
		)
		require.ErrorContains(t, err, "insufficient for outputs + fee")
	})
}
