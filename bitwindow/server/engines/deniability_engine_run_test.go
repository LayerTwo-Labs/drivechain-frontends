package engines_test

import (
	"context"
	"testing"
	"time"

	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// Every other test calls a sub-method, so a field the constructor stopped
// filling shipped a nil dereference that killed bitwindowd one second after
// boot. This drives the loop itself.
func TestDeniabilityEngineRunSurvivesItsFirstTick(t *testing.T) {
	db := database.Test(t)
	bitcoind := service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return nil, context.Canceled
	})

	e := engines.NewDeniability(bitcoind, db, testDenialWalletEngine(t, mocks.NewMockBitcoinServiceClient(gomock.NewController(t)), nil))

	ctx, cancel := context.WithTimeout(t.Context(), 3*time.Second)
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
