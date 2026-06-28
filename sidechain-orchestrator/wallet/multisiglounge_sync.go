package wallet

import "strings"

// CountMultisigSignatures counts signatures across a transaction's inputs,
// replicating the BitWindow Dart _countSignaturesInTransaction heuristic EXACTLY
// (it is used to reconstruct historical multisig state, so any divergence would
// change the displayed signed/unsigned status):
//
//   - scriptSig: split asm on spaces, count tokens that are 140..150 hex chars
//     and do not start with "OP_".
//   - witness: count txinwitness items that are 140..150 chars.
//
// This is a heuristic, not exact DER parsing (real signatures are ~70-72 bytes /
// 140-144 hex chars; the 140-150 window is the Dart range, kept for parity).
func CountMultisigSignatures(inputs []RawTxIn) int {
	total := 0
	for _, in := range inputs {
		if in.ScriptSig != nil {
			for _, part := range strings.Split(in.ScriptSig.Asm, " ") {
				if len(part) >= 140 && len(part) <= 150 && !strings.HasPrefix(part, "OP_") {
					total++
				}
			}
		}
		for _, w := range in.Witness {
			if len(w) >= 140 && len(w) <= 150 {
				total++
			}
		}
	}
	return total
}
