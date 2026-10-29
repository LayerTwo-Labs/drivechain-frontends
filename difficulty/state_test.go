package main

import (
	"context"
	"fmt"
	"math"
	"testing"
)

const testFork = 973728

type fakeChain struct {
	blocks  map[int64]Header
	tip     int64
	fetched []int64
}

// newFakeChain builds a chain that finds a block every spacing seconds from
// the fork to tip, with the bits consensus sets at each retarget.
func newFakeChain(tip, spacing int64) *fakeChain {
	c := &fakeChain{blocks: make(map[int64]Header), tip: tip}
	start := min(tip-recentBlocks, testFork) - 10
	c.blocks[start] = Header{Height: start, Time: 1793300000, Bits: 0x17020093}
	for h := start + 1; h <= tip; h++ {
		prev := c.blocks[h-1]
		bits := prev.Bits
		switch {
		case h == testFork:
			bits = 0x1901a6e1
		case IsRetarget(h, testFork):
			bits = NextBits(prev.Bits, prev.Time-c.blocks[WindowStart(h, testFork)].Time)
		}
		c.blocks[h] = Header{Height: h, Time: prev.Time + spacing, Bits: bits}
	}
	return c
}

func (c *fakeChain) Tip(context.Context) (int64, string, error) {
	return c.tip, fmt.Sprintf("%d-%d", c.tip, c.blocks[c.tip].Time), nil
}

func (c *fakeChain) Headers(_ context.Context, heights []int64) (map[int64]Header, error) {
	c.fetched = append(c.fetched, heights...)
	out := make(map[int64]Header, len(heights))
	for _, h := range heights {
		out[h] = c.blocks[h]
	}
	return out, nil
}

func TestBuildAfterFork(t *testing.T) {
	chain := newFakeChain(974562, 2)
	st, err := NewBuilder(chain, testFork).Build(context.Background(), 0)
	if err != nil {
		t.Fatal(err)
	}
	if len(st.Periods) != 3 {
		t.Fatalf("periods: got %d, want 3", len(st.Periods))
	}
	for i, start := range []int64{973728, 974016, 974304} {
		if st.Periods[i].Start != start {
			t.Errorf("period %d starts at %d, want %d", i, st.Periods[i].Start, start)
		}
	}
	if !st.Periods[0].Clamped || !st.Periods[0].Complete || st.Periods[2].Complete {
		t.Errorf("period flags wrong: %+v", st.Periods)
	}
	if math.Abs(st.Periods[1].ChangePct-12) > 0.1 {
		t.Errorf("second period change: got %+.2f%%", st.Periods[1].ChangePct)
	}
	if st.Next.Height != 974592 || st.Next.BlocksLeft != 30 || st.Next.WindowStart != 974303 {
		t.Errorf("next: %+v", st.Next)
	}
	if st.Next.Limit != "up" || math.Abs(st.Next.ChangePct-12) > 0.1 {
		t.Errorf("next change: %+v", st.Next)
	}
	if math.Abs(st.AvgBlockTime-2) > 1e-9 {
		t.Errorf("average block time: got %f", st.AvgBlockTime)
	}
	if len(st.Blocks) != recentBlocks+1 || st.Blocks[len(st.Blocks)-1].Interval != 2 {
		t.Errorf("recent blocks: %d", len(st.Blocks))
	}
	if st.Upcoming[0].Height != st.Next.Height || st.TargetReached == nil {
		t.Fatalf("projection: %+v", st.TargetReached)
	}
	if math.Abs(st.TargetReached.BlockTime-targetSpacing) > targetSpacing*0.05 {
		t.Errorf("target reached at block time %f", st.TargetReached.BlockTime)
	}
}

func TestBuildBeforeFork(t *testing.T) {
	chain := newFakeChain(testFork-2, 600)
	st, err := NewBuilder(chain, testFork).Build(context.Background(), 0)
	if err != nil {
		t.Fatal(err)
	}
	if st.BlocksToFork != 2 || st.Next != nil || st.Periods == nil || st.Upcoming == nil || len(st.Periods) != 0 {
		t.Errorf("before fork: %+v", st)
	}
}

func TestBuildFetchesOnlyShallowHeadersAgain(t *testing.T) {
	chain := newFakeChain(974562, 2)
	b := NewBuilder(chain, testFork)
	if _, err := b.Build(context.Background(), 0); err != nil {
		t.Fatal(err)
	}
	chain.fetched = nil
	if _, err := b.Build(context.Background(), 0); err != nil {
		t.Fatal(err)
	}
	if len(chain.fetched) != 0 {
		t.Fatalf("same tip fetched %d headers, want 0", len(chain.fetched))
	}
	chain.blocks[chain.tip] = Header{Height: chain.tip, Time: chain.blocks[chain.tip].Time + 1, Bits: chain.blocks[chain.tip].Bits}
	if _, err := b.Build(context.Background(), 0); err != nil {
		t.Fatal(err)
	}
	if len(chain.fetched) != stableDepth {
		t.Errorf("second build fetched %d headers, want %d", len(chain.fetched), stableDepth)
	}
	for _, h := range chain.fetched {
		if h <= chain.tip-stableDepth {
			t.Errorf("refetched deep header %d", h)
		}
	}
}

func TestTimespanLimit(t *testing.T) {
	for _, c := range []struct {
		span int64
		want string
	}{{targetTimespan/4 - 1, "up"}, {targetTimespan, ""}, {targetTimespan*4 + 1, "down"}} {
		if got := timespanLimit(c.span); got != c.want {
			t.Errorf("timespanLimit(%d) = %q, want %q", c.span, got, c.want)
		}
	}
}
