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

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
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

func TestECXBurnNetworkByID(t *testing.T) {
	for id, network := range map[string]ECXBurnNetwork{
		"betanet": {Name: "Betanet", CreditDivisor: 50},
		"ecash":   {},
		"drynet4": {},
		"bitcoin": {},
		"signet":  {},
		"":        {},
	} {
		t.Run(id, func(t *testing.T) {
			require.Equal(t, network, ECXBurnNetworkByID(id))
		})
	}
}

func TestECXBurnAddressHasOneHashOnTheBurnNetwork(t *testing.T) {
	script, err := hex.DecodeString(ECXBurnScriptHex)
	require.NoError(t, err)
	network, found := netcatalog.Embedded().ByID("betanet")
	require.True(t, found)
	require.Equal(t, netcatalog.FamilyECash, network.Family)
	require.Equal(t, "main", network.Chain)
	require.Equal(t, network.DisplayName, ECXBurnNetworkByID("betanet").Name)
	params := config.ChainParamsFor(config.NetworkECash)
	address, err := btcutil.DecodeAddress(ECXBurnAddress, params)
	require.NoError(t, err)
	require.True(t, address.IsForNet(params))
	require.Equal(t, script[3:23], address.ScriptAddress())
}

func TestECXBurnMinimumIsOneThousandCoins(t *testing.T) {
	require.EqualValues(t, 1000*btcutil.SatoshiPerBitcoin, ECXBurnMinimumSats)
}

func TestECXCreditSatsRoundsUpOnBetanet(t *testing.T) {
	for _, test := range []struct {
		burn   int64
		credit int64
	}{
		{math.MinInt64, -184_467_440_737_095_516},
		{-51, -1},
		{-50, -1},
		{-49, 0},
		{0, 0},
		{1, 1},
		{49, 1},
		{50, 1},
		{51, 2},
		{99, 2},
		{100, 2},
		{100_000_000_000, 2_000_000_000},
		{100_000_000_001, 2_000_000_001},
		{9_007_199_254_740_993, 180_143_985_094_820},
		{math.MaxInt64 - 8, 184_467_440_737_095_516},
		{math.MaxInt64 - 7, 184_467_440_737_095_516},
		{math.MaxInt64 - 6, 184_467_440_737_095_517},
		{math.MaxInt64, 184_467_440_737_095_517},
	} {
		t.Run(strconv.FormatInt(test.burn, 10), func(t *testing.T) {
			require.Equal(t, test.credit, ECXBurnNetworkByID("betanet").CreditSats(test.burn))
		})
	}
}
