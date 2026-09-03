package thunder

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	bip39 "github.com/tyler-smith/go-bip39"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	tw "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

const testMnemonic = "abandon abandon abandon abandon abandon abandon " +
	"abandon abandon abandon abandon abandon about"

// fakeIndex serves the Esplora routes a light wallet reads, and records every
// broadcast so a test reads what the wallet signed.
type fakeIndex struct {
	mu        sync.Mutex
	utxos     map[string]string
	funded    map[string]bool
	broadcast []json.RawMessage
	server    *httptest.Server
}

func newFakeIndex(t *testing.T) *fakeIndex {
	t.Helper()
	f := &fakeIndex{
		utxos:  make(map[string]string),
		funded: make(map[string]bool),
	}
	f.server = httptest.NewServer(http.HandlerFunc(f.serve))
	t.Cleanup(f.server.Close)
	return f
}

// fund gives one address a spendable coin.
func (f *fakeIndex) fund(address, txid string, valueSats int64) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.utxos[address] = `[{"txid":"` + txid + `","vout":0,"value":` +
		itoa(valueSats) + `,"outpoint_kind":"regular",
		"status":{"confirmed":true,"block_height":1,"block_time":1}}]`
	f.funded[address] = true
}

// fundPending gives one address a coin no block carries yet.
func (f *fakeIndex) fundPending(address, txid string, valueSats int64) {
	f.fundPendingAt(address, txid, 0, valueSats)
}

func (f *fakeIndex) fundPendingAt(address, txid string, vout, valueSats int64) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.utxos[address] = `[{"txid":"` + txid + `","vout":` + itoa(vout) + `,"value":` +
		itoa(valueSats) + `,"outpoint_kind":"regular","content_type":"value",
		"status":{"confirmed":false,"block_height":null,"block_time":null}}]`
	f.funded[address] = true
}

// spend takes one address back to holding nothing, the way the index answers
// once a transaction takes the coin.
func (f *fakeIndex) spend(address string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.utxos[address] = "[]"
}

func (f *fakeIndex) submitted() []json.RawMessage {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]json.RawMessage(nil), f.broadcast...)
}

func (f *fakeIndex) serve(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()

	if r.Method == http.MethodPost && r.URL.Path == "/tx" {
		body, _ := io.ReadAll(r.Body)
		f.broadcast = append(f.broadcast, json.RawMessage(body))
		_, _ = io.WriteString(w, strings.Repeat("ab", 32))
		return
	}

	path := strings.TrimPrefix(r.URL.Path, "/address/")
	switch {
	case strings.HasSuffix(path, "/utxo"):
		address := strings.TrimSuffix(path, "/utxo")
		if rows, ok := f.utxos[address]; ok {
			_, _ = io.WriteString(w, rows)
			return
		}
		_, _ = io.WriteString(w, "[]")

	case strings.HasSuffix(path, "/deposits"):
		_, _ = io.WriteString(w, "[]")

	case !strings.Contains(path, "/"):
		count := 0
		if f.funded[path] {
			count = 1
		}
		_, _ = io.WriteString(w, `{"address":"`+path+`",
			"chain_stats":{"funded_txo_count":`+itoa(int64(count))+`,
			"funded_txo_sum":0,"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0},
			"mempool_stats":{"funded_txo_count":0,"funded_txo_sum":0,
			"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0}}`)

	default:
		_, _ = io.WriteString(w, "[]")
	}
}

func itoa(v int64) string {
	if v == 0 {
		return "0"
	}
	var digits []byte
	for v > 0 {
		digits = append([]byte{byte('0' + v%10)}, digits...)
		v /= 10
	}
	return string(digits)
}

// lightHandler builds a handler with no node at all: port 1 accepts nothing.
func lightHandler(t *testing.T, index *fakeIndex) (*Handler, []tw.Address) {
	t.Helper()
	seed := bip39.NewSeed(testMnemonic, "")
	ring, err := tw.DeriveKeyring(seed, lightAddressWindow)
	if err != nil {
		t.Fatalf("derive the keyring: %v", err)
	}
	h := NewHandlerWithSeed(sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() Mode {
			return Mode{IndexURL: index.server.URL, Params: &chaincfg.RegressionNetParams}
		},
		func() ([]byte, error) { return seed, nil },
	)
	return h, ring.Addresses()
}

// Light mode runs no thunder binary, so the balance comes from the index.
func TestLightBalanceWithNoNode(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 7000)

	resp, err := h.GetBalance(context.Background(),
		connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if resp.Msg.TotalSats != 7000 || resp.Msg.AvailableSats != 7000 {
		t.Errorf("balance = %d total, %d available, want 7000 and 7000",
			resp.Msg.TotalSats, resp.Msg.AvailableSats)
	}
}

// A receive address must come from the seed, and must be one that received
// nothing yet.
func TestLightNewAddressSkipsAUsedOne(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 7000)

	resp, err := h.GetNewAddress(context.Background(),
		connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	if resp.Msg.Address != addresses[1].String() {
		t.Errorf("address = %q, want the first unused one %q",
			resp.Msg.Address, addresses[1])
	}
}

// The UTXO list must read the same in both modes, so one parser serves both.
func TestLightUTXOsReadLikeTheNode(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 4200)

	resp, err := h.GetWalletUtxos(context.Background(),
		connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}

	var rows []struct {
		OutPoint struct {
			Regular *struct {
				Txid string `json:"txid"`
				Vout uint32 `json:"vout"`
			} `json:"Regular"`
		} `json:"outpoint"`
		Output struct {
			Address string `json:"address"`
			Content struct {
				Value uint64 `json:"Value"`
			} `json:"content"`
		} `json:"output"`
	}
	if err := json.Unmarshal([]byte(resp.Msg.UtxosJson), &rows); err != nil {
		t.Fatalf("read the utxo json %s: %v", resp.Msg.UtxosJson, err)
	}
	if len(rows) != 1 {
		t.Fatalf("got %d utxos, want 1", len(rows))
	}
	if rows[0].OutPoint.Regular == nil {
		t.Fatal("the outpoint names no Regular variant")
	}
	if rows[0].Output.Address != addresses[0].String() || rows[0].Output.Content.Value != 4200 {
		t.Errorf("utxo = %+v", rows[0])
	}
}

// A send must sign in this process and reach the index, because no node runs.
func TestLightTransferBroadcastsThroughTheIndex(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 10000)

	resp, err := h.Transfer(context.Background(), connect.NewRequest(&pb.TransferRequest{
		Address:    addresses[5].String(),
		AmountSats: 4000,
		FeeSats:    500,
	}))
	if err != nil {
		t.Fatalf("transfer: %v", err)
	}
	if resp.Msg.Txid != strings.Repeat("ab", 32) {
		t.Errorf("txid = %q", resp.Msg.Txid)
	}

	sent := index.submitted()
	if len(sent) != 1 {
		t.Fatalf("the index got %d transactions, want 1", len(sent))
	}
	var signed struct {
		Transaction struct {
			Inputs  []json.RawMessage `json:"inputs"`
			Outputs []json.RawMessage `json:"outputs"`
		} `json:"transaction"`
		Authorizations []json.RawMessage `json:"authorizations"`
	}
	if err := json.Unmarshal(sent[0], &signed); err != nil {
		t.Fatalf("read what the wallet sent: %v", err)
	}
	if len(signed.Transaction.Inputs) != 1 {
		t.Errorf("the transaction spends %d coins, want 1", len(signed.Transaction.Inputs))
	}
	// One payment and one change output.
	if len(signed.Transaction.Outputs) != 2 {
		t.Errorf("the transaction pays %d outputs, want 2", len(signed.Transaction.Outputs))
	}
	if len(signed.Authorizations) != 1 {
		t.Errorf("the transaction carries %d signatures, want 1", len(signed.Authorizations))
	}
}

// A withdrawal must build its own mainchain script, because light mode runs no
// bitcoind to ask for one.
func TestLightWithdrawSignsTheMainchainScript(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 60000)

	_, err := h.Withdraw(context.Background(), connect.NewRequest(&pb.WithdrawRequest{
		Address:     "bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080",
		AmountSats:  20000,
		SideFeeSats: 500,
		MainFeeSats: 1000,
	}))
	if err != nil {
		t.Fatalf("withdraw: %v", err)
	}

	sent := index.submitted()
	if len(sent) != 1 {
		t.Fatalf("the index got %d transactions, want 1", len(sent))
	}
	if !strings.Contains(string(sent[0]), "Withdrawal") {
		t.Errorf("the transaction carries no withdrawal: %s", sent[0])
	}
	if !strings.Contains(string(sent[0]), "bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080") {
		t.Errorf("the withdrawal names no mainchain address: %s", sent[0])
	}
}

// An address from another network must not become a payout target.
func TestLightWithdrawRefusesAForeignAddress(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 60000)

	_, err := h.Withdraw(context.Background(), connect.NewRequest(&pb.WithdrawRequest{
		Address:     "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4",
		AmountSats:  20000,
		SideFeeSats: 500,
		MainFeeSats: 1000,
	}))
	if err == nil {
		t.Fatal("want an error from a mainnet address on regtest, got none")
	}
	if len(index.submitted()) != 0 {
		t.Error("a refused withdrawal still reached the index")
	}
}

// A published receive address carries an invoice. Change must not land on it,
// or the payment out ties to that invoice and a later payment mingles with the
// change.
//
// The wallet skips it by position, so a restart cannot forget the invoice.
func TestLightChangeAvoidsTheReceiveAddress(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 10000)

	// The wallet hands out its first free address to receive on.
	issued, err := h.GetNewAddress(context.Background(),
		connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	if issued.Msg.Address != addresses[1].String() {
		t.Fatalf("issued %q, want %q", issued.Msg.Address, addresses[1])
	}

	// A send must then take its change somewhere else.
	if _, err := h.Transfer(context.Background(), connect.NewRequest(&pb.TransferRequest{
		Address:    addresses[9].String(),
		AmountSats: 4000,
		FeeSats:    500,
	})); err != nil {
		t.Fatalf("transfer: %v", err)
	}

	sent := index.submitted()
	if len(sent) != 1 {
		t.Fatalf("the index got %d transactions, want 1", len(sent))
	}
	var signed struct {
		Transaction struct {
			Outputs []struct {
				Address string `json:"address"`
			} `json:"outputs"`
		} `json:"transaction"`
	}
	if err := json.Unmarshal(sent[0], &signed); err != nil {
		t.Fatalf("read what the wallet sent: %v", err)
	}
	for _, output := range signed.Transaction.Outputs {
		if output.Address == issued.Msg.Address {
			t.Errorf("change landed on the published receive address %q", output.Address)
		}
	}
}

// Asking twice before a payment answers the same address, which is what a
// receive page shows.
func TestLightNewAddressRepeatsUntilPaid(t *testing.T) {
	index := newFakeIndex(t)
	h, _ := lightHandler(t, index)

	first, err := h.GetNewAddress(context.Background(),
		connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	again, err := h.GetNewAddress(context.Background(),
		connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address again: %v", err)
	}
	if first.Msg.Address != again.Msg.Address {
		t.Errorf("the wallet moved on from %q to %q with no payment",
			first.Msg.Address, again.Msg.Address)
	}
}

// A restart builds a new backend. The receive address is unpaid, so change
// must still avoid it, with nothing carried over in memory.
func TestLightChangeAvoidsTheReceiveAddressAfterARestart(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 10000)

	issued, err := h.GetNewAddress(context.Background(),
		connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}

	// A second handler over the same wallet and index stands in for a restart.
	restarted, _ := lightHandler(t, index)
	if _, err := restarted.Transfer(context.Background(),
		connect.NewRequest(&pb.TransferRequest{
			Address:    addresses[9].String(),
			AmountSats: 4000,
			FeeSats:    500,
		})); err != nil {
		t.Fatalf("transfer after the restart: %v", err)
	}

	sent := index.submitted()
	if len(sent) != 1 {
		t.Fatalf("the index got %d transactions, want 1", len(sent))
	}
	var signed struct {
		Transaction struct {
			Outputs []struct {
				Address string `json:"address"`
			} `json:"outputs"`
		} `json:"transaction"`
	}
	if err := json.Unmarshal(sent[0], &signed); err != nil {
		t.Fatalf("read what the wallet sent: %v", err)
	}
	for _, output := range signed.Transaction.Outputs {
		if output.Address == issued.Msg.Address {
			t.Errorf("change landed on the receive address %q after a restart",
				output.Address)
		}
	}
}

// A payment the chain has not mined yet must show at once. It counts in the
// total and not in what the wallet can spend.
func TestLightBalanceCountsAPendingCoin(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 7000)
	index.fundPending(addresses[1].String(), strings.Repeat("bb", 32), 2500)

	resp, err := h.GetBalance(context.Background(),
		connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if resp.Msg.TotalSats != 9500 {
		t.Errorf("total = %d, want 9500", resp.Msg.TotalSats)
	}
	if resp.Msg.AvailableSats != 7000 {
		t.Errorf("available = %d, want the 7000 the chain carries", resp.Msg.AvailableSats)
	}
}

// The UTXO list carries a pending coin too, so the wallet shows the money
// before a block arrives.
func TestLightUTXOsCarryAPendingCoin(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 4200)
	index.fundPending(addresses[1].String(), strings.Repeat("bb", 32), 800)

	resp, err := h.GetWalletUtxos(context.Background(),
		connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	var rows []struct {
		Output struct {
			Content struct {
				Value uint64 `json:"Value"`
			} `json:"content"`
		} `json:"output"`
	}
	if err := json.Unmarshal([]byte(resp.Msg.UtxosJson), &rows); err != nil {
		t.Fatalf("read the utxo json %s: %v", resp.Msg.UtxosJson, err)
	}
	if len(rows) != 2 {
		t.Fatalf("got %d utxos, want both coins", len(rows))
	}
	var sum uint64
	for _, row := range rows {
		sum += row.Output.Content.Value
	}
	if sum != 5000 {
		t.Errorf("the coins hold %d sats, want 5000", sum)
	}
}

// The wallet holds its own change until the index catches up, and the index
// then reports the same coin. Counting it in both places doubles the balance.
func TestLightBalanceCountsItsOwnChangeOneTime(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 10000)

	// The payment leaves the wallet, so the change is all that comes back.
	if _, err := h.Transfer(context.Background(), connect.NewRequest(&pb.TransferRequest{
		Address:    "3nRfgx4Lbhxas4P2J2CpCQ98Srsr",
		AmountSats: 4000,
		FeeSats:    500,
	})); err != nil {
		t.Fatalf("transfer: %v", err)
	}

	// The index catches up: the coin the wallet spent is gone, and the change
	// it made reads as unconfirmed. The wallet still holds that change too.
	index.spend(addresses[0].String())
	index.fundPendingAt(addresses[2].String(), strings.Repeat("ab", 32), 1, 5500)

	resp, err := h.GetBalance(context.Background(),
		connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if resp.Msg.TotalSats != 5500 {
		t.Errorf("total = %d, want the change one time: 5500", resp.Msg.TotalSats)
	}
	// No block carries the change, so the wallet waits for it.
	if resp.Msg.AvailableSats != 0 {
		t.Errorf("available = %d, want 0", resp.Msg.AvailableSats)
	}
}

// The index lags a broadcast by one pass: it still offers the coin the wallet
// spent, and it does not name the change yet. A balance must show neither the
// spent coin nor a gap where the change is.
func TestLightBalanceFollowsABroadcastTheIndexHasNotRead(t *testing.T) {
	index := newFakeIndex(t)
	h, addresses := lightHandler(t, index)
	index.fund(addresses[0].String(), strings.Repeat("aa", 32), 10000)

	if _, err := h.Transfer(context.Background(), connect.NewRequest(&pb.TransferRequest{
		Address:    "3nRfgx4Lbhxas4P2J2CpCQ98Srsr",
		AmountSats: 4000,
		FeeSats:    500,
	})); err != nil {
		t.Fatalf("transfer: %v", err)
	}

	resp, err := h.GetBalance(context.Background(),
		connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if resp.Msg.TotalSats != 5500 {
		t.Errorf("total = %d, want the 5500 change", resp.Msg.TotalSats)
	}
	if resp.Msg.AvailableSats != 0 {
		t.Errorf("available = %d, want 0: the wallet spent its only mined coin",
			resp.Msg.AvailableSats)
	}

	utxos, err := h.GetWalletUtxos(context.Background(),
		connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	var rows []struct {
		Output struct {
			Content struct {
				Value uint64 `json:"Value"`
			} `json:"content"`
		} `json:"output"`
	}
	if err := json.Unmarshal([]byte(utxos.Msg.UtxosJson), &rows); err != nil {
		t.Fatalf("read the utxo json %s: %v", utxos.Msg.UtxosJson, err)
	}
	if len(rows) != 1 || rows[0].Output.Content.Value != 5500 {
		t.Errorf("utxos = %+v, want the change alone", rows)
	}
}
