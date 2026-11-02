package signmessage

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"strconv"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/ecdsa"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/require"
)

// Key and vectors from BIP322.
const bip322WIF = "L3VFeEujGtevx9w18HD1fhRbCH67Az2dpCymeRE1SoPK6XQtaN2k"

func decodeWIF(t *testing.T, wif string) *btcec.PrivateKey {
	t.Helper()
	decoded, err := btcutil.DecodeWIF(wif)
	require.NoError(t, err)
	return decoded.PrivKey
}

func addressesFor(t *testing.T, key *btcec.PrivateKey, params *chaincfg.Params) map[string]btcutil.Address {
	t.Helper()

	pkHash := btcutil.Hash160(key.PubKey().SerializeCompressed())

	legacy, err := btcutil.NewAddressPubKeyHash(pkHash, params)
	require.NoError(t, err)

	native, err := btcutil.NewAddressWitnessPubKeyHash(pkHash, params)
	require.NoError(t, err)

	redeem, err := txscript.PayToAddrScript(native)
	require.NoError(t, err)
	nested, err := btcutil.NewAddressScriptHash(redeem, params)
	require.NoError(t, err)

	taproot, err := btcutil.NewAddressTaproot(
		schnorr.SerializePubKey(txscript.ComputeTaprootKeyNoScript(key.PubKey())), params,
	)
	require.NoError(t, err)

	return map[string]btcutil.Address{"legacy": legacy, "native": native, "nested": nested, "taproot": taproot}
}

func TestBIP322MessageHash(t *testing.T) {
	t.Parallel()

	empty := bip322MessageHash("")
	require.Equal(t, "c90c269c4f8fcbe6880f72a721ddfbf1914268a794cbb21cfafee13770ae19f1", hex.EncodeToString(empty[:]))

	hello := bip322MessageHash("Hello World")
	require.Equal(t, "f0eb03b1a75ac6d9847f55c624a99169b5dccba2a31f5b23bea77ba270de0a7a", hex.EncodeToString(hello[:]))
}

func TestVerifyKnownVectors(t *testing.T) {
	t.Parallel()

	for _, tc := range []struct {
		name      string
		params    *chaincfg.Params
		address   string
		message   string
		signature string
	}{
		{
			name:      "bitcoin core p2pkh",
			params:    &chaincfg.TestNet3Params,
			address:   "mpLQjfK79b7CCV4VMJWEWAj5Mpx8Up5zxB",
			message:   "This is just a test message",
			signature: "INbVnW4e6PeRmsv2Qgu8NuopvrVjkcxob+sX8OcZG0SALhWybUjzMLPdAsXI46YZGb0KQTRii+wWIQzRpG/U+S0=",
		},
		{
			name:      "bip322 p2wpkh empty",
			params:    &chaincfg.MainNetParams,
			address:   "bc1q9vza2e8x573nczrlzms0wvx3gsqjx7vavgkx0l",
			message:   "",
			signature: "AkcwRAIgM2gBAQqvZX15ZiysmKmQpDrG83avLIT492QBzLnQIxYCIBaTpOaD20qRlEylyxFSeEA2ba9YOixpX8z46TSDtS40ASECx/EgAxlkQpQ9hYjgGu6EBCPMVPwVIVJqO4XCsMvViHI=",
		},
		{
			name:      "bip322 p2wpkh hello",
			params:    &chaincfg.MainNetParams,
			address:   "bc1q9vza2e8x573nczrlzms0wvx3gsqjx7vavgkx0l",
			message:   "Hello World",
			signature: "AkcwRAIgZRfIY3p7/DoVTty6YZbWS71bc5Vct9p9Fia83eRmw2QCICK/ENGfwLtptFluMGs2KsqoNSk89pO7F29zJLUx9a/sASECx/EgAxlkQpQ9hYjgGu6EBCPMVPwVIVJqO4XCsMvViHI=",
		},
		{
			name:      "bip322 p2tr hello",
			params:    &chaincfg.MainNetParams,
			address:   "bc1ppv609nr0vr25u07u95waq5lucwfm6tde4nydujnu8npg4q75mr5sxq8lt3",
			message:   "Hello World",
			signature: "AUHd69PrJQEv+oKTfZ8l+WROBHuy9HKrbFCJu7U1iK2iiEy1vMU5EfMtjc+VSHM7aU0SDbak5IUZRVno2P5mjSafAQ==",
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			valid, err := Verify(tc.address, tc.message, tc.signature, tc.params)
			require.NoError(t, err)
			require.True(t, valid)

			valid, err = Verify(tc.address, tc.message+"!", tc.signature, tc.params)
			require.NoError(t, err)
			require.False(t, valid)
		})
	}
}

func TestSignMatchesBitcoinCore(t *testing.T) {
	t.Parallel()

	params := &chaincfg.TestNet3Params
	key := decodeWIF(t, "cUeKHd5orzT3mz8P9pxyREHfsWtVfgsfDjiZZBcjUBAaGk1BTj7N")

	address, err := btcutil.DecodeAddress("mpLQjfK79b7CCV4VMJWEWAj5Mpx8Up5zxB", params)
	require.NoError(t, err)

	signature, err := Sign(key, address, "This is just a test message", params)
	require.NoError(t, err)
	require.Equal(t, "INbVnW4e6PeRmsv2Qgu8NuopvrVjkcxob+sX8OcZG0SALhWybUjzMLPdAsXI46YZGb0KQTRii+wWIQzRpG/U+S0=", signature)
}

// The digest is the same for every address type, so the segwit signatures are
// the Core bytes with the BIP137 header moved up by 4 or 8.
func TestSignSegwitHeadersMatchBitcoinCore(t *testing.T) {
	t.Parallel()

	params := &chaincfg.TestNet3Params
	key := decodeWIF(t, "cUeKHd5orzT3mz8P9pxyREHfsWtVfgsfDjiZZBcjUBAaGk1BTj7N")
	addresses := addressesFor(t, key, params)

	core, err := base64.StdEncoding.DecodeString("INbVnW4e6PeRmsv2Qgu8NuopvrVjkcxob+sX8OcZG0SALhWybUjzMLPdAsXI46YZGb0KQTRii+wWIQzRpG/U+S0=")
	require.NoError(t, err)

	for name, offset := range map[string]byte{"nested": 4, "native": 8} {
		t.Run(name, func(t *testing.T) {
			expected := append([]byte{core[0] + offset}, core[1:]...)

			signature, err := Sign(key, addresses[name], "This is just a test message", params)
			require.NoError(t, err)
			require.Equal(t, base64.StdEncoding.EncodeToString(expected), signature)
		})
	}
}

func TestSignNeverSignsTheRawMessage(t *testing.T) {
	t.Parallel()

	params := &chaincfg.MainNetParams
	key := decodeWIF(t, bip322WIF)
	address := addressesFor(t, key, params)["native"]

	for _, message := range []string{"", "Hello World", string(make([]byte, 32))} {
		t.Run(strconv.Quote(message), func(t *testing.T) {
			signature, err := Sign(key, address, message, params)
			require.NoError(t, err)

			raw, err := base64.StdEncoding.DecodeString(signature)
			require.NoError(t, err)
			compact := append([]byte{normalizeHeader(raw[0])}, raw[1:]...)

			single := sha256.Sum256([]byte(message))
			for _, digest := range [][]byte{single[:], chainhash.DoubleHashB([]byte(message)), []byte(message)} {
				recovered, _, err := ecdsa.RecoverCompact(compact, padDigest(digest))
				if err == nil {
					require.False(t, recovered.IsEqual(key.PubKey()))
				}
			}

			envelope, err := messageHash(message)
			require.NoError(t, err)
			recovered, _, err := ecdsa.RecoverCompact(compact, envelope)
			require.NoError(t, err)
			require.True(t, recovered.IsEqual(key.PubKey()))
		})
	}
}

func padDigest(digest []byte) []byte {
	padded := make([]byte, 32)
	copy(padded, digest)
	return padded
}

func TestSignRoundTrip(t *testing.T) {
	t.Parallel()

	params := &chaincfg.MainNetParams
	key := decodeWIF(t, bip322WIF)
	addresses := addressesFor(t, key, params)

	require.Equal(t, "bc1q9vza2e8x573nczrlzms0wvx3gsqjx7vavgkx0l", addresses["native"].EncodeAddress())
	require.Equal(t, "bc1ppv609nr0vr25u07u95waq5lucwfm6tde4nydujnu8npg4q75mr5sxq8lt3", addresses["taproot"].EncodeAddress())

	expectedHeaders := map[string]byte{"legacy": 31, "nested": 35, "native": 39}

	for name, address := range addresses {
		t.Run(name, func(t *testing.T) {
			signingKey := key
			if name == "taproot" {
				signingKey = txscript.TweakTaprootPrivKey(*key, []byte{})
			}

			signature, err := Sign(signingKey, address, "Hello World", params)
			require.NoError(t, err)

			raw, err := base64.StdEncoding.DecodeString(signature)
			require.NoError(t, err)
			if header, ok := expectedHeaders[name]; ok {
				require.Len(t, raw, 65)
				require.GreaterOrEqual(t, raw[0], header)
				require.Less(t, raw[0], header+4)
			}

			valid, err := Verify(address.EncodeAddress(), "Hello World", signature, params)
			require.NoError(t, err)
			require.True(t, valid)

			for otherName, other := range addresses {
				if otherName == name || (name == "legacy" && otherName != "taproot") {
					continue
				}
				t.Run(otherName, func(t *testing.T) {
					valid, err := Verify(other.EncodeAddress(), "Hello World", signature, params)
					require.NoError(t, err)
					require.False(t, valid)
				})
			}
		})
	}
}

func TestSignRefusesForeignAddress(t *testing.T) {
	t.Parallel()

	params := &chaincfg.MainNetParams
	other, err := btcec.NewPrivateKey()
	require.NoError(t, err)

	for name, address := range addressesFor(t, decodeWIF(t, bip322WIF), params) {
		t.Run(name, func(t *testing.T) {
			_, err := Sign(other, address, "Hello World", params)
			require.ErrorContains(t, err, "does not own")
		})
	}
}

// Electrum writes the compressed P2PKH header for segwit addresses too.
func TestVerifyAcceptsCompressedHeaderForSegwit(t *testing.T) {
	t.Parallel()

	params := &chaincfg.MainNetParams
	key := decodeWIF(t, bip322WIF)
	addresses := addressesFor(t, key, params)

	signature, err := signCompact(key, "Hello World", headerCompressedP2PKH)
	require.NoError(t, err)

	for _, name := range []string{"legacy", "native", "nested"} {
		t.Run(name, func(t *testing.T) {
			valid, err := Verify(addresses[name].EncodeAddress(), "Hello World", signature, params)
			require.NoError(t, err)
			require.True(t, valid)
		})
	}
}

func TestVerifyRejectsMalformedInput(t *testing.T) {
	t.Parallel()

	params := &chaincfg.MainNetParams
	address := "bc1q9vza2e8x573nczrlzms0wvx3gsqjx7vavgkx0l"

	_, err := Verify("not an address", "Hello World", "AA==", params)
	require.ErrorContains(t, err, "decode address")

	_, err = Verify(address, "Hello World", "%%%", params)
	require.ErrorContains(t, err, "decode signature")

	_, err = Verify("mpLQjfK79b7CCV4VMJWEWAj5Mpx8Up5zxB", "Hello World", "AA==", params)
	require.ErrorContains(t, err, "unknown address type")
}

// The signature that the frontend signer gave for the BIP84 vector key m/84'/1'/0'/0/0.
func TestSignNativeSegwitMatchesFrontend(t *testing.T) {
	keyBytes, err := hex.DecodeString("a9c4134b73560f43fc5c081e5c1daa7ce068adc806d80e1f37cb658e0fea4c8d")
	require.NoError(t, err)
	key, _ := btcec.PrivKeyFromBytes(keyBytes)
	address, err := btcutil.DecodeAddress("tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl", &chaincfg.SigNetParams)
	require.NoError(t, err)

	signature, err := Sign(key, address, "proof of funds", &chaincfg.SigNetParams)
	require.NoError(t, err)
	require.Equal(t, "KGpyhikj6zHeOb3mcq4dtyqa0CIOI5CGQ7mxEkao3PYpfuBVFxVh4MDh6kPTtob7yw+qm4JLmODIAmVLP7I2Ey8=", signature)
}

func TestKeyOwnsAddress(t *testing.T) {
	keyBytes, err := hex.DecodeString("a9c4134b73560f43fc5c081e5c1daa7ce068adc806d80e1f37cb658e0fea4c8d")
	require.NoError(t, err)
	_, pub := btcec.PrivKeyFromBytes(keyBytes)
	params := &chaincfg.SigNetParams
	hash := btcutil.Hash160(pub.SerializeCompressed())

	p2pkh, err := btcutil.NewAddressPubKeyHash(hash, params)
	require.NoError(t, err)
	p2wpkh, err := btcutil.NewAddressWitnessPubKeyHash(hash, params)
	require.NoError(t, err)
	nested, err := btcutil.NewAddressScriptHash(append([]byte{txscript.OP_0, txscript.OP_DATA_20}, hash...), params)
	require.NoError(t, err)
	tweaked := txscript.ComputeTaprootKeyNoScript(pub)
	p2tr, err := btcutil.NewAddressTaproot(schnorr.SerializePubKey(tweaked), params)
	require.NoError(t, err)

	compressed := hex.EncodeToString(pub.SerializeCompressed())
	for _, address := range []btcutil.Address{p2pkh, p2wpkh, nested} {
		owns, err := KeyOwnsAddress(compressed, address)
		require.NoError(t, err)
		require.True(t, owns, address.EncodeAddress())
	}
	owns, err := KeyOwnsAddress(hex.EncodeToString(tweaked.SerializeCompressed()), p2tr)
	require.NoError(t, err)
	require.True(t, owns)

	require.Equal(t, "tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl", p2wpkh.EncodeAddress())

	_, other := btcec.PrivKeyFromBytes(chainhash.HashB([]byte("other")))
	for _, address := range []btcutil.Address{p2pkh, p2wpkh, nested, p2tr} {
		owns, err := KeyOwnsAddress(hex.EncodeToString(other.SerializeCompressed()), address)
		require.NoError(t, err)
		require.False(t, owns, address.EncodeAddress())
	}

	_, err = KeyOwnsAddress("zz", p2wpkh)
	require.ErrorContains(t, err, "decode public key")
	_, err = KeyOwnsAddress("02ab", p2wpkh)
	require.ErrorContains(t, err, "parse public key")
}
