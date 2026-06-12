package wallet

import (
	"bytes"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

type mapKeySource map[string]*btcec.PrivateKey

func (m mapKeySource) PrivKeyForAddress(address string) (*btcec.PrivateKey, bool) {
	k, ok := m[address]
	return k, ok
}

// fixedKey derives a deterministic private key for tests.
func fixedKey(b byte) *btcec.PrivateKey {
	var seed [32]byte
	for i := range seed {
		seed[i] = b
	}
	priv, _ := btcec.PrivKeyFromBytes(seed[:])
	return priv
}

func p2wpkhAddr(t *testing.T, priv *btcec.PrivateKey, net *chaincfg.Params) string {
	t.Helper()
	addr, err := btcutil.NewAddressWitnessPubKeyHash(
		btcutil.Hash160(priv.PubKey().SerializeCompressed()), net,
	)
	if err != nil {
		t.Fatal(err)
	}
	return addr.EncodeAddress()
}

func p2pkhAddr(t *testing.T, priv *btcec.PrivateKey, net *chaincfg.Params) string {
	t.Helper()
	addr, err := btcutil.NewAddressPubKeyHash(
		btcutil.Hash160(priv.PubKey().SerializeCompressed()), net,
	)
	if err != nil {
		t.Fatal(err)
	}
	return addr.EncodeAddress()
}

// TestSignTransactionLocal signs a tx spending one P2WPKH and one P2PKH
// prevout, then proves both signatures by executing the script engine.
func TestSignTransactionLocal(t *testing.T) {
	net := &chaincfg.RegressionNetParams

	keyW := fixedKey(0x11)
	keyL := fixedKey(0x22)
	addrW := p2wpkhAddr(t, keyW, net)
	addrL := p2pkhAddr(t, keyL, net)

	inputs := []RawInput{
		{TxID: "aa00000000000000000000000000000000000000000000000000000000000001", Vout: 0},
		{TxID: "aa00000000000000000000000000000000000000000000000000000000000002", Vout: 3},
	}
	dest := p2wpkhAddr(t, fixedKey(0x33), net)
	rawHex, err := BuildUnsignedTransaction(inputs, []TxOutSpec{{Address: dest, AmountBTC: 0.0009}}, net)
	if err != nil {
		t.Fatalf("build: %v", err)
	}

	op := func(s string, vout uint32) wire.OutPoint {
		h, _ := chainhash.NewHashFromStr(s)
		return wire.OutPoint{Hash: *h, Index: vout}
	}
	prevOuts := map[wire.OutPoint]PrevOut{
		op(inputs[0].TxID, 0): {Address: addrW, AmountSats: 60_000},
		op(inputs[1].TxID, 3): {Address: addrL, AmountSats: 50_000},
	}
	keys := mapKeySource{addrW: keyW, addrL: keyL}

	signed, err := SignTransactionLocal(rawHex, prevOuts, keys, net)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	if !signed.Complete {
		t.Fatal("signing reported incomplete")
	}

	raw, err := hex.DecodeString(signed.Hex)
	if err != nil {
		t.Fatalf("decode signed hex: %v", err)
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		t.Fatalf("deserialize signed: %v", err)
	}

	// Execute each input's script against its prevout — the real proof.
	fetcher := txscript.NewMultiPrevOutFetcher(nil)
	for o, po := range prevOuts {
		addr, _ := btcutil.DecodeAddress(po.Address, net)
		script, _ := txscript.PayToAddrScript(addr)
		fetcher.AddPrevOut(o, wire.NewTxOut(po.AmountSats, script))
	}
	sigHashes := txscript.NewTxSigHashes(&tx, fetcher)
	for i, in := range tx.TxIn {
		prev := fetcher.FetchPrevOutput(in.PreviousOutPoint)
		vm, err := txscript.NewEngine(
			prev.PkScript, &tx, i, txscript.StandardVerifyFlags, nil, sigHashes, prev.Value, fetcher,
		)
		if err != nil {
			t.Fatalf("engine input %d: %v", i, err)
		}
		if err := vm.Execute(); err != nil {
			t.Errorf("input %d signature invalid: %v", i, err)
		}
	}
}

// TestSignTransactionLocalIncomplete: a missing key yields Complete=false
// without erroring, mirroring signrawtransactionwithwallet semantics.
func TestSignTransactionLocalIncomplete(t *testing.T) {
	net := &chaincfg.RegressionNetParams

	keyW := fixedKey(0x44)
	addrW := p2wpkhAddr(t, keyW, net)
	addrMissing := p2wpkhAddr(t, fixedKey(0x55), net)

	inputs := []RawInput{
		{TxID: "bb00000000000000000000000000000000000000000000000000000000000001", Vout: 0},
		{TxID: "bb00000000000000000000000000000000000000000000000000000000000002", Vout: 0},
	}
	rawHex, err := BuildUnsignedTransaction(inputs, []TxOutSpec{{Address: addrW, AmountBTC: 0.0001}}, net)
	if err != nil {
		t.Fatalf("build: %v", err)
	}

	op := func(s string) wire.OutPoint {
		h, _ := chainhash.NewHashFromStr(s)
		return wire.OutPoint{Hash: *h, Index: 0}
	}
	prevOuts := map[wire.OutPoint]PrevOut{
		op(inputs[0].TxID): {Address: addrW, AmountSats: 20_000},
		op(inputs[1].TxID): {Address: addrMissing, AmountSats: 20_000},
	}

	signed, err := SignTransactionLocal(rawHex, prevOuts, mapKeySource{addrW: keyW}, net)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	if signed.Complete {
		t.Error("expected incomplete signing with a missing key")
	}
}
