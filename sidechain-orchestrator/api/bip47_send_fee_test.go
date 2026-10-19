package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"fmt"
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

// bip47TestChain is a small chain for handler tests: it funds one address,
// refuses a broadcast that spends a coin it does not hold, and adds the
// outputs of every broadcast as unconfirmed coins.
type bip47TestChain struct {
	addr      string
	amount    int64
	txid      string
	coinList  []bip47TestCoin
	txs       map[string]*wire.MsgTx
	feeRate   float64
	feeErr    error
	broadcast []string
}

// bip47TestCoin is one unspent output of the chain.
type bip47TestCoin struct {
	txid      string
	vout      int
	addr      string
	amount    int64
	confirmed bool
}

func (c *bip47TestChain) coinsOf(addr string) []bip47TestCoin {
	return lo.Filter(c.coinList, func(coin bip47TestCoin, _ int) bool { return coin.addr == addr })
}

func outputAddress(out *wire.TxOut) string {
	_, addrs, _, err := txscript.ExtractPkScriptAddrs(out.PkScript, &chaincfg.SigNetParams)
	if err != nil || len(addrs) != 1 {
		return ""
	}
	return addrs[0].EncodeAddress()
}

// record keeps tx and adds its outputs as coins.
func (c *bip47TestChain) record(tx *wire.MsgTx, confirmed bool) string {
	txid := tx.TxHash().String()
	c.txs[txid] = tx
	for vout, out := range tx.TxOut {
		if addr := outputAddress(out); addr != "" {
			c.coinList = append(c.coinList, bip47TestCoin{txid: txid, vout: vout, addr: addr, amount: out.Value, confirmed: confirmed})
		}
	}
	return txid
}

// addCoin funds the address with one more confirmed coin.
func (c *bip47TestChain) addCoin(t *testing.T, amount int64) {
	t.Helper()
	decoded, err := btcutil.DecodeAddress(c.addr, &chaincfg.SigNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(decoded)
	require.NoError(t, err)
	funding := wire.NewMsgTx(2)
	funding.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{byte(1 + len(c.txs))}, 0), nil, nil))
	funding.AddTxOut(wire.NewTxOut(amount, script))
	c.record(funding, true)
}

func (c *bip47TestChain) AddressStats(_ context.Context, a string) (wallet.EsploraAddressStats, error) {
	coins := c.coinsOf(a)
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
	return lo.Map(c.coinsOf(a), func(coin bip47TestCoin, _ int) wallet.EsploraUTXO {
		status := wallet.EsploraStatus{}
		if coin.confirmed {
			status = wallet.EsploraStatus{Confirmed: true, BlockHeight: 100}
		}
		return wallet.EsploraUTXO{TxID: coin.txid, Vout: coin.vout, Value: coin.amount, Status: status}
	}), nil
}

func (c *bip47TestChain) AddressTxs(context.Context, string) ([]wallet.EsploraTx, error) {
	return nil, nil
}

func (c *bip47TestChain) Tx(_ context.Context, txid string) (wallet.EsploraTx, error) {
	tx, ok := c.txs[txid]
	if !ok {
		return wallet.EsploraTx{}, errors.New("tx not found")
	}
	return wallet.EsploraTx{
		TxID: txid,
		Vout: lo.Map(tx.TxOut, func(out *wire.TxOut, _ int) wallet.EsploraVout {
			return wallet.EsploraVout{Value: out.Value, ScriptPubKeyAddress: outputAddress(out)}
		}),
		Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 100},
	}, nil
}

func (c *bip47TestChain) TxHex(_ context.Context, txid string) (string, error) {
	tx, ok := c.txs[txid]
	if !ok {
		return "", errors.New("tx hex not found")
	}
	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		return "", err
	}
	return hex.EncodeToString(buf.Bytes()), nil
}

func newBip47TestChain(t *testing.T, addr string, amount int64, feeRate float64) *bip47TestChain {
	t.Helper()
	c := &bip47TestChain{addr: addr, amount: amount, txs: map[string]*wire.MsgTx{}, feeRate: feeRate}
	c.addCoin(t, amount)
	c.txid = c.coinList[0].txid
	return c
}

// Broadcast refuses a transaction that spends a coin the chain does not hold,
// as a real server refuses a conflict.
func (c *bip47TestChain) Broadcast(_ context.Context, rawHex string) (string, error) {
	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		return "", err
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		return "", err
	}
	for _, in := range tx.TxIn {
		op := in.PreviousOutPoint
		_, idx, ok := lo.FindIndexOf(c.coinList, func(coin bip47TestCoin) bool {
			return coin.txid == op.Hash.String() && coin.vout == int(op.Index)
		})
		if !ok {
			return "", fmt.Errorf("input %s is spent or unknown", op)
		}
		c.coinList = append(c.coinList[:idx], c.coinList[idx+1:]...)
	}
	c.broadcast = append(c.broadcast, rawHex)
	return c.record(&tx, false), nil
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
	assert.False(t, first.FeeIsEstimate, "two coins give an exact fee")
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

	amounts := map[string]int64{chain.txid: 500_000}
	for txid, tx := range chain.txs {
		if len(tx.TxOut) == 1 && tx.TxOut[0].Value == 300_000 {
			amounts[txid] = 300_000
		}
	}
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

// A first payment from a one-coin wallet pays from the notification change,
// so the preview gives an estimate and pins no coin, and the send still goes out.
func TestPreviewSendBip47OneCoinGivesAnEstimate(t *testing.T) {
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

	resp, err := h.PreviewSend(context.Background(), connect.NewRequest(&pb.PreviewSendRequest{
		WalletId:           w.ID,
		Destinations:       map[string]int64{code: 50_000},
		FeeRateSatPerVbyte: rate,
	}))
	require.NoError(t, err)
	assert.True(t, resp.Msg.FeeIsEstimate)
	assert.Positive(t, resp.Msg.FeeSats)
	assert.Equal(t, bip47send.EstimateNotificationFee(rate), resp.Msg.NotificationFeeSats)
	assert.Empty(t, resp.Msg.Inputs, "the payment coin does not exist before the notification")
	assert.Nil(t, resp.Msg.NotificationInput)
	assert.Empty(t, chain.broadcast)

	_, err = h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           w.ID,
		Destinations:       map[string]int64{code: 50_000},
		FeeRateSatPerVbyte: rate,
	}))
	require.NoError(t, err)
	assert.Len(t, chain.broadcast, 2, "the notification and the payment both go out")
}

// The notification of a one-coin wallet takes its fee and dust from the coin
// first, so a payment that needs the whole coin must not pass the preview.
func TestPreviewSendBip47OneCoinRefusesWhatTheChangeCannotPay(t *testing.T) {
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

	const coinSats = 500_000
	chain := newBip47TestChain(t, addrs[0], coinSats, 5)
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log)
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(bip47state.NewStore(t.TempDir()))

	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)

	_, err = h.PreviewSend(context.Background(), connect.NewRequest(&pb.PreviewSendRequest{
		WalletId:              w.ID,
		Destinations:          map[string]int64{recipient.Base58(): coinSats},
		FeeRateSatPerVbyte:    5,
		SubtractFeeFromAmount: true,
	}))
	require.ErrorContains(t, err, "after the BIP47 notification")
}
