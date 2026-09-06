package engines_test

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/btcsuite/btcd/chaincfg"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

const denialWalletID = "80CEBA2163224572BDEADD2D2181C51B"

// A denial names the wallet it spends from, so the engine has to resolve one.
// Passing nil here is what once pushed the empty-wallet-id tolerance into the
// product, where it skipped the watch-only check and reached Core's loaded
// wallet.
func testDenialWalletEngine(t *testing.T, bitcoind corerpc.BitcoinServiceClient) *engines.WalletEngine {
	t.Helper()

	dir := t.TempDir()
	walletData, err := json.Marshal(map[string]any{
		"version":        1,
		"activeWalletId": denialWalletID,
		"wallets": []map[string]any{{
			"version":     1,
			"master":      map[string]any{"seed_hex": "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"},
			"id":          denialWalletID,
			"name":        "test",
			"wallet_type": "bitcoinCore",
		}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletData, 0o600))

	return engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return bitcoind, nil },
		dir,
		&chaincfg.SigNetParams,
	)
}

func TestDeniabilityEngine(t *testing.T) {
	t.Parallel()

	ctx := context.Background()
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	t.Run("handleAbortedDenials", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		})
		engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

		// Create a denial with empty wallet_id (legacy behavior)
		denial, err := deniability.Create(ctx, db, denialWalletID, "test-txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		// Core holds a different UTXO, so the denial's tip is gone.
		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Times(1).
			Return(&connect.Response[corepb.ListUnspentResponse]{
				Msg: &corepb.ListUnspentResponse{
					Unspent: []*corepb.UnspentOutput{
						{Txid: "different-txid", Vout: 0, Amount: 0.01, Confirmations: 6},
					},
				},
			}, nil)

		// Run cleanup
		utxos, denials, err := engine.CleanupDenials(ctx)
		require.NoError(t, err)
		assert.Empty(t, denials) // Denial should be cancelled
		assert.Len(t, utxos, 1)

		// Verify denial was cancelled
		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.NotNil(t, denial.CancelledAt)
		assert.Equal(t, "cancelled due to UTXO being moved", *denial.CancelReason)
	})

	t.Run("executeDenial", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		})
		engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

		// Create a denial with empty wallet_id (legacy behavior)
		denial, err := deniability.Create(ctx, db, denialWalletID, "test-txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		// The send path asks for a change address too.
		mockBitcoind.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.GetNewAddressResponse]{
				Msg: &corepb.GetNewAddressResponse{Address: "bc1qtest"},
			}, nil)

		// Core signs and broadcasts a raw transaction.
		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.CreateRawTransactionResponse]{
				Msg: &corepb.CreateRawTransactionResponse{Tx: &corepb.RawTransaction{Hex: "raw-tx-hex"}},
			}, nil)

		mockBitcoind.EXPECT().
			SignRawTransactionWithWallet(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.SignRawTransactionWithWalletResponse]{
				Msg: &corepb.SignRawTransactionWithWalletResponse{Hex: "signed-tx-hex", Complete: true},
			}, nil)

		mockBitcoind.EXPECT().
			SendRawTransaction(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.SendRawTransactionResponse]{
				Msg: &corepb.SendRawTransactionResponse{Txid: "new-txid"},
			}, nil)

		// waitForTXToAppear keeps reading until the new txid shows up.
		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.ListUnspentResponse]{
				Msg: &corepb.ListUnspentResponse{
					Unspent: []*corepb.UnspentOutput{
						{Txid: "test-txid", Address: "bc1qsource", Vout: 0, Amount: 0.01, Confirmations: 6},
						{Txid: "new-txid", Address: "bc1qtest", Vout: 0, Amount: 0.005, Confirmations: 1},
					},
				},
			}, nil)

		// Execute denial
		err = engine.ExecuteDenial(ctx, []*engines.UTXO{
			{Txid: "test-txid", Vout: 0, ValueSats: 1000000},
		}, denial)
		require.NoError(t, err)

		// Verify execution was recorded
		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.NotNil(t, denial)
	})

	t.Run("processUTXO with insufficient amount", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		})
		engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

		// Create a denial with empty wallet_id (legacy behavior)
		denial, err := deniability.Create(ctx, db, denialWalletID, "test-txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		// Process UTXO with insufficient amount
		err = engine.ProcessUTXO(ctx, &engines.UTXO{
			Txid:      "test-txid",
			Vout:      0,
			ValueSats: 5000, // Less than fee
		}, denial)
		require.NoError(t, err)

		// Verify denial was cancelled
		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.NotNil(t, denial.CancelledAt)
		assert.Equal(t, "utxo is too small to split", *denial.CancelReason)
	})

	// A tip that clears the fee but cannot fund a non-dust output has to
	// terminate, not pay a zero-value destination and retry on every tick. No
	// send is mocked here, so attempting one fails the test.
	t.Run("processUTXO cancels when the split cannot clear dust", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		})
		engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

		// 10,001 sats leaves one sat over the fee; 10,600 leaves 600, of which
		// even the largest 90% roll is under the dust limit.
		for _, valueSats := range []uint64{10_001, 10_600} {
			denial, err := deniability.Create(ctx, db, denialWalletID, "test-txid", 0, 1*time.Hour, 3, nil)
			require.NoError(t, err)

			err = engine.ProcessUTXO(ctx, &engines.UTXO{
				Txid:      "test-txid",
				Vout:      0,
				ValueSats: valueSats,
			}, denial)
			require.NoError(t, err)

			denial, err = deniability.Get(ctx, db, denial.ID)
			require.NoError(t, err)
			require.NotNil(t, denial.CancelledAt, "denial for %d sats was left running", valueSats)
			assert.Equal(t, "utxo is too small to split", *denial.CancelReason)
		}
	})

	t.Run("processUTXO cancels a target size below dust", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		})
		engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

		denial, err := deniability.Create(ctx, db, denialWalletID, "test-txid", 0, 1*time.Hour, 3, []int64{100})
		require.NoError(t, err)

		err = engine.ProcessUTXO(ctx, &engines.UTXO{
			Txid:      "test-txid",
			Vout:      0,
			ValueSats: 20_000,
		}, denial)
		require.NoError(t, err)

		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		require.NotNil(t, denial.CancelledAt)
		assert.Equal(t, "utxo is too small to split", *denial.CancelReason)
	})

	// Control: a tip big enough for a non-dust split still splits.
	t.Run("processUTXO splits a UTXO that clears dust", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		})
		engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

		denial, err := deniability.Create(ctx, db, denialWalletID, "test-txid", 0, 1*time.Hour, 3, nil)
		require.NoError(t, err)

		mockBitcoind.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.GetNewAddressResponse]{
				Msg: &corepb.GetNewAddressResponse{Address: "bc1qtest"},
			}, nil)

		mockBitcoind.EXPECT().
			CreateRawTransaction(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.CreateRawTransactionResponse]{
				Msg: &corepb.CreateRawTransactionResponse{Tx: &corepb.RawTransaction{Hex: "raw-tx-hex"}},
			}, nil)

		mockBitcoind.EXPECT().
			SignRawTransactionWithWallet(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.SignRawTransactionWithWalletResponse]{
				Msg: &corepb.SignRawTransactionWithWalletResponse{Hex: "signed-tx-hex", Complete: true},
			}, nil)

		mockBitcoind.EXPECT().
			SendRawTransaction(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.SendRawTransactionResponse]{
				Msg: &corepb.SendRawTransactionResponse{Txid: "new-txid"},
			}, nil)

		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			AnyTimes().
			Return(&connect.Response[corepb.ListUnspentResponse]{
				Msg: &corepb.ListUnspentResponse{
					Unspent: []*corepb.UnspentOutput{
						{Txid: "test-txid", Address: "bc1qsource", Vout: 0, Amount: 0.0002, Confirmations: 6},
						{Txid: "new-txid", Address: "bc1qtest", Vout: 0, Amount: 0.0001, Confirmations: 1},
					},
				},
			}, nil)

		err = engine.ProcessUTXO(ctx, &engines.UTXO{
			Txid:      "test-txid",
			Vout:      0,
			ValueSats: 20_000,
		}, denial)
		require.NoError(t, err)

		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		assert.Nil(t, denial.CancelledAt)
		assert.Len(t, denial.ExecutedDenials, 1)
	})
}
