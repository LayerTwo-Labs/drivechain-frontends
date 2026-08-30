package orchestrator

import (
	"context"
	"strings"
	"testing"
	"time"
)

const (
	target979000 = "0000000000000000000000000000000000000000000000000000000079000000"
	tipHash      = "0000000000000000000000000000000000000000000000000000000079472000"
)

// A height names the block on the chain Core follows today, so the reset asks
// Core for that hash rather than trusting the number on its own.
func TestResolveResetTargetReadsAHeight(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979472},
		hashes:  map[int64]string{979000: target979000, 979472: tipHash},
		headers: map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
	}

	got, err := resolveResetTarget(context.Background(), core.start(t), "979000")
	if err != nil {
		t.Fatalf("resolveResetTarget: %v", err)
	}
	if got.Hash != target979000 || got.Height != 979000 {
		t.Errorf("target = %s/%d, want %s/979000", got.Hash, got.Height, target979000)
	}
}

// The field takes a copied height, and a copied height carries the group
// separators the UI prints.
func TestResolveResetTargetReadsASpacedHeight(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979472},
		hashes:  map[int64]string{979000: target979000, 979472: tipHash},
		headers: map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
	}

	got, err := resolveResetTarget(context.Background(), core.start(t), " 979 000 ")
	if err != nil {
		t.Fatalf("resolveResetTarget: %v", err)
	}
	if got.Height != 979000 {
		t.Errorf("height = %d, want 979000", got.Height)
	}
}

// A hash names one block, so the reset never asks Core to resolve a height.
func TestResolveResetTargetReadsAHash(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979472},
		headers: map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
	}

	got, err := resolveResetTarget(context.Background(), core.start(t), strings.ToUpper(target979000))
	if err != nil {
		t.Fatalf("resolveResetTarget: %v", err)
	}
	if got.Hash != target979000 {
		t.Errorf("hash = %s, want the lower case form %s", got.Hash, target979000)
	}
	if calls := strings.Join(core.methods, ","); calls != "getblockheader" {
		t.Errorf("rpc calls = %s, want getblockheader only", calls)
	}
}

func TestResolveResetTargetRefusesAHeightAboveTheTip(t *testing.T) {
	core := &fakeCore{tips: []int64{979472}, hashes: map[int64]string{979472: tipHash}}

	_, err := resolveResetTarget(context.Background(), core.start(t), "999999")
	if err == nil {
		t.Fatal("resolveResetTarget accepted a height above the tip")
	}
	if !strings.Contains(err.Error(), "979472") {
		t.Errorf("error = %v, want the tip height in it", err)
	}
}

// A block off the active chain has nothing above it to replay, and Core would
// climb back to a tip the caller never named.
func TestResolveResetTargetRefusesABlockOffTheChain(t *testing.T) {
	core := &fakeCore{
		tips:    []int64{979472},
		headers: map[string]blockHeader{other: {Height: 979000, Confirmations: -1, PreviousBlockHash: parent}},
	}

	_, err := resolveResetTarget(context.Background(), core.start(t), other)
	if err == nil {
		t.Fatal("resolveResetTarget accepted a block off the active chain")
	}
}

func TestResolveResetTargetRefusesJunk(t *testing.T) {
	core := &fakeCore{tips: []int64{979472}, hashes: map[int64]string{979472: tipHash}}

	for _, target := range []string{"", "   ", "abc", "-4", "0x10"} {
		if _, err := resolveResetTarget(context.Background(), core.start(t), target); err == nil {
			t.Errorf("resolveResetTarget accepted %q", target)
		}
	}
}

// The reset takes its own drop back at once. invalidateblock alone marks the
// branch bad, so Core would park on the parent and never follow it again.
func TestResetCoreToBlockReconsidersImmediately(t *testing.T) {
	resetSyncPollInterval = time.Millisecond
	t.Cleanup(func() { resetSyncPollInterval = time.Second })

	core := &fakeCore{
		tips:    []int64{978999, 979472},
		hashes:  map[int64]string{978999: parent, 979472: tipHash},
		headers: map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
	}

	base := ResetProgress{TargetHeight: 979000, TargetHash: target979000, TipHeight: 979472, BlocksTotal: 473}
	var steps []ResetProgress
	final, err := resetCoreToBlock(context.Background(), core.start(t), base, func(p ResetProgress) {
		steps = append(steps, p)
	})
	if err != nil {
		t.Fatalf("resetCoreToBlock: %v", err)
	}
	if final != 979472 {
		t.Errorf("final tip = %d, want 979472", final)
	}

	calls := strings.Join(core.methods, ",")
	invalidate := strings.Index(calls, "invalidateblock")
	reconsider := strings.Index(calls, "reconsiderblock")
	if invalidate < 0 || reconsider < 0 {
		t.Fatalf("rpc calls = %s, want both invalidateblock and reconsiderblock", calls)
	}
	if reconsider < invalidate {
		t.Errorf("rpc calls = %s, want invalidateblock before reconsiderblock", calls)
	}

	if got := phases(steps); !hasPhase(got, ResetPhaseMoveBack) || !hasPhase(got, ResetPhaseSyncForward) {
		t.Errorf("phases = %v, want a move back and a sync forward", got)
	}
}

// The parked tip is the block below the target, and it is what the move back
// reports.
func TestResetCoreToBlockReportsTheParkedTip(t *testing.T) {
	resetSyncPollInterval = time.Millisecond
	t.Cleanup(func() { resetSyncPollInterval = time.Second })

	core := &fakeCore{
		tips:    []int64{978999, 979472},
		hashes:  map[int64]string{978999: parent, 979472: tipHash},
		headers: map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
	}

	base := ResetProgress{TargetHeight: 979000, TargetHash: target979000, TipHeight: 979472, BlocksTotal: 473}
	var moveBack *ResetProgress
	if _, err := resetCoreToBlock(context.Background(), core.start(t), base, func(p ResetProgress) {
		if p.Phase == ResetPhaseMoveBack {
			step := p
			moveBack = &step
		}
	}); err != nil {
		t.Fatalf("resetCoreToBlock: %v", err)
	}
	if moveBack == nil {
		t.Fatal("the reset reported no move back")
	}
	if moveBack.CoreHeight != 978999 {
		t.Errorf("parked tip = %d, want 978999", moveBack.CoreHeight)
	}
}

// The blocks the reset drops are the target and everything above it, so a
// reset to the tip itself still replays one block.
func TestNewResetProgressCountsTheDroppedBlocks(t *testing.T) {
	core := &fakeCore{tips: []int64{979472, 979472}, hashes: map[int64]string{979472: tipHash}}
	client := core.start(t)

	got, err := newResetProgress(context.Background(), client, resetTarget{Hash: target979000, Height: 979000})
	if err != nil {
		t.Fatalf("newResetProgress: %v", err)
	}
	if got.BlocksTotal != 473 {
		t.Errorf("BlocksTotal = %d, want 473", got.BlocksTotal)
	}

	tip, err := newResetProgress(context.Background(), client, resetTarget{Hash: tipHash, Height: 979472})
	if err != nil {
		t.Fatalf("newResetProgress at the tip: %v", err)
	}
	if tip.BlocksTotal != 1 {
		t.Errorf("BlocksTotal at the tip = %d, want 1", tip.BlocksTotal)
	}
}

// A block left invalid sits off the active chain, so a retry on the same
// target is refused. A failure after the invalidate must clear the mark.
func TestResetCoreToBlockClearsTheMarkWhenTheTipReadFails(t *testing.T) {
	core := &fakeCore{
		// One tip only: the read after the invalidate finds no entry and fails.
		tips:    []int64{},
		hashes:  map[int64]string{},
		headers: map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
	}

	base := ResetProgress{TargetHeight: 979000, TargetHash: target979000, TipHeight: 979472, BlocksTotal: 473}
	if _, err := resetCoreToBlock(context.Background(), core.start(t), base, func(ResetProgress) {}); err == nil {
		t.Fatal("resetCoreToBlock reported no error after a failed tip read")
	}

	calls := strings.Join(core.methods, ",")
	if !strings.Contains(calls, "reconsiderblock") {
		t.Errorf("rpc calls = %s, want reconsiderblock after the failed tip read", calls)
	}
}

// A reconsiderblock that never reached Core left the target invalid, so the
// failed replay must still take the drop back.
func TestResetCoreToBlockClearsTheMarkWhenTheReplayFails(t *testing.T) {
	resetSyncPollInterval = time.Millisecond
	t.Cleanup(func() { resetSyncPollInterval = time.Second })

	core := &fakeCore{
		tips:         []int64{978999},
		hashes:       map[int64]string{978999: parent},
		headers:      map[string]blockHeader{target979000: {Height: 979000, Confirmations: 473, PreviousBlockHash: parent}},
		reconsiderNo: true,
	}

	base := ResetProgress{TargetHeight: 979000, TargetHash: target979000, TipHeight: 979472, BlocksTotal: 473}
	if _, err := resetCoreToBlock(context.Background(), core.start(t), base, func(ResetProgress) {}); err == nil {
		t.Fatal("resetCoreToBlock reported no error after a failed replay")
	}

	calls := strings.Join(core.methods, ",")
	if got := strings.Count(calls, "reconsiderblock"); got != 2 {
		t.Errorf("reconsiderblock calls = %d in %s, want a retry after the failed replay", got, calls)
	}
}

// Progress is a snapshot, so a slow reader may miss ticks. The terminal
// message carries the outcome, so a full buffer must not drop it.
func TestResetEmitKeepsTheTerminalMessage(t *testing.T) {
	ch := make(chan ResetProgress, 2)
	emit := resetEmitter(ch)

	emit(ResetProgress{Phase: ResetPhaseSyncForward, CoreHeight: 1})
	emit(ResetProgress{Phase: ResetPhaseSyncForward, CoreHeight: 2})
	emit(ResetProgress{Phase: ResetPhaseSyncForward, CoreHeight: 3})
	emit(ResetProgress{Phase: ResetPhaseDone, Done: true})

	var last ResetProgress
	for len(ch) > 0 {
		last = <-ch
	}
	if !last.Done {
		t.Errorf("last message = %+v, want the terminal one", last)
	}
}

func TestResetEmitKeepsTheError(t *testing.T) {
	ch := make(chan ResetProgress, 1)
	emit := resetEmitter(ch)

	emit(ResetProgress{Phase: ResetPhaseSyncForward, CoreHeight: 1})
	emit(ResetProgress{Phase: ResetPhaseSyncForward, Error: context.Canceled})

	var last ResetProgress
	for len(ch) > 0 {
		last = <-ch
	}
	if last.Error == nil {
		t.Errorf("last message = %+v, want the error", last)
	}
}

func phases(steps []ResetProgress) []ResetPhase {
	out := make([]ResetPhase, 0, len(steps))
	for _, s := range steps {
		out = append(out, s.Phase)
	}
	return out
}

func hasPhase(list []ResetPhase, want ResetPhase) bool {
	for _, p := range list {
		if p == want {
			return true
		}
	}
	return false
}
