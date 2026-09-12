package wallet

import (
	"context"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/samber/lo"
)

// frozenHold counts the sends of one wallet that hold the frozen coins locked,
// and names the coins the first of them locked. mu runs the lock step of one
// send at a time, so a second send waits for the lock instead of racing it.
type frozenHold struct {
	mu      sync.Mutex
	senders int
	coins   []RawInput
}

// Outpoint names one transaction output, and says whether a block holds it.
type Outpoint struct {
	TxID      string
	Vout      int
	Confirmed bool
}

// Key names the outpoint as txid:vout. A txid is hexadecimal, and a caller can
// spell it in either case, so the key holds one spelling.
func (o Outpoint) Key() string { return fmt.Sprintf("%s:%d", strings.ToLower(o.TxID), o.Vout) }

// FrozenCoinsFunc names the candidates a live BMM bid can take away, keyed
// txid:vout. A coin the bid created dies with a replacement of that bid, and a
// coin the bid spends conflicts with a second spend of it.
type FrozenCoinsFunc func(ctx context.Context, walletID string, candidates []Outpoint) (map[string]bool, error)

// SetFrozenCoins wires the source that names the coins a live BMM bid holds.
// Coin selection leaves those coins alone. A pinned input still spends one,
// because a bid raise has to spend the inputs of the bid it replaces.
func (s *Service) SetFrozenCoins(fn FrozenCoinsFunc) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.frozenCoins = fn
}

// SetHeldCoins records the coins a frontend froze. The set replaces the one
// before it, so an unfreeze reaches coin selection too. An outpoint names one
// coin of one wallet, so this one set covers every wallet.
func (s *Service) SetHeldCoins(coins []Outpoint) {
	s.mu.Lock()
	defer s.mu.Unlock()
	held := make(map[string]bool, len(coins))
	for _, coin := range coins {
		held[coin.Key()] = true
	}
	s.heldCoins = held
}

// HeldCoins names the coins a frontend froze.
func (s *Service) HeldCoins() map[string]bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.heldCoins
}

// FreezesCoins says whether any source of frozen coins is wired.
func (s *Service) FreezesCoins() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.frozenCoins != nil || len(s.heldCoins) > 0
}

// FrozenCoins names the candidates no send may take: the coins a live BMM bid
// holds, and the coins a frontend froze. It names none while no source is
// wired.
func (s *Service) FrozenCoins(ctx context.Context, walletID string, candidates []Outpoint) (map[string]bool, error) {
	s.mu.RLock()
	fn := s.frozenCoins
	held := s.heldCoins
	s.mu.RUnlock()
	if len(candidates) == 0 {
		return nil, nil
	}

	frozen := make(map[string]bool, len(held))
	for _, candidate := range candidates {
		if held[candidate.Key()] {
			frozen[candidate.Key()] = true
		}
	}

	if fn != nil {
		bid, err := fn(ctx, walletID, candidates)
		if err != nil {
			return nil, fmt.Errorf("read the coins a bmm bid holds: %w", err)
		}
		for key, isFrozen := range bid {
			if isFrozen {
				frozen[key] = true
			}
		}
	}

	if len(frozen) == 0 {
		return nil, nil
	}
	return frozen, nil
}

func (p *ElectrumBackend) dropFrozenCoins(
	ctx context.Context, walletID string, pool []electrumUTXO,
) ([]electrumUTXO, error) {
	frozen, err := p.svc.FrozenCoins(ctx, walletID, lo.Map(pool, func(u electrumUTXO, _ int) Outpoint {
		return Outpoint{TxID: u.txid, Vout: u.vout, Confirmed: u.confirmed}
	}))
	if err != nil || len(frozen) == 0 {
		return pool, err
	}
	return lo.Filter(pool, func(u electrumUTXO, _ int) bool {
		return !frozen[Outpoint{TxID: u.txid, Vout: u.vout}.Key()]
	}), nil
}

// lockFrozenCoins locks the coins no send may take for the length of one send,
// because Core picks the coins itself on most of its send paths. The caller
// unlocks them with the function it gets back.
//
// Every step of one wallet's freeze runs under the wallet's own hold, so a
// second send waits for the first to lock, and waits again for it to unlock.
// It then locks whatever Core still shows frozen, which covers a coin the user
// froze while the first send ran.
func (p *CoreBackend) lockFrozenCoins(ctx context.Context, walletID, walletName string) (func(), error) {
	if !p.svc.FreezesCoins() {
		return func() {}, nil
	}
	hold := p.holdFor(walletName)
	hold.mu.Lock()
	defer hold.mu.Unlock()
	hold.senders++

	// A coin an earlier send locked is already out of this list, and a coin
	// the user froze a moment ago is still in it. Core hides an unconfirmed
	// coin too, unless the call asks for it.
	utxos, err := p.rpc.ListUnspentMinConf(ctx, walletName, 0)
	if err != nil {
		hold.senders--
		return nil, fmt.Errorf("list unspent: %w", err)
	}
	frozen, err := p.svc.FrozenCoins(ctx, walletID, lo.Map(utxos, func(u UTXO, _ int) Outpoint {
		return Outpoint{TxID: u.TxID, Vout: u.Vout, Confirmed: u.Confirmations > 0}
	}))
	if err != nil {
		hold.senders--
		return nil, err
	}
	held := lo.FilterMap(utxos, func(u UTXO, _ int) (RawInput, bool) {
		return RawInput{TxID: u.TxID, Vout: u.Vout}, frozen[Outpoint{TxID: u.TxID, Vout: u.Vout}.Key()]
	})
	if len(held) > 0 {
		if err := p.rpc.LockUnspent(ctx, walletName, false, held); err != nil {
			hold.senders--
			return nil, err
		}
		hold.coins = append(hold.coins, held...)
	}
	return func() { p.leaveFrozenHold(ctx, walletName) }, nil
}

// holdFor returns the hold of one wallet, and makes one on the first call.
func (p *CoreBackend) holdFor(walletName string) *frozenHold {
	p.holdMu.Lock()
	defer p.holdMu.Unlock()
	if p.frozenHolds == nil {
		p.frozenHolds = make(map[string]*frozenHold)
	}
	hold, ok := p.frozenHolds[walletName]
	if !ok {
		hold = &frozenHold{}
		p.frozenHolds[walletName] = hold
	}
	return hold
}

// leaveFrozenHold takes this send out, and gives the coins back once the last
// send leaves. It holds the wallet's hold across the unlock, so the next send
// reads a list that already shows those coins again.
func (p *CoreBackend) leaveFrozenHold(ctx context.Context, walletName string) {
	hold := p.holdFor(walletName)
	hold.mu.Lock()
	defer hold.mu.Unlock()

	hold.senders--
	if hold.senders > 0 || len(hold.coins) == 0 {
		return
	}
	// A canceled send must still give the coins back, or they stay locked
	// until the next restart.
	free, cancel := context.WithTimeout(context.WithoutCancel(ctx), 30*time.Second)
	defer cancel()
	if err := p.rpc.LockUnspent(free, walletName, true, hold.coins); err != nil {
		// Core hides a locked coin from listunspent, so this record is the
		// only way back to it. The next send out tries the unlock again.
		p.log.Warn().Err(err).Msg("unlock the coins no send may take")
		return
	}
	hold.coins = nil
}
