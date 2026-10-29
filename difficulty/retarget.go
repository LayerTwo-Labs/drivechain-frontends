package main

import (
	"math"
	"math/big"
)

const (
	retargetInterval = 288
	targetSpacing    = 600
	targetTimespan   = retargetInterval * targetSpacing
)

var (
	powLimit   = new(big.Int).Sub(new(big.Int).Lsh(big.NewInt(1), 224), big.NewInt(1))
	diff1Bits  = uint32(0x1d00ffff)
	twoPower32 = math.Pow(2, 32)
)

// compactToTarget decodes nBits into the target it encodes.
func compactToTarget(bits uint32) *big.Int {
	size := bits >> 24
	word := int64(bits & 0x007fffff)
	if size <= 3 {
		return big.NewInt(word >> (8 * (3 - size)))
	}
	return new(big.Int).Lsh(big.NewInt(word), uint(8*(size-3)))
}

// targetToCompact encodes a target as nBits.
func targetToCompact(target *big.Int) uint32 {
	size := uint32((target.BitLen() + 7) / 8)
	var compact uint32
	if size <= 3 {
		compact = uint32(target.Uint64() << (8 * (3 - size)))
	} else {
		compact = uint32(new(big.Int).Rsh(target, uint(8*(size-3))).Uint64())
	}
	if compact&0x00800000 != 0 {
		compact >>= 8
		size++
	}
	return compact | size<<24
}

// Difficulty returns the difficulty of nBits, relative to the Bitcoin minimum.
func Difficulty(bits uint32) float64 {
	ratio, _ := new(big.Rat).SetFrac(compactToTarget(diff1Bits), compactToTarget(bits)).Float64()
	return ratio
}

// NextBits returns the nBits that eCash consensus sets at a retarget, from the
// nBits of the last block and the seconds the window took.
func NextBits(lastBits uint32, actualTimespan int64) uint32 {
	actualTimespan = clampTimespan(actualTimespan)
	target := compactToTarget(lastBits)
	target.Mul(target, big.NewInt(6*targetTimespan+actualTimespan))
	target.Div(target, big.NewInt(7*targetTimespan))
	if target.Cmp(powLimit) > 0 {
		target.Set(powLimit)
	}
	return targetToCompact(target)
}

func clampTimespan(timespan int64) int64 {
	return min(max(timespan, targetTimespan/4), targetTimespan*4)
}

// IsRetarget reports whether the block at height sets a new difficulty.
func IsRetarget(height, fork int64) bool {
	return height > fork && height%retargetInterval == 0
}

// NextRetarget returns the first retarget height above height.
func NextRetarget(height int64) int64 {
	return (height/retargetInterval + 1) * retargetInterval
}

// WindowStart returns the height whose time opens the window for the retarget
// at height. Each window shares the endpoint of the one before, but never
// reaches below the fork.
func WindowStart(height, fork int64) int64 {
	return max(height-retargetInterval-1, fork)
}

// BlockSeconds returns the mean block time that nBits gives at hashrate.
func BlockSeconds(bits uint32, hashrate float64) float64 {
	return Difficulty(bits) * twoPower32 / hashrate
}

// Hashrate returns the hashes per second that found blocks blocks of nBits in
// seconds.
func Hashrate(bits uint32, blocks int64, seconds int64) float64 {
	if seconds <= 0 {
		seconds = 1
	}
	return Difficulty(bits) * twoPower32 * float64(blocks) / float64(seconds)
}

// Step is one projected retarget.
type Step struct {
	Height     int64   `json:"height"`
	Difficulty float64 `json:"difficulty"`
	ChangePct  float64 `json:"changePct"`
	BlockTime  float64 `json:"blockTime"`
	ETASeconds float64 `json:"etaSeconds"`
}

// Project runs the retarget rule forward at a fixed hashrate, from bits set at
// height. It stops when the block time is within 5% of the target spacing.
func Project(height int64, bits uint32, hashrate float64, startETA float64, maxSteps int) []Step {
	steps := make([]Step, 0, maxSteps)
	eta := startETA
	for range maxSteps {
		blockTime := BlockSeconds(bits, hashrate)
		if math.Abs(blockTime-targetSpacing) <= targetSpacing*0.05 {
			break
		}
		eta += blockTime * retargetInterval
		height += retargetInterval
		next := NextBits(bits, int64(blockTime*retargetInterval))
		steps = append(steps, Step{
			Height:     height,
			Difficulty: Difficulty(next),
			ChangePct:  (Difficulty(next)/Difficulty(bits) - 1) * 100,
			BlockTime:  BlockSeconds(next, hashrate),
			ETASeconds: eta,
		})
		bits = next
	}
	return steps
}
