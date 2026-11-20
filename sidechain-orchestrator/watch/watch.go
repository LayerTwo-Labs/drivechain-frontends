// Package watch runs the send loop of a server stream that sends on change.
package watch

import (
	"context"
	"sync"
	"time"
)

// Changes sends the first value, then each value that differs from the
// last one sent. It reads on each wake from changed and on each recheck tick.
// A heartbeat goes out each heartbeatEvery, also while a read is slow.
func Changes[T any](
	ctx context.Context,
	changed <-chan struct{},
	recheck, heartbeatEvery time.Duration,
	read func() (T, error),
	same func(a, b T) bool,
	send func(T) error,
	heartbeat func() error,
) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	var sendMu sync.Mutex
	locked := func(f func() error) error {
		sendMu.Lock()
		defer sendMu.Unlock()
		return f()
	}
	beatErr := make(chan error, 1)
	go func() {
		ticker := time.NewTicker(heartbeatEvery)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				if err := locked(heartbeat); err != nil {
					beatErr <- err
					return
				}
			}
		}
	}()

	last, err := read()
	if err != nil {
		return err
	}
	if err := locked(func() error { return send(last) }); err != nil {
		return err
	}

	recheckTicker := time.NewTicker(recheck)
	defer recheckTicker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case err := <-beatErr:
			return err
		case <-changed:
		case <-recheckTicker.C:
		}
		next, err := read()
		if err != nil {
			return err
		}
		if same(last, next) {
			continue
		}
		if err := locked(func() error { return send(next) }); err != nil {
			return err
		}
		last = next
	}
}
