package wallet

import (
	"bytes"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"strings"

	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// DecodedForm is the kind of artifact DecodeTransaction recognized.
type DecodedForm int

const (
	DecodedFormUnknown DecodedForm = iota
	DecodedFormTxid                // a 64-hex-char transaction id, to be looked up
	DecodedFormRawTx               // a serialized raw transaction
	DecodedFormPSBT                // a base64 (or raw) PSBT
)

// DecodedInput is one input of a decoded transaction. Address and ValueSats are
// only set when resolvable (PSBT UTXO fields, or a wallet/chain lookup); Signed
// reports whether a PSBT input already carries a finalized or partial signature.
type DecodedInput struct {
	Index      int
	PrevTxID   string
	PrevVout   int
	Address    string
	ValueSats  int64
	HasValue   bool
	ScriptSig  string
	Witness    []string
	Sequence   int64
	IsCoinbase bool
	Signed     bool
}

// DecodedOutput is one output of a decoded transaction.
type DecodedOutput struct {
	Index           int
	ValueSats       int64
	Address         string
	ScriptType      string
	ScriptPubKeyHex string
}

// DecodedTransaction is the structured result of decoding a raw transaction or
// PSBT locally. FeeSats/HasFee are only set when every input value is known.
type DecodedTransaction struct {
	Form           DecodedForm
	TxID           string
	Version        int32
	Locktime       int32
	SizeBytes      int32
	VsizeVBytes    int32
	WeightWU       int32
	Inputs         []DecodedInput
	Outputs        []DecodedOutput
	TotalInputSats int64
	HasTotalInput  bool
	TotalOutput    int64
	FeeSats        int64
	HasFee         bool
	FeeRateSatVB   float64
	IsPSBT         bool
	SignedInputs   int
	RawHex         string
}

// ErrUnrecognizedTransaction is returned when input is neither a txid, a raw
// transaction, nor a PSBT.
var ErrUnrecognizedTransaction = errors.New("not a valid txid, transaction hex, or PSBT")

// LooksLikeTxid reports whether s is a bare 64-hex-char transaction id (no
// transaction structure), which must be looked up rather than decoded locally.
func LooksLikeTxid(s string) bool {
	s = strings.TrimSpace(s)
	if len(s) != 64 {
		return false
	}
	_, err := hex.DecodeString(s)
	return err == nil
}

// DecodeTransaction decodes a raw transaction or PSBT in input (auto-detecting
// the form) into a structured view. A bare txid returns DecodedFormTxid with no
// body — the caller looks it up. PSBT is tried before raw tx because a PSBT's
// magic prefix would otherwise mis-parse as a (truncated) transaction.
func DecodeTransaction(input string, net *chaincfg.Params) (*DecodedTransaction, error) {
	input = strings.TrimSpace(input)
	if input == "" {
		return nil, ErrUnrecognizedTransaction
	}

	if LooksLikeTxid(input) {
		return &DecodedTransaction{Form: DecodedFormTxid, TxID: strings.ToLower(input)}, nil
	}

	if packet, err := parsePSBT(input); err == nil {
		return decodePSBT(packet, net)
	}

	raw, err := hex.DecodeString(input)
	if err != nil {
		return nil, ErrUnrecognizedTransaction
	}
	tx := wire.NewMsgTx(wire.TxVersion)
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, ErrUnrecognizedTransaction
	}
	return decodeMsgTx(tx, net), nil
}

func parsePSBT(input string) (*psbt.Packet, error) {
	if p, err := psbt.NewFromRawBytes(strings.NewReader(input), true); err == nil {
		return p, nil
	}
	raw, err := base64.StdEncoding.DecodeString(input)
	if err != nil {
		return nil, err
	}
	return psbt.NewFromRawBytes(bytes.NewReader(raw), false)
}

func decodeMsgTx(tx *wire.MsgTx, net *chaincfg.Params) *DecodedTransaction {
	out := &DecodedTransaction{
		Form:        DecodedFormRawTx,
		TxID:        tx.TxHash().String(),
		Version:     tx.Version,
		Locktime:    int32(tx.LockTime),
		SizeBytes:   int32(tx.SerializeSize()),
		VsizeVBytes: int32(msgTxVsize(tx)),
		WeightWU:    int32(weightVsize(tx)),
	}

	var rawBuf bytes.Buffer
	if err := tx.Serialize(&rawBuf); err == nil {
		out.RawHex = hex.EncodeToString(rawBuf.Bytes())
	}

	for i, in := range tx.TxIn {
		di := DecodedInput{
			Index:      i,
			PrevTxID:   in.PreviousOutPoint.Hash.String(),
			PrevVout:   int(in.PreviousOutPoint.Index),
			Sequence:   int64(in.Sequence),
			ScriptSig:  hex.EncodeToString(in.SignatureScript),
			IsCoinbase: isCoinbaseOutpoint(in.PreviousOutPoint),
			Signed:     len(in.SignatureScript) > 0 || len(in.Witness) > 0,
		}
		for _, w := range in.Witness {
			di.Witness = append(di.Witness, hex.EncodeToString(w))
		}
		out.Inputs = append(out.Inputs, di)
	}

	for i, txOut := range tx.TxOut {
		do := decodeTxOut(i, txOut, net)
		out.TotalOutput += txOut.Value
		out.Outputs = append(out.Outputs, do)
	}
	return out
}

func decodePSBT(packet *psbt.Packet, net *chaincfg.Params) (*DecodedTransaction, error) {
	tx := packet.UnsignedTx
	if tx == nil {
		return nil, ErrUnrecognizedTransaction
	}

	out := &DecodedTransaction{
		Form:        DecodedFormPSBT,
		IsPSBT:      true,
		TxID:        tx.TxHash().String(),
		Version:     tx.Version,
		Locktime:    int32(tx.LockTime),
		SizeBytes:   int32(tx.SerializeSize()),
		VsizeVBytes: int32(msgTxVsize(tx)),
		WeightWU:    int32(weightVsize(tx)),
	}

	var rawBuf bytes.Buffer
	if err := packet.Serialize(&rawBuf); err == nil {
		out.RawHex = base64.StdEncoding.EncodeToString(rawBuf.Bytes())
	}

	allValuesKnown := true
	for i, in := range tx.TxIn {
		di := DecodedInput{
			Index:      i,
			PrevTxID:   in.PreviousOutPoint.Hash.String(),
			PrevVout:   int(in.PreviousOutPoint.Index),
			Sequence:   int64(in.Sequence),
			IsCoinbase: isCoinbaseOutpoint(in.PreviousOutPoint),
		}
		pin := packet.Inputs[i]
		di.Signed = len(pin.FinalScriptSig) > 0 || len(pin.FinalScriptWitness) > 0 ||
			len(pin.PartialSigs) > 0 || len(pin.TaprootKeySpendSig) > 0
		if di.Signed {
			out.SignedInputs++
		}

		if prevOut := psbtInputPrevOut(packet, i); prevOut != nil {
			di.ValueSats = prevOut.Value
			di.HasValue = true
			di.Address = scriptAddress(prevOut.PkScript, net)
			out.TotalInputSats += prevOut.Value
		} else {
			allValuesKnown = false
		}
		out.Inputs = append(out.Inputs, di)
	}
	out.HasTotalInput = allValuesKnown && len(tx.TxIn) > 0

	for i, txOut := range tx.TxOut {
		out.TotalOutput += txOut.Value
		out.Outputs = append(out.Outputs, decodeTxOut(i, txOut, net))
	}

	if out.HasTotalInput {
		fee := out.TotalInputSats - out.TotalOutput
		if fee >= 0 {
			out.FeeSats = fee
			out.HasFee = true
			if out.VsizeVBytes > 0 {
				out.FeeRateSatVB = float64(fee) / float64(out.VsizeVBytes)
			}
		}
	}
	return out, nil
}

func decodeTxOut(i int, txOut *wire.TxOut, net *chaincfg.Params) DecodedOutput {
	class, addrs, _, _ := txscript.ExtractPkScriptAddrs(txOut.PkScript, net)
	do := DecodedOutput{
		Index:           i,
		ValueSats:       txOut.Value,
		ScriptType:      class.String(),
		ScriptPubKeyHex: hex.EncodeToString(txOut.PkScript),
	}
	if len(addrs) > 0 {
		do.Address = addrs[0].EncodeAddress()
	}
	return do
}

func scriptAddress(pkScript []byte, net *chaincfg.Params) string {
	_, addrs, _, err := txscript.ExtractPkScriptAddrs(pkScript, net)
	if err != nil || len(addrs) == 0 {
		return ""
	}
	return addrs[0].EncodeAddress()
}

func psbtInputPrevOut(packet *psbt.Packet, i int) *wire.TxOut {
	in := packet.Inputs[i]
	if in.WitnessUtxo != nil {
		return in.WitnessUtxo
	}
	if in.NonWitnessUtxo != nil {
		vout := packet.UnsignedTx.TxIn[i].PreviousOutPoint.Index
		if int(vout) < len(in.NonWitnessUtxo.TxOut) {
			return in.NonWitnessUtxo.TxOut[int(vout)]
		}
	}
	return nil
}

func isCoinbaseOutpoint(op wire.OutPoint) bool {
	return op.Index == 0xffffffff && op.Hash == zeroHash
}

var zeroHash = func() (h [32]byte) { return }()

// msgTxVsize is the transaction's virtual size (weight units / 4, rounded up).
func msgTxVsize(tx *wire.MsgTx) int {
	return (weightVsize(tx) + 3) / 4
}

func weightVsize(tx *wire.MsgTx) int {
	base := tx.SerializeSizeStripped()
	total := tx.SerializeSize()
	return base*3 + total
}
