package engines

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/timestamps"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// A timestamp whose transaction bitcoind has never heard of has to eventually
// leave "confirming" — otherwise a dropped/replaced broadcast is reported as
// in-flight forever. A transient RPC failure must NOT do that.
func TestCheckConfirmations_UnknownTransaction(t *testing.T) {
	tests := []struct {
		name      string
		createdAt time.Time
		rpcErr    error
		want      timestamps.Status
	}{
		{
			name:      "unknown transaction past grace period fails",
			createdAt: time.Now().Add(-timestampFailureGrace - time.Hour),
			rpcErr:    errors.New("internal: -5: No such mempool or blockchain transaction. Use gettransaction for wallet transactions."),
			want:      timestamps.StatusFailed,
		},
		{
			name:      "unknown transaction within grace period keeps confirming",
			createdAt: time.Now().Add(-time.Hour),
			rpcErr:    errors.New("internal: -5: No such mempool or blockchain transaction. Use gettransaction for wallet transactions."),
			want:      timestamps.StatusConfirming,
		},
		{
			name:      "bitcoind outage keeps confirming",
			createdAt: time.Now().Add(-timestampFailureGrace - time.Hour),
			rpcErr:    errors.New("unavailable: dial tcp 127.0.0.1:8332: connect: connection refused"),
			want:      timestamps.StatusConfirming,
		},
		{
			name:      "bitcoind still starting up keeps confirming",
			createdAt: time.Now().Add(-timestampFailureGrace - time.Hour),
			rpcErr:    errors.New("internal: -28: Loading block index…"),
			want:      timestamps.StatusConfirming,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			ctx := context.Background()
			db := database.Test(t)

			core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			engine := NewTimestampEngine(db, zerolog.Nop(), nil,
				service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
					return core, nil
				}),
			)

			txid := "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
			id, err := timestamps.Create(ctx, db, timestamps.FileTimestamp{
				Filename:  "test.txt",
				FileHash:  "cafebabe",
				TxID:      &txid,
				Status:    timestamps.StatusConfirming,
				CreatedAt: tc.createdAt,
			})
			require.NoError(t, err)

			core.EXPECT().
				GetRawTransaction(gomock.Any(), gomock.Any()).
				Return((*connect.Response[corepb.GetRawTransactionResponse])(nil), tc.rpcErr)

			require.NoError(t, engine.checkConfirmations(ctx))

			got, err := timestamps.Get(ctx, db, id)
			require.NoError(t, err)
			require.NotNil(t, got)
			assert.Equal(t, tc.want, got.Status)
		})
	}
}
