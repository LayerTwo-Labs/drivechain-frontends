package bip47

import (
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

func TestPaymentCode_FromAliceSeed(t *testing.T) {
	pc, err := PaymentCodeFromSeed(aliceSeedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, alicePaymentCode, pc.Base58())
}

func TestPaymentCode_FromBobSeed(t *testing.T) {
	pc, err := PaymentCodeFromSeed(bobSeedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, bobPaymentCode, pc.Base58())
}

func TestPaymentCode_FromAliceMnemonic(t *testing.T) {
	pc, err := PaymentCodeFromMnemonic(aliceMnemonic, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, alicePaymentCode, pc.Base58())
}

func TestPaymentCode_FromBobMnemonic(t *testing.T) {
	pc, err := PaymentCodeFromMnemonic(bobMnemonic, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.Equal(t, bobPaymentCode, pc.Base58())
}

// TestPaymentCode_TestnetUsesCoinTypeOne verifies that on a non-mainnet
// chain, derivation traverses m/47'/1'/0' instead of m/47'/0'/0' — matching
// BIP44's coin_type convention and Sparrow/Samourai interop.
func TestPaymentCode_TestnetUsesCoinTypeOne(t *testing.T) {
	mainnet, err := PaymentCodeFromSeed(aliceSeedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)
	signet, err := PaymentCodeFromSeed(aliceSeedHex, &chaincfg.SigNetParams)
	require.NoError(t, err)
	regtest, err := PaymentCodeFromSeed(aliceSeedHex, &chaincfg.RegressionNetParams)
	require.NoError(t, err)
	require.NotEqual(t, mainnet.Base58(), signet.Base58(), "signet code must use coin_type 1")
	require.NotEqual(t, mainnet.Base58(), regtest.Base58(), "regtest code must use coin_type 1")
	require.Equal(t, signet.Base58(), regtest.Base58(), "all testnet variants share coin_type 1")
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
