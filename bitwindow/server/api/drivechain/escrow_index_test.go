package api_drivechain

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

// The index answers the escrow the mainchain holds. A light install reads every
// sidechain from here, so the shapes must match what the service sends.
func TestEscrowIndexReadsTheChain(t *testing.T) {
	var path string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path = r.URL.Path
		_, _ = w.Write([]byte(`[
			{"slot":2,"title":"BitNames","description":"names","vote_count":73,
			 "proposal_height":987283,"activation_height":987402,
			 "treasury":{"txid":"aa","vout":1,"value_sats":100007100}},
			{"slot":4,"title":"BitAssets","description":"assets","vote_count":73,
			 "proposal_height":987283,"activation_height":987402,"treasury":null}]`))
	}))
	defer server.Close()

	got, err := newEscrowIndex(server.URL).Sidechains(context.Background())
	if err != nil {
		t.Fatalf("read the escrow: %v", err)
	}
	if path != "/sidechains" {
		t.Errorf("read %q, want /sidechains", path)
	}
	if len(got) != 2 {
		t.Fatalf("read %d sidechains, want 2", len(got))
	}

	first := got[0]
	if first.Slot != 2 || first.Title != "BitNames" || first.VoteCount != 73 {
		t.Errorf("first chain = %+v", first)
	}
	if first.BalanceSatoshi != 100007100 || first.ChaintipTxid != "aa" || first.ChaintipVout != 1 {
		t.Errorf("the treasury did not carry through: %+v", first)
	}
	// A slot with no treasury reads as zero here, because the wire has no way
	// to say "none". It must not carry another chain's outpoint.
	if got[1].BalanceSatoshi != 0 || got[1].ChaintipTxid != "" {
		t.Errorf("a chain with no treasury carries one: %+v", got[1])
	}
}

// A down index must report an error, never an empty list that reads as "no
// sidechains exist".
func TestEscrowIndexReportsAFailure(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		http.Error(w, "no enforcer behind me", http.StatusServiceUnavailable)
	}))
	defer server.Close()

	if _, err := newEscrowIndex(server.URL).Sidechains(context.Background()); err == nil {
		t.Fatal("want an error from a down index, got none")
	}
}
