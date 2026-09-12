package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
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
	utxos      []wallet.UTXO
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

func (f *detailsProvider) ListUnspent(context.Context, string) ([]wallet.UTXO, error) {
	return f.utxos, nil
}

func (f *detailsProvider) Send(context.Context, string, wallet.SendRequest) (string, error) {
	return "", errors.New("this fake broadcasts nothing")
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
	h, _ := newDetailsHandler(t, fake)
	ctx := context.Background()

	_, err := h.SetFrozenCoins(ctx, connect.NewRequest(&pb.SetFrozenCoinsRequest{
		Outpoints: []*pb.FrozenOutpoint{{Txid: "held", Vout: 1}},
	}))
	require.NoError(t, err)

	held := h.svc.HeldCoins()
	assert.True(t, held[wallet.Outpoint{TxID: "held", Vout: 1}.Key()])

	// An unfreeze arrives as a smaller set, and it must free the coin.
	_, err = h.SetFrozenCoins(ctx, connect.NewRequest(&pb.SetFrozenCoinsRequest{}))
	require.NoError(t, err)
	assert.Empty(t, h.svc.HeldCoins())
}

func TestSetFrozenCoinsRefusesACoinWithoutATxid(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, _ := newDetailsHandler(t, fake)

	_, err := h.SetFrozenCoins(context.Background(), connect.NewRequest(&pb.SetFrozenCoinsRequest{
		Outpoints: []*pb.FrozenOutpoint{{Vout: 1}},
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

// A BIP47 notification pins the coin it picks, so a frozen coin has to leave
// the list before the pick.
func TestBip47NotificationSkipsAFrozenCoin(t *testing.T) {
	fake := &detailsProvider{
		rawTx: paymentWithChange(),
		utxos: []wallet.UTXO{
			{TxID: "frozen", Vout: 0, Address: "a", Amount: 0.01, Confirmations: 6, Spendable: true},
		},
	}
	h, walletID := newDetailsHandler(t, fake)
	h.svc.SetHeldCoins([]wallet.Outpoint{{TxID: "frozen", Vout: 0}})

	_, _, err := h.buildBip47NotificationTx(
		context.Background(), walletID, "00", nil, &chaincfg.RegressionNetParams,
	)
	require.ErrorContains(t, err, "no spendable UTXO")
}

// A CPFP child spends the parent output the caller names. No lock reaches an
// outpoint a caller pins, so the call has to refuse a frozen one.
func TestCreateCpfpRefusesAFrozenParent(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, walletID := newDetailsHandler(t, fake)
	h.svc.SetHeldCoins([]wallet.Outpoint{{TxID: "parent", Vout: 1}})

	_, err := h.CreateCpfp(context.Background(), connect.NewRequest(&pb.CreateCpfpRequest{
		WalletId:      walletID,
		ParentTxid:    "parent",
		ParentVout:    1,
		TargetFeeRate: 10,
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "is frozen")
}

// A required input is spent as it is given, so no lock reaches it.
func TestSendRefusesAFrozenRequiredInput(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, walletID := newDetailsHandler(t, fake)
	h.svc.SetHeldCoins([]wallet.Outpoint{{TxID: "frozen", Vout: 0}})

	_, err := h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:       walletID,
		Destinations:   map[string]int64{"bcrt1qdest": 50_000},
		RequiredInputs: []*pb.UnspentOutput{{Txid: "frozen", Vout: 0}},
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "is frozen")
}

// A bid raise pins the coin its own bid holds, and that coin stays spendable.
func TestSendAllowsAPinThatIsNotFrozen(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, walletID := newDetailsHandler(t, fake)
	h.svc.SetHeldCoins([]wallet.Outpoint{{TxID: "frozen", Vout: 0}})

	_, err := h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:       walletID,
		Destinations:   map[string]int64{"bcrt1qdest": 50_000},
		RequiredInputs: []*pb.UnspentOutput{{Txid: "free", Vout: 0}},
	}))
	// The fake backend cannot send, so the call fails later than the check.
	require.Error(t, err)
	assert.NotContains(t, err.Error(), "is frozen")
}

// A saved draft names its inputs. The user can freeze one of them before the
// broadcast, so the broadcast reads them again.
func TestBroadcastRefusesAFrozenInput(t *testing.T) {
	fake := &detailsProvider{rawTx: paymentWithChange()}
	h, walletID := newDetailsHandler(t, fake)

	// One input, spending frozenCoinTxid:1.
	tx := wire.NewMsgTx(wire.TxVersion)
	parent, err := chainhash.NewHashFromStr(
		"1111111111111111111111111111111111111111111111111111111111111111")
	require.NoError(t, err)
	tx.AddTxIn(&wire.TxIn{PreviousOutPoint: *wire.NewOutPoint(parent, 1)})
	tx.AddTxOut(&wire.TxOut{Value: 1_000, PkScript: []byte{0x51}})
	var raw bytes.Buffer
	require.NoError(t, tx.Serialize(&raw))

	h.svc.SetHeldCoins([]wallet.Outpoint{{TxID: parent.String(), Vout: 1}})

	_, err = h.BroadcastTransaction(context.Background(), connect.NewRequest(&pb.BroadcastTransactionRequest{
		WalletId: walletID,
		TxHex:    hex.EncodeToString(raw.Bytes()),
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "is frozen")
}
