package api

import "time"

// WatchHeartbeatInterval is the cadence at which server-streaming Watch*
// handlers emit idle keepalive frames when no real state changes happen.
//
// This MUST stay in lock-step with the client-side StreamSupervisor's
// heartbeat timeout. Concretely the relationship is:
//
//	clientHeartbeatTimeout > 2 * WatchHeartbeatInterval
//
// The client computes worst-case inter-frame gap as ~2× the server interval
// (a real send right before the heartbeat ticker fires resets the ticker,
// pushing the next heartbeat one full interval out). Anything ≤ 2× would
// produce spurious "dead stream" detections under perfectly healthy
// conditions.
//
// Sail_ui's StreamSupervisor defaults to 12s timeout against this 5s
// interval — a 2.4× margin, which absorbs jitter from GC pauses, slow
// network round-trips, and the supervisor's 2s watchdog tick granularity.
const WatchHeartbeatInterval = 5 * time.Second
