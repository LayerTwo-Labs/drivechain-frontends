package wallet

import (
	"context"
	"testing"
	"time"

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
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "thunder-addr", AmountSats: 50_000, FeeSats: 300,
	}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "bbb", WalletID: "w1", Slot: 5, Destination: "bitnames-addr", AmountSats: 10_000,
	}))

	got, err := svc.SidechainDeposits(ctx, 9, "")
	require.NoError(t, err)
	require.Len(t, got, 1, "a slot lists only its own deposits")
	assert.Equal(t, "aaa", got[0].Txid)
	assert.Equal(t, "thunder-addr", got[0].Destination)
	assert.Equal(t, int64(50_000), got[0].AmountSats)
	assert.Equal(t, int64(300), got[0].FeeSats)
	assert.False(t, got[0].CreatedAt.IsZero())

	empty, err := svc.SidechainDeposits(ctx, 3, "")
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

	got, err := svc.SidechainDeposits(ctx, 9, "")
	require.NoError(t, err)
	assert.Len(t, got, 1)
}

// A network swap between the broadcast and the insert must not move the row to
// the chain we swapped to, where the deposit never happened.
func TestRecordSidechainDepositKeepsBroadcastNetwork(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("regtest")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Network: "signet", Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr", AmountSats: 50_000,
	}))

	none, err := svc.SidechainDeposits(ctx, 9, "")
	require.NoError(t, err)
	assert.Empty(t, none, "regtest never saw this deposit")

	require.NoError(t, svc.RebindNetwork("signet"))
	got, err := svc.SidechainDeposits(ctx, 9, "")
	require.NoError(t, err)
	require.Len(t, got, 1)
	assert.Equal(t, "aaa", got[0].Txid)
}

// The table records a wallet id per row, so a caller naming one must not see
// another wallet's deposits.
func TestSidechainDepositsFilterByWallet(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "bbb", WalletID: "w2", Slot: 9, Destination: "addr-2", AmountSats: 10_000,
	}))

	mine, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	require.Len(t, mine, 1)
	assert.Equal(t, "aaa", mine[0].Txid)

	all, err := svc.SidechainDeposits(ctx, 9, "")
	require.NoError(t, err)
	assert.Len(t, all, 2, "an empty wallet id lists every wallet")
}

// The wallet overview reports deposit volume, which nothing else knows now.
func TestSidechainDepositTotals(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "bbb", WalletID: "w1", Slot: 5, Destination: "addr-2", AmountSats: 10_000,
	}))

	total, recent, err := svc.SidechainDepositTotals(ctx, time.Now().Add(-30*24*time.Hour), "")
	require.NoError(t, err)
	assert.Equal(t, int64(60_000), total)
	assert.Equal(t, int64(60_000), recent, "both rows land inside the window")

	_, none, err := svc.SidechainDepositTotals(ctx, time.Now().Add(time.Hour), "")
	require.NoError(t, err)
	assert.Zero(t, none, "a window that starts in the future holds nothing")
}

// The wallet overview shows one wallet's numbers, so a total that sums every
// wallet would report another wallet's deposits as this one's.
func TestSidechainDepositTotalsFilterByWallet(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "bbb", WalletID: "w2", Slot: 9, Destination: "addr-2", AmountSats: 10_000,
	}))

	since := time.Now().Add(-time.Hour)
	total, recent, err := svc.SidechainDepositTotals(ctx, since, "w1")
	require.NoError(t, err)
	assert.Equal(t, int64(50_000), total, "w2's deposit is not w1's volume")
	assert.Equal(t, int64(50_000), recent)

	all, _, err := svc.SidechainDepositTotals(ctx, since, "")
	require.NoError(t, err)
	assert.Equal(t, int64(60_000), all)
}
