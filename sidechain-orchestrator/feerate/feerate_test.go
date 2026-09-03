package feerate

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func explorerOver(t *testing.T, status int, body string) *Explorer {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/api/v1/fees/recommended" {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		w.WriteHeader(status)
		_, _ = w.Write([]byte(body))
	}))
	t.Cleanup(server.Close)
	return NewExplorer(server.URL)
}

// The next block pays the fastest rate the explorer reports.
func TestNextBlockFeeRateReadsTheFastestRate(t *testing.T) {
	e := explorerOver(t, http.StatusOK,
		`{"fastestFee":4,"halfHourFee":1,"hourFee":1,"economyFee":1,"minimumFee":1}`)

	rate, err := e.NextBlockFeeRate(context.Background())
	if err != nil {
		t.Fatalf("read the rate: %v", err)
	}
	if rate != 4 {
		t.Errorf("rate = %v, want 4", rate)
	}
}

// A trailing slash in the address names the same server.
func TestNewExplorerTrimsTheSlash(t *testing.T) {
	e := NewExplorer("https://explorer.example.com/")
	if e.URL() != "https://explorer.example.com" {
		t.Errorf("url = %q", e.URL())
	}
}

func TestNextBlockFeeRateRefusesAZeroRate(t *testing.T) {
	e := explorerOver(t, http.StatusOK, `{"fastestFee":0}`)
	if _, err := e.NextBlockFeeRate(context.Background()); err == nil {
		t.Fatal("want an error for a zero rate, got none")
	}
}

func TestNextBlockFeeRateRefusesABadStatus(t *testing.T) {
	e := explorerOver(t, http.StatusBadGateway, "")
	if _, err := e.NextBlockFeeRate(context.Background()); err == nil {
		t.Fatal("want an error for a 502, got none")
	}
}

func TestNextBlockFeeRateRefusesJunk(t *testing.T) {
	e := explorerOver(t, http.StatusOK, "not json")
	if _, err := e.NextBlockFeeRate(context.Background()); err == nil {
		t.Fatal("want an error for a body it cannot read, got none")
	}
}
