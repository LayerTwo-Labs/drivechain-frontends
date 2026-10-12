package orchestrator

import (
	"context"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

func TestShippedConfigNamesSolanaAsExternal(t *testing.T) {
	cfg, ok := BinaryConfigByName("solana")
	require.True(t, ok)

	assert.True(t, cfg.External)
	assert.Equal(t, 8, cfg.Slot)
	assert.Equal(t, 6008, cfg.Port)
	assert.Equal(t, 2, cfg.ChainLayer)
	assert.False(t, cfg.IsBitcoinCore)
	assert.False(t, cfg.Downloadable())
	assert.Equal(t, "127.0.0.1", cfg.RPCHost())
}

// The wallet derives no starter for it, and no reset or wipe resolves a data
// directory for it.
func TestExternalNodeHasNoWalletSlotAndNoDirectory(t *testing.T) {
	for _, slot := range WalletSidechainSlots() {
		assert.NotEqual(t, 8, slot.Slot)
	}
	_, ok := config.DirConfigByName("solana")
	assert.False(t, ok)
}

func TestOrchestratorNeverRunsAnExternalNode(t *testing.T) {
	useTempHome(t)
	cfg, ok := BinaryConfigByName("solana")
	require.True(t, ok)
	o := New(t.TempDir(), string(config.NetworkSignet), t.TempDir(), []BinaryConfig{cfg}, zerolog.Nop())
	t.Cleanup(o.StopAllMonitors)
	ctx := context.Background()

	_, err := o.Download(ctx, "solana", false)
	require.ErrorContains(t, err, "outside the orchestrator")

	_, err = o.Start(ctx, "solana", nil, nil)
	require.ErrorContains(t, err, "outside the orchestrator")

	_, err = o.StartWithL1(ctx, "solana", StartOpts{})
	require.ErrorContains(t, err, "outside the orchestrator")

	require.NoError(t, o.Stop(ctx, "solana", true))
	assert.False(t, o.process.IsRunning("solana"))
}
