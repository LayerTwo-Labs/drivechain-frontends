package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

func newBip47InputHandler(t *testing.T, scriptType string) (*WalletHandler, *wallet.WalletData, *bip47TestChain) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("Sender", nil, nil, "", "", "", scriptType, 0, "")
	require.NoError(t, err)
	net := &chaincfg.SigNetParams
	addresses, err := wallet.DeriveWalletReceiveAddresses(w, net, 0, 1)
	require.NoError(t, err)
	chain := newBip47TestChain(t, addresses[0], 500_000, 5)
	backend := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, backend), wallet.StaticParams(net), log)
	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	h.SetBip47StateStore(bip47state.NewStore(t.TempDir()))
	return h, w, chain
}

func bip47InputRequest(t *testing.T, walletID string) *pb.SendTransactionRequest {
	t.Helper()
	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), &chaincfg.SigNetParams)
	require.NoError(t, err)
	return &pb.SendTransactionRequest{
		WalletId:           walletID,
		Destinations:       map[string]int64{recipient.Base58(): 50_000},
		FeeRateSatPerVbyte: 5,
	}
}

func TestSendTransactionBip47SkipsTaproot(t *testing.T) {
	h, w, chain := newBip47InputHandler(t, "native-segwit")
	taprootWallet := *w
	taprootWallet.ScriptType = "taproot"
	addresses, err := wallet.DeriveWalletReceiveAddresses(&taprootWallet, &chaincfg.SigNetParams, 0, 1)
	require.NoError(t, err)
	chain.addCoinTo(t, addresses[0], 300_000)

	req := bip47InputRequest(t, w.ID)
	preview, err := h.PreviewSend(context.Background(), &pb.PreviewSendRequest{
		WalletId:           req.WalletId,
		Destinations:       req.Destinations,
		FeeRateSatPerVbyte: req.FeeRateSatPerVbyte,
	})
	require.NoError(t, err)
	require.NotNil(t, preview.NotificationInput)
	assert.Equal(t, chain.txid, preview.NotificationInput.Txid)
	assert.Empty(t, chain.broadcast)

	req.NotificationInput = preview.NotificationInput
	req.RequiredInputs = preview.Inputs
	_, err = h.SendTransaction(context.Background(), req)
	require.NoError(t, err)
	require.Len(t, chain.broadcast, 2)
	notification := decodeBip47TestTx(t, chain.broadcast[0])
	require.Len(t, notification.TxIn, 1)
	assert.Equal(t, chain.txid, notification.TxIn[0].PreviousOutPoint.Hash.String())
	assertBip47NotificationCode(t, w.Master.SeedHex, notification)
}

func TestSendTransactionBip47RefusesTaprootOnly(t *testing.T) {
	h, w, chain := newBip47InputHandler(t, "taproot")
	req := bip47InputRequest(t, w.ID)
	_, err := h.PreviewSend(context.Background(), &pb.PreviewSendRequest{
		WalletId:           req.WalletId,
		Destinations:       req.Destinations,
		FeeRateSatPerVbyte: req.FeeRateSatPerVbyte,
	})
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

	_, err = h.SendTransaction(context.Background(), req)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.ErrorContains(t, err, "Use P2PKH, P2WPKH, or P2SH-P2WPKH")
	assert.Empty(t, chain.broadcast)
	for code := range req.Destinations {
		state, err := h.bip47State.GetState(w.ID, code)
		require.NoError(t, err)
		require.NotNil(t, state)
		assert.Nil(t, state.NotificationTxID)
		assert.Zero(t, state.NextSendIndex)
	}
}

func TestSendTransactionBip47RefusesPinnedTaproot(t *testing.T) {
	h, w, chain := newBip47InputHandler(t, "taproot")
	nativeWallet := *w
	nativeWallet.ScriptType = "native-segwit"
	addresses, err := wallet.DeriveWalletReceiveAddresses(&nativeWallet, &chaincfg.SigNetParams, 0, 1)
	require.NoError(t, err)
	chain.addCoinTo(t, addresses[0], 300_000)

	req := bip47InputRequest(t, w.ID)
	req.NotificationInput = &pb.UnspentOutput{Txid: chain.txid, Vout: 0, AmountSats: 500_000}
	_, err = h.SendTransaction(context.Background(), req)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.ErrorContains(t, err, "notification coin "+chain.txid+":0 cannot fund BIP47")
	assert.ErrorContains(t, err, "Use P2PKH, P2WPKH, or P2SH-P2WPKH")
	assert.Empty(t, chain.broadcast)
}

func TestSendTransactionBip47ExposesTheInputKey(t *testing.T) {
	for _, scriptType := range []string{"legacy", "native-segwit"} {
		t.Run(scriptType, func(t *testing.T) {
			h, w, chain := newBip47InputHandler(t, scriptType)
			_, err := h.SendTransaction(context.Background(), bip47InputRequest(t, w.ID))
			require.NoError(t, err)
			require.Len(t, chain.broadcast, 2)
			notification := decodeBip47TestTx(t, chain.broadcast[0])
			require.Len(t, notification.TxIn, 1)
			input := notification.TxIn[0]
			switch scriptType {
			case "legacy":
				assert.Empty(t, input.Witness)
				assert.NotEmpty(t, input.SignatureScript)
			case "native-segwit":
				assert.Len(t, input.Witness, 2)
				assert.Empty(t, input.SignatureScript)
			}
			assertBip47NotificationCode(t, w.Master.SeedHex, notification)
		})
	}
}

func TestBip47NotificationSupportsNestedSegwit(t *testing.T) {
	h, w, chain := newBip47InputHandler(t, "nested-segwit")
	net := &chaincfg.SigNetParams
	recipient, err := bip47.PaymentCodeFromSeed(strings.Repeat("ab", 32), net)
	require.NoError(t, err)
	raw, address, err := h.buildBip47NotificationTx(context.Background(), w.ID, w.Master.SeedHex, recipient, net, 5, nil, nil)
	require.NoError(t, err)
	assert.Equal(t, chain.addr, address)
	tx := decodeBip47TestTx(t, raw)
	key, err := wallet.SigningKey(w, net, address, 1)
	require.NoError(t, err)
	keyHash := btcutil.Hash160(key.PubKey().SerializeCompressed())
	witnessAddress, err := btcutil.NewAddressWitnessPubKeyHash(keyHash, net)
	require.NoError(t, err)
	redeemScript, err := txscript.PayToAddrScript(witnessAddress)
	require.NoError(t, err)
	keyAddress, err := btcutil.NewAddressPubKeyHash(keyHash, net)
	require.NoError(t, err)
	scriptCode, err := txscript.PayToAddrScript(keyAddress)
	require.NoError(t, err)
	prevOut := chain.txs[chain.txid].TxOut[0]
	fetcher := txscript.NewCannedPrevOutputFetcher(prevOut.PkScript, prevOut.Value)
	hashes := txscript.NewTxSigHashes(tx, fetcher)
	tx.TxIn[0].Witness, err = txscript.WitnessSignature(tx, hashes, 0, prevOut.Value, scriptCode, txscript.SigHashAll, key, true)
	require.NoError(t, err)
	tx.TxIn[0].SignatureScript, err = txscript.NewScriptBuilder().AddData(redeemScript).Script()
	require.NoError(t, err)
	engine, err := txscript.NewEngine(prevOut.PkScript, tx, 0, txscript.StandardVerifyFlags, nil, hashes, prevOut.Value, fetcher)
	require.NoError(t, err)
	require.NoError(t, engine.Execute())
	assertBip47NotificationCode(t, w.Master.SeedHex, tx)
}

func decodeBip47TestTx(t *testing.T, rawHex string) *wire.MsgTx {
	t.Helper()
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	return &tx
}

func assertBip47NotificationCode(t *testing.T, senderSeed string, tx *wire.MsgTx) {
	t.Helper()
	input := tx.TxIn[0]
	var publicKey []byte
	if len(input.Witness) == 2 {
		publicKey = input.Witness[1]
	} else {
		pushes, err := txscript.PushedData(input.SignatureScript)
		require.NoError(t, err)
		require.Len(t, pushes, 2)
		publicKey = pushes[1]
	}
	senderKey, err := btcec.ParsePubKey(publicKey)
	require.NoError(t, err)
	require.Len(t, tx.TxOut, 3)
	pushes, err := txscript.PushedData(tx.TxOut[1].PkScript)
	require.NoError(t, err)
	require.Len(t, pushes, 1)
	require.Len(t, pushes[0], bip47.PaymentCodeLength)
	var payload [bip47.PaymentCodeLength]byte
	copy(payload[:], pushes[0])
	recipientKey, _, err := bip47.DeriveOwnNotificationKey(strings.Repeat("ab", 32), &chaincfg.SigNetParams)
	require.NoError(t, err)
	code, err := bip47.DecodeBlindedPayload(recipientKey, senderKey, input.PreviousOutPoint, payload)
	require.NoError(t, err)
	want, err := bip47.PaymentCodeFromSeed(senderSeed, &chaincfg.SigNetParams)
	require.NoError(t, err)
	assert.Equal(t, want.Base58(), code.Base58())
}
