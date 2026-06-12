package wallet

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/timestamppb"
	"google.golang.org/protobuf/types/known/wrapperspb"

	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

// fakeEnforcerClient overrides the wallet-service methods the provider uses;
// anything else panics via the embedded nil interface.
type fakeEnforcerClient struct {
	enforcerrpc.WalletServiceClient

	balance  *enforcerpb.GetBalanceResponse
	unspent  *enforcerpb.ListUnspentOutputsResponse
	txs      *enforcerpb.ListTransactionsResponse
	newAddr  string
	lastSend *enforcerpb.SendTransactionRequest
}

func (f *fakeEnforcerClient) GetBalance(ctx context.Context, _ *connect.Request[enforcerpb.GetBalanceRequest]) (*connect.Response[enforcerpb.GetBalanceResponse], error) {
	return connect.NewResponse(f.balance), nil
}

func (f *fakeEnforcerClient) ListUnspentOutputs(ctx context.Context, _ *connect.Request[enforcerpb.ListUnspentOutputsRequest]) (*connect.Response[enforcerpb.ListUnspentOutputsResponse], error) {
	return connect.NewResponse(f.unspent), nil
}

func (f *fakeEnforcerClient) ListTransactions(ctx context.Context, _ *connect.Request[enforcerpb.ListTransactionsRequest]) (*connect.Response[enforcerpb.ListTransactionsResponse], error) {
	return connect.NewResponse(f.txs), nil
}

func (f *fakeEnforcerClient) CreateNewAddress(ctx context.Context, _ *connect.Request[enforcerpb.CreateNewAddressRequest]) (*connect.Response[enforcerpb.CreateNewAddressResponse], error) {
	return connect.NewResponse(&enforcerpb.CreateNewAddressResponse{Address: f.newAddr}), nil
}

func (f *fakeEnforcerClient) SendTransaction(ctx context.Context, req *connect.Request[enforcerpb.SendTransactionRequest]) (*connect.Response[enforcerpb.SendTransactionResponse], error) {
	f.lastSend = req.Msg
	return connect.NewResponse(&enforcerpb.SendTransactionResponse{
		Txid: reverseHex("aabb"),
	}), nil
}

func reverseHex(s string) *commonv1.ReverseHex {
	return &commonv1.ReverseHex{Hex: &wrapperspb.StringValue{Value: s}}
}

func TestEnforcerProviderBalance(t *testing.T) {
	p := NewEnforcerProvider(&fakeEnforcerClient{
		balance: &enforcerpb.GetBalanceResponse{ConfirmedSats: 150_000_000, PendingSats: 25_000_000},
	})

	confirmed, unconfirmed, err := p.Balance(context.Background(), "w")
	require.NoError(t, err)
	assert.Equal(t, 1.5, confirmed)
	assert.Equal(t, 0.25, unconfirmed)
}

func TestEnforcerProviderListUnspent(t *testing.T) {
	confirmedAt := time.Unix(1_700_000_000, 0)
	firstSeen := time.Unix(1_700_000_500, 0)
	p := NewEnforcerProvider(&fakeEnforcerClient{
		unspent: &enforcerpb.ListUnspentOutputsResponse{
			Outputs: []*enforcerpb.ListUnspentOutputsResponse_Output{
				{
					Txid:            reverseHex("tx1"),
					Vout:            2,
					ValueSats:       50_000,
					IsConfirmed:     true,
					ConfirmedAtTime: timestamppb.New(confirmedAt),
					Address:         &wrapperspb.StringValue{Value: "addr1"},
				},
				{
					Txid:                reverseHex("tx2"),
					Vout:                0,
					ValueSats:           10_000,
					IsConfirmed:         false,
					UnconfirmedLastSeen: timestamppb.New(firstSeen),
					Address:             &wrapperspb.StringValue{Value: "addr2"},
				},
			},
		},
	})

	utxos, err := p.ListUnspent(context.Background(), "w")
	require.NoError(t, err)
	require.Len(t, utxos, 2)

	assert.Equal(t, "tx1", utxos[0].TxID)
	assert.Equal(t, 2, utxos[0].Vout)
	assert.Equal(t, 0.0005, utxos[0].Amount)
	assert.Equal(t, 1, utxos[0].Confirmations)
	assert.True(t, utxos[0].Spendable)
	assert.Equal(t, confirmedAt.Unix(), utxos[0].ReceivedAt)

	assert.Equal(t, 0, utxos[1].Confirmations)
	assert.Equal(t, firstSeen.Unix(), utxos[1].ReceivedAt)
}

func TestEnforcerProviderListTransactions(t *testing.T) {
	blockTime := time.Unix(1_700_000_000, 0)
	p := NewEnforcerProvider(&fakeEnforcerClient{
		txs: &enforcerpb.ListTransactionsResponse{
			Transactions: []*enforcerpb.WalletTransaction{
				{
					Txid:         reverseHex("send-tx"),
					ReceivedSats: 0,
					SentSats:     30_000,
					FeeSats:      500,
					ConfirmationInfo: &enforcerpb.WalletTransaction_Confirmation{
						Height:    123,
						Timestamp: timestamppb.New(blockTime),
					},
				},
				{
					Txid:         reverseHex("recv-tx"),
					ReceivedSats: 70_000,
					SentSats:     0,
				},
			},
		},
	})
	ctx := context.Background()

	txs, err := p.ListTransactions(ctx, "w", 10)
	require.NoError(t, err)
	require.Len(t, txs, 2)

	assert.Equal(t, "send-tx", txs[0].TxID)
	assert.Equal(t, -0.0003, txs[0].Amount)
	assert.Equal(t, 0.000005, txs[0].Fee)
	assert.Equal(t, 123, txs[0].Confirmations)
	assert.Equal(t, blockTime.Unix(), txs[0].BlockTime)

	assert.Equal(t, 0.0007, txs[1].Amount)
	assert.Equal(t, 0, txs[1].Confirmations)

	// Range slicing for the cursor-based scan.
	ranged, err := p.ListTransactionsRange(ctx, "w", 1, 1)
	require.NoError(t, err)
	require.Len(t, ranged, 1)
	assert.Equal(t, "recv-tx", ranged[0].TxID)

	past, err := p.ListTransactionsRange(ctx, "w", 10, 5)
	require.NoError(t, err)
	assert.Empty(t, past)
}

func TestEnforcerProviderListReceivedByAddress(t *testing.T) {
	p := NewEnforcerProvider(&fakeEnforcerClient{
		unspent: &enforcerpb.ListUnspentOutputsResponse{
			Outputs: []*enforcerpb.ListUnspentOutputsResponse_Output{
				{Txid: reverseHex("a"), ValueSats: 10_000, Address: &wrapperspb.StringValue{Value: "addrB"}},
				{Txid: reverseHex("b"), ValueSats: 5_000, Address: &wrapperspb.StringValue{Value: "addrB"}},
				{Txid: reverseHex("c"), ValueSats: 7_000, Address: &wrapperspb.StringValue{Value: "addrC"}},
			},
		},
		newAddr: "addrA",
	})

	addrs, err := p.ListReceivedByAddress(context.Background(), "w")
	require.NoError(t, err)
	require.Len(t, addrs, 3)

	// Sorted by address; the freshly minted addrA appears with zero amount.
	assert.Equal(t, "addrA", addrs[0].Address)
	assert.Equal(t, 0.0, addrs[0].Amount)
	assert.Equal(t, "addrB", addrs[1].Address)
	assert.Equal(t, 0.00015, addrs[1].Amount)
	assert.Equal(t, "addrC", addrs[2].Address)
}

func TestEnforcerProviderGetWalletTransaction(t *testing.T) {
	p := NewEnforcerProvider(&fakeEnforcerClient{
		txs: &enforcerpb.ListTransactionsResponse{
			Transactions: []*enforcerpb.WalletTransaction{
				{Txid: reverseHex("known"), ReceivedSats: 1_000},
			},
		},
	})
	ctx := context.Background()

	tx, err := p.GetWalletTransaction(ctx, "w", "known")
	require.NoError(t, err)
	assert.Equal(t, "known", tx.TxID)

	_, err = p.GetWalletTransaction(ctx, "w", "missing")
	require.ErrorContains(t, err, "not found")
}

func TestEnforcerProviderSend(t *testing.T) {
	fake := &fakeEnforcerClient{}
	p := NewEnforcerProvider(fake)
	ctx := context.Background()

	txid, err := p.Send(ctx, "w", SendRequest{
		DestinationsSats: map[string]int64{"dest": 25_000},
		FeeRateSatPerVB:  3,
		OpReturnHex:      "deadbeef",
		RequiredInputs: []RequiredInput{
			{TxID: "pin1", Vout: 1, AmountSats: 40_000},
			{TxID: "", Vout: 0}, // empty txid entries are dropped
		},
	})
	require.NoError(t, err)
	assert.Equal(t, "aabb", txid)

	require.NotNil(t, fake.lastSend)
	assert.Equal(t, uint64(25_000), fake.lastSend.Destinations["dest"])
	assert.Equal(t, uint64(3), fake.lastSend.FeeRate.GetSatPerVbyte())
	assert.Equal(t, "deadbeef", fake.lastSend.OpReturnMessage.GetHex().GetValue())
	require.Len(t, fake.lastSend.RequiredUtxos, 1)
	assert.Equal(t, "pin1", fake.lastSend.RequiredUtxos[0].Txid.GetHex().GetValue())

	// Fixed fee maps onto the sats oneof.
	_, err = p.Send(ctx, "w", SendRequest{
		DestinationsSats: map[string]int64{"dest": 1_000},
		FixedFeeSats:     800,
	})
	require.NoError(t, err)
	assert.Equal(t, uint64(800), fake.lastSend.FeeRate.GetSats())

	// Replay protection is a Core-only feature and must be rejected with an
	// InvalidArgument the handler passes through verbatim.
	_, err = p.Send(ctx, "w", SendRequest{
		DestinationsSats: map[string]int64{"dest": 1_000},
		ReplayProtect:    true,
	})
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestEnforcerProviderUnsupportedOps(t *testing.T) {
	p := NewEnforcerProvider(&fakeEnforcerClient{})
	ctx := context.Background()

	_, err := p.SignTransaction(ctx, "w", "00")
	require.ErrorContains(t, err, "not supported")
	_, err = p.AddressHDPath(ctx, "w", "addr")
	require.ErrorContains(t, err, "not supported")
	err = p.WatchKeys(ctx, "w", []WatchKey{{WIF: "x"}})
	require.ErrorContains(t, err, "not supported")
	_, err = p.BumpFee(ctx, "w", "txid", 2)
	require.ErrorContains(t, err, "not supported")
	_, err = p.Ensure(ctx, "w")
	require.Error(t, err)
}
