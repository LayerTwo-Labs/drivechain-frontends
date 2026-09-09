package lightwallet

import (
	"encoding/binary"
	"io"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync"
	"testing"
)

// fakeIndex serves the Esplora routes a light wallet reads.
type fakeIndex struct {
	mu       sync.Mutex
	utxos    map[string]string
	deposits map[string]string
	funded   map[string]bool
	// stats counts the address reads one walk made.
	stats  int
	server *httptest.Server
}

func newFakeIndex(t *testing.T) *fakeIndex {
	t.Helper()
	f := &fakeIndex{
		utxos:    map[string]string{},
		deposits: map[string]string{},
		funded:   map[string]bool{},
	}
	f.server = httptest.NewServer(http.HandlerFunc(f.serve))
	t.Cleanup(f.server.Close)
	return f
}

// deposit pays one address from the mainchain. A deposit names a mainchain
// outpoint, and the index answers it under both routes.
func (f *fakeIndex) deposit(address, txid string, valueSats int64, confirmed bool) {
	row := `{"txid":"` + txid + `","vout":0,"value":` + strconv.FormatInt(valueSats, 10) +
		`,"outpoint_kind":"deposit","content_type":"value","status":` + status(confirmed) + `}`
	f.mu.Lock()
	defer f.mu.Unlock()
	f.utxos[address] = "[" + row + "]"
	f.deposits[address] = "[" + row + "]"
	f.funded[address] = true
}

// rows gives one address the exact utxo listing a test names.
func (f *fakeIndex) rows(address, listing string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.utxos[address] = listing
	f.funded[address] = true
}

func status(confirmed bool) string {
	if confirmed {
		return `{"confirmed":true,"block_height":1,"block_time":1}`
	}
	return `{"confirmed":false,"block_height":null,"block_time":null}`
}

func (f *fakeIndex) serve(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()

	path := strings.TrimPrefix(r.URL.Path, "/address/")
	switch {
	case strings.HasSuffix(path, "/utxo"):
		f.write(w, f.utxos[strings.TrimSuffix(path, "/utxo")])
	case strings.HasSuffix(path, "/deposits"):
		f.write(w, f.deposits[strings.TrimSuffix(path, "/deposits")])
	default:
		f.stats++
		count := 0
		if f.funded[path] {
			count = 1
		}
		_, _ = io.WriteString(w, `{"address":"`+path+`",
			"chain_stats":{"funded_txo_count":`+strconv.Itoa(count)+`,
			"funded_txo_sum":0,"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0},
			"mempool_stats":{"funded_txo_count":0,"funded_txo_sum":0,
			"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0}}`)
	}
}

// reads answers how many addresses the index saw a stats call for, and starts
// the count again.
func (f *fakeIndex) reads() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	count := f.stats
	f.stats = 0
	return count
}

func (f *fakeIndex) write(w http.ResponseWriter, body string) {
	if body == "" {
		body = "[]"
	}
	_, _ = io.WriteString(w, body)
}

// testSeed is one wallet seed, and another one names another wallet.
var testSeed = []byte("a light wallet seed of sixty-four bytes, which bip39 answers with")

// testDerive stands in for a chain's key derivation. It answers a different
// address per seed and per index, which is all the read path needs.
func testDerive(seed []byte, index uint32) (Address, error) {
	key := binary.BigEndian.AppendUint32(append([]byte{}, seed...), index)
	return AddressForKey(key), nil
}

func testAddress(t *testing.T, index uint32) Address {
	t.Helper()
	address, err := testDerive(testSeed, index)
	if err != nil {
		t.Fatalf("derive %d: %v", index, err)
	}
	return address
}

func testWallet(seed []byte) *Window {
	return NewWindow(func() ([]byte, error) { return seed, nil }, testDerive, AddressWindow)
}
