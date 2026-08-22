package wallet

import (
	"context"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// An M5 is an ordinary transaction on the wire, so the record has to come from
// the moment we broadcast it. The enforcer used to keep this list for us.
func TestSidechainDepositsRoundTrip(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "thunder-addr", AmountSats: 50_000,
	}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "bbb", WalletID: "w1", Slot: 5, Destination: "bitnames-addr", AmountSats: 10_000,
	}))

	got, err := svc.SidechainDeposits(ctx, 9)
	require.NoError(t, err)
	require.Len(t, got, 1, "a slot lists only its own deposits")
	assert.Equal(t, "aaa", got[0].Txid)
	assert.Equal(t, "thunder-addr", got[0].Destination)
	assert.Equal(t, int64(50_000), got[0].AmountSats)
	assert.False(t, got[0].CreatedAt.IsZero())

	empty, err := svc.SidechainDeposits(ctx, 3)
	require.NoError(t, err)
	assert.Empty(t, empty)
}

// A re-broadcast of the same deposit must not double the list.
func TestRecordSidechainDepositIsIdempotent(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	d := SidechainDeposit{Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr", AmountSats: 1}
	require.NoError(t, svc.RecordSidechainDeposit(ctx, d))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, d))

	got, err := svc.SidechainDeposits(ctx, 9)
	require.NoError(t, err)
	assert.Len(t, got, 1)
}
