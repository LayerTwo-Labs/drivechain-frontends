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
