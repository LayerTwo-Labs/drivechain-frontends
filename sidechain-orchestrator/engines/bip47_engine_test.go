package engines

import (
	"bytes"
	"encoding/hex"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestParseOpReturnPayload_PushData1(t *testing.T) {
	// OP_RETURN OP_PUSHDATA1 0x50 <80 bytes of 0xAA>
	body := bytes.Repeat([]byte{0xAA}, 80)
	script := append([]byte{0x6a, 0x4c, 0x50}, body...)
	got, err := parseOpReturnPayload(script)
	require.NoError(t, err)
	require.Equal(t, body, got)
}

func TestParseOpReturnPayload_DirectPush(t *testing.T) {
	// OP_RETURN <0x05> <5 bytes> — payload < 76 bytes uses a direct push.
	body := []byte{1, 2, 3, 4, 5}
	script := append([]byte{0x6a, 0x05}, body...)
	got, err := parseOpReturnPayload(script)
	require.NoError(t, err)
	require.Equal(t, body, got)
}

func TestParseOpReturnPayload_RejectsNonOpReturn(t *testing.T) {
	_, err := parseOpReturnPayload([]byte{0x76, 0xa9})
	require.Error(t, err)
}

func TestParseOpReturnPayload_RejectsTruncated(t *testing.T) {
	_, err := parseOpReturnPayload([]byte{0x6a, 0x4c, 0x50, 0xAA}) // claims 80, has 1
	require.Error(t, err)
}

func TestPushedDataItems_TwoPushes(t *testing.T) {
	// P2PKH scriptSig: <sig 71 bytes> <pubkey 33 bytes>.
	sig := bytes.Repeat([]byte{0x01}, 71)
	pub := bytes.Repeat([]byte{0x02}, 33)
	var script []byte
	script = append(script, 0x47) // push 71
	script = append(script, sig...)
	script = append(script, 0x21) // push 33
	script = append(script, pub...)

	pushes, err := pushedDataItems(script)
	require.NoError(t, err)
	require.Len(t, pushes, 2)
	require.Equal(t, sig, pushes[0])
	require.Equal(t, pub, pushes[1])
}

func TestExtractInputPubKey_P2WPKH(t *testing.T) {
	// Witness stack [sig, pubkey] — return the second element parsed as pubkey.
	const pubHex = "0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683"
	witness := []string{"3045...sig", pubHex}
	pk, err := extractInputPubKey(witness, nil)
	require.NoError(t, err)
	require.Equal(t, pubHex, hex.EncodeToString(pk.SerializeCompressed()))
}

// TestExtractInputPubKey_RejectsEmptyInput proves the helper signals "no
// pubkey recoverable" so the designated-input loop in decodeNotificationTx
// can `continue` past P2SH/multisig inputs and try the next one.
func TestExtractInputPubKey_RejectsEmptyInput(t *testing.T) {
	_, err := extractInputPubKey(nil, nil)
	require.Error(t, err)
}

// Witness with a single element (e.g. a sweep with just a signature, no
// pubkey on the stack) is not a recoverable P2WPKH; the loop must skip it.
func TestExtractInputPubKey_RejectsSingleWitnessElement(t *testing.T) {
	_, err := extractInputPubKey([]string{"3045...sig"}, nil)
	require.Error(t, err)
}

func TestExtractInputPubKey_P2PKH(t *testing.T) {
	const pubHex = "0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683"
	pub, err := hex.DecodeString(pubHex)
	require.NoError(t, err)
	sig := bytes.Repeat([]byte{0x01}, 71)
	var script []byte
	script = append(script, 0x47)
	script = append(script, sig...)
	script = append(script, 0x21)
	script = append(script, pub...)

	scriptSig := &struct {
		Asm string `json:"asm"`
		Hex string `json:"hex"`
	}{Hex: hex.EncodeToString(script)}

	pk, err := extractInputPubKey(nil, scriptSig)
	require.NoError(t, err)
	require.Equal(t, pubHex, hex.EncodeToString(pk.SerializeCompressed()))
}
