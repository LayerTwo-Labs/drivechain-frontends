package wallet

import (
	"bytes"
	"encoding/hex"
	"fmt"
	"math"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// bip125Sequence marks inputs BIP125-replaceable, matching Core's
// createrawtransaction default (replaceable=true).
const bip125Sequence = wire.MaxTxInSequenceNum - 2

// TxOutSpec is one output of an unsigned transaction under construction:
// a pay-to-address amount, or an OP_RETURN payload when OpReturnHex is set.
type TxOutSpec struct {
	Address     string
	AmountBTC   float64
	OpReturnHex string
	// Set for an owned change output so the PSBT carries its derivation records.
	Kind        ScriptKind
	Derivations []keyDerivation
}

// BuildUnsignedTransaction assembles a raw unsigned transaction in-process,
// for backends with no node to delegate to (electrum) — CoreBackend uses
// createrawtransaction instead. Matches Core's defaults: version 2,
// locktime 0, BIP125 sequence. Outputs keep their given order.
func BuildUnsignedTransaction(inputs []RawInput, outputs []TxOutSpec, net *chaincfg.Params) (string, error) {
	tx := wire.NewMsgTx(2)

	for _, in := range inputs {
		prevHash, err := chainhash.NewHashFromStr(in.TxID)
		if err != nil {
			return "", fmt.Errorf("parse input txid %q: %w", in.TxID, err)
		}
		txIn := wire.NewTxIn(wire.NewOutPoint(prevHash, uint32(in.Vout)), nil, nil)
		txIn.Sequence = bip125Sequence
		tx.AddTxIn(txIn)
	}

	for _, out := range outputs {
		if out.OpReturnHex != "" {
			data, err := hex.DecodeString(out.OpReturnHex)
			if err != nil {
				return "", fmt.Errorf("decode op_return hex: %w", err)
			}
			script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData(data).Script()
			if err != nil {
				return "", fmt.Errorf("build op_return script: %w", err)
			}
			tx.AddTxOut(wire.NewTxOut(0, script))
			continue
		}

		addr, err := btcutil.DecodeAddress(out.Address, net)
		if err != nil {
			return "", fmt.Errorf("decode address %q: %w", out.Address, err)
		}
		script, err := txscript.PayToAddrScript(addr)
		if err != nil {
			return "", fmt.Errorf("script for %q: %w", out.Address, err)
		}
		tx.AddTxOut(wire.NewTxOut(int64(math.Round(out.AmountBTC*1e8)), script))
	}

	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		return "", fmt.Errorf("serialize: %w", err)
	}
	return hex.EncodeToString(buf.Bytes()), nil
}
