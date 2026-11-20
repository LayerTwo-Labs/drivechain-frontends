package chaindata

import (
	"context"
	"fmt"
	"time"

	zmq "github.com/go-zeromq/zmq4"
)

// zmqJoinDelay covers the time a new ZMQ subscription needs before Core
// sends it messages. Mempool reads go to Core until it ends.
const zmqJoinDelay = 200 * time.Millisecond

func (e *Engine) runZMQ(ctx context.Context) {
	for ctx.Err() == nil {
		addr := e.zmqAddr()
		if addr == "" || e.Health() != nil {
			e.sleepZMQ(ctx)
			continue
		}
		err := e.subscribe(ctx, addr)
		if e.zmqUp.Swap(false) || err != nil && ctx.Err() == nil {
			e.log.Info().Err(err).Str("addr", addr).Msg("zmq sequence feed stopped")
		}
		e.sleepZMQ(ctx)
	}
}

func (e *Engine) sleepZMQ(ctx context.Context) {
	t := time.NewTimer(retryDelay)
	defer t.Stop()
	select {
	case <-ctx.Done():
	case <-t.C:
	}
}

// subscribe reads Core's sequence feed until it fails. An A or R message is
// a mempool change; a C or D message is a new tip.
func (e *Engine) subscribe(ctx context.Context, addr string) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	e.mu.Lock()
	e.zmqCancel = cancel
	e.mu.Unlock()
	defer func() {
		e.mu.Lock()
		e.zmqCancel = nil
		e.mu.Unlock()
	}()

	sub := zmq.NewSub(ctx)
	defer sub.Close() //nolint:errcheck // the feed is gone either way
	if err := sub.Dial(addr); err != nil {
		return fmt.Errorf("dial %s: %w", addr, err)
	}
	if err := sub.SetOption(zmq.OptionSubscribe, "sequence"); err != nil {
		return fmt.Errorf("subscribe to sequence: %w", err)
	}
	joined := time.AfterFunc(zmqJoinDelay, func() {
		e.log.Info().Str("addr", addr).Msg("zmq sequence feed joined")
		e.zmqUp.Store(true)
		e.Fire(EventMempool)
	})
	defer joined.Stop()

	for {
		msg, err := sub.Recv()
		if err != nil {
			return fmt.Errorf("receive: %w", err)
		}
		if len(msg.Frames) < 2 || string(msg.Frames[0]) != "sequence" || len(msg.Frames[1]) < 33 {
			continue
		}
		switch msg.Frames[1][32] {
		case 'A', 'R':
			e.Fire(EventMempool)
		case 'C', 'D':
			e.kick()
		}
	}
}
