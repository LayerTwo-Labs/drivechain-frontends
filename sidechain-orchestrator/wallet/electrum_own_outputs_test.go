package wallet

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const strangerAddr = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

// fundedSend puts a confirmed send on the fake index: the wallet address funds
// it, a stranger takes a payment, and changeAddr takes the change.
func fundedSend(fake *fakeEsplora, from, changeAddr string, spent, paid, kept int64) EsploraTx {
	tx := EsploraTx{
		TxID: "5555555555555555555555555555555555555555555555555555555555555555",
		Fee:  spent - paid - kept,
		Vin: []EsploraVin{{
			Prevout: &EsploraVout{ScriptPubKeyAddress: from, Value: spent},
		}},
		Vout: []EsploraVout{
			{ScriptPubKeyAddress: strangerAddr, Value: paid},
			{ScriptPubKeyAddress: changeAddr, Value: kept},
		},
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1700000000},
	}
	fake.stats[from] = EsploraAddressStats{
		Address: from,
		ChainStats: EsploraTxoStats{
			FundedTxoCount: 1, FundedTxoSum: spent,
			SpentTxoCount: 1, SpentTxoSum: spent, TxCount: 2,
		},
	}
	fake.utxos[from] = nil
	fake.txs[from] = []EsploraTx{tx}
	fake.stats[changeAddr] = EsploraAddressStats{
		Address:    changeAddr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: kept, TxCount: 1},
	}
	fake.utxos[changeAddr] = []EsploraUTXO{{
		TxID: tx.TxID, Vout: 1, Value: kept,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1700000000},
	}}
	fake.txs[changeAddr] = []EsploraTx{tx}
	return tx
}

// A full node reserves a change index on every funding call and never gives it
// back, so the change of a send it built sits past the gap the walk stops at.
// The light wallet must still count that coin as its own.
func TestElectrumKeepsChangePastTheGap(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	d, err := p.walletDescriptorFor(w, ScriptNativeSegwit)
	require.NoError(t, err)
	far, err := p.deriveAddr(d, true, 60)
	require.NoError(t, err)

	fundedSend(fake, addr, far.address, 400_000, 90_000, 300_000)

	confirmed, _, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.003, confirmed, 1e-9)

	utxos, err := p.ListUnspent(ctx, w.ID)
	require.NoError(t, err)
	require.Len(t, utxos, 1)
	assert.Equal(t, far.address, utxos[0].Address)

	txs, err := p.ListTransactions(ctx, w.ID, 10)
	require.NoError(t, err)
	require.Len(t, txs, 1, "the change must not read as a second payment out")
	assert.Equal(t, strangerAddr, txs[0].Address)
	assert.InDelta(t, -0.0009, txs[0].Amount, 1e-9)
}

// A change coin lifts the window, so a second coin further out joins the same
// scan. The first lookup misses it, and the wider map holds it.
func TestElectrumKeepsChangeTheFirstWindowMisses(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	d, err := p.walletDescriptorFor(w, ScriptNativeSegwit)
	require.NoError(t, err)
	near, err := p.deriveAddr(d, true, electrumOwnOutputWindow-100)
	require.NoError(t, err)
	far, err := p.deriveAddr(d, true, electrumOwnOutputWindow+500)
	require.NoError(t, err)

	tx := EsploraTx{
		TxID: "7777777777777777777777777777777777777777777777777777777777777777",
		Fee:  10_000,
		Vin:  []EsploraVin{{Prevout: &EsploraVout{ScriptPubKeyAddress: addr, Value: 400_000}}},
		Vout: []EsploraVout{
			{ScriptPubKeyAddress: strangerAddr, Value: 90_000},
			{ScriptPubKeyAddress: near.address, Value: 100_000},
			{ScriptPubKeyAddress: far.address, Value: 200_000},
		},
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1700000000},
	}
	fake.stats[addr] = EsploraAddressStats{
		Address: addr,
		ChainStats: EsploraTxoStats{
			FundedTxoCount: 1, FundedTxoSum: 400_000,
			SpentTxoCount: 1, SpentTxoSum: 400_000, TxCount: 2,
		},
	}
	fake.txs[addr] = []EsploraTx{tx}
	for i, coin := range []struct {
		address string
		value   int64
	}{{near.address, 100_000}, {far.address, 200_000}} {
		fake.stats[coin.address] = EsploraAddressStats{
			Address:    coin.address,
			ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: coin.value, TxCount: 1},
		}
		fake.utxos[coin.address] = []EsploraUTXO{{
			TxID: tx.TxID, Vout: i + 1, Value: coin.value,
			Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1700000000},
		}}
		fake.txs[coin.address] = []EsploraTx{tx}
	}

	confirmed, _, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.003, confirmed, 1e-9)
}

// The change of a send the wallet itself built sits at the first free index, so
// the walk reaches it and the scan holds it one time only.
func TestElectrumKeepsNearChangeOnce(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	d, err := p.walletDescriptorFor(w, ScriptNativeSegwit)
	require.NoError(t, err)
	near, err := p.deriveAddr(d, true, 0)
	require.NoError(t, err)

	fundedSend(fake, addr, near.address, 400_000, 90_000, 300_000)

	scan, err := p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	count := 0
	for _, a := range scan.addrs {
		if a.address == near.address {
			count++
		}
	}
	assert.Equal(t, 1, count)

	confirmed, _, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.003, confirmed, 1e-9)
}

// A payment to somebody else stays a payment: no derived address matches it.
func TestElectrumLeavesAStrangerOut(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address: addr,
		ChainStats: EsploraTxoStats{
			FundedTxoCount: 1, FundedTxoSum: 400_000,
			SpentTxoCount: 1, SpentTxoSum: 400_000, TxCount: 2,
		},
	}
	fake.utxos[addr] = nil
	fake.txs[addr] = []EsploraTx{{
		TxID: "6666666666666666666666666666666666666666666666666666666666666666",
		Fee:  10_000,
		Vin:  []EsploraVin{{Prevout: &EsploraVout{ScriptPubKeyAddress: addr, Value: 400_000}}},
		Vout: []EsploraVout{{ScriptPubKeyAddress: strangerAddr, Value: 390_000}},
		Status: EsploraStatus{
			Confirmed: true, BlockHeight: 100, BlockTime: 1700000000,
		},
	}}

	scan, err := p.scan(ctx, w.ID, false)
	require.NoError(t, err)
	assert.False(t, scan.owns(strangerAddr))

	confirmed, _, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.Zero(t, confirmed)

	// The address is looked up one time: a refresh derives nothing again.
	assert.True(t, p.otherAddrs[w.ID][strangerAddr])
	assert.Empty(t, p.unchecked(w.ID, []string{strangerAddr}))
}

// A chain derives the whole window past its highest used index, whatever that
// index is.
func TestChainWindowsHoldTheWholeWindow(t *testing.T) {
	p, _, w, _ := newElectrumFixture(t)

	segwit := walletChain{ScriptNativeSegwit, true}
	scan := &electrumScan{}
	assert.Equal(t, uint32(electrumOwnOutputWindow), p.chainWindows(w, scan)[segwit])

	for _, used := range []uint32{3, 60, electrumOwnOutputWindow, 4321} {
		scan.addrs = []scannedAddr{{
			kind: ScriptNativeSegwit, change: true, index: used, hdPath: "m/84'/1'/0'/1/0",
			stats: EsploraAddressStats{ChainStats: EsploraTxoStats{TxCount: 1}},
		}}
		end := p.chainWindows(w, scan)[segwit]
		assert.GreaterOrEqual(t, end, used+1+electrumOwnOutputWindow)
	}
}

// A network switch drops the map, so no address of the old chain survives it.
func TestNetworkResetDropsTheAddressMap(t *testing.T) {
	p, _, w, _ := newElectrumFixture(t)

	spots, err := p.spotsFor(w.ID, w, &electrumScan{})
	require.NoError(t, err)
	require.NotEmpty(t, spots)
	p.rememberOther(w.ID, []string{strangerAddr})

	p.ResetNetworkState()

	assert.Empty(t, p.addrSpots[w.ID])
	assert.Empty(t, p.addrSpotWindows[w.ID])
	assert.Empty(t, p.otherAddrs[w.ID])
}

func TestWindowsCover(t *testing.T) {
	segwit := walletChain{ScriptNativeSegwit, false}
	taproot := walletChain{ScriptTaproot, false}

	built := map[walletChain]uint32{segwit: 1000, taproot: 1000}
	assert.True(t, windowsCover(built, map[walletChain]uint32{segwit: 1000}))
	assert.False(t, windowsCover(built, map[walletChain]uint32{segwit: 2000}))
	assert.False(t, windowsCover(built, map[walletChain]uint32{{ScriptLegacy, false}: 1}))
}
