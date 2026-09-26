package orchestrator

import (
	"context"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// A fork that keeps its own wallet boots without a starter. The wallet service
// here holds no wallet, so a request for a starter fails the boot.
func TestAForkWithItsOwnWalletTakesNoStarter(t *testing.T) {
	o := &Orchestrator{
		log:       zerolog.Nop(),
		Network:   string(config.NetworkECash),
		WalletSvc: wallet.NewService(t.TempDir(), zerolog.Nop()),
	}
	freebank := BinaryConfig{
		Name: "freebank", DisplayName: "FreeBank", ChainLayer: 2, Slot: 130, Port: 8454, IsBitcoinCore: true,
	}
	require.NoError(t, o.ensureCoreSidechainWallet(context.Background(), freebank))

	bbc := BinaryConfig{Name: "bbc", DisplayName: "Bbc", ChainLayer: 2, Slot: 1, Port: 8332, IsBitcoinCore: true}
	require.ErrorContains(t, o.ensureCoreSidechainWallet(context.Background(), bbc), "sidechain starter")
}

func TestFreeBankShipsAsACoreFork(t *testing.T) {
	cfg, ok := BinaryConfigByName("freebank")
	require.True(t, ok)
	assert.True(t, cfg.IsBitcoinCore)
	assert.Equal(t, 8454, cfg.Port)
}
