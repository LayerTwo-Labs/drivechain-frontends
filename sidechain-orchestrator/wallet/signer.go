package wallet

import (
	"bytes"
	"encoding/hex"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// KeySource resolves the private key controlling a wallet address.
// Providers that sign locally implement this from their derivation state.
type KeySource interface {
	PrivKeyForAddress(address string) (*btcec.PrivateKey, bool)
}

// PrevOut is the output an input spends — needed to compute its sighash.
type PrevOut struct {
	Address    string
	AmountSats int64
}

// SignTransactionLocal signs every input of rawHex whose prevout address
// resolves through keys, entirely in-process. Supports P2WPKH and P2PKH
// prevouts. Complete is true only when every input got a signature.
func SignTransactionLocal(
	rawHex string,
	prevOuts map[wire.OutPoint]PrevOut,
	keys KeySource,
	net *chaincfg.Params,
) (*SignRawTransactionResult, error) {
	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		return nil, fmt.Errorf("decode tx hex: %w", err)
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, fmt.Errorf("deserialize tx: %w", err)
	}

	fetcher := txscript.NewMultiPrevOutFetcher(nil)
	scripts := make(map[wire.OutPoint][]byte, len(prevOuts))
	for op, po := range prevOuts {
		addr, err := btcutil.DecodeAddress(po.Address, net)
		if err != nil {
			return nil, fmt.Errorf("decode prevout address %q: %w", po.Address, err)
		}
		script, err := txscript.PayToAddrScript(addr)
		if err != nil {
			return nil, fmt.Errorf("script for %q: %w", po.Address, err)
		}
		scripts[op] = script
		fetcher.AddPrevOut(op, wire.NewTxOut(po.AmountSats, script))
	}
	sigHashes := txscript.NewTxSigHashes(&tx, fetcher)

	complete := true
	for i, in := range tx.TxIn {
		po, ok := prevOuts[in.PreviousOutPoint]
		if !ok {
			complete = false
			continue
		}
		priv, ok := keys.PrivKeyForAddress(po.Address)
		if !ok {
			complete = false
			continue
		}

		addr, err := btcutil.DecodeAddress(po.Address, net)
		if err != nil {
			return nil, fmt.Errorf("decode address %q: %w", po.Address, err)
		}
		script := scripts[in.PreviousOutPoint]

		switch addr.(type) {
		case *btcutil.AddressWitnessPubKeyHash:
			witness, err := txscript.WitnessSignature(
				&tx, sigHashes, i, po.AmountSats, script, txscript.SigHashAll, priv, true,
			)
			if err != nil {
				return nil, fmt.Errorf("sign witness input %d: %w", i, err)
			}
			tx.TxIn[i].Witness = witness
		case *btcutil.AddressPubKeyHash:
			sigScript, err := txscript.SignatureScript(
				&tx, i, script, txscript.SigHashAll, priv, true,
			)
			if err != nil {
				return nil, fmt.Errorf("sign legacy input %d: %w", i, err)
			}
			tx.TxIn[i].SignatureScript = sigScript
		default:
			complete = false
		}
	}

	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		return nil, fmt.Errorf("serialize signed tx: %w", err)
	}
	return &SignRawTransactionResult{
		Hex:      hex.EncodeToString(buf.Bytes()),
		Complete: complete,
	}, nil
}
