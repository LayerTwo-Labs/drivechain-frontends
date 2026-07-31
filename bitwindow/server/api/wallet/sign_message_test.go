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
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"
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

// The enforcer's Secp256K1Sign takes a common.Hex message, so plaintext has to be
// hex encoded on the way in or every signature request fails to decode.
func TestSignMessageHexEncodesMessage(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	ctx := context.Background()

	const (
		walletID = "80CEBA2163224572BDEADD2D2181C51B"
		seedHex  = "0329e77e27d1e24336be53d25a897e92e67b5ec7e88eca7529b14e3ffd9168a247b6906469fb8a79ecb25ec077e033f6b567d5d9b0ae334f1e33457ae6bb1364"
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

	res, err := server.SignMessage(ctx, connect.NewRequest(&pb.SignMessageRequest{
		WalletId: walletID,
		Message:  message,
	}))
	require.NoError(t, err)
	require.Equal(t, "3045')", res.Msg.Signature)

	require.NotNil(t, signed, "enforcer was never called")
	decoded, err := hex.DecodeString(signed.Message.Hex.Value)
	require.NoError(t, err, "message must be hex the enforcer can decode")
	require.Equal(t, message, string(decoded))

	expectedKey, err := deriveMessageSigningPrivateKey(seedHex, &chaincfg.SigNetParams)
	require.NoError(t, err)
	require.Equal(t, expectedKey, signed.SecretKey.Hex.Value)
}
