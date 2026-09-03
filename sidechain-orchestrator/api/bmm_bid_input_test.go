package api

import (
	"math"
	"testing"
)

func TestCheckBidInput(t *testing.T) {
	tests := []struct {
		name    string
		bidSats int64
		rate    float64
		wantErr bool
	}{
		{name: "an exact bid", bidSats: 5_000},
		{name: "a rate", rate: 2.5},
		{name: "neither", wantErr: true},
		{name: "a negative rate", rate: -1, wantErr: true},
		{name: "not a number", rate: math.NaN(), wantErr: true},
		{name: "an infinity", rate: math.Inf(1), wantErr: true},
		{name: "a negative infinity", rate: math.Inf(-1), wantErr: true},
		{name: "an exact bid beside a bad rate", bidSats: 5_000, rate: math.NaN(), wantErr: true},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := checkBidInput(test.bidSats, test.rate)
			if test.wantErr && err == nil {
				t.Fatalf("checkBidInput(%d, %v) allowed the bid", test.bidSats, test.rate)
			}
			if !test.wantErr && err != nil {
				t.Fatalf("checkBidInput(%d, %v) refused the bid: %v", test.bidSats, test.rate, err)
			}
		})
	}
}

func TestBidSizing(t *testing.T) {
	tests := []struct {
		name       string
		in         bidInput
		wantSats   int64
		wantByRate bool
	}{
		{
			name:     "a worthless round with no ceiling lets the wallet size it",
			in:       bidInput{rateSatVb: 42, capToBlockWorth: true},
			wantSats: 0, wantByRate: true,
		},
		{
			name:     "a valuable round takes an exact fee",
			in:       bidInput{rateSatVb: 42, blockWorthSats: 100_000, capToBlockWorth: true},
			wantSats: int64(math.Ceil(42 * nominalBidVsize)), wantByRate: false,
		},
		{
			name:     "the cap holds a rich rate down to what the block is worth",
			in:       bidInput{rateSatVb: 5_000, blockWorthSats: 9_000, capToBlockWorth: true},
			wantSats: 9_000, wantByRate: false,
		},
		{
			name:     "an exact bid above the worth still caps",
			in:       bidInput{bidSats: 50_000, blockWorthSats: 9_000, capToBlockWorth: true},
			wantSats: 9_000, wantByRate: false,
		},
		{
			name:     "no cap asked, so an exact bid stands",
			in:       bidInput{bidSats: 50_000, blockWorthSats: 9_000},
			wantSats: 50_000, wantByRate: false,
		},
		{
			name:     "the ceiling holds an opening bid the wallet would size",
			in:       bidInput{rateSatVb: 5_000, maxBidSats: 20_000, capToBlockWorth: true},
			wantSats: 20_000, wantByRate: false,
		},
		{
			name:     "the ceiling holds an exact bid too",
			in:       bidInput{bidSats: 50_000, maxBidSats: 20_000},
			wantSats: 20_000, wantByRate: false,
		},
		{
			name:     "a rate under the ceiling pays the rate",
			in:       bidInput{rateSatVb: 2, maxBidSats: 20_000, capToBlockWorth: true},
			wantSats: int64(math.Ceil(2 * nominalBidVsize)), wantByRate: false,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			sats, byRate := bidSizing(test.in)
			if sats != test.wantSats {
				t.Errorf("bid is %d sats, want %d", sats, test.wantSats)
			}
			if byRate != test.wantByRate {
				t.Errorf("byRate is %v, want %v", byRate, test.wantByRate)
			}
		})
	}
}

// A replacement has to beat the fees of the transaction it evicts and every
// descendant, so a chain of stranded bids costs the sum of all of them.
func TestReplacementBid(t *testing.T) {
	tests := []struct {
		name        string
		sized       int64
		floor       int64
		maxBid      int64
		wantSats    int64
		wantAllowed bool
	}{
		{
			name:  "the sized bid already clears the floor",
			sized: 80_000, floor: 53_000, maxBid: 100_000,
			wantSats: 80_000, wantAllowed: true,
		},
		{
			name:  "a 52 bid chain costs more than the rate alone",
			sized: 10_000, floor: 53_000, maxBid: 100_000,
			wantSats: 53_000, wantAllowed: true,
		},
		{
			name:  "the floor is over the ceiling, so the round is refused",
			sized: 10_000, floor: 150_000, maxBid: 100_000,
			wantSats: 0, wantAllowed: false,
		},
		{
			name:  "no ceiling lets the floor stand",
			sized: 10_000, floor: 150_000, maxBid: 0,
			wantSats: 150_000, wantAllowed: true,
		},
		{
			name:  "nothing to evict leaves the sized bid alone",
			sized: 10_000, floor: 0, maxBid: 100_000,
			wantSats: 10_000, wantAllowed: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			sats, ok := replacementBid(tt.sized, tt.floor, tt.maxBid)
			if ok != tt.wantAllowed {
				t.Fatalf("allowed = %v, want %v", ok, tt.wantAllowed)
			}
			if sats != tt.wantSats {
				t.Errorf("sats = %d, want %d", sats, tt.wantSats)
			}
		})
	}
}
