package wallet

import (
	"context"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A fresh deposit carries no credit stamp, and the stamp lands on the one
// deposit named. The balance path counts every unstamped deposit, so a stamp
// on the wrong row hides money the sidechain still owes.
func TestMarkSidechainDepositCredited(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "bbb", WalletID: "w1", Slot: 9, Destination: "addr-2", AmountSats: 10_000,
	}))

	fresh, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	require.Len(t, fresh, 2)
	for _, d := range fresh {
		assert.True(t, d.CreditedAt.IsZero(), "a fresh deposit carries no credit stamp")
	}

	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "aaa"))

	stamped, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	byTxid := map[string]SidechainDeposit{}
	for _, d := range stamped {
		byTxid[d.Txid] = d
	}
	assert.False(t, byTxid["aaa"].CreditedAt.IsZero(), "the named deposit carries the stamp")
	assert.True(t, byTxid["bbb"].CreditedAt.IsZero(), "the other deposit keeps none")
}

// The stamp says the sidechain credited the coins. A second call must not move
// it, because the first moment is the one the balance path reads.
func TestMarkSidechainDepositCreditedKeepsTheFirstStamp(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "aaa"))

	first, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	require.Len(t, first, 1)

	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "aaa"))

	second, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	require.Len(t, second, 1)
	assert.Equal(t, first[0].CreditedAt, second[0].CreditedAt)
}

// Rows are keyed by network. A stamp written on one network must leave the
// other network's deposit pending.
func TestMarkSidechainDepositCreditedIsScopedToTheNetwork(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.RebindNetwork("regtest"))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{
		Txid: "aaa", WalletID: "w1", Slot: 9, Destination: "addr-1", AmountSats: 50_000,
	}))
	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "aaa"))

	regtest, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	require.Len(t, regtest, 1)
	assert.False(t, regtest[0].CreditedAt.IsZero())

	require.NoError(t, svc.RebindNetwork("signet"))
	signet, err := svc.SidechainDeposits(ctx, 9, "w1")
	require.NoError(t, err)
	require.Len(t, signet, 1)
	assert.True(t, signet[0].CreditedAt.IsZero(), "the other network keeps its deposit pending")
}

// A dropped attempt moved no coin, and the retry adds its own row, so counting
// it would inflate the volume and double-count the same deposit.
func TestSidechainDepositTotalsSkipADroppedAttempt(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "kept", WalletID: "w", Slot: 2, AmountSats: 1000}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "lost", WalletID: "w", Slot: 2, AmountSats: 7000}))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "lost"))

	total, _, err := svc.SidechainDepositTotals(ctx, time.Unix(0, 0), "")
	require.NoError(t, err)
	require.Equal(t, int64(1000), total)
}

// A deposit that turns up again counts again.
func TestClearSidechainDepositDropRestoresTheTotal(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "back", WalletID: "w", Slot: 2, AmountSats: 500}))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "back"))
	require.NoError(t, svc.ClearSidechainDepositDrop(ctx, "back"))

	total, _, err := svc.SidechainDepositTotals(ctx, time.Unix(0, 0), "")
	require.NoError(t, err)
	require.Equal(t, int64(500), total)
}

// The sidechain already took the coin, so a late drop must not erase it.
func TestMarkSidechainDepositDroppedSkipsACreditedDeposit(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "done", WalletID: "w", Slot: 2, AmountSats: 900}))
	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "done"))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "done"))

	deposits, err := svc.SidechainDeposits(ctx, 2, "")
	require.NoError(t, err)
	require.Len(t, deposits, 1)
	require.True(t, deposits[0].DroppedAt.IsZero(), "a credited deposit must never read as dropped")
}

// A fee bump gives the deposit a new txid. Without the move, the watch reads
// the old row as a deposit the network lost and asks for the money again.
func TestRepointSidechainDepositFollowsAFeeBump(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "slow", WalletID: "w", Slot: 2, AmountSats: 4000}))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "slow"))
	require.NoError(t, svc.RepointSidechainDeposit(ctx, "slow", "bumped", 900))

	deposits, err := svc.SidechainDeposits(ctx, 2, "")
	require.NoError(t, err)
	require.Len(t, deposits, 1)
	require.Equal(t, "bumped", deposits[0].Txid)
	require.True(t, deposits[0].DroppedAt.IsZero(), "the replacement carries the money, so the drop stamp must go")
	require.Equal(t, int64(4000), deposits[0].AmountSats)
	require.Equal(t, int64(900), deposits[0].FeeSats, "the bump raised the fee the user pays")
}

// A bump of an ordinary send touches no deposit row.
func TestRepointSidechainDepositLeavesOtherRowsAlone(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "kept", WalletID: "w", Slot: 2, AmountSats: 100}))
	require.NoError(t, svc.RepointSidechainDeposit(ctx, "an-ordinary-send", "its-replacement", 100))

	deposits, err := svc.SidechainDeposits(ctx, 2, "")
	require.NoError(t, err)
	require.Len(t, deposits, 1)
	require.Equal(t, "kept", deposits[0].Txid)
}

// The drop watch and the credit read race, so a deposit can carry a stamp the
// sidechain just disproved. The coin arrived, so the stamp must go, or the row
// reads as dropped for ever and tells the user to deposit again.
func TestMarkSidechainDepositCreditedClearsTheDropStamp(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "raced", WalletID: "w", Slot: 2, AmountSats: 300}))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "raced"))
	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "raced"))

	deposits, err := svc.SidechainDeposits(ctx, 2, "")
	require.NoError(t, err)
	require.Len(t, deposits, 1)
	require.False(t, deposits[0].CreditedAt.IsZero())
	require.True(t, deposits[0].DroppedAt.IsZero(), "a credited deposit cannot also read as dropped")
}

// The watch reads the slots from the deposits, so a slot with no local binary
// still gets watched. A credited slot needs no watch.
func TestSidechainDepositSlotsListsTheOpenOnes(t *testing.T) {
	ctx := context.Background()
	svc := NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "a", WalletID: "w", Slot: 7, AmountSats: 1}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "b", WalletID: "w", Slot: 7, AmountSats: 1}))
	require.NoError(t, svc.RecordSidechainDeposit(ctx, SidechainDeposit{Txid: "c", WalletID: "w", Slot: 42, AmountSats: 1}))
	require.NoError(t, svc.MarkSidechainDepositCredited(ctx, "c"))

	slots, err := svc.SidechainDepositSlots(ctx)
	require.NoError(t, err)
	require.Equal(t, []uint32{7}, slots)
}
