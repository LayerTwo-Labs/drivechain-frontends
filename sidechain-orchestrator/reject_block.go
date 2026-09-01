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

// RejectOutcome says what a reject did to the chain Core follows.
type RejectOutcome int

const (
	// RejectOutcomeSwitchedBranch means Core dropped the block and followed
	// another branch.
	RejectOutcomeSwitchedBranch RejectOutcome = iota + 1
	// RejectOutcomeParkedOnParent means Core dropped the block and parked on
	// its parent, with no branch to take.
	RejectOutcomeParkedOnParent
	// RejectOutcomeAlreadyInactive means the block already sat off the active
	// chain, so the tip did not move.
	RejectOutcomeAlreadyInactive
)

// RejectBlockResult reports where Core landed after a reject.
type RejectBlockResult struct {
	CoreHeight      uint32
	CoreTipHash     string
	Outcome         RejectOutcome
	EnforcerChecked bool
	EnforcerHeight  uint32
	EnforcerRebuilt bool
	EnforcerError   string
}

// AcceptBlockResult reports where Core landed after a block is accepted again.
type AcceptBlockResult struct {
	CoreHeight      uint32
	CoreTipHash     string
	EnforcerChecked bool
	EnforcerHeight  uint32
	EnforcerRebuilt bool
	EnforcerError   string
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
		Int("outcome", int(result.Outcome)).
		Msg("rejected a block")

	// Core already moved, so a failure past this point is reported in the
	// result rather than as an error. An error-only answer would hide the
	// mutation and take the caller's undo path with it.
	rec := o.reconcileEnforcer(ctx, client, enforcerWait)
	result.EnforcerChecked = rec.Checked
	result.EnforcerHeight = rec.Height
	result.EnforcerRebuilt = rec.Rebuilt
	result.EnforcerError = rec.Err
	if rec.Err != "" {
		o.log.Error().Str("error", rec.Err).Msg("core moved but the enforcer could not be reconciled")
	}
	return result, nil
}

// AcceptBlock undoes RejectBlock. Core clears the mark on the block, on its
// ancestors and on its descendants, then re-checks them. Taking the branch back
// is a reorg like the reject, so the enforcer gets the same reconciliation.
func (o *Orchestrator) AcceptBlock(ctx context.Context, blockHash string, enforcerWait time.Duration) (AcceptBlockResult, error) {
	if enforcerWait <= 0 {
		enforcerWait = defaultEnforcerReorgWait
	}

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

	rec := o.reconcileEnforcer(ctx, client, enforcerWait)
	result.EnforcerChecked = rec.Checked
	result.EnforcerHeight = rec.Height
	result.EnforcerRebuilt = rec.Rebuilt
	result.EnforcerError = rec.Err
	if rec.Err != "" {
		o.log.Error().Str("error", rec.Err).Msg("core moved but the enforcer could not be reconciled")
	}
	return result, nil
}

// enforcerReconciliation reports what happened to the enforcer after a Core
// move. Checked stays false when the enforcer was never asked, so a caller
// never reads Height as an observed tip.
type enforcerReconciliation struct {
	Checked bool
	Height  uint32
	Rebuilt bool
	Err     string
}

// reconcileEnforcer brings the enforcer back onto the chain Core follows. It
// asks whether the enforcer sits off that chain rather than whether this call
// moved it, so a retry after a failed read still repairs the divergence.
func (o *Orchestrator) reconcileEnforcer(ctx context.Context, client *CoreStatusClient, wait time.Duration) enforcerReconciliation {
	// A connect-only enforcer answers RPC without ever entering ProcessManager,
	// so IsRunning would read it as stopped and skip a reconciliation it needs.
	if !o.enforcerReachable() {
		o.log.Info().Msg("enforcer is stopped, so it reads the new chain on its next start")
		return enforcerReconciliation{}
	}

	hash, tip, err := o.ChainTip(ctx)
	if err == nil {
		onChain, chainErr := blockOnActiveChain(ctx, client, hash)
		if chainErr == nil && onChain {
			o.log.Info().Int32("enforcer_tip", tip).Msg("enforcer already sits on core's chain")
			return enforcerReconciliation{Checked: true, Height: uint32(max(tip, 0))}
		}
	}

	height, outcome := o.awaitEnforcerRollback(ctx, client, wait)
	switch outcome {
	case enforcerWaitFollowed:
		return enforcerReconciliation{Checked: true, Height: height}
	case enforcerWaitCanceled:
		// The caller left, which says nothing about the enforcer. Deleting a
		// validator chain over a cancelled wait costs a full rebuild.
		return enforcerReconciliation{
			Checked: true,
			Height:  height,
			Err:     "the wait for the enforcer was cancelled, so its chain was left alone",
		}
	}

	// A rebuild stops the daemon, deletes its chain and starts it again. None of
	// that is ours to do for an enforcer this process never started.
	if !o.process.IsRunning("enforcer") {
		return enforcerReconciliation{
			Checked: true,
			Height:  height,
			Err:     "the enforcer did not follow, and this process does not manage it, so its chain was left alone",
		}
	}

	if err := o.rebuildEnforcerChain(ctx, wait); err != nil {
		return enforcerReconciliation{Checked: true, Height: height, Err: err.Error()}
	}
	return enforcerReconciliation{Checked: true, Height: height, Rebuilt: true}
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

	// A block already off the active chain moves nothing, so the tip differing
	// from its parent says only that the two were never related.
	outcome := RejectOutcomeSwitchedBranch
	switch {
	case header.Confirmations < 0:
		outcome = RejectOutcomeAlreadyInactive
	case tipHash == header.PreviousBlockHash:
		outcome = RejectOutcomeParkedOnParent
	}

	return RejectBlockResult{
		CoreHeight:  tipHeight,
		CoreTipHash: tipHash,
		Outcome:     outcome,
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

// enforcerWaitOutcome says why the wait for the enforcer ended. A cancelled
// wait is not a verdict on the enforcer, so it must not cost a chain rebuild.
type enforcerWaitOutcome int

const (
	enforcerWaitFollowed enforcerWaitOutcome = iota
	enforcerWaitExpired
	enforcerWaitCanceled
)

// awaitEnforcerRollback watches the enforcer until its tip sits on the chain
// Core follows. A tip it cannot read counts as no answer, not as a failure:
// the enforcer refuses GetChainTip while it reorganizes.
func (o *Orchestrator) awaitEnforcerRollback(ctx context.Context, client *CoreStatusClient, wait time.Duration) (uint32, enforcerWaitOutcome) {
	deadline := time.Now().Add(wait)
	var tip int32
	for {
		hash, height, err := o.ChainTip(ctx)
		if err == nil {
			tip = height
			onChain, chainErr := blockOnActiveChain(ctx, client, hash)
			if chainErr == nil && onChain {
				o.log.Info().Int32("enforcer_tip", tip).Str("enforcer_hash", hash).Msg("enforcer followed the reject")
				return uint32(max(tip, 0)), enforcerWaitFollowed
			}
		}
		if !time.Now().Before(deadline) {
			o.log.Warn().
				Int32("enforcer_tip", tip).
				Msg("enforcer did not follow the reject, rebuilding its validator chain")
			return uint32(max(tip, 0)), enforcerWaitExpired
		}
		select {
		case <-ctx.Done():
			o.log.Warn().Int32("enforcer_tip", tip).Msg("the wait for the enforcer was cancelled")
			return uint32(max(tip, 0)), enforcerWaitCanceled
		case <-time.After(enforcerReorgPollInterval):
		}
	}
}

// rebuildEnforcerChain deletes the enforcer's validator chain and starts it
// again. It re-reads every block from the local Core, so this costs no network
// download. It returns only once the restart is over: the chain is already
// gone, so a rebuild reported over a stopped enforcer hides a wiped one.
func (o *Orchestrator) rebuildEnforcerChain(ctx context.Context, wait time.Duration) error {
	if err := o.stopForNetworkSwap(ctx, "enforcer"); err != nil {
		return fmt.Errorf("stop the enforcer: %w", err)
	}

	// Leave it stopped rather than report a rebuild it never made: a restart
	// here reopens the very chain that failed to follow Core's branch.
	if err := config.WipeEnforcerChainDataSync(config.NetworkFromString(o.Network), o.log); err != nil {
		return fmt.Errorf("clear the enforcer chain: %w", err)
	}

	// RestartDaemon starts the one daemon whatever the active wallet is. The
	// L1 boot path serves an electrum wallet no local backends, so it would
	// report success and leave the enforcer stopped with no chain data.
	bootCh, err := o.RestartDaemon(context.Background(), "enforcer")
	if err != nil {
		return fmt.Errorf("start the enforcer: %w", err)
	}
	if err := o.awaitEnforcerBoot(bootCh, wait); err != nil {
		o.log.Error().Err(err).Msg("enforcer restart after the reject failed")
		return fmt.Errorf("the enforcer chain was cleared but the enforcer did not come back: %w", err)
	}
	return nil
}

// awaitEnforcerBoot waits for a restart to finish and reports what it left
// behind. A boot stream that ends without an error says the start path ran, so
// a live process is the only trustworthy evidence that the restart took.
func (o *Orchestrator) awaitEnforcerBoot(bootCh <-chan StartupProgress, wait time.Duration) error {
	if err := drainEnforcerBoot(bootCh, wait); err != nil {
		return err
	}
	if !o.enforcerReachable() {
		return fmt.Errorf("the enforcer is not running")
	}
	return nil
}

// drainEnforcerBoot reads a boot stream to its end and returns the first
// failure it carries. A stream that neither fails nor ends within wait is a
// failure of its own: the caller holds the reject lock while it waits.
func drainEnforcerBoot(bootCh <-chan StartupProgress, wait time.Duration) error {
	timeout := time.NewTimer(wait)
	defer timeout.Stop()
	for {
		select {
		case p, ok := <-bootCh:
			if !ok {
				return nil
			}
			if p.Error != nil {
				return p.Error
			}
		case <-timeout.C:
			return fmt.Errorf("the restart did not finish within %s", wait)
		}
	}
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
