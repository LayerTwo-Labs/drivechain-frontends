package thunderwallet

import (
	"context"
	"sync"
	"testing"
	"time"
)

// listCoins stands in for an index that lags what the wallet spends.
type listCoins struct{ coins []Coin }

func (l *listCoins) Coins(context.Context, []Address) ([]Coin, error) { return l.coins, nil }

func coinAt(vout uint32, sats uint64) Coin {
	return Coin{OutPoint: OutPoint{Kind: KindRegular, Vout: vout}, ValueSats: sats}
}

// An index keeps offering a spent coin until it syncs. A second send that
// picked it again would be a conflict the node refuses.
func TestReservedCoinsHidesASpentCoin(t *testing.T) {
	source := &ReservedCoins{
		source: &listCoins{[]Coin{coinAt(0, 1000), coinAt(1, 2000)}},
		spent:  map[OutPoint]time.Time{},
		change: map[OutPoint]pendingCoin{},
	}

	before, err := source.Coins(context.Background(), nil)
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(before) != 2 {
		t.Fatalf("read %d coins, want 2", len(before))
	}

	source.Reserve([]OutPoint{{Kind: KindRegular, Vout: 0}}, nil)

	after, err := source.Coins(context.Background(), nil)
	if err != nil {
		t.Fatalf("coins after the spend: %v", err)
	}
	if len(after) != 1 || after[0].OutPoint.Vout != 1 {
		t.Errorf("read %+v, want only the coin that is still unspent", after)
	}
}

// A wallet whose source reserves must tell it what each broadcast spent.
func TestWalletReservesWhatItSpends(t *testing.T) {
	key, err := DeriveKey(make([]byte, 32), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	ring := NewMemoryKeyring(key)
	mine := ring.Addresses()[0]

	coin := coinAt(0, 100_000)
	coin.Address = mine
	source := NewReservedCoins(&listCoins{[]Coin{coin}})
	wallet := New(source, ring, &countingBroadcaster{})

	if _, err := wallet.Send(context.Background(), []Address{mine},
		[]Recipient{{Address: mine, ValueSats: 1000}}, 100, mine); err != nil {
		t.Fatalf("send: %v", err)
	}

	left, err := source.Coins(context.Background(), nil)
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(left) != 0 {
		t.Errorf("the source still offers %d spent coins", len(left))
	}
}

// countingBroadcaster accepts anything and answers one txid.
type countingBroadcaster struct{ calls int }

func (b *countingBroadcaster) Broadcast(context.Context, AuthorizedTransaction) (Hash, error) {
	b.calls++
	return Hash{1}, nil
}

// Two sends at the same time must never spend one coin twice. The node would
// refuse the second as a conflict, and one honest request would fail.
func TestWalletSpendsOneCoinOnce(t *testing.T) {
	key, err := DeriveKey(make([]byte, 32), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	ring := NewMemoryKeyring(key)
	mine := ring.Addresses()[0]

	coin := coinAt(0, 100_000)
	coin.Address = mine
	source := NewReservedCoins(&listCoins{[]Coin{coin}})
	broadcaster := &recordingBroadcaster{}
	wallet := New(source, ring, broadcaster)

	var wg sync.WaitGroup
	for range 4 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			_, _ = wallet.Send(context.Background(), []Address{mine},
				[]Recipient{{Address: mine, ValueSats: 1000}}, 100, mine)
		}()
	}
	wg.Wait()

	spent := make(map[OutPoint]int)
	for _, tx := range broadcaster.sent {
		for _, in := range tx.Transaction.Inputs {
			spent[in.OutPoint]++
		}
	}
	for outpoint, count := range spent {
		if count > 1 {
			t.Errorf("%d transactions spend the coin at vout %d, want 1",
				count, outpoint.Vout)
		}
	}
	if len(broadcaster.sent) == 0 {
		t.Error("no send went through")
	}
}

// A send makes change the index has not seen yet. A second send must still
// find that money, rather than read the wallet as empty.
func TestChangeSpendsBeforeTheIndexCatchesUp(t *testing.T) {
	key, err := DeriveKey(make([]byte, 32), 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	ring := NewMemoryKeyring(key)
	mine := ring.Addresses()[0]

	coin := coinAt(0, 100_000)
	coin.Address = mine
	// The index never learns anything, which is the worst lag there is.
	source := NewReservedCoins(&listCoins{[]Coin{coin}})
	wallet := New(source, ring, &recordingBroadcaster{})

	for i := range 3 {
		if _, err := wallet.Send(context.Background(), []Address{mine},
			[]Recipient{{Address: mine, ValueSats: 1000}}, 100, mine); err != nil {
			t.Fatalf("send %d: %v", i+1, err)
		}
	}
}

// recordingBroadcaster keeps every transaction it accepts.
type recordingBroadcaster struct {
	mu   sync.Mutex
	sent []AuthorizedTransaction
}

func (b *recordingBroadcaster) Broadcast(
	_ context.Context, tx AuthorizedTransaction,
) (Hash, error) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.sent = append(b.sent, tx)
	var out Hash
	out[0] = byte(len(b.sent))
	return out, nil
}

// The index lags a broadcast by one pass. A wallet read must still drop the
// coin the wallet spent, and must still carry the change it made.
func TestReservedCoinsAdjustsBothHalves(t *testing.T) {
	var mine Address
	mine[0] = 0x11

	spent := coinAt(0, 5000)
	spent.Address = mine
	change := coinAt(1, 4000)
	change.Address = mine

	source := NewReservedCoins(&listCoins{})
	source.Reserve([]OutPoint{spent.OutPoint}, []Coin{change})

	confirmed, pending := source.Adjust([]Address{mine}, []Coin{spent}, nil)
	if len(confirmed) != 0 {
		t.Errorf("the spent coin is still spendable: %+v", confirmed)
	}
	if len(pending) != 1 || pending[0].OutPoint != change.OutPoint {
		t.Fatalf("pending = %+v, want the change alone", pending)
	}
}

// The index reads the change one pass later. The wallet holds it too, and
// counting it twice doubles a balance.
func TestReservedCoinsAdjustsTheChangeOneTime(t *testing.T) {
	var mine Address
	mine[0] = 0x11

	change := coinAt(1, 4000)
	change.Address = mine

	source := NewReservedCoins(&listCoins{})
	source.Reserve(nil, []Coin{change})

	confirmed, pending := source.Adjust([]Address{mine}, nil, []Coin{change})
	if len(confirmed) != 0 {
		t.Errorf("confirmed = %+v, want nothing a block carries", confirmed)
	}
	if len(pending) != 1 {
		t.Errorf("pending holds %d coins, want the change one time", len(pending))
	}
}

// Change for another wallet's address belongs to that wallet, not this one.
func TestReservedCoinsAdjustsOnlyTheAddressesItReads(t *testing.T) {
	var mine, theirs Address
	mine[0] = 0x11
	theirs[0] = 0x22

	payment := coinAt(0, 7000)
	payment.Address = theirs

	source := NewReservedCoins(&listCoins{})
	source.Reserve(nil, []Coin{payment})

	confirmed, pending := source.Adjust([]Address{mine}, nil, nil)
	if len(confirmed) != 0 || len(pending) != 0 {
		t.Errorf("read %+v and %+v, want nothing", confirmed, pending)
	}
}
