package feerate

import (
	"context"
	"errors"
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
func TestEstimateFeeReadsTheFastestRate(t *testing.T) {
	e := explorerOver(t, http.StatusOK,
		`{"fastestFee":4,"halfHourFee":1,"hourFee":1,"economyFee":1,"minimumFee":1}`)

	rate, err := e.EstimateFee(context.Background())
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

func TestEstimateFeeRefusesAZeroRate(t *testing.T) {
	e := explorerOver(t, http.StatusOK, `{"fastestFee":0}`)
	if _, err := e.EstimateFee(context.Background()); err == nil {
		t.Fatal("want an error for a zero rate, got none")
	}
}

func TestEstimateFeeRefusesABadStatus(t *testing.T) {
	e := explorerOver(t, http.StatusBadGateway, "")
	if _, err := e.EstimateFee(context.Background()); err == nil {
		t.Fatal("want an error for a 502, got none")
	}
}

func TestEstimateFeeRefusesJunk(t *testing.T) {
	e := explorerOver(t, http.StatusOK, "not json")
	if _, err := e.EstimateFee(context.Background()); err == nil {
		t.Fatal("want an error for a body it cannot read, got none")
	}
}

// The fallback answers with the first source that reports a rate.
func TestFallbackTakesTheFirstAnswer(t *testing.T) {
	broken := Func(func(context.Context) (float64, error) { return 0, errUnavailable })
	steady := Func(func(context.Context) (float64, error) { return 7, nil })

	rate, err := NewFallback(broken, steady).EstimateFee(context.Background())
	if err != nil {
		t.Fatalf("estimate: %v", err)
	}
	if rate != 7 {
		t.Errorf("rate = %v, want 7", rate)
	}
}

// A caller sees why no source answered.
func TestFallbackNamesEveryFailure(t *testing.T) {
	broken := Func(func(context.Context) (float64, error) { return 0, errUnavailable })

	_, err := NewFallback(broken, broken).EstimateFee(context.Background())
	if err == nil {
		t.Fatal("want an error when no source answers, got none")
	}
	if !errors.Is(err, errUnavailable) {
		t.Errorf("error = %v, want the source failure", err)
	}
}

func TestFallbackWithNoSource(t *testing.T) {
	if _, err := NewFallback().EstimateFee(context.Background()); err == nil {
		t.Fatal("want an error with no source, got none")
	}
}

var errUnavailable = errors.New("the source is down")
