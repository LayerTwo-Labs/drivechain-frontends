package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

// bip47TestChain funds one address and records every broadcast, so a
// handler-level test can drive the real electrum backend with no REST server.
type bip47TestChain struct {
	addr      string
	amount    int64
	txid      string
	rawHex    string
	feeRate   float64
	feeErr    error
	broadcast []string
}

func (c *bip47TestChain) AddressStats(_ context.Context, a string) (wallet.EsploraAddressStats, error) {
	if a != c.addr {
		return wallet.EsploraAddressStats{Address: a}, nil
	}
	return wallet.EsploraAddressStats{
		Address:    a,
		ChainStats: wallet.EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: c.amount, TxCount: 1},
	}, nil
}

func (c *bip47TestChain) AddressUTXOs(_ context.Context, a string) ([]wallet.EsploraUTXO, error) {
	if a != c.addr {
		return nil, nil
	}
	return []wallet.EsploraUTXO{{
		TxID: c.txid, Vout: 0, Value: c.amount,
		Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}, nil
}

func (c *bip47TestChain) AddressTxs(context.Context, string) ([]wallet.EsploraTx, error) {
	return nil, nil
}

func (c *bip47TestChain) Tx(_ context.Context, txid string) (wallet.EsploraTx, error) {
	if txid != c.txid {
		return wallet.EsploraTx{}, errors.New("tx not found")
	}
	return wallet.EsploraTx{
		TxID:   txid,
		Vout:   []wallet.EsploraVout{{Value: c.amount, ScriptPubKeyAddress: c.addr}},
		Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 100},
	}, nil
}

func (c *bip47TestChain) TxHex(_ context.Context, txid string) (string, error) {
	if txid != c.txid {
		return "", errors.New("tx hex not found")
	}
	return c.rawHex, nil
}

func newBip47TestChain(t *testing.T, addr string, amount int64, feeRate float64) *bip47TestChain {
	t.Helper()
	decoded, err := btcutil.DecodeAddress(addr, &chaincfg.SigNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(decoded)
	require.NoError(t, err)
	funding := wire.NewMsgTx(2)
	funding.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1}, 0), nil, nil))
	funding.AddTxOut(wire.NewTxOut(amount, script))
	var buf bytes.Buffer
	require.NoError(t, funding.Serialize(&buf))
	return &bip47TestChain{
		addr:    addr,
		amount:  amount,
		txid:    funding.TxHash().String(),
		rawHex:  hex.EncodeToString(buf.Bytes()),
		feeRate: feeRate,
	}
}

func (c *bip47TestChain) Broadcast(_ context.Context, rawHex string) (string, error) {
	c.broadcast = append(c.broadcast, rawHex)
	return "broadcasttxid", nil
}

func (c *bip47TestChain) TipHeight(context.Context) (int, error) { return 110, nil }

func (c *bip47TestChain) FeeRateForTarget(context.Context, int) (float64, error) {
	if c.feeErr != nil {
		return 0, c.feeErr
	}
	return c.feeRate, nil
}

// A first BIP47 payment publishes a notification transaction before the
// payment. Without a fee estimate the payment cannot be built, so nothing at
// all may go out: the notification alone spends a coin and pays no recipient.
func TestSendTransactionBip47WithoutAFeeEstimateBroadcastsNothing(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	net := &chaincfg.SigNetParams
	addrs, err := wallet.DeriveBIP84Addresses(w.Master.SeedHex, net, 0, 1)
	require.NoError(t, err)

	chain := newBip47TestChain(t, addrs[0], 500_000, 0)
	chain.feeErr = errors.New("estimatefee: connection refused")
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)
	store := bip47state.NewStore(t.TempDir())
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(store)

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)
	code := recipient.Base58()

	ctx := context.Background()
	send := &pb.SendTransactionRequest{
		WalletId:     w.ID,
		Destinations: map[string]int64{code: 50_000},
	}

	_, err = h.SendTransaction(ctx, connect.NewRequest(send))
	require.Error(t, err)
	assert.Contains(t, err.Error(), "fee estimate")
	assert.Empty(t, chain.broadcast, "no notification may go out before the payment is priced")

	state, err := store.GetState(w.ID, code)
	require.NoError(t, err)
	if state != nil {
		assert.Nil(t, state.NotificationTxID, "an unsent notification leaves no record")
	}

	// The same send goes through once the chain answers, so the refusal above
	// came from the missing estimate alone.
	chain.feeErr = nil
	chain.feeRate = 5
	_, err = h.SendTransaction(ctx, connect.NewRequest(send))
	require.NoError(t, err)
	assert.Len(t, chain.broadcast, 2, "the notification and the payment both go out")

	// A later payment to the same recipient sends no notification, but it still
	// reserves an index. A missing estimate must give that index back, or a run
	// of failures walks the payment past the recipient's gap limit.
	state, err = store.GetState(w.ID, code)
	require.NoError(t, err)
	require.NotNil(t, state)
	nextIndex := state.NextSendIndex

	chain.feeErr = errors.New("estimatefee: connection refused")
	_, err = h.SendTransaction(ctx, connect.NewRequest(send))
	require.Error(t, err)
	assert.Len(t, chain.broadcast, 2, "a payment the wallet cannot price sends nothing")

	state, err = store.GetState(w.ID, code)
	require.NoError(t, err)
	require.NotNil(t, state)
	assert.Equal(t, nextIndex, state.NextSendIndex, "the reserved index comes back")
}

func TestSendTransactionBip47NotificationPaysTheSendRate(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	net := &chaincfg.SigNetParams
	addrs, err := wallet.DeriveBIP84Addresses(w.Master.SeedHex, net, 0, 1)
	require.NoError(t, err)

	const fundedSats int64 = 500_000
	chain := newBip47TestChain(t, addrs[0], fundedSats, 20)
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(bip47state.NewStore(t.TempDir()))

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)

	_, err = h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     w.ID,
		Destinations: map[string]int64{recipient.Base58(): 50_000},
	}))
	require.NoError(t, err)
	require.Len(t, chain.broadcast, 2)

	raw, err := hex.DecodeString(chain.broadcast[0])
	require.NoError(t, err)
	var notification wire.MsgTx
	require.NoError(t, notification.Deserialize(bytes.NewReader(raw)))
	require.Len(t, notification.TxIn, 1)
	require.Equal(t, chain.txid, notification.TxIn[0].PreviousOutPoint.Hash.String())

	outSats := lo.SumBy(notification.TxOut, func(o *wire.TxOut) int64 { return o.Value })
	vsize := int64(notification.SerializeSizeStripped()*3+notification.SerializeSize()+3) / 4
	assert.GreaterOrEqual(t, fundedSats-outSats, 20*vsize)
}

func TestSendTransactionBip47AboveTheFeeCapBroadcastsNothing(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	net := &chaincfg.SigNetParams
	addrs, err := wallet.DeriveBIP84Addresses(w.Master.SeedHex, net, 0, 1)
	require.NoError(t, err)

	chain := newBip47TestChain(t, addrs[0], 100_000_000, 20_000)
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(bip47state.NewStore(t.TempDir()))

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)

	_, err = h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     w.ID,
		Destinations: map[string]int64{recipient.Base58(): 50_000},
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "above the limit")
	assert.Empty(t, chain.broadcast)
}
