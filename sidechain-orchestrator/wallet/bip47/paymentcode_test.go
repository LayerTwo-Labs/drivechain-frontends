package bip47

import (
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

func TestPaymentCode_FromAliceSeed(t *testing.T) {
	pc, err := PaymentCodeFromSeed(aliceSeedHex)
	require.NoError(t, err)
	require.Equal(t, alicePaymentCode, pc.Base58())
}

func TestPaymentCode_FromBobSeed(t *testing.T) {
	pc, err := PaymentCodeFromSeed(bobSeedHex)
	require.NoError(t, err)
	require.Equal(t, bobPaymentCode, pc.Base58())
}

func TestPaymentCode_FromAliceMnemonic(t *testing.T) {
	pc, err := PaymentCodeFromMnemonic(aliceMnemonic)
	require.NoError(t, err)
	require.Equal(t, alicePaymentCode, pc.Base58())
}

func TestPaymentCode_FromBobMnemonic(t *testing.T) {
	pc, err := PaymentCodeFromMnemonic(bobMnemonic)
	require.NoError(t, err)
	require.Equal(t, bobPaymentCode, pc.Base58())
}

func TestPaymentCode_RoundTrip(t *testing.T) {
	for _, code := range []string{alicePaymentCode, bobPaymentCode} {
		pc, err := ParsePaymentCode(code)
		require.NoError(t, err)
		require.Equal(t, code, pc.Base58())
	}
}

func TestPaymentCode_RejectsWrongVersionByte(t *testing.T) {
	// Take Alice's code and corrupt the base58 version by re-encoding with
	// a different prefix. Simplest: tweak the first character.
	bad := "Q" + alicePaymentCode[1:]
	_, err := ParsePaymentCode(bad)
	require.Error(t, err)
}

func TestNotificationAddress_AliceMainnet(t *testing.T) {
	pc, err := ParsePaymentCode(alicePaymentCode)
	require.NoError(t, err)
	addr, err := DeriveNotificationAddress(pc, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, aliceNotificationAddress, addr.EncodeAddress())
}

func TestNotificationAddress_BobMainnet(t *testing.T) {
	pc, err := ParsePaymentCode(bobPaymentCode)
	require.NoError(t, err)
	addr, err := DeriveNotificationAddress(pc, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, bobNotificationAddress, addr.EncodeAddress())
}
