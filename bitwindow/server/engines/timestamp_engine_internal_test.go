package engines

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
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
		inIBD     bool
		want      timestamps.Status
	}{
		{
			name:      "unknown transaction during initial block download keeps confirming",
			createdAt: time.Now().Add(-timestampFailureGrace - time.Hour),
			rpcErr:    errors.New("internal: -5: No such mempool or blockchain transaction. Use gettransaction for wallet transactions."),
			inIBD:     true,
			want:      timestamps.StatusConfirming,
		},
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
			ctx := t.Context()
			db := database.Test(t)

			ctrl := gomock.NewController(t)
			core := mocks.NewMockBitcoinServiceClient(ctrl)
			engine := NewTimestampEngine(db, nil,
				service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
					return core, nil
				}),
				nil,
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
				GetBlockchainInfo(gomock.Any(), gomock.Any()).
				Return(connect.NewResponse(&corepb.GetBlockchainInfoResponse{
					InitialBlockDownload: tc.inIBD,
				}), nil)

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

func TestCheckConfirmations_UpdateFailureReturnsError(t *testing.T) {
	tests := []struct {
		name    string
		resp    *corepb.GetRawTransactionResponse
		rpcErr  error
		wantErr string
	}{
		{
			name:    "a confirmed timestamp",
			resp:    &corepb.GetRawTransactionResponse{Confirmations: 1},
			wantErr: "mark timestamp 1 confirmed: ",
		},
		{
			name:    "an unknown transaction past the grace period",
			rpcErr:  errors.New("internal: -5: No such mempool or blockchain transaction."),
			wantErr: "mark timestamp 1 failed: ",
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			ctx := t.Context()
			db := database.Test(t)
			core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			engine := NewTimestampEngine(db, nil,
				service.New("bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
					return core, nil
				}),
				nil,
			)

			txid := "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
			_, err := timestamps.Create(ctx, db, timestamps.FileTimestamp{
				Filename:  "test.txt",
				FileHash:  "cafebabe",
				TxID:      &txid,
				Status:    timestamps.StatusConfirming,
				CreatedAt: time.Now().Add(-timestampFailureGrace - time.Hour),
			})
			require.NoError(t, err)
			_, err = db.ExecContext(ctx, `CREATE TRIGGER no_update BEFORE UPDATE ON file_timestamps
				BEGIN SELECT RAISE(ABORT, 'update refused'); END`)
			require.NoError(t, err)

			core.EXPECT().GetBlockchainInfo(gomock.Any(), gomock.Any()).
				Return(connect.NewResponse(&corepb.GetBlockchainInfoResponse{}), nil)
			var resp *connect.Response[corepb.GetRawTransactionResponse]
			if tc.resp != nil {
				resp = connect.NewResponse(tc.resp)
			}
			core.EXPECT().GetRawTransaction(gomock.Any(), gomock.Any()).Return(resp, tc.rpcErr)

			err = engine.checkConfirmations(ctx)
			require.ErrorContains(t, err, tc.wantErr)
			require.ErrorContains(t, err, "update refused")
		})
	}
}
