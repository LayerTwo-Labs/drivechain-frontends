package api

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

type utxoTimeProvider struct {
	detailsProvider
	txReads map[string]int
}

func (f *utxoTimeProvider) GetWalletTransaction(_ context.Context, _, txid string) (*wallet.WalletTx, error) {
	f.txReads[txid]++
	return &wallet.WalletTx{TxID: txid, TimeReceived: 1_700_000_000}, nil
}

func TestListUnspentReadsEachCoinTimeOnce(t *testing.T) {
	fake := &utxoTimeProvider{txReads: map[string]int{}}
	fake.utxos = []wallet.UTXO{
		{TxID: "a", Vout: 0, Amount: 1},
		{TxID: "a", Vout: 1, Amount: 2},
		{TxID: "b", Vout: 0, Amount: 3},
	}
	h, walletID := newDetailsHandler(t, &fake.detailsProvider)
	h.SetEngine(wallet.NewWalletEngine(h.svc, wallet.NewBackendRouter(h.svc, fake, fake), nil, *h.svc.Log()))

	for range 3 {
		resp, err := h.ListUnspent(context.Background(), &pb.ListUnspentRequest{WalletId: walletID})
		require.NoError(t, err)
		require.Len(t, resp.Utxos, 3)
		for _, u := range resp.Utxos {
			require.Equal(t, int64(1_700_000_000), u.ReceivedAt.GetSeconds(), u.Txid)
		}
	}
	require.Equal(t, map[string]int{"a": 1, "b": 1}, fake.txReads)

	fake.utxos = fake.utxos[2:]
	_, err := h.ListUnspent(context.Background(), &pb.ListUnspentRequest{WalletId: walletID})
	require.NoError(t, err)
	require.Equal(t, map[string]int64{"b": 1_700_000_000}, h.receivedAt[walletID], "a spent coin leaves the cache")
}
