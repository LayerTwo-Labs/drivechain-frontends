package engines

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// txIndexMissErr is what Core answers for a confirmed transaction it holds no
// index entry for.
const txIndexMissErr = "unknown: -5: No such mempool or blockchain transaction. " +
	"Use gettransaction for wallet transactions."

func fixedFee(amount btcutil.Amount) txFee {
	return func(context.Context, string) (btcutil.Amount, error) { return amount, nil }
}

// opReturnTx is a spending transaction that carries one OP_RETURN output.
func opReturnTx(t *testing.T, spends byte) *wire.MsgTx {
	t.Helper()
	script, err := txscript.NewScriptBuilder().
		AddOp(txscript.OP_RETURN).
		AddData([]byte("bitwindow")).
		Script()
	require.NoError(t, err)

	tx := wire.NewMsgTx(wire.TxVersion)
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{spends}, 0), nil, nil))
	tx.AddTxOut(wire.NewTxOut(0, script))
	return tx
}

// parserWithCore wires a Parser to a mock Core. The mock fails a test on each
// call that it does not expect, getrawtransaction included.
func parserWithCore(t *testing.T) (*Parser, *mocks.MockBitcoinServiceClient) {
	t.Helper()
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	return &Parser{
		db: database.Test(t),
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}, core
}

func TestBlockOpReturnFeesComeFromOneGetBlock(t *testing.T) {
	ctx := t.Context()
	p, core := parserWithCore(t)

	txs := []*wire.MsgTx{opReturnTx(t, 1), opReturnTx(t, 2), opReturnTx(t, 3)}
	const blockHash = "0f9188f13cb7b2c71f2a335e3a4fc328bf5beb436012afca590b1a11466e2206"
	core.EXPECT().
		GetBlock(gomock.Any(), tests.Connect(&corepb.GetBlockRequest{
			Hash:      blockHash,
			Verbosity: corepb.GetBlockRequest_VERBOSITY_BLOCK_TX_INFO,
		})).
		Return(connect.NewResponse(&corepb.GetBlockResponse{Transactions: []*corepb.GetBlockResponse_Transaction{
			{Txid: "coinbase"},
			{Txid: txs[0].TxID(), Fee: 0.0000276},
			{Txid: txs[1].TxID(), Fee: 0.001},
			{Txid: txs[2].TxID(), Fee: 0.00000141},
		}}), nil).
		Times(1)

	height := uint32(210)
	blockTime := time.Unix(1700000000, 0)
	fee := p.blockFees(blockHash)
	for _, tx := range txs {
		require.NoError(t, p.opReturnForTXID(ctx, tx, &height, &blockTime, fee))
	}

	stored, err := opreturns.List(ctx, p.db, 10)
	require.NoError(t, err)
	fees := map[string]btcutil.Amount{}
	for _, row := range stored {
		fees[row.TxID] = row.Fee
	}
	require.Equal(t, map[string]btcutil.Amount{
		txs[0].TxID(): 2760,
		txs[1].TxID(): 100_000,
		txs[2].TxID(): 141,
	}, fees)
}

func TestBlockWithNoOpReturnReadsNoFees(t *testing.T) {
	p, _ := parserWithCore(t)

	tx := wire.NewMsgTx(wire.TxVersion)
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1}, 0), nil, nil))
	tx.AddTxOut(wire.NewTxOut(1000, []byte{txscript.OP_0, txscript.OP_DATA_20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}))

	height := uint32(210)
	blockTime := time.Unix(1700000000, 0)
	require.NoError(t, p.opReturnForTXID(t.Context(), tx, &height, &blockTime, p.blockFees("00")))
}

func TestBlockFeeReadErrorFailsTheBlock(t *testing.T) {
	ctx := t.Context()
	p, core := parserWithCore(t)
	core.EXPECT().GetBlock(gomock.Any(), gomock.Any()).Return(nil, errors.New("unavailable: unexpected EOF"))

	height := uint32(210)
	blockTime := time.Unix(1700000000, 0)
	err := p.opReturnForTXID(ctx, opReturnTx(t, 1), &height, &blockTime, p.blockFees("00"))
	require.ErrorContains(t, err, "unexpected EOF")

	stored, err := opreturns.List(ctx, p.db, 10)
	require.NoError(t, err)
	require.Empty(t, stored)
}

// Core sends no fee on getrawtransaction for a mempool transaction, so the
// mempool path reads getmempoolentry.
func TestMempoolOpReturnFeeComesFromGetMempoolEntry(t *testing.T) {
	ctx := t.Context()
	p, _ := parserWithCore(t)
	tx := opReturnTx(t, 1)

	var calls []string
	p.rawCall = func(_ context.Context, method string, params ...any) (json.RawMessage, error) {
		calls = append(calls, method)
		require.Equal(t, []any{tx.TxID()}, params)
		return json.RawMessage(`{"vsize":138,"fees":{"base":0.00002760,"modified":0.00002760}}`), nil
	}

	require.NoError(t, p.HandleNewRawTransaction(ctx, tx))
	require.Equal(t, []string{"getmempoolentry"}, calls)

	stored, err := opreturns.List(ctx, p.db, 10)
	require.NoError(t, err)
	require.Len(t, stored, 1)
	require.Equal(t, btcutil.Amount(2760), stored[0].Fee)
	require.Nil(t, stored[0].Height)
}

// Core publishes the transactions of a new block on the same ZMQ topic. Those
// are not in the mempool, and the block scan records them.
func TestMempoolOpReturnMissDropsTheRow(t *testing.T) {
	ctx := t.Context()
	p, _ := parserWithCore(t)
	p.rawCall = func(context.Context, string, ...any) (json.RawMessage, error) {
		return nil, errors.New("internal: getmempoolentry: -5: Transaction not in mempool")
	}

	require.NoError(t, p.HandleNewRawTransaction(ctx, opReturnTx(t, 1)))

	stored, err := opreturns.List(ctx, p.db, 10)
	require.NoError(t, err)
	require.Empty(t, stored)
}

func TestMempoolOpReturnFeeErrorFails(t *testing.T) {
	ctx := t.Context()
	p, _ := parserWithCore(t)
	p.rawCall = func(context.Context, string, ...any) (json.RawMessage, error) {
		return nil, errors.New("unavailable: connection refused")
	}

	require.ErrorContains(t, p.HandleNewRawTransaction(ctx, opReturnTx(t, 1)), "connection refused")

	stored, err := opreturns.List(ctx, p.db, 10)
	require.NoError(t, err)
	require.Empty(t, stored)
}

func TestIsTxIndexMissMatchesEveryCoreShape(t *testing.T) {
	require.True(t, isTxIndexMiss(txIndexMissErr))
	require.True(t, isTxIndexMiss("unknown: -5: No such mempool transaction. Use -txindex or "+
		"provide a block hash to enable blockchain transaction queries. "+
		"Use gettransaction for wallet transactions."))
	require.True(t, isTxIndexMiss("unknown: -5: No such mempool transaction. "+
		"Blockchain transactions are still in the process of being indexed."))
	require.False(t, isTxIndexMiss("unavailable: unexpected EOF"))
}
