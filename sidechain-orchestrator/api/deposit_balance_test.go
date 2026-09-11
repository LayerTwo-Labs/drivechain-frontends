package api

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// The sidechain names a deposit coin after the mainchain outpoint that paid
// it. Anything else in the listing belongs to another payment.
func TestHoldsDepositCoin(t *testing.T) {
	const txid = "280a3c6e7e5c6f272e43df3aaece690c94d50b321d24f55f1e46abe8124e7cc3"
	coins := map[string]int64{
		txid + ":0":       1_000_000,
		"sidechaintx:1":   4000,
		"anothermain:0":   7000,
		"280a3c6e7e5c6f2": 1,
	}
	assert.True(t, holdsDepositCoin(coins, txid))
	assert.False(t, holdsDepositCoin(coins, "notadeposit"))
	assert.False(t, holdsDepositCoin(map[string]int64{}, txid))
}

// A deposit lands in exactly one count: the pending sum while the sidechain
// holds no coin for it, and the confirmed balance once it does.
func TestSplitCreditedDeposits(t *testing.T) {
	owned := map[string]bool{"mine": true, "mine-two": true}

	for _, tc := range []struct {
		name         string
		deposits     []wallet.SidechainDeposit
		coins        map[string]int64
		spent        map[string]int64
		wantPending  int64
		wantCredited []string
	}{
		{
			name:        "a deposit the sidechain has not seen is pending",
			deposits:    []wallet.SidechainDeposit{{Txid: "m1", Destination: "mine", AmountSats: 1_000_000}},
			coins:       map[string]int64{},
			wantPending: 1_000_000,
		},
		{
			name:         "the same deposit stops counting once the coin lands",
			deposits:     []wallet.SidechainDeposit{{Txid: "m1", Destination: "mine", AmountSats: 1_000_000}},
			coins:        map[string]int64{"m1:0": 1_000_000},
			wantPending:  0,
			wantCredited: []string{"m1"},
		},
		{
			name:         "a deposit the wallet spent is credited",
			deposits:     []wallet.SidechainDeposit{{Txid: "m1", Destination: "mine", AmountSats: 1_000_000}},
			coins:        map[string]int64{"sidechaintx:0": 500_000, "sidechaintx:1": 499_000},
			spent:        map[string]int64{"m1:0": 1_000_000},
			wantPending:  0,
			wantCredited: []string{"m1"},
		},
		{
			name: "one deposit of two lands, and only the other stays pending",
			deposits: []wallet.SidechainDeposit{
				{Txid: "m1", Destination: "mine", AmountSats: 1_000_000},
				{Txid: "m2", Destination: "mine-two", AmountSats: 250_000},
			},
			coins:        map[string]int64{"m1:0": 1_000_000},
			wantPending:  250_000,
			wantCredited: []string{"m1"},
		},
		{
			// The deposit page hands out one address, so a second deposit
			// pays the address a credited one already holds a coin at.
			name: "a second deposit to the same address stays pending",
			deposits: []wallet.SidechainDeposit{
				{Txid: "m1", Destination: "mine", AmountSats: 1_000_000},
				{Txid: "m2", Destination: "mine", AmountSats: 250_000},
			},
			coins:        map[string]int64{"m1:0": 1_000_000},
			wantPending:  250_000,
			wantCredited: []string{"m1"},
		},
		{
			name:        "a deposit to somebody else's address is nobody's pending balance",
			deposits:    []wallet.SidechainDeposit{{Txid: "m1", Destination: "theirs", AmountSats: 1_000_000}},
			coins:       map[string]int64{},
			wantPending: 0,
		},
		{
			name:        "a sidechain coin of our own leaves the deposit pending",
			deposits:    []wallet.SidechainDeposit{{Txid: "m1", Destination: "mine", AmountSats: 1_000_000}},
			coins:       map[string]int64{"sidechaintx:0": 5000},
			wantPending: 1_000_000,
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			pending, credited := splitCreditedDeposits(tc.deposits, owned, tc.coins, tc.spent)
			assert.Equal(t, tc.wantPending, pending)
			assert.Equal(t, tc.wantCredited, credited)
		})
	}
}
