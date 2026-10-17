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
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47send"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

// bip47TestChain funds one address and records every broadcast, so a
// handler-level test can drive the real electrum backend with no REST server.
type bip47TestChain struct {
	addr      string
	amount    int64
	txid      string
	rawHex    string
	more      []bip47TestCoin
	feeRate   float64
	feeErr    error
	broadcast []string
}

// bip47TestCoin is one more coin on the funded address.
type bip47TestCoin struct {
	amount int64
	txid   string
	rawHex string
}

func (c *bip47TestChain) coins() []bip47TestCoin {
	return append([]bip47TestCoin{{amount: c.amount, txid: c.txid, rawHex: c.rawHex}}, c.more...)
}

// addCoin funds the address with one more coin.
func (c *bip47TestChain) addCoin(t *testing.T, amount int64) {
	t.Helper()
	decoded, err := btcutil.DecodeAddress(c.addr, &chaincfg.SigNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(decoded)
	require.NoError(t, err)
	funding := wire.NewMsgTx(2)
	funding.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{byte(2 + len(c.more))}, 0), nil, nil))
	funding.AddTxOut(wire.NewTxOut(amount, script))
	var buf bytes.Buffer
	require.NoError(t, funding.Serialize(&buf))
	c.more = append(c.more, bip47TestCoin{amount: amount, txid: funding.TxHash().String(), rawHex: hex.EncodeToString(buf.Bytes())})
}

func (c *bip47TestChain) AddressStats(_ context.Context, a string) (wallet.EsploraAddressStats, error) {
	if a != c.addr {
		return wallet.EsploraAddressStats{Address: a}, nil
	}
	coins := c.coins()
	return wallet.EsploraAddressStats{
		Address: a,
		ChainStats: wallet.EsploraTxoStats{
			FundedTxoCount: len(coins),
			FundedTxoSum:   lo.SumBy(coins, func(c bip47TestCoin) int64 { return c.amount }),
			TxCount:        len(coins),
		},
	}, nil
}

func (c *bip47TestChain) AddressUTXOs(_ context.Context, a string) ([]wallet.EsploraUTXO, error) {
	if a != c.addr {
		return nil, nil
	}
	return lo.Map(c.coins(), func(coin bip47TestCoin, _ int) wallet.EsploraUTXO {
		return wallet.EsploraUTXO{
			TxID: coin.txid, Vout: 0, Value: coin.amount,
			Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 100},
		}
	}), nil
}

func (c *bip47TestChain) AddressTxs(context.Context, string) ([]wallet.EsploraTx, error) {
	return nil, nil
}

func (c *bip47TestChain) Tx(_ context.Context, txid string) (wallet.EsploraTx, error) {
	coin, ok := lo.Find(c.coins(), func(coin bip47TestCoin) bool { return coin.txid == txid })
	if !ok {
		return wallet.EsploraTx{}, errors.New("tx not found")
	}
	return wallet.EsploraTx{
		TxID:   txid,
		Vout:   []wallet.EsploraVout{{Value: coin.amount, ScriptPubKeyAddress: c.addr}},
		Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 100},
	}, nil
}

func (c *bip47TestChain) TxHex(_ context.Context, txid string) (string, error) {
	coin, ok := lo.Find(c.coins(), func(coin bip47TestCoin) bool { return coin.txid == txid })
	if !ok {
		return "", errors.New("tx hex not found")
	}
	return coin.rawHex, nil
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
	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		return "", err
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		return "", err
	}
	c.broadcast = append(c.broadcast, rawHex)
	return tx.TxHash().String(), nil
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

// A preview of a first payment to a payment code prices the notification and
// the payment on coins of their own, and reserves no index. A send that pins
// those coins pays the fees the preview showed.
func TestPreviewSendBip47PricesTheNotification(t *testing.T) {
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

	chain := newBip47TestChain(t, addrs[0], 500_000, 5)
	chain.addCoin(t, 300_000)
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)
	store := bip47state.NewStore(t.TempDir())
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(store)

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)
	code := recipient.Base58()
	const rate = 5

	preview := func() *pb.PreviewSendResponse {
		resp, err := h.PreviewSend(context.Background(), connect.NewRequest(&pb.PreviewSendRequest{
			WalletId:           w.ID,
			Destinations:       map[string]int64{code: 50_000},
			FeeRateSatPerVbyte: rate,
		}))
		require.NoError(t, err)
		return resp.Msg
	}

	first := preview()
	require.NotNil(t, first.NotificationInput)
	assert.Equal(t, int64(300_000), first.NotificationInput.AmountSats, "the notification takes the smallest coin")
	assert.Equal(t, bip47send.EstimateNotificationFee(rate), first.NotificationFeeSats)
	require.NotEmpty(t, first.Inputs)
	for _, in := range first.Inputs {
		assert.NotEqual(t, first.NotificationInput.Txid, in.Txid, "the payment leaves the notification coin alone")
	}
	assert.Empty(t, chain.broadcast)
	state, err := store.GetState(w.ID, code)
	require.NoError(t, err)
	assert.Nil(t, state, "a preview reserves no index")

	_, err = h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           w.ID,
		Destinations:       map[string]int64{code: 50_000},
		FeeRateSatPerVbyte: rate,
		RequiredInputs:     first.Inputs,
		NotificationInput:  first.NotificationInput,
	}))
	require.NoError(t, err)
	require.Len(t, chain.broadcast, 2, "the notification and the payment both go out")

	amounts := lo.SliceToMap(chain.coins(), func(c bip47TestCoin) (string, int64) { return c.txid, c.amount })
	paid := func(rawHex string) (string, int64) {
		raw, err := hex.DecodeString(rawHex)
		require.NoError(t, err)
		var tx wire.MsgTx
		require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
		require.Len(t, tx.TxIn, 1)
		in := tx.TxIn[0].PreviousOutPoint.Hash.String()
		return in, amounts[in] - lo.SumBy(tx.TxOut, func(o *wire.TxOut) int64 { return o.Value })
	}
	notificationCoin, notificationFee := paid(chain.broadcast[0])
	assert.Equal(t, first.NotificationInput.Txid, notificationCoin)
	assert.Equal(t, first.NotificationFeeSats, notificationFee)
	paymentCoin, paymentFee := paid(chain.broadcast[1])
	assert.Equal(t, first.Inputs[0].Txid, paymentCoin)
	assert.Equal(t, first.FeeSats, paymentFee)

	later := preview()
	assert.Nil(t, later.NotificationInput, "a notified recipient takes the payment alone")
	assert.Zero(t, later.NotificationFeeSats)
}

// A preview of a payment to a payment code sizes the payment output, but it
// reserves no index and publishes no notification.
func TestPreviewSendBip47ReservesNoIndex(t *testing.T) {
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

	chain := newBip47TestChain(t, addrs[0], 500_000, 5)
	chain.addCoin(t, 300_000)
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)
	store := bip47state.NewStore(t.TempDir())
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(store)

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)
	code := recipient.Base58()

	resp, err := h.PreviewSend(context.Background(), connect.NewRequest(&pb.PreviewSendRequest{
		WalletId:           w.ID,
		Destinations:       map[string]int64{code: 50_000},
		FeeRateSatPerVbyte: 5,
	}))
	require.NoError(t, err)
	assert.Positive(t, resp.Msg.FeeSats)
	assert.NotNil(t, resp.Msg.NotificationInput)
	assert.Empty(t, chain.broadcast)

	state, err := store.GetState(w.ID, code)
	require.NoError(t, err)
	assert.Nil(t, state, "a preview reserves no index")

	require.NoError(t, store.MarkNotified(w.ID, code, strings.Repeat("cd", 32)))
	resp, err = h.PreviewSend(context.Background(), connect.NewRequest(&pb.PreviewSendRequest{
		WalletId:           w.ID,
		Destinations:       map[string]int64{code: 50_000},
		FeeRateSatPerVbyte: 5,
	}))
	require.NoError(t, err)
	assert.Len(t, resp.Msg.Inputs, 1, "a notified recipient takes the payment alone, so its coins can be pinned")
	state, err = store.GetState(w.ID, code)
	require.NoError(t, err)
	assert.Zero(t, state.NextSendIndex, "a preview reserves no index")
}
