package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// resetSyncPollInterval is how often the replay reads Core's tip while
// reconsiderblock runs. Tests shorten it.
var resetSyncPollInterval = time.Second

// ResetPhase says which step of a reset a progress message reports.
type ResetPhase int

const (
	ResetPhaseResolve ResetPhase = iota + 1
	ResetPhaseMoveBack
	ResetPhaseSyncForward
	ResetPhaseEnforcer
	ResetPhaseDone
)

// ResetProgress is one step of a reset.
type ResetProgress struct {
	Phase           ResetPhase
	Message         string
	TargetHeight    uint32
	TargetHash      string
	CoreHeight      uint32
	TipHeight       uint32
	BlocksDone      uint32
	BlocksTotal     uint32
	EnforcerChecked bool
	EnforcerHeight  uint32
	EnforcerRebuilt bool
	EnforcerError   string
	Done            bool
	Error           error
}

var resetHashPattern = regexp.MustCompile(`^[0-9a-fA-F]{64}$`)

// resetTarget is the block a reset moves back to.
type resetTarget struct {
	Hash   string
	Height uint32
}

// resolveResetTarget reads a target as a hash or as a height. Two branches can
// share a height, so a height only ever names the block on the chain Core
// follows today.
func resolveResetTarget(ctx context.Context, client *CoreStatusClient, target string) (resetTarget, error) {
	trimmed := strings.TrimSpace(target)
	if trimmed == "" {
		return resetTarget{}, fmt.Errorf("name the block to reset to, by height or by hash")
	}

	hash := ""
	if resetHashPattern.MatchString(trimmed) {
		hash = normalizeBlockHash(trimmed)
	} else {
		height, err := strconv.ParseUint(strings.ReplaceAll(trimmed, " ", ""), 10, 32)
		if err != nil {
			return resetTarget{}, fmt.Errorf("read %q as a height or as a 64-character hash", trimmed)
		}
		tipHeight, _, err := coreTip(ctx, client)
		if err != nil {
			return resetTarget{}, err
		}
		if uint32(height) > tipHeight {
			return resetTarget{}, fmt.Errorf("no block at height %d: this node holds a chain that ends at %d", height, tipHeight)
		}
		raw, err := client.call(ctx, "getblockhash", height)
		if err != nil {
			return resetTarget{}, fmt.Errorf("get block hash at %d: %w", height, err)
		}
		if err := json.Unmarshal(raw, &hash); err != nil {
			return resetTarget{}, fmt.Errorf("decode block hash at %d: %w", height, err)
		}
	}

	header, err := readBlockHeader(ctx, client, hash)
	if err != nil {
		return resetTarget{}, err
	}
	// A block off the active chain has nothing above it to replay, and Core
	// would climb back to a tip the caller never named.
	if header.Confirmations < 0 {
		return resetTarget{}, fmt.Errorf("block %s sits off the chain this node follows", hash)
	}
	if header.Height < 0 {
		return resetTarget{}, fmt.Errorf("block %s reports no height", hash)
	}
	return resetTarget{Hash: hash, Height: uint32(header.Height)}, nil
}

// ResetToBlock moves the chain back to a block, then syncs forward to the tip
// again. Core drops the block and every block above it, and immediately takes
// the drop back: invalidateblock alone marks the branch bad, so Core would park
// on the parent and never follow that branch again. The blocks stay on disk, so
// the replay downloads nothing.
func (o *Orchestrator) ResetToBlock(ctx context.Context, target string, enforcerWait time.Duration) (<-chan ResetProgress, error) {
	if enforcerWait <= 0 {
		enforcerWait = defaultEnforcerReorgWait
	}

	client, err := o.CoreStatusClient()
	if err != nil {
		return nil, fmt.Errorf("bitcoin core rpc: %w", err)
	}

	// Resolve before the channel so a bad target is an RPC error, not a stream
	// that opens and then fails.
	resolved, err := resolveResetTarget(ctx, client, target)
	if err != nil {
		return nil, err
	}

	// Core keeps replaying whatever the caller does, so the run must outlive the
	// request. A cancelled reset would release rejectMu while Core still moves.
	run := context.WithoutCancel(ctx)
	ch := make(chan ResetProgress, 32)
	go func() {
		defer close(ch)
		o.runResetToBlock(run, client, resolved, enforcerWait, ch)
	}()
	return ch, nil
}

func (o *Orchestrator) runResetToBlock(
	ctx context.Context,
	client *CoreStatusClient,
	target resetTarget,
	enforcerWait time.Duration,
	ch chan ResetProgress,
) {
	// An accept or a reject landing mid-reset would move the chain this call
	// still replays.
	o.rejectMu.Lock()
	defer o.rejectMu.Unlock()

	emit := resetEmitter(ch)

	// A reject landing between the resolve and this lock moves the active
	// chain, and a stale target would take that rejection back.
	onChain, err := blockOnActiveChain(ctx, client, target.Hash)
	if err == nil && !onChain {
		err = fmt.Errorf("block %s left the chain this node follows", target.Hash)
	}
	if err != nil {
		emit(ResetProgress{Phase: ResetPhaseResolve, Error: err})
		return
	}

	base, err := newResetProgress(ctx, client, target)
	if err != nil {
		emit(ResetProgress{Phase: ResetPhaseResolve, Error: err})
		return
	}

	o.log.Info().
		Str("target", target.Hash).
		Uint32("target_height", target.Height).
		Uint32("tip_height", base.TipHeight).
		Msg("reset the chain to a block")

	final, err := resetCoreToBlock(ctx, client, base, emit)
	if err != nil {
		return
	}

	step := base
	step.Phase = ResetPhaseEnforcer
	step.CoreHeight = final
	step.BlocksDone = base.BlocksTotal
	step.Message = "The enforcer follows Core."
	emit(step)

	rec := o.reconcileEnforcer(ctx, client, enforcerWait)
	if rec.Err != "" {
		o.log.Error().Str("error", rec.Err).Msg("core replayed but the enforcer could not be reconciled")
	}

	step = base
	step.Phase = ResetPhaseDone
	step.CoreHeight = final
	step.BlocksDone = base.BlocksTotal
	step.EnforcerChecked = rec.Checked
	step.EnforcerHeight = rec.Height
	step.EnforcerRebuilt = rec.Rebuilt
	step.EnforcerError = rec.Err
	step.Done = true
	step.Message = fmt.Sprintf("The chain is back at %d.", final)
	emit(step)
}

// resetEmitter writes progress without a stall behind a reader that left.
// Progress is a snapshot, so a slow reader may miss ticks. A terminal message
// carries the outcome, so it takes the place of the oldest tick rather than
// drop.
func resetEmitter(ch chan ResetProgress) func(ResetProgress) {
	return func(p ResetProgress) {
		terminal := p.Done || p.Error != nil
		for {
			select {
			case ch <- p:
				return
			default:
				if !terminal {
					return
				}
				select {
				case <-ch:
				default:
				}
			}
		}
	}
}

// newResetProgress reads the tip the replay ends on and counts the blocks the
// reset drops.
func newResetProgress(ctx context.Context, client *CoreStatusClient, target resetTarget) (ResetProgress, error) {
	tipHeight, _, err := coreTip(ctx, client)
	if err != nil {
		return ResetProgress{}, err
	}
	if target.Height > tipHeight {
		return ResetProgress{}, fmt.Errorf(
			"no block at height %d: this node holds a chain that ends at %d", target.Height, tipHeight)
	}
	return ResetProgress{
		TargetHeight: target.Height,
		TargetHash:   target.Hash,
		TipHeight:    tipHeight,
		BlocksTotal:  tipHeight - target.Height + 1,
	}, nil
}

// resetCoreToBlock drops the target block and takes the drop back at once, then
// reports the replay. invalidateblock alone marks the branch bad, so Core would
// park on the parent and never follow that branch again. It returns Core's tip
// when the replay ends, and emits its own failure before it returns the error.
func resetCoreToBlock(
	ctx context.Context,
	client *CoreStatusClient,
	base ResetProgress,
	emit func(ResetProgress),
) (uint32, error) {
	fail := func(phase ResetPhase, err error) (uint32, error) {
		step := base
		step.Phase = phase
		step.Error = err
		emit(step)
		return 0, err
	}

	step := base
	step.Phase = ResetPhaseResolve
	step.CoreHeight = base.TipHeight
	step.Message = fmt.Sprintf("Block %d is on the chain this node follows.", base.TargetHeight)
	emit(step)

	if _, err := client.call(ctx, "invalidateblock", base.TargetHash); err != nil {
		return fail(ResetPhaseMoveBack, fmt.Errorf("move back to block %s: %w", base.TargetHash, err))
	}

	// A block left invalid sits off the active chain, so a retry on the same
	// target is refused. Every path from here clears the mark.
	reconsidered := false
	defer func() {
		if !reconsidered {
			_, _ = client.call(ctx, "reconsiderblock", base.TargetHash)
		}
	}()

	parked, _, err := coreTip(ctx, client)
	if err != nil {
		return fail(ResetPhaseMoveBack, err)
	}
	step = base
	step.Phase = ResetPhaseMoveBack
	step.CoreHeight = parked
	step.Message = fmt.Sprintf("Core dropped %d blocks and sits at %d.", base.BlocksTotal, parked)
	emit(step)

	// Core clears the mark and re-validates every dropped block before
	// reconsiderblock returns, so that one call is the whole replay. A poll on
	// the side is the only way to report how far it got.
	replay := make(chan error, 1)
	go func() {
		_, err := client.call(ctx, "reconsiderblock", base.TargetHash)
		replay <- err
	}()

	step = base
	step.Phase = ResetPhaseSyncForward
	step.CoreHeight = parked
	step.Message = fmt.Sprintf("Core replays %d blocks from disk.", base.BlocksTotal)
	emit(step)

	if err := awaitResetReplay(ctx, client, base, parked, replay, emit); err != nil {
		return fail(ResetPhaseSyncForward, err)
	}
	// A reconsiderblock that never reached Core leaves the mark in force, so
	// only a call Core answered retires the retry.
	reconsidered = true

	final, _, err := coreTip(ctx, client)
	if err != nil {
		return fail(ResetPhaseSyncForward, err)
	}
	return final, nil
}

// awaitResetReplay reports Core's tip while reconsiderblock runs. A tip it
// cannot read counts as no answer: Core refuses RPC while it re-validates a
// long branch, and one refusal must not end the replay.
func awaitResetReplay(
	ctx context.Context,
	client *CoreStatusClient,
	base ResetProgress,
	parked uint32,
	replay <-chan error,
	emit func(ResetProgress),
) error {
	last := parked
	for {
		select {
		case err := <-replay:
			if err != nil {
				return fmt.Errorf("sync forward from block %s: %w", base.TargetHash, err)
			}
			return nil
		case <-ctx.Done():
			// The run context outlives the request, so only a shutdown lands
			// here. Core owns the replay either way.
			return ctx.Err()
		case <-time.After(resetSyncPollInterval):
		}

		height, _, err := coreTip(ctx, client)
		if err != nil || height <= last {
			continue
		}
		last = height
		step := base
		step.Phase = ResetPhaseSyncForward
		step.CoreHeight = height
		step.BlocksDone = height - base.TargetHeight + 1
		step.Message = fmt.Sprintf("Core is at %d of %d.", height, base.TipHeight)
		emit(step)
	}
}
