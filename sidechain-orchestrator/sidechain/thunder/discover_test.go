package thunder

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// countingIndex answers the routes discovery reads, and counts the requests.
func countingIndex(t *testing.T, used map[string]bool, calls *int64) *sidechainesplora.Client {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt64(calls, 1)
		path := strings.TrimPrefix(r.URL.Path, "/address/")
		if strings.HasSuffix(path, "/deposits") {
			_, _ = w.Write([]byte("[]"))
			return
		}
		_, _ = w.Write([]byte(addressStats(path, used[path])))
	}))
	t.Cleanup(server.Close)
	return sidechainesplora.New(server.URL)
}

// A user who runs a node first, then switches to light mode, may sit well past
// the first hundred keys. A node hands out addresses in order, so discovery
// walks through them and must not stop at a fixed window.
func TestDiscoveryReachesAFarAddress(t *testing.T) {
	names := make([]string, 300)
	for i := range names {
		names[i] = "addr" + itoa(int64(i))
	}
	used := make(map[string]bool, 121)
	for i := 0; i <= 120; i++ {
		used["addr"+itoa(int64(i))] = true
	}

	var calls int64
	source := newDiscoveredAddresses(&listAddresses{names}, countingIndex(t, used, &calls))

	got, err := source.Addresses(context.Background())
	if err != nil {
		t.Fatalf("discover: %v", err)
	}
	if len(got) != 121+gapLimit {
		t.Fatalf("found %d addresses, want %d", len(got), 121+gapLimit)
	}
	if got[120] != "addr120" {
		t.Errorf("address 120 = %q", got[120])
	}
}

// A fresh wallet must not read every key it could ever hold. It stops one gap
// past its last used address.
func TestDiscoveryStopsAtTheGap(t *testing.T) {
	names := make([]string, 500)
	for i := range names {
		names[i] = "addr" + itoa(int64(i))
	}

	var calls int64
	source := newDiscoveredAddresses(&listAddresses{names}, countingIndex(t, nil, &calls))

	got, err := source.Addresses(context.Background())
	if err != nil {
		t.Fatalf("discover: %v", err)
	}
	if len(got) != gapLimit {
		t.Errorf("found %d addresses, want %d", len(got), gapLimit)
	}
	// One stats call and one deposits call for each address it walked.
	if calls > int64(2*(gapLimit+1)) {
		t.Errorf("the walk cost %d requests, want at most %d", calls, 2*(gapLimit+1))
	}
}

// A second read inside the hold answers from memory, so one refresh does not
// walk the chain again for every call it makes.
func TestDiscoveryHoldsItsAnswer(t *testing.T) {
	var calls int64
	source := newDiscoveredAddresses(
		&listAddresses{[]string{"a", "b", "c"}}, countingIndex(t, nil, &calls))

	if _, err := source.Addresses(context.Background()); err != nil {
		t.Fatalf("discover: %v", err)
	}
	first := atomic.LoadInt64(&calls)
	if _, err := source.Addresses(context.Background()); err != nil {
		t.Fatalf("discover again: %v", err)
	}
	if atomic.LoadInt64(&calls) != first {
		t.Errorf("the second read cost %d more requests", atomic.LoadInt64(&calls)-first)
	}
}

// listAddresses stands in for a derived window.
type listAddresses struct{ names []string }

func (l *listAddresses) Addresses(context.Context) ([]string, error) { return l.names, nil }

// A restore hands back another wallet. The walk of the one before it names
// none of the new wallet's coins, so it must not answer from memory.
func TestDiscoveryForgetsAfterARestore(t *testing.T) {
	var calls int64
	keys := &listAddresses{[]string{"a", "b"}}
	source := newDiscoveredAddresses(keys, countingIndex(t, nil, &calls))

	if _, err := source.Addresses(context.Background()); err != nil {
		t.Fatalf("discover: %v", err)
	}

	keys.names = []string{"x", "y"}
	source.Forget()

	got, err := source.Addresses(context.Background())
	if err != nil {
		t.Fatalf("discover after the restore: %v", err)
	}
	if len(got) == 0 || got[0] != "x" {
		t.Errorf("read %v, want the restored wallet", got)
	}
}
