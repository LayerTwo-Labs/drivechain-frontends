package wallet

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

// hexOfLen returns a hex string of exactly n characters.
func hexOfLen(n int) string { return strings.Repeat("a", n) }

// TestCountMultisigSignatures pins the Dart _countSignaturesInTransaction
// heuristic: witness/scriptSig tokens 140..150 hex chars count as signatures;
// shorter (pubkeys, push opcodes) or OP_-prefixed asm tokens do not.
func TestCountMultisigSignatures(t *testing.T) {
	t.Run("witness two sigs", func(t *testing.T) {
		in := RawTxIn{Witness: []string{
			"",            // empty (OP_0 placeholder)
			hexOfLen(142), // sig
			hexOfLen(144), // sig
			hexOfLen(70),  // witnessScript fragment / short, not a sig
		}}
		assert.Equal(t, 2, CountMultisigSignatures([]RawTxIn{in}))
	})

	t.Run("witness boundary 140 and 150 inclusive", func(t *testing.T) {
		in := RawTxIn{Witness: []string{hexOfLen(139), hexOfLen(140), hexOfLen(150), hexOfLen(151)}}
		assert.Equal(t, 2, CountMultisigSignatures([]RawTxIn{in}))
	})

	t.Run("scriptSig asm sigs skip OP_ and short tokens", func(t *testing.T) {
		asm := strings.Join([]string{"OP_0", hexOfLen(144), hexOfLen(146), hexOfLen(66)}, " ")
		in := RawTxIn{ScriptSig: &ScriptSig{Asm: asm}}
		assert.Equal(t, 2, CountMultisigSignatures([]RawTxIn{in}))
	})

	t.Run("scriptSig OP_-prefixed long token does not count", func(t *testing.T) {
		// A 144-char token that starts with OP_ must be excluded.
		asm := "OP_" + hexOfLen(141)
		in := RawTxIn{ScriptSig: &ScriptSig{Asm: asm}}
		assert.Equal(t, 0, CountMultisigSignatures([]RawTxIn{in}))
	})

	t.Run("sums across inputs and both sources", func(t *testing.T) {
		a := RawTxIn{Witness: []string{hexOfLen(142)}}
		b := RawTxIn{ScriptSig: &ScriptSig{Asm: hexOfLen(144)}}
		assert.Equal(t, 2, CountMultisigSignatures([]RawTxIn{a, b}))
	})

	t.Run("no signatures", func(t *testing.T) {
		assert.Equal(t, 0, CountMultisigSignatures([]RawTxIn{{}}))
	})
}
