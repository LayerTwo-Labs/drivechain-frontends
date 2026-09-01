package api

import "math"

// nominalBidVsize is the size of a one input bid, in vBytes.
const nominalBidVsize = 188

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
