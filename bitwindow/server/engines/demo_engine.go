package engines

import (
	"context"
	"database/sql"
	"math/rand"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/demo"
	"github.com/rs/zerolog"
)

// DemoEngine simulates sidechain activity in demo mode by periodically
// adding small amounts to demo sidechain balances and generating random actions.
type DemoEngine struct {
	db              *sql.DB
	depositInterval time.Duration
	actionInterval  time.Duration
	cleanupInterval time.Duration
}

// NewDemoEngine creates a new demo engine with the specified update interval.
func NewDemoEngine(db *sql.DB) *DemoEngine {
	return &DemoEngine{
		db:              db,
		depositInterval: 45 * time.Second, // Update balances every 45 seconds
		actionInterval:  30 * time.Second, // Generate actions every 30 seconds
		cleanupInterval: 1 * time.Hour,    // Cleanup old actions every hour
	}
}

// Run starts the demo engine goroutine that simulates deposits and actions.
func (e *DemoEngine) Run(ctx context.Context) error {
	log := zerolog.Ctx(ctx)
	log.Info().Msg("demo engine: starting simulation")

	depositTicker := time.NewTicker(e.depositInterval)
	actionTicker := time.NewTicker(e.actionInterval)
	cleanupTicker := time.NewTicker(e.cleanupInterval)
	defer depositTicker.Stop()
	defer actionTicker.Stop()
	defer cleanupTicker.Stop()

	// Generate a few initial actions so the list isn't empty on startup
	if err := e.generateInitialActions(ctx); err != nil {
		log.Warn().Err(err).Msg("demo engine: failed to generate initial actions")
	}

	for {
		select {
		case <-ctx.Done():
			log.Info().Msg("demo engine: shutting down")
			return nil

		case <-depositTicker.C:
			if err := e.simulateDeposit(ctx); err != nil {
				log.Warn().Err(err).Msg("demo engine: failed to simulate deposit")
			}

		case <-actionTicker.C:
			if err := e.simulateAction(ctx); err != nil {
				log.Warn().Err(err).Msg("demo engine: failed to simulate action")
			}

		case <-cleanupTicker.C:
			if err := demo.CleanupOldActions(ctx, e.db); err != nil {
				log.Warn().Err(err).Msg("demo engine: failed to cleanup old actions")
			}
		}
	}
}

// simulateDeposit adds a random amount to a random demo sidechain.
func (e *DemoEngine) simulateDeposit(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Get available demo sidechain slots
	slots, err := demo.GetDemoSidechainSlots(ctx, e.db)
	if err != nil {
		return err
	}

	if len(slots) == 0 {
		return nil
	}

	// Pick a random sidechain
	slot := slots[rand.Intn(len(slots))]

	// Generate a random deposit amount between 1000 and 50000 sats
	amount := int64(rand.Intn(49000) + 1000)

	if err := demo.UpdateDemoBalance(ctx, e.db, slot, amount); err != nil {
		return err
	}

	log.Debug().
		Uint32("slot", slot).
		Int64("amount_sats", amount).
		Msg("demo engine: simulated deposit")

	return nil
}

// simulateAction generates a random demo action.
func (e *DemoEngine) simulateAction(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Get sidechains for action generation
	sidechains, err := demo.GetDemoSidechainsForActions(ctx, e.db)
	if err != nil {
		return err
	}

	if len(sidechains) == 0 {
		return nil
	}

	// Generate a random action
	action := demo.GenerateRandomAction(sidechains)
	if action == nil {
		return nil
	}

	if err := demo.InsertDemoAction(ctx, e.db, action); err != nil {
		return err
	}

	log.Debug().
		Str("type", string(action.ActionType)).
		Str("sidechain", action.SidechainName).
		Msg("demo engine: simulated action")

	return nil
}

// generateInitialActions creates a batch of actions on startup so the list isn't empty.
func (e *DemoEngine) generateInitialActions(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Get sidechains for action generation
	sidechains, err := demo.GetDemoSidechainsForActions(ctx, e.db)
	if err != nil {
		return err
	}

	if len(sidechains) == 0 {
		return nil
	}

	// Generate 10-15 initial actions with staggered timestamps
	count := rand.Intn(6) + 10
	now := time.Now().Unix()

	for i := 0; i < count; i++ {
		action := demo.GenerateRandomAction(sidechains)
		if action == nil {
			continue
		}

		// Stagger timestamps over the last hour
		action.CreatedAt = now - int64(rand.Intn(3600))

		if err := demo.InsertDemoAction(ctx, e.db, action); err != nil {
			log.Warn().Err(err).Msg("demo engine: failed to insert initial action")
			continue
		}
	}

	log.Info().Int("count", count).Msg("demo engine: generated initial actions")
	return nil
}
