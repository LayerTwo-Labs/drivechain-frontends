package wallet

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestBuildSendOutputsRawOutputsFirst verifies raw outputs keep their order at
// the front (so consensus-ordered scripts like an OP_DRIVECHAIN treasury and its
// OP_RETURN address stay adjacent and first) and that their value is funded.
func TestBuildSendOutputsRawOutputsFirst(t *testing.T) {
	treasuryHex := hex.EncodeToString([]byte{0xB4, 0x01, 0x01, 0x51})
	req := SendRequest{
		RawOutputs:       []TxOutSpec{{RawScriptHex: treasuryHex, AmountSats: 600_000}},
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
		OpReturnHex:      "deadbeef",
	}

	outs, total := buildSendOutputs(req)

	require.Len(t, outs, 3)
	assert.Equal(t, treasuryHex, outs[0].RawScriptHex, "raw output comes first")
	assert.Equal(t, int64(600_000), outs[0].AmountSats)
	assert.Equal(t, int64(50_000), int64(outs[1].AmountBTC*1e8), "destination follows raw outputs")
	assert.Equal(t, "deadbeef", outs[2].OpReturnHex, "op_return is last")
	assert.Equal(t, int64(650_000), total, "raw output value counts toward funding")
}

// TestOutputToTxOutRawScript verifies a raw-script output is emitted verbatim,
// with no minimal-push rewriting that would corrupt an OP_DRIVECHAIN script.
func TestOutputToTxOutRawScript(t *testing.T) {
	// OP_DRIVECHAIN OP_PUSHBYTES_1 <slot=1> OP_TRUE — slot 1 must NOT collapse to OP_1.
	script := []byte{0xB4, 0x01, 0x01, 0x51}
	out, err := outputToTxOut(
		TxOutSpec{RawScriptHex: hex.EncodeToString(script), AmountSats: 600_000},
		&chaincfg.SigNetParams,
	)
	require.NoError(t, err)
	assert.Equal(t, script, out.PkScript)
	assert.Equal(t, int64(600_000), out.Value)
}

// TestM5TreasuryScriptAllSlots verifies the OP_DRIVECHAIN treasury script is
// emitted byte-for-byte for every slot 0-255, with OP_PUSHBYTES_1 (0x01) intact —
// i.e. low slots (1-16) are NOT collapsed to OP_1..OP_16 by minimal-push encoding,
// which would make the script unparseable as a CTIP.
func TestM5TreasuryScriptAllSlots(t *testing.T) {
	for slot := 0; slot <= 255; slot++ {
		want := []byte{0xB4, 0x01, byte(slot), 0x51}
		out, err := outputToTxOut(
			TxOutSpec{RawScriptHex: hex.EncodeToString(want), AmountSats: 12_345},
			&chaincfg.SigNetParams,
		)
		require.NoErrorf(t, err, "slot %d", slot)
		require.Equalf(t, want, out.PkScript, "slot %d script mismatch", slot)
		assert.Equalf(t, int64(12_345), out.Value, "slot %d value", slot)
	}
}

// TestM5OpReturnAddressRoundtrip verifies the sidechain address survives the
// OP_RETURN encoding intact — mirrors the enforcer's try_parse_op_return_address.
func TestM5OpReturnAddressRoundtrip(t *testing.T) {
	for _, addr := range []string{
		"s1_examplesidechainaddress",
		"thunder1qxyz",
		"a",
	} {
		out, err := outputToTxOut(
			TxOutSpec{OpReturnHex: hex.EncodeToString([]byte(addr))},
			&chaincfg.SigNetParams,
		)
		require.NoError(t, err)
		require.Equal(t, byte(txscript.OP_RETURN), out.PkScript[0])
		assert.Zero(t, out.Value)

		pushed, err := txscript.PushedData(out.PkScript)
		require.NoErrorf(t, err, "addr %q", addr)
		require.Lenf(t, pushed, 1, "addr %q", addr)
		assert.Equalf(t, []byte(addr), pushed[0], "addr %q roundtrip", addr)
	}
}

// TestBuildPSBTExternalInputPrefinalized verifies an external (anyone-can-spend)
// input is added from its previous transaction, pre-finalized with an empty
// scriptSig, and skipped by the signer.
func TestBuildPSBTExternalInputPrefinalized(t *testing.T) {
	net := &chaincfg.SigNetParams

	drivechainScript := []byte{0xB4, 0x01, 0x01, 0x51}
	treasuryPrev := wire.NewMsgTx(2)
	treasuryPrev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	treasuryPrev.AddTxOut(wire.NewTxOut(500_000, drivechainScript))

	inputs := []psbtInput{{
		outpoint: wire.OutPoint{Hash: treasuryPrev.TxHash(), Index: 0},
		amount:   500_000,
		external: true,
	}}
	outputs := []TxOutSpec{{RawScriptHex: hex.EncodeToString(drivechainScript), AmountSats: 500_000}}

	packet, err := buildPSBT(inputs, outputs, net, func(string) (*wire.MsgTx, error) {
		return treasuryPrev, nil
	})
	require.NoError(t, err)

	require.NotNil(t, packet.Inputs[0].FinalScriptSig, "external input is pre-finalized")
	assert.Len(t, packet.Inputs[0].FinalScriptSig, 0, "with an empty scriptSig")
	require.NotNil(t, packet.Inputs[0].NonWitnessUtxo, "external input carries its prev tx")

	signed, err := signPSBT(packet, inputs, net)
	require.NoError(t, err)
	assert.Equal(t, 0, signed, "external input is never signed")
}
