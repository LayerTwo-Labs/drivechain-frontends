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

type countingChecker struct{ calls atomic.Int32 }

func (c *countingChecker) Check(context.Context) error {
	c.calls.Add(1)
	return nil
}

func TestChainDataHealthCheckReadsTheEngine(t *testing.T) {
	var down atomic.Bool
	var infos atomic.Int32
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(ctx context.Context, method string, _ ...any) (json.RawMessage, error) {
		if down.Load() {
			return nil, errors.New("connection refused")
		}
		if method == "getblockchaininfo" {
			infos.Add(1)
			return json.RawMessage(`{"chain":"signet","blocks":5,"headers":5,"bestblockhash":"a"}`), nil
		}
		<-ctx.Done()
		return nil, ctx.Err()
	}})
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go engine.Run(ctx)

	first := &countingChecker{}
	check := &chainDataHealthCheck{engine: engine, first: first}
	require.NoError(t, check.Check(t.Context()))
	require.Equal(t, int32(1), first.calls.Load())
	require.Eventually(t, func() bool { return engine.Health() == nil }, time.Second, time.Millisecond)

	before := infos.Load()
	for range 20 {
		require.NoError(t, check.Check(t.Context()))
	}
	require.Equal(t, int32(1), first.calls.Load())
	require.Equal(t, before, infos.Load(), "a check reads memory, not Core")

	down.Store(true)
	cancel()
	require.Eventually(t, func() bool { return !engine.Running() }, time.Second, time.Millisecond)
	require.NoError(t, check.Check(t.Context()), "a stopped engine falls back to the probe")
	require.Equal(t, int32(2), first.calls.Load())
}

func TestChainDataHealthCheckReportsPresync(t *testing.T) {
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(ctx context.Context, method string, _ ...any) (json.RawMessage, error) {
		return json.RawMessage(`{"chain":"main","blocks":0,"headers":0,"bestblockhash":"g"}`), nil
	}})
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go engine.Run(ctx)

	check := &chainDataHealthCheck{engine: engine, first: &countingChecker{}}
	require.NoError(t, check.Check(t.Context()))
	require.Eventually(t, func() bool { return engine.Health() == nil }, time.Second, time.Millisecond)
	require.EqualError(t, check.Check(t.Context()), PresyncMessagePrefix)
}

func TestCoreCacheTTLDropsWhileTheEngineRuns(t *testing.T) {
	o := &Orchestrator{chainData: chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(ctx context.Context, _ string, _ ...any) (json.RawMessage, error) {
		<-ctx.Done()
		return nil, ctx.Err()
	}})}
	require.Equal(t, time.Second, o.coreCacheTTL(time.Second))
	o.chainData.Start(t.Context())
	require.Zero(t, o.coreCacheTTL(time.Second), "a new block reaches GetSyncStatus with no TTL delay")
}

func TestSidechainRunningCopiesNoConfigs(t *testing.T) {
	var configs []BinaryConfig
	for _, name := range []string{"bitcoind", "enforcer", "thunder", "bitnames", "bitassets", "zside", "truthcoin", "photon", "coinshift"} {
		layer := 2
		if name == "bitcoind" || name == "enforcer" {
			layer = 1
		}
		configs = append(configs, BinaryConfig{Name: name, BinaryName: name, ChainLayer: layer})
	}
	o := New(t.TempDir(), "regtest", t.TempDir(), configs, zerolog.Nop())

	require.False(t, o.SidechainRunning())
	require.Zero(t, testing.AllocsPerRun(100, func() { o.SidechainRunning() }))
}
