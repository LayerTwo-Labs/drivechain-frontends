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

func burnTx(txid string, height int, outs ...EsploraVout) EsploraTx {
	return EsploraTx{TxID: txid, Vout: outs, Status: EsploraStatus{Confirmed: height > 0, BlockHeight: height}}
}

func eaterOut(sats int64) EsploraVout {
	return EsploraVout{ScriptPubKey: ECXBurnScriptHex, ScriptPubKeyType: "p2pkh", Value: sats}
}

func payoutOut(t *testing.T, address string) EsploraVout {
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(address)).Script()
	require.NoError(t, err)
	return EsploraVout{ScriptPubKey: hex.EncodeToString(script), ScriptPubKeyType: "op_return"}
}

func TestECXBurnReadsTheBurnAndThePayout(t *testing.T) {
	betanet := ECXBurnNetworkByID("betanet")
	for _, test := range []struct {
		name string
		tx   EsploraTx
		burn ECXBurn
		ok   bool
	}{
		{
			name: "confirmed",
			tx:   burnTx("a", 974041, eaterOut(700_000_000_000), payoutOut(t, "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5"), EsploraVout{ScriptPubKey: "0014aa", Value: 5}),
			burn: ECXBurn{TxID: "a", Height: 974041, BurnSats: 700_000_000_000, PayoutAddress: "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5", PayoutSats: 14_000_000_000},
			ok:   true,
		},
		{
			name: "mempool",
			tx:   burnTx("b", 0, payoutOut(t, "1G5mvGz5tFN6dCW3fSqWy9SEPG3PiArw4Y"), eaterOut(100_000_000_001)),
			burn: ECXBurn{TxID: "b", BurnSats: 100_000_000_001, PayoutAddress: "1G5mvGz5tFN6dCW3fSqWy9SEPG3PiArw4Y", PayoutSats: 2_000_000_001},
			ok:   true,
		},
		{
			name: "two burn outputs add up",
			tx:   burnTx("c", 5, eaterOut(60_000_000_000), eaterOut(40_000_000_000), payoutOut(t, "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk"), payoutOut(t, "1G5mvGz5tFN6dCW3fSqWy9SEPG3PiArw4Y")),
			burn: ECXBurn{TxID: "c", Height: 5, BurnSats: 100_000_000_000, PayoutAddress: "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk", PayoutSats: 2_000_000_000},
			ok:   true,
		},
		{
			name: "no payout address",
			tx:   burnTx("d", 5, eaterOut(100_000_000_000)),
			burn: ECXBurn{TxID: "d", Height: 5, BurnSats: 100_000_000_000, PayoutSats: 2_000_000_000},
			ok:   true,
		},
		{
			name: "binary payout data",
			tx:   burnTx("g", 5, eaterOut(100_000_000_000), EsploraVout{ScriptPubKey: "6a01ff", ScriptPubKeyType: "op_return"}),
			burn: ECXBurn{TxID: "g", Height: 5, BurnSats: 100_000_000_000, PayoutSats: 2_000_000_000},
			ok:   true,
		},
		{
			name: "spreadsheet formula",
			tx:   burnTx("h", 5, eaterOut(100_000_000_000), payoutOut(t, "=HYPERLINK(\"https://example.com\")")),
			burn: ECXBurn{TxID: "h", Height: 5, BurnSats: 100_000_000_000, PayoutSats: 2_000_000_000},
			ok:   true,
		},
		{
			name: "testnet address",
			tx:   burnTx("i", 5, eaterOut(100_000_000_000), payoutOut(t, "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx")),
			burn: ECXBurn{TxID: "i", Height: 5, BurnSats: 100_000_000_000, PayoutSats: 2_000_000_000},
			ok:   true,
		},
		{
			name: "below the minimum",
			tx:   burnTx("e", 5, eaterOut(99_999_999_999), payoutOut(t, "bc1q")),
		},
		{
			name: "no burn",
			tx:   burnTx("f", 5, payoutOut(t, "omni")),
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			burn, ok := betanet.Burn(test.tx)
			require.Equal(t, test.ok, ok)
			require.Equal(t, test.burn, burn)
		})
	}
}

func TestECXBurnCSV(t *testing.T) {
	text, err := ECXBurnCSV([]ECXBurn{
		{BurnSats: 700_000_000_000, PayoutAddress: "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5", PayoutSats: 14_000_000_000},
		{BurnSats: 101_898_226_480, PayoutAddress: "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk", PayoutSats: 2_037_964_530},
		{BurnSats: 100_000_000_000, PayoutAddress: "a,\"b\"", PayoutSats: 2_000_000_000},
	})
	require.NoError(t, err)
	require.Equal(t, "burn_amount,payout_address,payout_amount\n"+
		"7000.00000000,bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5,140.00000000\n"+
		"1018.98226480,3HxectQ44ECnadiofJjPGRMukEEAkjWjFk,20.37964530\n"+
		"1000.00000000,\"a,\"\"b\"\"\",20.00000000\n", text)
}

func TestECXBurnCSVWithNoBurns(t *testing.T) {
	text, err := ECXBurnCSV(nil)
	require.NoError(t, err)
	require.Equal(t, "burn_amount,payout_address,payout_amount\n", text)
}
