package api

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strings"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// depositAncestorLimit is how deep a chain of unconfirmed deposits may go. Core
// refuses a transaction whose unconfirmed ancestors reach its own limit, so a
// deposit past this point cannot enter the mempool at all.
const depositAncestorLimit = 21

// treasuryOutpoint is one sidechain treasury output: the input a deposit spends.
type treasuryOutpoint struct {
	txid      string
	vout      int
	valueSats int64
	// ancestors counts the unconfirmed deposits this one already builds on.
	ancestors int
}

// errTreasuryChainFull says the unconfirmed deposit chain reached the mempool
// ancestor limit. A block must land before the slot takes another deposit.
// errTreasurySpentElsewhere says a transaction other than a deposit took the
// treasury output, so no deposit can build on it until a block lands.
var errTreasurySpentElsewhere = errors.New("another transaction already spends the treasury output of this slot; wait for the next block")

var errTreasuryChainFull = errors.New("the unconfirmed deposits of this slot reached the mempool limit; wait for the next block")

// treasuryTip follows the treasury output from the enforcer's confirmed ctip
// through every unconfirmed deposit that spends it, and returns the one nothing
// spends yet. A deposit must build on that output: the enforcer only sees
// confirmed state, so its ctip goes stale the moment anybody deposits.
//
// A chain source that cannot name a spender stops the walk, and the caller gets
// the last outpoint it proved. That is the confirmed ctip on an Electrum
// backend, which is the behaviour the slot had before this walk existed.
func treasuryTip(
	ctx context.Context, chain wallet.ChainSource, slot uint8, ctip treasuryOutpoint,
) (treasuryOutpoint, error) {
	script := orchestrator.M8TreasuryScript(slot)
	tip := ctip

	for tip.ancestors < depositAncestorLimit {
		spender, spent, err := chain.SpenderOf(ctx, tip.txid, tip.vout)
		switch {
		case errors.Is(err, wallet.ErrSpenderUnknown):
			return tip, nil
		case err != nil:
			return treasuryOutpoint{}, fmt.Errorf("read the spender of treasury %s:%d: %w", tip.txid, tip.vout, err)
		case !spent:
			return tip, nil
		}

		next, err := treasuryOutputOf(ctx, chain, spender, script)
		if err != nil {
			return treasuryOutpoint{}, err
		}
		// Something already took this outpoint and paid no treasury output, so
		// it is a withdrawal or another treasury spend. Building on a spent
		// outpoint makes a conflict, so the caller waits for a block.
		if next == nil {
			return treasuryOutpoint{}, fmt.Errorf("%w: %s spends treasury %s:%d",
				errTreasurySpentElsewhere, spender, tip.txid, tip.vout)
		}
		next.ancestors = tip.ancestors + 1
		tip = *next
	}
	return treasuryOutpoint{}, errTreasuryChainFull
}

// treasuryScriptMatches reports whether an output script hex is the slot's
// treasury script.
func treasuryScriptMatches(scriptHex string, script []byte) bool {
	return strings.EqualFold(scriptHex, hex.EncodeToString(script))
}

// treasuryOutputOf finds the output of txid that pays the slot's treasury
// script. It returns nil when the transaction pays none.
func treasuryOutputOf(
	ctx context.Context, chain wallet.ChainSource, txid string, script []byte,
) (*treasuryOutpoint, error) {
	tx, err := chain.GetRawTransaction(ctx, txid)
	if err != nil {
		return nil, fmt.Errorf("read deposit %s: %w", txid, err)
	}
	if tx == nil {
		return nil, fmt.Errorf("read deposit %s: the chain source returned nothing", txid)
	}
	for _, out := range tx.Vout {
		if !treasuryScriptMatches(out.ScriptPubKey.Hex, script) {
			continue
		}
		return &treasuryOutpoint{
			txid:      txid,
			vout:      out.N,
			valueSats: int64(math.Round(out.Value * 1e8)),
		}, nil
	}
	return nil, nil
}

// firstTreasuryOf finds the treasury output an unconfirmed deposit of ours
// already created for a slot the enforcer still reports as unfunded.
//
// The enforcer only sees confirmed blocks, so a slot stays nil to it until the
// very first deposit confirms. Without this a second deposit in that window
// builds a rival treasury output carrying only its own amount, and one of the
// two can never take the slot.
func (h *WalletHandler) firstTreasuryOf(
	ctx context.Context, chain wallet.ChainSource, slot uint8,
) (*treasuryOutpoint, error) {
	deposits, err := h.svc.SidechainDeposits(ctx, uint32(slot), "")
	if err != nil {
		return nil, fmt.Errorf("read the deposits of slot %d: %w", slot, err)
	}
	script := orchestrator.M8TreasuryScript(slot)
	// The drop stamp is not consulted: the watch needs two agreeing passes and
	// lifts a stamp a minute late, so a deposit can carry one while it still
	// lives. The chain decides, and a transaction it has lost answers
	// ErrTxNotFound below.
	for _, d := range deposits {
		out, err := treasuryOutputOf(ctx, chain, d.Txid, script)
		switch {
		case errors.Is(err, wallet.ErrTxNotFound):
			// The chain holds no such transaction, so it created no treasury
			// output. A later record may still name a live one.
			continue
		case err != nil:
			// The source could not answer. Treating that as "no treasury"
			// makes this deposit build a rival output for the slot.
			return nil, err
		}
		if out != nil {
			// This deposit is unconfirmed by definition: the enforcer reports
			// no ctip until one confirms. So it is already an ancestor of
			// whatever spends its treasury output.
			out.ancestors = 1
			return out, nil
		}
	}
	return nil, nil
}

// depositStart is the treasury output a new deposit builds on, or nil when the
// slot holds none at all and this deposit creates the first one.
//
// The enforcer only sees confirmed blocks, so its ctip goes stale the moment
// anybody deposits, and it reads nil until the very first deposit confirms.
func (h *WalletHandler) depositStart(
	ctx context.Context, treasury sidechainTreasury, walletID string, slot uint8,
) (*treasuryOutpoint, error) {
	if ctip := treasury.ctip; ctip != nil {
		return &treasuryOutpoint{
			txid:      ctip.GetTxid().GetHex().GetValue(),
			vout:      int(ctip.Vout),
			valueSats: int64(ctip.Value),
		}, nil
	}
	return h.firstTreasuryOf(ctx, h.engine.ChainForWallet(walletID), slot)
}
