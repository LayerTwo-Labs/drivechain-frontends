package api_wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"
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

		privKeyHex, err := deriveMessageSigningPrivateKey(
			signingWallet(0, ""), chainParams, addressOf(t, expected, chainParams),
		)
		require.NoError(t, err)

		expectedKey, err := expected.ECPrivKey()
		require.NoError(t, err)
		require.Equal(t, hex.EncodeToString(expectedKey.Serialize()), privKeyHex)
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
		privKeyHex, err := deriveMessageSigningPrivateKey(wallet, chainParams, address)
		require.NoError(t, err)

		expected, err := account5.ECPrivKey()
		require.NoError(t, err)
		require.Equal(t, hex.EncodeToString(expected.Serialize()), privKeyHex)
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

	// Standard wallet: taproot comes alongside segwit off the same seed.
	privKeyHex, err := deriveMessageSigningPrivateKey(signingWallet(0, ""), chainParams, taproot.EncodeAddress())
	require.NoError(t, err)
	require.Equal(t, hex.EncodeToString(expected.Serialize()), privKeyHex)

	// Taproot-only wallet: the explicit m/86' path is its single kind.
	privKeyHex, err = deriveMessageSigningPrivateKey(signingWallet(0, "m/86'/1'/0'"), chainParams, taproot.EncodeAddress())
	require.NoError(t, err)
	require.Equal(t, hex.EncodeToString(expected.Serialize()), privKeyHex)
}

// The enforcer's Secp256K1Sign takes a common.Hex message, so plaintext has to be
// hex encoded on the way in or every signature request fails to decode.
func TestSignMessageHexEncodesMessage(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	ctx := context.Background()

	const (
		walletID = "80CEBA2163224572BDEADD2D2181C51B"
		seedHex  = testSeedHex
	)

	tempDir := t.TempDir()
	walletData, err := json.Marshal(map[string]any{
		"version":        1,
		"activeWalletId": walletID,
		"wallets": []map[string]any{{
			"version":     1,
			"master":      map[string]any{"seed_hex": seedHex},
			"id":          walletID,
			"name":        "test",
			"wallet_type": "bitcoinCore",
		}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(tempDir, "wallet.json"), walletData, 0o600))

	walletEngine := engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return nil, nil },
		nil,
		tempDir,
		&chaincfg.SigNetParams,
	)
	require.True(t, walletEngine.IsUnlocked(), "unencrypted wallets auto-unlock at startup")

	var signed *cryptov1.Secp256K1SignRequest
	mockCrypto := mocks.NewMockCryptoServiceClient(ctrl)
	mockCrypto.EXPECT().
		Secp256K1Sign(gomock.Any(), gomock.Any()).
		DoAndReturn(func(ctx context.Context, req *connect.Request[cryptov1.Secp256K1SignRequest]) (*connect.Response[cryptov1.Secp256K1SignResponse], error) {
			signed = req.Msg
			return &connect.Response[cryptov1.Secp256K1SignResponse]{
				Msg: &cryptov1.Secp256K1SignResponse{
					Signature: &commonv1.Hex{Hex: wrapperspb.String("3045')")},
				},
			}, nil
		})

	server := &Server{
		walletEngine: walletEngine,
		crypto: service.New("test-crypto", func(ctx context.Context) (cryptorpc.CryptoServiceClient, error) {
			return mockCrypto, nil
		}),
	}

	// Non-ASCII on purpose: raw plaintext would not be valid hex either way, but
	// multi-byte input also proves the encoding is over bytes, not runes.
	const message = "signed by Bjørn"

	wallet := signingWallet(0, "")
	address := addressOf(t, deriveAddressKey(t, &chaincfg.SigNetParams, 1, 0, 0), &chaincfg.SigNetParams)

	res, err := server.SignMessage(ctx, connect.NewRequest(&pb.SignMessageRequest{
		WalletId: walletID,
		Message:  message,
		Address:  address,
	}))
	require.NoError(t, err)
	require.Equal(t, "3045')", res.Msg.Signature)

	require.NotNil(t, signed, "enforcer was never called")
	decoded, err := hex.DecodeString(signed.Message.Hex.Value)
	require.NoError(t, err, "message must be hex the enforcer can decode")
	require.Equal(t, message, string(decoded))

	expectedKey, err := deriveMessageSigningPrivateKey(wallet, &chaincfg.SigNetParams, address)
	require.NoError(t, err)
	require.Equal(t, expectedKey, signed.SecretKey.Hex.Value)
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
			privKeyHex, err := deriveMessageSigningPrivateKey(wallet, chainParams, address)
			require.NoError(t, err)
			require.Equal(t, hex.EncodeToString(expected.Serialize()), privKeyHex)
		}
	}
}
