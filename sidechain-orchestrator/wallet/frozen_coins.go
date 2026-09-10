package wallet

import (
	"context"
	"fmt"
	"time"

	"github.com/samber/lo"
)

// Outpoint names one transaction output, and says whether a block holds it.
type Outpoint struct {
	TxID      string
	Vout      int
	Confirmed bool
}

// Key names the outpoint as txid:vout.
func (o Outpoint) Key() string { return fmt.Sprintf("%s:%d", o.TxID, o.Vout) }

// FrozenCoinsFunc names the candidates a live BMM bid can take away, keyed
// txid:vout. A coin the bid created dies with a replacement of that bid, and a
// coin the bid spends conflicts with a second spend of it.
type FrozenCoinsFunc func(ctx context.Context, candidates []Outpoint) (map[string]bool, error)

// SetFrozenCoins wires the source that names the coins a live BMM bid holds.
// Coin selection leaves those coins alone. A pinned input still spends one,
// because a bid raise has to spend the inputs of the bid it replaces.
func (s *Service) SetFrozenCoins(fn FrozenCoinsFunc) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.frozenCoins = fn
}

// FreezesCoins says whether a source of frozen coins is wired.
func (s *Service) FreezesCoins() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.frozenCoins != nil
}

// FrozenCoins names the candidates a live BMM bid holds. It names none while no
// source is wired.
func (s *Service) FrozenCoins(ctx context.Context, candidates []Outpoint) (map[string]bool, error) {
	s.mu.RLock()
	fn := s.frozenCoins
	s.mu.RUnlock()
	if fn == nil || len(candidates) == 0 {
		return nil, nil
	}
	frozen, err := fn(ctx, candidates)
	if err != nil {
		return nil, fmt.Errorf("read the coins a bmm bid holds: %w", err)
	}
	return frozen, nil
}

func (p *ElectrumBackend) dropFrozenCoins(ctx context.Context, pool []electrumUTXO) ([]electrumUTXO, error) {
	frozen, err := p.svc.FrozenCoins(ctx, lo.Map(pool, func(u electrumUTXO, _ int) Outpoint {
		return Outpoint{TxID: u.txid, Vout: u.vout, Confirmed: u.confirmed}
	}))
	if err != nil || len(frozen) == 0 {
		return pool, err
	}
	return lo.Filter(pool, func(u electrumUTXO, _ int) bool {
		return !frozen[Outpoint{TxID: u.txid, Vout: u.vout}.Key()]
	}), nil
}

// lockFrozenCoins locks the coins a live BMM bid holds for the length of one
// send, because Core picks the coins itself on most of its send paths. The
// caller unlocks them with the function it gets back.
func (p *CoreBackend) lockFrozenCoins(ctx context.Context, walletName string) (func(), error) {
	if !p.svc.FreezesCoins() {
		return func() {}, nil
	}
	// The coin a live bid holds is its own change, and Core hides an
	// unconfirmed coin from listunspent unless the call asks for it.
	utxos, err := p.rpc.ListUnspentMinConf(ctx, walletName, 0)
	if err != nil {
		return nil, fmt.Errorf("list unspent: %w", err)
	}
	frozen, err := p.svc.FrozenCoins(ctx, lo.Map(utxos, func(u UTXO, _ int) Outpoint {
		return Outpoint{TxID: u.TxID, Vout: u.Vout, Confirmed: u.Confirmations > 0}
	}))
	if err != nil {
		return nil, err
	}
	held := lo.FilterMap(utxos, func(u UTXO, _ int) (RawInput, bool) {
		return RawInput{TxID: u.TxID, Vout: u.Vout}, frozen[Outpoint{TxID: u.TxID, Vout: u.Vout}.Key()]
	})
	if len(held) == 0 {
		return func() {}, nil
	}
	if err := p.rpc.LockUnspent(ctx, walletName, false, held); err != nil {
		return nil, err
	}
	return func() {
		// A canceled send must still give the coins back, or they stay locked
		// until the next restart.
		free, cancel := context.WithTimeout(context.WithoutCancel(ctx), 30*time.Second)
		defer cancel()
		if err := p.rpc.LockUnspent(free, walletName, true, held); err != nil {
			p.log.Warn().Err(err).Msg("unlock the coins a bmm bid holds")
		}
	}, nil
}
