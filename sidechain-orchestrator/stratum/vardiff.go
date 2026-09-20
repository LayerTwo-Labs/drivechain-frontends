package stratum

import (
	"math"
	"time"
)

const (
	startDifficulty  = 8192
	minDifficulty    = 1
	shareInterval    = 10 * time.Second
	retargetInterval = time.Minute
	// earlyRetargetShares lets a fast miner leave a low start difficulty in
	// seconds, not minutes.
	earlyRetargetShares = 30
	maxRetargetStep     = 4
	hashrateWindow      = 5 * time.Minute
	minHashrateSpan     = 10 * time.Second
)

func dueForRetarget(shares int, elapsed time.Duration) bool {
	return elapsed >= retargetInterval || shares >= earlyRetargetShares
}

// retarget returns the difficulty that brings the share rate toward one share
// per shareInterval. A small miss keeps the current difficulty.
func retarget(current float64, shares int, elapsed time.Duration) float64 {
	if elapsed <= 0 {
		return current
	}
	if shares == 0 {
		return current / maxRetargetStep
	}
	ratio := float64(shares) * shareInterval.Seconds() / elapsed.Seconds()
	if ratio > 0.5 && ratio < 2 {
		return current
	}
	return current * math.Min(math.Max(ratio, 1.0/maxRetargetStep), maxRetargetStep)
}

// clampDifficulty holds d between the floor and the network difficulty. A
// share above the network difficulty is a block, so no miner needs more.
func clampDifficulty(d, floor, network float64) float64 {
	if floor <= 0 {
		floor = minDifficulty
	}
	d = math.Max(d, floor)
	if network > 0 {
		d = math.Min(d, network)
	}
	return d
}

type shareSample struct {
	at         time.Time
	difficulty float64
}

// hashrate estimates hashes per second from the shares in the window. A
// connection younger than the window divides by its own age.
func hashrate(samples []shareSample, connected, now time.Time) float64 {
	span := now.Sub(connected)
	span = min(max(span, minHashrateSpan), hashrateWindow)
	var sum float64
	for _, s := range samples {
		if now.Sub(s.at) <= hashrateWindow {
			sum += s.difficulty
		}
	}
	return sum * math.Pow(2, 32) / span.Seconds()
}

func pruneSamples(samples []shareSample, now time.Time) []shareSample {
	i := 0
	for i < len(samples) && now.Sub(samples[i].at) > hashrateWindow {
		i++
	}
	return samples[i:]
}
