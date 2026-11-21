package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"sync/atomic"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
)

func TestChainDataHealthCheckSeesCoreUpAtOnce(t *testing.T) {
	var down atomic.Bool
	down.Store(true)
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(ctx context.Context, method string, _ ...any) (json.RawMessage, error) {
		if down.Load() {
			return nil, errors.New("connection refused")
		}
		if method == "getblockchaininfo" {
			return json.RawMessage(`{"chain":"regtest","blocks":5,"headers":5,"bestblockhash":"a"}`), nil
		}
		<-ctx.Done()
		return nil, ctx.Err()
	}})
	go engine.Run(t.Context())

	check := &chainDataHealthCheck{engine: engine, first: &countingChecker{}}
	require.NoError(t, check.Check(t.Context()))
	require.Eventually(t, func() bool {
		err := engine.Health()
		return err != nil && !errors.Is(err, chaindata.ErrNoProbe)
	}, 2*time.Second, time.Millisecond)
	require.Error(t, check.Check(t.Context()))

	down.Store(false)
	start := time.Now()
	require.NoError(t, check.Check(t.Context()))
	require.Less(t, time.Since(start), 500*time.Millisecond)
	require.NoError(t, engine.Health())
}
