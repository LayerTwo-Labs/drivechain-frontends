package api_wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/require"
)

const testSeedHex = "0329e77e27d1e24336be53d25a897e92e67b5ec7e88eca7529b14e3ffd9168a247b6906469fb8a79ecb25ec077e033f6b567d5d9b0ae334f1e33457ae6bb1364"

// signingWallet is a seed-only wallet at the given account override.
func signingWallet(accountIndex uint32, derivationPath string) *engines.WalletInfo {
	wallet := &engines.WalletInfo{AccountIndex: accountIndex, DerivationPath: derivationPath}
	wallet.Master.SeedHex = testSeedHex
	return wallet
}

// deriveAddressKey walks m/84'/coin'/account'/0/index for the test to compare against.
func deriveAddressKey(t *testing.T, chainParams *chaincfg.Params, coin, account, index uint32) *hdkeychain.ExtendedKey {
	t.Helper()

	seed, err := hex.DecodeString(testSeedHex)
	require.NoError(t, err)

	key, err := hdkeychain.NewMaster(seed, chainParams)
	require.NoError(t, err)

	const h = hdkeychain.HardenedKeyStart
	for _, child := range []uint32{h + 84, h + coin, h + account, 0, index} {
		key, err = key.Derive(child)
		require.NoError(t, err)
	}
	return key
}

func addressOf(t *testing.T, key *hdkeychain.ExtendedKey, chainParams *chaincfg.Params) string {
	t.Helper()

	pubKey, err := key.ECPubKey()
	require.NoError(t, err)

	addr, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(pubKey.SerializeCompressed()), chainParams)
	require.NoError(t, err)

	return addr.EncodeAddress()
}

// A signature only proves ownership of the address it was made with, so signing
// has to use the key behind the requested address - not the wallet's first one.
func TestDeriveMessageSigningPrivateKey(t *testing.T) {
	t.Parallel()

	chainParams := &chaincfg.SigNetParams

	for _, index := range []uint32{0, 3, addressScanDepth - 1} {
		expected := deriveAddressKey(t, chainParams, 1, 0, index)

		privKey, err := deriveMessageSigningPrivateKey(
			signingWallet(0, ""), chainParams, addressOf(t, expected, chainParams),
		)
		require.NoError(t, err)

		expectedKey, err := expected.ECPrivKey()
		require.NoError(t, err)
		require.Equal(t, expectedKey.Serialize(), privKey.Serialize())
	}

	// An address past the gap limit, or one from another wallet entirely, has no
	// key here - signing it would be a lie.
	beyondGap := deriveAddressKey(t, chainParams, 1, 0, addressScanDepth)
	_, err := deriveMessageSigningPrivateKey(
		signingWallet(0, ""), chainParams, addressOf(t, beyondGap, chainParams),
	)
	require.ErrorContains(t, err, "not one of the wallet")

	// Mainnet uses coin type 0, so the same index is a different address entirely
	mainnetAddr := addressOf(t, deriveAddressKey(t, &chaincfg.MainNetParams, 0, 0, 0), &chaincfg.MainNetParams)
	_, err = deriveMessageSigningPrivateKey(signingWallet(0, ""), chainParams, mainnetAddr)
	require.ErrorContains(t, err, "not one of the wallet")
}

// Wallets imported at a non-standard account own addresses under that account,
// so signing must derive from it too.
func TestDeriveMessageSigningPrivateKeyHonorsAccount(t *testing.T) {
	t.Parallel()

	chainParams := &chaincfg.SigNetParams
	account5 := deriveAddressKey(t, chainParams, 1, 5, 0)
	address := addressOf(t, account5, chainParams)

	for _, wallet := range []*engines.WalletInfo{
		signingWallet(5, ""),
		signingWallet(0, "m/84'/1'/5'"),
	} {
		privKey, err := deriveMessageSigningPrivateKey(wallet, chainParams, address)
		require.NoError(t, err)

		expected, err := account5.ECPrivKey()
		require.NoError(t, err)
		require.Equal(t, expected.Serialize(), privKey.Serialize())
	}

	// The default-account wallet does not own that address
	_, err := deriveMessageSigningPrivateKey(signingWallet(0, ""), chainParams, address)
	require.ErrorContains(t, err, "not one of the wallet")
}

// Default wallets import BIP84 and BIP86 descriptors, and the receive UI hands
// out both, so a taproot address must be signable too.
func TestDeriveMessageSigningPrivateKeyHandlesTaproot(t *testing.T) {
	t.Parallel()

	chainParams := &chaincfg.SigNetParams

	key := deriveKeyAtPurpose(t, chainParams, 86, 1, 0, 0)
	tapKey := txscript.ComputeTaprootKeyNoScript(pubKeyOf(t, key))
	taproot, err := btcutil.NewAddressTaproot(schnorr.SerializePubKey(tapKey), chainParams)
	require.NoError(t, err)

	expected, err := key.ECPrivKey()
	require.NoError(t, err)

	// The key must be tweaked: an untweaked internal key signs for a pubkey the
	// address does not commit to, so the signature proves nothing about it.
	tweaked := txscript.TweakTaprootPrivKey(*expected, []byte{})
	require.NotEqual(t, hex.EncodeToString(expected.Serialize()), hex.EncodeToString(tweaked.Serialize()))
	require.Equal(t,
		taproot.ScriptAddress(),
		schnorr.SerializePubKey(tweaked.PubKey()),
		"tweaked key must match the address's witness program",
	)

	for _, wallet := range []*engines.WalletInfo{
		signingWallet(0, ""),            // taproot comes alongside segwit off one seed
		signingWallet(0, "m/86'/1'/0'"), // explicit m/86' path is its single kind
	} {
		privKey, err := deriveMessageSigningPrivateKey(wallet, chainParams, taproot.EncodeAddress())
		require.NoError(t, err)
		require.Equal(t, tweaked.Serialize(), privKey.Serialize())
	}
}

// Light mode has no enforcer and no bitcoind, so signing and verifying must
// need neither.
func TestSignAndVerifyMessageWithoutNode(t *testing.T) {
	ctx := context.Background()

	const walletID = "80CEBA2163224572BDEADD2D2181C51B"

	tempDir := t.TempDir()
	walletData, err := json.Marshal(map[string]any{
		"version":        1,
		"activeWalletId": walletID,
		"wallets": []map[string]any{{
			"version":     1,
			"master":      map[string]any{"seed_hex": testSeedHex},
			"id":          walletID,
			"name":        "test",
			"wallet_type": "electrum",
		}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(tempDir, "wallet.json"), walletData, 0o600))

	walletEngine := engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return nil, errors.New("no bitcoind in light mode")
		},
		tempDir,
		&chaincfg.SigNetParams,
	)
	require.True(t, walletEngine.IsUnlocked(), "unencrypted wallets auto-unlock at startup")

	server := &Server{walletEngine: walletEngine}

	const message = "signed by Bjørn"
	segwit := addressOf(t, deriveAddressKey(t, &chaincfg.SigNetParams, 1, 0, 2), &chaincfg.SigNetParams)

	tapKey := txscript.ComputeTaprootKeyNoScript(pubKeyOf(t, deriveKeyAtPurpose(t, &chaincfg.SigNetParams, 86, 1, 0, 1)))
	taproot, err := btcutil.NewAddressTaproot(schnorr.SerializePubKey(tapKey), &chaincfg.SigNetParams)
	require.NoError(t, err)

	for _, address := range []string{segwit, taproot.EncodeAddress()} {
		signed, err := server.SignMessage(ctx, connect.NewRequest(&pb.SignMessageRequest{
			WalletId: walletID,
			Message:  message,
			Address:  address,
		}))
		require.NoError(t, err, address)

		for _, tc := range []struct {
			message string
			valid   bool
		}{{message, true}, {message + " ", false}} {
			verified, err := server.VerifyMessage(ctx, connect.NewRequest(&pb.VerifyMessageRequest{
				Message:   tc.message,
				Signature: signed.Msg.Signature,
				PublicKey: address,
			}))
			require.NoError(t, err)
			require.Equal(t, tc.valid, verified.Msg.Valid, address)
		}
	}
}

// deriveKeyAtPurpose walks m/purpose'/coin'/account'/0/index.
func deriveKeyAtPurpose(t *testing.T, chainParams *chaincfg.Params, purpose, coin, account, index uint32) *hdkeychain.ExtendedKey {
	t.Helper()

	seed, err := hex.DecodeString(testSeedHex)
	require.NoError(t, err)

	key, err := hdkeychain.NewMaster(seed, chainParams)
	require.NoError(t, err)

	const h = hdkeychain.HardenedKeyStart
	for _, child := range []uint32{h + purpose, h + coin, h + account, 0, index} {
		key, err = key.Derive(child)
		require.NoError(t, err)
	}
	return key
}

func pubKeyOf(t *testing.T, key *hdkeychain.ExtendedKey) *btcec.PublicKey {
	t.Helper()

	pubKey, err := key.ECPubKey()
	require.NoError(t, err)
	return pubKey
}

// Electrum wallets can sit at m/44' or m/49', and the stored wallet does not say
// which, so those addresses must resolve too.
func TestDeriveMessageSigningPrivateKeyHandlesLegacyAndNested(t *testing.T) {
	t.Parallel()

	chainParams := &chaincfg.SigNetParams

	for _, tc := range []struct {
		purpose uint32
		path    string
		address func(*testing.T, *btcec.PublicKey) string
	}{
		{44, "m/44'/1'/0'", func(t *testing.T, pub *btcec.PublicKey) string {
			addr, err := btcutil.NewAddressPubKeyHash(btcutil.Hash160(pub.SerializeCompressed()), chainParams)
			require.NoError(t, err)
			return addr.EncodeAddress()
		}},
		{49, "m/49'/1'/0'", func(t *testing.T, pub *btcec.PublicKey) string {
			witness, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(pub.SerializeCompressed()), chainParams)
			require.NoError(t, err)
			redeem, err := txscript.PayToAddrScript(witness)
			require.NoError(t, err)
			addr, err := btcutil.NewAddressScriptHash(redeem, chainParams)
			require.NoError(t, err)
			return addr.EncodeAddress()
		}},
	} {
		key := deriveKeyAtPurpose(t, chainParams, tc.purpose, 1, 0, 0)
		address := tc.address(t, pubKeyOf(t, key))

		expected, err := key.ECPrivKey()
		require.NoError(t, err)

		for _, wallet := range []*engines.WalletInfo{signingWallet(0, ""), signingWallet(0, tc.path)} {
			privKey, err := deriveMessageSigningPrivateKey(wallet, chainParams, address)
			require.NoError(t, err)
			require.Equal(t, expected.Serialize(), privKey.Serialize())
		}
	}
}
