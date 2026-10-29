package main

import (
	"context"
	"fmt"
	"slices"
)

const (
	recentBlocks = retargetInterval
	stableDepth  = 100
	maxSteps     = 400
)

// Header is the part of a block header the dashboard reads.
type Header struct {
	Height int64
	Time   int64
	Bits   uint32
}

// Chain is the node the dashboard reads.
type Chain interface {
	Tip(ctx context.Context) (height int64, hash string, err error)
	Headers(ctx context.Context, heights []int64) (map[int64]Header, error)
}

// State is everything the page shows.
type State struct {
	Now           int64    `json:"now"`
	Fork          int64    `json:"fork"`
	Interval      int64    `json:"interval"`
	TargetSpacing int64    `json:"targetSpacing"`
	Tip           Block    `json:"tip"`
	Difficulty    float64  `json:"difficulty"`
	AvgBlockTime  float64  `json:"avgBlockTime"`
	Hashrate      float64  `json:"hashrate"`
	Next          *Next    `json:"next"`
	Periods       []Period `json:"periods"`
	Upcoming      []Step   `json:"upcoming"`
	TargetReached *Step    `json:"targetReached"`
	Blocks        []Block  `json:"blocks"`
	BlocksToFork  int64    `json:"blocksToFork"`
	Error         string   `json:"error,omitempty"`
	Updated       int64    `json:"updated"`
}

// Block is one block on the chain.
type Block struct {
	Height   int64 `json:"height"`
	Time     int64 `json:"time"`
	Interval int64 `json:"interval"`
}

// Period is one span of blocks at one difficulty.
type Period struct {
	Start        int64   `json:"start"`
	Difficulty   float64 `json:"difficulty"`
	ChangePct    float64 `json:"changePct"`
	Timespan     int64   `json:"timespan"`
	AvgBlockTime float64 `json:"avgBlockTime"`
	Clamped      bool    `json:"clamped"`
	Complete     bool    `json:"complete"`
}

// Next is the retarget the chain moves toward.
type Next struct {
	Height            int64   `json:"height"`
	BlocksLeft        int64   `json:"blocksLeft"`
	WindowStart       int64   `json:"windowStart"`
	Elapsed           int64   `json:"elapsed"`
	ProjectedTimespan int64   `json:"projectedTimespan"`
	Difficulty        float64 `json:"difficulty"`
	ChangePct         float64 `json:"changePct"`
	Limit             string  `json:"limit"`
	ETASeconds        float64 `json:"etaSeconds"`
}

// Builder turns chain headers into State, and keeps every header deep enough
// that no reorg moves it.
type Builder struct {
	chain   Chain
	fork    int64
	cache   map[int64]Header
	last    *State
	lastTip string
}

func NewBuilder(chain Chain, fork int64) *Builder {
	return &Builder{chain: chain, fork: fork, cache: make(map[int64]Header)}
}

func (b *Builder) headers(ctx context.Context, tip int64, heights []int64) (map[int64]Header, error) {
	out := make(map[int64]Header, len(heights))
	var missing []int64
	for _, h := range heights {
		if hdr, ok := b.cache[h]; ok {
			out[h] = hdr
		} else if !slices.Contains(missing, h) {
			missing = append(missing, h)
		}
	}
	if len(missing) > 0 {
		got, err := b.chain.Headers(ctx, missing)
		if err != nil {
			return nil, err
		}
		for _, h := range missing {
			hdr, ok := got[h]
			if !ok {
				return nil, fmt.Errorf("node returned no header at %d", h)
			}
			out[h] = hdr
			if h <= tip-stableDepth {
				b.cache[h] = hdr
			}
		}
	}
	return out, nil
}

// Build reads the chain and returns the state at now.
func (b *Builder) Build(ctx context.Context, now int64) (State, error) {
	tip, tipHash, err := b.chain.Tip(ctx)
	if err != nil {
		return State{}, err
	}
	if b.last != nil && tipHash == b.lastTip {
		st := *b.last
		st.Now, st.Updated = now, now
		return st, nil
	}
	st, err := b.build(ctx, tip, now)
	if err != nil {
		return State{}, err
	}
	b.last, b.lastTip = &st, tipHash
	return st, nil
}

func (b *Builder) build(ctx context.Context, tip, now int64) (State, error) {
	st := State{
		Now: now, Fork: b.fork, Interval: retargetInterval, TargetSpacing: targetSpacing, Updated: now,
		Periods: []Period{}, Upcoming: []Step{}, Blocks: []Block{},
	}

	first := tip - recentBlocks
	if tip >= b.fork {
		first = max(first, b.fork)
	}
	heights := []int64{}
	for h := first; h <= tip; h++ {
		heights = append(heights, h)
	}
	next := NextRetarget(tip)
	if tip >= b.fork {
		for s := b.fork; s <= tip; s += retargetInterval {
			heights = append(heights, s)
			if end := s + retargetInterval; end <= tip {
				heights = append(heights, WindowStart(end, b.fork), end-1)
			}
		}
		heights = append(heights, WindowStart(next, b.fork))
	}
	hdrs, err := b.headers(ctx, tip, heights)
	if err != nil {
		return State{}, err
	}

	tipHdr := hdrs[tip]
	st.Tip = Block{Height: tip, Time: tipHdr.Time}
	st.Difficulty = Difficulty(tipHdr.Bits)
	for h := first; h <= tip; h++ {
		blk := Block{Height: h, Time: hdrs[h].Time}
		if prev, ok := hdrs[h-1]; ok {
			blk.Interval = hdrs[h].Time - prev.Time
		}
		st.Blocks = append(st.Blocks, blk)
	}
	if tip < b.fork {
		st.BlocksToFork = b.fork - tip
		return st, nil
	}

	if n := tip - first; n > 0 {
		span := tipHdr.Time - hdrs[first].Time
		st.AvgBlockTime = float64(span) / float64(n)
		work := 0.0
		for h := first + 1; h <= tip; h++ {
			work += Difficulty(hdrs[h].Bits) * twoPower32
		}
		st.Hashrate = work / float64(max(span, 1))
	}

	for s := b.fork; s <= tip; s += retargetInterval {
		p := Period{Start: s, Difficulty: Difficulty(hdrs[s].Bits)}
		if len(st.Periods) > 0 {
			p.ChangePct = (p.Difficulty/st.Periods[len(st.Periods)-1].Difficulty - 1) * 100
		}
		if end := s + retargetInterval; end <= tip {
			ws := WindowStart(end, b.fork)
			p.Timespan = hdrs[end-1].Time - hdrs[ws].Time
			p.AvgBlockTime = float64(p.Timespan) / float64(end-1-ws)
			p.Clamped = clampTimespan(p.Timespan) != p.Timespan
			p.Complete = true
		} else if tip > s {
			p.Timespan = tipHdr.Time - hdrs[s].Time
			p.AvgBlockTime = float64(p.Timespan) / float64(tip-s)
		}
		st.Periods = append(st.Periods, p)
	}

	ws := WindowStart(next, b.fork)
	nx := &Next{Height: next, BlocksLeft: next - tip, WindowStart: ws, Elapsed: tipHdr.Time - hdrs[ws].Time}
	if done := tip - ws; done > 0 {
		nx.ProjectedTimespan = nx.Elapsed * (next - 1 - ws) / done
	} else {
		nx.ProjectedTimespan = int64(st.AvgBlockTime * float64(next-1-ws))
	}
	nextBits := NextBits(tipHdr.Bits, nx.ProjectedTimespan)
	nx.Difficulty = Difficulty(nextBits)
	nx.ChangePct = (nx.Difficulty/st.Difficulty - 1) * 100
	nx.Limit = timespanLimit(nx.ProjectedTimespan)
	nx.ETASeconds = st.AvgBlockTime * float64(nx.BlocksLeft)
	st.Next = nx

	if st.Hashrate > 0 {
		st.Upcoming = append(st.Upcoming, Step{
			Height: next, Difficulty: nx.Difficulty, ChangePct: nx.ChangePct,
			BlockTime: BlockSeconds(nextBits, st.Hashrate), ETASeconds: nx.ETASeconds,
		})
		steps := Project(next, nextBits, st.Hashrate, nx.ETASeconds, maxSteps)
		st.Upcoming = append(st.Upcoming, steps...)
		if len(steps) < maxSteps {
			last := st.Upcoming[len(st.Upcoming)-1]
			st.TargetReached = &last
		}
	}
	return st, nil
}

// timespanLimit names the clamp a window hits: "up" when it is short enough to
// raise the difficulty by the most allowed, "down" when it is long enough to
// lower it by the most allowed.
func timespanLimit(timespan int64) string {
	switch {
	case timespan < targetTimespan/4:
		return "up"
	case timespan > targetTimespan*4:
		return "down"
	}
	return ""
}
