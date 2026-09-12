package api

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// detailsProvider answers the three reads GetTransactionDetails makes.
type detailsProvider struct {
	wallet.Backend
	rawTx      *wallet.RawTransaction
	owned      map[string]bool
	ownedErr   error
	askedOwned []string
}

func (f *detailsProvider) GetWalletTransaction(_ context.Context, _, txid string) (*wallet.WalletTx, error) {
	return &wallet.WalletTx{TxID: txid, Amount: -0.5, Hex: "00"}, nil
}

func (f *detailsProvider) OwnedAddresses(_ context.Context, _ string, addresses []string) (map[string]bool, error) {
	f.askedOwned = addresses
	if f.ownedErr != nil {
		return nil, f.ownedErr
	}
	return f.owned, nil
}

func (f *detailsProvider) Chain() wallet.ChainSource { return f }

func (f *detailsProvider) GetRawTransaction(_ context.Context, _ string) (*wallet.RawTransaction, error) {
	return f.rawTx, nil
}

func (f *detailsProvider) Broadcast(_ context.Context, _ string) (string, error) {
	return "", errors.New("broadcast is out of scope")
}

// paymentWithChange is a send that pays a stranger, carries an OP_RETURN, and
// returns the rest to the wallet's own change address.
func paymentWithChange() *wallet.RawTransaction {
	return &wallet.RawTransaction{
		TxID:  "tx",
		Vsize: 200,
		Vin:   []wallet.RawTxIn{{TxID: "parent", Vout: 0}},
		Vout: []wallet.RawTxOut{
			{Value: 0.1, N: 0, ScriptPubKey: wallet.ScriptPubKey{Type: "witness_v0_keyhash", Address: "stranger"}},
			{Value: 0, N: 1, ScriptPubKey: wallet.ScriptPubKey{Type: "nulldata"}},
			{Value: 8.32, N: 2, ScriptPubKey: wallet.ScriptPubKey{Type: "witness_v0_keyhash", Address: "change"}},
		},
	}
}

func newDetailsHandler(t *testing.T, fake *detailsProvider) (*WalletHandler, string) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.GenerateWallet("Core", "", "", nil)
	require.NoError(t, err)

	router := wallet.NewBackendRouter(svc, fake, fake)
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, router, nil, log))
	return h, w.ID
}

func TestGetTransactionDetailsMarksTheChangeOutput(t *testing.T) {
	fake := &detailsProvider{
		rawTx: paymentWithChange(),
		owned: map[string]bool{"change": true},
	}
	h, walletID := newDetailsHandler(t, fake)

	resp, err := h.GetTransactionDetails(context.Background(), connect.NewRequest(&pb.GetTransactionDetailsRequest{
		WalletId: walletID,
		Txid:     "tx",
	}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Outputs, 3)

	assert.False(t, resp.Msg.Outputs[0].IsMine, "the payment leaves the wallet")
	assert.False(t, resp.Msg.Outputs[0].IsChange)
	assert.False(t, resp.Msg.Outputs[1].IsMine, "an OP_RETURN output has no address")
	assert.True(t, resp.Msg.Outputs[2].IsMine)
	assert.True(t, resp.Msg.Outputs[2].IsChange)
	assert.Equal(t, []string{"stranger", "", "change"}, fake.askedOwned)
}

func TestGetTransactionDetailsMarksAReceiveOutput(t *testing.T) {
	fake := &detailsProvider{
		rawTx: paymentWithChange(),
		owned: map[string]bool{"stranger": false},
	}
	h, walletID := newDetailsHandler(t, fake)

	resp, err := h.GetTransactionDetails(context.Background(), connect.NewRequest(&pb.GetTransactionDetailsRequest{
		WalletId: walletID,
		Txid:     "tx",
	}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Outputs, 3)

	assert.True(t, resp.Msg.Outputs[0].IsMine)
	assert.False(t, resp.Msg.Outputs[0].IsChange, "a receive address is not change")
}

func TestGetTransactionDetailsFailsOnAnOwnershipError(t *testing.T) {
	fake := &detailsProvider{
		rawTx:    paymentWithChange(),
		ownedErr: errors.New("core is down"),
	}
	h, walletID := newDetailsHandler(t, fake)

	_, err := h.GetTransactionDetails(context.Background(), connect.NewRequest(&pb.GetTransactionDetailsRequest{
		WalletId: walletID,
		Txid:     "tx",
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInternal, connect.CodeOf(err))
}

func TestSetFrozenCoinsRecordsTheWholeSet(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, walletID := newDetailsHandler(t, fake)
	ctx := context.Background()

	_, err := h.SetFrozenCoins(ctx, connect.NewRequest(&pb.SetFrozenCoinsRequest{
		WalletId:  walletID,
		Outpoints: []*pb.FrozenOutpoint{{Txid: "held", Vout: 1}},
	}))
	require.NoError(t, err)

	held := h.svc.HeldCoins(walletID)
	assert.True(t, held[wallet.Outpoint{TxID: "held", Vout: 1}.Key()])

	// An unfreeze arrives as a smaller set, and it must free the coin.
	_, err = h.SetFrozenCoins(ctx, connect.NewRequest(&pb.SetFrozenCoinsRequest{WalletId: walletID}))
	require.NoError(t, err)
	assert.Empty(t, h.svc.HeldCoins(walletID))
}

func TestSetFrozenCoinsRefusesACoinWithoutATxid(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, walletID := newDetailsHandler(t, fake)

	_, err := h.SetFrozenCoins(context.Background(), connect.NewRequest(&pb.SetFrozenCoinsRequest{
		WalletId:  walletID,
		Outpoints: []*pb.FrozenOutpoint{{Vout: 1}},
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}
