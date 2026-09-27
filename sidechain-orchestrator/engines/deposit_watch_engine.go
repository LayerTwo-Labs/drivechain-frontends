package engines

import (
	"context"
	"errors"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
)

// depositWatchTickInterval is how often the engine re-reads the open deposits.
// A deposit that loses a race never confirms, and nothing else reports that, so
// the user waits one pass at most after the proof lands.
const depositWatchTickInterval = 60 * time.Second

// depositMissingPasses is how many passes in a row must report a deposit gone
// before the engine stamps it. One Esplora host in a list can answer 404 while
// another still holds the transaction, and each pass rotates the provider, so
// a second agreeing answer costs a minute and removes that whole class of
// wrong stamp.
const depositMissingPasses = 2

// DepositStore is the part of the wallet service this engine reads and stamps.
type DepositStore interface {
	SidechainDeposits(ctx context.Context, slot uint32, walletID string) ([]wallet.SidechainDeposit, error)
	MarkSidechainDepositDropped(ctx context.Context, txid string) error
	ClearSidechainDepositDrop(ctx context.Context, txid string) error
}

// ChainForWallet hands back the chain source that serves one wallet, and the
// backend that holds the wallets themselves.
type ChainForWallet interface {
	ChainForWallet(walletID string) wallet.ChainSource
	Backend() wallet.Backend
}

// DepositWatchEngine stamps a deposit the network stopped holding. A deposit
// that loses the race for the treasury output never confirms and never gets
// credited, so without this it counts as pending for ever.
type DepositWatchEngine struct {
	log    zerolog.Logger
	store  DepositStore
	chains ChainForWallet
	slots  func() []uint32
	wake   chan struct{}

	// missing counts the consecutive passes that found each deposit gone. A
	// restart clears it, which only costs one more pass.
	missing map[string]int
}

func NewDepositWatchEngine(
	log zerolog.Logger, store DepositStore, chains ChainForWallet, slots func() []uint32,
) *DepositWatchEngine {
	return &DepositWatchEngine{
		log:     log.With().Str("component", "deposit-watch").Logger(),
		store:   store,
		chains:  chains,
		slots:   slots,
		wake:    make(chan struct{}, 1),
		missing: map[string]int{},
	}
}

// ResetForNetwork forces an immediate pass after a network swap.
func (e *DepositWatchEngine) ResetForNetwork(string) {
	select {
	case e.wake <- struct{}{}:
	default:
	}
}

func (e *DepositWatchEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(depositWatchTickInterval)
	defer ticker.Stop()

	e.log.Info().Dur("interval", depositWatchTickInterval).Msg("deposit watch engine started")

	for {
		e.tick(ctx)
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		case <-e.wake:
		}
	}
}

func (e *DepositWatchEngine) tick(ctx context.Context) {
	for _, slot := range e.slots() {
		deposits, err := e.store.SidechainDeposits(ctx, slot, "")
		if err != nil {
			e.log.Warn().Err(err).Uint32("slot", slot).Msg("could not read the deposits of the slot")
			continue
		}
		for _, d := range deposits {
			if !d.CreditedAt.IsZero() {
				continue
			}
			e.judge(ctx, d)
		}
	}
}

// judge stamps or clears one deposit. A source that cannot answer leaves the
// deposit alone: a wrong stamp tells the user to send money twice.
func (e *DepositWatchEngine) judge(ctx context.Context, d wallet.SidechainDeposit) {
	// Ask the wallet that made the deposit first. It knows its own transaction
	// whatever the node indexes, and Core reports a conflicted one directly.
	// A generic chain read cannot do that without a synced txindex.
	switch tx, walletErr := e.chains.Backend().GetWalletTransaction(ctx, d.WalletID, d.Txid); {
	case walletErr != nil:
		// The wallet cannot answer, so fall through to the chain source.
	case tx == nil:
		// Nothing to read from, so fall through too.
	case tx.Confirmations < 0:
		e.stamp(ctx, d, "the wallet reports the deposit as conflicted")
		return
	default:
		// The deposit is confirmed, or unconfirmed and still the wallet's own. A
		// mempool that evicts an unconfirmed wallet transaction does not kill
		// it: the wallet rebroadcasts it and a miner can still take it. The
		// conflict above is the only wallet answer that ends a deposit.
		e.revive(ctx, d)
		return
	}

	chain := e.chains.ChainForWallet(d.WalletID)
	_, txErr := chain.GetRawTransaction(ctx, d.Txid)
	if txErr == nil {
		e.revive(ctx, d)
		return
	}

	// Only an answer of "no such transaction" proves the deposit is gone. A
	// rate limit or a timeout looks the same to the caller, and a wrong stamp
	// asks the user to send the money a second time.
	if !errors.Is(txErr, wallet.ErrTxNotFound) {
		delete(e.missing, d.Txid)
		return
	}
	e.missing[d.Txid]++
	if e.missing[d.Txid] < depositMissingPasses {
		return
	}
	e.stamp(ctx, d, "the network dropped the deposit, so it can never confirm")
}

// revive clears a stamp the deposit outlived, and the count behind it.
func (e *DepositWatchEngine) revive(ctx context.Context, d wallet.SidechainDeposit) {
	delete(e.missing, d.Txid)
	if d.DroppedAt.IsZero() {
		return
	}
	if err := e.store.ClearSidechainDepositDrop(ctx, d.Txid); err != nil {
		e.log.Warn().Err(err).Str("txid", d.Txid).Msg("could not lift the drop stamp")
		return
	}
	e.log.Info().Str("txid", d.Txid).Msg("the deposit is back, lifting the drop stamp")
}

// stamp records a deposit the network no longer carries.
func (e *DepositWatchEngine) stamp(ctx context.Context, d wallet.SidechainDeposit, why string) {
	if !d.DroppedAt.IsZero() {
		return
	}
	if err := e.store.MarkSidechainDepositDropped(ctx, d.Txid); err != nil {
		e.log.Warn().Err(err).Str("txid", d.Txid).Msg("could not stamp the dropped deposit")
		return
	}
	e.log.Warn().Str("txid", d.Txid).Uint32("slot", d.Slot).Int64("amount_sats", d.AmountSats).Msg(why)
}
