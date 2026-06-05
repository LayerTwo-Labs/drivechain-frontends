package fork

import (
	"context"
	"testing"
)

type fakeTip struct{ tip Tip }

func (f fakeTip) ForkTip(context.Context) (Tip, error) { return f.tip, nil }

type fakeWallets struct {
	meta  []WalletMeta
	utxos map[string][]Utxo
}

func (f fakeWallets) Wallets() []WalletMeta { return f.meta }
func (f fakeWallets) Unspent(_ context.Context, id string, _ int) ([]Utxo, error) {
	return f.utxos[id], nil
}

// one wallet "w" holding a single spendable UTXO confirmed at the given height.
func walletsAt(height int) fakeWallets {
	return fakeWallets{
		meta: []WalletMeta{{ID: "w", Name: "Main", ReplayProtectable: true}},
		utxos: map[string][]Utxo{
			"w": {{Outpoint: "tx:0", Address: "addr", Sats: 1000, Height: height, Spendable: true}},
		},
	}
}

func state(t *testing.T, tip Tip, w WalletScanner) *ForkState {
	t.Helper()
	st, err := NewEngine(fakeTip{tip}, w, 0).State(context.Background())
	if err != nil {
		t.Fatalf("State: %v", err)
	}
	return st
}

func TestSignetSimulatesRecurringFork(t *testing.T) {
	// tip just past the 288 boundary; a coin confirmed at 286 <= 288 is claimable.
	st := state(t, Tip{Chain: "signet", Blocks: 290, Headers: 290}, walletsAt(286))
	if !st.Simulated {
		t.Fatal("signet must be simulated")
	}
	if st.ClaimBoundary != 288 || st.ForkHeight != 432 {
		t.Fatalf("boundaries: claim=%d fork=%d, want 288/432", st.ClaimBoundary, st.ForkHeight)
	}
	if !st.HasFundsToClaim {
		t.Fatal("pre-boundary coin should be claimable")
	}
	// Claim-before-countdown: unclaimed coins hide the countdown.
	if st.ShowCountdown {
		t.Fatal("countdown must be hidden while coins are unclaimed")
	}
}

func TestSignetCountdownShowsOnceClaimed(t *testing.T) {
	// Same tip, but the only coin is post-boundary (height 290 > 288), so
	// nothing is claimable and the countdown to the next fork shows.
	st := state(t, Tip{Chain: "signet", Blocks: 290, Headers: 290}, walletsAt(290))
	if st.HasFundsToClaim {
		t.Fatal("post-boundary coin must not be claimable")
	}
	if !st.ShowCountdown {
		t.Fatal("countdown should show once nothing is claimable")
	}
}

func TestFixedHeightNoClaimsBeforeFork(t *testing.T) {
	// regtest forks at 400; at height 100 the fork hasn't happened, so no claims.
	st := state(t, Tip{Chain: "regtest", Blocks: 100, Headers: 100}, walletsAt(51))
	if st.Simulated || st.ForkHeight != 400 || st.ClaimBoundary != 400 {
		t.Fatalf("regtest fixed: sim=%v fork=%d claim=%d", st.Simulated, st.ForkHeight, st.ClaimBoundary)
	}
	if st.HasFundsToClaim {
		t.Fatal("no claims before the fork height is reached")
	}
	if !st.ShowCountdown {
		t.Fatal("countdown should show before the fork")
	}
}

func TestFixedHeightClaimsAfterFork(t *testing.T) {
	// past height 400, a coin confirmed at 391 <= 400 is claimable, countdown gone.
	st := state(t, Tip{Chain: "regtest", Blocks: 410, Headers: 410}, walletsAt(391))
	if !st.HasFundsToClaim {
		t.Fatal("coin confirmed at height 391 <= 400 should be claimable")
	}
	if st.ShowCountdown {
		t.Fatal("no countdown after a fixed-height fork")
	}
	if len(st.Claims) != 1 || st.Claims[0].ClaimableSats != 1000 {
		t.Fatalf("claims: %+v", st.Claims)
	}
}
