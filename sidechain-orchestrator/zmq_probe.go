package orchestrator

import (
	"context"
	"fmt"
	"net"
	"strings"
	"time"

	"github.com/rs/zerolog"
)

// extractZmqSequenceAddr scans enforcer args for --node-zmq-addr-sequence and
// returns the host:port portion. Returns "" if the flag isn't present (e.g.
// older enforcer configs without the migration applied).
func extractZmqSequenceAddr(args []string) string {
	for _, raw := range args {
		const flag = "--node-zmq-addr-sequence"
		if !strings.HasPrefix(raw, flag) {
			continue
		}
		val := strings.TrimPrefix(raw, flag)
		val = strings.TrimPrefix(val, "=")
		val = strings.TrimSpace(val)
		// Strip the "tcp://" scheme so net.Dial gets host:port.
		val = strings.TrimPrefix(val, "tcp://")
		if val != "" {
			return val
		}
	}
	return ""
}

// waitForZmqReachable polls the given host:port with TCP dials until the
// socket accepts connections or we exhaust the retry budget. It returns nil
// once the socket is reachable, or an error that explains the most likely
// misconfig (missing zmqpubsequence in bitcoin.conf) so the UI can surface
// it instead of letting the enforcer crash silently with exit code 1.
func waitForZmqReachable(ctx context.Context, hostPort string, log *zerolog.Logger) error {
	const (
		dialTimeout = 1 * time.Second
		retryEvery  = 5 * time.Second
		maxAttempts = 6 // ~30s wall-clock budget
	)

	for attempt := 1; attempt <= maxAttempts; attempt++ {
		dialCtx, cancel := context.WithTimeout(ctx, dialTimeout)
		conn, err := (&net.Dialer{}).DialContext(dialCtx, "tcp", hostPort)
		cancel()
		if err == nil {
			_ = conn.Close()
			if attempt > 1 && log != nil {
				log.Info().Str("zmq_addr", hostPort).Int("attempts", attempt).
					Msg("bitcoind ZMQ socket reachable, proceeding with enforcer")
			}
			return nil
		}
		if log != nil {
			log.Warn().Err(err).Str("zmq_addr", hostPort).Int("attempt", attempt).Int("max", maxAttempts).
				Msg("bitcoind ZMQ socket not reachable yet, retrying")
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(retryEvery):
		}
	}

	return fmt.Errorf(
		"bitcoind ZMQ socket %s unreachable after %d attempts — check that bitcoin.conf includes 'zmqpubsequence=tcp://%s'",
		hostPort, maxAttempts, hostPort,
	)
}
