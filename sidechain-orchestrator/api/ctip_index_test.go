package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestReadIndexCtipReadsTheTreasury(t *testing.T) {
	var gotPath string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotPath = r.URL.Path
		_, _ = w.Write([]byte(`{"slot":9,"treasury":{"txid":"be01","vout":2,"value_sats":10403007000}}`))
	}))
	defer srv.Close()

	ctip, err := readIndexCtip(context.Background(), srv.URL+"/drivechain", 9)
	if err != nil {
		t.Fatalf("read the treasury: %v", err)
	}
	if gotPath != "/drivechain/sidechain/9" {
		t.Errorf("asked for %q, want /drivechain/sidechain/9", gotPath)
	}
	if ctip == nil {
		t.Fatal("a slot with a treasury must report one")
	}
	if ctip.Txid != "be01" || ctip.Vout != 2 || ctip.Value != 10403007000 {
		t.Errorf("read %+v, want txid be01 vout 2 value 10403007000", *ctip)
	}
}

// A slot that took no deposit yet holds no treasury. The first deposit starts
// one, so that is not a fault.
func TestReadIndexCtipAllowsAnEmptyTreasury(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"slot":13}`))
	}))
	defer srv.Close()

	ctip, err := readIndexCtip(context.Background(), srv.URL, 13)
	if err != nil {
		t.Fatalf("read the treasury: %v", err)
	}
	if ctip != nil {
		t.Errorf("read %+v, want no treasury", *ctip)
	}
}

func TestReadIndexCtipReportsABadAnswer(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNotFound)
		_, _ = w.Write([]byte("404 page not found"))
	}))
	defer srv.Close()

	if _, err := readIndexCtip(context.Background(), srv.URL, 9); err == nil {
		t.Error("a 404 must report an error, not an empty treasury")
	}
}
