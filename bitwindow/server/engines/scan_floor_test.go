package engines

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
)

func parserOn(network config.Network) *Parser {
	return &Parser{conf: config.Config{BitcoinCoreNetwork: network}}
}

// An explicit historical target must fetch the blocks it names. A floor above
// it leaves every batch empty while the run still reports the goal as reached.
func TestScanFloorIsZeroUnderASyncTarget(t *testing.T) {
	p := &Parser{conf: config.Config{
		BitcoinCoreNetwork: config.NetworkMainnet,
		SyncToHeight:       500000,
	}}
	assert.Zero(t, p.scanFloor(900000))
}

func TestScanFloorStartsOneWindowBack(t *testing.T) {
	for _, network := range []config.Network{
		config.NetworkMainnet, config.NetworkECash,
	} {
		t.Run(string(network), func(t *testing.T) {
			assert.Equal(t, 900000-recentScanWindow, parserOn(network).scanFloor(900000))
		})
	}
}

// Signet, testnet and regtest blocks are small or empty, so those scan whole.
func TestScanFloorIsZeroOnSmallChains(t *testing.T) {
	for _, network := range []config.Network{
		config.NetworkSignet, config.NetworkRegtest, config.Network("testnet"),
	} {
		t.Run(string(network), func(t *testing.T) {
			assert.Zero(t, parserOn(network).scanFloor(900000))
		})
	}
}

// A short chain must not wrap around on the unsigned subtraction.
func TestScanFloorIsZeroOnAChainShorterThanTheWindow(t *testing.T) {
	p := parserOn(config.NetworkMainnet)

	for _, tip := range []uint32{0, 1, 200, recentScanWindow} {
		assert.Zero(t, p.scanFloor(tip), "tip %d", tip)
	}
}

// One block past a full window is the first tip that moves the floor.
func TestScanFloorMovesOneBlockPastTheWindow(t *testing.T) {
	assert.Equal(t, uint32(1), parserOn(config.NetworkMainnet).scanFloor(recentScanWindow+1))
}

func TestScanFloorWindowIsAboutAWeek(t *testing.T) {
	assert.Equal(t, uint32(1008), recentScanWindow)
}
