package thunder

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// stubHistory stands in for the node.
type stubHistory struct {
	calls int
	tip   uint32
}

func (s *stubHistory) History(context.Context, []string) ([]sidechainesplora.Entry, error) {
	s.calls++
	return []sidechainesplora.Entry{{Txid: "from-node"}}, nil
}

func (s *stubHistory) TipHeight(context.Context) (uint32, error) { return s.tip, nil }

func indexServing(t *testing.T, txid string) *httptest.Server {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/address/alice/txs" {
			_ = json.NewEncoder(w).Encode([]sidechainesplora.Tx{{Txid: txid}})
			return
		}
		if r.URL.Path == "/blocks/tip/height" {
			_, _ = w.Write([]byte("77"))
			return
		}
		if strings.HasPrefix(r.URL.Path, "/address/") &&
			!strings.Contains(r.URL.Path, "/txs") &&
			!strings.HasSuffix(r.URL.Path, "/deposits") {
			_, _ = w.Write([]byte(addressStats(
				strings.TrimPrefix(r.URL.Path, "/address/"), false)))
			return
		}
		_, _ = w.Write([]byte("[]"))
	}))
	t.Cleanup(server.Close)
	return server
}

// A network swap and a wallet mode change both move the index while the
// process runs. Reading the URL once would keep answering from the old one.
func TestHistoryFollowsTheCurrentMode(t *testing.T) {
	index := indexServing(t, "from-index")
	node := &stubHistory{}
	source := newSources(node, nil, nil, nil)

	read := func(mode Mode) []sidechainesplora.Entry {
		t.Helper()
		entries, err := source.History(mode).History(context.Background(), []string{"alice"})
		if err != nil {
			t.Fatalf("history: %v", err)
		}
		return entries
	}

	// Full mode: no index, so the node answers.
	if entries := read(Mode{LocalNode: true}); entries[0].Txid != "from-node" {
		t.Fatalf("full mode read %+v, want the node", entries)
	}
	// The mode changes under us.
	if entries := read(Mode{IndexURL: index.URL}); entries[0].Txid != "from-index" {
		t.Fatalf("light mode read %+v, want the index", entries)
	}
	// And back again.
	if entries := read(Mode{LocalNode: true}); entries[0].Txid != "from-node" {
		t.Errorf("read %+v after the swap back, want the node", entries)
	}
}

// A second index URL builds a second client, so a swap between two hosted
// indexes does not keep reading the first.
func TestHistoryRebuildsOnANewURL(t *testing.T) {
	first := indexServing(t, "first")
	second := indexServing(t, "second")
	source := newSources(&stubHistory{}, nil, nil, nil)

	entries, err := source.History(Mode{IndexURL: first.URL}).
		History(context.Background(), []string{"alice"})
	if err != nil || entries[0].Txid != "first" {
		t.Fatalf("read %+v (err %v), want the first index", entries, err)
	}

	entries, err = source.History(Mode{IndexURL: second.URL}).
		History(context.Background(), []string{"alice"})
	if err != nil || entries[0].Txid != "second" {
		t.Errorf("read %+v (err %v), want the second index", entries, err)
	}
}

// A running node holds the wallet, so it names the addresses even when an
// index answers the history. Only a host with no node derives its own.
func TestAddressesFollowTheNode(t *testing.T) {
	index := indexServing(t, "any")
	node := &stubAddresses{name: "from-node"}
	derived := &stubKeys{stubAddresses{name: "derived"}}
	source := newSources(&stubHistory{}, node, nil, derived)

	got, err := source.Addresses(Mode{IndexURL: index.URL, LocalNode: true}).
		Addresses(context.Background())
	if err != nil || got[0] != "from-node" {
		t.Fatalf("read %v (err %v), want the node with an index override", got, err)
	}

	got, err = source.Addresses(Mode{IndexURL: index.URL}).Addresses(context.Background())
	if err != nil || len(got) != 1 || got[0] != "derived" {
		t.Errorf("read %v (err %v), want the derived addresses", got, err)
	}
}

// With no seed there is nothing to derive, so the node answers.
func TestAddressesWithNoSeed(t *testing.T) {
	node := &stubAddresses{name: "from-node"}
	source := newSources(&stubHistory{}, node, nil, nil)

	got, err := source.Addresses(Mode{}).Addresses(context.Background())
	if err != nil || got[0] != "from-node" {
		t.Errorf("read %v (err %v), want the node", got, err)
	}
}

// stubAddresses stands in for one address source.
type stubAddresses struct{ name string }

func (s *stubAddresses) Addresses(context.Context) ([]string, error) {
	return []string{s.name}, nil
}

// stubKeys stands in for the wallet a light mode owns.
type stubKeys struct{ stubAddresses }

func (s *stubKeys) Keyring() (*thunderwallet.MemoryKeyring, error) {
	return thunderwallet.NewMemoryKeyring(), nil
}
