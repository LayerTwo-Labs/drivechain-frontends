package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// defaultEnforcerReorgWait is how long the enforcer gets to follow a rollback
// on its own before its validator chain is deleted.
const defaultEnforcerReorgWait = 60 * time.Second

const enforcerReorgPollInterval = 2 * time.Second

// WipeUntilBlockResult reports what the rollback did.
type WipeUntilBlockResult struct {
	CoreHeight           uint32
	InvalidatedBlockHash string
	EnforcerHeight       uint32
	EnforcerRebuilt      bool
}

// WipeUntilBlock rolls the chain back to height in place of a full wipe. Core
// invalidates the first block above the height, which disconnects the branch
// but leaves every block on disk, so a later sync downloads nothing it already
// has. The enforcer has no rollback RPC: it gets a window to follow the
// reorg, and its validator chain is deleted only when it does not.
func (o *Orchestrator) WipeUntilBlock(ctx context.Context, height uint32, enforcerWait time.Duration) (WipeUntilBlockResult, error) {
	if enforcerWait <= 0 {
		enforcerWait = defaultEnforcerReorgWait
	}

	client, err := o.CoreStatusClient()
	if err != nil {
		return WipeUntilBlockResult{}, fmt.Errorf("bitcoin core rpc: %w", err)
	}

	hash, err := rollBackCore(ctx, client, height)
	if err != nil {
		return WipeUntilBlockResult{}, err
	}
	o.log.Info().Uint32("keep_until", height).Str("invalidated", hash).Msg("rolled the chain back")

	result := WipeUntilBlockResult{CoreHeight: height, InvalidatedBlockHash: hash}

	if !o.process.IsRunning("enforcer") {
		o.log.Info().Msg("enforcer is stopped, so it reads the rolled-back chain on its next start")
		return result, nil
	}

	enforcerHeight, followed := o.awaitEnforcerRollback(ctx, height, enforcerWait)
	if followed {
		result.EnforcerHeight = enforcerHeight
		return result, nil
	}

	if err := o.rebuildEnforcerChain(ctx); err != nil {
		return result, err
	}
	result.EnforcerRebuilt = true
	return result, nil
}

// awaitEnforcerRollback watches the enforcer's tip until it sits at or below
// height. A tip it cannot read counts as no answer, not as a failure: the
// enforcer refuses GetChainTip while it reorganizes.
func (o *Orchestrator) awaitEnforcerRollback(ctx context.Context, height uint32, wait time.Duration) (uint32, bool) {
	deadline := time.Now().Add(wait)
	for {
		_, tip, err := o.ChainTip(ctx)
		if err == nil && tip <= int32(height) {
			o.log.Info().Int32("enforcer_tip", tip).Msg("enforcer followed the rollback")
			return uint32(tip), true
		}
		if !time.Now().Before(deadline) {
			o.log.Warn().
				Int32("enforcer_tip", tip).
				Uint32("want", height).
				Msg("enforcer did not follow the rollback, rebuilding its validator chain")
			return uint32(max(tip, 0)), false
		}
		select {
		case <-ctx.Done():
			return uint32(max(tip, 0)), false
		case <-time.After(enforcerReorgPollInterval):
		}
	}
}

// rebuildEnforcerChain deletes the enforcer's validator chain and starts it
// again. Its wallet stays, and it re-reads every block from the local Core, so
// this costs no network download.
func (o *Orchestrator) rebuildEnforcerChain(ctx context.Context) error {
	if err := o.stopForNetworkSwap(ctx, "enforcer"); err != nil {
		return fmt.Errorf("stop the enforcer: %w", err)
	}

	config.WipeEnforcerChainDataSync(config.NetworkFromString(o.Network), o.log)

	bootCh, err := o.StartWithL1(context.Background(), "enforcer", StartOpts{})
	if err != nil {
		return fmt.Errorf("start the enforcer: %w", err)
	}
	go func() {
		for p := range bootCh {
			if p.Error != nil {
				o.log.Error().Err(p.Error).Msg("enforcer restart after the rollback failed")
			}
		}
	}()
	return nil
}

// rollBackCore invalidates the first block above height and returns its hash.
// Core disconnects the branch down to height and keeps every block on disk.
func rollBackCore(ctx context.Context, client *CoreStatusClient, height uint32) (string, error) {
	tip, err := client.GetBlockCount(ctx)
	if err != nil {
		return "", fmt.Errorf("read core tip: %w", err)
	}
	if int64(height) >= tip {
		return "", fmt.Errorf("height %d is not below the core tip %d", height, tip)
	}

	hash, err := blockHashAt(ctx, client, int64(height)+1)
	if err != nil {
		return "", err
	}
	if _, err := client.call(ctx, "invalidateblock", hash); err != nil {
		return "", fmt.Errorf("invalidate block %s: %w", hash, err)
	}

	newTip, err := client.GetBlockCount(ctx)
	if err != nil {
		return "", fmt.Errorf("read core tip after the rollback: %w", err)
	}
	if newTip != int64(height) {
		return "", fmt.Errorf("core tip is %d after the rollback, want %d", newTip, height)
	}
	return hash, nil
}

func blockHashAt(ctx context.Context, client *CoreStatusClient, height int64) (string, error) {
	raw, err := client.call(ctx, "getblockhash", height)
	if err != nil {
		return "", fmt.Errorf("get block hash at %d: %w", height, err)
	}
	var hash string
	if err := json.Unmarshal(raw, &hash); err != nil {
		return "", fmt.Errorf("decode block hash at %d: %w", height, err)
	}
	return hash, nil
}
