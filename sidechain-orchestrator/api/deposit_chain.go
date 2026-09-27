package api

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

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
// errTreasuryAmbiguous says the slot carries rival unconfirmed treasuries, so
// no deposit can extend either. Only a block settles which one wins.
var errTreasuryAmbiguous = errors.New("this slot holds rival unconfirmed treasury outputs; wait for the next block")

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
	recorded recordedChain,
) (treasuryOutpoint, error) {
	script := orchestrator.M8TreasuryScript(slot)
	tip := ctip

	for tip.ancestors < depositAncestorLimit {
		spender, spent, err := chain.SpenderOf(ctx, tip.txid, tip.vout)
		switch {
		case errors.Is(err, wallet.ErrSpenderUnknown):
			// Electrum has no such call, and the built-in mainnet source is
			// Electrum only. Our own records name the deposits we broadcast,
			// and the parent links read with plain transaction reads.
			return recorded(ctx, chain, script, tip)
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
// Each deposit reads through the chain source of the wallet that broadcast it.
// Only that backend speaks for its own transaction: a Core node holds a deposit
// a public Esplora host has not received yet, and the absent answer builds a
// rival treasury output.
func (h *WalletHandler) firstTreasuryOf(
	ctx context.Context, sourceFor func(walletID string) wallet.ChainSource, slot uint8,
) (*treasuryOutpoint, error) {
	deposits, err := h.svc.SidechainDeposits(ctx, uint32(slot), "")
	if err != nil {
		return nil, fmt.Errorf("read the deposits of slot %d: %w", slot, err)
	}
	script := orchestrator.M8TreasuryScript(slot)
	// A stamp alone does not skip a deposit: the watch needs two agreeing passes
	// and lifts a stamp a minute late, so a deposit can carry one while it still
	// lives. The chain decides, and a transaction it has lost answers
	// ErrTxNotFound below.
	var bases []*treasuryOutpoint
	for _, d := range deposits {
		source := sourceFor(d.WalletID)
		out, err := treasuryOutputOf(ctx, source, d.Txid, script)
		switch {
		case errors.Is(err, wallet.ErrTxNotFound):
			// The chain holds no such transaction, so it created no treasury
			// output. A later record may still name a live one.
			continue
		case errors.Is(err, wallet.ErrTxUnreadable) && !d.DroppedAt.IsZero():
			// Core without a txindex reads no transaction outside its mempool,
			// so a stamped deposit stays unreadable for ever and would lock the
			// slot. A stamp plus no mempool copy is proof of a dead deposit.
			continue
		case err != nil:
			// The source could not answer. Treating that as "no treasury"
			// makes this deposit build a rival output for the slot.
			return nil, err
		case out == nil:
			continue
		}
		// A record order cannot find the base: created_at holds whole seconds,
		// and a chain of deposits lands inside one. The chain itself names each
		// parent, so walk down to the base from here.
		base, err := treasuryBase(ctx, source, script, out)
		if err != nil {
			return nil, err
		}
		if !holdsOutpoint(bases, base) {
			bases = append(bases, base)
		}
	}
	// Rival bases mean rival treasuries, and only one can ever take the slot.
	// Extending either would abandon the other.
	if len(bases) > 1 {
		return nil, fmt.Errorf("%w: slot %d holds %d", errTreasuryAmbiguous, slot, len(bases))
	}
	if len(bases) == 1 {
		return bases[0], nil
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
	// A deposit to this slot never reached the store, so our records describe
	// neither the chain above a ctip nor the chain without one. A block settles
	// it: the enforcer then reports a ctip we have not seen before.
	ctipTxid := treasury.ctip.GetTxid().GetHex().GetValue()
	if blind, blocked := h.slotStaysBlind(slot, ctipTxid); blocked {
		return nil, fmt.Errorf("%w: slot %d has an unrecorded deposit since ctip %q",
			errTreasuryAmbiguous, slot, blind)
	}
	if ctip := treasury.ctip; ctip != nil {
		return &treasuryOutpoint{
			txid:      ctip.GetTxid().GetHex().GetValue(),
			vout:      int(ctip.Vout),
			valueSats: int64(ctip.Value),
		}, nil
	}
	return h.firstTreasuryOf(ctx, func(depositWallet string) wallet.ChainSource {
		if depositWallet == "" {
			return h.engine.ChainForWallet(walletID)
		}
		return h.engine.ChainForWallet(depositWallet)
	}, slot)
}

// treasuryBase walks down from one treasury output to the deepest unconfirmed
// one in the same chain.
//
// It does not count: treasuryTip walks back up over these same transactions
// and counts each hop there. The base itself is one ancestor, because every
// deposit here is unconfirmed — the enforcer reports no ctip until one
// confirms.
func treasuryBase(
	ctx context.Context, chain wallet.ChainSource, script []byte, from *treasuryOutpoint,
) (*treasuryOutpoint, error) {
	base := *from
	base.ancestors = 1

	for hops := 0; hops < depositAncestorLimit; hops++ {
		tx, err := chain.GetRawTransaction(ctx, base.txid)
		if err != nil {
			return nil, fmt.Errorf("read deposit %s: %w", base.txid, err)
		}
		prior, err := treasuryParentOf(ctx, chain, tx, script)
		if err != nil {
			return nil, err
		}
		// No input takes a treasury output, so this is the base of the chain.
		if prior == nil {
			return &base, nil
		}
		prior.ancestors = 1
		base = *prior
	}
	return &base, nil
}

// treasuryParentOf finds the treasury output one deposit spends. A deposit
// also spends the user's own coins, so each input is matched against the
// treasury output of the transaction it came from.
func treasuryParentOf(
	ctx context.Context, chain wallet.ChainSource, tx *wallet.RawTransaction, script []byte,
) (*treasuryOutpoint, error) {
	if tx == nil {
		return nil, nil
	}
	for _, in := range tx.Vin {
		if in.TxID == "" {
			continue
		}
		prior, err := treasuryOutputOf(ctx, chain, in.TxID, script)
		switch {
		case errors.Is(err, wallet.ErrTxNotFound), errors.Is(err, wallet.ErrTxUnreadable):
			// Absent, or unreadable on a node with no txindex. A deposit also
			// spends ordinary confirmed coins, so neither makes this input the
			// treasury link.
			continue
		case err != nil:
			// The source could not answer at all, so the base below this is
			// unknown and an undercount would run past the mempool limit.
			return nil, err
		case prior == nil || prior.vout != in.Vout:
			continue
		}
		return prior, nil
	}
	return nil, nil
}

// recordedChain reports the deepest treasury output our own records name above
// `from`, for a chain source that cannot say who spends an outpoint.
type recordedChain func(
	ctx context.Context, chain wallet.ChainSource, script []byte, from treasuryOutpoint,
) (treasuryOutpoint, error)

// recordedTipOf walks our recorded deposits for the slot and reports the
// deepest treasury output that descends from `from`.
//
// It sees only the deposits this install made. Another install can always
// deposit to the same slot, and no local record shows that — the chain settles
// it, and exactly one deposit takes the treasury.
func (h *WalletHandler) recordedTipOf(slot uint8) recordedChain {
	return func(
		ctx context.Context, chain wallet.ChainSource, script []byte, from treasuryOutpoint,
	) (treasuryOutpoint, error) {
		deposits, err := h.svc.SidechainDeposits(ctx, uint32(slot), "")
		if err != nil {
			return treasuryOutpoint{}, fmt.Errorf("read the deposits of slot %d: %w", slot, err)
		}

		best := from
		for _, d := range deposits {
			out, err := treasuryOutputOf(ctx, chain, d.Txid, script)
			switch {
			case errors.Is(err, wallet.ErrTxNotFound), errors.Is(err, wallet.ErrTxUnreadable):
				continue
			case err != nil:
				return treasuryOutpoint{}, err
			case out == nil:
				continue
			}
			depth, descends, err := treasuryDepthFrom(ctx, chain, script, out, from)
			if err != nil {
				return treasuryOutpoint{}, err
			}
			if descends && depth > best.ancestors {
				out.ancestors = depth
				best = *out
			}
		}
		if best.ancestors >= depositAncestorLimit {
			return treasuryOutpoint{}, errTreasuryChainFull
		}
		return best, nil
	}
}

// treasuryDepthFrom counts the hops from `out` down to `from`, and reports
// whether it reaches it at all.
func treasuryDepthFrom(
	ctx context.Context, chain wallet.ChainSource, script []byte, out *treasuryOutpoint, from treasuryOutpoint,
) (int, bool, error) {
	at := *out
	for depth := from.ancestors; depth <= depositAncestorLimit; depth++ {
		if at.txid == from.txid && at.vout == from.vout {
			return depth, true, nil
		}
		tx, err := chain.GetRawTransaction(ctx, at.txid)
		if err != nil {
			return 0, false, fmt.Errorf("read deposit %s: %w", at.txid, err)
		}
		prior, err := treasuryParentOf(ctx, chain, tx, script)
		if err != nil {
			return 0, false, err
		}
		if prior == nil {
			return 0, false, nil
		}
		at = *prior
	}
	return 0, false, nil
}

// holdsOutpoint reports whether the list already names this outpoint.
func holdsOutpoint(list []*treasuryOutpoint, want *treasuryOutpoint) bool {
	for _, held := range list {
		if held.txid == want.txid && held.vout == want.vout {
			return true
		}
	}
	return false
}

// depositRecordAttempts is how many times a broadcast deposit tries to reach
// the store. The broadcast cannot be undone, so a locked or busy database is
// worth a retry before the slot goes blind.
const depositRecordAttempts = 3

// recordDeposit stores a deposit that is already on the wire.
func (h *WalletHandler) recordDeposit(ctx context.Context, d wallet.SidechainDeposit) error {
	var err error
	for attempt := 0; attempt < depositRecordAttempts; attempt++ {
		if err = h.svc.RecordSidechainDeposit(ctx, d); err == nil {
			return nil
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(time.Duration(attempt+1) * 100 * time.Millisecond):
		}
	}
	return err
}

// blindSlotKey names one slot on one network. The handler outlives a network
// switch, so a bare slot number would carry a marker across networks.
type blindSlotKey struct {
	network string
	slot    uint8
}

// slotStaysBlind reports whether a slot still carries an unrecorded deposit.
//
// The flag holds the ctip the slot had when the record failed. A block that
// moves the enforcer past it settles the unknown chain, so the flag clears
// itself and the slot takes deposits again. Without that a failed write would
// block the slot until the daemon restarts.
func (h *WalletHandler) slotStaysBlind(slot uint8, ctipTxid string) (string, bool) {
	key := h.blindKey(slot)
	held, ok := h.depositSlotBlind.Load(key)
	if !ok {
		return "", false
	}
	blindAt := held.(string)
	if ctipTxid != blindAt {
		h.depositSlotBlind.Delete(key)
		return "", false
	}
	return blindAt, true
}

func (h *WalletHandler) blindKey(slot uint8) blindSlotKey {
	return blindSlotKey{network: h.svc.Network(), slot: slot}
}
