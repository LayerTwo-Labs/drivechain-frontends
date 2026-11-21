package main

import "context"

// onCoreUp calls up each time connected turns true after a change.
func onCoreUp(ctx context.Context, changed <-chan struct{}, connected func() bool, up func()) {
	was := false
	for {
		select {
		case <-ctx.Done():
			return
		case <-changed:
		}
		now := connected()
		if now && !was {
			up()
		}
		was = now
	}
}
