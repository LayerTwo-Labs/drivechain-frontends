package main

import (
	"math"
	"testing"
)

func TestCompactRoundTrip(t *testing.T) {
	for _, bits := range []uint32{0x1d00ffff, 0x17020093, 0x1901a6e1, 0x19017992, 0x1901511d} {
		if got := targetToCompact(compactToTarget(bits)); got != bits {
			t.Errorf("round trip %08x: got %08x", bits, got)
		}
	}
}

func TestNextBitsMatchesChain(t *testing.T) {
	cases := []struct {
		name       string
		last       uint32
		start, end int64
		want       uint32
	}{
		{"974016, window 973728 to 974015", 0x1901a6e1, 1793300395, 1793300825, 0x19017992},
		{"974304, window 974015 to 974303", 0x19017992, 1793300825, 1793301247, 0x1901511d},
	}
	for _, c := range cases {
		if got := NextBits(c.last, c.end-c.start); got != c.want {
			t.Errorf("%s: got %08x, want %08x", c.name, got, c.want)
		}
	}
}

func TestNextBitsDampsTowardMeasured(t *testing.T) {
	bits := uint32(0x1901a6e1)
	if got := NextBits(bits, targetTimespan); got != bits {
		t.Errorf("on-target window changed bits: got %08x", got)
	}
	slower := Difficulty(NextBits(bits, 2*targetTimespan)) / Difficulty(bits)
	if math.Abs(slower-7.0/8.0) > 1e-5 {
		t.Errorf("a window twice as long: ratio %f, want 7/8", slower)
	}
}

func TestDifficulty(t *testing.T) {
	if got := Difficulty(0x1901a6e1); math.Abs(got-2600022924.553239) > 1 {
		t.Errorf("difficulty: got %f", got)
	}
}

func TestRetargetHeights(t *testing.T) {
	const fork = 973728
	if IsRetarget(fork, fork) {
		t.Error("the fork block resets the difficulty, it does not retarget")
	}
	if !IsRetarget(974016, fork) || IsRetarget(974017, fork) {
		t.Error("974016 retargets, 974017 does not")
	}
	if got := NextRetarget(974562); got != 974592 {
		t.Errorf("next retarget: got %d", got)
	}
	if got := WindowStart(974016, fork); got != fork {
		t.Errorf("first window starts at the fork: got %d", got)
	}
	if got := WindowStart(974304, fork); got != 974015 {
		t.Errorf("later windows share the previous endpoint: got %d", got)
	}
}

func TestProjectReachesTargetSpacing(t *testing.T) {
	bits := uint32(0x1901511d)
	hashrate := Hashrate(bits, 1, 2)
	steps := Project(974304, bits, hashrate, 0, 500)
	if len(steps) == 0 || len(steps) == 500 {
		t.Fatalf("projection did not converge: %d steps", len(steps))
	}
	if math.Abs(steps[0].ChangePct-12) > 0.1 {
		t.Errorf("first step from fast blocks: got %+.2f%%, want +12%%", steps[0].ChangePct)
	}
	last := steps[len(steps)-1]
	if math.Abs(last.BlockTime-targetSpacing) > targetSpacing*0.05 {
		t.Errorf("last step block time: got %f", last.BlockTime)
	}
	for i := 1; i < len(steps); i++ {
		if steps[i].ETASeconds <= steps[i-1].ETASeconds || steps[i].Height != steps[i-1].Height+retargetInterval {
			t.Fatalf("step %d out of order", i)
		}
	}
}
