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
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const warningTestMessage = "This transaction burns Alphanet coins for a claim of real ECX. You cannot reverse this transaction."
const warningTestBurnAddress = wallet.ECXBurnAddress
const warningTestClaimAddress = "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"
const warningTestPublicKey = "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"

type warningBackend struct {
	detailsProvider
	transactions []wallet.WalletTransaction
	hexByID      map[string]string
	readIDs      []string
	walletID     string
	readError    error
	afterRead    func()
}

func (f *warningBackend) ListTransactions(_ context.Context, _ string, count int) ([]wallet.WalletTransaction, error) {
	if count > 0 && count < len(f.transactions) {
		return f.transactions[:count], nil
	}
	return f.transactions, nil
}

func (f *warningBackend) GetWalletTransaction(_ context.Context, walletID, txid string) (*wallet.WalletTx, error) {
	f.readIDs = append(f.readIDs, txid)
	f.walletID = walletID
	if f.readError != nil {
		return nil, f.readError
	}
	raw, ok := f.hexByID[txid]
	if !ok {
		return nil, fmt.Errorf("transaction %s is absent", txid)
	}
	if f.afterRead != nil {
		f.afterRead()
	}
	return &wallet.WalletTx{TxID: txid, Hex: raw}, nil
}

func newWarningHandler(t *testing.T, backend *warningBackend) (*WalletHandler, string) {
	t.Helper()
	previousID := config.ECashNetworkID()
	config.SetECashNetworkID("alphanet")
	t.Cleanup(func() { config.SetECashNetworkID(previousID) })
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork(string(config.NetworkECash))
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	w, err := svc.GenerateWallet("Warning", "", "", nil)
	require.NoError(t, err)
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, backend, wallet.StaticParams(&chaincfg.MainNetParams), log))
	return h, w.ID
}

func warningDataScript(t *testing.T, address string) string {
	t.Helper()
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(address)).Script()
	require.NoError(t, err)
	return hex.EncodeToString(script)
}

func warningOutputs(t *testing.T) []*pb.TransactionOutput {
	t.Helper()
	address, err := btcutil.DecodeAddress(warningTestBurnAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(address)
	require.NoError(t, err)
	return []*pb.TransactionOutput{
		{ValueSats: 1, Address: warningTestBurnAddress, ScriptPubkeyHex: hex.EncodeToString(script)},
		{ValueSats: 0, ScriptPubkeyHex: warningDataScript(t, warningTestClaimAddress)},
	}
}

func warningTransaction(t *testing.T, outputs []*pb.TransactionOutput) (string, string, *wallet.RawTransaction) {
	t.Helper()
	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1}, 0), nil, nil))
	rawTx := &wallet.RawTransaction{}
	for _, output := range outputs {
		script, err := hex.DecodeString(output.ScriptPubkeyHex)
		require.NoError(t, err)
		tx.AddTxOut(wire.NewTxOut(output.ValueSats, script))
		rawTx.Vout = append(rawTx.Vout, wallet.RawTxOut{
			Value:        float64(output.ValueSats) / 1e8,
			ScriptPubKey: wallet.ScriptPubKey{Address: output.Address, Hex: output.ScriptPubkeyHex},
		})
	}
	rawTx.TxID = tx.TxHash().String()
	var raw bytes.Buffer
	require.NoError(t, tx.Serialize(&raw))
	rawTx.Hex = hex.EncodeToString(raw.Bytes())
	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	return rawTx.Hex, encoded, rawTx
}

func TestTransactionWarningChecksTheBurnOutputs(t *testing.T) {
	cases := []struct {
		name   string
		change func([]*pb.TransactionOutput) []*pb.TransactionOutput
		warn   bool
	}{
		{"burn intent", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { return o }, true},
		{"no address metadata", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[0].Address = ""; return o }, true},
		{"uppercase script", func(o []*pb.TransactionOutput) []*pb.TransactionOutput {
			o[0].ScriptPubkeyHex = strings.ToUpper(o[0].ScriptPubkeyHex)
			return o
		}, true},
		{"ordinary payment", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[0].ScriptPubkeyHex = "51"; return o }, false},
		{"zero burn", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[0].ValueSats = 0; return o }, false},
		{"negative burn", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[0].ValueSats = -1; return o }, false},
		{"no OP_RETURN", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { return o[:1] }, false},
		{"nonzero OP_RETURN", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[1].ValueSats = 1; return o }, false},
		{"invalid address", func(o []*pb.TransactionOutput) []*pb.TransactionOutput {
			o[1].ScriptPubkeyHex = warningDataScript(t, "invalid")
			return o
		}, false},
		{"testnet address", func(o []*pb.TransactionOutput) []*pb.TransactionOutput {
			o[1].ScriptPubkeyHex = warningDataScript(t, "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx")
			return o
		}, false},
		{"public key", func(o []*pb.TransactionOutput) []*pb.TransactionOutput {
			o[1].ScriptPubkeyHex = warningDataScript(t, warningTestPublicKey)
			return o
		}, false},
		{"invalid hex", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[1].ScriptPubkeyHex = "zz"; return o }, false},
		{"empty data", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[1].ScriptPubkeyHex = "6a"; return o }, false},
		{"short data", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[1].ScriptPubkeyHex = "6a4c"; return o }, false},
		{"extra data", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[1].ScriptPubkeyHex += "0101"; return o }, false},
		{"extra opcode", func(o []*pb.TransactionOutput) []*pb.TransactionOutput { o[1].ScriptPubkeyHex += "51"; return o }, false},
		{"other opcode", func(o []*pb.TransactionOutput) []*pb.TransactionOutput {
			o[1].ScriptPubkeyHex = "00" + o[1].ScriptPubkeyHex[2:]
			return o
		}, false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h, _ := newWarningHandler(t, &warningBackend{})
			message := h.transactionWarning(tc.change(warningOutputs(t)))
			if tc.warn {
				require.Equal(t, warningTestMessage, message)
			} else {
				require.Empty(t, message)
			}
		})
	}
}

func TestTransactionWarningChecksTheNetwork(t *testing.T) {
	h, _ := newWarningHandler(t, &warningBackend{})
	require.Equal(t, warningTestMessage, h.transactionWarning(warningOutputs(t)))
	for _, tc := range []struct {
		network config.Network
		id      string
		warn    bool
	}{
		{config.NetworkECash, "alphanet", true},
		{config.NetworkECash, "betanet", false},
		{config.NetworkMainnet, "alphanet", false},
		{config.NetworkSignet, "alphanet", false},
		{config.NetworkRegtest, "alphanet", false},
		{config.NetworkTestnet, "alphanet", false},
	} {
		t.Run(string(tc.network)+" "+tc.id, func(t *testing.T) {
			require.NoError(t, h.svc.RebindNetwork(string(tc.network)))
			config.SetECashNetworkID(tc.id)
			message := h.transactionWarning(warningOutputs(t))
			if tc.warn {
				require.Equal(t, warningTestMessage, message)
			} else {
				require.Empty(t, message)
			}
		})
	}
}

func TestDecodeTransactionReturnsTheBurnWarning(t *testing.T) {
	raw, packet, tx := warningTransaction(t, warningOutputs(t))
	for _, input := range []string{raw, packet, tx.TxID} {
		for _, explicitWallet := range []bool{false, true} {
			backend := &warningBackend{detailsProvider: detailsProvider{rawTx: tx}}
			h, walletID := newWarningHandler(t, backend)
			if !explicitWallet {
				walletID = ""
			}
			response, err := h.DecodeTransaction(context.Background(), connect.NewRequest(&pb.DecodeTransactionRequest{
				Input: input, WalletId: walletID,
			}))
			require.NoError(t, err)
			require.Equal(t, warningTestMessage, response.Msg.WarningMessage)
		}
	}
}

func TestGetTransactionDetailsReturnsTheBurnWarning(t *testing.T) {
	raw, _, tx := warningTransaction(t, warningOutputs(t))
	backend := &warningBackend{detailsProvider: detailsProvider{rawTx: tx}, hexByID: map[string]string{tx.TxID: raw}}
	h, walletID := newWarningHandler(t, backend)
	response, err := h.GetTransactionDetails(context.Background(), connect.NewRequest(&pb.GetTransactionDetailsRequest{
		WalletId: walletID, Txid: tx.TxID,
	}))
	require.NoError(t, err)
	require.Equal(t, warningTestMessage, response.Msg.Transaction.WarningMessage)
	require.Equal(t, []string{tx.TxID}, backend.readIDs)
}

func TestListTransactionsWarnsAllRowsAndReadsEachTransactionOnce(t *testing.T) {
	raw, _, tx := warningTransaction(t, warningOutputs(t))
	payment, _, paymentTx := warningTransaction(t, warningOutputs(t)[:1])
	ordinary, _, ordinaryTx := warningTransaction(t, warningOutputs(t)[1:])
	backend := &warningBackend{
		hexByID: map[string]string{tx.TxID: raw, paymentTx.TxID: payment, ordinaryTx.TxID: ordinary},
		transactions: []wallet.WalletTransaction{
			{TxID: tx.TxID, Address: "", Category: "send"},
			{TxID: tx.TxID, Address: warningTestBurnAddress, Category: "send"},
			{TxID: tx.TxID, Address: warningTestBurnAddress, Category: "send", Confirmations: 2},
			{TxID: ordinaryTx.TxID, Label: ecxBurnWarning},
			{TxID: paymentTx.TxID, Address: warningTestBurnAddress, Category: "send"},
			{TxID: paymentTx.TxID, Address: warningTestBurnAddress, Category: "send"},
		},
	}
	h, walletID := newWarningHandler(t, backend)
	response, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletID}))
	require.NoError(t, err)
	require.Equal(t, []string{tx.TxID, ordinaryTx.TxID, paymentTx.TxID}, backend.readIDs)
	require.Equal(t, walletID, backend.walletID)
	for _, entry := range response.Msg.Transactions {
		if entry.Txid == tx.TxID {
			require.Equal(t, warningTestMessage, entry.WarningMessage)
		} else {
			require.Empty(t, entry.WarningMessage)
		}
	}
	repeated, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletID}))
	require.NoError(t, err)
	require.Equal(t, response.Msg, repeated.Msg)
	require.Equal(t, []string{tx.TxID, ordinaryTx.TxID, paymentTx.TxID}, backend.readIDs)
}

func TestListTransactionsWarnsWithoutTheBurnAddressRow(t *testing.T) {
	outputs := warningOutputs(t)
	outputs[0], outputs[1] = outputs[1], outputs[0]
	raw, _, tx := warningTransaction(t, outputs)
	backend := &warningBackend{
		hexByID: map[string]string{tx.TxID: raw},
		transactions: []wallet.WalletTransaction{
			{TxID: tx.TxID, Category: "send"},
			{TxID: tx.TxID, Address: warningTestBurnAddress, Category: "send"},
		},
	}
	h, walletID := newWarningHandler(t, backend)
	response, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{
		WalletId: walletID, Count: 1,
	}))
	require.NoError(t, err)
	require.Len(t, response.Msg.Transactions, 1)
	require.Empty(t, response.Msg.Transactions[0].Address)
	require.Equal(t, warningTestMessage, response.Msg.Transactions[0].WarningMessage)
	require.Equal(t, []string{tx.TxID}, backend.readIDs)
}

func TestListTransactionsKeepsTheCacheAcrossNetworkChanges(t *testing.T) {
	raw, _, tx := warningTransaction(t, warningOutputs(t))
	backend := &warningBackend{
		hexByID: map[string]string{tx.TxID: raw},
		transactions: []wallet.WalletTransaction{
			{TxID: tx.TxID, Address: warningTestBurnAddress, Category: "send"},
		},
		afterRead: func() { config.SetECashNetworkID("betanet") },
	}
	h, walletID := newWarningHandler(t, backend)
	_, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletID}))
	require.NoError(t, err)
	config.SetECashNetworkID("alphanet")
	response, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletID}))
	require.NoError(t, err)
	require.Equal(t, warningTestMessage, response.Msg.Transactions[0].WarningMessage)
	require.Equal(t, []string{tx.TxID}, backend.readIDs)
}

func TestListTransactionsReturnsWarningReadErrors(t *testing.T) {
	for _, tc := range []struct {
		name string
		err  error
		raw  string
	}{
		{"read", errors.New("node unavailable"), ""},
		{"decode", nil, "invalid"},
		{"no raw transaction", nil, "0000000000000000000000000000000000000000000000000000000000000001"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			backend := &warningBackend{
				transactions: []wallet.WalletTransaction{{TxID: "burn", Address: warningTestBurnAddress}},
				hexByID:      map[string]string{"burn": tc.raw}, readError: tc.err,
			}
			h, walletID := newWarningHandler(t, backend)
			response, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletID}))
			require.Nil(t, response)
			require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
		})
	}
}

func TestListTransactionsSkipsWarningsOutsideAlphanet(t *testing.T) {
	for _, tc := range []struct {
		network config.Network
		id      string
	}{
		{config.NetworkECash, "betanet"},
		{config.NetworkMainnet, "alphanet"},
		{config.NetworkSignet, "alphanet"},
		{config.NetworkRegtest, "alphanet"},
		{config.NetworkTestnet, "alphanet"},
	} {
		t.Run(string(tc.network)+" "+tc.id, func(t *testing.T) {
			backend := &warningBackend{
				transactions: []wallet.WalletTransaction{{TxID: "burn", Address: warningTestBurnAddress}},
				readError:    errors.New("unexpected read"),
			}
			h, walletID := newWarningHandler(t, backend)
			require.NoError(t, h.svc.RebindNetwork(string(tc.network)))
			config.SetECashNetworkID(tc.id)
			response, err := h.ListTransactions(context.Background(), connect.NewRequest(&pb.ListTransactionsRequest{WalletId: walletID}))
			require.NoError(t, err)
			require.Empty(t, response.Msg.Transactions[0].WarningMessage)
			require.Empty(t, backend.readIDs)
		})
	}
}
