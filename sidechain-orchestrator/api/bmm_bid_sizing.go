package api

import (
	"fmt"
	"math"
)

// nominalBidVsize is the size of a one input bid, in vBytes.
const nominalBidVsize = 188

// checkBidInput reports why a bid names no usable amount. A rate arrives as a
// double over the wire, so it can carry NaN or an infinity, and both pass a
// plain comparison.
func checkBidInput(bidSats int64, rateSatVb float64) error {
	if math.IsNaN(rateSatVb) || math.IsInf(rateSatVb, 0) {
		return fmt.Errorf("fee_rate_sat_vb must be a number")
	}
	if bidSats <= 0 && rateSatVb <= 0 {
		return fmt.Errorf("name a bid: bid_sats or fee_rate_sat_vb")
	}
	return nil
}

type bidInput struct {
	bidSats         int64
	rateSatVb       float64
	blockWorthSats  int64
	maxBidSats      int64
	capToBlockWorth bool
}

// bidSizing decides what a bid pays, and whether the wallet sizes it. A cap or
// a ceiling forces an exact fee, because neither applies after the broadcast.
func bidSizing(in bidInput) (sats int64, byRate bool) {
	sats = in.bidSats
	capped := in.capToBlockWorth && in.blockWorthSats > 0

	if sats <= 0 && (capped || in.maxBidSats > 0) {
		sats = int64(math.Ceil(in.rateSatVb * nominalBidVsize))
	}
	if capped && sats > in.blockWorthSats {
		sats = in.blockWorthSats
	}
	if in.maxBidSats > 0 && sats > in.maxBidSats {
		sats = in.maxBidSats
	}
	return sats, sats <= 0 && in.rateSatVb > 0
}

// replacementBumpSats is the margin a replacement adds over the fees it evicts.
// A replacement that only matches them fails the incremental relay rule.
const replacementBumpSats = 1000

// replacementBid raises a sized bid so it clears every fee it has to evict.
// The mempool counts the replaced transaction and its descendants together, so
// a long chain of stranded bids costs the sum of all of them.
//
// It reports false when that floor is over the ceiling the operator set,
// because a bid under the floor never enters the mempool and only burns a
// round.
func replacementBid(sizedSats, floorSats, maxBidSats int64) (sats int64, ok bool) {
	if maxBidSats > 0 && floorSats > maxBidSats {
		return 0, false
	}
	if floorSats > sizedSats {
		return floorSats, true
	}
	return sizedSats, true
}
