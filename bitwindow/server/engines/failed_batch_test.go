package engines

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
)

type failedBatchClient struct {
	corerpc.BitcoinServiceClient
	failedTxID string
}

func (c failedBatchClient) GetRawTransaction(ctx context.Context, req *connect.Request[corepb.GetRawTransactionRequest]) (*connect.Response[corepb.GetRawTransactionResponse], error) {
	if req.Msg.Txid == c.failedTxID {
		return nil, connect.NewError(connect.CodeUnavailable, errors.New("node stopped"))
	}
	return c.BitcoinServiceClient.GetRawTransaction(ctx, req)
}

func TestFailedBatchDropsOrphanRowsOnRetry(t *testing.T) {
	ctx := t.Context()
	old := servedChain{}
	old.extend(1, 101, 1, chainhash.Hash{})
	first := opReturnTx(t)
	second := opReturnTx(t)
	second.LockTime = 1
	old[101].Transactions = append(old[101].Transactions, first, second)
	p := tickParser(t, old, 101)
	markProcessed(t, ctx, p, old, 1, 100)
	client, err := p.bitcoind.Get(ctx)
	require.NoError(t, err)
	p.bitcoind = service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return failedBatchClient{BitcoinServiceClient: client, failedTxID: second.TxID()}, nil
	})

	err = p.handleBlockTick(ctx)
	require.ErrorContains(t, err, "node stopped")
	tip, err := blocks.GetProcessedTip(ctx, p.db)
	require.NoError(t, err)
	require.Equal(t, uint32(100), tip.Height)
	row, err := opreturns.GetByTxID(ctx, p.db, first.TxID())
	require.NoError(t, err)
	require.NotNil(t, row)

	current := servedChain{}
	current.extend(1, 100, 1, chainhash.Hash{})
	current.extend(101, 101, 2, current.hash(100))
	retry := tickParser(t, current, 101)
	retry.db = p.db
	retry.m4Engine = NewM4Engine(p.db, config.NetworkMainnet)
	require.NoError(t, retry.handleBlockTick(ctx))
	tip, err = blocks.GetProcessedTip(ctx, p.db)
	require.NoError(t, err)
	require.Equal(t, current.hash(101), tip.Hash)
	row, err = opreturns.GetByTxID(ctx, p.db, first.TxID())
	require.NoError(t, err)
	require.Nil(t, row, "the active block has no old transaction")
}
