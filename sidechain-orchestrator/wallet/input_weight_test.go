package wallet

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestInputWeightUnits(t *testing.T) {
	const key = "[abcd1234/84h/1h/0h]tpubDCBWBScQPGv4Xk3JSbhw6wYYpayMjb2eAYyArpbSqQTbLDpphHGAetB6VQgVeftLML8vDSUEWcC2xDi3qJJ3YCDChJDvqVzpgoYSuT52MhJ/0/1"

	// Every number below is the largest weight Bitcoin Core assumes for that
	// input: a 72 byte ECDSA signature, or a 65 byte Schnorr signature.
	for _, tc := range []struct {
		name        string
		descriptor  string
		weightUnits int
		vbytes      float64
	}{
		{"legacy", "pkh(" + key + ")#checksum", 592, 148},
		{"segwit", "wpkh(" + key + ")#checksum", 272, 68},
		{"nested segwit", "sh(wpkh(" + key + "))#checksum", 364, 91},
		{"taproot", "tr(" + key + ")#checksum", 231, 57.75},
		{"2 of 3 segwit multisig", "wsh(multi(2," + key + "," + key + "," + key + "))", 418, 104.5},
		{"2 of 3 sorted multisig", "wsh(sortedmulti(2," + key + "," + key + "," + key + "))", 418, 104.5},
	} {
		t.Run(tc.name, func(t *testing.T) {
			got, err := InputWeightUnits(tc.descriptor)
			require.NoError(t, err)
			assert.Equal(t, tc.weightUnits, got)
			assert.InDelta(t, tc.vbytes, float64(got)/4, 0.001)
		})
	}
}

func TestInputWeightUnitsScalesWithTheKeyCount(t *testing.T) {
	const key = "tpubD6NzVbkrYhZ4XgiXtGrdW5XDAPFCL9h7we1vwNCpn8tGbBcgfVYjXyhWo4E1xkh56hjod1RhGjxbaTLV3X4FyWuejifB9jusQ46QzG87VKp/0/*"

	build := func(required, keys int) string {
		desc := "wsh(multi(" + string(rune('0'+required))
		for i := 0; i < keys; i++ {
			desc += "," + key
		}
		return desc + "))"
	}

	twoOfThree, err := InputWeightUnits(build(2, 3))
	require.NoError(t, err)
	twoOfFive, err := InputWeightUnits(build(2, 5))
	require.NoError(t, err)
	threeOfFive, err := InputWeightUnits(build(3, 5))
	require.NoError(t, err)

	// More keys widen the script, and more signatures widen the witness.
	assert.Greater(t, twoOfFive, twoOfThree)
	assert.Greater(t, threeOfFive, twoOfFive)
	assert.Equal(t, twoOfFive+witnessItemBytes(maxECDSASignatureBytes), threeOfFive)
}

func TestInputWeightUnitsRejectsWhatItCannotSize(t *testing.T) {
	for _, descriptor := range []string{
		"",
		"raw(51)",
		"combo(0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798)",
		"wsh(multi(4,key,key))",
		// A script tree may force a script path spend, which costs far more
		// than the key path.
		"tr(NUMS,pk(tpubDCBWBScQPGv4Xk3JSbhw6wYYpayMjb2eAYyArpbSqQTbLDpphHGAetB6VQgVeftLML8vDSUEWcC2xDi3qJJ3YCDChJDvqVzpgoYSuT52MhJ/0/1))",
	} {
		_, err := InputWeightUnits(descriptor)
		assert.Error(t, err, descriptor)
	}
}

// A legacy output may pay an uncompressed key, which is 32 bytes wider. A
// number that reads low builds a transaction above the standard limit.
func TestInputWeightUnitsReadsTheLegacyKeySize(t *testing.T) {
	const compressed = "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"
	const uncompressed = "0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798" +
		"483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8"

	small, err := InputWeightUnits("pkh(" + compressed + ")")
	require.NoError(t, err)
	large, err := InputWeightUnits("pkh([abcd1234/44h/0h/0h/0/5]" + uncompressed + ")")
	require.NoError(t, err)

	assert.Equal(t, 592, small)
	assert.Equal(t, large-small, 4*(uncompressedPubKeyBytes-compressedPubKeyBytes), "32 vbytes wider")

	// A key it cannot read takes the wider size, never the narrower one.
	unknown, err := InputWeightUnits("pkh(5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ)")
	require.NoError(t, err)
	assert.Equal(t, large, unknown, "a WIF this cannot read takes the wider size")

	// A derivation path means an extended key, and BIP32 derives compressed
	// keys only.
	derived, err := InputWeightUnits(
		"pkh([abcd1234/44h/0h/0h]tpubDCBWBScQPGv4Xk3JSbhw6wYYpayMjb2eAYyArpbSqQTbLDpphHGAetB6VQgVeftLML8vDSUEWcC2xDi3qJJ3YCDChJDvqVzpgoYSuT52MhJ/0/1)",
	)
	require.NoError(t, err)
	assert.Equal(t, small, derived)
}

// A backend that reports no descriptor still knows its own script kind, so
// both routes must agree.
func TestInputWeightUnitsForKindMatchesTheDescriptor(t *testing.T) {
	const key = "[abcd1234/84h/1h/0h]tpubDCBWBScQPGv4Xk3JSbhw6wYYpayMjb2eAYyArpbSqQTbLDpphHGAetB6VQgVeftLML8vDSUEWcC2xDi3qJJ3YCDChJDvqVzpgoYSuT52MhJ/0/1"

	for _, tc := range []struct {
		kind       ScriptKind
		descriptor string
	}{
		{ScriptLegacy, "pkh(" + key + ")"},
		{ScriptNativeSegwit, "wpkh(" + key + ")"},
		{ScriptNestedSegwit, "sh(wpkh(" + key + "))"},
		{ScriptTaproot, "tr(" + key + ")"},
	} {
		fromKind, err := InputWeightUnitsForKind(tc.kind)
		require.NoError(t, err)
		fromDescriptor, err := InputWeightUnits(tc.descriptor)
		require.NoError(t, err)
		assert.Equal(t, fromDescriptor, fromKind, tc.descriptor)
	}
}

func TestInputWeightUnitsForKindRejectsMultisig(t *testing.T) {
	// A multisig script's size follows its own m and n, which a kind alone
	// does not carry.
	_, err := InputWeightUnitsForKind(ScriptMultisig)
	assert.Error(t, err)
}

func TestVarIntLen(t *testing.T) {
	assert.Equal(t, 1, varIntLen(0))
	assert.Equal(t, 1, varIntLen(252))
	assert.Equal(t, 3, varIntLen(253))
	assert.Equal(t, 3, varIntLen(0xffff))
	assert.Equal(t, 5, varIntLen(0x10000))
}
