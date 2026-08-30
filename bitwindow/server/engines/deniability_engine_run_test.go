package engines_test

import (
	"context"
	"database/sql"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// Every other test calls a sub-method, so a field the constructor stopped
// filling shipped a nil dereference that killed bitwindowd one second after
// boot. This drives the loop itself.
func TestDeniabilityEngineRunSurvivesItsFirstTick(t *testing.T) {
	db := database.Test(t)
	bitcoind := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return nil, context.Canceled
	})

	e := engines.NewDeniability(bitcoind, db, nil)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	done := make(chan error, 1)
	go func() { done <- e.Run(ctx) }()

	select {
	case err := <-done:
		// It returns nil on a cancelled context; the point is that it returns
		// at all rather than crashing on a nil field.
		require.NoError(t, err)
	case <-time.After(10 * time.Second):
		t.Fatal("Run did not return after its context ended")
	}
}

// newFailingDenialEngine wires an engine whose Bitcoin Core broadcast always
// fails, plus a denial that is due right away. sends is how many broadcasts the
// test allows before gomock fails it.
func newFailingDenialEngine(t *testing.T, sends int) (*sql.DB, *engines.DeniabilityEngine, deniability.Denial) {
	t.Helper()

	db := database.Test(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	apitests.ExpectCoreWalletSetup(mockBitcoind)

	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[corepb.ListUnspentResponse]{
			Msg: &corepb.ListUnspentResponse{
				Unspent: []*corepb.UnspentOutput{
					{Txid: "test-txid", Address: "bc1qsource", Vout: 0, Amount: 0.01, Confirmations: 6},
				},
			},
		}, nil)

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

	// The broadcast fails every time, as it would against a node that is down.
	mockBitcoind.EXPECT().
		SendRawTransaction(gomock.Any(), gomock.Any()).
		Times(sends).
		Return(nil, errors.New("bitcoind is down"))

	bitcoindService := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	})
	engine := engines.NewDeniability(bitcoindService, db, testDenialWalletEngine(t, mockBitcoind))

	// A zero delay makes the first hop due immediately.
	denial, err := deniability.Create(context.Background(), db, denialWalletID, "test-txid", 0, 0, 3, nil)
	require.NoError(t, err)

	return db, engine, denial
}

// A denial whose send keeps failing used to re-issue the identical transaction
// on every one-second tick, forever.
func TestDeniabilityEngineRunBacksOffFailingDenials(t *testing.T) {
	ctx := context.Background()

	t.Run("does not retry within the backoff", func(t *testing.T) {
		db, engine, denial := newFailingDenialEngine(t, 1)

		runCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
		defer cancel()
		require.NoError(t, engine.Run(runCtx))

		denial, err := deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		require.Equal(t, int32(1), denial.FailedAttempts)
		require.NotNil(t, denial.RetryAfter)
		require.True(t, denial.RetryAfter.After(time.Now()))
		require.Nil(t, denial.CancelledAt)
	})

	t.Run("cancels once the failures pile up", func(t *testing.T) {
		db, engine, denial := newFailingDenialEngine(t, 1)

		// One failure short of the limit, and due again right away.
		_, err := db.ExecContext(ctx, `
			UPDATE denials SET failed_attempts = 9, retry_after = NULL WHERE id = ?
		`, denial.ID)
		require.NoError(t, err)

		runCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
		defer cancel()
		require.NoError(t, engine.Run(runCtx))

		denial, err = deniability.Get(ctx, db, denial.ID)
		require.NoError(t, err)
		require.Equal(t, int32(10), denial.FailedAttempts)
		require.NotNil(t, denial.CancelledAt)
		require.NotNil(t, denial.CancelReason)
		require.Contains(t, *denial.CancelReason, "cancelled after 10 failed attempts")
	})
}
