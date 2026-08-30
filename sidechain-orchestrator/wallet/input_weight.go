package wallet

import (
	"fmt"
	"strconv"
	"strings"
)

// The largest signature Bitcoin Core assumes when it sizes an input it has not
// signed yet: 72 bytes for ECDSA (a 71 byte DER signature and the sighash
// byte) and 65 for Schnorr (64 bytes and a non-default sighash byte).
const (
	maxECDSASignatureBytes   = 72
	maxSchnorrSignatureBytes = 65
	compressedPubKeyBytes    = 33
	uncompressedPubKeyBytes  = 65
	witnessProgramV0Bytes    = 34 // OP_0 <32 byte script hash>
	witnessProgramKeyBytes   = 22 // OP_0 <20 byte key hash>
)

// varIntLen is the byte count of a Bitcoin compact size integer.
func varIntLen(value int) int {
	switch {
	case value < 0xfd:
		return 1
	case value <= 0xffff:
		return 3
	case value <= 0xffffffff:
		return 5
	default:
		return 9
	}
}

// inputWeight combines the non-witness bytes and the witness bytes of one
// input into weight units. Only the non-witness part carries the four times
// discount.
func inputWeight(scriptSigBytes, witnessBytes int) int {
	const outpointAndSequenceBytes = 32 + 4 + 4
	base := outpointAndSequenceBytes + varIntLen(scriptSigBytes) + scriptSigBytes
	return (base * 4) + witnessBytes
}

// pushBytes is the byte count of a script push of size bytes, the opcode
// included.
func pushBytes(size int) int {
	switch {
	case size <= 75:
		return 1 + size
	case size <= 255:
		return 2 + size
	default:
		return 3 + size
	}
}

// witnessItemBytes is the byte count of one witness stack item, its compact
// size length prefix included.
func witnessItemBytes(size int) int {
	return varIntLen(size) + size
}

// bareMultisigScriptBytes is the byte count of an m-of-n OP_CHECKMULTISIG
// script that holds compressed keys.
func bareMultisigScriptBytes(keys int) int {
	// OP_m, one push per key, OP_n, OP_CHECKMULTISIG.
	return 1 + (keys * (1 + compressedPubKeyBytes)) + 1 + 1
}

// multisigWitnessBytes is the witness of an m-of-n P2WSH spend: the empty item
// OP_CHECKMULTISIG pops, one signature per required key, and the script.
func multisigWitnessBytes(required, keys int) int {
	script := bareMultisigScriptBytes(keys)
	items := 1 + required + 1 // the empty item, the signatures, and the script

	total := varIntLen(items)
	total += witnessItemBytes(0)
	total += required * witnessItemBytes(maxECDSASignatureBytes)
	total += witnessItemBytes(script)
	return total
}

// singleSigWitnessBytes is the witness of a P2WPKH spend.
func singleSigWitnessBytes() int {
	return varIntLen(2) + witnessItemBytes(maxECDSASignatureBytes) + witnessItemBytes(compressedPubKeyBytes)
}

// taprootKeyPathWitnessBytes is the witness of a taproot key path spend.
func taprootKeyPathWitnessBytes() int {
	return varIntLen(1) + witnessItemBytes(maxSchnorrSignatureBytes)
}

// InputWeightUnitsForKind returns the largest weight one input of this script
// kind costs. A backend that knows its own kind, but reports no descriptor,
// sizes its coins with this.
func InputWeightUnitsForKind(kind ScriptKind) (int, error) {
	switch kind {
	case ScriptLegacy:
		scriptSig := pushBytes(maxECDSASignatureBytes) + pushBytes(compressedPubKeyBytes)
		return inputWeight(scriptSig, 0), nil
	case ScriptNativeSegwit:
		return inputWeight(0, singleSigWitnessBytes()), nil
	case ScriptNestedSegwit:
		return inputWeight(pushBytes(witnessProgramKeyBytes), singleSigWitnessBytes()), nil
	case ScriptTaproot:
		return inputWeight(0, taprootKeyPathWitnessBytes()), nil
	default:
		return 0, fmt.Errorf("cannot size input for script kind %v", kind)
	}
}

// InputWeightUnits returns the largest weight one input costs, for the output
// the descriptor describes. Bitcoin Core reports that descriptor on every
// listunspent entry, so the size comes from the real script, not from a guess
// about the address.
//
// It reports an error for a script kind it cannot size.
func InputWeightUnits(descriptor string) (int, error) {
	desc := strings.TrimSpace(descriptor)
	if desc == "" {
		return 0, fmt.Errorf("empty descriptor")
	}
	// Drop the checksum Core appends.
	if hash := strings.IndexByte(desc, '#'); hash >= 0 {
		desc = desc[:hash]
	}

	switch {
	case strings.HasPrefix(desc, "pkh("):
		// A legacy output may pay an uncompressed key, which is 32 bytes wider
		// than a compressed one. Segwit forbids that, so only this branch asks.
		scriptSig := pushBytes(maxECDSASignatureBytes) + pushBytes(legacyPubKeyBytes(desc))
		return inputWeight(scriptSig, 0), nil

	case strings.HasPrefix(desc, "wpkh("):
		return inputWeight(0, singleSigWitnessBytes()), nil

	case strings.HasPrefix(desc, "tr("):
		// tr(key) spends through the key path. tr(key,{tree}) may have to spend
		// through a script, which costs far more, and the tree sets how much.
		// Report nothing rather than a number that reads low.
		args, err := splitDescriptorArgs(desc[len("tr("):])
		if err != nil {
			return 0, err
		}
		if len(args) > 1 {
			return 0, fmt.Errorf("cannot size a taproot script path spend: %q", descriptor)
		}
		return inputWeight(0, taprootKeyPathWitnessBytes()), nil

	case strings.HasPrefix(desc, "sh(wpkh("):
		return inputWeight(pushBytes(witnessProgramKeyBytes), singleSigWitnessBytes()), nil

	case strings.HasPrefix(desc, "sh(wsh("):
		required, keys, err := parseMultisigThreshold(desc)
		if err != nil {
			return 0, err
		}
		return inputWeight(pushBytes(witnessProgramV0Bytes), multisigWitnessBytes(required, keys)), nil

	case strings.HasPrefix(desc, "wsh("):
		required, keys, err := parseMultisigThreshold(desc)
		if err != nil {
			return 0, err
		}
		return inputWeight(0, multisigWitnessBytes(required, keys)), nil

	case strings.HasPrefix(desc, "sh("):
		required, keys, err := parseMultisigThreshold(desc)
		if err != nil {
			return 0, err
		}
		redeem := bareMultisigScriptBytes(keys)
		// OP_0 for the bug in OP_CHECKMULTISIG, the signatures, the script.
		scriptSig := 1 + (required * pushBytes(maxECDSASignatureBytes)) + pushBytes(redeem)
		return inputWeight(scriptSig, 0), nil
	}

	return 0, fmt.Errorf("cannot size input for descriptor %q", descriptor)
}

// legacyPubKeyBytes reads the public key size out of a pkh() descriptor.
//
// Core reports the concrete key on every listunspent entry, so the size is a
// read, not a guess. A key it cannot read takes the uncompressed size, because
// a number that reads low builds a transaction above the standard limit.
func legacyPubKeyBytes(desc string) int {
	args, err := splitDescriptorArgs(desc[len("pkh("):])
	if err != nil || len(args) != 1 {
		return uncompressedPubKeyBytes
	}

	key := strings.TrimSpace(args[0])
	// Drop the [fingerprint/path] origin, when the descriptor carries one.
	if close := strings.IndexByte(key, ']'); close >= 0 {
		key = key[close+1:]
	}

	// A derivation path means an extended key, and BIP32 derives compressed
	// keys only.
	if strings.ContainsRune(key, '/') {
		return compressedPubKeyBytes
	}

	switch {
	case isHex(key) && len(key) == compressedPubKeyBytes*2:
		return compressedPubKeyBytes
	case isHex(key) && len(key) == uncompressedPubKeyBytes*2:
		return uncompressedPubKeyBytes
	default:
		return uncompressedPubKeyBytes
	}
}

func isHex(s string) bool {
	if s == "" {
		return false
	}
	for i := 0; i < len(s); i++ {
		c := s[i]
		isDigit := c >= '0' && c <= '9'
		isLower := c >= 'a' && c <= 'f'
		isUpper := c >= 'A' && c <= 'F'
		if !isDigit && !isLower && !isUpper {
			return false
		}
	}
	return true
}

// parseMultisig reads the required key count and the total key count out of a
// multi() or sortedmulti() expression.
func parseMultisigThreshold(desc string) (required, keys int, err error) {
	open := strings.Index(desc, "multi(")
	if open < 0 {
		return 0, 0, fmt.Errorf("descriptor %q holds no multi() expression", desc)
	}

	args, err := splitDescriptorArgs(desc[open+len("multi("):])
	if err != nil {
		return 0, 0, err
	}
	if len(args) < 2 {
		return 0, 0, fmt.Errorf("multi() in %q takes a threshold and at least one key", desc)
	}

	required, err = strconv.Atoi(strings.TrimSpace(args[0]))
	if err != nil {
		return 0, 0, fmt.Errorf("multi() threshold in %q: %w", desc, err)
	}
	keys = len(args) - 1
	if required < 1 || required > keys {
		return 0, 0, fmt.Errorf("multi() in %q needs %d of %d keys", desc, required, keys)
	}
	return required, keys, nil
}

// splitDescriptorArgs splits the argument list that starts at the beginning of s and
// ends at its unmatched closing bracket. Brackets inside a key origin or a
// nested function do not split.
func splitDescriptorArgs(s string) ([]string, error) {
	var (
		args  []string
		start int
		depth int
	)
	for i := 0; i < len(s); i++ {
		switch s[i] {
		case '(', '[':
			depth++
		case ']':
			depth--
		case ')':
			if depth == 0 {
				return append(args, s[start:i]), nil
			}
			depth--
		case ',':
			if depth == 0 {
				args = append(args, s[start:i])
				start = i + 1
			}
		}
	}
	return nil, fmt.Errorf("descriptor argument list %q never closes", s)
}
