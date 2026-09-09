package lightwallet

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

const depositTxid = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

func testBackend(t *testing.T, index *fakeIndex) *Backend {
	t.Helper()
	return NewBackend(sidechainesplora.New(index.server.URL), testWallet(testSeed),
		OutputShape{ValueKey: ValueKeyValue})
}

// A deposit is why a light install exists. It must read as one coin of the
// wallet, under the outpoint the mainchain gave it.
func TestBackendShowsADeposit(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, 0).String(), depositTxid, 21000, true)

	raw, err := testBackend(t, index).UTXOs(context.Background())
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}

	var rows []struct {
		Outpoint map[string]json.RawMessage `json:"outpoint"`
		Output   struct {
			Address string           `json:"address"`
			Content map[string]int64 `json:"content"`
		} `json:"output"`
		Confirmed bool `json:"confirmed"`
	}
	if err := json.Unmarshal(raw, &rows); err != nil {
		t.Fatalf("read the listing %s: %v", raw, err)
	}
	if len(rows) != 1 {
		t.Fatalf("the wallet holds %d coins, want 1", len(rows))
	}
	if got := string(rows[0].Outpoint["Deposit"]); got != `"`+depositTxid+`:0"` {
		t.Errorf("outpoint = %s, want the mainchain one", got)
	}
	if got := rows[0].Output.Address; got != testAddress(t, 0).String() {
		t.Errorf("address = %s, want the first derived one", got)
	}
	if got := rows[0].Output.Content[ValueKeyValue]; got != 21000 {
		t.Errorf("value = %d, want 21000", got)
	}
	if !rows[0].Confirmed {
		t.Error("a mined deposit reads as unconfirmed")
	}
}

// The balance is the other half of what a deposit must move.
func TestBackendSumsADeposit(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, 0).String(), depositTxid, 21000, true)
	index.deposit(testAddress(t, 1).String(), depositTxid, 9000, true)

	total, available, err := testBackend(t, index).Balance(context.Background())
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if total != 30000 || available != 30000 {
		t.Errorf("balance = %d total and %d available, want 30000 of each", total, available)
	}
}

// A deposit no block carries yet counts in the total and not in what the
// wallet can spend, so a payment on its way shows as pending and not as money
// already mined.
func TestBackendCountsAnUnconfirmedDepositApart(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, 0).String(), depositTxid, 21000, true)
	index.deposit(testAddress(t, 1).String(), depositTxid, 9000, false)

	backend := testBackend(t, index)
	total, available, err := backend.Balance(context.Background())
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if total != 30000 {
		t.Errorf("total = %d, want 30000", total)
	}
	if available != 21000 {
		t.Errorf("available = %d, want the mined deposit alone", available)
	}

	raw, err := backend.UTXOs(context.Background())
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	var rows []struct {
		Confirmed bool `json:"confirmed"`
	}
	if err := json.Unmarshal(raw, &rows); err != nil {
		t.Fatalf("read the listing: %v", err)
	}
	if len(rows) != 2 {
		t.Fatalf("the wallet holds %d coins, want 2", len(rows))
	}
	if !rows[0].Confirmed || rows[1].Confirmed {
		t.Errorf("the mined coin must come first and the waiting one after: %s", raw)
	}
}

// A wallet with no coins reads as empty rather than as an error, because that
// is what a fresh install is.
func TestBackendReadsAnEmptyWallet(t *testing.T) {
	backend := testBackend(t, newFakeIndex(t))
	total, available, err := backend.Balance(context.Background())
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if total != 0 || available != 0 {
		t.Errorf("balance = %d and %d, want nothing", total, available)
	}
	raw, err := backend.UTXOs(context.Background())
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	if string(raw) != "[]" {
		t.Errorf("utxos = %s, want an empty listing", raw)
	}
}

// A receive page shows the first address that took nothing. An address that
// took a deposit is used, so the next payment must not land on it again.
func TestBackendHandsOutAnUnusedAddress(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, 0).String(), depositTxid, 21000, true)

	address, err := testBackend(t, index).NewAddress(context.Background())
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	if want := testAddress(t, 1).String(); address != want {
		t.Errorf("address = %s, want %s", address, want)
	}
}

// Discovery carries one whole gap past the last used address, so a wallet that
// already ran a node still reads the coins of its later keys.
func TestBackendReadsPastAUsedAddress(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, 5).String(), depositTxid, 7000, true)
	index.deposit(testAddress(t, 5+gapLimit).String(), depositTxid, 3000, true)

	total, _, err := testBackend(t, index).Balance(context.Background())
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if total != 10000 {
		t.Errorf("total = %d, want both coins", total)
	}
}

// The walk stops one gap in, or a fresh wallet would cost one request for
// every key it could ever hold.
func TestBackendStopsAfterTheGap(t *testing.T) {
	index := newFakeIndex(t)
	index.deposit(testAddress(t, gapLimit+1).String(), depositTxid, 7000, true)

	addresses, err := testBackend(t, index).Addresses(context.Background())
	if err != nil {
		t.Fatalf("addresses: %v", err)
	}
	if len(addresses) != gapLimit {
		t.Errorf("the walk read %d addresses, want %d", len(addresses), gapLimit)
	}
}
