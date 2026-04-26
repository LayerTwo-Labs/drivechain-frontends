package bip47

import (
	"encoding/binary"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
)

func decodeHex(t *testing.T, s string) []byte {
	t.Helper()
	b, err := hex.DecodeString(s)
	require.NoError(t, err)
	return b
}

func parseDesignatedOutpoint(t *testing.T) wire.OutPoint {
	t.Helper()
	b := decodeHex(t, designatedOutpointHex)
	require.Len(t, b, 36)
	var h chainhash.Hash
	copy(h[:], b[0:32])
	return wire.OutPoint{
		Hash:  h,
		Index: binary.LittleEndian.Uint32(b[32:36]),
	}
}

func TestECDH_AliceToBobSharedSecretX(t *testing.T) {
	wif, err := btcutil.DecodeWIF(designatedInputWIF)
	require.NoError(t, err)

	bob, err := ParsePaymentCode(bobPaymentCode)
	require.NoError(t, err)
	b0, err := bob.NotificationPubKey()
	require.NoError(t, err)
	require.Equal(t, bobB0PubHex, hex.EncodeToString(b0.SerializeCompressed()))

	x, err := ecdhX(wif.PrivKey, b0)
	require.NoError(t, err)
	require.Equal(t, sharedSecretXHex, hex.EncodeToString(x[:]))
}

func TestBlindingMask_AliceToBob(t *testing.T) {
	x := decodeHex(t, sharedSecretXHex)
	var x32 [32]byte
	copy(x32[:], x)
	op := parseDesignatedOutpoint(t)
	mask := blindingMask(x32, op)
	require.Equal(t, blindingMaskHex, hex.EncodeToString(mask[:]))
}

func TestBuildBlindedPayload_AliceToBob(t *testing.T) {
	wif, err := btcutil.DecodeWIF(designatedInputWIF)
	require.NoError(t, err)

	alice, err := PaymentCodeFromSeed(aliceSeedHex)
	require.NoError(t, err)
	aliceSerialized := alice.Serialize()
	require.Equal(t, aliceUnblindedPayload, hex.EncodeToString(aliceSerialized[:]))

	bob, err := ParsePaymentCode(bobPaymentCode)
	require.NoError(t, err)

	op := parseDesignatedOutpoint(t)
	blinded, err := BuildBlindedPayload(aliceSerialized, wif.PrivKey, bob, op)
	require.NoError(t, err)
	require.Equal(t, aliceBlindedPayload, hex.EncodeToString(blinded[:]))
}
