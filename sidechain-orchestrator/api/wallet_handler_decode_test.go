package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"strings"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

type decodeBackend struct {
	detailsProvider
	walletID string
}

type offlineDecodeSource struct {
	psbtTestEsplora
	reads atomic.Int32
}

func (s *offlineDecodeSource) AddressStats(context.Context, string) (wallet.EsploraAddressStats, error) {
	s.reads.Add(1)
	return wallet.EsploraAddressStats{}, errors.New("the indexer is offline")
}

func (s *offlineDecodeSource) TipHeight(context.Context) (int, error) {
	s.reads.Add(1)
	return 0, errors.New("the indexer is offline")
}

func newOfflineDecodeHandler(t *testing.T) (*WalletHandler, string, *offlineDecodeSource) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	w, err := svc.CreateElectrumWallet("Local decode", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	source := &offlineDecodeSource{}
	params := wallet.StaticParams(&chaincfg.SigNetParams)
	backend := wallet.NewElectrumBackend(svc, source, params, log)
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, backend, params, log))
	return h, w.ID, source
}

func (f *decodeBackend) OwnedAddresses(ctx context.Context, walletID string, addresses []string) (map[string]bool, error) {
	f.walletID = walletID
	return f.detailsProvider.OwnedAddresses(ctx, walletID, addresses)
}

func newDecodeHandler(t *testing.T, fake *decodeBackend) (*WalletHandler, string) {
	t.Helper()
	h, walletID := newDetailsHandler(t, &fake.detailsProvider)
	h.SetEngine(wallet.NewWalletEngine(h.svc, fake, wallet.StaticParams(&chaincfg.SigNetParams), zerolog.Nop()))
	return h, walletID
}

func decodeTestPacket(t *testing.T) (*psbt.Packet, []string) {
	t.Helper()
	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1}, 0), nil, nil))
	var addresses []string
	for i := byte(1); i <= 3; i++ {
		address, err := btcutil.NewAddressPubKeyHash(bytes.Repeat([]byte{i}, 20), &chaincfg.SigNetParams)
		require.NoError(t, err)
		script, err := txscript.PayToAddrScript(address)
		require.NoError(t, err)
		tx.AddTxOut(wire.NewTxOut(1000, script))
		addresses = append(addresses, address.EncodeAddress())
	}
	tx.AddTxOut(wire.NewTxOut(0, []byte{txscript.OP_RETURN}))
	addresses = append(addresses, "")
	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	_, pub := btcec.PrivKeyFromBytes([]byte{1})
	packet.Outputs[0].Bip32Derivation = []*psbt.Bip32Derivation{{
		PubKey: pub.SerializeCompressed(), Bip32Path: []uint32{1, 0},
	}}
	packet.Outputs[1].TaprootBip32Derivation = []*psbt.TaprootBip32Derivation{{
		XOnlyPubKey: pub.SerializeCompressed()[1:], Bip32Path: []uint32{1, 0},
	}}
	return packet, addresses
}

func TestDecodeTransactionChecksWalletOwnership(t *testing.T) {
	packet, addresses := decodeTestPacket(t)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	var raw bytes.Buffer
	require.NoError(t, packet.UnsignedTx.Serialize(&raw))
	for _, tc := range []struct {
		name  string
		input string
	}{
		{"psbt", encoded},
		{"raw", hex.EncodeToString(raw.Bytes())},
		{"txid", packet.UnsignedTx.TxHash().String()},
	} {
		t.Run(tc.name, func(t *testing.T) {
			fake := &decodeBackend{detailsProvider: detailsProvider{
				owned: map[string]bool{addresses[1]: false, addresses[2]: true},
				rawTx: &wallet.RawTransaction{TxID: packet.UnsignedTx.TxHash().String()},
			}}
			for _, address := range addresses {
				fake.rawTx.Vout = append(fake.rawTx.Vout, wallet.RawTxOut{ScriptPubKey: wallet.ScriptPubKey{Address: address}})
			}
			h, walletID := newDecodeHandler(t, fake)
			response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{
				Input: tc.input, WalletId: walletID, CheckOwnership: true,
			})
			require.NoError(t, err)
			require.Equal(t, walletID, fake.walletID)
			require.Equal(t, addresses, fake.askedOwned)
			require.Len(t, response.Outputs, 4)
			require.False(t, response.Outputs[0].IsMine)
			require.False(t, response.Outputs[0].IsChange)
			require.True(t, response.Outputs[1].IsMine)
			require.False(t, response.Outputs[1].IsChange)
			require.True(t, response.Outputs[2].IsMine)
			require.True(t, response.Outputs[2].IsChange)
			require.False(t, response.Outputs[3].IsMine)
			require.False(t, response.Outputs[3].IsChange)
		})
	}
}

func TestDecodeTransactionKeepsStaticMetadata(t *testing.T) {
	packet, _ := decodeTestPacket(t)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	fake := &decodeBackend{detailsProvider: detailsProvider{ownedErr: errors.New("unexpected wallet read")}}
	h, _ := newDecodeHandler(t, fake)
	response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{Input: encoded})
	require.NoError(t, err)
	require.Empty(t, fake.askedOwned)
	require.True(t, response.Outputs[0].IsChange)
	require.True(t, response.Outputs[1].IsChange)
	require.False(t, response.Outputs[2].IsChange)
	for _, output := range response.Outputs {
		require.False(t, output.IsMine)
	}
}

func TestDecodeTransactionReadsLocalDataWithoutAnIndexer(t *testing.T) {
	packet, _ := decodeTestPacket(t)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	var raw bytes.Buffer
	require.NoError(t, packet.UnsignedTx.Serialize(&raw))
	for _, tc := range []struct {
		name   string
		input  string
		wallet bool
	}{
		{"psbt", encoded, false},
		{"psbt with wallet", encoded, true},
		{"raw", hex.EncodeToString(raw.Bytes()), false},
		{"raw with wallet", hex.EncodeToString(raw.Bytes()), true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h, walletID, source := newOfflineDecodeHandler(t)
			if !tc.wallet {
				walletID = ""
			}
			response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{
				Input: tc.input, WalletId: walletID,
			})
			require.NoError(t, err)
			require.Zero(t, source.reads.Load())
			require.Equal(t, packet.UnsignedTx.TxHash().String(), response.Txid)
			require.Len(t, response.Outputs, len(packet.Outputs))
			for _, output := range response.Outputs {
				require.False(t, output.IsMine)
			}
		})
	}
}

func TestDecodeTransactionReturnsOwnershipError(t *testing.T) {
	packet, _ := decodeTestPacket(t)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	fake := &decodeBackend{detailsProvider: detailsProvider{ownedErr: errors.New("wallet read failed")}}
	h, walletID := newDecodeHandler(t, fake)
	response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{
		Input: encoded, WalletId: walletID, CheckOwnership: true,
	})
	require.Nil(t, response)
	require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	require.ErrorContains(t, err, "wallet read failed")
}

func TestDecodeTransactionChecksOwnershipWithAnOfflineIndexer(t *testing.T) {
	packet, _ := decodeTestPacket(t)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	var raw bytes.Buffer
	require.NoError(t, packet.UnsignedTx.Serialize(&raw))
	for _, tc := range []struct {
		name  string
		input string
	}{
		{"psbt", encoded},
		{"raw", hex.EncodeToString(raw.Bytes())},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h, walletID, source := newOfflineDecodeHandler(t)
			response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{
				Input: tc.input, WalletId: walletID, CheckOwnership: true,
			})
			require.Nil(t, response)
			require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
			require.ErrorContains(t, err, "the indexer is offline")
			require.Positive(t, source.reads.Load())
		})
	}
}

// Core with no txindex reads a confirmed tx by txid only from its block.
func TestDecodeTransactionReadsATxidWithNoTxindex(t *testing.T) {
	txid := strings.Repeat("ab", 32)
	confirmed := paymentWithChange()
	confirmed.TxID = txid
	confirmed.Blockhash = "block"
	confirmed.Vin[0].Prevout = &wallet.RawTxOut{Value: 8.43, ScriptPubKey: wallet.ScriptPubKey{Address: "funding"}}
	notInWallet := errors.New("Invalid or non-wallet transaction id")
	mempool := paymentWithChange()
	mempool.TxID = txid

	for _, tc := range []struct {
		name      string
		fake      detailsProvider
		blockHash string
		wantFee   bool
	}{
		{
			name: "wallet tx in a block",
			fake: detailsProvider{
				rawTxErr: wallet.ErrTxUnreadable,
				walletTx: &wallet.WalletTx{TxID: txid, Confirmations: 3, Blockhash: "block", Hex: "00"},
				blockTx:  confirmed,
			},
			wantFee: true,
		},
		{
			name:      "block named by the caller",
			fake:      detailsProvider{rawTxErr: wallet.ErrTxUnreadable, walletErr: notInWallet, blockTx: confirmed},
			blockHash: "block",
			wantFee:   true,
		},
		{
			name: "mempool tx",
			fake: detailsProvider{rawTx: mempool, walletErr: notInWallet},
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h, walletID := newDecodeHandler(t, &decodeBackend{detailsProvider: tc.fake})
			response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{
				Input: txid, WalletId: walletID, BlockHash: tc.blockHash,
			})
			require.NoError(t, err)
			require.Equal(t, pb.DecodedForm_DECODED_FORM_TXID, response.Form)
			require.Equal(t, txid, response.Txid)
			require.Len(t, response.Outputs, 3)
			require.Equal(t, tc.wantFee, response.HasFee)
			if tc.wantFee {
				require.Equal(t, "funding", response.Inputs[0].Address)
				require.Equal(t, int64(1_000_000), response.FeeSats)
			}
		})
	}

	t.Run("neither in the wallet nor in the mempool", func(t *testing.T) {
		fake := &decodeBackend{detailsProvider: detailsProvider{rawTxErr: wallet.ErrTxUnreadable, walletErr: notInWallet}}
		h, walletID := newDecodeHandler(t, fake)
		response, err := h.DecodeTransaction(context.Background(), &pb.DecodeTransactionRequest{
			Input: txid, WalletId: walletID,
		})
		require.Nil(t, response)
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
		require.ErrorContains(t, err, "not in the wallet or the mempool, and the node keeps no txindex")
	})
}

// Core with no txindex reads a confirmed deposit from the block the wallet names.
func TestDepositConfirmationsReadsABlockWithNoTxindex(t *testing.T) {
	txid := strings.Repeat("cd", 32)
	confirmed := paymentWithChange()
	confirmed.TxID = txid
	confirmed.Blockhash = "block"
	confirmed.Confirmations = 6
	h, walletID := newDecodeHandler(t, &decodeBackend{detailsProvider: detailsProvider{
		rawTxErr: wallet.ErrTxUnreadable,
		walletTx: &wallet.WalletTx{TxID: txid, Confirmations: 6, Blockhash: "block", Hex: "00"},
		blockTx:  confirmed,
	}})

	got := h.depositConfirmations(context.Background(), wallet.SidechainDeposit{Txid: txid, WalletID: walletID})

	require.EqualValues(t, 6, got)
}
