package orchestrator

import (
	"encoding/json"
	"testing"
)

func TestParseMainchainBalance(t *testing.T) {
	raw := json.RawMessage(`{"mine":{"trusted":1.25,"untrusted_pending":0.5,"immature":0}}`)

	got, err := parseMainchainBalance(raw)
	if err != nil {
		t.Fatalf("parseMainchainBalance: %v", err)
	}
	if got.Confirmed != 1.25 {
		t.Errorf("confirmed = %v, want 1.25", got.Confirmed)
	}
	if got.Unconfirmed != 0.5 {
		t.Errorf("unconfirmed = %v, want 0.5", got.Unconfirmed)
	}
}

func TestParseMainchainBalanceWatchOnlyWalletStaysZero(t *testing.T) {
	raw := json.RawMessage(`{"mine":{"trusted":0,"untrusted_pending":0,"immature":0},"watchonly":{"trusted":9}}`)

	got, err := parseMainchainBalance(raw)
	if err != nil {
		t.Fatalf("parseMainchainBalance: %v", err)
	}
	if got.Confirmed != 0 || got.Unconfirmed != 0 {
		t.Errorf("got %+v, want zero balances", got)
	}
}

func TestParseMainchainBalanceRejectsBadJSON(t *testing.T) {
	if _, err := parseMainchainBalance(json.RawMessage(`not json`)); err == nil {
		t.Fatal("want an error for bad JSON")
	}
}
