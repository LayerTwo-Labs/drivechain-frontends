// Package signmessage signs and verifies Bitcoin signed messages: BIP137 for
// P2PKH, P2SH-P2WPKH and P2WPKH addresses, BIP322 simple for every other address.
package signmessage

import (
	"bytes"
	"encoding/base64"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/ecdsa"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

const (
	messagePrefix = "Bitcoin Signed Message:\n"
	bip322Tag     = "BIP0322-signed-message"

	headerUncompressedP2PKH = 27
	headerCompressedP2PKH   = 31
	headerNestedSegwit      = 35
	headerNativeSegwit      = 39
	headerMax               = 42
	compactSigLen           = 65
)

func messageHash(message string) ([]byte, error) {
	var buf bytes.Buffer
	if err := wire.WriteVarString(&buf, 0, messagePrefix); err != nil {
		return nil, err
	}
	if err := wire.WriteVarString(&buf, 0, message); err != nil {
		return nil, err
	}
	return chainhash.DoubleHashB(buf.Bytes()), nil
}

func bip322MessageHash(message string) chainhash.Hash {
	return *chainhash.TaggedHash([]byte(bip322Tag), []byte(message))
}

// Sign returns the base64 signature of message for address. key must be the
// key the address commits to; for taproot, the tweaked output key.
func Sign(key *btcec.PrivateKey, address btcutil.Address, message string, params *chaincfg.Params) (string, error) {
	signature, err := sign(key, address, message)
	if err != nil {
		return "", err
	}

	valid, err := Verify(address.EncodeAddress(), message, signature, params)
	if err != nil {
		return "", fmt.Errorf("verify own signature: %w", err)
	}
	if !valid {
		return "", fmt.Errorf("key does not own address %s", address.EncodeAddress())
	}

	return signature, nil
}

func sign(key *btcec.PrivateKey, address btcutil.Address, message string) (string, error) {
	switch address.(type) {
	case *btcutil.AddressPubKeyHash:
		return signCompact(key, message, headerCompressedP2PKH)
	case *btcutil.AddressScriptHash:
		return signCompact(key, message, headerNestedSegwit)
	case *btcutil.AddressWitnessPubKeyHash:
		return signCompact(key, message, headerNativeSegwit)
	case *btcutil.AddressTaproot:
		return signTaproot(key, address, message)
	default:
		return "", fmt.Errorf("cannot sign a message for address type %T", address)
	}
}

func signCompact(key *btcec.PrivateKey, message string, header byte) (string, error) {
	hash, err := messageHash(message)
	if err != nil {
		return "", err
	}

	sig := ecdsa.SignCompact(key, hash, true)
	sig[0] += header - headerCompressedP2PKH
	return base64.StdEncoding.EncodeToString(sig), nil
}

func signTaproot(key *btcec.PrivateKey, address btcutil.Address, message string) (string, error) {
	pkScript, err := txscript.PayToAddrScript(address)
	if err != nil {
		return "", fmt.Errorf("address script: %w", err)
	}

	toSign := bip322ToSign(pkScript, message)
	fetcher := txscript.NewCannedPrevOutputFetcher(pkScript, 0)
	sigHash, err := txscript.CalcTaprootSignatureHash(
		txscript.NewTxSigHashes(toSign, fetcher), txscript.SigHashDefault, toSign, 0, fetcher,
	)
	if err != nil {
		return "", fmt.Errorf("taproot sighash: %w", err)
	}

	sig, err := schnorr.Sign(key, sigHash)
	if err != nil {
		return "", fmt.Errorf("schnorr sign: %w", err)
	}

	return encodeWitness(wire.TxWitness{sig.Serialize()})
}

// Verify reports whether signature signs message for address. It returns an
// error only when the address or the signature cannot be parsed.
func Verify(address, message, signature string, params *chaincfg.Params) (bool, error) {
	addr, err := btcutil.DecodeAddress(address, params)
	if err != nil {
		return false, fmt.Errorf("decode address: %w", err)
	}
	if !addr.IsForNet(params) {
		return false, fmt.Errorf("address %s is not for network %s", address, params.Name)
	}

	sig, err := base64.StdEncoding.DecodeString(signature)
	if err != nil {
		return false, fmt.Errorf("decode signature: %w", err)
	}

	if len(sig) == compactSigLen && sig[0] >= headerUncompressedP2PKH && sig[0] <= headerMax {
		return verifyCompact(addr, message, sig, params)
	}

	return verifyBIP322(addr, message, sig)
}

func verifyCompact(address btcutil.Address, message string, sig []byte, params *chaincfg.Params) (bool, error) {
	header := sig[0]
	normalized := append([]byte{normalizeHeader(header)}, sig[1:]...)

	hash, err := messageHash(message)
	if err != nil {
		return false, err
	}

	pubKey, compressed, err := ecdsa.RecoverCompact(normalized, hash)
	if err != nil {
		return false, nil
	}

	candidates, err := compactCandidates(header, pubKey, compressed, params)
	if err != nil {
		return false, err
	}

	for _, candidate := range candidates {
		if candidate.EncodeAddress() == address.EncodeAddress() {
			return true, nil
		}
	}
	return false, nil
}

func normalizeHeader(header byte) byte {
	switch {
	case header >= headerNativeSegwit:
		return header - (headerNativeSegwit - headerCompressedP2PKH)
	case header >= headerNestedSegwit:
		return header - (headerNestedSegwit - headerCompressedP2PKH)
	default:
		return header
	}
}

// compactCandidates lists the addresses a recovered key may prove. A
// compressed-P2PKH header also covers segwit, since Electrum writes that header
// for every address type.
func compactCandidates(header byte, pubKey *btcec.PublicKey, compressed bool, params *chaincfg.Params) ([]btcutil.Address, error) {
	if !compressed {
		addr, err := btcutil.NewAddressPubKeyHash(btcutil.Hash160(pubKey.SerializeUncompressed()), params)
		if err != nil {
			return nil, err
		}
		return []btcutil.Address{addr}, nil
	}

	pkHash := btcutil.Hash160(pubKey.SerializeCompressed())

	legacy, err := btcutil.NewAddressPubKeyHash(pkHash, params)
	if err != nil {
		return nil, err
	}

	native, err := btcutil.NewAddressWitnessPubKeyHash(pkHash, params)
	if err != nil {
		return nil, err
	}

	redeem, err := txscript.PayToAddrScript(native)
	if err != nil {
		return nil, err
	}
	nested, err := btcutil.NewAddressScriptHash(redeem, params)
	if err != nil {
		return nil, err
	}

	switch {
	case header >= headerNativeSegwit:
		return []btcutil.Address{native}, nil
	case header >= headerNestedSegwit:
		return []btcutil.Address{nested}, nil
	default:
		return []btcutil.Address{legacy, native, nested}, nil
	}
}

func verifyBIP322(address btcutil.Address, message string, sig []byte) (bool, error) {
	witness, err := decodeWitness(sig)
	if err != nil {
		return false, fmt.Errorf("decode BIP322 signature: %w", err)
	}

	pkScript, err := txscript.PayToAddrScript(address)
	if err != nil {
		return false, fmt.Errorf("address script: %w", err)
	}

	toSign := bip322ToSign(pkScript, message)
	toSign.TxIn[0].Witness = witness

	fetcher := txscript.NewCannedPrevOutputFetcher(pkScript, 0)
	engine, err := txscript.NewEngine(
		pkScript, toSign, 0, txscript.StandardVerifyFlags, nil,
		txscript.NewTxSigHashes(toSign, fetcher), 0, fetcher,
	)
	if err != nil {
		return false, nil
	}

	return engine.Execute() == nil, nil
}

// bip322ToSign builds the unsigned BIP322 to_sign transaction for pkScript.
func bip322ToSign(pkScript []byte, message string) *wire.MsgTx {
	hash := bip322MessageHash(message)
	scriptSig := append([]byte{txscript.OP_0, txscript.OP_DATA_32}, hash[:]...)

	toSpend := wire.NewMsgTx(0)
	toSpend.AddTxIn(&wire.TxIn{
		PreviousOutPoint: wire.OutPoint{Index: 0xffffffff},
		SignatureScript:  scriptSig,
		Sequence:         0,
	})
	toSpend.AddTxOut(wire.NewTxOut(0, pkScript))

	toSign := wire.NewMsgTx(0)
	toSign.AddTxIn(&wire.TxIn{
		PreviousOutPoint: wire.OutPoint{Hash: toSpend.TxHash(), Index: 0},
		Sequence:         0,
	})
	toSign.AddTxOut(wire.NewTxOut(0, []byte{txscript.OP_RETURN}))

	return toSign
}

func encodeWitness(witness wire.TxWitness) (string, error) {
	var buf bytes.Buffer
	if err := wire.WriteVarInt(&buf, 0, uint64(len(witness))); err != nil {
		return "", err
	}
	for _, item := range witness {
		if err := wire.WriteVarBytes(&buf, 0, item); err != nil {
			return "", err
		}
	}
	return base64.StdEncoding.EncodeToString(buf.Bytes()), nil
}

func decodeWitness(raw []byte) (wire.TxWitness, error) {
	r := bytes.NewReader(raw)

	count, err := wire.ReadVarInt(r, 0)
	if err != nil {
		return nil, err
	}
	if count > uint64(len(raw)) {
		return nil, errors.New("witness item count exceeds signature length")
	}

	witness := make(wire.TxWitness, 0, count)
	for i := uint64(0); i < count; i++ {
		item, err := wire.ReadVarBytes(r, 0, uint32(len(raw)), "witness item")
		if err != nil {
			return nil, err
		}
		witness = append(witness, item)
	}

	if r.Len() != 0 {
		return nil, errors.New("trailing bytes after witness")
	}
	return witness, nil
}
