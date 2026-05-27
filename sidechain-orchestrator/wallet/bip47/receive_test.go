package bip47

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
)

func TestDeriveOwnNotificationKey_Alice(t *testing.T) {
	priv, addr, err := DeriveOwnNotificationKey(aliceSeedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, aliceA0Hex, hex.EncodeToString(priv.Serialize()))
	require.Equal(t, aliceNotificationAddress, addr.EncodeAddress())
}

// Bob is the receiver. Given Alice's notification pubkey (extracted from
// Alice's payment code), Bob must derive the same first-ten payment addresses
// the sender produced via DerivePaymentAddress.
func TestDeriveReceivedPaymentAddress_AliceToBob_FirstTen(t *testing.T) {
	alice, err := ParsePaymentCode(alicePaymentCode)
	require.NoError(t, err)
	aliceNotifPub, err := alice.NotificationPubKey()
	require.NoError(t, err)
	require.Equal(t, aliceA0PubHex, hex.EncodeToString(aliceNotifPub.SerializeCompressed()))

	for i, want := range aliceToBobAddresses {
		addr, priv, err := DeriveReceivedPaymentAddress(bobSeedHex, aliceNotifPub, uint32(i), &chaincfg.MainNetParams, AddressP2PKH)
		require.NoErrorf(t, err, "index %d", i)
		require.Equalf(t, want, addr.EncodeAddress(), "index %d", i)
		// Privkey's pubkey must hash to the same address.
		got, err := p2pkhAddress(priv.PubKey(), &chaincfg.MainNetParams)
		require.NoError(t, err)
		require.Equal(t, want, got.EncodeAddress())
	}
}

func TestDecodeBlindedPayload_AliceToBob_Vector(t *testing.T) {
	bobNotifPriv, _, err := DeriveOwnNotificationKey(bobSeedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)

	wif, err := btcutil.DecodeWIF(designatedInputWIF)
	require.NoError(t, err)
	aliceInputPub := wif.PrivKey.PubKey()

	outpoint := mustParseOutpoint(t, designatedOutpointHex)

	blindedBytes, err := hex.DecodeString(aliceBlindedPayload)
	require.NoError(t, err)
	require.Len(t, blindedBytes, PaymentCodeLength)
	var blinded [PaymentCodeLength]byte
	copy(blinded[:], blindedBytes)

	got, err := DecodeBlindedPayload(bobNotifPriv, aliceInputPub, outpoint, blinded)
	require.NoError(t, err)

	alice, err := ParsePaymentCode(alicePaymentCode)
	require.NoError(t, err)
	require.True(t, got.Equal(alice), "decoded payment code does not equal alicePaymentCode")
}

func TestBuildAndDecodeBlindedPayload_RoundTrip(t *testing.T) {
	alice, err := ParsePaymentCode(alicePaymentCode)
	require.NoError(t, err)
	bob, err := ParsePaymentCode(bobPaymentCode)
	require.NoError(t, err)

	wif, err := btcutil.DecodeWIF(designatedInputWIF)
	require.NoError(t, err)
	desigPriv := wif.PrivKey

	outpoint := mustParseOutpoint(t, designatedOutpointHex)

	aliceCode := alice.Serialize()
	blinded, err := BuildBlindedPayload(aliceCode, desigPriv, bob, outpoint)
	require.NoError(t, err)

	bobNotifPriv, _, err := DeriveOwnNotificationKey(bobSeedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)

	got, err := DecodeBlindedPayload(bobNotifPriv, desigPriv.PubKey(), outpoint, blinded)
	require.NoError(t, err)
	require.True(t, got.Equal(alice))
}

// mustParseOutpoint parses the test-vector outpoint hex. Format:
// 32 bytes txid (already in network byte order — matches the literal big-endian
// txid you'd display) + 4 bytes little-endian vout.
func mustParseOutpoint(t *testing.T, h string) wire.OutPoint {
	t.Helper()
	raw, err := hex.DecodeString(h)
	require.NoError(t, err)
	require.Len(t, raw, 36)
	var op wire.OutPoint
	copy(op.Hash[:], raw[:32])
	op.Index = uint32(raw[32]) | uint32(raw[33])<<8 | uint32(raw[34])<<16 | uint32(raw[35])<<24
	return op
}
