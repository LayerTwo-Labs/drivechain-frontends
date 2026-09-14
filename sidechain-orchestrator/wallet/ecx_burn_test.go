package wallet

import (
	"encoding/hex"
	"math"
	"strconv"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/require"
)

func TestECXBurnAddressAndScriptMatch(t *testing.T) {
	address, err := btcutil.DecodeAddress(ECXBurnAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	require.IsType(t, &btcutil.AddressPubKeyHash{}, address)
	require.True(t, address.IsForNet(&chaincfg.MainNetParams))
	require.Equal(t, ECXBurnAddress, address.EncodeAddress())
	script, err := txscript.PayToAddrScript(address)
	require.NoError(t, err)
	require.Equal(t, ECXBurnScriptHex, hex.EncodeToString(script))
}

func TestECXBurnMinimumIsOneThousandCoins(t *testing.T) {
	require.EqualValues(t, 1000*btcutil.SatoshiPerBitcoin, ECXBurnMinimumSats)
}

func TestECXCreditSatsRoundsUp(t *testing.T) {
	for _, test := range []struct {
		burn   int64
		credit int64
	}{
		{math.MinInt64, -92_233_720_368_547_758},
		{-101, -1},
		{-100, -1},
		{-99, 0},
		{0, 0},
		{1, 1},
		{99, 1},
		{100, 1},
		{101, 2},
		{199, 2},
		{200, 2},
		{100_000_000_000, 1_000_000_000},
		{100_000_000_001, 1_000_000_001},
		{9_007_199_254_740_993, 90_071_992_547_410},
		{math.MaxInt64 - 7, 92_233_720_368_547_758},
		{math.MaxInt64 - 6, 92_233_720_368_547_759},
		{math.MaxInt64, 92_233_720_368_547_759},
	} {
		t.Run(strconv.FormatInt(test.burn, 10), func(t *testing.T) {
			require.Equal(t, test.credit, ECXCreditSats(test.burn))
		})
	}
}
