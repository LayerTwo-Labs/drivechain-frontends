package rpcmeter

import (
	"context"
	"testing"
	"time"

	"github.com/rs/zerolog"
)

func TestShortMethod(t *testing.T) {
	cases := map[string]string{
		"/bitcoin.bitcoind.v1alpha.BitcoinService/GetBlock": "GetBlock",
		"GetBlock": "GetBlock",
		"":         "",
		"/":        "/",
	}
	for in, want := range cases {
		if got := shortMethod(in); got != want {
			t.Errorf("shortMethod(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestRecordAccumulates(t *testing.T) {
	m := New(context.Background(), zerolog.Nop(), 0) // 0 => no reporter goroutine

	m.record("/svc/GetBlock", 10*time.Millisecond, false)
	m.record("/svc/GetBlock", 30*time.Millisecond, true)
	m.record("/svc/GetBlockHash", 5*time.Millisecond, false)

	gb := m.stats["GetBlock"]
	if gb == nil {
		t.Fatal("GetBlock not recorded")
	}
	if gb.count != 2 {
		t.Errorf("GetBlock count = %d, want 2", gb.count)
	}
	if gb.errors != 1 {
		t.Errorf("GetBlock errors = %d, want 1", gb.errors)
	}
	if gb.maxDur != 30*time.Millisecond {
		t.Errorf("GetBlock maxDur = %s, want 30ms", gb.maxDur)
	}
	if gb.totalDur != 40*time.Millisecond {
		t.Errorf("GetBlock totalDur = %s, want 40ms", gb.totalDur)
	}
	if m.stats["GetBlockHash"].count != 1 {
		t.Errorf("GetBlockHash count = %d, want 1", m.stats["GetBlockHash"].count)
	}
}

func TestFlushResetsWindow(t *testing.T) {
	m := New(context.Background(), zerolog.Nop(), 0)
	m.record("/svc/GetBlock", time.Millisecond, false)

	m.flush()
	if len(m.stats) != 0 {
		t.Errorf("stats not reset after flush: %d entries", len(m.stats))
	}
	// Flushing an empty window must not panic.
	m.flush()
}
