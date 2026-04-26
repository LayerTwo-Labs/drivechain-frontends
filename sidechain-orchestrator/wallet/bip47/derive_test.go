package bip47

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

func TestSenderA0_AliceMatchesVector(t *testing.T) {
	account, err := SeedAccountKey(aliceSeedHex)
	require.NoError(t, err)
	a0Ext, err := account.Derive(0)
	require.NoError(t, err)
	a0, err := a0Ext.ECPrivKey()
	require.NoError(t, err)
	require.Equal(t, aliceA0Hex, hex.EncodeToString(a0.Serialize()))
	require.Equal(t, aliceA0PubHex, hex.EncodeToString(a0.PubKey().SerializeCompressed()))
}

func TestDerivePaymentAddress_AliceToBob_FirstTen(t *testing.T) {
	bob, err := ParsePaymentCode(bobPaymentCode)
	require.NoError(t, err)

	for i, want := range aliceToBobAddresses {
		addr, err := DerivePaymentAddress(aliceSeedHex, bob, uint32(i), &chaincfg.MainNetParams)
		require.NoErrorf(t, err, "index %d", i)
		require.Equalf(t, want, addr.EncodeAddress(), "index %d", i)
	}
}

func TestDerivePaymentAddress_RejectsSelfSend(t *testing.T) {
	alice, err := ParsePaymentCode(alicePaymentCode)
	require.NoError(t, err)
	_, err = DerivePaymentAddress(aliceSeedHex, alice, 0, &chaincfg.MainNetParams)
	require.Error(t, err)
}

func TestDerivePaymentAddress_RejectsHardenedIndex(t *testing.T) {
	bob, err := ParsePaymentCode(bobPaymentCode)
	require.NoError(t, err)
	_, err = DerivePaymentAddress(aliceSeedHex, bob, 0x80000000, &chaincfg.MainNetParams)
	require.Error(t, err)
}
