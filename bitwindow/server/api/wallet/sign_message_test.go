package api_wallet

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// The signing key must be the wallet's own key material - an empty/absent secret
// key makes the enforcer's Secp256K1Sign call fail, so SignMessage never works.
func TestDeriveMessageSigningPrivateKey(t *testing.T) {
	t.Parallel()

	const seedHex = "0329e77e27d1e24336be53d25a897e92e67b5ec7e88eca7529b14e3ffd9168a247b6906469fb8a79ecb25ec077e033f6b567d5d9b0ae334f1e33457ae6bb1364"

	chainParams := &chaincfg.SigNetParams

	privKeyHex, err := deriveMessageSigningPrivateKey(seedHex, chainParams)
	require.NoError(t, err)

	privKeyBytes, err := hex.DecodeString(privKeyHex)
	require.NoError(t, err)
	require.Len(t, privKeyBytes, 32)

	// Independently derive m/84'/1'/0'/0/0 and check the key matches, so the
	// signature verifies against the wallet's first receiving address.
	seed, err := hex.DecodeString(seedHex)
	require.NoError(t, err)

	key, err := hdkeychain.NewMaster(seed, chainParams)
	require.NoError(t, err)

	for _, child := range []uint32{
		hdkeychain.HardenedKeyStart + 84,
		hdkeychain.HardenedKeyStart + 1, // signet coin type
		hdkeychain.HardenedKeyStart + 0,
		0, // external chain
		0, // address index
	} {
		key, err = key.Derive(child)
		require.NoError(t, err)
	}

	expected, err := key.ECPrivKey()
	require.NoError(t, err)
	require.Equal(t, hex.EncodeToString(expected.Serialize()), privKeyHex)

	// Mainnet uses coin type 0, so it must derive a different key
	mainnetPrivKeyHex, err := deriveMessageSigningPrivateKey(seedHex, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.NotEqual(t, privKeyHex, mainnetPrivKeyHex)

	// Sanity check: the pubkey hashes to the first receiving address
	pubKey, err := key.ECPubKey()
	require.NoError(t, err)

	addr, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(pubKey.SerializeCompressed()), chainParams)
	require.NoError(t, err)
	require.NotEmpty(t, addr.EncodeAddress())
}
