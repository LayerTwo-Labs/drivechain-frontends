package engines

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// txIndexMissErr is what Core answers for a confirmed transaction it holds no
// index entry for.
const txIndexMissErr = "unknown: -5: No such mempool or blockchain transaction. " +
	"Use gettransaction for wallet transactions."

// opReturnTx is a spending transaction that carries one OP_RETURN output.
func opReturnTx(t *testing.T) *wire.MsgTx {
	t.Helper()
	script, err := txscript.NewScriptBuilder().
		AddOp(txscript.OP_RETURN).
		AddData([]byte("bitwindow")).
		Script()
	require.NoError(t, err)

	tx := wire.NewMsgTx(wire.TxVersion)
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1}, 0), nil, nil))
	tx.AddTxOut(wire.NewTxOut(0, script))
	return tx
}

// parserWithRawTxError wires a Parser to a Core that fails every
// getrawtransaction with errMsg.
func parserWithRawTxError(t *testing.T, errMsg string) *Parser {
	t.Helper()
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().
		GetRawTransaction(gomock.Any(), gomock.Any()).
		Return(nil, connect.NewError(connect.CodeUnknown, errors.New(errMsg))).
		AnyTimes()

	return &Parser{
		db: database.Test(t),
		bitcoind: service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return core, nil
		}),
	}
}

// A node without a complete txindex answers -5 for a confirmed transaction.
// Returning that error aborted the whole block batch, so processed_blocks
// never advanced and the parser replayed the same batch every two seconds.
func TestConfirmedOpReturnSurvivesAMissingTxIndexEntry(t *testing.T) {
	ctx := context.Background()
	p := parserWithRawTxError(t, txIndexMissErr)

	height := uint32(995432)
	blockTime := time.Unix(1700000000, 0)

	opReturns, err := p.handleOpReturns(ctx, opReturnTx(t), &height, &blockTime)
	require.NoError(t, err)
	require.Len(t, opReturns, 1)
	require.Zero(t, opReturns[0].Fee, "an unknown fee reads as zero, not as a failure")
}

// An unconfirmed miss means the transaction left the mempool. That row must
// not land, so the caller still sees the error.
func TestUnconfirmedOpReturnStillFailsOnAMissingTransaction(t *testing.T) {
	ctx := context.Background()
	p := parserWithRawTxError(t, txIndexMissErr)

	createdAt := time.Unix(1700000000, 0)

	_, err := p.handleOpReturns(ctx, opReturnTx(t), nil, &createdAt)
	require.Error(t, err)
}

// Any other getrawtransaction failure stays terminal.
func TestConfirmedOpReturnStillFailsOnAnUnrelatedRpcError(t *testing.T) {
	ctx := context.Background()
	p := parserWithRawTxError(t, "unavailable: unexpected EOF")

	height := uint32(995432)
	blockTime := time.Unix(1700000000, 0)

	_, err := p.handleOpReturns(ctx, opReturnTx(t), &height, &blockTime)
	require.Error(t, err)
}

func TestIsTxIndexMissMatchesBothCoreShapes(t *testing.T) {
	require.True(t, isTxIndexMiss(txIndexMissErr))
	require.True(t, isTxIndexMiss("unknown: -5: No such mempool transaction. "+
		"Blockchain transactions are still in the process of being indexed."))
	require.False(t, isTxIndexMiss("unavailable: unexpected EOF"))
}
