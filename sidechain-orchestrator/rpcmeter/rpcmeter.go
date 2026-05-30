// Package rpcmeter provides a Connect interceptor that meters RPC traffic
// through a handler — call counts, latency, and error counts per method —
// and logs a periodic per-method summary. It exists to answer "is BitWindow
// spamming bitcoind, and with what?" by attributing the orchestrator's hosted
// Bitcoin Core proxy traffic to individual methods at the one chokepoint every
// frontend call passes through.
package rpcmeter

import (
	"context"
	"sort"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
)

// Meter accumulates per-method stats over a window and logs a summary each
// tick. Safe for concurrent use.
type Meter struct {
	log      zerolog.Logger
	interval time.Duration

	mu    sync.Mutex
	stats map[string]*methodStat
}

type methodStat struct {
	count    int64
	errors   int64
	totalDur time.Duration
	maxDur   time.Duration
}

// New returns a Meter that logs a summary every interval and starts its
// reporter goroutine, which runs until ctx is cancelled. interval <= 0
// disables periodic reporting (the interceptor still records, but nothing is
// flushed) — used by tests.
func New(ctx context.Context, log zerolog.Logger, interval time.Duration) *Meter {
	m := &Meter{
		log:      log,
		interval: interval,
		stats:    make(map[string]*methodStat),
	}
	if interval > 0 {
		go m.report(ctx)
	}
	return m
}

// Interceptor returns a connect.Interceptor that records every unary call.
// Streaming calls pass through unmetered (the bitcoind proxy is all unary).
func (m *Meter) Interceptor() connect.Interceptor { return interceptor{m: m} }

func (m *Meter) record(procedure string, dur time.Duration, isErr bool) {
	method := shortMethod(procedure)

	m.mu.Lock()
	defer m.mu.Unlock()
	s := m.stats[method]
	if s == nil {
		s = &methodStat{}
		m.stats[method] = s
	}
	s.count++
	s.totalDur += dur
	if dur > s.maxDur {
		s.maxDur = dur
	}
	if isErr {
		s.errors++
	}
}

// report flushes a per-method summary every interval and resets the window.
func (m *Meter) report(ctx context.Context) {
	ticker := time.NewTicker(m.interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			m.flush()
		}
	}
}

func (m *Meter) flush() {
	m.mu.Lock()
	snapshot := m.stats
	m.stats = make(map[string]*methodStat)
	m.mu.Unlock()

	if len(snapshot) == 0 {
		return
	}

	type row struct {
		method string
		stat   *methodStat
	}
	rows := make([]row, 0, len(snapshot))
	var total int64
	for method, s := range snapshot {
		rows = append(rows, row{method, s})
		total += s.count
	}
	// Loudest method first.
	sort.Slice(rows, func(i, j int) bool { return rows[i].stat.count > rows[j].stat.count })

	perSec := float64(total) / m.interval.Seconds()
	ev := m.log.Info().
		Int64("total_calls", total).
		Float64("calls_per_sec", round2(perSec)).
		Dur("window", m.interval)

	for _, r := range rows {
		avg := time.Duration(0)
		if r.stat.count > 0 {
			avg = r.stat.totalDur / time.Duration(r.stat.count)
		}
		// One nested object per method: count, avg/max latency, errors.
		dict := zerolog.Dict().
			Int64("calls", r.stat.count).
			Dur("avg", avg).
			Dur("max", r.stat.maxDur)
		if r.stat.errors > 0 {
			dict = dict.Int64("errors", r.stat.errors)
		}
		ev = ev.Dict(r.method, dict)
	}
	ev.Msg("rpcmeter: bitcoind proxy traffic")
}

// shortMethod trims the leading service path so logs read "GetBlock" not
// "/bitcoin.bitcoind.v1alpha.BitcoinService/GetBlock".
func shortMethod(procedure string) string {
	if i := strings.LastIndex(procedure, "/"); i >= 0 && i < len(procedure)-1 {
		return procedure[i+1:]
	}
	return procedure
}

func round2(f float64) float64 {
	return float64(int64(f*100+0.5)) / 100
}

type interceptor struct{ m *Meter }

func (i interceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		if req.Spec().IsClient {
			return next(ctx, req)
		}
		start := time.Now()
		resp, err := next(ctx, req)
		i.m.record(req.Spec().Procedure, time.Since(start), err != nil)
		return resp, err
	}
}

func (i interceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return next
}

func (i interceptor) WrapStreamingHandler(next connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return next
}
