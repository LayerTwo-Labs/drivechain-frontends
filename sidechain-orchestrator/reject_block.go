package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// defaultEnforcerReorgWait is how long the enforcer gets to follow a reject on
// its own before its validator chain is deleted.
const defaultEnforcerReorgWait = 60 * time.Second

const enforcerReorgPollInterval = 2 * time.Second

// RejectBlockResult reports where Core landed after a reject.
type RejectBlockResult struct {
	CoreHeight      uint32
	CoreTipHash     string
	SwitchedBranch  bool
	EnforcerHeight  uint32
	EnforcerRebuilt bool
}

// AcceptBlockResult reports where Core landed after a block is accepted again.
type AcceptBlockResult struct {
	CoreHeight  uint32
	CoreTipHash string
}

// RejectBlock drops a block Core must not follow. Core disconnects it and every
// block above it, keeps them all on disk, and follows the best remaining valid
// branch on its own. The enforcer has no rollback RPC: it gets a window to
// follow the reorg, and its validator chain is deleted only when it does not.
func (o *Orchestrator) RejectBlock(ctx context.Context, blockHash string, enforcerWait time.Duration) (RejectBlockResult, error) {
	if enforcerWait <= 0 {
		enforcerWait = defaultEnforcerReorgWait
	}

	// An accept landing during the enforcer wait would restore the branch this
	// call is still reconciling against.
	o.rejectMu.Lock()
	defer o.rejectMu.Unlock()

	client, err := o.CoreStatusClient()
	if err != nil {
		return RejectBlockResult{}, fmt.Errorf("bitcoin core rpc: %w", err)
	}

	result, err := rejectBlockOnCore(ctx, client, blockHash)
	if err != nil {
		return RejectBlockResult{}, err
	}
	o.log.Info().
		Str("rejected", normalizeBlockHash(blockHash)).
		Uint32("core_height", result.CoreHeight).
		Bool("switched_branch", result.SwitchedBranch).
		Msg("rejected a block")

	if !o.process.IsRunning("enforcer") {
		o.log.Info().Msg("enforcer is stopped, so it reads the new chain on its next start")
		return result, nil
	}

	enforcerHeight, followed := o.awaitEnforcerRollback(ctx, client, enforcerWait)
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

// AcceptBlock undoes RejectBlock. Core clears the mark on the block, on its
// ancestors and on its descendants, then re-checks them.
func (o *Orchestrator) AcceptBlock(ctx context.Context, blockHash string) (AcceptBlockResult, error) {
	o.rejectMu.Lock()
	defer o.rejectMu.Unlock()

	client, err := o.CoreStatusClient()
	if err != nil {
		return AcceptBlockResult{}, fmt.Errorf("bitcoin core rpc: %w", err)
	}

	result, err := acceptBlockOnCore(ctx, client, blockHash)
	if err != nil {
		return AcceptBlockResult{}, err
	}
	o.log.Info().
		Str("accepted", normalizeBlockHash(blockHash)).
		Uint32("core_height", result.CoreHeight).
		Msg("accepted a block again")
	return result, nil
}

// rejectBlockOnCore invalidates the named block and reports the tip Core chose
// in its place. Core parks on the block's parent when it has nowhere else to
// go, so any other tip means it found another branch and followed it.
func rejectBlockOnCore(ctx context.Context, client *CoreStatusClient, blockHash string) (RejectBlockResult, error) {
	hash := normalizeBlockHash(blockHash)
	if hash == "" {
		return RejectBlockResult{}, fmt.Errorf("name the block to reject by its hash")
	}

	header, err := readBlockHeader(ctx, client, hash)
	if err != nil {
		return RejectBlockResult{}, err
	}

	if _, err := client.call(ctx, "invalidateblock", hash); err != nil {
		return RejectBlockResult{}, fmt.Errorf("reject block %s: %w", hash, err)
	}

	tipHeight, tipHash, err := coreTip(ctx, client)
	if err != nil {
		return RejectBlockResult{}, err
	}
	if tipHash == hash {
		return RejectBlockResult{}, fmt.Errorf("core still sits on block %s after the reject", hash)
	}

	return RejectBlockResult{
		CoreHeight:     tipHeight,
		CoreTipHash:    tipHash,
		SwitchedBranch: tipHash != header.PreviousBlockHash,
	}, nil
}

// acceptBlockOnCore clears the reject and reports the tip Core settles on.
func acceptBlockOnCore(ctx context.Context, client *CoreStatusClient, blockHash string) (AcceptBlockResult, error) {
	hash := normalizeBlockHash(blockHash)
	if hash == "" {
		return AcceptBlockResult{}, fmt.Errorf("name the block to accept by its hash")
	}
	if _, err := client.call(ctx, "reconsiderblock", hash); err != nil {
		return AcceptBlockResult{}, fmt.Errorf("accept block %s: %w", hash, err)
	}

	tipHeight, tipHash, err := coreTip(ctx, client)
	if err != nil {
		return AcceptBlockResult{}, err
	}
	return AcceptBlockResult{CoreHeight: tipHeight, CoreTipHash: tipHash}, nil
}

// blockOnActiveChain asks Core whether a block sits on the chain it follows.
// Core answers a negative confirmation count for a block on a branch it
// dropped, which is the only reliable way to tell the two apart: a height
// names no branch, and Core keeps syncing while the enforcer catches up.
func blockOnActiveChain(ctx context.Context, client *CoreStatusClient, hash string) (bool, error) {
	if hash == "" {
		return false, fmt.Errorf("no block hash to look up")
	}
	header, err := readBlockHeader(ctx, client, normalizeBlockHash(hash))
	if err != nil {
		return false, err
	}
	return header.Confirmations >= 0, nil
}

// awaitEnforcerRollback watches the enforcer until its tip sits on the chain
// Core follows. A tip it cannot read counts as no answer, not as a failure:
// the enforcer refuses GetChainTip while it reorganizes.
func (o *Orchestrator) awaitEnforcerRollback(ctx context.Context, client *CoreStatusClient, wait time.Duration) (uint32, bool) {
	deadline := time.Now().Add(wait)
	var tip int32
	for {
		hash, height, err := o.ChainTip(ctx)
		if err == nil {
			tip = height
			onChain, chainErr := blockOnActiveChain(ctx, client, hash)
			if chainErr == nil && onChain {
				o.log.Info().Int32("enforcer_tip", tip).Str("enforcer_hash", hash).Msg("enforcer followed the reject")
				return uint32(max(tip, 0)), true
			}
		}
		if !time.Now().Before(deadline) {
			o.log.Warn().
				Int32("enforcer_tip", tip).
				Msg("enforcer did not follow the reject, rebuilding its validator chain")
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

	// RestartDaemon starts the one daemon whatever the active wallet is. The
	// L1 boot path serves an electrum wallet no local backends, so it would
	// report success and leave the enforcer stopped with no chain data.
	bootCh, err := o.RestartDaemon(context.Background(), "enforcer")
	if err != nil {
		return fmt.Errorf("start the enforcer: %w", err)
	}
	go func() {
		for p := range bootCh {
			if p.Error != nil {
				o.log.Error().Err(p.Error).Msg("enforcer restart after the reject failed")
			}
		}
	}()
	return nil
}

// normalizeBlockHash puts a hash in the form Core answers with. Core takes
// either case but always answers in lower case.
func normalizeBlockHash(hash string) string {
	return strings.ToLower(strings.TrimSpace(hash))
}

type blockHeader struct {
	Height            int64  `json:"height"`
	Confirmations     int64  `json:"confirmations"`
	PreviousBlockHash string `json:"previousblockhash"`
}

func readBlockHeader(ctx context.Context, client *CoreStatusClient, hash string) (blockHeader, error) {
	raw, err := client.call(ctx, "getblockheader", hash)
	if err != nil {
		return blockHeader{}, fmt.Errorf("get block header %s: %w", hash, err)
	}
	var header blockHeader
	if err := json.Unmarshal(raw, &header); err != nil {
		return blockHeader{}, fmt.Errorf("decode block header %s: %w", hash, err)
	}
	return header, nil
}

func coreTip(ctx context.Context, client *CoreStatusClient) (uint32, string, error) {
	height, err := client.GetBlockCount(ctx)
	if err != nil {
		return 0, "", fmt.Errorf("read core tip: %w", err)
	}
	raw, err := client.call(ctx, "getblockhash", height)
	if err != nil {
		return 0, "", fmt.Errorf("get block hash at %d: %w", height, err)
	}
	var hash string
	if err := json.Unmarshal(raw, &hash); err != nil {
		return 0, "", fmt.Errorf("decode block hash at %d: %w", height, err)
	}
	return uint32(height), hash, nil
}
