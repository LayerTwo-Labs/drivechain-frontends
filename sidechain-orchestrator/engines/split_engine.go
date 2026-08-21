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

// ForkStateSource yields the fork snapshot. The orchestrator satisfies this.
type ForkStateSource interface {
	ForkState(ctx context.Context) (*fork.ForkState, error)
}

// OutspendSource answers BTC-mainnet spend status per output.
type OutspendSource interface {
	Outspend(ctx context.Context, txid string, vout int) (wallet.EsploraOutspend, bool, error)
}

// SplitStore persists the per-outpoint split status.
type SplitStore interface {
	SplitStatuses(ctx context.Context) (map[string]bool, error)
	SaveSplitStatus(ctx context.Context, outpoint string, splittable bool) error
}

// SplitEngine finds which claimable pre-fork UTXOs are splittable: the same
// outpoint exists unspent on BTC mainnet. Each outpoint gets one lookup ever;
// the fork scan gates the lookups so rate-limited servers see few requests.
type SplitEngine struct {
	log     zerolog.Logger
	fork    ForkStateSource
	btc     OutspendSource
	store   SplitStore
	network func() string

	wake chan struct{}
}

func NewSplitEngine(log zerolog.Logger, forkState ForkStateSource, btc OutspendSource, store SplitStore, network func() string) *SplitEngine {
	return &SplitEngine{
		log:     log.With().Str("component", "split-engine").Logger(),
		fork:    forkState,
		btc:     btc,
		store:   store,
		network: network,
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
	if !config.IsEcashFork(config.NetworkFromString(e.network())) {
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

	cached, err := e.store.SplitStatuses(ctx)
	if err != nil {
		e.log.Warn().Err(err).Msg("split: cache unavailable")
		return
	}

	for _, claim := range st.Claims {
		for _, u := range claim.UTXOs {
			if ctx.Err() != nil {
				return
			}
			if _, ok := cached[u.Outpoint]; ok {
				continue
			}
			// A failed lookup stops the pass — one dead provider must not
			// cost a request per outpoint per tick. A later tick retries.
			if err := e.check(ctx, u.Outpoint); err != nil {
				e.log.Warn().Err(err).Str("outpoint", u.Outpoint).Msg("split: pass stopped")
				return
			}
		}
	}
}

// check does the single BTC-side lookup for one outpoint. An error caches
// nothing, so a later tick retries.
func (e *SplitEngine) check(ctx context.Context, outpoint string) error {
	txid, vout, ok := parseOutpoint(outpoint)
	if !ok {
		e.log.Warn().Str("outpoint", outpoint).Msg("split: malformed outpoint")
		return nil
	}
	out, found, err := e.btc.Outspend(ctx, txid, vout)
	if err != nil {
		return err
	}
	// A mempool spend can drop out again — cache only stable states: unspent,
	// spent with confirmation, or absent from the chain. A reorg of a
	// confirmed spend is accepted as final.
	if found && out.Spent && !out.Status.Confirmed {
		return nil
	}
	splittable := found && !out.Spent
	if err := e.store.SaveSplitStatus(ctx, outpoint, splittable); err != nil {
		return err
	}
	e.log.Info().Str("outpoint", outpoint).Bool("splittable", splittable).Msg("split: outpoint checked")
	return nil
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
