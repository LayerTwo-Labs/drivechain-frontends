package wallet

import (
	"context"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestBurnPSBTKeepsOutputsAndFee(t *testing.T) {
	testBurnPSBT(t, false)
}

func TestMultisigBurnPSBTKeepsOutputsAndFee(t *testing.T) {
	testBurnPSBT(t, true)
}

func testBurnPSBT(t *testing.T, multisig bool) {
	t.Helper()
	cli, daemon := findBitcoinTools(t)
	rt := newRegtest(t, cli, daemon)
	defer rt.stop()
	rt.rpc(t, nil, "createwallet", "miner")
	var minerAddress string
	rt.walletRPC(t, "miner", &minerAddress, "getnewaddress")
	rt.rpc(t, nil, "generatetoaddress", "141", minerAddress)

	svc := newTestService(t)
	params := &chaincfg.RegressionNetParams
	var w *WalletData
	var err error
	if multisig {
		w, err = svc.CreateElectrumMultisig("Burn", nil, 2, 3, "wsh", []MultisigCosigner{
			multisigTestCosigner(t, params, 0, true),
			multisigTestCosigner(t, params, 1, true),
			multisigTestCosigner(t, params, 2, false),
		})
	} else {
		w, err = svc.CreateElectrumWallet("Burn", nil, nil, testMnemonic, "", "", "", 0, "")
	}
	require.NoError(t, err)
	addresses, err := DeriveWalletReceiveAddresses(w, params, 0, 1)
	require.NoError(t, err)
	address := addresses[0]
	var fundTxid string
	rt.walletRPC(t, "miner", &fundTxid, "sendtoaddress", address, "2000")
	var fundHex string
	rt.rpc(t, &fundHex, "getrawtransaction", fundTxid)
	fund, err := DecodeTransaction(fundHex, params)
	require.NoError(t, err)
	var fundIndex uint32
	for _, output := range fund.Outputs {
		if output.Address == address {
			fundIndex = uint32(output.Index)
			require.EqualValues(t, 200_000_000_000, output.ValueSats)
		}
	}
	rt.rpc(t, nil, "generatetoaddress", "1", minerAddress)

	source := newFakeEsplora()
	source.stats[address] = EsploraAddressStats{
		Address:    address,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000_000_000, TxCount: 1},
	}
	source.utxos[address] = []EsploraUTXO{{
		TxID: fundTxid, Vout: int(fundIndex), Value: 200_000_000_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 142},
	}}
	source.hexByID[fundTxid] = fundHex
	backend := NewElectrumBackend(svc, source, StaticParams(params), zerolog.New(zerolog.NewTestWriter(t)))
	productionBurn, err := btcutil.DecodeAddress(ECXBurnAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	burn, err := btcutil.NewAddressPubKeyHash(productionBurn.ScriptAddress(), params)
	require.NoError(t, err)
	burnAmount := ECXBurnMinimumSats + 1
	ctx := context.Background()
	unsigned, err := backend.CreatePSBT(ctx, w.ID, SendRequest{
		DestinationsSats: map[string]int64{burn.EncodeAddress(): burnAmount},
		OpReturnHex:      hex.EncodeToString([]byte(address)),
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)
	preview, err := DecodeTransaction(unsigned, params)
	require.NoError(t, err)
	require.True(t, preview.HasFee)
	require.Positive(t, preview.FeeSats)
	require.Len(t, preview.Outputs, 3)
	require.Equal(t, burn.EncodeAddress(), preview.Outputs[0].Address)
	require.Equal(t, burnAmount, preview.Outputs[0].ValueSats)
	require.EqualValues(t, 1_000_000_001, ECXCreditSats(burnAmount))
	require.Zero(t, preview.Outputs[1].ValueSats)
	script, err := hex.DecodeString(preview.Outputs[1].ScriptPubKeyHex)
	require.NoError(t, err)
	require.Equal(t, byte(txscript.OP_RETURN), script[0])
	data, err := txscript.PushedData(script)
	require.NoError(t, err)
	require.Equal(t, [][]byte{[]byte(address)}, data)
	change := preview.Outputs[2].Address
	owned, err := backend.OwnedAddresses(ctx, w.ID, []string{address, burn.EncodeAddress(), change})
	require.NoError(t, err)
	require.Equal(t, map[string]bool{address: false, change: true}, owned)

	var signed string
	if multisig {
		first, err := backend.SignPSBTWithCosigner(ctx, w.ID, unsigned, w.Multisig.Cosigners[0].Xpub)
		require.NoError(t, err)
		status, err := MultisigPsbtSigningStatus(first, w.Multisig.Cosigners)
		require.NoError(t, err)
		require.Equal(t, 1, status.Signatures)
		require.False(t, status.Finalizable)
		_, err = backend.FinalizePSBT(first)
		require.Error(t, err)
		second, err := backend.SignPSBTWithCosigner(ctx, w.ID, unsigned, w.Multisig.Cosigners[1].Xpub)
		require.NoError(t, err)
		signed, err = backend.CombinePSBT([]string{unsigned, first, second})
		require.NoError(t, err)
		status, err = MultisigPsbtSigningStatus(signed, w.Multisig.Cosigners)
		require.NoError(t, err)
		require.Equal(t, 2, status.Signatures)
		require.True(t, status.Finalizable)
	} else {
		signed, err = backend.SignPSBT(ctx, w.ID, unsigned)
		require.NoError(t, err)
	}
	raw, err := backend.FinalizePSBT(signed)
	require.NoError(t, err)
	final, err := DecodeTransaction(raw, params)
	require.NoError(t, err)
	for i, output := range preview.Outputs {
		require.Equal(t, output.ValueSats, final.Outputs[i].ValueSats)
		require.Equal(t, output.ScriptPubKeyHex, final.Outputs[i].ScriptPubKeyHex)
	}
	require.Equal(t, preview.FeeSats, int64(200_000_000_000)-final.TotalOutput)
	var txid string
	rt.rpc(t, &txid, "sendrawtransaction", raw)
	require.Equal(t, final.TxID, txid)
	rt.rpc(t, nil, "getmempoolentry", txid)

	again, err := DeriveWalletReceiveAddresses(w, params, 0, 1)
	require.NoError(t, err)
	require.Equal(t, addresses, again)
}
