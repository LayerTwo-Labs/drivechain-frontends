package wallet

import (
	"context"
	"testing"

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
