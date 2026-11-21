package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
)

// chainDataHealthCheck reads Core's health from the chain data engine. The
// first check probes Core itself and points the engine at the endpoint.
type chainDataHealthCheck struct {
	engine *chaindata.Engine
	first  HealthChecker

	once sync.Once
}

func (h *chainDataHealthCheck) Check(ctx context.Context) error {
	probed := false
	h.once.Do(func() {
		h.engine.Restart()
		probed = true
	})
	if probed || !h.engine.Running() {
		return h.first.Check(ctx)
	}
	raw, err := h.engine.Get(chaindata.KindBlockchainInfo)
	if errors.Is(err, chaindata.ErrNoProbe) {
		return h.first.Check(ctx)
	}
	if err != nil {
		return err
	}
	var info struct {
		Chain   string `json:"chain"`
		Blocks  int64  `json:"blocks"`
		Headers int64  `json:"headers"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return fmt.Errorf("decode getblockchaininfo: %w", err)
	}
	if info.Chain != "regtest" && info.Blocks == 0 && info.Headers == 0 {
		return fmt.Errorf("%s", PresyncMessagePrefix)
	}
	return nil
}

// ChainData is the engine that holds Core's chain, mempool and wallet reads.
func (o *Orchestrator) ChainData() *chaindata.Engine {
	return o.chainData
}

func (o *Orchestrator) callCore(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
	client, err := o.CoreStatusClient()
	if err != nil {
		return nil, err
	}
	return client.call(ctx, method, params...)
}

func (o *Orchestrator) callCoreBatch(ctx context.Context, method string, params [][]any) ([]chaindata.BatchResult, error) {
	client, err := o.CoreStatusClient()
	if err != nil {
		return nil, err
	}
	results, err := CallBitcoindRPCBatch(ctx, client.url, client.user, client.password, method, params)
	if err != nil {
		return nil, err
	}
	out := make([]chaindata.BatchResult, len(results))
	for i, r := range results {
		out[i] = chaindata.BatchResult(r)
	}
	return out, nil
}

func (o *Orchestrator) zmqSequenceAddr() string {
	if o.BitcoinConf == nil {
		return ""
	}
	return o.BitcoinConf.ZMQSequenceAddress()
}

// blockchainInfo reads getblockchaininfo from the engine, or from Core while
// the engine does not run.
func (o *Orchestrator) blockchainInfo(ctx context.Context) (json.RawMessage, error) {
	if o.chainData.Running() {
		raw, err := o.chainData.Get(chaindata.KindBlockchainInfo)
		if !errors.Is(err, chaindata.ErrNoProbe) {
			return raw, err
		}
	}
	return o.callCore(ctx, "getblockchaininfo")
}

// coreCacheTTL is ttl while the engine does not run. The engine holds the
// newest Core state, so a second cache on top of it only delays a new block.
func (o *Orchestrator) coreCacheTTL(ttl time.Duration) time.Duration {
	if o.chainData.Running() {
		return 0
	}
	return ttl
}

// SidechainRunning reports whether a layer-2 sidechain process runs.
func (o *Orchestrator) SidechainRunning() bool {
	names := make([]string, 0, 16)
	o.mu.RLock()
	for name, cfg := range o.configs {
		if cfg.ChainLayer == 2 {
			names = append(names, name)
		}
	}
	o.mu.RUnlock()
	return slices.ContainsFunc(names, o.process.IsRunning)
}
