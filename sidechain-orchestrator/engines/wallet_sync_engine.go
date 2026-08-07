package engines

import (
	"context"
	"sync"
	"time"

	"github.com/rs/zerolog"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const (
	// walletSyncTickInterval is the safety net. Push subscriptions carry the
	// fast path, so a quiet tick costs one tip check per wallet.
	walletSyncTickInterval = 60 * time.Second
	// walletSyncConcurrency bounds parallel scans: there is one chain
	// connection, so a wide fan-out would starve foreground reads.
	walletSyncConcurrency = 2
)

// WalletSyncEngine keeps every electrum wallet on the current network warm, so
// switching wallets serves stored history instead of waiting on a scan.
type WalletSyncEngine struct {
	log    zerolog.Logger
	svc    *wallet.Service
	engine *wallet.WalletEngine

	wake chan struct{}
}

func NewWalletSyncEngine(log zerolog.Logger, svc *wallet.Service, walletEngine *wallet.WalletEngine) *WalletSyncEngine {
	return &WalletSyncEngine{
		log:    log.With().Str("component", "wallet-sync").Logger(),
		svc:    svc,
		engine: walletEngine,
		wake:   make(chan struct{}, 1),
	}
}

// ResetForNetwork asks for an immediate pass against the incoming chain.
func (e *WalletSyncEngine) ResetForNetwork(string) {
	e.poke()
}

func (e *WalletSyncEngine) poke() {
	select {
	case e.wake <- struct{}{}:
	default:
	}
}

// Run loops until ctx is cancelled. A failing wallet is logged and the rest of
// the pass continues — one unreachable server must not stall the others.
func (e *WalletSyncEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(walletSyncTickInterval)
	defer ticker.Stop()

	changed := e.svc.Subscribe(ctx)
	e.log.Info().Dur("interval", walletSyncTickInterval).Msg("wallet sync engine started")

	for {
		e.tick(ctx)
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		case <-changed:
		case <-e.wake:
		}
	}
}

func (e *WalletSyncEngine) tick(ctx context.Context) {
	if !e.engine.ElectrumAvailable() {
		return
	}
	wallets := e.orderedWallets()
	if len(wallets) == 0 {
		return
	}

	sem := make(chan struct{}, walletSyncConcurrency)
	var wg sync.WaitGroup
	for _, id := range wallets {
		if ctx.Err() != nil {
			break
		}
		sem <- struct{}{}
		wg.Add(1)
		go func(walletID string) {
			defer wg.Done()
			defer func() { <-sem }()
			if err := e.engine.SyncElectrumWallet(ctx, walletID); err != nil {
				e.log.Debug().Err(err).Str("wallet", walletID).Msg("background wallet sync failed")
			}
		}(id)
	}
	wg.Wait()
}

// orderedWallets lists electrum wallet IDs with the active one first, so what
// is on screen refreshes before the wallets behind it.
func (e *WalletSyncEngine) orderedWallets() []string {
	ids := lo.FilterMap(e.svc.GetAllWallets(), func(w wallet.WalletData, _ int) (string, bool) {
		return w.ID, w.WalletType == wallet.WalletTypeElectrum
	})
	active := e.svc.ActiveWalletID()
	if i := lo.IndexOf(ids, active); i > 0 {
		ids[0], ids[i] = ids[i], ids[0]
	}
	return ids
}
