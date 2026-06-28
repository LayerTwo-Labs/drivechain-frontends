package wallet

import (
	"encoding/base64"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func strptr(s string) *string { return &s }

func sampleGroupData() MultisigGroupData {
	return MultisigGroupData{
		ID:   "abc123",
		Name: "Test Group",
		N:    2,
		M:    2,
		Keys: []MultisigGroupKey{
			{
				Owner:          "Alice",
				Xpub:           "tpubDFH9dgzveyD8zTbPUFuLrGmCydNvxehyNdUXKJAQN8x4aZ4j6UZqGfnqFrD4NqyaTVGKbvEW54tsvPTK2UoSbCC1PJY8iCNiwTL3RWZEheQ",
				DerivationPath: "m/48'/1'/0'/2'",
				Fingerprint:    strptr("73c5da0a"),
				OriginPath:     strptr("48'/1'/0'/2'"),
				IsWallet:       true,
			},
			{
				Owner:          "Bob",
				Xpub:           "tpubDFH9dgzveyD94P86sEzUzWtd2wxFkUoK78rSBqSWyXNuFq46dy4HbPTEZEP4fbSY4L5Vb2LFnm23JeGQppq5SPcPDNuHZU3JQwMSFXLdudh",
				DerivationPath: "m/48'/1'/0'/3'",
				Fingerprint:    nil,
				OriginPath:     nil,
				IsWallet:       false,
			},
		},
		Created:           1719500000000,
		DescriptorReceive: "wsh(sortedmulti(2,...))#aaaaaaaa",
		DescriptorChange:  "wsh(sortedmulti(2,...))#bbbbbbbb",
		WatchWalletName:   "multisig_abc123",
	}
}

func TestGroupOpReturnRoundTrip(t *testing.T) {
	in := sampleGroupData()
	msg, err := EncodeGroupOpReturn(in, 1719500000)
	require.NoError(t, err)

	out, err := DecodeGroupOpReturn(msg)
	require.NoError(t, err)
	assert.Equal(t, in, out)
}

// TestEncodeMetadataBytes pins the 9-byte metadata envelope: flag 0x02, a
// big-endian uint32 timestamp, and the 4-byte "json" filetype.
func TestEncodeMetadataBytes(t *testing.T) {
	msg, err := EncodeGroupOpReturn(sampleGroupData(), 1719500000)
	require.NoError(t, err)

	metaB64 := msg[:strIndex(msg, '|')]
	meta, err := base64.StdEncoding.DecodeString(metaB64)
	require.NoError(t, err)
	require.Len(t, meta, 9)
	assert.Equal(t, byte(0x02), meta[0])
	assert.Equal(t, []byte{0x66, 0x7d, 0x7c, 0xe0}, meta[1:5]) // 1719500000 big-endian
	assert.Equal(t, "json", string(meta[5:9]))
}

// TestDecodeCapturedDartPayload decodes a payload constructed exactly as the
// BitWindow Dart _broadcastMultisigGroup produces it (big-endian ts, 9-byte
// metadata, base64(meta)|base64(utf8(json)) with Dart's compact key order and
// explicit nulls). This is the load-bearing parity check: existing on-chain
// groups must still import.
func TestDecodeCapturedDartPayload(t *testing.T) {
	const captured = "AmZ9fOBqc29u|eyJpZCI6ImFiYzEyMyIsIm5hbWUiOiJUZXN0IEdyb3VwIiwibiI6MiwibSI6Miwia2V5cyI6W3sib3duZXIiOiJBbGljZSIsInhwdWIiOiJ0cHViREZIOWRnenZleUQ4elRiUFVGdUxyR21DeWROdnhlaHlOZFVYS0pBUU44eDRhWjRqNlVacUdmbnFGckQ0TnF5YVRWR0tidkVXNTR0c3ZQVEsyVW9TYkNDMVBKWThpQ05pd1RMM1JXWkVoZVEiLCJwYXRoIjoibS80OCcvMScvMCcvMiciLCJmaW5nZXJwcmludCI6IjczYzVkYTBhIiwib3JpZ2luX3BhdGgiOiI0OCcvMScvMCcvMiciLCJpc193YWxsZXQiOnRydWV9LHsib3duZXIiOiJCb2IiLCJ4cHViIjoidHB1YkRGSDlkZ3p2ZXlEOTRQODZzRXpVeld0ZDJ3eEZrVW9LNzhyU0JxU1d5WE51RnE0NmR5NEhiUFRFWkVQNGZiU1k0TDVWYjJMRm5tMjNKZUdRcHBxNVNQY1BETnVIWlUzSlF3TVNGWExkdWRoIiwicGF0aCI6Im0vNDgnLzEnLzAnLzMnIiwiZmluZ2VycHJpbnQiOm51bGwsIm9yaWdpbl9wYXRoIjpudWxsLCJpc193YWxsZXQiOmZhbHNlfV0sImNyZWF0ZWQiOjE3MTk1MDAwMDAwMDAsImRlc2NyaXB0b3JSZWNlaXZlIjoid3NoKHNvcnRlZG11bHRpKDIsLi4uKSkjYWFhYWFhYWEiLCJkZXNjcmlwdG9yQ2hhbmdlIjoid3NoKHNvcnRlZG11bHRpKDIsLi4uKSkjYmJiYmJiYmIiLCJ3YXRjaF93YWxsZXRfbmFtZSI6Im11bHRpc2lnX2FiYzEyMyJ9"

	group, err := DecodeGroupOpReturn(captured)
	require.NoError(t, err)
	assert.Equal(t, sampleGroupData(), group)
}

func TestDecodeRejectsMalformed(t *testing.T) {
	t.Run("no separator", func(t *testing.T) {
		_, err := DecodeGroupOpReturn("notapipe")
		require.Error(t, err)
	})
	t.Run("too many parts", func(t *testing.T) {
		_, err := DecodeGroupOpReturn("a|b|c")
		require.Error(t, err)
	})
	t.Run("bad metadata length", func(t *testing.T) {
		// base64 of 3 bytes, not 9.
		meta := base64.StdEncoding.EncodeToString([]byte{0x02, 0x00, 0x00})
		content := base64.StdEncoding.EncodeToString([]byte("{}"))
		_, err := DecodeGroupOpReturn(meta + "|" + content)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "metadata length")
	})
	t.Run("multisig flag not set", func(t *testing.T) {
		meta := make([]byte, 9)
		meta[0] = 0x01 // flag 0x02 not set
		copy(meta[5:9], "json")
		metaB64 := base64.StdEncoding.EncodeToString(meta)
		content := base64.StdEncoding.EncodeToString([]byte("{}"))
		_, err := DecodeGroupOpReturn(metaB64 + "|" + content)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "multisig flag")
	})
}

func strIndex(s string, c byte) int {
	for i := 0; i < len(s); i++ {
		if s[i] == c {
			return i
		}
	}
	return -1
}

// TestDeriveAccountXpubMatchesGroupKey proves wallet-key detection: deriving the
// account xpub from the abandon seed at the group key's path reproduces the
// stored xpub byte-for-byte (the Phase 1 BIP48 multisig keys).
func TestDeriveAccountXpubMatchesGroupKey(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.SigNetParams

	cases := map[string]string{
		"m/48'/1'/0'/2'": "tpubDFH9dgzveyD8zTbPUFuLrGmCydNvxehyNdUXKJAQN8x4aZ4j6UZqGfnqFrD4NqyaTVGKbvEW54tsvPTK2UoSbCC1PJY8iCNiwTL3RWZEheQ",
		"m/48'/1'/0'/3'": "tpubDFH9dgzveyD94P86sEzUzWtd2wxFkUoK78rSBqSWyXNuFq46dy4HbPTEZEP4fbSY4L5Vb2LFnm23JeGQppq5SPcPDNuHZU3JQwMSFXLdudh",
		"m/48'/1'/0'/4'": "tpubDFH9dgzveyD97hF9wTbwFieMpH9LcP5HcmbBS3vu8ijqNnu8djwrD2so8GbXpAzeTw7wwPjdKwQX6BTk2o6eCSGHJggkVYnMeBC9ECe9Ufp",
	}
	for path, want := range cases {
		got, err := DeriveAccountXpub(seedHex, path, net)
		require.NoError(t, err)
		assert.Equal(t, want, got, "path %s", path)
	}

	// A path the wallet doesn't own derives a different xpub (no false match).
	other, err := DeriveAccountXpub(seedHex, "m/48'/1'/0'/9'", net)
	require.NoError(t, err)
	assert.NotContains(t, cases, other)
}

// TestExtractOpReturnMessage builds an OP_RETURN script the way the wallet send
// path does (push the UTF-8 message bytes) and recovers the message string.
func TestExtractOpReturnMessage(t *testing.T) {
	const message = "AmZ9fOBqc29u|eyJpZCI6ImFiYzEyMyJ9"
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(message)).Script()
	require.NoError(t, err)

	outs := []RawTxOut{
		{ScriptPubKey: ScriptPubKey{Hex: "0014deadbeef"}}, // a non-OP_RETURN output, skipped
		{ScriptPubKey: ScriptPubKey{Hex: hex.EncodeToString(script)}},
	}
	got, err := ExtractOpReturnMessage(outs)
	require.NoError(t, err)
	assert.Equal(t, message, got)

	_, err = ExtractOpReturnMessage([]RawTxOut{{ScriptPubKey: ScriptPubKey{Hex: "0014deadbeef"}}})
	require.Error(t, err)
}
