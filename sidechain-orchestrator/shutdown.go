package orchestrator

import (
	"context"
	"os"
	"time"
)

// Internal orchestratord shutdown state. The wire format (GetShutdownState
// in orchestrator.proto) exposes this as two bools (draining, will_exit).
const (
	shutdownStateRunning      int32 = 0
	shutdownStateDrainingExit int32 = 1 // drain in progress, os.Exit at end
	shutdownStateDrainingKeep int32 = 2 // drain in progress, stay alive at end
)

// ShutdownDraining reports whether a drain is currently in progress and, if
// so, whether the daemon will os.Exit when it completes.
func (o *Orchestrator) ShutdownDraining() (draining, willExit bool) {
	o.shutdownMu.Lock()
	defer o.shutdownMu.Unlock()
	return o.shutdownState != shutdownStateRunning, o.shutdownState == shutdownStateDrainingExit
}

// BeginShutdown kicks off the orchestratord shutdown sequence. Idempotent:
// subsequent calls while a drain is in flight are no-ops. Returns true iff
// this call initiated a fresh drain.
func (o *Orchestrator) BeginShutdown() bool {
	o.shutdownMu.Lock()
	if o.shutdownState != shutdownStateRunning {
		o.shutdownMu.Unlock()
		return false
	}
	o.shutdownState = shutdownStateDrainingExit
	o.shutdownIdle = make(chan struct{})
	idleCh := o.shutdownIdle
	o.shutdownMu.Unlock()

	go o.runShutdown(idleCh)
	return true
}

// runShutdown drains all managed children, then either os.Exit(0)s or stays
// alive depending on whether CancelShutdownExit flipped the bit while we were
// draining. In-flight binary stops always run to completion.
func (o *Orchestrator) runShutdown(idleCh chan struct{}) {
	progressCh, err := o.ShutdownAll(context.Background(), false)
	if err != nil {
		o.log.Error().Err(err).Msg("shutdown: ShutdownAll start failed")
	} else {
		for range progressCh {
		}
	}

	o.shutdownMu.Lock()
	final := o.shutdownState
	o.shutdownState = shutdownStateRunning
	o.shutdownIdle = nil
	close(idleCh)
	o.shutdownMu.Unlock()

	if final == shutdownStateDrainingExit {
		o.log.Info().Msg("shutdown drain complete; exiting")
		os.Exit(0)
	}
	o.log.Info().Msg("shutdown drain complete; staying alive (adopted by relaunched bitwindowd)")
}

// CancelShutdownExit flips the will-exit bit off if a drain is in progress
// and currently set to exit. Returns true iff the bit was flipped. In-flight
// binary stops continue regardless — see plan: in-flight stops are
// uncancellable by design.
func (o *Orchestrator) CancelShutdownExit() bool {
	o.shutdownMu.Lock()
	defer o.shutdownMu.Unlock()
	if o.shutdownState != shutdownStateDrainingExit {
		return false
	}
	o.shutdownState = shutdownStateDrainingKeep
	return true
}

// awaitDrainForBoot is the internal hook callers like StartWithL1 use to
// serialize a fresh-stack boot behind any in-flight drain from a previous
// bitwindowd session. If a drain is running, flips it to KEEP (so the
// daemon doesn't os.Exit when it finishes) and blocks until the in-flight
// stops complete. Surfaces a "Waiting for previous shutdown to finish..."
// startup-log entry on bitcoind + enforcer monitors so the bottom nav
// renders progress with no glue on the caller side.
//
// No-op when the daemon is RUNNING.
func (o *Orchestrator) awaitDrainForBoot(ctx context.Context) {
	o.shutdownMu.Lock()
	if o.shutdownState == shutdownStateRunning {
		o.shutdownMu.Unlock()
		return
	}
	wasExit := o.shutdownState == shutdownStateDrainingExit
	idleCh := o.shutdownIdle
	if wasExit {
		o.shutdownState = shutdownStateDrainingKeep
	}
	o.shutdownMu.Unlock()

	o.log.Info().Bool("was_exit", wasExit).Msg("adopting in-flight drain from previous session")

	const waitMsg = "Waiting for previous shutdown to finish..."
	now := time.Now()
	for _, name := range []string{"bitcoind", "enforcer"} {
		cfg, ok := o.configs[name]
		if !ok {
			continue
		}
		mon := o.getOrCreateMonitor(name, NewHealthChecker(cfg), nil)
		mon.AddStartupLog(now, waitMsg)
	}

	select {
	case <-idleCh:
	case <-ctx.Done():
	}
	o.log.Info().Msg("previous-session drain complete; proceeding to boot")
}

// AwaitShutdownIdle blocks until any in-flight drain completes. Returns
// immediately if no drain is active. Respects context cancellation.
func (o *Orchestrator) AwaitShutdownIdle(ctx context.Context) error {
	o.shutdownMu.Lock()
	if o.shutdownState == shutdownStateRunning {
		o.shutdownMu.Unlock()
		return nil
	}
	idleCh := o.shutdownIdle
	o.shutdownMu.Unlock()

	select {
	case <-idleCh:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}
