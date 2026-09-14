package wallet

import (
	"bytes"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
)

func newInputCheckPacket(t *testing.T, script []byte) (*psbt.Packet, *wire.MsgTx) {
	t.Helper()
	previous := wire.NewMsgTx(2)
	previous.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{txscript.OP_0}, nil))
	previous.AddTxOut(wire.NewTxOut(100_000, script))
	transaction := wire.NewMsgTx(2)
	transaction.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: previous.TxHash()}, nil, nil))
	transaction.AddTxOut(wire.NewTxOut(99_000, script))
	packet, err := psbt.NewFromUnsignedTx(transaction)
	require.NoError(t, err)
	return packet, previous
}

func inputCheckScript(t *testing.T, kind string) []byte {
	t.Helper()
	hash := bytes.Repeat([]byte{1}, 20)
	builder := txscript.NewScriptBuilder()
	switch kind {
	case "legacy":
		builder.AddOp(txscript.OP_DUP).AddOp(txscript.OP_HASH160).AddData(hash).AddOp(txscript.OP_EQUALVERIFY).AddOp(txscript.OP_CHECKSIG)
	case "native key":
		builder.AddOp(txscript.OP_0).AddData(hash)
	case "native script":
		builder.AddOp(txscript.OP_0).AddData(bytes.Repeat([]byte{2}, 32))
	case "taproot":
		builder.AddOp(txscript.OP_1).AddData(bytes.Repeat([]byte{3}, 32))
	default:
		t.Fatalf("unknown script kind %q", kind)
	}
	script, err := builder.Script()
	require.NoError(t, err)
	return script
}

func inputCheckBase64(t *testing.T, packet *psbt.Packet) string {
	t.Helper()
	text, err := packet.B64Encode()
	require.NoError(t, err)
	return text
}

func TestCheckPSBTInputsAcceptsPreviousOutputData(t *testing.T) {
	for _, kind := range []string{"legacy", "native key", "native script", "taproot"} {
		t.Run(kind, func(t *testing.T) {
			packet, previous := newInputCheckPacket(t, inputCheckScript(t, kind))
			if kind == "legacy" {
				packet.Inputs[0].NonWitnessUtxo = previous
			} else {
				packet.Inputs[0].WitnessUtxo = previous.TxOut[0]
			}
			require.NoError(t, CheckPSBTInputs(inputCheckBase64(t, packet)))
		})
	}
	t.Run("full and witness data agree", func(t *testing.T) {
		packet, previous := newInputCheckPacket(t, inputCheckScript(t, "native key"))
		packet.Inputs[0].NonWitnessUtxo = previous
		packet.Inputs[0].WitnessUtxo = previous.TxOut[0]
		require.NoError(t, CheckPSBTInputs(inputCheckBase64(t, packet)))
	})
}

func TestCheckPSBTInputsChecksNestedSegWit(t *testing.T) {
	for _, kind := range []string{"native key", "native script"} {
		t.Run(kind, func(t *testing.T) {
			redeem := inputCheckScript(t, kind)
			script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_HASH160).AddData(btcutil.Hash160(redeem)).AddOp(txscript.OP_EQUAL).Script()
			require.NoError(t, err)
			for _, state := range []string{"match", "different hash", "absent", "legacy"} {
				t.Run(state, func(t *testing.T) {
					packet, previous := newInputCheckPacket(t, script)
					packet.Inputs[0].WitnessUtxo = previous.TxOut[0]
					packet.Inputs[0].RedeemScript = bytes.Clone(redeem)
					switch state {
					case "match":
						require.NoError(t, CheckPSBTInputs(inputCheckBase64(t, packet)))
						return
					case "different hash":
						packet.Inputs[0].RedeemScript[len(redeem)-1] ^= 1
					case "absent":
						packet.Inputs[0].RedeemScript = nil
					case "legacy":
						packet.Inputs[0].RedeemScript = inputCheckScript(t, "legacy")
					}
					require.ErrorContains(t, CheckPSBTInputs(inputCheckBase64(t, packet)), "PSBT input 0")
				})
			}
		})
	}
}

func TestCheckPSBTInputsRejectsPreviousOutputErrors(t *testing.T) {
	for _, test := range []struct {
		name string
		edit func(*psbt.Packet, *wire.MsgTx)
		text string
	}{
		{
			name: "transaction hash",
			edit: func(packet *psbt.Packet, previous *wire.MsgTx) {
				packet.UnsignedTx.TxIn[0].PreviousOutPoint.Hash[0] ^= 1
			},
			text: "previous transaction that is not the one it spends",
		},
		{
			name: "output index",
			edit: func(packet *psbt.Packet, previous *wire.MsgTx) {
				packet.UnsignedTx.TxIn[0].PreviousOutPoint.Index = 1
			},
			text: "no output at that index",
		},
		{
			name: "witness amount",
			edit: func(packet *psbt.Packet, previous *wire.MsgTx) {
				packet.Inputs[0].WitnessUtxo = wire.NewTxOut(previous.TxOut[0].Value+1, previous.TxOut[0].PkScript)
			},
			text: "disagrees with its previous transaction",
		},
		{
			name: "witness script",
			edit: func(packet *psbt.Packet, previous *wire.MsgTx) {
				packet.Inputs[0].WitnessUtxo = wire.NewTxOut(previous.TxOut[0].Value, inputCheckScript(t, "native key"))
			},
			text: "disagrees with its previous transaction",
		},
		{
			name: "legacy without full transaction",
			edit: func(packet *psbt.Packet, previous *wire.MsgTx) {
				packet.Inputs[0].NonWitnessUtxo = nil
				packet.Inputs[0].WitnessUtxo = previous.TxOut[0]
			},
			text: "no full previous transaction for its legacy script",
		},
		{
			name: "no previous output",
			edit: func(packet *psbt.Packet, previous *wire.MsgTx) {
				packet.Inputs[0].NonWitnessUtxo = nil
			},
			text: "no previous-output data",
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			packet, previous := newInputCheckPacket(t, inputCheckScript(t, "legacy"))
			packet.Inputs[0].NonWitnessUtxo = previous
			test.edit(packet, previous)
			require.ErrorContains(t, CheckPSBTInputs(inputCheckBase64(t, packet)), test.text)
		})
	}
}

func TestCheckPSBTInputsChecksEachInput(t *testing.T) {
	packet, previous := newInputCheckPacket(t, inputCheckScript(t, "native key"))
	packet.Inputs[0].WitnessUtxo = previous.TxOut[0]
	packet.UnsignedTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 1}, nil, nil))
	packet.Inputs = append(packet.Inputs, psbt.PInput{})
	require.ErrorContains(t, CheckPSBTInputs(inputCheckBase64(t, packet)), "PSBT input 1 has no previous-output data")
}

func TestCheckPSBTInputsRejectsInvalidBase64(t *testing.T) {
	require.ErrorContains(t, CheckPSBTInputs("invalid"), "decode psbt")
}
