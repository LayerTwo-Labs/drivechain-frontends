package thunderwallet

import (
	"context"
	"crypto/ed25519"
	"errors"
	"testing"
)

// stubCoins answers with a fixed coin set.
type stubCoins struct{ coins []Coin }

func (s *stubCoins) Coins(context.Context, []Address) ([]Coin, error) {
	return s.coins, nil
}

// captureBroadcast keeps what the wallet sent, so a test reads it back.
type captureBroadcast struct{ sent *AuthorizedTransaction }

func (c *captureBroadcast) Broadcast(_ context.Context, tx AuthorizedTransaction) (Hash, error) {
	c.sent = &tx
	return tx.Transaction.Txid()
}

func coin(address Address, sats uint64, vout uint32) Coin {
	return Coin{
		OutPoint:  OutPoint{Kind: KindRegular, Vout: vout},
		Address:   address,
		ValueSats: sats,
	}
}

func testWallet(t *testing.T, sats ...uint64) (*Wallet, Address, *captureBroadcast) {
	t.Helper()
	ring := NewMemoryKeyring(testKey(t, 5))
	address := ring.Addresses()[0]
	coins := make([]Coin, 0, len(sats))
	for i, value := range sats {
		coins = append(coins, coin(address, value, uint32(i)))
	}
	sent := &captureBroadcast{}
	return New(&stubCoins{coins: coins}, ring, sent), address, sent
}

// A send pays the recipient, keeps the change, and leaves the fee behind.
func TestSendPaysAndKeepsChange(t *testing.T) {
	wallet, address, sent := testWallet(t, 10000)
	recipient := AddressForKey(testKey(t, 6).Public().(ed25519.PublicKey))

	if _, err := wallet.Send(context.Background(), []Address{address},
		[]Recipient{{Address: recipient, ValueSats: 6000}}, 500, address); err != nil {
		t.Fatalf("send: %v", err)
	}

	tx := sent.sent.Transaction
	if len(tx.Outputs) != 2 {
		t.Fatalf("got %d outputs, want a payment and change", len(tx.Outputs))
	}
	if *tx.Outputs[0].Content.Value != 6000 || tx.Outputs[0].Address != recipient {
		t.Errorf("payment = %+v", tx.Outputs[0])
	}
	// 10000 in, 6000 out, 500 fee, so 3500 comes back.
	if *tx.Outputs[1].Content.Value != 3500 || tx.Outputs[1].Address != address {
		t.Errorf("change = %+v", tx.Outputs[1])
	}
	if err := Verify(*sent.sent); err != nil {
		t.Errorf("the wallet sent a transaction it cannot verify: %v", err)
	}
}

// An exact amount writes no change output, so the wallet leaves no dust.
func TestSendWithNoChange(t *testing.T) {
	wallet, address, sent := testWallet(t, 5000)
	recipient := AddressForKey(testKey(t, 6).Public().(ed25519.PublicKey))

	if _, err := wallet.Send(context.Background(), []Address{address},
		[]Recipient{{Address: recipient, ValueSats: 4900}}, 100, address); err != nil {
		t.Fatalf("send: %v", err)
	}
	if got := len(sent.sent.Transaction.Outputs); got != 1 {
		t.Errorf("got %d outputs, want only the payment", got)
	}
}

// A wallet that holds too little says so, and sends nothing.
func TestSendWithoutEnoughValue(t *testing.T) {
	wallet, address, sent := testWallet(t, 1000)
	recipient := AddressForKey(testKey(t, 6).Public().(ed25519.PublicKey))

	_, err := wallet.Send(context.Background(), []Address{address},
		[]Recipient{{Address: recipient, ValueSats: 5000}}, 100, address)
	if !errors.Is(err, ErrNotEnoughValue) {
		t.Fatalf("error = %v, want ErrNotEnoughValue", err)
	}
	if sent.sent != nil {
		t.Error("the wallet broadcast a transaction it could not fund")
	}
}

// A withdrawal costs its payout plus its mainchain fee, because the enforcer
// pays both out of the treasury. Charging only the payout overdraws the wallet.
func TestWithdrawCountsTheMainchainFee(t *testing.T) {
	wallet, address, sent := testWallet(t, 10000)

	if _, err := wallet.Withdraw(context.Background(), []Address{address},
		WithdrawalRequest{
			MainScriptPubKey: []byte{0x00, 0x14},
			MainAddress:      "tb1qexample",
			ValueSats:        5000,
			MainFeeSats:      1000,
		}, 200, address); err != nil {
		t.Fatalf("withdraw: %v", err)
	}

	tx := sent.sent.Transaction
	withdrawal := tx.Outputs[0].Content.Withdrawal
	if withdrawal == nil {
		t.Fatalf("first output = %+v, want a withdrawal", tx.Outputs[0])
	}
	if withdrawal.ValueSats != 5000 || withdrawal.MainFeeSats != 1000 {
		t.Errorf("withdrawal = %+v", withdrawal)
	}
	// 10000 in, 6000 withdrawn, 200 fee, so 3800 comes back.
	if got := *tx.Outputs[1].Content.Value; got != 3800 {
		t.Errorf("change = %d, want 3800", got)
	}
}

func TestWithdrawNeedsAMainchainScript(t *testing.T) {
	wallet, address, _ := testWallet(t, 10000)
	_, err := wallet.Withdraw(context.Background(), []Address{address},
		WithdrawalRequest{ValueSats: 1000}, 100, address)
	if err == nil {
		t.Fatal("want an error with no mainchain script, got none")
	}
}

// Largest first keeps the input count low, which keeps the transaction small.
func TestSelectCoinsTakesTheLargestFirst(t *testing.T) {
	var address Address
	available := []Coin{
		coin(address, 100, 0), coin(address, 9000, 1), coin(address, 500, 2),
	}
	selected, gathered, err := SelectCoins(available, 5000)
	if err != nil {
		t.Fatalf("select: %v", err)
	}
	if len(selected) != 1 || selected[0].ValueSats != 9000 || gathered != 9000 {
		t.Errorf("selected %+v gathering %d, want the one 9000 coin", selected, gathered)
	}
}

func TestSelectCoinsCombinesWhenNeeded(t *testing.T) {
	var address Address
	available := []Coin{coin(address, 3000, 0), coin(address, 3000, 1)}
	selected, gathered, err := SelectCoins(available, 5000)
	if err != nil {
		t.Fatalf("select: %v", err)
	}
	if len(selected) != 2 || gathered != 6000 {
		t.Errorf("selected %d coins gathering %d, want 2 and 6000", len(selected), gathered)
	}
}
