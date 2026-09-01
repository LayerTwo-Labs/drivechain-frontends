package engines

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/fork"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// splitTickInterval is the pass cadence. Claims appear only after a wallet
// scan, so a slow tick is sufficient.
const splitTickInterval = 2 * time.Minute

// absentRecheckInterval is how long a coin Bitcoin does not know waits for the
// next lookup. A replay-protected send makes change no other chain ever holds,
// so most coins answer absent forever; without this they cost a request per
// tick each.
const absentRecheckInterval = 6 * time.Hour

// ForkStateSource yields the fork snapshot. The orchestrator satisfies this.
type ForkStateSource interface {
	ForkState(ctx context.Context) (*fork.ForkState, error)
}

// UnspentSource lists every coin the wallets hold. The orchestrator satisfies
// this.
type UnspentSource interface {
	WalletUnspent(ctx context.Context) ([]fork.Utxo, error)
}

// OutspendSource answers BTC-mainnet spend status per output. The bool reports
// whether Bitcoin holds the transaction at all.
type OutspendSource interface {
	Outspend(ctx context.Context, txid string, vout int) (wallet.EsploraOutspend, bool, error)
}

// SplitStore persists the per-outpoint split status.
type SplitStore interface {
	SplitStatuses(ctx context.Context) (map[string]bool, error)
	SaveSplitStatus(ctx context.Context, outpoint string, splittable bool) error
}

// SplitEngine asks BTC mainnet about every coin the wallets hold. A pre-fork
// coin lives on both chains because they share its history; a post-fork coin
// lives on both when its transaction went out without replay protection. Each
// outpoint gets one lookup ever, so rate-limited servers see few requests.
type SplitEngine struct {
	log     zerolog.Logger
	fork    ForkStateSource
	coins   UnspentSource
	btc     OutspendSource
	store   SplitStore
	network func() string
	now     func() time.Time

	// absent holds when a lookup last reported that Bitcoin does not know a
	// coin. Such an answer expires, so it gates the next lookup, not the coin.
	absent map[string]time.Time

	wake chan struct{}
}

func NewSplitEngine(log zerolog.Logger, forkState ForkStateSource, coins UnspentSource, btc OutspendSource, store SplitStore, network func() string) *SplitEngine {
	return &SplitEngine{
		log:     log.With().Str("component", "split-engine").Logger(),
		fork:    forkState,
		coins:   coins,
		btc:     btc,
		store:   store,
		network: network,
		now:     time.Now,
		absent:  map[string]time.Time{},
		wake:    make(chan struct{}, 1),
	}
}

// ResetForNetwork asks for an immediate pass on the incoming chain.
func (e *SplitEngine) ResetForNetwork(string) {
	select {
	case e.wake <- struct{}{}:
	default:
	}
}

// Run loops until ctx is cancelled.
func (e *SplitEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(splitTickInterval)
	defer ticker.Stop()
	e.log.Info().Dur("interval", splitTickInterval).Msg("split engine started")

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

func (e *SplitEngine) tick(ctx context.Context) {
	if !config.SharesBitcoinHistory(config.NetworkFromString(e.network())) {
		return
	}
	st, err := e.fork.ForkState(ctx)
	if err != nil {
		e.log.Debug().Err(err).Msg("split: fork state unavailable")
		return
	}
	// A simulated fork (signet rehearsal) has no BTC-mainnet outpoints.
	if st.Simulated {
		return
	}
	coins, err := e.coins.WalletUnspent(ctx)
	if err != nil {
		e.log.Warn().Err(err).Msg("split: coin list unavailable")
		return
	}
	cached, err := e.store.SplitStatuses(ctx)
	if err != nil {
		e.log.Warn().Err(err).Msg("split: cache unavailable")
		return
	}
	e.absent = keepLiveAbsences(e.absent, coins)

	for _, u := range coins {
		if ctx.Err() != nil {
			return
		}
		if _, done := cached[u.Outpoint]; done {
			continue
		}
		if !dueForRecheck(e.absent[u.Outpoint], e.now()) {
			continue
		}
		status, err := checkReplayStatus(ctx, e.btc, u.Outpoint)
		if err != nil {
			// One dead provider must not cost a request per coin per tick.
			e.log.Warn().Err(err).Str("outpoint", u.Outpoint).Msg("split: pass stopped")
			return
		}
		switch status {
		case btcUnknown:
			// Bitcoin holds no such coin, which this chain's own coins answer
			// forever. The next lookup waits.
			e.absent[u.Outpoint] = e.now()
			continue
		case btcPending:
			// A block settles this, so the next tick asks again.
			continue
		}
		delete(e.absent, u.Outpoint)
		if err := e.store.SaveSplitStatus(ctx, u.Outpoint, status == btcUnspent); err != nil {
			e.log.Warn().Err(err).Str("outpoint", u.Outpoint).Msg("split: pass stopped")
			return
		}
		e.log.Info().Str("outpoint", u.Outpoint).Bool("splittable", status == btcUnspent).Msg("split: outpoint checked")
	}
}

// keepLiveAbsences drops the records of coins the wallet no longer holds, so a
// spent coin costs no memory.
func keepLiveAbsences(absent map[string]time.Time, coins []fork.Utxo) map[string]time.Time {
	live := make(map[string]time.Time, len(absent))
	for _, u := range coins {
		if t, ok := absent[u.Outpoint]; ok {
			live[u.Outpoint] = t
		}
	}
	return live
}

// dueForRecheck reports whether a coin gets a lookup on this pass. A coin no
// lookup reported absent yet carries the zero time and always qualifies.
func dueForRecheck(lastAbsent, now time.Time) bool {
	return lastAbsent.IsZero() || now.Sub(lastAbsent) >= absentRecheckInterval
}

// btcStatus is what Bitcoin says about one coin.
type btcStatus int

const (
	// btcUnknown: no server holds the coin. A coin this chain alone made
	// answers this forever, and a replay can still land much later.
	btcUnknown btcStatus = iota
	// btcPending: a spend sits in the mempool and can drop out again.
	btcPending
	// btcSpent: a confirmed spend, so nothing replays.
	btcSpent
	// btcUnspent: the coin exists on Bitcoin, so a spend here replays there.
	btcUnspent
)

// checkReplayStatus asks Bitcoin about one coin. The caller acts on the answer.
func checkReplayStatus(ctx context.Context, btc OutspendSource, outpoint string) (btcStatus, error) {
	txid, vout, ok := parseOutpoint(outpoint)
	if !ok {
		return btcUnknown, nil
	}
	out, found, err := btc.Outspend(ctx, txid, vout)
	switch {
	case err != nil:
		return btcUnknown, err
	case !found:
		return btcUnknown, nil
	case out.Spent && !out.Status.Confirmed:
		return btcPending, nil
	case out.Spent:
		return btcSpent, nil
	default:
		return btcUnspent, nil
	}
}

func parseOutpoint(outpoint string) (string, int, bool) {
	i := strings.LastIndex(outpoint, ":")
	if i <= 0 {
		return "", 0, false
	}
	vout, err := strconv.Atoi(outpoint[i+1:])
	if err != nil || vout < 0 {
		return "", 0, false
	}
	return outpoint[:i], vout, true
}
